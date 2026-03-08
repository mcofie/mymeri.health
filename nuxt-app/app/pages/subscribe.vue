<template>
  <div class="subscribe-page">
    <nav class="simple-nav">
      <NuxtLink to="/" class="logo">MyMeri<span class="dot">.</span></NuxtLink>
    </nav>

    <div class="subscribe-container">
      <header class="page-header narrow">
        <span class="step-label">Step 1 of 2</span>
        <h1 class="premium-gradient">End the Pharmacy Dash</h1>
        <p class="text-muted">Save 20% and gain total security with a 3-month "Stock-Up" supply.</p>
      </header>

      <!-- Cycle Pivot Toggle -->
      <div class="cycle-pivot glass animate-fade-in">
        <button 
          class="pivot-btn" 
          :class="{ active: form.cyclePreference === 'Monthly' }"
          @click="form.cyclePreference = 'Monthly'"
        >
          Monthly Flow
          <span>Standard Delivery</span>
        </button>
        <button 
          class="pivot-btn stock-up" 
          :class="{ active: form.cyclePreference === 'Quarterly' }"
          @click="form.cyclePreference = 'Quarterly'"
        >
          Stock-Up (Bulk) 💎
          <span>3 Months of Security</span>
        </button>
      </div>

      <!-- Tier Selection Section -->
      <section class="tiers-selection">
        <div class="tier-grid">
          <div 
            v-for="tier in filteredTiers" 
            :key="tier.name" 
            class="tier-pill glass" 
            :class="{ active: selectedTier === tier.name, 'featured-glow': tier.name === 'Peace of Mind' }"
            @click="selectedTier = tier.name"
          >
            <div class="tier-icon">{{ tier.icon }}</div>
            <div class="tier-info">
              <div class="tier-badge-row">
                <h3>{{ tier.name }}</h3>
                <span v-if="tier.savings" class="savings-tag">{{ tier.savings }} Savings</span>
              </div>
              <p>{{ tier.price[form.country] }} {{ form.cyclePreference === 'Quarterly' ? '(Quarterly)' : '/ Mo' }}</p>
            </div>
            <div class="check-circle" v-if="selectedTier === tier.name">✓</div>
          </div>
        </div>

        <!-- Custom Item Selection (A La Carte) -->
        <div v-if="selectedTier === 'Custom'" class="custom-builder glass animate-fade-in">
          <header class="builder-header">
            <h3>Custom Box Builder</h3>
            <p class="text-muted">Available in {{ marketName }}</p>
          </header>
          
          <div class="item-grid">
            <div 
              v-for="item in inventoryItems" 
              :key="item.id" 
              class="inventory-item" 
              :class="{ selected: getItemQuantity(item.id) > 0 }"
            >
              <div class="item-meta">
                <span class="item-name">{{ item.name }}</span>
                <span class="item-price">{{ item.currency }} {{ item.price }}</span>
              </div>
              
              <div class="quantity-controls" v-if="getItemQuantity(item.id) > 0">
                <button class="qty-btn" @click="updateQuantity(item, -1)">-</button>
                <span class="qty-count">{{ getItemQuantity(item.id) }}</span>
                <button class="qty-btn" @click="updateQuantity(item, 1)">+</button>
              </div>
              <div v-else class="item-action" @click="updateQuantity(item, 1)">
                + Add
              </div>
            </div>
          </div>

          <div class="builder-footer" v-if="selectedItems.length > 0">
            <div class="total-bar">
              <span>Your Custom Total:</span>
              <strong>{{ currentCurrency }} {{ customTotal }}</strong>
            </div>
          </div>
          <div v-else class="empty-builder">
            <p>Select items below to build your tailored box.</p>
          </div>
        </div>

        <div class="selected-tier-details glass" v-if="currentTier && selectedTier !== 'Custom'">
          <div class="detail-header">
            <h4>Included in {{ currentTier.name }} Box:</h4>
            <span class="price-bubble">{{ currentTier.price[form.country] }}</span>
          </div>
          <ul class="feature-list">
            <li v-for="feature in currentTier.features" :key="feature">{{ feature }}</li>
          </ul>
        </div>
      </section>

      <!-- Details Form Section -->
      <section class="details-section">
        <header class="page-header">
          <span class="step-label">Step 2 of 2</span>
          <h2>Delivery & Cycle Tracking</h2>
          <p class="text-muted">We use this to nudge you exactly 7 days before your cycle starts.</p>
        </header>

        <div class="form-card glass">
          <form @submit.prevent="handleSubscribe" class="auth-form">
            <div class="input-row">
              <div class="input-group">
                <label>Market</label>
                <select v-model="form.country" class="glass-input">
                  <option value="GH">Ghana 🇬🇭</option>
                  <option value="NG">Nigeria 🇳🇬</option>
                  <option value="KE">Kenya 🇰🇪</option>
                </select>
              </div>
              <div class="input-group">
                <label>WhatsApp Number</label>
                <input v-model="form.whatsapp" type="tel" placeholder="+233..." class="glass-input" required />
              </div>
            </div>

            <div class="input-group">
                <label>Full Name</label>
                <input v-model="form.name" type="text" placeholder="Ama Mensah" class="glass-input" required />
            </div>

            <div class="input-row">
              <div class="input-group">
                <label>Last Period Date</label>
                <input v-model="form.lastDate" type="date" class="glass-input" required />
              </div>
              <div class="input-group">
                <label>Cycle Length (Days)</label>
                <input v-model="form.cycleLength" type="number" min="20" max="45" class="glass-input" required />
              </div>
            </div>

            <div class="input-group">
              <label>Delivery Address</label>
              <textarea v-model="form.address" placeholder="Digital Address or Landmarks..." class="glass-input" required></textarea>
            </div>

            <div class="privacy-note">
              <input type="checkbox" id="discreet" v-model="form.is_discreet" />
              <label for="discreet">I would like Discreet Packaging (plain box, no branding) 🤫</label>
            </div>

            <button type="submit" class="btn-submit pink-glow" :disabled="loading || (selectedTier === 'Custom' && selectedItems.length === 0)">
              <span v-if="loading">Finalizing...</span>
              <span v-else-if="selectedTier === 'Custom' && selectedItems.length === 0">Add Items to Continue</span>
              <span v-else>Confirm Subscription & Get My Link</span>
            </button>
          </form>
        </div>
      </section>
    </div>

    <!-- Success Modal Overlay -->
    <div v-if="success" class="modal-overlay">
      <div class="success-card glass">
        <div class="success-icon">🎉</div>
        <h2>Welcome to the Flow, {{ form.name.split(' ')[0] }}!</h2>
        <p>Your subscription is being processed. We've sent a confirmation to your WhatsApp. You will receive your first payment link 3 days before your cycle starts.</p>
        <NuxtLink to="/" class="btn-primary glass">Back to Home</NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const loading = ref(false)
