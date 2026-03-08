<template>
  <NuxtLayout name="dashboard">
    <div class="dashboard-home">
      <!-- Top Metrics -->
      <section class="metrics-grid">
        <MetricCard label="Active Souls" :value="metrics?.subscribers?.toString()" icon="✨" trendValue="+12%" trendDirection="up" />
        <MetricCard label="Due Deliveries" :value="metrics?.dueDeliveries?.toString()" icon="🚚" trendValue="+8%" trendDirection="up" />
        <MetricCard label="Cycle Revenue" :value="'GHS ' + (metrics?.revenue / 1000).toFixed(1) + 'k'" icon="💰" trendValue="+15%" trendDirection="up" />
        <MetricCard label="Market Trust" value="98%" icon="🛡️" trendValue="+0.4%" trendDirection="up" />
      </section>

      <!-- Main Visual Grid -->
      <section class="visual-grid">
        <div class="main-column">
          <div class="performance-widget glass animate-fade-in">
            <header class="widget-header">
               <div>
                  <h3>Revenue Pulse</h3>
                  <p class="text-muted">Tracking GHS volume across cycle stashes.</p>
               </div>
               <div class="period-select glass">Last 12 Months</div>
            </header>
            <div class="chart-sim">
               <div v-for="bar in revenueHistory" :key="bar.label" class="bar-wrap">
                  <div class="bar" :style="{ height: Math.max(10, (bar.value / maxRevenue) * 100) + '%' }" :title="bar.label + ': ' + bar.value"></div>
                  <span class="bar-label">{{ bar.label }}</span>
               </div>
            </div>
          </div>

          <div class="orders-widget glass animate-fade-in">
            <header class="widget-header">
              <h3>Recent Stash Activity</h3>
              <NuxtLink to="/orders" class="view-link">Manage Orders →</NuxtLink>
            </header>
            <div class="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Member</th>
                    <th>Stash</th>
                    <th>Status</th>
                    <th>Timeline</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="order in orders" :key="order.id" class="stash-row">
                    <td>
                      <div class="member-cell">
                        <div class="avatar-box">{{ order.name.charAt(0) }}</div>
                        <div class="member-info">
                          <span class="name">{{ order.name }}</span>
                          <span class="location">{{ order.location }}</span>
                        </div>
                      </div>
                    </td>
                    <td>
                      <div class="stash-cell">
                        <span class="tier-tag">{{ order.tier }}</span>
                        <span class="amount">{{ order.amount }}</span>
                      </div>
                    </td>
                    <td>
                      <span class="status-pill" :class="order.status.toLowerCase()">{{ order.status }}</span>
                    </td>
                    <td>
                      <div class="timeline-cell">
                        <span class="days">T - {{ order.cycleDay }}d</span>
                        <div class="mini-progress"><div class="fill" :style="{ width: Math.min(100, Math.max(0, 100 - (order.cycleDay * 5))) + '%' }"></div></div>
                      </div>
                    </td>
                  </tr>
                  <tr v-if="orders.length === 0">
                    <td colspan="4" style="text-align: center; padding: 40px; color: var(--mera-text-muted);">No recent orders found.</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <aside class="side-column">
          <div class="nudge-widget glass animate-fade-in">
            <h3>Cycle Health</h3>
            <div class="meter-wrap">
              <div class="meter-header">
                <span>Nudge Delivery</span>
                <strong>98.2%</strong>
              </div>
              <div class="meter-bar"><div class="meter-fill" style="width: 98.2%"></div></div>
            </div>
            <div class="meter-wrap">
              <div class="meter-header">
                <span>Stock Utilization</span>
                <strong>{{ metrics?.inventoryUtility || '94.0' }}%</strong>
              </div>
              <div class="meter-bar pink"><div class="meter-fill" :style="{ width: (metrics?.inventoryUtility || 94) + '%' }"></div></div>
            </div>
            <div class="meter-wrap">
              <div class="meter-header">
                <span>Market Resilience</span>
                <strong>82.0%</strong>
              </div>
              <div class="meter-bar purple"><div class="meter-fill" style="width: 82%"></div></div>
            </div>
          </div>

          <div class="active-markets glass animate-fade-in">
             <h3>Market Reach</h3>
             <div class="market-list">
                <div v-for="market in marketStats" :key="market.code" class="market-item">
                   <span class="flag">{{ market.flag }}</span>
                   <div class="market-info">
                      <span class="country">{{ market.name }}</span>
                      <span class="sub-count">{{ market.count }} Souls</span>
                   </div>
                   <div class="trend-up" v-if="market.count > 0">+{{ Math.floor(Math.random() * 10) }}%</div>
                </div>
             </div>
          </div>
        </aside>
      </section>
    </div>
  </NuxtLayout>
