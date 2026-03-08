<template>
  <div class="dashboard-layout animate-fade-in">
    <!-- Sidebar -->
    <aside class="sidebar glass">
      <div class="logo-area">
        <div class="logo-mark">M</div>
        <h1 class="premium-gradient">MyMeri</h1>
      </div>

      <nav class="nav-links">
        <NuxtLink to="/admin" class="nav-link" active-class="active">
          <span class="nav-icon">📊</span>
          <span class="nav-text">Overview</span>
        </NuxtLink>
        <NuxtLink to="/subscriptions" class="nav-link" active-class="active">
          <span class="nav-icon">💎</span>
          <span class="nav-text">Subscribers</span>
        </NuxtLink>
        <NuxtLink to="/orders" class="nav-link" active-class="active">
          <span class="nav-icon">📦</span>
          <span class="nav-text">Cycle Orders</span>
        </NuxtLink>
        <NuxtLink to="/inventory" class="nav-link" active-class="active">
          <span class="nav-icon">🏢</span>
          <span class="nav-text">Inventory</span>
        </NuxtLink>
        <NuxtLink to="/fulfillment" class="nav-link" active-class="active">
          <span class="nav-icon">🛡️</span>
          <span class="nav-text">Fulfillment</span>
        </NuxtLink>
        <NuxtLink to="/messages" class="nav-link" active-class="active">
          <span class="nav-icon">💬</span>
          <span class="nav-text">Messages</span>
        </NuxtLink>
      </nav>

      <div class="sidebar-footer">
        <div class="user-pill glass" @click="handleLogout">
          <div class="avatar-box">{{ userInitials }}</div>
          <div class="user-info">
            <span class="name">{{ userName }}</span>
            <span class="logout-hint">Click to logout</span>
          </div>
          <span class="exit-icon">↩️</span>
        </div>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="main-wrapper">
      <header class="dashboard-header">
        <div class="search-field glass nexus-focus">
          <span class="search-icon">🔍</span>
          <input 
            ref="searchInput"
            v-model="globalSearch" 
            type="text" 
            placeholder="Quick search... (⌘K)" 
            @keyup.enter="handleGlobalSearch"
          />
          <div v-if="globalSearch" class="search-clear" @click="globalSearch = ''">✕</div>
        </div>

        <div class="header-tools">
          <div class="market-selector glass">
            <span class="selector-icon">🌏</span>
            <select v-model="activeMarket" class="nexus-select">
              <option value="GH">Ghana 🇬🇭</option>
              <option value="NG">Nigeria 🇳🇬</option>
              <option value="KE">Kenya 🇰🇪</option>
            </select>
          </div>
          
          <button class="notification-btn glass nexus-pulse" @click="toggleNotifications">
            <span class="bell-icon">🔔</span>
            <span class="dot-alert"></span>
          </button>
        </div>
      </header>

      <!-- Global Search Results Overlay (Simple) -->
      <div v-if="showSearchOverlay" class="search-overlay glass" @click.self="showSearchOverlay = false">
         <div class="search-results-box animate-scale-up">
            <div class="results-header">
               <span>Search results for: "{{ globalSearch }}"</span>
               <button @click="showSearchOverlay = false">Esc</button>
            </div>
            <div class="results-list">
               <p class="text-muted">Searching across Souls, Orders, and Stashes...</p>
               <!-- This would eventually map real results -->
               <div class="empty-results">No instant results. Press Enter for deep search.</div>
            </div>
         </div>
      </div>

      <div class="content-view">
        <slot />
      </div>
    </main>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const globalSearch = ref('')
const activeMarket = useState('activeMarket', () => 'GH')
const showSearchOverlay = ref(false)
const searchInput = ref(null)

const userName = computed(() => {
  return user.value?.user_metadata?.full_name || user.value?.email || 'Administrator'
})

const userInitials = computed(() => {
  if (user.value?.user_metadata?.full_name) {
    return user.value.user_metadata.full_name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
  }
  return user.value?.email?.slice(0, 1).toUpperCase() || 'AD'
})

const handleLogout = async () => {
  if (confirm('Are you sure you want to sign out of the dashboard?')) {
    await supabase.auth.signOut()
    navigateTo('/login')
  }
}

const handleGlobalSearch = () => {
  if (globalSearch.value.trim()) {
    showSearchOverlay.value = true
  }
}

const toggleNotifications = () => {
  alert('Connected to Pusher: Monitoring live stashes...')
}

// Global Keyboard Shortcuts
onMounted(() => {
  window.addEventListener('keydown', (e) => {
    if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
      e.preventDefault()
      searchInput.value?.focus()
    }
  })
})
</script>

<style scoped>
.dashboard-layout {
  display: flex;
  min-height: 100vh;
  padding: 24px;
  background-color: #fcfaff;
  gap: 24px;
}

/* Sidebar Styling */
.sidebar {
  width: 300px;
  display: flex;
  flex-direction: column;
  padding: 48px 32px;
  position: sticky;
  top: 24px;
  height: calc(100vh - 48px);
  border-radius: 40px;
  border: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 20px 50px rgba(0,0,0,0.05);
}

.logo-area {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 72px;
  padding-left: 8px;
}

