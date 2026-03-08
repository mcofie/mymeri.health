import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const WHATSAPP_API_TOKEN = Deno.env.get('WHATSAPP_API_TOKEN')!
const WHATSAPP_PHONE_NUMBER_ID = Deno.env.get('WHATSAPP_PHONE_NUMBER_ID')!

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    db: { schema: 'mera' }
})

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

Deno.serve(async (req: Request) => {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { subscription_id } = await req.json()

        if (!subscription_id) {
            throw new Error('Subscription ID is required')
        }

        // Fetch subscription and profile details
        const { data: sub, error: subError } = await supabase
            .from('subscriptions')
            .select(`
                id,
                user_id,
                box_tier,
                profiles (whatsapp_id, full_name, country_code)
            `)
            .eq('id', subscription_id)
            .single()

        if (subError || !sub) throw new Error('Subscription not found')

        // Handle profile as object or single-item array
        const profile = Array.isArray(sub.profiles) ? sub.profiles[0] : sub.profiles

        if (!profile || !profile.whatsapp_id) {
            throw new Error(`Profile data incomplete for subscription ${subscription_id}`)
        }

        console.log(`Sending nudge to ${profile.full_name} (${profile.whatsapp_id}) for sub ${subscription_id}`)

        // Send the WhatsApp "Pulse Check" template
        const result = await sendWhatsAppTemplate(
            profile.whatsapp_id,
            'pulse_check',
            profile.country_code,
            [profile.full_name]
        )

        console.log('WhatsApp send result:', JSON.stringify(result))

        // Log the message in our internal chat history
        await supabase.from('messages').insert({
            whatsapp_id: profile.whatsapp_id,
            direction: 'OUTBOUND',
            content: `Sent manual nudge: Welcome to your cycle care!`,
            metadata: { type: 'manual_nudge', template: 'pulse_check' }
        })

        return new Response(JSON.stringify({
            message: 'Manual nudge sent successfully',
            recipient: profile.full_name,
            whatsapp_id: profile.whatsapp_id
        }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })

    } catch (err: any) {
        console.error('Manual Nudge Error:', err.message)
        return new Response(JSON.stringify({
            error: err.message,
            stack: err.stack,
            details: 'Check function logs in Supabase dashboard for full trace'
        }), {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
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
        const errText = await res.text()
        console.error(`Failed to send WhatsApp message to ${to}:`, errText)
        throw new Error(`WhatsApp API error: ${errText}`)
    }

    return await res.json()
}
