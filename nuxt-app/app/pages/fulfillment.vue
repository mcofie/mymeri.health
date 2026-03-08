<template>
  <NuxtLayout name="dashboard">
    <div class="fulfillment-page">
      <header class="page-header">
        <div class="header-left">
          <h1>Fulfillment Center</h1>
          <p class="text-muted">Process packing slips for <strong>{{ packingSlips.length }}</strong> ready-to-dispatch orders.</p>
        </div>
      </header>

      <div class="fulfillment-content">
        <div v-if="packingSlips.length > 0" class="slips-grid animate-fade-in">
          <div v-for="slip in packingSlips" :key="slip.slip_id" class="slip-card glass" :class="{ 'discreet-priority': slip.is_discreet }">
            <div class="card-glow"></div>
            
            <header class="slip-card-header">
              <div class="id-wrap">
                 <span class="slip-tag">Packing Slip</span>
                 <span class="slip-id">#{{ slip.slip_id.slice(0, 8) }}</span>
              </div>
              <div v-if="slip.is_discreet" class="discreet-badge-premium animate-pulse">
                <span>🤫 Discreet</span>
              </div>
            </header>

            <div class="customer-section">
              <h3 class="customer-name">{{ slip.full_name }}</h3>
              <p class="address-box">{{ slip.address }}</p>
              <div class="wa-pill">
                 <span class="wa-icon">💬</span>
                 <span class="wa-id">{{ slip.whatsapp_id }}</span>
              </div>
            </div>

            <div class="fulfillment-items">
              <div class="tier-indicator" :class="slip.items_json.tier.toLowerCase()">
                <span class="tier-dot"></span>
                <span class="tier-label">{{ slip.items_json.tier }} Plan</span>
              </div>
              
              <ul class="items-checklist">
                <li v-for="item in slip.items_json.items" :key="item.id" class="item-entry">
                  <div class="qty-box">{{ item.quantity }}x</div>
                  <span class="item-name">{{ item.inventory.name }}</span>
                </li>
              </ul>
            </div>

            <footer class="slip-card-footer">
              <button class="btn-util glass" @click="printLabel(slip)">
                <span>🖨️ Label</span>
              </button>
              <button class="btn-dispatch glass" @click="dispatch(slip.slip_id)" :disabled="slip.status === 'Packed'">
                 <span v-if="slip.status === 'Packed'">✅ Dispatched</span>
                 <span v-else>Mark Packed →</span>
              </button>
            </footer>
          </div>
        </div>

        <div v-else class="empty-state-fulfillment glass animate-fade-in">
          <div class="illustration-wrap">☕</div>
          <h2>All Clear!</h2>
          <p>The fulfilment queue is empty. Catch up on messages or grab a coffee until the next stash order arrives.</p>
          <NuxtLink to="/messages" class="btn-secondary-sm glass">Check Messages</NuxtLink>
        </div>
      </div>

      <!-- Hidden Label Template for Printing -->
      <div id="print-label-template" v-if="selectedLabel" class="printable-label">
        <div class="label-heading">
          <span class="mera-logo">MyMeri.health</span>
          <span class="label-type">PRIORITY DELIVERY</span>
        </div>
        <hr />
        <div class="recipient-box">
          <span class="label-sm">DELIVER TO:</span>
          <h1 class="recipient-name">{{ selectedLabel.full_name }}</h1>
          <p class="recipient-address">{{ selectedLabel.address }}</p>
          <p class="recipient-phone">WA: {{ selectedLabel.whatsapp_id }}</p>
        </div>
        <div class="label-footer">
          <div class="qr-placeholder">📦</div>
          <div class="instructions">
            <span v-if="selectedLabel.is_discreet" class="urgent-text">⚠️ RECIPIENT REQUESTED DISCREET PACKAGING</span>
            <span v-else>FRAGILE - HANDLE WITH CARE</span>
          </div>
        </div>
      </div>
    </div>
  </NuxtLayout>
</template>

<script setup>
const supabase = useSupabaseClient()
const packingSlips = ref([])
const selectedLabel = ref(null)

const fetchSlips = async () => {
    const { data } = await supabase
        .from('fulfillment_view')
        .select('*')
        .order('status', { ascending: false })
    
    packingSlips.value = data || []
}

const printLabel = (slip) => {
    selectedLabel.value = slip
    nextTick(() => {
        window.print()
        selectedLabel.value = null
    })
}

