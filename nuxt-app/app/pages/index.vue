<template>
  <div class="landing-page">
    <nav class="glass-nav">
      <div class="container">
        <div class="logo">MyMeri<span class="dot">.</span></div>
        <div class="nav-links">
          <NuxtLink to="/subscribe" class="btn-primary-sm glass">Get Started</NuxtLink>
        </div>
      </div>
    </nav>

    <header class="hero">
      <div class="container mobile-stack">
        <div class="hero-content">
          <span class="badge-premium">Bulk Security • 20% Savings</span>
          <h1 class="premium-gradient">End the <br />Pharmacy Dash.</h1>
          <p class="hero-text text-muted">Stop the last-minute panic buys. MyMeri delivers your custom "Stock-Up" stash 3 days before you even need to think about it. Professional care, delivered in bulk for your peace of mind.</p>
          <div class="hero-actions">
            <NuxtLink to="/subscribe" class="btn-hero pink-glow">Secure My Stash</NuxtLink>
            <a href="#how-it-works" class="btn-secondary-hero glass">Why go bulk?</a>
          </div>
        </div>
        <div class="hero-image-wrapper">
          <img src="/hero-box.png" alt="MyMeri Stock-Up Box" class="hero-img glass-border" />
          <div class="stats-card-float glass">
            <div class="stat-item">
              <strong>98.2%</strong>
              <span>Security Rate</span>
            </div>
            <div class="stat-divider"></div>
            <div class="stat-item">
              <strong>20% Off</strong>
              <span>Bulk Savings</span>
            </div>
          </div>
        </div>
      </div>
    </header>

    <section id="how-it-works" class="features">
      <div class="container">
        <div class="section-header">
          <h2>The "Advance" Logic</h2>
          <p class="text-muted">We think ahead so you don't have to.</p>
        </div>
        
        <div class="feature-grid">
          <div class="feature-card glass hover-lift">
            <div class="feature-icon">🛡️</div>
            <h3>Bulk Security</h3>
            <p>Buy in quarterly bundles. Never run out of your preferred brand again.</p>
          </div>
          <div class="feature-card glass hover-lift active-glow">
            <div class="feature-icon">🔔</div>
            <h3>14-Day Advance</h3>
            <p>For bulk users, we nudge you 2 weeks early to ensure your next stash is ready.</p>
          </div>
          <div class="feature-card glass hover-lift">
            <div class="feature-icon">💸</div>
            <h3>Economy of Scale</h3>
            <p>Save significantly on unit price and delivery fees by stocking up quarterly.</p>
          </div>
        </div>
      </div>
    </section>

    <section class="tiers-preview">
      <div class="container">
        <div class="section-header">
          <h2>Select Your Security</h2>
          <p class="text-muted">Save more by planning ahead with our Quarterly stashes.</p>
        </div>
        
        <div class="tier-grid">
          <div class="tier-card glass">
            <h3>Essential</h3>
            <div class="price">GHS 120<span>/month</span></div>
            <ul class="tier-features">
              <li>Premium Eco-Pads</li>
              <li>Standard 7-Day Nudge</li>
              <li>Monthly Delivery</li>
            </ul>
          </div>
          <div class="tier-card glass featured">
            <div class="best-value">Best Logic</div>
            <h3>Peace of Mind</h3>
            <div class="price">GHS 480<span>/quarter</span></div>
            <div class="savings-info">Save 20% vs Retail</div>
            <ul class="tier-features">
              <li>Full 3-Month Supply</li>
              <li>14-Day Advance Nudge</li>
              <li>Single Yearly Logistics</li>
              <li>Priority Bulk Access</li>
            </ul>
          </div>
          <div class="tier-card glass">
            <h3>Comfort</h3>
            <div class="price">GHS 200<span>/month</span></div>
            <ul class="tier-features">
              <li>Everything in Essential</li>
              <li>Herbal Cycle Teas</li>
              <li>Artisanal Dark Chocolate</li>
              <li>Priority Packaging</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <footer class="landing-footer glass-top">
      <div class="container">
        <div class="footer-grid">
          <div class="footer-info">
            <div class="logo">MyMeri<span class="dot">.</span></div>
            <p class="text-muted">Pan-African wellness, delivered with dignity.</p>
          </div>
          <div class="footer-links">
            <NuxtLink to="/subscribe" class="nav-item">Subscribe</NuxtLink>
          </div>
        </div>
        <div class="copyright">
          &copy; 2026 MyMeri. All rights reserved. Built for wellness.
        </div>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.landing-page {
  background: var(--mera-bg);
  color: var(--mera-text);
  min-height: 100vh;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
}

.glass-nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid var(--mera-border);
  padding: 16px 0;
}

