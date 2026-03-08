<template>
  <NuxtLayout name="dashboard">
    <div class="orders-page">
      <header class="page-header">
        <div class="header-left">
          <h1>Stash Orders</h1>
          <p class="text-muted">Tracking payments and fulfillment for <strong>{{ totalOrders }}</strong> souls.</p>
        </div>
        <div class="header-right">
          <div class="search-wrap glass">
            <span class="search-icon">🔍</span>
            <input v-model="search" type="text" placeholder="Search by name or reference..." class="glass-input-clean" />
          </div>
        </div>
      </header>

      <div class="orders-container">
        <div v-if="filteredOrders.length > 0" class="table-wrap animate-fade-in">
          <table>
            <thead>
              <tr>
                <th>Member</th>
                <th>Reference</th>
                <th>Total Stash</th>
                <th>Timeline</th>
                <th>Status</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in filteredOrders" :key="order.id" class="stash-row">
                <td>
                  <div class="member-cell">
                    <div class="market-flag">{{ getFlag(order.profiles?.country_code) }}</div>
                    <div class="member-info">
                      <span class="name">{{ order.profiles?.full_name || 'Member' }}</span>
                      <span class="member-id">#{{ order.id.slice(0, 8) }}</span>
                    </div>
                  </div>
                </td>
                <td>
                  <div class="ref-cell" @click="copyRef(order.paystack_reference)">
                    <span class="ref-code">{{ order.paystack_reference || 'N/A' }}</span>
                    <span class="copy-hint">📋</span>
                  </div>
                </td>
                <td>
                  <div class="amount-cell">
                    <span class="amount">{{ order.currency }} {{ order.total_amount }}</span>
                  </div>
                </td>
                <td>
                   <div class="timeline-cell">
                      <span class="date">{{ formatDate(order.scheduled_for_date) }}</span>
                      <span class="days-left">{{ getDaysLeft(order.scheduled_for_date) }}</span>
                   </div>
                </td>
                <td>
                  <span class="status-pill" :class="order.status.toLowerCase()">{{ order.status }}</span>
                </td>
                <td>
                  <div class="row-actions">
                    <button class="btn-action glass" @click="viewOrder(order.id)">
                      <span>Process</span>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div v-else class="empty-state glass animate-fade-in">
          <div class="empty-icon">📦</div>
          <h2>No Stash Orders!</h2>
          <p>When members subscribe or order bulk packs, they will appear here for fulfillment.</p>
          <NuxtLink to="/subscriptions" class="btn-primary glass pink-glow">View Subscribers</NuxtLink>
        </div>
      </div>
    </div>
  </NuxtLayout>
</template>

<script setup>
const supabase = useSupabaseClient()
const orders = ref([])
const search = ref('')

const totalOrders = computed(() => orders.value.length)

const fetchOrders = async () => {
    const { data } = await supabase
        .from('orders')
        .select(`
            *,
            profiles (full_name, country_code)
        `)
        .order('created_at', { ascending: false })
    
    orders.value = data || []
}

const filteredOrders = computed(() => {
    if (!search.value) return orders.value
    const q = search.value.toLowerCase()
    return orders.value.filter(o => 
        o.paystack_reference?.toLowerCase().includes(q) ||
        o.profiles?.full_name?.toLowerCase().includes(q)
    )
})

const getFlag = (code) => {
  const flags = { GH: '🇬🇭', NG: '🇳🇬', KE: '🇰🇪' }
  return flags[code] || '🌍'
}

const formatDate = (dateStr) => {
  return new Date(dateStr).toLocaleDateString('en-GB', { day: '2-digit', month: 'short' })
}

const getDaysLeft = (dateStr) => {
  const diff = Math.floor((new Date(dateStr) - new Date()) / (1000 * 60 * 60 * 24))
  return diff >= 0 ? `T - ${diff}d` : 'Past Due'
}

const copyRef = (ref) => {
  if (ref) navigator.clipboard.writeText(ref)
}

const viewOrder = (id) => {
    console.log('Viewing order:', id)
}

onMounted(fetchOrders)
</script>

<style scoped>
.orders-page { display: flex; flex-direction: column; gap: 40px; }

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.header-left h1 { font-size: 32px; font-weight: 800; margin-bottom: 8px; }

.search-wrap {
  display: flex;
  align-items: center;
  padding: 8px 20px;
  gap: 12px;
  border-radius: 40px;
  width: 380px;
}

.search-icon { opacity: 0.5; }
.glass-input-clean {
  background: none;
  border: none;
  color: var(--mera-text);
  width: 100%;
  font-size: 14px;
}
.glass-input-clean:focus { outline: none; }

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
.market-flag { font-size: 24px; }
.member-info { display: flex; flex-direction: column; }
.member-info .name { font-size: 15px; font-weight: 700; }
.member-info .member-id { font-size: 11px; color: var(--mera-text-muted); font-family: monospace; }

.ref-cell {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 6px 12px;
  background: rgba(0,0,0,0.03);
  border-radius: 8px;
  width: fit-content;
}
.ref-code { font-family: monospace; color: var(--mera-primary); font-size: 12px; font-weight: 600; }
.copy-hint { font-size: 10px; opacity: 0; transition: opacity 0.2s; }
.ref-cell:hover .copy-hint { opacity: 1; }

.amount-cell .amount { font-size: 15px; font-weight: 700; }

.timeline-cell { display: flex; flex-direction: column; }
.timeline-cell .date { font-size: 14px; font-weight: 600; }
.timeline-cell .days-left { font-size: 11px; color: var(--mera-primary); font-weight: 700; }

.status-pill {
  padding: 6px 14px;
  border-radius: 40px;
  font-size: 10px;
  font-weight: 800;
  text-transform: uppercase;
}
.status-pill.pending { background: #fff5e6; color: #ff9f0a; }
.status-pill.paid { background: #e9fbf0; color: #34c759; }
.status-pill.dispatched { background: #e6f0ff; color: #007aff; }

.btn-action {
  padding: 8px 16px;
  border-radius: 12px;
  border: none;
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
  color: var(--mera-text);
  transition: all 0.2s;
}
.btn-action:hover { background: var(--mera-primary); color: white; border-color: var(--mera-primary); }

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 80px 40px;
  gap: 20px;
  margin-top: 40px;
}
.empty-icon { font-size: 64px; }
.empty-state h2 { font-size: 24px; font-weight: 800; }
.empty-state p { color: var(--mera-text-muted); max-width: 400px; line-height: 1.6; margin-bottom: 20px; }

.btn-primary { padding: 14px 28px; border-radius: 12px; font-size: 14px; font-weight: 700; text-decoration: none; color: white; display: inline-block; }
</style>
