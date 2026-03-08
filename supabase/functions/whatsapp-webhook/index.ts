import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const VERIFY_TOKEN = Deno.env.get('WHATSAPP_VERIFY_TOKEN') || 'mymera_secure_token'

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    db: { schema: 'mera' }
})

Deno.serve(async (req: Request) => {
    const { method } = req
    const url = new URL(req.url)

    // 1. Handle Webhook Verification (GET)
    if (method === 'GET') {
        const mode = url.searchParams.get('hub.mode')
        const token = url.searchParams.get('hub.verify_token')
        const challenge = url.searchParams.get('hub.challenge')

        if (mode === 'subscribe' && token === VERIFY_TOKEN) {
            console.log('Webhook Verified!')
            return new Response(challenge, { status: 200 })
        }
        return new Response('Forbidden', { status: 403 })
    }

    // 2. Handle Incoming Messages (POST)
    if (method === 'POST') {
        try {
            const body = await req.json()

            // WhatsApp payload structure: entry[] -> changes[] -> value -> messages[]
            const entry = body.entry?.[0]
            const changes = entry?.changes?.[0]
            const value = changes?.value
            const message = value?.messages?.[0]

            if (message) {
                const whatsapp_id = message.from
                const text = message.text?.body || '[Non-text message]'

                // Insert into our database
                const { error } = await supabase.from('messages').insert({
                    whatsapp_id: whatsapp_id,
                    direction: 'INBOUND',
                    content: text,
                    metadata: {
                        wa_id: message.id,
                        timestamp: message.timestamp,
                        raw: message
                    }
                })

                if (error) {
                    console.error('Database Error:', error)
                } else {
                    console.log(`Saved inbound message from ${whatsapp_id}`)
                }
            }

            // Always return 200 OK to WhatsApp
            return new Response(JSON.stringify({ status: 'ok' }), {
                status: 200,
                headers: { 'Content-Type': 'application/json' }
            })
        } catch (err: any) {
            console.error('Webhook Error:', err.message)
            return new Response(JSON.stringify({ error: err.message }), {
                status: 500,
                headers: { 'Content-Type': 'application/json' }
            })
        }
    }

    return new Response('Method Not Allowed', { status: 405 })
})
