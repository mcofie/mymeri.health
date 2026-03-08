<template>
  <div class="login-container">
    <div class="login-card glass animate-fade-in">
      <div class="login-header">
        <h1 class="premium-gradient">MyMeri Admin</h1>
        <p class="text-muted">{{ mode === 'login' ? 'Enter your credentials to access the dashboard.' : 'Enter your email and password to create an admin account.' }}</p>
      </div>
      
      <!-- Login/Signup Tabs -->
      <div class="auth-tabs glass">
        <button 
          class="tab-btn" 
          :class="{ active: mode === 'login' }"
          @click="mode = 'login'"
        >Log In</button>
        <button 
          class="tab-btn" 
          :class="{ active: mode === 'signup' }"
          @click="mode = 'signup'"
        >Register</button>
      </div>
      
      <form @submit.prevent="handleAuth" class="login-form">
        <div class="input-group">
          <label>Email Address</label>
          <input v-model="email" type="email" placeholder="admin@mymeri.health" autofocus required />
        </div>
        <div class="input-group">
          <div class="label-row">
             <label>Password</label>
             <span class="forgot-link" v-if="mode === 'login'">Forgot?</span>
          </div>
          <input v-model="password" type="password" placeholder="••••••••" required />
        </div>
        
        <button type="submit" :disabled="loading" class="btn-primary-sm btn-full pink-glow h-large">
          <span v-if="loading">Processing...</span>
          <span v-else>{{ mode === 'login' ? 'Continue with Dashboard' : 'Create My Account' }}</span>
        </button>
      </form>
      
      <p v-if="error" class="error-msg glass-error">{{ error }}</p>
    </div>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')
const mode = ref('login') // 'login' or 'signup'

// Auto-redirect if already logged in
watchEffect(() => {
  if (user.value) {
    navigateTo('/admin')
  }
})

const handleAuth = async () => {
  if (!email.value || !password.value) return
  
  loading.value = true
  error.value = ''
  
  try {
    if (mode.value === 'login') {
      const { error: authError } = await supabase.auth.signInWithPassword({
        email: email.value,
        password: password.value
      })
      if (authError) error.value = authError.message
    } else {
      const { error: authError } = await supabase.auth.signUp({
        email: email.value,
        password: password.value,
        options: {
          emailRedirectTo: `${window.location.origin}/confirm`
        }
      })
      if (authError) error.value = authError.message
      else alert('Success! Please check your email for a confirmation link.')
    }
  } catch (e) {
    error.value = 'An unexpected error occurred. Please check your internet connection.'
  } finally {
    loading.value = false
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
  background-color: var(--mera-bg);
}

.login-card {
  width: 100%;
  max-width: 440px;
  padding: 56px;
  display: flex;
  flex-direction: column;
  gap: 32px;
  text-align: center;
}

.auth-tabs {
  display: flex;
  padding: 4px;
  border-radius: 14px;
  background: rgba(0, 0, 0, 0.02);
  margin-bottom: 8px;
}

.tab-btn {
  flex: 1;
  padding: 10px;
  border-radius: 12px;
  border: none;
  background: transparent;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  color: var(--mera-text-muted);
  transition: all 0.2s;
}

.tab-btn.active {
  background: white;
  color: var(--mera-text);
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.h-large {
  padding: 18px !important;
  font-size: 16px !important;
}

.login-header h1 {
  font-size: 32px;
  margin-bottom: 8px;
}

.login-header p {
  font-size: 14px;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
  text-align: left;
}

.input-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.label-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.forgot-link {
  font-size: 12px;
  color: var(--mera-primary);
  cursor: pointer;
  opacity: 0.8;
}

.forgot-link:hover {
  opacity: 1;
  text-decoration: underline;
}

label {
  font-size: 13px;
  color: var(--mera-text-muted);
  font-weight: 500;
}

input {
  background: rgba(0, 0, 0, 0.015);
  border: 1px solid var(--mera-border);
  border-radius: 14px;
  padding: 14px 18px;
  color: var(--mera-text);
  font-size: 15px;
  transition: all 0.2s;
  width: 100%;
}

input:focus {
  outline: none;
  border-color: var(--mera-primary);
  background: white;
  box-shadow: 0 0 0 4px rgba(255, 77, 148, 0.05);
}

.btn-full {
  width: 100%;
  margin-top: 12px;
}

.pink-glow {
  box-shadow: 0 4px 15px rgba(255, 77, 148, 0.2);
}

.pink-glow:hover {
  box-shadow: 0 8px 25px rgba(255, 77, 148, 0.3);
}

.error-msg {
  color: #ff3b30;
  font-size: 13px;
  padding: 12px;
  background: rgba(255, 59, 48, 0.05);
  border-radius: 12px;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fade-in {
  animation: fadeIn 0.6s ease forwards;
}

@media (max-width: 480px) {
  .login-card {
    padding: 32px 24px;
    gap: 24px;
  }
}
</style>
