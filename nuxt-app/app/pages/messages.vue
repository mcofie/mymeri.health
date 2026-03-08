<template>
  <NuxtLayout name="dashboard">
    <div class="chat-page glass">
      <!-- Contact List -->
      <aside class="contacts-sidebar">
        <header class="sidebar-header">
          <div class="header-main">
            <h3>Customer Chats</h3>
            <div class="live-pill">
              <span class="live-blink">●</span>
              <span>WhatsApp Live</span>
            </div>
          </div>
        </header>

        <div class="search-box">
          <div class="search-inner glass">
            <span class="search-icon">🔍</span>
            <input v-model="contactSearch" type="text" placeholder="Search customer..." class="glass-input-sm-clean" />
          </div>
        </div>

        <div class="contacts-list thin-scrollbar">
          <div 
            v-for="contact in filteredContacts" 
            :key="contact.id" 
            class="contact-item" 
            :class="{ active: activeContact?.id === contact.id }"
            @click="activeContact = contact"
          >
            <div class="avatar-wrap">
               <div class="avatar-box">{{ contact.full_name?.charAt(0) || '?' }}</div>
               <span v-if="contact.unread" class="unread-pulse"></span>
            </div>
            <div class="contact-info">
              <div class="name-row">
                 <span class="contact-name">{{ contact.full_name || 'Anonymous' }}</span>
                 <span class="country-hint">{{ contact.country_code }}</span>
              </div>
              <span class="last-msg">{{ contact.last_message || 'No messages yet' }}</span>
            </div>
          </div>
          
          <div v-if="filteredContacts.length === 0" class="mini-empty">
            <p>No chats found.</p>
          </div>
        </div>
      </aside>

      <!-- Message Area -->
      <main class="message-area" v-if="activeContact">
        <header class="chat-header">
          <div class="active-user">
            <div class="avatar-md-premium">{{ activeContact.full_name?.charAt(0) }}</div>
            <div class="user-details">
              <h3>{{ activeContact.full_name }}</h3>
              <p class="whatsapp-id">WA: {{ activeContact.whatsapp_id }}</p>
            </div>
          </div>
          <div class="header-actions">
            <a v-if="activeContact.google_maps_link" :href="activeContact.google_maps_link" target="_blank" class="util-btn glass" title="Delivery Location">📍 Map</a>
            <button class="util-btn glass" title="More Options">⋮</button>
          </div>
        </header>

        <div class="messages-container thin-scrollbar" ref="messageContainer">
          <div 
            v-for="msg in messages" 
            :key="msg.id" 
            class="msg-wrapper" 
            :class="msg.direction.toLowerCase()"
          >
            <div class="msg-bubble glass">
              <p>{{ msg.content }}</p>
              <div class="msg-footer">
                <span class="msg-time">{{ formatTime(msg.created_at) }}</span>
                <span v-if="msg.direction === 'OUTBOUND'" class="read-receipt">✓✓</span>
              </div>
            </div>
          </div>
        </div>

        <footer class="input-area">
          <form @submit.prevent="sendMessage" class="chat-form">
            <button type="button" class="tool-btn" title="Attach Item">📎</button>
            <div class="input-wrap glass">
               <input 
                 v-model="newMessage" 
                 type="text" 
                 placeholder="Type message to subscriber..." 
                 class="main-chat-input"
               />
            </div>
            <button type="submit" class="send-btn-nexus" :disabled="!newMessage.trim()">
              <span>✈</span>
            </button>
          </form>
        </footer>
      </main>

      <div v-else class="empty-chat-nexus animate-fade-in">
        <div class="nexus-glow"></div>
        <div class="nexus-illustration">💬</div>
        <h2>WhatsApp Nexus</h2>
        <p>Syncing with your Business API. Select a soul to start the conversation.</p>
        <div class="nexus-status-pills">
           <span class="nexus-pill">Live API: Connected</span>
           <span class="nexus-pill">Webhooks: Active</span>
        </div>
      </div>
    </div>
  </NuxtLayout>
</template>

<script setup>
const supabase = useSupabaseClient()
const activeContact = ref(null)
const contactSearch = ref('')
const newMessage = ref('')
const messageContainer = ref(null)

const contacts = ref([])
const messages = ref([])