.glass-nav .container {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo {
  font-size: 24px;
  font-weight: 700;
  letter-spacing: -1px;
}

.dot { color: var(--mera-primary); }

.nav-links {
  display: flex;
  gap: 24px;
  align-items: center;
}

.nav-item {
  font-size: 14px;
  color: var(--mera-text-muted);
  text-decoration: none;
  transition: color 0.3s;
}

.nav-item:hover { color: var(--mera-text); }

.hero {
  padding: 160px 0 100px;
}

.mobile-stack {
  display: grid;
  grid-template-columns: 1.2fr 1fr;
  gap: 80px;
  align-items: center;
}

.badge-premium {
  display: inline-block;
  padding: 4px 12px;
  background: rgba(255, 77, 148, 0.1);
  color: var(--mera-primary);
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  margin-bottom: 24px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

h1 {
  font-size: 64px;
  line-height: 1.1;
  margin-bottom: 24px;
  letter-spacing: -2px;
}

.hero-text {
  font-size: 18px;
  line-height: 1.6;
  margin-bottom: 48px;
  max-width: 500px;
}

.hero-actions {
  display: flex;
  gap: 20px;
}

.btn-hero {
  background: var(--mera-primary);
  color: white;
  padding: 18px 36px;
  border-radius: 40px;
  text-decoration: none;
  font-weight: 600;
  transition: all 0.3s;
}

.btn-hero:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 40px rgba(255, 77, 148, 0.3);
}

.btn-secondary-hero {
  padding: 18px 36px;
  border-radius: 40px;
  text-decoration: none;
  font-weight: 600;
  color: var(--mera-text);
}

.hero-image-wrapper {
  position: relative;
}

.hero-img {
  width: 100%;
  border-radius: 40px;
  transition: transform 0.5s;
}

.hero-image-wrapper:hover .hero-img {
  transform: scale(1.02);
}

.stats-card-float {
  position: absolute;
  bottom: -40px;
  right: -40px;
  padding: 24px 40px;
  border-radius: 24px;
  display: flex;
  gap: 24px;
  align-items: center;
}

.stat-item {
  display: flex;
  flex-direction: column;
}

.stat-item strong {
  font-size: 24px;
  color: var(--mera-primary);
}

.stat-item span {
  font-size: 12px;
  color: var(--mera-text-muted);
}

.stat-divider {
  width: 1px;
  height: 40px;
  background: var(--mera-border);
}

.features {
  padding: 120px 0;
}

.section-header {
  text-align: center;
  margin-bottom: 64px;
}

.section-header h2 {
  font-size: 40px;
  margin-bottom: 12px;
}

.feature-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 32px;
}

.feature-card {
  padding: 40px;
  border-radius: 32px;
  text-align: left;
}

.feature-icon {
  font-size: 40px;
  margin-bottom: 24px;
}

.feature-card h3 {
  font-size: 20px;
  margin-bottom: 16px;
}

.feature-card p {
  font-size: 14px;
  line-height: 1.6;
}

.active-glow {
  box-shadow: 0 0 60px rgba(142, 85, 233, 0.05);
  border-color: rgba(142, 85, 233, 0.2);
}

.tiers-preview {
  padding: 100px 0 160px;
}

.tier-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 32px;
}

.tier-card {
  padding: 48px;
  border-radius: 40px;
  text-align: center;
  position: relative;
}

.tier-card h3 {
  font-size: 24px;
  margin-bottom: 24px;
}

.price {
  font-size: 48px;
  font-weight: 700;
  margin-bottom: 8px;
}

.price span {
  font-size: 16px;
  font-weight: 400;
  opacity: 0.5;
}

.savings-info {
  color: #34c759;
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 32px;
}

.tier-features {
  list-style: none;
  padding: 0;
  text-align: left;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.tier-features li {
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.tier-features li::before {
  content: "✨";
  font-size: 12px;
}

.featured {
  background: rgba(255, 77, 148, 0.02);
  border-color: rgba(255, 77, 148, 0.2);
  transform: scale(1.05);
}

.best-value {
  position: absolute;
  top: 24px;
  right: 24px;
  background: var(--mera-primary);
  color: white;
  font-size: 10px;
  font-weight: 700;
  padding: 4px 12px;
  border-radius: 20px;
  text-transform: uppercase;
}

.landing-footer {
  padding: 80px 0 40px;
  border-top: 1px solid var(--mera-border);
}

.footer-grid {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 60px;
}

.footer-info p {
  margin-top: 12px;
  font-size: 14px;
}

.copyright {
  text-align: center;
  font-size: 12px;
  color: var(--mera-text-muted);
  border-top: 1px solid var(--mera-border);
  padding-top: 40px;
}

/* Mobile Responsiveness */
@media (max-width: 1024px) {
  h1 { font-size: 48px; }
  .mobile-stack { gap: 40px; }
  .stats-card-float { right: 0; bottom: -24px; padding: 16px 24px; }
}

@media (max-width: 768px) {
  .mobile-stack {
    grid-template-columns: 1fr;
    text-align: center;
  }
  
  .hero-content {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  
  .hero-text { margin: 0 auto 32px; }
  
  .hero-actions {
    flex-direction: column;
    width: 100%;
  }
  
  .hero-image-wrapper { order: -1; margin-bottom: 40px; }
  
  .feature-grid, .tier-grid {
    grid-template-columns: 1fr;
  }
  
  .featured {
    transform: none;
  }
  
  .stats-card-float {
    position: relative;
    right: 0;
    bottom: 0;
    margin-top: 24px;
    justify-content: center;
  }

  .nav-links { display: none; }
}
</style>