</template>

<script setup>
const supabase = useSupabaseClient()

const markets = [
  { code: 'GH', name: 'Ghana', flag: '🇬🇭' },
  { code: 'NG', name: 'Nigeria', flag: '🇳🇬' },
  { code: 'KE', name: 'Kenya', flag: '🇰🇪' }
]

const { data: metrics } = await useAsyncData('dashboard-metrics', async () => {
    // 1. Total Subscribers
    const { count: subscriberCount } = await supabase.from('subscriptions').select('*', { count: 'exact', head: true })
    
    // 2. Due Deliveries (T-7)
    const sevenDaysFromNow = new Date()
    sevenDaysFromNow.setDate(sevenDaysFromNow.getDate() + 7)
    const isoDate = sevenDaysFromNow.toISOString().split('T')[0]
    const { count: dueCount } = await supabase.from('subscriptions')
        .select('*', { count: 'exact', head: true })
        .lte('next_period_date', isoDate)
        .eq('status', 'Active')
    
    // 3. Total Revenue (Sum of Paid Orders)
    const { data: revenueData } = await supabase.from('orders')
        .select('total_amount')
        .eq('status', 'Paid')
    
    const totalRevenue = revenueData?.reduce((sum, o) => sum + Number(o.total_amount), 0) || 0

    // 4. Inventory Utility (Simple mock based on stock levels )
    const { data: stock } = await supabase.from('inventory').select('stock_level')
    const totalStock = stock?.reduce((sum, s) => sum + s.stock_level, 0) || 0
    const utility = Math.min(99, Math.floor((totalStock / 1000) * 100))

    return {
        subscribers: subscriberCount || 0,
        dueDeliveries: dueCount || 0,
        revenue: totalRevenue,
        inventoryUtility: utility
    }
})

const { data: marketStats } = await useAsyncData('market-stats', async () => {
    const { data } = await supabase.from('profiles').select('country_code')
    
    return markets.map(m => ({
        ...m,
        count: data?.filter(p => p.country_code === m.code).length || 0
    }))
})

const { data: revenueHistory } = await useAsyncData('revenue-history', async () => {
    // Fetch last 12 months of paid revenue
    const { data } = await supabase.from('orders')
        .select('total_amount, created_at')
        .eq('status', 'Paid')
        .order('created_at', { ascending: true })
    
    const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D']
    const history = months.map((m, i) => ({ label: m, value: 0 }))

    data?.forEach(o => {
        const month = new Date(o.created_at).getMonth()
        history[month].value += Number(o.total_amount)
    })

    return history
})

