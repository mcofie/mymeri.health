<template>
  <NuxtLayout name="dashboard">
    <div class="inventory-page">
      <header class="page-header">
        <div class="header-left">
          <h1 class="premium-gradient">Global Stash Inventory</h1>
          <p class="text-muted">Managing stashes for <strong>{{ activeMarketName }}</strong> souls.</p>
        </div>
        <div class="header-right">
          <div class="search-wrap glass">
             <span class="search-icon">🔍</span>
             <input v-model="searchQuery" type="text" placeholder="Search stash items..." class="glass-input-clean" />
          </div>
          <button class="btn-add glass pink-glow" @click="openAddModal">
            <span>+ Add Stash Item</span>
          </button>
        </div>
      </header>

      <!-- Market Pulse Tabset -->
      <div class="market-pulse glass">
        <button 
          v-for="market in markets" 
          :key="market.code"
          class="market-pill-btn"
          :class="{ active: activeMarket === market.code }"
          @click="activeMarket = market.code"
        >
          <span class="flag-icon">{{ market.flag }}</span>
          <span class="market-name">{{ market.name }}</span>
          <span class="count-tag">{{ getMarketCount(market.code) }}</span>
        </button>
      </div>

      <div class="inventory-container">
        <div v-if="filteredInventory.length > 0" class="inventory-grid animate-fade-in">
          <div v-for="item in filteredInventory" :key="item.id" class="stash-card glass">
            <div class="card-glow"></div>
            
            <header class="card-header-premium">
              <span class="category-tag">{{ item.category }}</span>
              <button class="btn-delete glass" @click="deleteItem(item.id)">🗑️</button>
            </header>
            
            <div class="item-visual">
              <h3>{{ item.name }}</h3>
              <p class="description-text">{{ item.description }}</p>
            </div>

            <footer class="card-footer-premium">
              <div class="price-nexus">
                <span class="nexus-currency">{{ item.currency }}</span>
                <span class="nexus-amount">{{ item.price }}</span>
              </div>
              
              <div class="stock-nexus">
                <div class="nexus-header">
                  <span class="nexus-label">Current Stock</span>
                  <span class="nexus-value" :class="getStockClass(item.stock_level)">{{ item.stock_level }} units</span>
                </div>
                <div class="nexus-bar-bg">
                  <div 
                    class="nexus-bar-fill" 
                    :class="getStockClass(item.stock_level)"
                    :style="{ width: Math.min(100, (item.stock_level / 100) * 100) + '%' }"
                  ></div>
                </div>
                <div class="nexus-controls">
                  <button class="ctrl-btn glass" @click="updateStock(item.id, -10)">-10</button>
                  <button class="ctrl-btn glass" @click="updateStock(item.id, -1)">-1</button>
                  <button class="ctrl-btn glass" @click="updateStock(item.id, 1)">+1</button>
                  <button class="ctrl-btn glass" @click="updateStock(item.id, 10)">+10</button>
                </div>
              </div>
            </footer>
          </div>
        </div>

        <div v-else class="empty-inventory-nexus glass animate-fade-in">
          <div class="empty-nexus-visual">📦</div>
          <h3>Inventory Empty in {{ activeMarketName }}</h3>
          <p>No products have been added to the {{ activeMarketName }} stash yet. Add your first item to begin tracking stock.</p>
          <button class="btn-primary glass pink-glow" @click="openAddModal">Add Stash Anchor</button>
        </div>
      </div>

      <!-- Add Stash Modal Premium -->
      <Teleport to="body">
        <div v-if="showAddModal" class="modal-nexus-overlay" @click.self="showAddModal = false">
          <div class="modal-nexus-card glass animate-fade-in">
            <header class="modal-nexus-header">
               <div class="title-wrap">
                  <span class="market-hint">{{ activeMarketName }} Market</span>
                  <h2>New Stash Item</h2>
               </div>
               <button class="nexus-close" @click="showAddModal = false">✕</button>
            </header>

            <form @submit.prevent="addItem" class="nexus-item-form">
              <div class="nexus-field">
                <label>Item Name</label>
                <div class="nexus-input-wrap glass">
                   <input v-model="newItem.name" type="text" placeholder="e.g. Always Ultra Heavy" required autofocus />
                </div>
              </div>

              <div class="nexus-field">
                <label>Stash Description</label>
                <div class="nexus-input-wrap glass">
                   <textarea v-model="newItem.description" placeholder="Short description for packing slips..."></textarea>
                </div>
              </div>

              <div class="nexus-grid">
                <div class="nexus-field">
                  <label>Category</label>
                  <div class="nexus-input-wrap glass">
                    <select v-model="newItem.category" required>
                      <option value="Pads">Pads</option>
                      <option value="Choice">Choice</option>
                      <option value="Relief">Relief</option>
                    </select>
                  </div>
                </div>
                <div class="nexus-field">
                  <label>Unit Price ({{ activeCurrency }})</label>
                  <div class="nexus-input-wrap glass">
                    <input v-model="newItem.price" type="number" step="0.01" required />
                  </div>
                </div>
              </div>

              <div class="nexus-field">
                <label>Opening Stock Balance</label>
                <div class="nexus-input-wrap glass">
                   <input v-model="newItem.stock_level" type="number" required />
                </div>
              </div>

              <footer class="nexus-form-footer">
                <button type="button" class="btn-nexus-cancel" @click="showAddModal = false">Discard</button>
                <button type="submit" class="btn-nexus-save glass pink-glow" :disabled="loading">
                  {{ loading ? 'Securing...' : 'Secure in Stash' }}
                </button>
              </footer>
            </form>
          </div>
        </div>
      </Teleport>
    </div>
  </NuxtLayout>