const fetchContacts = async () => {
  const { data } = await supabase.from('profiles').select('*').limit(20)
  contacts.value = data || []
  if (contacts.value.length > 0 && !activeContact.value) {
    activeContact.value = contacts.value[0]
  }
}

const filteredContacts = computed(() => {
  if (!contactSearch.value) return contacts.value
  const q = contactSearch.value.toLowerCase()
  return contacts.value.filter(c => 
    c.full_name?.toLowerCase().includes(q) || 
    c.whatsapp_id?.includes(q)
  )
})

const fetchMessages = async () => {
  if (!activeContact.value) return
  const { data } = await supabase
    .from('messages')
    .select('*')
    .eq('whatsapp_id', activeContact.value.whatsapp_id)
    .order('created_at', { ascending: true })
  
  messages.value = data || []
  scrollToBottom()
}

const sendMessage = async () => {
  if (!newMessage.value.trim() || !activeContact.value) return
  
  const content = newMessage.value
  newMessage.value = ''

  const { data, error } = await supabase.from('messages').insert({
    whatsapp_id: activeContact.value.whatsapp_id,
    direction: 'OUTBOUND',
    content: content
  })

  // Local optimistic update
  if (!error) {
    // In a real app we'd wait for realtime, but let's push for UX
    messages.value.push({
      id: Math.random(),
      direction: 'OUTBOUND',
      content: content,
      created_at: new Date().toISOString()
    })
    scrollToBottom()
  }
}

const formatTime = (iso) => {
  return new Date(iso).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

const scrollToBottom = () => {
  nextTick(() => {
    if (messageContainer.value) {
      messageContainer.value.scrollTop = messageContainer.value.scrollHeight
    }
  })
}

let messageSubscription = null

const setupRealtime = () => {
  messageSubscription = supabase
    .channel('public:messages')
    .on('postgres_changes', { 
      event: 'INSERT', 
      schema: 'mera', 
      table: 'messages'
    }, (payload) => {
      if (activeContact.value && payload.new.whatsapp_id === activeContact.value.whatsapp_id) {
        const exists = messages.value.some(m => m.id === payload.new.id)
        if (!exists) {
          messages.value.push(payload.new)
          scrollToBottom()
        }
      }
      
      const contact = contacts.value.find(c => c.whatsapp_id === payload.new.whatsapp_id)
      if (contact) {
        contact.last_message = payload.new.content
        if (activeContact.value?.whatsapp_id !== payload.new.whatsapp_id) {
          contact.unread = true
        }
      }
    })
    .subscribe()
}

watch(activeContact, fetchMessages)

onMounted(() => {
  fetchContacts()
  setupRealtime()
})

onUnmounted(() => {
  if (messageSubscription) supabase.removeChannel(messageSubscription)
})
</script>

<style scoped>
.chat-page {
  display: flex;
  height: calc(100vh - 120px);
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 12px 40px rgba(0,0,0,0.1);
}

/* Contacts Sidebar */
.contacts-sidebar {
  width: 380px;
  border-right: 1px solid var(--mera-border);
  display: flex;
  flex-direction: column;
  background: rgba(255, 255, 255, 0.05);
}

.sidebar-header { padding: 32px 32px 24px; }
.header-main h3 { font-size: 20px; font-weight: 800; margin-bottom: 8px; }

.live-pill {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 10px;
  font-weight: 800;
  text-transform: uppercase;
  color: #34c759;
  background: rgba(52, 199, 89, 0.1);
  padding: 4px 10px;
  border-radius: 40px;
  width: fit-content;
}

.live-blink { animation: blink 2s infinite; }
@keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0.3; } }

.search-box { padding: 0 32px 20px; }
.search-inner { display: flex; align-items: center; padding: 10px 16px; gap: 10px; border-radius: 12px; }
.search-icon { opacity: 0.5; font-size: 14px; }
.glass-input-sm-clean { background: none; border: none; color: var(--mera-text); width: 100%; font-size: 13px; }
.glass-input-sm-clean:focus { outline: none; }

.contacts-list { flex: 1; overflow-y: auto; padding-bottom: 20px; }

.contact-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 32px;
  cursor: pointer;
  transition: all 0.2s;
  position: relative;
}

.contact-item:hover { background: rgba(255, 255, 255, 0.05); }
.contact-item.active { background: rgba(255, 77, 148, 0.1); }
.contact-item.active::after { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: var(--mera-primary); }

