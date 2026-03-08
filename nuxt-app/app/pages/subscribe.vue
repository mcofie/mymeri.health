<template>
  <div class="subscribe-page">
    <nav class="simple-nav">
      <NuxtLink to="/" class="logo">MyMeri<span class="dot">.</span></NuxtLink>
      <div class="step-indicator">
        <div class="step-dot" :class="{ active: currentStep >= 1, completed: currentStep > 1 }"><span>1</span></div>
        <div class="step-line" :class="{ active: currentStep > 1 }"></div>
        <div class="step-dot" :class="{ active: currentStep >= 2, completed: currentStep > 2 }"><span>2</span></div>
        <div class="step-line" :class="{ active: currentStep > 2 }"></div>
        <div class="step-dot" :class="{ active: currentStep >= 3 }"><span>3</span></div>
      </div>
    </nav>

    <div class="subscribe-nexus">
      <div class="flow-content">
        <!-- Step 1: Market & Foundation -->
        <section v-if="currentStep === 1" class="step-section animate-fade-in">
          <header class="section-header">
            <h1 class="premium-gradient">{{ greeting }}, {{ marketName }}</h1>
            <p class="text-muted">Where should we deliver, and how often would you like to stock up?</p>
          </header>

          <div class="market-grid">
            <div 
              v-for="m in markets" 
              :key="m.code" 
              class="selector-card glass" 
              :class="{ active: form.country === m.code }"
              @click="form.country = m.code"
            >
              <span class="market-flag">{{ m.flag }}</span>
              <div class="market-name">
                <h3>{{ m.name }}</h3>
              </div>
              <div class="check-mark" v-if="form.country === m.code">✓</div>
            </div>
          </div>

          <div class="cycle-comparison glass">
            <header class="comp-header">
               <h3>Subscription Strategy</h3>
               <p>The "Stock-Up" option secures your essentials for 3 full months at a time.</p>
            </header>
            
            <div class="pivot-options">
              <button 
                class="pivot-selector" 
                :class="{ active: form.cyclePreference === 'Monthly' }"
                @click="form.cyclePreference = 'Monthly'"
              >
                <div class="pivot-meta">
                  <span class="pivot-title">Monthly Flow</span>
                  <p>Flexible, month-to-month delivery.</p>
                </div>
              </button>

              <button 
                class="pivot-selector stock-up" 
                :class="{ active: form.cyclePreference === 'Quarterly' }"
                @click="form.cyclePreference = 'Quarterly'"
              >
                <span class="savings-badge">💎 Recommended: Save 20%</span>
                <div class="pivot-meta">
                  <span class="pivot-title">Stock-Up (Bulk)</span>
                  <p>Maximum security. One delivery every 90 days.</p>
                </div>
              </button>
            </div>
          </div>

          <div class="trust-strip">
             <div class="trust-item"><span class="t-icon">🔒</span> Secure Checkout</div>
             <div class="trust-item"><span class="t-icon">🤫</span> Discreet Delivery</div>
             <div class="trust-item"><span class="t-icon">⚡</span> Priority Support</div>
          </div>

          <footer class="flow-footer">
            <button class="btn-next pink-glow" @click="nextStep">Continue to Box Selection →</button>
          </footer>
        </section>

        <!-- Step 2: The Box Selection -->
        <section v-if="currentStep === 2" class="step-section animate-fade-in">
          <header class="section-header">
            <h1 class="premium-gradient">Choose Your Stash</h1>
            <p class="text-muted">Explore our local curated boxes or build a custom one.</p>
          </header>

          <div class="tier-stack">
            <div 
              v-for="tier in filteredTiers" 
              :key="tier.name" 
              class="tier-row glass" 
              :class="{ active: selectedTier === tier.name, 'peace-glow': tier.name === 'Peace of Mind' }"
              @click="selectedTier = tier.name"
            >
              <div class="tier-intro">
                <span class="tier-icon-box">{{ tier.icon }}</span>
                <div class="tier-label-group">
                  <h3>{{ tier.name }}</h3>
                  <p v-if="tier.name !== 'Custom'">{{ tier.features.length }} essentials inside</p>
                  <p v-else>Pick items individually</p>
                </div>
              </div>
              
              <div class="tier-price-nexus">
                <span class="price-val">{{ currentCurrency }} {{ tier.price[form.country] }}</span>
                <span class="price-freq">{{ form.cyclePreference === 'Quarterly' ? '/ Quarter' : '/ Month' }}</span>
              </div>
            </div>
          </div>

          <!-- Custom Builder Integration -->
          <div v-if="selectedTier === 'Custom'" class="custom-builder-nexus glass animate-fade-in">
             <header class="nexus-header">
                <h3>A La Carte Collection</h3>
                <p class="text-muted">Stock available for {{ marketName }}</p>
             </header>

             <div class="inventory-nexus-grid">
               <div 
                 v-for="item in inventoryItems" 
                 :key="item.id" 
                 class="item-pill"
                 :class="{ active: getItemQuantity(item.id) > 0 }"
               >
                 <div class="item-info">
                   <span class="item-name">{{ item.name }}</span>
                   <span class="item-price">{{ item.currency }} {{ item.price }}</span>
                 </div>
                 <div class="item-controls" v-if="getItemQuantity(item.id) > 0">
                   <button @click="updateQuantity(item, -1)">-</button>
                   <span class="count">{{ getItemQuantity(item.id) }}</span>
                   <button @click="updateQuantity(item, 1)">+</button>
                 </div>
                 <button v-else class="add-btn" @click="updateQuantity(item, 1)">+ Add</button>
               </div>
             </div>
          </div>

          <div class="tier-details-nexus" v-if="currentTier && selectedTier !== 'Custom'">
             <ul class="feature-grid">
                <li v-for="f in currentTier.features" :key="f">{{ f }}</li>
             </ul>
          </div>

          <footer class="flow-footer">
            <button class="btn-prev" @click="prevStep">← Back</button>
            <button 
              class="btn-next pink-glow" 
              @click="nextStep"
              :disabled="isCustom && selectedItems.length === 0"
            >
              Step 3: Delivery Details →
            </button>
          </footer>
        </section>

        <!-- Step 3: Delivery Details -->
        <section v-if="currentStep === 3" class="step-section animate-fade-in">
          <header class="section-header">
            <h1 class="premium-gradient">Final Details</h1>
            <p class="text-muted">Just a few more specifics to secure your stash.</p>
          </header>

          <div class="final-form glass">
             <form @submit.prevent="handleSubscribe" class="nexus-form">
                <div class="nexus-row">
                   <div class="nexus-group">
                      <label>WhatsApp ID</label>
                      <div class="phone-nexus glass-input">
                        <span class="p-prefix">{{ currentPrefix }}</span>
                        <input 
                          :value="localPhone" 
                          @input="handlePhoneInput"
                          type="tel" 
                          placeholder="24 123 4567" 
                          class="phone-input" 
                          required 
                        />
                      </div>
                   </div>
                   <div class="nexus-group">
                      <label>Full Name</label>
                      <input v-model="form.name" type="text" placeholder="Ama Mensah" class="nexus-input glass-input" required />
                   </div>
                </div>

                <div class="nexus-row">
                   <div class="nexus-group">
                      <label>
                        Last Period Start Date
                        <span class="info-tag" title="We use this to time your reminders exactly 7 days before your next flow.">? لماذا؟</span>
                      </label>
                      <div class="date-nexus glass-input">
                        <input v-model="dateSegments.dd" type="number" placeholder="DD" min="1" max="31" class="d-segment" @input="nextOnMax($event, 2, 'mm')" />
                        <span class="d-sep">/</span>
                        <input v-model="dateSegments.mm" id="mm-input" type="number" placeholder="MM" min="1" max="12" class="d-segment" @input="nextOnMax($event, 2, 'yyyy')" />
                        <span class="d-sep">/</span>
                        <input v-model="dateSegments.yyyy" id="yyyy-input" type="number" placeholder="YYYY" min="2024" max="2026" class="d-segment-large" />
                      </div>
                   </div>
                   <div class="nexus-group">
                      <label>Cycle Duration (Days)</label>
                      <input v-model="form.cycleLength" type="number" min="20" max="45" class="nexus-input glass-input" required />
                   </div>
                </div>

                <div class="nexus-group">
                   <label>Delivery Location</label>
                   <textarea v-model="form.address" placeholder="Digital Address or landmarks..." class="nexus-input glass-input" required></textarea>
                </div>

                <div class="discreet-toggle glass">
                   <input type="checkbox" id="discreet-box" v-model="form.is_discreet" />
                   <label for="discreet-box">
                      <strong>Discreet Packaging</strong>
                      <span>Plain branding-free box for your privacy. 🤫</span>
                   </label>
                </div>

                <footer class="flow-footer-final">
                  <button type="button" class="btn-prev" @click="prevStep">← Back</button>
                  <button type="submit" class="btn-submit pink-glow" :disabled="loading">
                    <span v-if="loading">Confirming...</span>
                    <span v-else>Confirm & Subscribe 💎</span>
                  </button>
                </footer>
             </form>
          </div>
        </section>
      </div>

      <!-- Persistent Summary Sidebar -->
      <aside v-if="!success" class="summary-sidebar glass">
        <h3>Stash Overview</h3>
        
        <div class="summary-item">
          <span class="label">Region</span>
          <span class="val">{{ marketName }}</span>
        </div>
        
        <div class="summary-item">
          <span class="label">Cycle</span>
          <span class="val">{{ form.cyclePreference }}</span>
        </div>

        <div v-if="selectedItems.length > 0" class="summary-items-list">
          <div v-for="i in selectedItems" :key="i.id" class="mini-item">
             <span>{{ i.quantity }}x {{ i.name }}</span>
             <span>{{ currentCurrency }} {{ i.price * i.quantity }}</span>
          </div>
        </div>

        <div class="summary-divider"></div>
        
        <div class="summary-total">
          <span class="total-label">Final Stash Total</span>
          <div class="total-nexus">
            <span class="total-curr">{{ currentCurrency }}</span>
            <span class="total-val">{{ isCustom ? customTotal : tierPrice }}</span>
            <span v-if="standardPrice" class="standard-price-cross">{{ currentCurrency }} {{ standardPrice }}</span>
          </div>
          <p v-if="form.cyclePreference === 'Quarterly'" class="savings-hint">20% Bulk Savings Applied 💎</p>
        </div>
      </aside>
    </div>
    
    <!-- Mobile Summary Bar (Sticky Footer) -->
    <div v-if="!success" class="mobile-summary-bar glass">
      <div class="m-summary-content">
        <button v-if="currentStep > 1" class="m-btn-prev" @click="prevStep">
          ←
        </button>
        <div class="m-summary-meta">
          <span class="m-label">{{ selectedTier }} ({{ form.cyclePreference }})</span>
          <div class="m-total">
            <span class="m-curr">{{ currentCurrency }}</span>
            <span class="m-val">{{ isCustom ? customTotal : tierPrice }}</span>
          </div>
        </div>
        <button v-if="currentStep < 3" class="m-btn-next pink-glow" @click="nextStep">
          Next
        </button>
        <button v-else class="m-btn-next pink-glow" @click="handleSubscribe" :disabled="loading">
          {{ loading ? '...' : 'Finish' }}
        </button>
      </div>
    </div>

    <!-- Success Overlays -->
    <Teleport to="body">
      <div v-if="success" class="success-overlay-nexus">
        <div class="success-card-nexus glass animate-scale-up">
           <div class="diamond-confetti">✨💎✨</div>
           <div class="celebration">🎉</div>
           <h1>Welcome to the Flow, {{ form.name.split(' ')[0] }}!</h1>
           <p>Your subscription is secured. We've recorded your cycle to ensure your stash arrives <strong>3 days before</strong> you need it.</p>
           
           <div class="roadmap glass">
              <div class="roadmap-item active">
                 <span class="r-dot"></span>
                 <p>Profile Created & Stash Reserved</p>
              </div>
              <div class="roadmap-item">
                 <span class="r-dot"></span>
                 <p>WhatsApp Link Sent (Within 10 mins)</p>
              </div>
              <div class="roadmap-item">
                 <span class="r-dot"></span>
                 <p>First Nudge (7 Days before cycle)</p>
              </div>
           </div>

           <NuxtLink to="/" class="btn-home glass pink-glow">Return to Home</NuxtLink>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const currentStep = ref(1)
