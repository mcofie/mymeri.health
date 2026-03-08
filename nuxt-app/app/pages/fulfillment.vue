<template>
  <NuxtLayout name="dashboard">
    <div class="fulfillment-page">
      <header class="page-header">
        <div>
          <h1>Fulfillment Center</h1>
          <p class="text-muted">Process packing slips for ready-to-dispatch orders.</p>
        </div>
      </header>

      <div class="slips-grid">
        <div v-for="slip in packingSlips" :key="slip.slip_id" class="slip-card glass" :class="{ 'discreet-border': slip.is_discreet }">
          <div class="slip-header">
            <span class="slip-id">#{{ slip.slip_id.slice(0, 8) }}</span>
            <span v-if="slip.is_discreet" class="discreet-badge">🤫 Discreet Packaging</span>
          </div>

          <div class="customer-preview">
            <h3>{{ slip.full_name }}</h3>
            <p class="address">{{ slip.address }}</p>
            <p class="phone">{{ slip.whatsapp_id }}</p>
          </div>

          <div class="items-list">
            <h4>Included in Box:</h4>
            <div class="tier-bubble">{{ slip.items_json.tier }} Tier</div>
            <ul>
              <li v-for="item in slip.items_json.items" :key="item.id">
                {{ item.quantity }}x {{ item.inventory.name }}
              </li>
            </ul>
          </div>

          <div class="slip-footer">
            <div class="footer-btns">
              <button class="btn-secondary glass" @click="printLabel(slip)">🖨️ Label</button>
              <button class="btn-primary glass" @click="dispatch(slip.slip_id)" :disabled="slip.status === 'Packed'">
                {{ slip.status === 'Packed' ? 'Dispatched' : 'Mark Packed' }}
              </button>
            </div>
          </div>
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
            <span v-if="selectedLabel.is_discreet">⚠️ RECIPIENT REQUESTED DISCREET PACKAGING</span>
            <span v-else>FRAGILE - HANDLE WITH CARE</span>
          </div>
        </div>
      </div>

      <div v-if="packingSlips.length === 0" class="empty-state glass">
        <p>No new orders to fulfill. Relax! ☕</p>
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
    // 1. Update Packing Slip status
    const { error: psError } = await supabase
        .from('packing_slips')
        .update({ status: 'Packed' })
        .eq('id', id)
    
    if (!psError) {
        // 2. Ideally update the Order status too
        // In fulfillment_view, we have slip_id. We'd need the order_id to update the order.
        // For brevity, we update local state
        const slip = packingSlips.value.find(s => s.slip_id === id)
        if (slip) slip.status = 'Packed'
    }
}

onMounted(fetchSlips)
</script>

<style scoped>
.fulfillment-page { display: flex; flex-direction: column; gap: 32px; }

.slips-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 24px;
}

.slip-card {
    padding: 24px;
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.slip-card.discreet-border {
    border-top: 4px solid var(--mera-accent);
}

.slip-header { display: flex; justify-content: space-between; align-items: center; }
.slip-id { font-size: 12px; color: var(--mera-text-muted); font-family: monospace; }
.discreet-badge { font-size: 10px; background: rgba(255, 77, 148, 0.1); color: var(--mera-accent); padding: 2px 8px; border-radius: 4px; }

.customer-preview h3 { font-size: 18px; margin-bottom: 4px; }
.address { font-size: 13px; color: var(--mera-text-muted); line-height: 1.4; }
.phone { font-size: 13px; color: var(--mera-accent); margin-top: 4px; }

.items-list h4 { font-size: 13px; margin-bottom: 12px; color: var(--mera-text-muted); }
.tier-bubble { display: inline-block; margin-bottom: 12px; background: rgba(255, 255, 255, 0.05); padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; }
.items-list ul { list-style: none; padding: 0; display: flex; flex-direction: column; gap: 6px; }
.items-list li { font-size: 14px; }

.slip-footer { margin-top: auto; }
.footer-btns { display: grid; grid-template-columns: 100px 1fr; gap: 12px; }
.btn-primary { padding: 12px; border-radius: 12px; cursor: pointer; }
.btn-secondary { padding: 12px; border-radius: 12px; cursor: pointer; color: var(--mera-text-muted); font-size: 13px; }

/* Print Mode Styles */
.printable-label { display: none; }

@media print {
    /* Hide everything on the page except the printable-label */
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
    .dashboard-layout, .fulfillment-page, .sidebar, .top-bar { display: none !important; }

    .printable-label {
        font-family: sans-serif;
        border: 2px solid black;
        border-radius: 0;
    }
    .label-heading { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
    .mera-logo { font-size: 24px; font-weight: bold; }
    .label-type { font-size: 14px; border: 1px solid black; padding: 4px 8px; }
    .recipient-box { margin: 40px 0; }
    .label-sm { font-size: 12px; font-weight: bold; color: #666; }
    .recipient-name { font-size: 32px; margin: 10px 0; }
    .recipient-address { font-size: 20px; line-height: 1.4; color: black; }
    .recipient-phone { font-size: 16px; margin-top: 10px; font-weight: bold; }
    .label-footer { margin-top: 60px; display: flex; align-items: center; gap: 20px; border-top: 1px dashed #ccc; padding-top: 20px; }
    .qr-placeholder { font-size: 40px; border: 1px solid #ccc; padding: 20px; }
    .instructions { font-size: 14px; color: black; }
}
</style>
