<template>
  <div class="dashboard-layout">
    <aside class="sidebar glass">
      <div class="logo">
        <h1 class="premium-gradient">MyMeri</h1>
      </div>
      <nav>
        <NuxtLink to="/admin" class="nav-item" active-class="active">Overview</NuxtLink>
        <NuxtLink to="/subscriptions" class="nav-item" active-class="active">Subscriptions</NuxtLink>
        <NuxtLink to="/orders" class="nav-item" active-class="active">Orders</NuxtLink>
        <NuxtLink to="/inventory" class="nav-item" active-class="active">Inventory</NuxtLink>
        <NuxtLink to="/fulfillment" class="nav-item" active-class="active">Fulfillment</NuxtLink>
        <NuxtLink to="/messages" class="nav-item" active-class="active">Messages</NuxtLink>
      </nav>
      <div class="sidebar-footer">
        <div class="user-profile glass" @click="handleLogout">
          <div class="avatar-sm"></div>
          <div class="user-meta">
            <span class="username">Admin</span>
            <span class="logout-label">Sign Out</span>
          </div>
        </div>
      </div>
    </aside>
    <main class="content">
      <header class="top-bar">
        <div class="search-bar glass">Search for subscribers...</div>
        <div class="actions">
          <div class="country-pill glass">Ghana 🇬🇭</div>
          <div class="notification-icon glass">🔔</div>
        </div>
      </header>
      <slot />
    </main>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()

const handleLogout = async () => {
  await supabase.auth.signOut()
  navigateTo('/login')
}
</script>

<style scoped>
.dashboard-layout {
  display: flex;
  min-height: 100vh;
  padding: 24px;
  gap: 24px;
}

.sidebar {
  width: 280px;
  display: flex;
  flex-direction: column;
  padding: 32px 24px;
  position: sticky;
  top: 24px;
  height: calc(100vh - 48px);
}

.logo h1 {
  font-size: 28px;
  margin-bottom: 48px;
}

nav {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.nav-item {
  padding: 12px 16px;
  border-radius: 12px;
  color: var(--mera-text-muted);
  cursor: pointer;
  transition: all 0.2s;
}

.nav-item.active, .nav-item:hover {
  background: rgba(255, 255, 255, 0.05);
  color: var(--mera-text);
}

.content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.top-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-bar {
  width: 400px;
  padding: 12px 20px;
  color: var(--mera-text-muted);
  font-size: 14px;
}

.actions {
  display: flex;
  gap: 12px;
}

.country-pill, .notification-icon {
  padding: 10px 18px;
  display: flex;
  align-items: center;
  gap: 8px;
}

/* User Profile Styles */
.user-profile {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;
}

.user-profile:hover {
  background: rgba(255, 59, 48, 0.1);
  border-color: rgba(255, 59, 48, 0.2);
}

.avatar-sm {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--mera-primary), var(--mera-accent));
}

.user-meta {
  display: flex;
  flex-direction: column;
}

.username {
  font-size: 14px;
  font-weight: 500;
}

.logout-label {
  font-size: 11px;
  color: var(--mera-text-muted);
}

.user-profile:hover .logout-label {
  color: #ff3b30;
}
</style>