const dispatch = async (id) => {
    const { error: psError } = await supabase
        .from('packing_slips')
        .update({ status: 'Packed' })
        .eq('id', id)
    
    if (!psError) {
        const slip = packingSlips.value.find(s => s.slip_id === id)
        if (slip) slip.status = 'Packed'
    }
}

onMounted(fetchSlips)
</script>

<style scoped>
.fulfillment-page { display: flex; flex-direction: column; gap: 40px; }
.header-left h1 { font-size: 32px; font-weight: 800; margin-bottom: 8px; }

.slips-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
    gap: 32px;
}

.slip-card {
    padding: 32px;
    display: flex;
    flex-direction: column;
    gap: 24px;
    position: relative;
    overflow: hidden;
    transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}
.slip-card:hover { transform: translateY(-8px); }

.discreet-priority {
  border-left: 6px solid var(--mera-accent) !important;
}

.slip-card-header { display: flex; justify-content: space-between; align-items: flex-start; }
.id-wrap { display: flex; flex-direction: column; gap: 4px; }
.slip-tag { font-size: 10px; text-transform: uppercase; letter-spacing: 1px; color: var(--mera-text-muted); font-weight: 700; }
.slip-id { font-size: 14px; color: var(--mera-text); font-family: monospace; font-weight: 600; }

.discreet-badge-premium {
  background: var(--mera-accent);
  color: white;
  padding: 6px 12px;
  border-radius: 40px;
  font-size: 11px;
  font-weight: 800;
  box-shadow: 0 4px 12px rgba(255, 77, 148, 0.3);
}

.customer-section { display: flex; flex-direction: column; gap: 8px; }
.customer-name { font-size: 22px; font-weight: 800; }
.address-box { font-size: 14px; color: var(--mera-text-muted); line-height: 1.5; }
.wa-pill { display: flex; align-items: center; gap: 8px; margin-top: 4px; }
.wa-id { font-size: 13px; font-weight: 700; color: var(--mera-primary); }

.fulfillment-items {
  background: rgba(0,0,0,0.02);
  padding: 20px;
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.tier-indicator { display: flex; align-items: center; gap: 8px; }
.tier-dot { width: 8px; height: 8px; border-radius: 50%; }
.tier-indicator.comfort .tier-dot { background: #a272ff; box-shadow: 0 0 10px #a272ff; }
.tier-indicator.essential .tier-dot { background: #34c759; box-shadow: 0 0 10px #34c759; }
.tier-label { font-size: 12px; font-weight: 800; text-transform: uppercase; opacity: 0.8; }

.items-checklist { list-style: none; padding: 0; display: flex; flex-direction: column; gap: 10px; }
.item-entry { display: flex; align-items: center; gap: 12px; font-size: 15px; font-weight: 500; }
.qty-box { background: rgba(0,0,0,0.05); padding: 2px 8px; border-radius: 6px; font-size: 12px; font-weight: 800; color: var(--mera-primary); }

.slip-card-footer { display: grid; grid-template-columns: 1fr 2fr; gap: 12px; margin-top: auto; }

.btn-util, .btn-dispatch {
  padding: 14px;
  border-radius: 14px;
  border: none;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-util { color: var(--mera-text-muted); }
.btn-dispatch { background: var(--mera-primary); color: white; }
.btn-dispatch:disabled { background: #e9fbf0; color: #34c759; opacity: 1; cursor: default; }

.empty-state-fulfillment {
  padding: 100px 40px;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}
.illustration-wrap { font-size: 80px; }
.empty-state-fulfillment h2 { font-size: 28px; font-weight: 800; }
.empty-state-fulfillment p { color: var(--mera-text-muted); max-width: 450px; line-height: 1.6; margin-bottom: 20px; }

.btn-secondary-sm { padding: 12px 24px; border-radius: 12px; text-decoration: none; color: var(--mera-text); font-weight: 700; font-size: 14px; }

/* Print Mode Styles */
.printable-label { display: none; }
.urgent-text { font-weight: 900; background: #000; color: #fff; padding: 4px; }

@media print {
    body * { visibility: hidden; }
    #print-label-template, #print-label-template * { visibility: visible; }
    #print-label-template {
        display: block !important;
        position: fixed;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        padding: 40px;
        background: white !important;
        color: black !important;
    }
}
</style>