const success = ref(false)
const selectedTier = ref('Comfort')
const inventoryItems = ref([])
const selectedItems = ref([])

const tiers = [
  { name: 'Essential', icon: '🌸', mode: 'Monthly', price: { GH: 'GHS 120', NG: 'NGN 2500', KE: 'KES 850' }, features: ['Premium Eco-Pads (12ct)', 'WhatsApp Cycle Tracking', 'Standard Packaging'] },
  { name: 'Comfort', icon: '✨', mode: 'Monthly', price: { GH: 'GHS 200', NG: 'NGN 4500', KE: 'KES 1500' }, features: ['Essential + Night Pads', 'Cramp Relief Tea', 'Artisanal Dark Chocolate', 'Priority Packaging'] },
  { name: 'Peace of Mind', icon: '💎', mode: 'Quarterly', savings: '20%', price: { GH: 'GHS 480', NG: 'NGN 10500', KE: 'KES 3500' }, features: ['Full 3-Month Bulk Supply', 'Quarterly Delivery (Single Trip)', 'Priority "Emergency Fetch" Access', 'Maximum Price Savings'] },
  { name: 'Custom', icon: '🎨', mode: 'Both', price: { GH: 'Tailor Your Own', NG: 'Tailor Your Own', KE: 'Tailor Your Own' }, features: ['Pick items individually', 'Quantity bulk selectors', 'Pay based on selection'] }
]

const form = reactive({
  country: 'GH',
  whatsapp: '',
  name: '',
  address: '',
  lastDate: '',
  cycleLength: 28,
  is_discreet: false,
  cyclePreference: 'Monthly'
})

const filteredTiers = computed(() => {
    return tiers.filter(t => t.mode === form.cyclePreference || t.mode === 'Both')
})

const currentTier = computed(() => tiers.find(t => t.name === selectedTier.value))
const currentCurrency = computed(() => ({'GH': 'GHS', 'NG': 'NGN', 'KE': 'KES'}[form.country]))
const marketName = computed(() => ({'GH': 'Ghana', 'NG': 'Nigeria', 'KE': 'Kenya'}[form.country]))

