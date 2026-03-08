<template>
  <NuxtLayout name="dashboard">
    <div class="subscriptions-page">
      <header class="page-header">
        <div class="header-left">
          <h1>Active Souls</h1>
          <p class="text-muted">Total: <strong>{{ totalCount }}</strong> active subscribers tracking their cycles.</p>
        </div>
        
        <div class="header-right">
          <div class="search-wrap glass">
            <span class="search-icon">🔍</span>
            <input v-model="search" type="text" placeholder="Search by name or WhatsApp..." class="glass-input-clean" />
          </div>
          <div class="filter-wrap">
             <select v-model="filterCountry" class="glass-select-nexus">
               <option value="ALL">All Markets</option>
               <option value="GH">Ghana 🇬🇭</option>
               <option value="NG">Nigeria 🇳🇬</option>
               <option value="KE">Kenya 🇰🇪</option>
             </select>
          </div>
        </div>
      </header>

      <div class="souls-container">
        <div v-if="filteredSubscriptions.length > 0" class="table-wrap animate-fade-in">
          <table>
            <thead>
              <tr>
                <th>Member</th>
                <th>Selected Tier</th>
                <th>Cycle Plan</th>
                <th>Location</th>
                <th>Next Stash</th>
                <th>Status</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="sub in filteredSubscriptions" :key="sub.id" class="stash-row">
                <td>
                  <div class="member-cell">
                    <div class="avatar-box-nexus">{{ sub.profiles?.full_name?.charAt(0) }}</div>
                    <div class="member-info">
                      <span class="name">{{ sub.profiles?.full_name }}</span>
                      <span class="whatsapp">WA: {{ sub.profiles?.whatsapp_id }}</span>
                    </div>
                  </div>
                </td>
                <td>
                  <div class="tier-cell">
                    <span class="tier-pill" :class="sub.box_tier.toLowerCase().replace(/ /g, '-')">{{ sub.box_tier }}</span>
                    <div v-if="sub.box_tier === 'Custom' && sub.custom_items_json" class="custom-peek" :title="customItemsList(sub.custom_items_json)">
                      {{ sub.custom_items_json.length }} items
                    </div>
                  </div>
                </td>
                <td>
                  <div class="plan-cell">
                    <span class="plan-text">{{ sub.billing_cycle }}</span>
                    <span v-if="sub.billing_cycle === 'Quarterly'" class="buffer-tag">Stock-Up</span>
                  </div>
                </td>
                <td>
                  <div class="map-cell">
                    <div class="market-indicator">
                       <span class="flag-mini">{{ getFlag(sub.profiles?.country_code) }}</span>
                    </div>
                    <a v-if="sub.profiles?.google_maps_link" :href="sub.profiles.google_maps_link" target="_blank" class="map-link-btn" title="Open in Google Maps">📍 Map</a>
                    <span v-else class="no-pin">No Pin</span>
                  </div>
                </td>
                <td>
                   <div class="date-cell">
                      <span class="date">{{ formatDateShort(sub.next_period_date) }}</span>
                      <span class="days-left">{{ getDaysLeft(sub.next_period_date) }}</span>
                   </div>
                </td>
                <td>
                  <span class="status-pill-nexus" :class="sub.status.toLowerCase()">{{ sub.status }}</span>
                </td>
                <td>
                  <div class="soul-actions">
                    <button class="btn-nudge glass" @click="initiateNudge(sub)" :disabled="nudgingId === sub.id">
                      <span v-if="nudgingId === sub.id">⏳</span>
                      <span v-else>🔔 Nudge</span>
                    </button>
                    <button class="btn-edit glass" @click="editProfile(sub.profiles)">
                      <span>📝</span>
                    </button>
                    <NuxtLink to="/messages" class="btn-msg glass">
                      <span>💬</span>
                    </NuxtLink>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div v-else class="empty-state-nexus glass animate-fade-in">
          <div class="illustration">💎</div>
          <h2>No Souls Found</h2>
          <p>We couldn't find any active subscribers matching your current filters or search query.</p>
          <button @click="resetFilters" class="btn-secondary glass">Clear Filters</button>
        </div>
      </div>

      <!-- Edit Modal Premium -->
      <Teleport to="body">
        <div v-if="showEditModal" class="modal-overlay-nexus" @click.self="showEditModal = false">
          <div class="modal-nexus glass animate-fade-in">
            <header class="modal-header">
              <h2>Edit Member Profile</h2>
              <button class="close-btn" @click="showEditModal = false">✕</button>
            </header>
            
            <form @submit.prevent="saveProfile" class="nexus-form">
              <div class="nexus-input-group">
                <label>Google Maps Location Link</label>
                <div class="input-container glass">
                  <span class="prefix">📍</span>
                  <input v-model="editingUser.google_maps_link" type="url" placeholder="Paste Maps URL here..." />
                </div>
              </div>
              
              <div class="nexus-input-group">
                <label>Admin Internal Notes</label>
                <div class="input-container glass">
                  <textarea v-model="editingUser.internal_notes" placeholder="Delivery landmarks, preferences, or specific delivery times..."></textarea>
                </div>
              </div>

              <div class="nexus-modal-footer">
                <button type="button" class="btn-cancel" @click="showEditModal = false">Cancel</button>
                <button type="submit" class="btn-save glass pink-glow">Update Profile</button>
              </div>
            </form>
          </div>
        </div>
      </Teleport>
    </div>
  </NuxtLayout>
