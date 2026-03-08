<template>
  <NuxtLayout name="dashboard">
    <div class="dashboard-home">
      <section class="metrics-grid">
        <MetricCard label="Active Subscribers" :value="metrics?.subscribers?.toString()" icon="👥" trendValue="+12%" trendDirection="up" />
        <MetricCard label="Next Deliveries (T-7)" value="342" icon="📦" trendValue="+8%" trendDirection="up" />
        <MetricCard label="Pending Payments" :value="metrics?.pending?.toString()" icon="💳" trendValue="-3%" trendDirection="down" />
        <MetricCard label="Inventory Utility" value="94%" icon="📊" trendValue="+2%" trendDirection="up" />
      </section>

      <section class="main-grid">
        <div class="orders-table glass">
          <div class="table-header">
            <h3>Recent Cycle Orders</h3>
            <button class="view-all">View All</button>
          </div>
          <table>
            <thead>
              <tr>
                <th>Customer</th>
                <th>Tier</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Cycle Day</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in orders" :key="order.id">
                <td>
                  <div class="user-cell">
                    <div class="avatar-mini"></div>
                    <span>{{ order.name }}</span>
                  </div>
                </td>
                <td><span class="badge tier" :class="order.tier.toLowerCase()">{{ order.tier }}</span></td>
                <td>{{ order.amount }}</td>
                <td><span class="badge status" :class="order.status.toLowerCase()">{{ order.status }}</span></td>
                <td>T - {{ order.cycleDay }}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="sidebar-widgets">
          <div class="pulse-check glass">
            <h3>Nudge Health</h3>
            <div class="nudge-stats">
              <div class="stat">
                <span>WhatsApp Delivery</span>
                <strong>98.2%</strong>
              </div>
              <div class="stat">
                <span>Response Rate</span>
                <strong>42.1%</strong>
              </div>
            </div>
          </div>
          
          <div class="discreet-toggle-card glass">
            <div class="header">
              <h3>Priority Packaging</h3>
              <div class="status-indicator active"></div>
            </div>
            <p>82% of current cycle orders requested Discreet Packaging.</p>
          </div>
        </div>
      </section>
    </div>
  </NuxtLayout>
</template>

<script setup>
const supabase = useSupabaseClient()

const { data: metrics } = await useAsyncData('dashboard-metrics', async () => {
    // In a real app, these would be separate counts or summarized via RPC
    const { count: subscriberCount } = await supabase.from('subscriptions').select('*', { count: 'exact', head: true })
    const { count: pendingOrders } = await supabase.from('orders').select('*', { count: 'exact', head: true }).eq('status', 'Pending')
    
    return {
        subscribers: subscriberCount || 0,
        pending: pendingOrders || 0
    }
})

const { data: orders } = await useAsyncData('recent-orders', async () => {
    const { data } = await supabase
        .from('orders')
        .select(`
            id,
            total_amount,
            currency,
            status,
            scheduled_for_date,
            profiles (full_name)
        `)
        .order('created_at', { ascending: false })
        .limit(5)
    
    return data?.map(o => ({
        id: o.id,
        name: o.profiles?.full_name || 'Unknown',
        tier: 'Standard', // Can be derived if subscription is linked
        amount: `${o.currency} ${o.total_amount}`,
        status: o.status,
        cycleDay: Math.abs(new Date(o.scheduled_for_date).getDate() - new Date().getDate())
    })) || []
})
</script>

<style scoped>
.dashboard-home {
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.metrics-grid {
  display: flex;
  gap: 24px;
}

.main-grid {
  display: grid;
  grid-template-columns: 1fr 320px;
  gap: 24px;
}

.orders-table {
  padding: 24px;
}

.table-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 24px;
}

.view-all {
  background: none;
  border: none;
  color: var(--mera-primary);
  font-size: 14px;
  cursor: pointer;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th {
  text-align: left;
  padding: 12px 16px;
  color: var(--mera-text-muted);
  font-weight: 500;
  font-size: 13px;
  border-bottom: 1px solid var(--mera-border);
}

td {
  padding: 16px;
  font-size: 14px;
  border-bottom: 1px solid var(--mera-border);
}

.user-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.avatar-mini {
  width: 24px;
  height: 24px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
}

.badge {
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 11px;
  text-transform: uppercase;
  font-weight: 600;
}

.badge.tier.comfort { background: rgba(142, 85, 233, 0.15); color: #a272ff; }
.badge.tier.essential { background: rgba(52, 199, 89, 0.15); color: #34c759; }
.badge.tier.eco { background: rgba(255, 77, 148, 0.15); color: #ff66a3; }

.badge.status.paid { background: rgba(52, 199, 89, 0.1); color: #34c759; }
.badge.status.pending { background: rgba(255, 159, 10, 0.1); color: #ff9f0a; }
.badge.status.failed { background: rgba(255, 59, 48, 0.1); color: #ff3b30; }

.sidebar-widgets {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.pulse-check, .discreet-toggle-card {
  padding: 24px;
}

.nudge-stats {
  margin-top: 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.stat {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.stat span {
  font-size: 12px;
  color: var(--mera-text-muted);
}

.stat strong {
  font-size: 20px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.status-indicator.active {
  width: 8px;
  height: 8px;
  background: #34c759;
  border-radius: 50%;
  box-shadow: 0 0 12px #34c759;
}

p {
  font-size: 13px;
  color: var(--mera-text-muted);
  line-height: 1.5;
}
</style>