const customTotal = computed(() => {
  return selectedItems.value.reduce((sum, item) => sum + (Number(item.price) * item.quantity), 0)
})

const fetchInventory = async () => {
    const { data } = await supabase
        .from('inventory')
        .select('*')
        .eq('country_code', form.country)
    inventoryItems.value = data || []
}

const updateQuantity = (item, delta) => {
    const index = selectedItems.value.findIndex(i => i.id === item.id)
    if (index > -1) {
        selectedItems.value[index].quantity += delta
        if (selectedItems.value[index].quantity <= 0) {
            selectedItems.value.splice(index, 1)
        }
    } else if (delta > 0) {
        selectedItems.value.push({ ...item, quantity: delta })
    }
}

const getItemQuantity = (id) => {
    const item = selectedItems.value.find(i => i.id === id)
    return item ? item.quantity : 0
}

watch(() => form.country, () => {
    fetchInventory()
    selectedItems.value = [] // Reset on country change
})

onMounted(fetchInventory)

const handleSubscribe = async () => {
  loading.value = true
  
  try {
    // 1. Create/Upsert Profile
    await supabase.from('profiles').upsert({
      whatsapp_id: form.whatsapp,
      full_name: form.name,
      address: form.address,
      country_code: form.country
    }, { onConflict: 'whatsapp_id' })

    const { data: profileData } = await supabase.from('profiles').select('id').eq('whatsapp_id', form.whatsapp).single()
    
    if (profileData) {
        const currencyMap = { 'GH': 'GHS', 'NG': 'NGN', 'KE': 'KES' }
        const subData = {
            user_id: profileData.id,
            box_tier: selectedTier.value,
            last_period_date: form.lastDate,
            cycle_length: form.cycleLength,
            status: 'Active',
            country_code: form.country,
            currency: currencyMap[form.country] || 'GHS',
            billing_cycle: form.cyclePreference,
            nudge_buffer_days: form.cyclePreference === 'Quarterly' ? 14 : 7
        }

        if (selectedTier.value === 'Custom') {
            subData.custom_items_json = selectedItems.value.map(i => ({ 
                id: i.id, 
                name: i.name, 
                price: i.price,
                quantity: i.quantity 
            }))
        }

        const { error: subError } = await supabase.from('subscriptions').insert(subData)
        
        if (!subError) success.value = true
        else console.error('Sub Error:', subError)
    }
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.subscribe-page {
  background: var(--mera-bg);
  min-height: 100vh;
  padding-bottom: 100px;
}

.simple-nav {
  padding: 24px;
}

.logo { font-size: 24px; font-weight: 700; text-decoration: none; color: var(--mera-text); }
.dot { color: var(--mera-primary); }

.subscribe-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 0 24px;
}

.page-header {
  margin-bottom: 40px;
  text-align: center;
}

.step-label {
  font-size: 11px;
  text-transform: uppercase;
  color: var(--mera-primary);
  font-weight: 700;
  letter-spacing: 1px;
}

.narrow { max-width: 600px; margin-left: auto; margin-right: auto; }

.cycle-pivot {
    display: flex;
    padding: 6px;
    border-radius: 20px;
    margin-bottom: 40px;
}

.pivot-btn {
    flex: 1;
    padding: 16px;
    border-radius: 16px;
    border: none;
    background: transparent;
    cursor: pointer;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    transition: all 0.3s;
    font-weight: 600;
    color: var(--mera-text-muted);
}

.pivot-btn span { font-size: 11px; font-weight: 400; opacity: 0.7; }
.pivot-btn.active { background: white; color: var(--mera-text); box-shadow: 0 4px 20px rgba(0,0,0,0.06); }
.pivot-btn.stock-up.active { color: var(--mera-primary); }

.tier-badge-row { display: flex; align-items: center; gap: 12px; margin-bottom: 4px; }

.savings-tag {
    background: #34c759;
    color: white;
    font-size: 10px;
    padding: 2px 8px;
    border-radius: 6px;
    font-weight: 700;
}

.featured-glow {
    border-color: rgba(255, 77, 148, 0.3) !important;
    background: rgba(255, 77, 148, 0.03) !important;
    box-shadow: 0 10px 40px rgba(255, 77, 148, 0.08) !important;
}

h1 { font-size: 40px; margin: 12px 0; }
h2 { font-size: 32px; margin: 12px 0; }

.tier-grid {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 24px;
}

.tier-pill {
  display: flex;
  align-items: center;
  padding: 20px 32px;
  border-radius: 24px;
  cursor: pointer;
  transition: all 0.3s;
  gap: 24px;
}

.tier-pill.active {
  background: rgba(255, 77, 148, 0.02);
  border-color: rgba(255, 77, 148, 0.2);
}

.tier-icon { font-size: 32px; }

.tier-info { flex: 1; }
.tier-info h3 { font-size: 18px; margin-bottom: 4px; }
.tier-info p { font-size: 14px; color: var(--mera-text-muted); }

.check-circle {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: var(--mera-primary);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
}

/* Custom Builder Styles */
.custom-builder {
    padding: 32px;
    border-radius: 32px;
    margin-bottom: 80px;
}

.builder-header { margin-bottom: 24px; }
.builder-header h3 { font-size: 20px; margin-bottom: 4px; }

.item-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
}

