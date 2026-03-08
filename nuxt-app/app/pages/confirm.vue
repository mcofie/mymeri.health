<template>
  <div class="confirm-container">
    <div class="confirm-card glass">
      <h1 class="premium-gradient">Confirming Access...</h1>
      <p>Please wait while we secure your session.</p>
    </div>
  </div>
</template>

<script setup>
const user = useSupabaseUser()
watch(user, () => {
  if (user.value) {
    navigateTo('/admin')
  }
}, { immediate: true })
</script>

<style scoped>
.confirm-container {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
}
.confirm-card {
  padding: 48px;
  text-align: center;
}
</style>
