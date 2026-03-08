<template>
  <div class="subscribe-page">
    <nav class="simple-nav">
      <NuxtLink to="/" class="logo">MyMeri<span class="dot">.</span></NuxtLink>
    </nav>

    <div class="subscribe-container">
      <header class="page-header">
        <span class="step-label">Step 1 of 2</span>
        <h1 class="premium-gradient">Tailor Your Box</h1>
        <p class="text-muted">Select the curated experience that fits your cycle best.</p>
      </header>

      <!-- Tier Selection Section -->
      <section class="tiers-selection">
        <div class="tier-grid">
          <div 
            v-for="tier in tiers" 
            :key="tier.name" 
            class="tier-pill glass" 
            :class="{ active: selectedTier === tier.name }"
            @click="selectedTier = tier.name"
          >
            <div class="tier-icon">{{ tier.icon }}</div>
            <div class="tier-info">
              <h3>{{ tier.name }}</h3>
              <p>{{ tier.price[form.country] }} / Mo</p>
            </div>
            <div class="check-circle" v-if="selectedTier === tier.name">✓</div>
          </div>
        </div>

        <div class="selected-tier-details glass" v-if="currentTier">
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

            <button type="submit" class="btn-submit pink-glow" :disabled="loading">
              <span v-if="loading">Finalizing...</span>
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

const tiers = [
  { name: 'Essential', icon: '🌸', price: { GH: 'GHS 120', NG: 'NGN 2500', KE: 'KES 850' }, features: ['Premium Eco-Pads (12ct)', 'WhatsApp Cycle Tracking', 'Standard Packaging'] },
  { name: 'Comfort', icon: '✨', price: { GH: 'GHS 200', NG: 'NGN 4500', KE: 'KES 1500' }, features: ['Essential + Night Pads', 'Cramp Relief Tea', 'Artisanal Dark Chocolate', 'Priority Packaging'] },
  { name: 'Eco Premium', icon: '🌿', price: { GH: 'GHS 350', NG: 'NGN 8000', KE: 'KES 2800' }, features: ['Everything in Comfort', 'Organic Cotton Liners', 'Lavender Heat Patches', 'Reusable Period Underwear'] }
]

const form = reactive({
  country: 'GH',
  whatsapp: '',
  name: '',
  address: '',
  lastDate: '',
  cycleLength: 28,
  is_discreet: false
})

const currentTier = computed(() => tiers.find(t => t.name === selectedTier.value))

const handleSubscribe = async () => {
  loading.value = true
  
  try {
    // 1. In a headless environment, we'd use a service role to create the profile
    // For this flow, we'll try to insert a profile (assuming RLS allows or handled via a function)
    const profileId = crypto.randomUUID()
    
    const { error: profileError } = await supabase.from('profiles').upsert({
      whatsapp_id: form.whatsapp,
      full_name: form.name,
      address: form.address,
      country_code: form.country
    }, { onConflict: 'whatsapp_id' }).select()

    // 2. We'd fetch the id from the inserted profile. For now, we simulate.
    const { data: profileData } = await supabase.from('profiles').select('id').eq('whatsapp_id', form.whatsapp).single()
    
    if (profileData) {
        const { error: subError } = await supabase.from('subscriptions').insert({
            user_id: profileData.id,
            box_tier: selectedTier.value,
            last_period_date: form.lastDate,
            cycle_length: form.cycleLength,
            status: 'Active'
        })
        
        if (!subError) success.value = true
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
  .input-row, .feature-list {
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
</style>