.logo-mark {
  width: 40px;
  height: 40px;
  background: var(--mera-primary);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 14px;
  font-weight: 800;
  font-size: 20px;
  box-shadow: 0 4px 15px rgba(255, 77, 148, 0.3);
}

.logo-area h1 {
  font-size: 28px;
  font-weight: 900;
  letter-spacing: -1.5px;
  color: #1a1a1a;
}

.nav-links {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 24px;
  border-radius: 20px;
  color: #666;
  text-decoration: none;
  font-weight: 700;
  font-size: 15px;
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.nav-link:hover {
  background: rgba(255, 255, 255, 0.6);
  color: var(--mera-primary);
  transform: translateX(6px);
}

.nav-link.active {
  background: white;
  color: var(--mera-primary);
  box-shadow: 0 4px 25px rgba(255, 77, 148, 0.1);
  border: 1px solid rgba(255, 77, 148, 0.1);
}

.nav-icon {
  font-size: 20px;
  filter: grayscale(1);
  transition: all 0.3s;
}

.nav-link.active .nav-icon {
  filter: grayscale(0);
}

/* Sidebar Footer */
.sidebar-footer {
  margin-top: auto;
}

.user-pill {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 14px;
  border-radius: 24px;
  cursor: pointer;
  transition: all 0.3s;
  background: white;
}

.user-pill:hover {
  background: rgba(255, 59, 48, 0.05);
  box-shadow: 0 4px 15px rgba(255, 59, 48, 0.1);
}

.avatar-box {
  width: 44px;
  height: 44px;
  background: #f8f8f8;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  font-weight: 800;
  color: var(--mera-primary);
}

.user-info { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
.name { font-size: 14px; font-weight: 800; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.logout-hint { font-size: 11px; color: #999; }
.exit-icon { font-size: 16px; opacity: 0.2; transition: all 0.3s; }

.user-pill:hover .exit-icon { opacity: 1; transform: translateX(4px); }
.user-pill:hover .name { color: #ff3b30; }

/* Main Wrapper Styling */
.main-wrapper {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 40px;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-field {
  width: 480px;
  padding: 14px 28px;
  display: flex;
  align-items: center;
  gap: 16px;
  border-radius: 50px;
  transition: all 0.3s;
}

.search-field:focus-within {
  background: white;
  box-shadow: 0 10px 30px rgba(0,0,0,0.05);
  width: 520px;
}

.search-field input {
  background: none;
  border: none;
  width: 100%;
  font-size: 15px;
  color: #1a1a1a;
  outline: none;
  font-weight: 600;
}

.search-field ::placeholder { color: #aaa; }

.search-clear { cursor: pointer; opacity: 0.3; }

.header-tools {
  display: flex;
  gap: 20px;
}

.market-selector {
  display: flex;
  align-items: center;
  padding: 10px 20px;
  border-radius: 40px;
  gap: 10px;
  background: white;
}

.nexus-select {
  background: none;
  border: none;
  font-size: 14px;
  font-weight: 800;
  color: #1a1a1a;
  outline: none;
  cursor: pointer;
}

.notification-btn {
  width: 52px;
  height: 52px;
  border-radius: 18px;
  border: none;
  cursor: pointer;
  position: relative;
  font-size: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: white;
  transition: all 0.3s;
}

.notification-btn:hover { transform: rotate(15deg); }

.nexus-pulse::after {
  content: '';
  position: absolute;
  top: 14px;
  right: 14px;
  width: 10px;
  height: 10px;
  background: var(--mera-primary);
  border-radius: 50%;
  border: 2px solid white;
  animation: pulse-ring 1.5s infinite;
}

@keyframes pulse-ring {
  0% { transform: scale(0.8); box-shadow: 0 0 0 0 rgba(255, 77, 148, 0.7); }
  70% { transform: scale(1); box-shadow: 0 0 0 10px rgba(255, 77, 148, 0); }
  100% { transform: scale(0.8); }
}

.content-view { flex: 1; }

.search-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  z-index: 3000;
  background: rgba(255,255,255,0.7);
  backdrop-filter: blur(20px);
  display: flex;
  align-items: center;
  justify-content: center;
}

.search-results-box {
  width: 90%;
  max-width: 600px;
  background: white;
  border-radius: 32px;
  padding: 40px;
  box-shadow: 0 30px 60px rgba(0,0,0,0.1);
}

.results-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; font-weight: 800; }
.results-header button { background: #f0f0f0; border: none; padding: 4px 12px; border-radius: 8px; font-size: 12px; font-weight: 800; }

.animate-scale-up {
  animation: scaleUp 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
}

@keyframes scaleUp {
  from { opacity: 0; transform: scale(0.9); }
  to { opacity: 1; transform: scale(1); }
}

/* Animations */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fade-in {
  animation: fadeIn 0.8s ease forwards;
}

@media (max-width: 1150px) {
  .sidebar { width: 100px; padding: 40px 16px; }
  .logo-area h1, .nav-text, .user-info, .exit-icon, .search-field { display: none; }
  .nav-icon { font-size: 26px; }
  .logo-area { justify-content: center; padding-left: 0; }
}
</style>
