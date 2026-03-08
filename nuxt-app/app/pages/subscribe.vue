<template>
  <div class="subscribe-container">
    <div class="header">
      <h1 class="premium-gradient">Choose Your Cycle Box</h1>
      <p>Seamless menstrual health, delivered discreetly to your door.</p>
    </div>

    <div class="tiers-grid">
      <div v-for="tier in tiers" :key="tier.name" class="tier-card glass hover-scale" :class="{ selected: selectedTier === tier.name }" @click="selectedTier = tier.name">
        <div class="badge">{{ tier.price }} / mo</div>
        <h2>{{ tier.name }}</h2>
        <p>{{ tier.description }}</p>
        <ul class="features">
          <li v-for="f in tier.features" :key="f">{{ f }}</li>
        </ul>
      </div>
    </div>

    <div class="form-section glass">
      <h3>Your Details</h3>
      <form @submit.prevent="handleSubscribe" class="subscribe-form">
        <div class="grid-2">
          <div class="input-group">
            <label>WhatsApp Number</label>
            <input v-model="form.whatsapp" type="tel" placeholder="233 50 000 0000" required />
          </div>
          <div class="input-group">
            <label>Full Name</label>
            <input v-model="form.name" type="text" placeholder="Ama Mensah" required />
          </div>
        </div>

        <div class="grid-2">
          <div class="input-group">
            <label>Last Period Date</label>
            <input v-model="form.lastDate" type="date" required />
          </div>
          <div class="input-group">
            <label>Typical Cycle Length (Days)</label>
            <input v-model="form.cycleLength" type="number" min="20" max="45" required />
          </div>
        </div>

        <div class="input-group">
          <label>Delivery Address</label>
          <textarea v-model="form.address" placeholder="Accra, East Legon..." required></textarea>
        </div>

        <button type="submit" :disabled="loading" class="btn-primary glass">
          {{ loading ? 'Saving...' : 'Start My Subscription' }}
        </button>
      </form>
      <p v-if="success" class="success-msg">Welcome to MyMeri! We'll reach out on WhatsApp soon.</p>
    </div>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const loading = ref(false)
const success = ref(false)
const selectedTier = ref('Essential')

const tiers = [
  { name: 'Essential', price: 'GHS 100', description: 'Just the basics.', features: ['Premium Pads (12)', 'Pain Relief Tips', 'Basic Cycle Tracking'] },
  { name: 'Comfort', price: 'GHS 200', description: 'Most popular.', features: ['Premium Pads (20)', 'Meds for Cramps', 'Luxury Tea & Treats', 'Discreet Box'] },
  { name: 'Eco', price: 'GHS 150', description: 'Sustainable choice.', features: ['Biodegradable Pads', 'Natural Treats', 'Earth-friendly Box'] }
]

const form = reactive({
  whatsapp: '',
  name: '',
  address: '',
  lastDate: '',
  cycleLength: 28
})

const handleSubscribe = async () => {
  loading.value = true
  
  // 1. Create Profile (Hack for anonymous signup or handled via service role later)
  // In a real app, this would be a Supabase RPC or handled via the Edge Function
  // For the demo, we assume the user exists or we insert into a 'waitlist' style logic
  
  // Let's assume we insert into our schema directly for now (requires proper RLS or service role)
  // Note: For public insertion, we need the DB to allow anon inserts on specific tables
  
  const { error } = await supabase.from('profiles').insert({
    id: '00000000-0000-0000-0000-000000000000', // Dummy or actual auth id
    whatsapp_id: form.whatsapp,
    full_name: form.name,
    address: form.address,
    country_code: 'GH'
  })

  // Then create subscription...
  
  loading.value = false
  success.value = true
}
</script>

<style scoped>
.subscribe-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 80px 24px;
  display: flex;
  flex-direction: column;
  gap: 64px;
}

.header { text-align: center; }
.header h1 { font-size: 48px; margin-bottom: 16px; }
.header p { color: var(--mera-text-muted); font-size: 18px; }

.tiers-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.tier-card {
  padding: 32px;
  cursor: pointer;
  position: relative;
  border: 1px solid var(--mera-border);
}

.tier-card.selected {
  border-color: var(--mera-primary);
  background: rgba(255, 77, 148, 0.05);
}

.badge {
  position: absolute;
  top: 24px;
  right: 24px;
  font-size: 12px;
  background: var(--mera-primary);
  padding: 4px 12px;
  border-radius: 20px;
}

.features {
  margin-top: 24px;
  list-style: none;
  font-size: 14px;
  color: var(--mera-text-muted);
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.features li::before { content: "✓ "; color: var(--mera-primary); }

.form-section {
  max-width: 700px;
  margin: 0 auto;
  width: 100%;
  padding: 48px;
}

.subscribe-form {
  margin-top: 32px;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

.input-group { display: flex; flex-direction: column; gap: 8px; }
label { font-size: 13px; color: var(--mera-text-muted); }

input, textarea {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid var(--mera-border);
  border-radius: 12px;
  padding: 12px 16px;
  color: var(--mera-text);
}

textarea { height: 100px; }

.btn-primary { padding: 16px; border-radius: 12px; font-weight: 600; cursor: pointer; }

.success-msg { color: #34c759; text-align: center; margin-top: 16px; font-weight: 600; }
</style>