</template>

<script setup>
const supabase = useSupabaseClient()
const subscriptions = ref([])
const search = ref('')
const filterCountry = ref('ALL')
const nudgingId = ref(null)
const showEditModal = ref(false)
const editingUser = ref(null)

const totalCount = computed(() => subscriptions.value.length)

const fetchSubscriptions = async () => {
    const { data } = await supabase
        .from('subscriptions')
        .select(`
            *,
            profiles (id, full_name, whatsapp_id, country_code, google_maps_link, internal_notes)
        `)
        .order('next_period_date', { ascending: true })
    
    subscriptions.value = data || []
}

const filteredSubscriptions = computed(() => {
    let list = subscriptions.value
    
    if (filterCountry.value !== 'ALL') {
      list = list.filter(s => s.profiles?.country_code === filterCountry.value)
    }
    
    if (search.value) {
      const q = search.value.toLowerCase()
      list = list.filter(s => 
        s.profiles?.full_name?.toLowerCase().includes(q) ||
        s.profiles?.whatsapp_id?.includes(q)
      )
    }
    
    return list
})

const getFlag = (code) => {
  const flags = { GH: '🇬🇭', NG: '🇳🇬', KE: '🇰🇪' }
  return flags[code] || '🌍'
}

const formatDateShort = (dateStr) => {
  return new Date(dateStr).toLocaleDateString('en-GB', { day: '2-digit', month: 'short' })
}

const getDaysLeft = (dateStr) => {
  const diff = Math.floor((new Date(dateStr) - new Date()) / (1000 * 60 * 60 * 24))
  return diff >= 0 ? `T - ${diff}d` : 'Past Due'
}

const customItemsList = (items) => {
  return items.map(i => `${i.quantity}x ${i.name}`).join(', ')
}

const resetFilters = () => {
  search.value = ''
  filterCountry.value = 'ALL'
}

const initiateNudge = async (sub) => {
  nudgingId.value = sub.id
  try {
    const { data, error } = await supabase.functions.invoke('manual-nudge', {
      body: { subscription_id: sub.id }
    })
    if (error) throw error
    alert(`Nudge sent to ${sub.profiles.full_name}!`)
  } catch (err) {
    console.error('Nudge Error:', err)
    alert('Failed to send nudge.')
  } finally {
    nudgingId.value = null
  }
}

const editProfile = (profile) => {
  editingUser.value = { ...profile }
  showEditModal.value = true
}

const saveProfile = async () => {
  const { error } = await supabase
    .from('profiles')
    .update({
      google_maps_link: editingUser.value.google_maps_link,
      internal_notes: editingUser.value.internal_notes
    })
    .eq('id', editingUser.value.id)
  
  if (!error) {
    showEditModal.value = false
    fetchSubscriptions()
  }
}

onMounted(fetchSubscriptions)
</script>

<style scoped>
.subscriptions-page { display: flex; flex-direction: column; gap: 40px; }

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.header-left h1 { font-size: 32px; font-weight: 800; margin-bottom: 8px; }

.header-right { display: flex; gap: 16px; align-items: center; }

.search-wrap {
  display: flex;
  align-items: center;
  padding: 8px 20px;
  gap: 12px;
  border-radius: 40px;
  width: 320px;
}

.search-icon { opacity: 0.5; }
.glass-input-clean { background: none; border: none; color: var(--mera-text); width: 100%; font-size: 14px; }
.glass-input-clean:focus { outline: none; }

.glass-select-nexus {
  background: rgba(255, 255, 255, 0.4);
  backdrop-filter: blur(10px);
  border: 1px solid var(--mera-border);
  padding: 10px 16px;
  border-radius: 40px;
  font-size: 13px;
  font-weight: 600;
  color: var(--mera-text);
  outline: none;
}

.table-wrap { width: 100%; }
table { width: 100%; border-collapse: separate; border-spacing: 0 16px; margin-top: -16px; }

th {
  text-align: left;
  padding: 12px 24px;
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 1px;
  color: var(--mera-text-muted);
}