</template>

<script setup>
const supabase = useSupabaseClient()
const inventory = ref([])
const showAddModal = ref(false)
const loading = ref(false)
const activeMarket = useState('activeMarket', () => 'GH')
const searchQuery = ref('')

const markets = [
  { code: 'GH', name: 'Ghana', flag: '🇬🇭', currency: 'GHS' },
  { code: 'NG', name: 'Nigeria', flag: '🇳🇬', currency: 'NGN' },
  { code: 'KE', name: 'Kenya', flag: '🇰🇪', currency: 'KES' }
]

const newItem = reactive({
  name: '',
  description: '',
  category: 'Pads',
  price: 0,
  stock_level: 0
})

const activeMarketName = computed(() => markets.find(m => m.code === activeMarket.value)?.name)
const activeCurrency = computed(() => markets.find(m => m.code === activeMarket.value)?.currency)

const filteredInventory = computed(() => {
  return inventory.value.filter(item => {
    const matchesMarket = item.country_code === activeMarket.value
    const matchesSearch = item.name.toLowerCase().includes(searchQuery.value.toLowerCase()) || 
                         item.category.toLowerCase().includes(searchQuery.value.toLowerCase())
    return matchesMarket && matchesSearch
  })
})

const getMarketCount = (code) => {
  return inventory.value.filter(item => item.country_code === code).length
}

const fetchInventory = async () => {
  const { data } = await supabase.from('inventory').select('*').order('name', { ascending: true })
  inventory.value = data || []
}

const openAddModal = () => {
  showAddModal.value = true
}