const maxRevenue = computed(() => {
    const max = Math.max(...(revenueHistory.value?.map(h => h.value) || [100]))
    return max === 0 ? 100 : max
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
            country_code,
            profiles (full_name)
        `)
        .order('created_at', { ascending: false })
        .limit(6)
    
    return data?.map(o => ({
        id: o.id,
        name: o.profiles?.full_name || 'Member',
        location: `${markets.find(m => m.code === o.country_code)?.name || 'Ghana'}, ${o.country_code}`,
        tier: 'Custom Box',
        amount: `${o.currency} ${o.total_amount}`,
        status: o.status,
        cycleDay: Math.max(0, Math.floor((new Date(o.scheduled_for_date) - new Date()) / (1000 * 60 * 60 * 24)))
    })) || []
})
</script>

<style scoped>
.dashboard-home { display: flex; flex-direction: column; gap: 40px; }

.metrics-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 24px; }

.visual-grid {
  display: grid;
  grid-template-columns: 1fr 340px;
  gap: 32px;
}

.main-column { display: flex; flex-direction: column; gap: 32px; }
.side-column { display: flex; flex-direction: column; gap: 32px; }

.widget-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.widget-header h3 { font-size: 20px; font-weight: 800; }

.period-select { padding: 6px 16px; border-radius: 40px; font-size: 11px; font-weight: 700; color: var(--mera-text-muted); }

/* Performance Widget */
.performance-widget { padding: 32px; }
.chart-sim {
  height: 140px;
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 12px;
  padding-bottom: 12px;
}

.bar-wrap { flex: 1; display: flex; flex-direction: column; align-items: center; gap: 8px; }
.bar {
  width: 100%;
  background: var(--mera-primary);
  border-radius: 6px 6px 4px 4px;
  opacity: 0.15;
  transition: all 0.4s;
}

.bar:hover { opacity: 0.8; transform: scaleY(1.05); }
.bar-label { font-size: 9px; font-weight: 700; color: var(--mera-text-muted); }

/* Orders Widget */
.orders-widget { padding: 32px; }
.view-link { font-size: 13px; font-weight: 700; color: var(--mera-primary); text-decoration: none; }

table { width: 100%; border-collapse: separate; border-spacing: 0 12px; margin-top: -12px; }
th { text-align: left; padding: 12px 16px; font-size: 11px; text-transform: uppercase; letter-spacing: 1px; color: var(--mera-text-muted); }

.stash-row { transition: transform 0.2s; }
.stash-row:hover { transform: scale(1.01); }

.stash-row td {
  padding: 16px;
  background: rgba(255, 255, 255, 0.4);
  backdrop-filter: blur(10px);
}

.stash-row td:first-child { border-radius: 16px 0 0 16px; border-left: 1px solid var(--mera-border); }
.stash-row td:last-child { border-radius: 0 16px 16px 0; border-right: 1px solid var(--mera-border); }
.stash-row td { border-top: 1px solid var(--mera-border); border-bottom: 1px solid var(--mera-border); }

.member-cell { display: flex; align-items: center; gap: 12px; }
.avatar-box {
  width: 32px;
  height: 32px;
  background: #f0f0f0;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 800;
  font-size: 12px;
  color: var(--mera-primary);
}

.member-info { display: flex; flex-direction: column; }
.member-info .name { font-size: 14px; font-weight: 700; }
.member-info .location { font-size: 11px; color: var(--mera-text-muted); }

.stash-cell { display: flex; flex-direction: column; gap: 2px; }
.tier-tag { font-size: 11px; font-weight: 700; color: var(--mera-primary); }
.stash-cell .amount { font-size: 13px; font-weight: 500; }

.status-pill {
  padding: 4px 12px;
  border-radius: 40px;
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
}

.status-pill.active { background: #e9fbf0; color: #34c759; }
.status-pill.pending { background: #fff5e6; color: #ff9f0a; }

.timeline-cell { display: flex; flex-direction: column; gap: 6px; width: 100px; }
.timeline-cell .days { font-size: 12px; font-weight: 700; }
.mini-progress { height: 4px; background: rgba(0,0,0,0.05); border-radius: 2px; overflow: hidden; }
.mini-progress .fill { height: 100%; background: var(--mera-primary); border-radius: 2px; }

/* Side Column Widgets */
.nudge-widget, .active-markets { padding: 32px; }
.side-column h3 { font-size: 18px; margin-bottom: 24px; }

.meter-wrap { margin-bottom: 20px; }
.meter-header { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 12px; }
.meter-header span { color: var(--mera-text-muted); font-weight: 500; }
.meter-header strong { font-weight: 800; }

.meter-bar { height: 6px; background: rgba(0,0,0,0.05); border-radius: 3px; overflow: hidden; }
.meter-fill { height: 100%; background: #34c759; border-radius: 3px; }
.meter-bar.pink .meter-fill { background: var(--mera-primary); }
.meter-bar.purple .meter-fill { background: var(--mera-accent); }

.market-list { display: flex; flex-direction: column; gap: 16px; }
.market-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 12px;
  background: rgba(0, 0, 0, 0.015);
  border-radius: 16px;
}

.market-item .flag { font-size: 24px; }
.market-info { flex: 1; display: flex; flex-direction: column; }
.market-info .country { font-size: 14px; font-weight: 700; }
.market-info .sub-count { font-size: 12px; color: var(--mera-text-muted); }

.trend-up { font-size: 11px; font-weight: 800; color: #34c759; }
.trend-soon { font-size: 10px; font-weight: 700; color: var(--mera-primary); opacity: 0.6; }

@media (max-width: 1200px) {
  .visual-grid { grid-template-columns: 1fr; }
  .metrics-grid { grid-template-columns: repeat(2, 1fr); }
}
</style>