.avatar-wrap { position: relative; }
.avatar-box {
  width: 48px;
  height: 48px;
  background: #f0f0f0;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 800;
  color: var(--mera-primary);
}

.unread-pulse {
  position: absolute;
  top: -2px;
  right: -2px;
  width: 12px;
  height: 12px;
  background: var(--mera-primary);
  border: 2px solid white;
  border-radius: 50%;
}

.contact-info { flex: 1; display: flex; flex-direction: column; gap: 4px; overflow: hidden; }
.name-row { display: flex; justify-content: space-between; align-items: center; }
.contact-name { font-weight: 800; font-size: 15px; }
.country-hint { font-size: 10px; opacity: 0.5; font-weight: 700; }
.last-msg { font-size: 12px; color: var(--mera-text-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

/* Message Area */
.message-area { flex: 1; display: flex; flex-direction: column; background: rgba(255, 255, 255, 0.02); }

.chat-header {
  padding: 24px 40px;
  border-bottom: 1px solid var(--mera-border);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.active-user { display: flex; gap: 16px; align-items: center; }
.avatar-md-premium {
  width: 52px;
  height: 52px;
  border-radius: 16px;
  background: linear-gradient(135deg, var(--mera-primary), var(--mera-accent));
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: 800;
  box-shadow: 0 4px 15px rgba(255, 77, 148, 0.3);
}

.user-details h3 { font-size: 18px; font-weight: 800; }
.whatsapp-id { font-size: 12px; color: var(--mera-text-muted); font-weight: 600; }

.util-btn {
  padding: 8px 16px;
  border-radius: 12px;
  font-size: 13px;
  font-weight: 700;
  color: var(--mera-text);
  text-decoration: none;
  cursor: pointer;
  border: none;
}

.messages-container {
  flex: 1;
  padding: 40px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.msg-wrapper { display: flex; width: 100%; }
.msg-wrapper.outbound { justify-content: flex-end; }
.msg-wrapper.inbound { justify-content: flex-start; }

.msg-bubble {
  max-width: 65%;
  padding: 16px 20px;
  border-radius: 20px;
  position: relative;
}

.outbound .msg-bubble {
  border-bottom-right-radius: 4px;
  background: linear-gradient(135deg, var(--mera-primary), var(--mera-accent));
  color: white;
}

.inbound .msg-bubble { border-bottom-left-radius: 4px; }

.msg-footer { display: flex; justify-content: flex-end; align-items: center; gap: 6px; margin-top: 6px; }
.msg-time { font-size: 10px; opacity: 0.6; font-weight: 700; }
.read-receipt { font-size: 10px; color: white; opacity: 0.8; }

.input-area { padding: 32px 40px; }
.chat-form { display: flex; gap: 20px; align-items: center; }
.tool-btn { background: none; border: none; font-size: 22px; cursor: pointer; opacity: 0.5; }

.input-wrap { flex: 1; padding: 4px 20px; border-radius: 20px; }
.main-chat-input { background: none; border: none; color: var(--mera-text); width: 100%; padding: 12px 0; font-size: 15px; }
.main-chat-input:focus { outline: none; }

.send-btn-nexus {
  width: 52px;
  height: 52px;
  border-radius: 16px;
  background: var(--mera-primary);
  border: none;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 20px;
  box-shadow: 0 4px 15px rgba(255, 77, 148, 0.4);
}

.empty-chat-nexus {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  gap: 24px;
  position: relative;
}

.nexus-illustration { font-size: 100px; transform: rotate(-5deg); filter: drop-shadow(0 10px 20px rgba(0,0,0,0.1)); }
.empty-chat-nexus h2 { font-size: 32px; font-weight: 800; }
.empty-chat-nexus p { color: var(--mera-text-muted); max-width: 400px; line-height: 1.6; }

.nexus-status-pills { display: flex; gap: 12px; }
.nexus-pill { font-size: 11px; font-weight: 800; text-transform: uppercase; color: var(--mera-text-muted); background: rgba(0,0,0,0.03); padding: 6px 16px; border-radius: 40px; }

.thin-scrollbar::-webkit-scrollbar { width: 4px; }
.thin-scrollbar::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.1); border-radius: 10px; }
</style>
