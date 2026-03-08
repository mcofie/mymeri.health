<template>
  <div class="mera-date-picker">
    <div class="picker-label-row">
      <label>{{ label }}</label>
      <div class="info-pill" :title="helpText">
        <span>? لماذا؟</span>
      </div>
    </div>
    
    <div class="picker-anchor">
      <div class="picker-trigger glass-input" @click.stop="isOpen = !isOpen">
        <span v-if="modelValue" class="formatted-date">{{ formattedDisplayDate }}</span>
        <span v-else class="placeholder">Select Date</span>
        <span class="calendar-icon">🗓️</span>
      </div>

      <Transition name="fade-up">
        <div v-if="isOpen" class="calendar-dropdown glass" @click.stop>
          <header class="calendar-header">
            <button type="button" class="nav-btn" @click.stop="changeMonth(-1)">‹</button>
            <h3>{{ currentMonthName }} {{ currentYear }}</h3>
            <button type="button" class="nav-btn" @click.stop="changeMonth(1)">›</button>
          </header>

          <div class="calendar-grid">
            <div class="weekday" v-for="d in ['S','M','T','W','T','F','S']" :key="d">{{ d }}</div>
            <div 
              v-for="blank in blanks" 
              :key="'blank-'+blank" 
              class="day blank"
            ></div>
            <div 
              v-for="day in daysInMonth" 
              :key="day" 
              class="day"
              :class="{ 
                'selected': isSelected(day),
                'today': isToday(day)
              }"
              @click.stop="selectDate(day)"
            >
              {{ day }}
            </div>
          </div>
        </div>
      </Transition>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  modelValue: String,
  label: { type: String, default: 'Last Period Start Date' },
  helpText: { type: String, default: 'We use this to time your reminders exactly 7 days before your next flow.' }
})

const emit = defineEmits(['update:modelValue'])

const isOpen = ref(false)
const today = new Date()
const viewDate = ref(props.modelValue ? new Date(props.modelValue) : new Date())

const currentMonth = computed(() => viewDate.value.getMonth())
const currentYear = computed(() => viewDate.value.getFullYear())

const currentMonthName = computed(() => {
  return new Intl.DateTimeFormat('en-US', { month: 'long' }).format(viewDate.value)
})

const blanks = computed(() => {
  const firstDay = new Date(currentYear.value, currentMonth.value, 1).getDay()
  return Array.from({ length: firstDay }, (_, i) => i)
})

const daysInMonth = computed(() => {
  const days = new Date(currentYear.value, currentMonth.value + 1, 0).getDate()
  return Array.from({ length: days }, (_, i) => i + 1)
})

const formattedDisplayDate = computed(() => {
  if (!props.modelValue) return ''
  const date = new Date(props.modelValue)
  return new Intl.DateTimeFormat('en-GB', { day: '2-digit', month: 'long', year: 'numeric' }).format(date)
})

const changeMonth = (delta) => {
  const newDate = new Date(viewDate.value)
  newDate.setMonth(newDate.getMonth() + delta)
  viewDate.value = newDate
}

const selectDate = (day) => {
  const d = new Date(currentYear.value, currentMonth.value, day)
  // Format as YYYY-MM-DD properly in local time
  const offset = d.getTimezoneOffset()
  const localDate = new Date(d.getTime() - (offset * 60 * 1000))
  const formatted = localDate.toISOString().split('T')[0]
  
  emit('update:modelValue', formatted)
  isOpen.value = false
}

const isSelected = (day) => {
  if (!props.modelValue) return false
  const d = new Date(props.modelValue)
  return d.getDate() === day && d.getMonth() === currentMonth.value && d.getFullYear() === currentYear.value
}

const isToday = (day) => {
  return today.getDate() === day && today.getMonth() === currentMonth.value && today.getFullYear() === currentYear.value
}

// Close on click outside
if (process.client) {
  window.addEventListener('click', () => {
    isOpen.value = false
  })
}
</script>

<style scoped>
.mera-date-picker {
  display: flex;
  flex-direction: column;
  gap: 12px;
  position: relative;
}

.picker-label-row {
  display: flex;
  align-items: center;
  gap: 10px;
}

.picker-label-row label {
  font-size: 13px;
  font-weight: 700;
  color: #1a1a1a;
  opacity: 0.8;
}

.info-pill {
  background: #f0f0f0;
  padding: 4px 10px;
  border-radius: 40px;
  cursor: help;
  display: flex;
}

.info-pill span {
  font-size: 11px;
  font-weight: 800;
  color: #1a1a1a;
  opacity: 0.5;
}

.picker-anchor {
  position: relative;
}

.picker-trigger {
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  padding: 16px 20px !important;
  user-select: none;
}

.formatted-date {
  font-size: 16px;
  font-weight: 700;
  color: #1a1a1a;
}

.placeholder {
  font-size: 16px;
  color: #bbb;
  font-weight: 600;
}

.calendar-dropdown {
  position: absolute;
  top: calc(100% + 12px);
  left: 0;
  right: 0;
  z-index: 1000;
  padding: 24px;
  border-radius: 24px;
  box-shadow: 0 20px 50px rgba(0,0,0,0.1);
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.calendar-header h3 {
  font-size: 16px;
  font-weight: 800;
  margin: 0;
}

.nav-btn {
  background: #f5f5f5;
  border: none;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  transition: all 0.2s;
}

.nav-btn:hover { background: #eee; }

.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
}

.weekday {
  text-align: center;
  font-size: 10px;
  font-weight: 950;
  color: #bbb;
  padding: 8px 0;
  text-transform: uppercase;
}

.day {
  aspect-ratio: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 700;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
}

.day:hover:not(.blank):not(.selected) {
  background: #f9f9f9;
}

.day.selected {
  background: #1a1a1a;
  color: white;
}

.day.today:not(.selected) {
  color: var(--mera-primary);
  text-decoration: underline;
  text-underline-offset: 4px;
}

.day.blank {
  cursor: default;
}

/* Animations */
.fade-up-enter-active, .fade-up-leave-active {
  transition: all 0.3s cubic-bezier(0.23, 1, 0.32, 1);
}
.fade-up-enter-from {
  opacity: 0;
  transform: translateY(10px);
}
.fade-up-leave-to {
  opacity: 0;
  transform: translateY(10px);
}
</style>