const addItem = async () => {
  loading.value = true
  const { error } = await supabase.from('inventory').insert({
    ...newItem,
    currency: activeCurrency.value,
    country_code: activeMarket.value
  })

  if (!error) {
    showAddModal.value = false
    Object.assign(newItem, { name: '', description: '', category: 'Pads', price: 0, stock_level: 0 })
    fetchInventory()
  } else {
    alert('Error adding item: ' + error.message)
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

const deleteItem = async (id) => {
  if (!confirm('Are you sure you want to remove this item?')) return
  const { error } = await supabase.from('inventory').delete().eq('id', id)
  if (!error) {
    inventory.value = inventory.value.filter(i => i.id !== id)
  }
}

const getStockClass = (level) => {
  if (level < 20) return 'low'
  if (level < 100) return 'medium'
  return 'high'
}

onMounted(fetchInventory)
</script>

<style scoped>
.inventory-page { display: flex; flex-direction: column; gap: 40px; }

.page-header { display: flex; justify-content: space-between; align-items: center; }
.header-left h1 { font-size: 32px; font-weight: 800; margin-bottom: 8px; }
.header-right { display: flex; gap: 16px; align-items: center; }

.search-wrap { display: flex; align-items: center; padding: 10px 20px; border-radius: 40px; gap: 12px; width: 320px; }
.search-icon { opacity: 0.5; }
.glass-input-clean { background: none; border: none; color: var(--mera-text); width: 100%; font-size: 14px; outline: none; }

.btn-add { padding: 12px 24px; border-radius: 14px; border: none; font-weight: 800; font-size: 14px; color: white; cursor: pointer; }

/* Market Pulse Tabs */
.market-pulse {
  display: flex;
  padding: 8px;
  border-radius: 28px;
  gap: 12px;
  width: fit-content;
  background: rgba(255, 255, 255, 0.4);
}

.market-pill-btn {
  padding: 12px 24px;
  border-radius: 20px;
  border: none;
  background: transparent;
  color: var(--mera-text-muted);
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 12px;
  font-weight: 700;
  transition: all 0.3s;
}

.market-pill-btn.active {
  background: white;
  color: var(--mera-text);
  box-shadow: 0 4px 20px rgba(0,0,0,0.06);
}

.count-tag {
  font-size: 10px;
  background: rgba(0,0,0,0.05);
  padding: 2px 8px;
  border-radius: 20px;
  opacity: 0.7;
}

.inventory-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
  gap: 32px;
}

.stash-card {
  padding: 32px;
  display: flex;
  flex-direction: column;
  gap: 28px;
  position: relative;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.stash-card:hover { transform: translateY(-8px); box-shadow: 0 20px 40px rgba(0,0,0,0.08); }

.card-header-premium { display: flex; justify-content: space-between; align-items: center; }
.category-tag {
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 1.5px;
  background: rgba(255, 77, 148, 0.05);
  color: var(--mera-primary);
  padding: 4px 12px;
  border-radius: 20px;
  font-weight: 800;
}

.btn-delete { width: 32px; height: 32px; padding: 0; border: none; cursor: pointer; opacity: 0.2; transition: opacity 0.2s; }
.stash-card:hover .btn-delete { opacity: 1; }

.item-visual h3 { font-size: 24px; font-weight: 800; margin-bottom: 12px; }
.description-text { font-size: 14px; color: var(--mera-text-muted); line-height: 1.6; min-height: 50px; }

.card-footer-premium { margin-top: auto; display: flex; flex-direction: column; gap: 24px; }
.price-nexus { display: flex; align-items: baseline; gap: 8px; }
.nexus-amount { font-size: 32px; font-weight: 900; }
.nexus-currency { font-size: 14px; font-weight: 700; opacity: 0.6; }

.stock-nexus { display: flex; flex-direction: column; gap: 12px; }
.nexus-header { display: flex; justify-content: space-between; font-size: 12px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px; }

.nexus-value.low { color: #ff3b30; }
.nexus-value.medium { color: #ff9f0a; }
.nexus-value.high { color: #34c759; }

.nexus-bar-bg { height: 8px; background: rgba(0,0,0,0.05); border-radius: 4px; overflow: hidden; }
.nexus-bar-fill { height: 100%; transition: width 0.6s cubic-bezier(0.19, 1, 0.22, 1); }
.nexus-bar-fill.low { background: #ff3b30; }
.nexus-bar-fill.medium { background: #ff9f0a; }
.nexus-bar-fill.high { background: #34c759; }

.nexus-controls { display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px; }
.ctrl-btn { padding: 8px; border-radius: 10px; border: none; font-size: 11px; font-weight: 800; cursor: pointer; transition: all 0.2s; }
.ctrl-btn:hover { background: var(--mera-primary); color: white; }

.empty-inventory-nexus { padding: 100px 40px; text-align: center; display: flex; flex-direction: column; align-items: center; gap: 20px; }
.empty-nexus-visual { font-size: 80px; }
.empty-inventory-nexus h3 { font-size: 28px; font-weight: 800; }

/* Modal Premium */
.modal-nexus-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(255,255,255,0.7);
  backdrop-filter: blur(20px);
  display: flex; align-items: center; justify-content: center;
  z-index: 2000;
}

.modal-nexus-card { width: 90%; max-width: 540px; padding: 48px; border-radius: 40px; }
.modal-nexus-header { display: flex; justify-content: space-between; margin-bottom: 40px; }
.market-hint { font-size: 11px; text-transform: uppercase; font-weight: 800; color: var(--mera-primary); letter-spacing: 1px; }
.modal-nexus-header h2 { font-size: 28px; font-weight: 900; margin-top: 4px; }
.nexus-close { background: none; border: none; font-size: 24px; cursor: pointer; opacity: 0.3; }

.nexus-item-form { display: flex; flex-direction: column; gap: 28px; }
.nexus-field { display: flex; flex-direction: column; gap: 10px; }
.nexus-field label { font-size: 13px; font-weight: 700; color: var(--mera-text-muted); }

.nexus-input-wrap { padding: 4px 18px; border-radius: 16px; display: flex; align-items: center; }
.nexus-input-wrap input, .nexus-input-wrap select, .nexus-input-wrap textarea {
  background: none; border: none; width: 100%; padding: 12px 0; color: var(--mera-text); font-size: 16px; outline: none;
}
.nexus-input-wrap textarea { height: 100px; resize: none; }

.nexus-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }

.nexus-form-footer { display: flex; justify-content: flex-end; gap: 20px; align-items: center; margin-top: 12px; }
.btn-nexus-save { padding: 14px 32px; border-radius: 14px; border: none; color: white; font-weight: 800; cursor: pointer; }
.btn-nexus-cancel { background: none; border: none; font-weight: 700; color: var(--mera-text-muted); cursor: pointer; }
</style>
