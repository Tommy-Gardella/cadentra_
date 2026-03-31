/* =============================================
   CADENTRA — Shared JavaScript
   ============================================= */

// ---- Navbar scroll shadow ----
(function () {
  const navbar = document.querySelector('.navbar');
  if (!navbar) return;
  window.addEventListener('scroll', () => {
    navbar.classList.toggle('scrolled', window.scrollY > 10);
  });
})();

// ---- Mobile nav toggle ----
(function () {
  const toggle = document.querySelector('.nav-toggle');
  const menu = document.querySelector('.nav-mobile-menu');
  if (!toggle || !menu) return;

  toggle.addEventListener('click', () => {
    const open = menu.classList.toggle('open');
    toggle.setAttribute('aria-expanded', open);
    toggle.textContent = open ? '✕' : '☰';
  });

  // Close menu when a link is clicked
  menu.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      menu.classList.remove('open');
      toggle.textContent = '☰';
      toggle.setAttribute('aria-expanded', false);
    });
  });
})();

// ---- Active nav link ----
(function () {
  const page = location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav-links a, .nav-mobile-menu a').forEach(link => {
    const href = link.getAttribute('href');
    if (href === page || (page === '' && href === 'index.html')) {
      link.classList.add('active');
    }
  });
})();

// ---- Hero email capture form (index.html) ----
(function () {
  const form = document.getElementById('hero-email-form');
  const confirm = document.getElementById('hero-confirm');
  if (!form || !confirm) return;

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    form.style.display = 'none';
    confirm.classList.add('show');
  });
})();

// ---- Contact form (contact.html) ----
(function () {
  const form = document.getElementById('contact-form');
  const confirm = document.getElementById('contact-confirm');
  if (!form || !confirm) return;

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    form.style.display = 'none';
    confirm.classList.add('show');
    confirm.scrollIntoView({ behavior: 'smooth', block: 'center' });
  });
})();

// ---- Nav CTA buttons → index.html#waitlist ----
(function () {
  document.querySelectorAll('.nav-cta').forEach(btn => {
    btn.addEventListener('click', () => {
      const isHome = location.pathname.endsWith('index.html') || location.pathname.endsWith('/');
      if (isHome) {
        document.getElementById('waitlist')?.scrollIntoView({ behavior: 'smooth' });
      } else {
        location.href = 'index.html#waitlist';
      }
    });
  });
})();

// ---- Fade-up observer ----
(function () {
  if (!('IntersectionObserver' in window)) {
    document.querySelectorAll('.fade-up').forEach(el => el.style.opacity = '1');
    return;
  }
  const io = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.style.animationPlayState = 'running';
        io.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 });

  document.querySelectorAll('.fade-up').forEach(el => {
    el.style.animationPlayState = 'paused';
    io.observe(el);
  });
})();
