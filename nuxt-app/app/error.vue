<template>
  <div class="error-page glass">
    <h1 class="premium-gradient">{{ error.statusCode }}</h1>
    <p>{{ error.message || 'Something went wrong' }}</p>
    <button @click="handleError" class="btn-primary glass">Back Home</button>
  </div>
</template>

<script setup>
const props = defineProps({
  error: Object
})

const handleError = () => clearError({ redirect: '/' })
</script>

<style scoped>
.error-page {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  gap: 24px;
  text-align: center;
  background-color: var(--mera-bg);
  color: var(--mera-text);
}

h1 {
  font-size: 120px;
  font-weight: 700;
}

p {
  color: var(--mera-text-muted);
  font-size: 18px;
}

.btn-primary {
  padding: 12px 32px;
  border-radius: 12px;
  color: var(--mera-text);
  cursor: pointer;
  border: 1px solid var(--mera-border);
}
</style>
