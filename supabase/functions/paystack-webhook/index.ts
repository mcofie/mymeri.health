import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'
import { crypto } from "https://deno.land/std@0.210.0/crypto/mod.ts";

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY')!

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    db: { schema: 'mera' }
})

Deno.serve(async (req: Request) => {
    try {
        const signature = req.headers.get('x-paystack-signature')
        if (!signature) {
            return new Response('No signature', { status: 401 })
        }

        const body = await req.text()

        // 1. Verify Signature
        const hash = await hmacSha512(PAYSTACK_SECRET_KEY, body)
        if (hash !== signature) {
            return new Response('Invalid signature', { status: 401 })
        }

        const payload = JSON.parse(body)
        const event = payload.event

        if (event === 'charge.success') {
            const data = payload.data
            const reference = data.reference

            // 2. Update Order (and get data for alerts)
            const { data: order, error: orderError } = await supabase
                .from('orders')
                .update({
                    status: 'Paid',
                    paystack_reference: reference,
                    updated_at: new Date().toISOString()
                })
                .select(`
                    *,
                    profiles (full_name),
                    subscriptions (box_tier, last_period_date, cycle_length)
                `)
                .eq('id', data.metadata?.order_id || reference)
                .single()

            if (orderError) throw orderError

            // 3. Send Discord Alert
            await sendDiscordAlert({
                name: (order as any).profiles?.full_name || 'Customer',
                amount: (order as any).total_amount,
                currency: (order as any).currency,
                tier: (order as any).subscriptions?.box_tier || 'Custom',
                is_discreet: (order as any).is_discreet_packaging,
                country: (order as any).country_code
            })

            // 4. Generate Packing List Entry
            const { data: orderItems, error: itemsError } = await supabase
                .from('order_items')
                .select(`
                    *,
                    inventory (name, stock_level, category)
                `)
                .eq('order_id', (order as any).id)

            if (itemsError) throw itemsError

            const { error: packingError } = await supabase
                .from('packing_slips')
                .insert({
                    order_id: (order as any).id,
                    status: 'To Pack',
                    items_json: {
                        tier: (order as any).subscriptions?.box_tier || 'Custom',
                        items: orderItems,
                        metadata: data.metadata
                    },
                    is_discreet: (order as any).is_discreet_packaging,
                    country_code: (order as any).country_code
                })

            if (packingError) console.error('Error creating packing slip:', packingError)

            // 4. Update Inventory (Stock Management)
            for (const item of (orderItems as any[]) || []) {
                const { error: stockError } = await supabase
                    .from('inventory')
                    .update({ stock_level: item.inventory.stock_level - item.quantity })
                    .eq('id', item.inventory_id)

                if (stockError) console.error(`Error updating stock for ${item.inventory.name}:`, stockError)
            }

            // 5. Update Subscription's last_period_date
            if ((order as any).subscription_id && (order as any).scheduled_for_date) {
                const { error: subUpdateError } = await supabase
                    .from('subscriptions')
                    .update({
                        last_period_date: (order as any).scheduled_for_date,
                        updated_at: new Date().toISOString()
                    })
                    .eq('id', (order as any).subscription_id)

                if (subUpdateError) console.error('Error updating subscription:', subUpdateError)
            }
        }

        return new Response(JSON.stringify({ received: true }), {
            headers: { 'Content-Type': 'application/json' },
        })
    } catch (err: any) {
        console.error('Webhook Error:', err.message)
        return new Response(JSON.stringify({ error: err.message }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' },
        })
    }
})

async function sendDiscordAlert(info: { name: string, amount: number, currency: string, tier: string, is_discreet: boolean, country: string }) {
    const WEBHOOK_URL = Deno.env.get('DISCORD_WEBHOOK_URL')
    if (!WEBHOOK_URL) {
        console.log('No DISCORD_WEBHOOK_URL set, skipping notification.')
        return
    }

    const payload = {
        embeds: [{
            title: "📦 New MyMeri Order Confirmed!",
            color: 0xFF4D94, // Premium Pink
            fields: [
                { name: "Customer", value: info.name, inline: true },
                { name: "Amount", value: `${info.currency} ${info.amount}`, inline: true },
                { name: "Market", value: info.country === 'GH' ? 'Ghana 🇬🇭' : info.country === 'NG' ? 'Nigeria 🇳🇬' : 'Kenya 🇰🇪', inline: true },
                { name: "Subscription Tier", value: info.tier, inline: true },
                { name: "Packaging", value: info.is_discreet ? "Discreet 🤫" : "Standard 🌸", inline: true },
            ],
            footer: { text: "Fulfillment Required via Dashbaord" },
            timestamp: new Date().toISOString()
        }]
    }

    try {
        await fetch(WEBHOOK_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        })
    } catch (e) {
        console.error('Failed to send Discord alert:', e)
    }
}

async function hmacSha512(key: string, message: string) {
    const enc = new TextEncoder()
    const cryptoKey = await crypto.subtle.importKey(
        "raw",
        enc.encode(key),
        { name: "HMAC", hash: "SHA-512" },
        false,
        ["sign"]
    )
    const signature = await crypto.subtle.sign("HMAC", cryptoKey, enc.encode(message))
    return Array.from(new Uint8Array(signature))
        .map(b => b.toString(16).padStart(2, "0"))
        .join("")
}
