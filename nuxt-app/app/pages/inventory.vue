<template>
  <NuxtLayout name="dashboard">
    <div class="inventory-page">
      <header class="page-header">
        <div>
          <h1>Inventory Management</h1>
          <p class="text-muted">Manage stock levels for Ghanian operations.</p>
        </div>
        <button class="btn-primary glass" @click="showAddModal = true">+ Add Item</button>
      </header>

      <div class="inventory-grid">
        <div v-for="item in inventory" :key="item.id" class="inventory-card glass hover-scale">
          <div class="card-header">
            <span class="category-pill">{{ item.category }}</span>
            <div class="stock-status" :class="getStockClass(item.stock_level)"></div>
          </div>
          <h3>{{ item.name }}</h3>
          <p class="desc">{{ item.description }}</p>
          <div class="pricing">
            <span class="currency">{{ item.currency }}</span>
            <span class="amount">{{ item.price }}</span>
          </div>
          <div class="stock-controls">
            <span class="stock-label">Stock Level: <strong>{{ item.stock_level }}</strong></span>
            <div class="btns">
              <button @click="updateStock(item.id, -1)">-</button>
              <button @click="updateStock(item.id, 1)">+</button>
            </div>
          </div>
        </div>
      </div>

      <!-- Add Modal -->
      <div v-if="showAddModal" class="modal-overlay" @click.self="showAddModal = false">
        <div class="modal glass">
          <h2>Add New Inventory Item</h2>
          <form @submit.prevent="addItem" class="edit-form">
            <div class="input-group">
              <label>Item Name</label>
              <input v-model="newItem.name" type="text" placeholder="e.g., Lavender Heat Pack" class="glass-input" required />
            </div>
            <div class="input-group">
              <label>Description</label>
              <textarea v-model="newItem.description" placeholder="A short description..." class="glass-input" required></textarea>
            </div>
            <div class="grid-2">
              <div class="input-group">
                <label>Category</label>
                <select v-model="newItem.category" class="glass-input" required>
                  <option value="Pads">Pads</option>
                  <option value="Meds">Meds</option>
                  <option value="Treats">Treats</option>
                </select>
              </div>
              <div class="input-group">
                <label>Price</label>
                <input v-model="newItem.price" type="number" step="0.01" class="glass-input" required />
              </div>
            </div>
            <div class="grid-2">
              <div class="input-group">
                <label>Currency</label>
                <select v-model="newItem.currency" class="glass-input" required>
                  <option value="GHS">GHS (Ghana)</option>
                  <option value="NGN">NGN (Nigeria)</option>
                  <option value="KES">KES (Kenya)</option>
                </select>
              </div>
              <div class="input-group">
                <label>Initial Stock</label>
                <input v-model="newItem.stock_level" type="number" class="glass-input" required />
              </div>
            </div>
            <div class="modal-actions">
              <button type="button" class="btn-sm" @click="showAddModal = false">Cancel</button>
              <button type="submit" class="btn-primary glass" :disabled="loading">
                {{ loading ? 'Saving...' : 'Add Item' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </NuxtLayout>
</template>

<script setup>
const supabase = useSupabaseClient()
const inventory = ref([])
const showAddModal = ref(false)
const loading = ref(false)

const newItem = reactive({
  name: '',
  description: '',
  category: 'Pads',
  price: 0,
  currency: 'GHS',
  stock_level: 0
})

const fetchInventory = async () => {
  const { data } = await supabase.from('inventory').select('*').order('created_at', { ascending: false })
  inventory.value = data || []
}

const addItem = async () => {
  loading.value = true
  const countryMap = { 'GHS': 'GH', 'NGN': 'NG', 'KES': 'KE' }
  
  const { error } = await supabase.from('inventory').insert({
    ...newItem,
    country_code: countryMap[newItem.currency] || 'GH'
  })

  if (!error) {
    showAddModal.value = false
    Object.assign(newItem, { name: '', description: '', category: 'Pads', price: 0, stock_level: 0 })
    fetchInventory()
  }
  loading.value = false
}

const updateStock = async (id, delta) => {
  const item = inventory.value.find(i => i.id === id)
  if (item) {
    const newStock = Math.max(0, item.stock_level + delta)
    const { error } = await supabase
      .from('inventory')
      .update({ stock_level: newStock })
      .eq('id', id)
    
    if (!error) item.stock_level = newStock
  }
}

const getStockClass = (level) => {
  if (level < 10) return 'low'
  if (level < 50) return 'medium'
  return 'high'
}

onMounted(fetchInventory)
</script>

<style scoped>
.inventory-page { display: flex; flex-direction: column; gap: 32px; }

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.btn-primary { padding: 10px 24px; border-radius: 12px; cursor: pointer; }

.inventory-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
}

.inventory-card {
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.category-pill {
  font-size: 11px;
  background: rgba(255, 255, 255, 0.05);
  padding: 4px 10px;
  border-radius: 20px;
  color: var(--mera-text-muted);
}

.stock-status { width: 8px; height: 8px; border-radius: 50%; }
.stock-status.low { background: #ff3b30; box-shadow: 0 0 10px #ff3b30; }
.stock-status.medium { background: #ff9f0a; box-shadow: 0 0 10px #ff9f0a; }
.stock-status.high { background: #34c759; box-shadow: 0 0 10px #34c759; }

.desc { font-size: 13px; color: var(--mera-text-muted); min-height: 40px; }

.pricing .amount { font-size: 20px; font-weight: 600; margin-left: 4px; }
.pricing .currency { font-size: 12px; color: var(--mera-text-muted); }

.stock-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top: 1px solid var(--mera-border);
  padding-top: 16px;
}

.stock-label { font-size: 13px; }
.btns { display: flex; gap: 8px; }

.btns button {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  border: 1px solid var(--mera-border);
  background: none;
  color: var(--mera-text);
  cursor: pointer;
  transition: all 0.2s;
}

.btns button:hover { background: rgba(255, 255, 255, 0.05); }

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.6);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  width: 100%;
  max-width: 500px;
  padding: 40px;
  border-radius: 24px;
}

.edit-form {
  margin-top: 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.input-group { display: flex; flex-direction: column; gap: 8px; }
label { font-size: 12px; color: var(--mera-text-muted); }

.glass-input {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid var(--mera-border);
  border-radius: 12px;
  padding: 12px;
  color: var(--mera-text);
  width: 100%;
}

textarea.glass-input { height: 80px; resize: none; }

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  margin-top: 24px;
}

.btn-sm { background: none; border: 1px solid var(--mera-border); color: var(--mera-text); padding: 10px 20px; border-radius: 12px; cursor: pointer; }
</style>
