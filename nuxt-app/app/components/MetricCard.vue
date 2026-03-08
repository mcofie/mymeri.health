<template>
  <div class="metric-card glass hover-scale">
    <div class="header">
      <span class="label text-muted">{{ label }}</span>
      <div class="icon glass">{{ icon }}</div>
    </div>
    <div class="value">{{ value }}</div>
    <div class="footer">
      <span class="trend" :class="trendDirection">{{ trendValue }}</span>
      <span class="period">since last cycle</span>
    </div>
  </div>
</template>

<script setup>
defineProps({
  label: String,
  value: String,
  icon: String,
  trendValue: String,
  trendDirection: String // 'up' or 'down'
})
</script>

<style scoped>
.metric-card {
  flex: 1;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.label {
  font-size: 14px;
  color: var(--mera-text-muted);
}

.icon {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
}

.value {
  font-size: 32px;
  font-weight: 600;
}

.footer {
  display: flex;
  gap: 8px;
  font-size: 12px;
  align-items: center;
}

.trend.up { color: #34c759; }
.trend.down { color: #ff3b30; }

.period { color: rgba(255, 255, 255, 0.3); }
</style>