.inventory-item {
    padding: 16px 20px;
    border: 1px solid var(--mera-border);
    border-radius: 16px;
    cursor: pointer;
    display: flex;
    justify-content: space-between;
    align-items: center;
    transition: all 0.2s;
}

.inventory-item:hover { border-color: var(--mera-primary); }
.inventory-item.selected { background: rgba(255, 77, 148, 0.02); border-color: var(--mera-primary); }

.item-meta { display: flex; flex-direction: column; }
.item-name { font-size: 14px; font-weight: 500; }
.item-price { font-size: 12px; color: var(--mera-text-muted); }

.item-action { font-size: 12px; font-weight: 700; color: var(--mera-primary); cursor: pointer; }

.quantity-controls {
    display: flex;
    align-items: center;
    gap: 12px;
    background: white;
    padding: 4px 8px;
    border-radius: 12px;
    border: 1px solid var(--mera-border);
}

.qty-btn {
    border: none;
    background: none;
    color: var(--mera-primary);
    font-size: 16px;
    font-weight: 700;
    cursor: pointer;
    width: 24px;
    height: 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
}

.qty-btn:hover { transform: scale(1.2); }

.qty-count {
    font-size: 14px;
    font-weight: 700;
    min-width: 16px;
    text-align: center;
}

.total-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 18px;
}

.empty-builder { text-align: center; padding: 40px; color: var(--mera-text-muted); font-size: 14px; }

.selected-tier-details {
  padding: 32px;
  border-radius: 24px;
  margin-bottom: 80px;
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.price-bubble {
  background: rgba(0, 0, 0, 0.02);
  padding: 4px 12px;
  border-radius: 12px;
  font-weight: 700;
  color: var(--mera-primary);
}

.feature-list {
  list-style: none;
  padding: 0;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.feature-list li {
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.feature-list li::before { content: "✨"; font-size: 12px; }

.form-card {
  padding: 48px;
  border-radius: 32px;
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.input-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

.input-group { display: flex; flex-direction: column; gap: 8px; }
label { font-size: 13px; color: var(--mera-text-muted); }

.glass-input {
  background: rgba(0, 0, 0, 0.02);
  border: 1px solid var(--mera-border);
  padding: 14px 18px;
  border-radius: 14px;
  color: var(--mera-text);
  font-size: 15px;
}

textarea.glass-input { height: 100px; resize: none; }

.privacy-note {
  display: flex;
  gap: 12px;
  align-items: center;
  font-size: 14px;
  color: var(--mera-text-muted);
}

.btn-submit {
  background: var(--mera-primary);
  color: white;
  padding: 18px;
  border-radius: 40px;
  border: none;
  font-weight: 600;
  cursor: pointer;
}

.btn-submit:disabled { opacity: 0.5; cursor: not-allowed; }

.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(20px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 24px;
}

.success-card {
  max-width: 500px;
  padding: 64px 48px;
  text-align: center;
  border-radius: 40px;
}

.success-icon { font-size: 64px; margin-bottom: 24px; }
.success-card h2 { margin-bottom: 16px; }
.success-card p { margin-bottom: 32px; line-height: 1.6; color: var(--mera-text-muted); }

/* Mobile Adjustments */
@media (max-width: 768px) {
  .input-row, .feature-list, .item-grid {
    grid-template-columns: 1fr;
  }
  
  .tier-pill {
    padding: 16px 20px;
    gap: 16px;
  }
  
  .form-card { padding: 24px; }
  
  h1 { font-size: 32px; }
  h2 { font-size: 24px; }

  .price-bubble { font-size: 14px; }
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

.animate-fade-in { animation: fadeIn 0.4s ease forwards; }
</style>