.stash-row td {
  padding: 20px 24px;
  background: rgba(255, 255, 255, 0.4);
  backdrop-filter: blur(10px);
  border-top: 1px solid var(--mera-border);
  border-bottom: 1px solid var(--mera-border);
}

.stash-row td:first-child { border-radius: 20px 0 0 20px; border-left: 1px solid var(--mera-border); }
.stash-row td:last-child { border-radius: 0 20px 20px 0; border-right: 1px solid var(--mera-border); }

.member-cell { display: flex; align-items: center; gap: 16px; }
.avatar-box-nexus {
  width: 44px;
  height: 44px;
  background: #f0f0f0;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 800;
  color: var(--mera-primary);
  font-size: 18px;
}

.member-info { display: flex; flex-direction: column; }
.name { font-size: 15px; font-weight: 700; }
.whatsapp { font-size: 11px; color: var(--mera-text-muted); font-family: monospace; }

.tier-cell { display: flex; flex-direction: column; gap: 4px; }
.tier-pill {
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 10px;
  font-weight: 800;
  text-transform: uppercase;
  width: fit-content;
}
.tier-pill.peace-of-mind { background: #fee7f2; color: #ff2d55; }
.tier-pill.custom { background: #eef1ff; color: #5856d6; }

.custom-peek { font-size: 10px; opacity: 0.5; font-weight: 600; cursor: help; }

.plan-cell { display: flex; align-items: center; gap: 8px; }
.plan-text { font-size: 13px; font-weight: 600; }
.buffer-tag { font-size: 10px; background: #fee2e2; color: #b91c1c; padding: 2px 6px; border-radius: 4px; font-weight: 700; }

.map-cell { display: flex; align-items: center; gap: 12px; }
.flag-mini { font-size: 18px; }
.map-link-btn {
  text-decoration: none;
  font-size: 12px;
  font-weight: 700;
  color: var(--mera-primary);
  background: rgba(255, 77, 148, 0.05);
  padding: 4px 10px;
  border-radius: 8px;
}
.no-pin { font-size: 11px; color: var(--mera-text-muted); }

.date-cell { display: flex; flex-direction: column; }
.date { font-size: 14px; font-weight: 600; }
.days-left { font-size: 11px; color: var(--mera-accent); font-weight: 700; }

.status-pill-nexus {
  padding: 6px 14px;
  border-radius: 40px;
  font-size: 10px;
  font-weight: 800;
  text-transform: uppercase;
}
.status-pill-nexus.active { background: #e9fbf0; color: #34c759; }

.soul-actions { display: flex; gap: 8px; }
.btn-nudge, .btn-edit, .btn-msg {
  padding: 8px;
  border-radius: 10px;
  cursor: pointer;
  border: none;
  transition: all 0.2s;
}

.btn-nudge {
  padding: 8px 14px;
  font-size: 11px;
  font-weight: 800;
  color: var(--mera-primary);
}
.btn-nudge:hover:not(:disabled) { background: var(--mera-primary); color: white; }

.btn-edit:hover, .btn-msg:hover { transform: scale(1.1); }

.empty-state-nexus {
  padding: 100px 40px;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}
.illustration { font-size: 64px; }
.empty-state-nexus h2 { font-size: 26px; font-weight: 800; }
.btn-secondary { padding: 12px 24px; border-radius: 14px; font-size: 14px; font-weight: 700; cursor: pointer; color: var(--mera-text); }

/* Modal Premium */
.modal-overlay-nexus {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.4);
  backdrop-filter: blur(12px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
}

.modal-nexus {
  width: 90%;
  max-width: 520px;
  padding: 40px;
  border-radius: 32px;
}

.modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px; }
.modal-header h2 { font-size: 24px; font-weight: 800; }
.close-btn { background: none; border: none; font-size: 20px; cursor: pointer; opacity: 0.3; }

.nexus-form { display: flex; flex-direction: column; gap: 24px; }
.nexus-input-group { display: flex; flex-direction: column; gap: 10px; }
.nexus-input-group label { font-size: 13px; font-weight: 700; color: var(--mera-text-muted); }

.input-container { display: flex; align-items: center; padding: 14px 20px; border-radius: 16px; gap: 12px; }
.input-container input, .input-container textarea {
  background: none; border: none; width: 100%; color: var(--mera-text); font-size: 15px; outline: none;
}
.input-container textarea { height: 120px; resize: none; }

.nexus-modal-footer { display: flex; justify-content: flex-end; gap: 16px; margin-top: 20px; }
.btn-save { padding: 14px 28px; border-radius: 14px; border: none; color: white; font-weight: 800; cursor: pointer; }
.btn-cancel { background: none; border: none; font-weight: 700; color: var(--mera-text-muted); cursor: pointer; }
</style>
