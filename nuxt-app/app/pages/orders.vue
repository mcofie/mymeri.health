<template>
  <NuxtLayout name="dashboard">
    <div class="orders-page">
      <header class="page-header">
        <div>
          <h1>Order Management</h1>
          <p class="text-muted">Tracking payments and fulfillment for {{ totalOrders }} orders.</p>
        </div>
        <div class="actions">
          <input v-model="search" type="text" placeholder="Search Paystack Reference..." class="glass-input" />
        </div>
      </header>

      <div class="table-container glass">
        <table class="mera-table">
          <thead>
            <tr>
              <th>Order ID</th>
              <th>Customer</th>
              <th>Reference</th>
              <th>Amount</th>
              <th>Scheduled For</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="order in filteredOrders" :key="order.id">
              <td>#{{ order.id.slice(0, 8) }}</td>
              <td>{{ order.profiles?.full_name }}</td>
              <td><span class="ref-code">{{ order.paystack_reference || 'N/A' }}</span></td>
              <td><strong>{{ order.currency }} {{ order.total_amount }}</strong></td>
              <td>{{ order.scheduled_for_date }}</td>
              <td><span class="status-badge" :class="order.status.toLowerCase()">{{ order.status }}</span></td>
              <td>
                <div class="table-actions">
                  <button class="btn-sm glass" @click="viewOrder(order.id)">Process</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
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
    return orders.value.filter(o => 
        o.paystack_reference?.toLowerCase().includes(search.value.toLowerCase()) ||
        o.profiles?.full_name?.toLowerCase().includes(search.value.toLowerCase())
    )
})

const viewOrder = (id) => {
    console.log('Viewing order:', id)
}

onMounted(fetchOrders)
</script>

<style scoped>
.orders-page { display: flex; flex-direction: column; gap: 32px; }

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.glass-input {
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid var(--mera-border);
    color: var(--mera-text);
    padding: 10px 18px;
    border-radius: 12px;
    width: 250px;
}

.table-container { overflow-x: auto; border-radius: 16px; }

.mera-table { width: 100%; border-collapse: collapse; text-align: left; }
.mera-table th { padding: 16px 24px; font-size: 13px; color: var(--mera-text-muted); border-bottom: 1px solid var(--mera-border); }
.mera-table td { padding: 16px 24px; border-bottom: 1px solid var(--mera-border); font-size: 14px; }

.ref-code { font-family: monospace; color: var(--mera-accent); font-size: 12px; }

.status-badge {
    padding: 4px 10px;
    border-radius: 6px;
    font-size: 11px;
    font-weight: 600;
}
.status-badge.pending { background: rgba(255, 159, 10, 0.1); color: #ff9f0a; }
.status-badge.paid { background: rgba(52, 199, 89, 0.1); color: #34c759; }
.status-badge.dispatched { background: rgba(0, 122, 255, 0.1); color: #007aff; }

.btn-sm { padding: 4px 12px; border-radius: 8px; font-size: 12px; cursor: pointer; color: var(--mera-text); }
</style>
