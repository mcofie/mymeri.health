<template>
  <div class="login-container">
    <div class="login-card glass">
      <h1 class="premium-gradient">MyMeri Admin</h1>
      <p>Enter your credentials to access the dashboard.</p>
      
      <form @submit.prevent="handleLogin" class="login-form">
        <div class="input-group">
          <label>Email</label>
          <input v-model="email" type="email" placeholder="admin@mymeri.health" required />
        </div>
        <div class="input-group">
          <label>Password</label>
          <input v-model="password" type="password" placeholder="••••••••" required />
        </div>
        
        <button type="submit" :disabled="loading" class="btn-primary glass">
          {{ loading ? 'Authenticating...' : 'Sign In' }}
        </button>
      </form>
      
      <p v-if="error" class="error-msg">{{ error }}</p>
    </div>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  loading.value = true
  error.value = ''
  
  const { error: authError } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value
  })
  
  if (authError) {
    error.value = authError.message
    loading.value = false
  } else {
    navigateTo('/admin')
  }
}
</script>

<style scoped>
.login-container {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 24px;
}

.login-card {
  width: 100%;
  max-width: 400px;
  padding: 48px;
  display: flex;
  flex-direction: column;
  gap: 24px;
  text-align: center;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
  text-align: left;
}

.input-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

label {
  font-size: 13px;
  color: var(--mera-text-muted);
}

input {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid var(--mera-border);
  border-radius: 12px;
  padding: 12px 16px;
  color: var(--mera-text);
  font-size: 15px;
}

.btn-primary {
  margin-top: 12px;
  padding: 14px;
  border-radius: 12px;
  cursor: pointer;
}

.error-msg {
  color: #ff3b30;
  font-size: 13px;
}
</style>