const loading = ref(false)
const success = ref(false)
const selectedTier = ref('Comfort')
const inventoryItems = ref([])
const selectedItems = ref([])

const markets = [
  { code: 'GH', name: 'Ghana', flag: '🇬🇭', currency: 'GHS', prefix: '+233' },
  { code: 'NG', name: 'Nigeria', flag: '🇳🇬', currency: 'NGN', prefix: '+234' },
  { code: 'KE', name: 'Kenya', flag: '🇰🇪', currency: 'KES', prefix: '+254' }
]

const tiers = [
  { name: 'Essential', icon: '🌸', mode: 'Monthly', price: { GH: '120', NG: '2500', KE: '850' }, features: ['Premium Eco-Pads (12ct)', 'WhatsApp Cycle Tracking', 'Standard Packaging'] },
  { name: 'Comfort', icon: '✨', mode: 'Monthly', price: { GH: '200', NG: '4500', KE: '1500' }, features: ['Essential + Night Pads', 'Cramp Relief Tea', 'Artisanal Dark Chocolate', 'Priority Packaging'] },
  { name: 'Peace of Mind', icon: '💎', mode: 'Quarterly', price: { GH: '480', NG: '10500', KE: '3500' }, features: ['Full 3-Month Bulk Supply', 'Quarterly Delivery (Single Trip)', 'Priority "Emergency Fetch" Access', 'Maximum Price Savings'] },
  { name: 'Custom', icon: '🎨', mode: 'Both', price: { GH: 'Varies', NG: 'Varies', KE: 'Varies' }, features: ['Pick items individually', 'Quantity bulk selectors', 'Pay based on selection'] }
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

const dateSegments = reactive({ dd: '', mm: '', yyyy: '' })
const localPhone = ref('')

const isCustom = computed(() => selectedTier.value === 'Custom')
const marketName = computed(() => markets.find(m => m.code === form.country)?.name)
const currentCurrency = computed(() => markets.find(m => m.code === form.country)?.currency)
const currentPrefix = computed(() => markets.find(m => m.code === form.country)?.prefix)

const handlePhoneInput = (e) => {
  const input = e.target.value.replace(/\D/g, '')
  // Format with spaces for readability (e.g. 24 123 4567)
  let formatted = ''
  for (let i = 0; i < input.length; i++) {
    if (i === 2 || i === 5) formatted += ' '
    formatted += input[i]
  }
  localPhone.value = formatted.trim()
  form.whatsapp = currentPrefix.value + input
}

const nextOnMax = (e, max, nextId) => {
  if (e.target.value.length >= max) {
    document.getElementById(nextId)?.focus()
  }
}

watch(dateSegments, () => {
  if (dateSegments.dd && dateSegments.mm && dateSegments.yyyy) {
    form.lastDate = `${dateSegments.yyyy}-${dateSegments.mm.padStart(2, '0')}-${dateSegments.dd.padStart(2, '0')}`
  }
})
const filteredTiers = computed(() => tiers.filter(t => t.mode === form.cyclePreference || t.mode === 'Both'))
const currentTier = computed(() => tiers.find(t => t.name === selectedTier.value))
const tierPrice = computed(() => currentTier.value?.price[form.country] || '0')

const customTotal = computed(() => {
  return selectedItems.value.reduce((sum, item) => sum + (Number(item.price) * item.quantity), 0)
})

const fetchInventory = async () => {
    const { data } = await supabase.from('inventory').select('*').eq('country_code', form.country)
    inventoryItems.value = data || []
}

const updateQuantity = (item, delta) => {
    const index = selectedItems.value.findIndex(i => i.id === item.id)
    if (index > -1) {
        selectedItems.value[index].quantity += delta
        if (selectedItems.value[index].quantity <= 0) selectedItems.value.splice(index, 1)
    } else if (delta > 0) {
        selectedItems.value.push({ ...item, quantity: delta })
    }
}

const getItemQuantity = (id) => {
    const item = selectedItems.value.find(i => i.id === id)
    return item ? item.quantity : 0
}

const greeting = computed(() => {
  const hour = new Date().getHours()
  if (hour < 12) return 'Good Morning'
  if (hour < 17) return 'Good Afternoon'
  return 'Good Evening'
})

const standardPrice = computed(() => {
    // Basic math to show savings value
    const priceStr = currentTier.value?.price[form.country] || '0'
    const priceNum = Number(priceStr.replace(/[^0-9.-]+/g,""))
    if (form.cyclePreference === 'Quarterly') {
        const fullPrice = Math.round(priceNum / 0.8)
        return `${fullPrice}`
    }
    return null
})

const nextStep = () => { currentStep.value++ }
const prevStep = () => { currentStep.value-- }

const handleSubscribe = async () => {
  loading.value = true
  try {
    // 1. Calculate the next predicted period date
    const lastDate = new Date(form.lastDate)
    lastDate.setDate(lastDate.getDate() + Number(form.cycleLength))
    const nextDate = lastDate.toISOString().split('T')[0]

    // 2. Profiles Upsert (Lead Generation)
    await supabase.from('profiles').upsert({
      whatsapp_id: form.whatsapp,
      full_name: form.name,
      address: form.address,
      country_code: form.country
    }, { onConflict: 'whatsapp_id' })

    const { data: profileData } = await supabase.from('profiles').select('id').eq('whatsapp_id', form.whatsapp).single()
    
    if (profileData) {
        const subData = {
            user_id: profileData.id,
            box_tier: selectedTier.value,
            last_period_date: form.lastDate,
            cycle_length: Number(form.cycleLength),
            next_period_date: nextDate,
            status: 'Active',
            country_code: form.country,
            currency: currentCurrency.value,
            billing_cycle: form.cyclePreference,
            nudge_buffer_days: form.cyclePreference === 'Quarterly' ? 14 : 7,
            is_discreet: form.is_discreet
        }

        if (isCustom.value) {
            subData.custom_items_json = selectedItems.value.map(i => ({ 
                id: i.id, name: i.name, price: i.price, quantity: i.quantity 
            }))
        }

        const { error: subError } = await supabase.from('subscriptions').insert(subData)
        if (!subError) success.value = true
        else throw subError
    }
  } catch (e) { 
    console.error('Subscription Failed:', e)
    alert('Something went wrong. Please check your connection.')
  } 
  finally { loading.value = false }
}

watch(() => form.country, () => { fetchInventory(); selectedItems.value = [] })
onMounted(fetchInventory)
</script>

<style scoped>
/* Base Styles & Mobile-First Foundation */
.subscribe-page { 
  background: #fdfcff; 
  min-height: 100vh; 
  display: flex; 
  flex-direction: column; 
  color: var(--mera-text);
  -webkit-tap-highlight-color: transparent;
}

.simple-nav {
  padding: 16px 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  background: rgba(253, 252, 255, 0.95);
  backdrop-filter: blur(20px);
  z-index: 1000;
  border-bottom: 1px solid rgba(0,0,0,0.03);
}

.logo { font-size: 18px; font-weight: 900; text-decoration: none; color: #1a1a1a; letter-spacing: -0.5px; }
.dot { color: var(--mera-primary); }

@media (min-width: 360px) {
  .simple-nav { padding: 20px 24px; }
  .logo { font-size: 20px; }
}

.step-indicator { display: flex; align-items: center; gap: 6px; }
.step-dot { width: 24px; height: 24px; border-radius: 50%; background: #f0f0f0; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 800; color: #aaa; transition: all 0.4s; }
.step-dot.active { border-color: var(--mera-primary); color: var(--mera-primary); background: white; border: 2px solid var(--mera-primary); }
.step-dot.completed { background: var(--mera-primary); color: white; }
.step-line { width: 14px; height: 2px; background: #f0f0f0; border-radius: 2px; }
.step-line.active { background: var(--mera-primary); }

@media (min-width: 360px) {
  .step-indicator { gap: 8px; }
  .step-dot { width: 28px; height: 28px; font-size: 11px; }
  .step-line { width: 20px; }
}

.subscribe-nexus {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px 16px;
  display: grid;
  grid-template-columns: 1fr;
  gap: 32px;
}

@media (min-width: 1024px) {
  .subscribe-nexus {
    grid-template-columns: 1fr 340px;
    padding: 60px 48px;
    gap: 80px;
  }
}

.flow-content { display: flex; flex-direction: column; width: 100%; }

/* Typography & Headers */
.section-header { margin-bottom: 24px; text-align: left; }
h1 { font-size: 28px; font-weight: 900; margin-bottom: 8px; letter-spacing: -1px; line-height: 1.1; }
.text-muted { font-size: 14px; color: #777; line-height: 1.4; }

@media (min-width: 360px) {
  h1 { font-size: 32px; }
  .text-muted { font-size: 15px; }
}

@media (min-width: 1024px) {
  h1 { font-size: 48px; }
  .section-header { margin-bottom: 48px; }
}

/* Step 1: Market Grid */
.market-grid { 
  display: grid; 
  grid-template-columns: repeat(3, 1fr); 
  gap: 8px; 
  margin-bottom: 32px; 
}

.selector-card { 
  padding: 12px 8px; 
  border-radius: 16px; 
  cursor: pointer; 
  text-align: center; 
  position: relative; 
  transition: all 0.3s cubic-bezier(0.23, 1, 0.32, 1);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  border: 1px solid rgba(0,0,0,0.05);
  background: white;
}

.selector-card.active { border-color: var(--mera-primary); box-shadow: 0 4px 15px rgba(255, 77, 148, 0.08); }
.market-flag { font-size: 24px; }
.market-name h3 { font-size: 12px; font-weight: 800; margin-bottom: 0; line-height: 1.2; }
.market-name span { display: none; }

@media (min-width: 360px) {
  .market-grid { gap: 12px; }
  .selector-card { padding: 16px 12px; border-radius: 20px; gap: 8px; }
  .market-flag { font-size: 28px; }
  .market-name h3 { font-size: 14px; }
}

@media (min-width: 640px) {
  .market-name span { display: block; font-size: 10px; color: #aaa; font-weight: 700; text-transform: uppercase; }
  .selector-card { padding: 24px; gap: 12px; }
  .market-flag { font-size: 32px; }
  .market-grid { gap: 20px; }
}

/* Cycle Comparison & Pivot */
.cycle-comparison { padding: 24px; border-radius: 28px; margin-bottom: 24px; background: rgba(0,0,0,0.02); }
.comp-header { margin-bottom: 20px; }
.comp-header h3 { font-size: 19px; font-weight: 800; color: #1a1a1a; }
.comp-header p { font-size: 13px; color: #777; margin-top: 4px; }

.pivot-options { display: flex; flex-direction: column; gap: 12px; }
.pivot-selector { 
  padding: 20px; 
  border-radius: 20px; 
  border: 1px solid #eee; 
  background: white; 
  text-align: left; 
  cursor: pointer; 
  transition: all 0.3s; 
  position: relative; 
}
.pivot-selector.active { border-color: var(--mera-primary); background: rgba(255, 77, 148, 0.02); }
.pivot-title { font-size: 16px; font-weight: 800; display: block; margin-bottom: 4px; }
.pivot-meta p { font-size: 13px; color: #777; margin: 0; line-height: 1.4; }

.savings-badge { 
  position: absolute; 
  top: -10px; 
  right: 16px; 
  background: #1a1a1a; 
  color: #fff; 
  padding: 4px 12px; 
  border-radius: 40px; 
  font-size: 10px; 
  font-weight: 900; 
  letter-spacing: 0.5px;
}

/* Trust Strip */
.trust-strip {
  display: flex;
  justify-content: space-around;
  padding: 24px 0;
  margin-bottom: 24px;
  border-top: 1px solid #eee;
}
.trust-item { font-size: 11px; font-weight: 800; color: #aaa; text-transform: uppercase; display: flex; align-items: center; gap: 6px; }
.t-icon { font-size: 14px; }

/* Tier Selection */
.tier-stack { display: flex; flex-direction: column; gap: 12px; }
.tier-row { 
  padding: 20px; 
  border-radius: 24px; 
  display: flex; 
  justify-content: space-between; 
  align-items: center; 
  cursor: pointer; 
  transition: all 0.2s;
  border: 1px solid rgba(0,0,0,0.05);
}
.tier-row.active { border-color: var(--mera-primary); background: white; box-shadow: 0 10px 25px rgba(255, 77, 148, 0.05); }

.tier-price-nexus { text-align: right; }
.price-val { font-size: 20px; font-weight: 950; display: block; color: #1a1a1a; }
.price-freq { font-size: 10px; font-weight: 700; color: #aaa; text-transform: uppercase; }

/* Savings Visualization */
.total-nexus { position: relative; display: flex; flex-direction: column; }
.standard-price-cross { 
  font-size: 12px; 
  color: #bbb; 
  text-decoration: line-through; 
  font-weight: 600; 
  margin-top: -4px;
}

/* Info Tags */
.info-tag { font-size: 10px; background: #f0f0f0; padding: 2px 6px; border-radius: 10px; color: #888; cursor: help; margin-left: 6px; }

/* Success Roadmap */
.diamond-confetti { font-size: 24px; margin-bottom: 12px; animation: float 3s ease-in-out infinite; }
.roadmap { margin: 32px 0; display: flex; flex-direction: column; gap: 16px; text-align: left; }
.roadmap-item { display: flex; align-items: center; gap: 12px; opacity: 0.5; }
.roadmap-item.active { opacity: 1; }
.r-dot { width: 10px; height: 10px; border-radius: 50%; background: #eee; }
.roadmap-item.active .r-dot { background: var(--mera-primary); box-shadow: 0 0 10px var(--mera-primary); position: relative; }
.roadmap-item.active .r-dot::after { content: ''; position: absolute; inset: -4px; border: 2px solid var(--mera-primary); border-radius: 50%; animation: pulse 2s infinite; }
.roadmap-item p { font-size: 13px; font-weight: 700; color: #555; margin: 0; }

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

@keyframes pulse {
  0% { transform: scale(1); opacity: 1; }
  100% { transform: scale(1.5); opacity: 0; }
}

/* Builder */
.custom-builder-nexus { padding: 24px; border-radius: 28px; margin-top: 24px; }
.inventory-nexus-grid { 
  display: grid; 
  grid-template-columns: 1fr; 
  gap: 12px; 
  margin-top: 20px; 
}

@media (min-width: 640px) {
  .inventory-nexus-grid { grid-template-columns: 1fr 1fr; }
}

.item-pill { 
  padding: 18px 20px; 
  border-radius: 20px; 
  display: flex; 
  justify-content: space-between; 
  align-items: center; 
  border: 1px solid rgba(0,0,0,0.05); 
  background: white;
  transition: all 0.2s;
}
.item-pill.active { border-color: var(--mera-primary); box-shadow: 0 4px 20px rgba(255, 77, 148, 0.05); }

.item-info { display: flex; flex-direction: column; gap: 4px; }
.item-name { font-size: 14px; font-weight: 800; color: #1a1a1a; }
.item-price { font-size: 12px; font-weight: 600; color: #aaa; }

.item-controls {
  display: flex;
  align-items: center;
  gap: 12px;
  background: #f8f8f8;
  padding: 4px;
  border-radius: 40px;
  border: 1px solid #eee;
}

.item-controls button {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  border: none;
  background: white;
  color: #1a1a1a;
  font-weight: 900;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 5px rgba(0,0,0,0.05);
  transition: all 0.2s;
}

.item-controls button:hover { background: var(--mera-primary); color: white; }
.item-controls .count { font-size: 14px; font-weight: 900; min-width: 16px; text-align: center; }

.add-btn {
  padding: 8px 16px;
  border-radius: 40px;
  border: 1px solid #eee;
  background: white;
  color: #1a1a1a;
  font-weight: 800;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s;
}

.add-btn:hover { border-color: var(--mera-primary); color: var(--mera-primary); transform: translateY(-1px); }

.tier-details-nexus { padding: 20px; border-radius: 20px; margin-top: 20px; }
.feature-grid { list-style: none; padding: 0; display: grid; grid-template-columns: 1fr; gap: 10px; }

@media (min-width: 640px) {
  .feature-grid { grid-template-columns: 1fr 1fr; }
}

.feature-grid li { font-size: 13px; font-weight: 600; color: #555; }

/* Step 3: Final Form */
.final-form { padding: 24px; border-radius: 28px; }
.nexus-form { display: flex; flex-direction: column; gap: 24px; }
.nexus-row { display: grid; grid-template-columns: 1fr; gap: 20px; }

@media (min-width: 768px) {
  .nexus-row { grid-template-columns: 1fr 1fr; }
}

.nexus-group label { font-size: 12px; font-weight: 700; color: #999; margin-bottom: 6px; }
.glass-input { padding: 16px; border-radius: 16px; font-size: 16px; width: 100%; border: 1px solid #eee; background: rgba(255,255,255,0.5); }

.discreet-toggle { padding: 16px 20px; border-radius: 18px; display: flex; gap: 14px; align-items: flex-start; }
.discreet-toggle strong { font-size: 14px; font-weight: 800; display: block; }
.discreet-toggle span { font-size: 12px; color: #777; }

/* Segmented Inputs (Phone & Date) */
.phone-nexus { display: flex; align-items: center; gap: 8px; cursor: text; }
.p-prefix { font-weight: 800; color: #1a1a1a; font-size: 16px; border-right: 2px solid #eee; padding-right: 8px; }
.phone-input { border: none; background: transparent; font-size: 16px; font-weight: 700; color: #1a1a1a; width: 100%; outline: none; }

.date-nexus { display: flex; align-items: center; gap: 4px; }
.d-segment { width: 32px; border: none; background: transparent; font-size: 16px; font-weight: 700; text-align: center; outline: none; -moz-appearance: textfield; }
.d-segment::-webkit-inner-spin-button, .d-segment::-webkit-outer-spin-button { -webkit-appearance: none; }
.d-segment-large { width: 52px; border: none; background: transparent; font-size: 16px; font-weight: 700; text-align: center; outline: none; }
.d-sep { color: #ccc; font-weight: 700; }

/* Bottom Nav Bar (Mobile Actions) */
.flow-footer, .flow-footer-final { 
  display: none; 
  gap: 12px; 
  margin-top: 40px; 
  padding-bottom: 20px; 
}

@media (min-width: 1024px) {
  .flow-footer, .flow-footer-final { display: flex; }
}

.btn-next { flex: 2; padding: 18px; border-radius: 40px; border: none; background: var(--mera-primary); color: white; font-weight: 800; cursor: pointer; font-size: 15px; }
.btn-prev { flex: 1; padding: 18px; border-radius: 40px; border: 1px solid #eee; background: white; font-weight: 700; cursor: pointer; font-size: 14px; }

.btn-submit { width: 100%; padding: 20px; border-radius: 40px; border: none; background: #1a1a1a; color: white; font-weight: 800; font-size: 16px; }

/* Sticky Mobile Summary Bar */
.mobile-summary-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 2000;
  padding: 16px 20px;
  padding-bottom: calc(16px + env(safe-area-inset-bottom));
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(15px);
  border-top: 1px solid rgba(0,0,0,0.05);
  box-shadow: 0 -10px 30px rgba(0,0,0,0.05);
}

@media (min-width: 1024px) {
  .mobile-summary-bar { display: none; }
}

.m-summary-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 600px;
  margin: 0 auto;
  gap: 20px;
}

.m-summary-meta { display: flex; flex-direction: column; gap: 2px; }
.m-label { font-size: 11px; font-weight: 800; color: #aaa; text-transform: uppercase; letter-spacing: 0.5px; }
.m-total { display: flex; align-items: baseline; gap: 4px; }
.m-curr { font-size: 13px; font-weight: 700; color: #777; }
.m-val { font-size: 22px; font-weight: 950; color: var(--mera-primary); }

.m-btn-prev {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  border: 1px solid #eee;
  background: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  color: #777;
  cursor: pointer;
}

.m-btn-next {
  background: var(--mera-primary);
  color: white;
  border: none;
  padding: 14px 28px;
  border-radius: 40px;
  font-weight: 800;
  font-size: 15px;
  box-shadow: 0 8px 20px rgba(255, 77, 148, 0.2);
}

/* Sidebar (Desktop) */
.summary-sidebar { 
  display: none; 
  padding: 32px; 
  border-radius: 32px; 
  height: fit-content; 
  position: sticky; 
  top: 100px; 
  background: white;
  border: 1px solid rgba(0,0,0,0.05);
}

@media (min-width: 1024px) {
  .summary-sidebar { display: block; }
}

.summary-sidebar h3 { font-size: 17px; font-weight: 900; margin-bottom: 20px; border-bottom: 1px solid #eee; padding-bottom: 12px; }
.summary-item { display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 13px; font-weight: 700; }
.summary-item .label { color: #aaa; text-transform: uppercase; font-size: 10px; }

.summary-total { margin-top: 20px; padding-top: 20px; border-top: 1px dashed #eee; }
.total-val { font-size: 32px; font-weight: 900; color: var(--mera-primary); }

/* Success Overlay */
.success-overlay-nexus { position: fixed; inset: 0; background: white; z-index: 5000; display: flex; align-items: center; justify-content: center; padding: 20px; }
.success-card-nexus { width: 100%; max-width: 480px; padding: 40px 24px; text-align: center; border-radius: 32px; }
.celebration { font-size: 60px; margin-bottom: 24px; }
.btn-home { display: block; padding: 18px; border-radius: 40px; text-decoration: none; color: white; font-weight: 800; background: var(--mera-primary); margin-top: 24px; }

/* Animations */
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(15px); }
    to { opacity: 1; transform: translateY(0); }
}
.animate-fade-in { animation: fadeIn 0.4s ease-out forwards; }
</style>
```
