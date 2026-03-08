import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const WHATSAPP_API_TOKEN = Deno.env.get('WHATSAPP_API_TOKEN')!
const WHATSAPP_PHONE_NUMBER_ID = Deno.env.get('WHATSAPP_PHONE_NUMBER_ID')!

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    db: { schema: 'mera' }
})

Deno.serve(async (req: Request) => {
    try {
        // 1. Pulse Check (7 days away)
        const sevenDaysAway = new Date()
        sevenDaysAway.setDate(sevenDaysAway.getDate() + 7)
        const sevenDaysStr = sevenDaysAway.toISOString().split('T')[0]

        const currentHour = new Date().getUTCHours()

        const { data: pulseChecks, error: pulseError } = await supabase
            .from('subscriptions')
            .select(`
                id,
                user_id,
                next_period_date,
                profiles (whatsapp_id, full_name, country_code, timezone)
            `)
            .eq('next_period_date', sevenDaysStr)
            .eq('status', 'Active')
        // Add a conceptual check for local 9 AM
        // In a real staging, you'd calculate this based on profiles.timezone
        // .filter('profiles.timezone_offset', 'eq', 9 - currentHour) 

        if (pulseError) throw pulseError

        // 2. Payment Invoice (3 days away)
        const threeDaysAway = new Date()
        threeDaysAway.setDate(threeDaysAway.getDate() + 3)
        const threeDaysStr = threeDaysAway.toISOString().split('T')[0]

        const { data: invoices, error: invoiceError } = await supabase
            .from('subscriptions')
            .select(`
                id,
                user_id,
                next_period_date,
                box_tier,
                profiles (whatsapp_id, full_name, country_code)
            `)
            .eq('next_period_date', threeDaysStr)
            .eq('status', 'Active')

        if (invoiceError) throw invoiceError

        // Process Pulse Checks
        for (const sub of (pulseChecks as any[]) || []) {
            await sendWhatsAppTemplate(
                sub.profiles.whatsapp_id,
                'pulse_check',
                sub.profiles.country_code,
                [sub.profiles.full_name]
            )
        }

        // Process Invoices
        for (const sub of (invoices as any[]) || []) {
            // Create a pending order for this cycle
            const { data: order, error: orderError } = await supabase
                .from('orders')
                .insert({
                    subscription_id: sub.id,
                    user_id: sub.user_id,
                    status: 'Pending',
                    total_amount: calculatePrice(sub.box_tier, sub.profiles.country_code),
                    currency: getCurrency(sub.profiles.country_code),
                    country_code: sub.profiles.country_code,
                    scheduled_for_date: sub.next_period_date
                })
                .select()
                .single()

            if (orderError) console.error('Error creating order:', orderError)

            if (order) {
                await sendWhatsAppTemplate(
                    sub.profiles.whatsapp_id,
                    'payment_invoice',
                    sub.profiles.country_code,
                    [sub.profiles.full_name, order.total_amount, order.currency]
                )
            }
        }

        return new Response(JSON.stringify({ message: 'Success', pulseCount: pulseChecks?.length, invoiceCount: invoices?.length }), {
            headers: { 'Content-Type': 'application/json' },
        })
    } catch (err: any) {
        return new Response(JSON.stringify({ error: err.message }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' },
        })
    }
})

async function sendWhatsAppTemplate(to: string, template: string, countryCode: string, components: any[]) {
    const url = `https://graph.facebook.com/v18.0/${WHATSAPP_PHONE_NUMBER_ID}/messages`

    const body = {
        messaging_product: 'whatsapp',
        to: to,
        type: 'template',
        template: {
            name: template,
            language: { code: 'en' },
            components: [
                {
                    type: 'body',
                    parameters: components.map(c => ({ type: 'text', text: String(c) }))
                }
            ]
        }
    }

    const res = await fetch(url, {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${WHATSAPP_API_TOKEN}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(body)
    })

    if (!res.ok) {
        console.error(`Failed to send WhatsApp message to ${to}:`, await res.text())
    }
}

function calculatePrice(tier: string, country: string): number {
    const prices: Record<string, Record<string, number>> = {
        'GH': { 'Essential': 100, 'Comfort': 200, 'Eco': 150 },
        'NG': { 'Essential': 5000, 'Comfort': 10000, 'Eco': 7500 },
        'KE': { 'Essential': 1000, 'Comfort': 2000, 'Eco': 1500 }
    }
    return prices[country]?.[tier] || 100
}

function getCurrency(country: string): string {
    const currencies: Record<string, string> = { 'GH': 'GHS', 'NG': 'NGN', 'KE': 'KES' }
    return currencies[country] || 'GHS'
}
