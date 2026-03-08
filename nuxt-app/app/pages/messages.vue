<template>
  <NuxtLayout name="dashboard">
    <div class="chat-page glass">
      <!-- Contact List -->
      <aside class="contacts-sidebar">
        <header class="sidebar-header">
          <h3>Customer Chats</h3>
          <span class="online-status">● Live</span>
        </header>
        <div class="search-box">
          <input type="text" placeholder="Search customer..." class="glass-input-sm" />
        </div>
        <div class="contacts-list">
          <div 
            v-for="contact in contacts" 
            :key="contact.id" 
            class="contact-item" 
            :class="{ active: activeContact?.id === contact.id }"
            @click="activeContact = contact"
          >
            <div class="avatar-sm"></div>
            <div class="contact-info">
              <span class="contact-name">{{ contact.full_name }}</span>
              <span class="last-msg">{{ contact.last_message || 'No messages yet' }}</span>
            </div>
            <span v-if="contact.unread" class="unread-dot"></span>
          </div>
        </div>
      </aside>

      <!-- Message Area -->
      <main class="message-area" v-if="activeContact">
        <header class="chat-header">
          <div class="active-user">
            <div class="avatar-md"></div>
            <div>
              <h3>{{ activeContact.full_name }}</h3>
              <p class="whatsapp-id">{{ activeContact.whatsapp_id }}</p>
            </div>
          </div>
          <div class="header-actions">
            <a v-if="activeContact.google_maps_link" :href="activeContact.google_maps_link" target="_blank" class="location-btn glass">📍 Open Map</a>
            <button class="settings-btn glass">⋮</button>
          </div>
        </header>

        <div class="messages-container" ref="messageContainer">
          <div 
            v-for="msg in messages" 
            :key="msg.id" 
            class="msg-wrapper" 
            :class="msg.direction.toLowerCase()"
          >
            <div class="msg-bubble glass">
              <p>{{ msg.content }}</p>
              <span class="msg-time">{{ formatTime(msg.created_at) }}</span>
            </div>
          </div>
        </div>

        <footer class="input-area">
          <form @submit.prevent="sendMessage" class="chat-form">
            <button type="button" class="attach-btn">📎</button>
            <input 
              v-model="newMessage" 
              type="text" 
              placeholder="Type your message..." 
              class="glass-input"
            />
            <button type="submit" class="send-btn" :disabled="!newMessage.trim()">
              <span>✈</span>
            </button>
          </form>
        </footer>
      </main>

      <div v-else class="empty-chat">
        <div class="illustration">💬</div>
        <h2>Select a customer to start chatting</h2>
        <p>Syncs directly with your WhatsApp Business API</p>
      </div>
    </div>
  </NuxtLayout>
</template>

<script setup>
const supabase = useSupabaseClient()
const activeContact = ref(null)
const newMessage = ref('')
const messageContainer = ref(null)

// In a real app, these would come from the 'mera.profiles' and 'mera.messages' tables
const contacts = ref([])
const messages = ref([])

const fetchContacts = async () => {
  const { data } = await supabase.from('profiles').select('*').limit(10)
  contacts.value = data || []
  if (contacts.value.length > 0) activeContact.value = contacts.value[0]
}

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

  // 1. Insert into DB (Dashboard visibility)
  const { data, error } = await supabase.from('messages').insert({
    whatsapp_id: activeContact.value.whatsapp_id,
    direction: 'OUTBOUND',
    content: content
  })

  // 2. Trigger WhatsApp API via Nuxt Server Action or Edge Function
  // await $fetch('/api/whatsapp/send', { method: 'POST', body: { to: activeContact.value.whatsapp_id, message: content } })

  if (!error) {
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

// 🌐 Realtime Subscription
let messageSubscription = null

const setupRealtime = () => {
  messageSubscription = supabase
    .channel('public:messages')
    .on('postgres_changes', { 
      event: 'INSERT', 
      schema: 'mera', 
      table: 'messages'
    }, (payload) => {
      // If the message is for the currently active contact, push it to the list
      if (activeContact.value && payload.new.whatsapp_id === activeContact.value.whatsapp_id) {
        // Avoid duplicate push if we just sent it ourselves
        const exists = messages.value.some(m => m.id === payload.new.id)
        if (!exists) {
          messages.value.push(payload.new)
          scrollToBottom()
        }
      }
      
      // Update contact's last message in the sidebar
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
  height: calc(100vh - 48px);
  border-radius: 24px;
  overflow: hidden;
}

/* Contacts Sidebar */
.contacts-sidebar {
  width: 350px;
  border-right: 1px solid var(--mera-border);
  display: flex;
  flex-direction: column;
  background: rgba(255, 255, 255, 0.02);
}

.sidebar-header {
  padding: 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.online-status {
  font-size: 11px;
  color: #34c759;
  background: rgba(52, 199, 89, 0.1);
  padding: 2px 8px;
  border-radius: 12px;
}

.search-box { padding: 0 24px 16px; }

.contacts-list {
  flex: 1;
  overflow-y: auto;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 24px;
  cursor: pointer;
  transition: all 0.2s;
}

.contact-item:hover { background: rgba(255, 255, 255, 0.03); }
.contact-item.active { background: rgba(255, 77, 148, 0.05); }

.contact-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
  overflow: hidden;
}

.contact-name { font-weight: 500; font-size: 14px; }
.last-msg { font-size: 12px; color: var(--mera-text-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

/* Message Area */
.message-area {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.chat-header {
  padding: 16px 32px;
  border-bottom: 1px solid var(--mera-border);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.active-user { display: flex; gap: 12px; align-items: center; }
.avatar-md { width: 44px; height: 44px; border-radius: 50%; background: linear-gradient(135deg, var(--mera-primary), var(--mera-accent)); }
.whatsapp-id { font-size: 12px; color: var(--mera-text-muted); }

.header-actions { display: flex; gap: 12px; }
.location-btn { padding: 8px 16px; border-radius: 12px; font-size: 13px; color: var(--mera-text); text-decoration: none; }

.messages-container {
  flex: 1;
  padding: 32px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.msg-wrapper { display: flex; width: 100%; }
.msg-wrapper.outbound { justify-content: flex-end; }
.msg-wrapper.inbound { justify-content: flex-start; }

.msg-bubble {
  max-width: 60%;
  padding: 12px 16px;
  border-radius: 16px;
  position: relative;
}

.outbound .msg-bubble {
  border-bottom-right-radius: 4px;
  background: rgba(255, 77, 148, 0.1);
}

.inbound .msg-bubble {
  border-bottom-left-radius: 4px;
}

.msg-time {
  display: block;
  font-size: 10px;
  color: var(--mera-text-muted);
  margin-top: 4px;
}

.input-area {
  padding: 24px 32px;
  background: rgba(255, 255, 255, 0.02);
}

.chat-form {
  display: flex;
  gap: 16px;
  align-items: center;
}

.attach-btn { background: none; border: none; font-size: 20px; cursor: pointer; color: var(--mera-text-muted); }

.glass-input { flex: 1; padding: 12px 20px; border-radius: 16px; }

.send-btn {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: var(--mera-primary);
  border: none;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: transform 0.2s;
}

.send-btn:hover:not(:disabled) { transform: scale(1.05); }
.send-btn:disabled { opacity: 0.5; cursor: not-allowed; }

.empty-chat {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  gap: 16px;
}

.illustration { font-size: 80px; }
</style>
