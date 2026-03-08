<template>
  <NuxtLayout name="dashboard">
    <div class="subscriptions-page">
      <header class="page-header">
        <div>
          <h1>Active Subscriptions</h1>
          <p class="text-muted">Total: {{ totalCount }} active cycle tracking boxes.</p>
        </div>
        <div class="filters">
          <select v-model="filterCountry" class="glass-select">
            <option value="ALL">All Countries</option>
            <option value="GH">Ghana 🇬🇭</option>
            <option value="NG">Nigeria 🇳🇬</option>
            <option value="KE">Kenya 🇰🇪</option>
          </select>
        </div>
      </header>

      <div class="table-container glass">
        <table class="mera-table">
          <thead>
            <tr>
              <th>Subscriber</th>
              <th>Tier</th>
              <th>Location</th>
              <th>Next Nudge</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="sub in filteredSubscriptions" :key="sub.id">
              <td>
                <div class="user-info">
                  <div class="avatar-mini"></div>
                  <div>
                    <div class="name">{{ sub.profiles?.full_name }}</div>
                    <div class="whatsapp">{{ sub.profiles?.whatsapp_id }}</div>
                  </div>
                </div>
              </td>
              <td><span class="tier-badge">{{ sub.box_tier }}</span></td>
              <td>
                <div class="location-cell">
                  <a v-if="sub.profiles?.google_maps_link" :href="sub.profiles.google_maps_link" target="_blank" class="map-icon" title="View Map">📍</a>
                  <span v-else class="text-muted">No pin</span>
                </div>
              </td>
              <td><span class="nudge-date">{{ formatDate(sub.next_period_date) }}</span></td>
              <td><span class="status-pill" :class="sub.status.toLowerCase()">{{ sub.status }}</span></td>
              <td>
                <div class="table-actions">
                  <button class="nudge-btn glass" @click="initiateNudge(sub)" :disabled="nudgingId === sub.id" title="Send WhatsApp Nudge">
                    <span v-if="nudgingId === sub.id">⏳</span>
                    <span v-else>🔔 Nudge</span>
                  </button>
                  <button class="icon-btn" @click="editProfile(sub.profiles)" title="Edit Details">📝</button>
                  <NuxtLink to="/messages" class="icon-btn" title="Message">💬</NuxtLink>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Edit Modal -->
      <div v-if="showEditModal" class="modal-overlay" @click.self="showEditModal = false">
        <div class="modal glass">
          <h2>Edit Customer Details</h2>
          <form @submit.prevent="saveProfile" class="edit-form">
            <div class="input-group">
              <label>Google Maps Link</label>
              <input v-model="editingUser.google_maps_link" type="url" placeholder="https://maps.google.com/..." class="glass-input" />
            </div>
            <div class="input-group">
              <label>Internal Notes</label>
              <textarea v-model="editingUser.internal_notes" placeholder="Best time to call, specific landmark..." class="glass-input"></textarea>
            </div>
            <div class="modal-actions">
              <button type="button" class="btn-sm" @click="showEditModal = false">Cancel</button>
              <button type="submit" class="btn-primary glass">Save Changes</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </NuxtLayout>
</template>

<script setup>
const supabase = useSupabaseClient()
const subscriptions = ref([])
const filterCountry = ref('ALL')

const totalCount = computed(() => subscriptions.value.length)
const showEditModal = ref(false)
const editingUser = ref(null)

const nudgingId = ref(null)

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
    alert('Failed to send nudge. Check console for details.')
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

const filteredSubscriptions = computed(() => {
    if (filterCountry.value === 'ALL') return subscriptions.value
    return subscriptions.value.filter(s => s.profiles?.country_code === filterCountry.value)
})

const formatDate = (dateStr) => {
    return new Date(dateStr).toLocaleDateString('en-GB', {
        day: 'numeric',
        month: 'short',
        year: 'numeric'
    })
}

onMounted(fetchSubscriptions)
</script>

<style scoped>
.subscriptions-page { display: flex; flex-direction: column; gap: 32px; }

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.glass-select {
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid var(--mera-border);
    color: var(--mera-text);
    padding: 8px 16px;
    border-radius: 10px;
}

.table-container {
    overflow-x: auto;
    border-radius: 16px;
}

.mera-table {
    width: 100%;
    border-collapse: collapse;
    text-align: left;
}

.mera-table th {
    padding: 16px 24px;
    font-size: 13px;
    color: var(--mera-text-muted);
    font-weight: 500;
    border-bottom: 1px solid var(--mera-border);
}

.mera-table td {
    padding: 16px 24px;
    border-bottom: 1px solid var(--mera-border);
    font-size: 14px;
}

.user-info { display: flex; gap: 12px; align-items: center; }
.avatar-mini { width: 32px; height: 32px; border-radius: 50%; background: linear-gradient(135deg, var(--mera-primary), var(--mera-accent)); }
.whatsapp { font-size: 12px; color: var(--mera-text-muted); }

.tier-badge {
    background: rgba(255, 77, 148, 0.1);
    color: var(--mera-primary);
    padding: 2px 10px;
    border-radius: 6px;
    font-size: 12px;
}

.nudge-date { color: var(--mera-accent); font-weight: 500; }

.status-pill {
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 11px;
    text-transform: uppercase;
}
.status-pill.active { background: rgba(52, 199, 89, 0.1); color: #34c759; }

.table-actions { display: flex; gap: 12px; }
.nudge-btn {
  padding: 6px 14px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
  color: var(--mera-primary);
  border: 1px solid var(--mera-primary);
  cursor: pointer;
  transition: all 0.2s;
}

.nudge-btn:hover:not(:disabled) {
  background: var(--mera-primary);
  color: white;
}

.nudge-btn:disabled {
  opacity: 0.5;
  cursor: wait;
}

.icon-btn { cursor: pointer; background: none; border: none; font-size: 16px; text-decoration: none; }

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  width: 100%;
  max-width: 500px;
  padding: 40px;
  border-radius: 24px;
}

.edit-form {
  margin-top: 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  margin-top: 24px;
}

.glass-input {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid var(--mera-border);
  border-radius: 12px;
  padding: 12px 16px;
  color: var(--mera-text);
  width: 100%;
}

textarea.glass-input { height: 100px; resize: none; }

.btn-primary { padding: 10px 24px; border-radius: 12px; cursor: pointer; }
.btn-sm { background: none; border: 1px solid var(--mera-border); color: var(--mera-text); padding: 10px 20px; border-radius: 12px; cursor: pointer; }
</style>
