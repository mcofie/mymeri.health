<template>
  <div class="toast-container">
    <TransitionGroup name="toast">
      <div v-for="toast in toasts" :key="toast.id" class="toast glass" :class="toast.type">
        <span class="message">{{ toast.message }}</span>
        <button @click="remove(toast.id)" class="close">×</button>
      </div>
    </TransitionGroup>
  </div>
</template>

<script setup>
// Mocking a toast system
const toasts = ref([])

const remove = (id) => {
  toasts.value = toasts.value.filter(t => t.id !== id)
}
</script>

<style scoped>
.toast-container {
  position: fixed;
  bottom: 24px;
  right: 24px;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.toast {
  padding: 16px 24px;
  min-width: 300px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-radius: 12px;
  animation: slideIn 0.3s ease-out;
}

.toast.info { border-left: 4px solid var(--mera-primary); }

.message {
  font-size: 14px;
  color: var(--mera-text);
}

.close {
  background: none;
  border: none;
  color: var(--mera-text-muted);
  font-size: 20px;
  cursor: pointer;
}

@keyframes slideIn {
  from { transform: translateX(100%); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

.toast-enter-active, .toast-leave-active {
  transition: all 0.3s ease;
}
.toast-enter-from { transform: translateX(100%); opacity: 0; }
.toast-leave-to { transform: translateX(100%); opacity: 0; }
</style>
