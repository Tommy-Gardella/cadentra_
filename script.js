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
  const submitBtn = form ? form.querySelector('button[type="submit"]') : null;
  if (!form || !confirm) return;

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    submitBtn.disabled = true;
    submitBtn.textContent = 'Submitting...';

    fetch('https://formspree.io/f/xjgpozbp', {
      method: 'POST',
      headers: { 'Accept': 'application/json' },
      body: new FormData(form)
    })
    .then(function (response) {
      if (response.ok) {
        form.style.display = 'none';
        confirm.classList.add('show');
      } else {
        submitBtn.disabled = false;
        submitBtn.textContent = 'Join the Waitlist →';
        alert('Something went wrong. Please try again.');
      }
    })
    .catch(function () {
      submitBtn.disabled = false;
      submitBtn.textContent = 'Join the Waitlist →';
      alert('Something went wrong. Please try again.');
    });
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

// ---- Nav CTA — auth-aware ----
(function () {
  var cta         = document.querySelector('.nav-cta');
  var mobileMenu  = document.querySelector('.nav-mobile-menu');
  if (!cta) return;

  function initNavDefault() {
    // Fallback: waitlist scroll
    cta.addEventListener('click', function () {
      var isHome = location.pathname.endsWith('index.html') || location.pathname.endsWith('/');
      if (isHome) {
        var el = document.getElementById('waitlist');
        if (el) el.scrollIntoView({ behavior: 'smooth' });
      } else {
        location.href = 'index.html#waitlist';
      }
    });
  }

  if (!window._supabase) { initNavDefault(); return; }

  window._supabase.auth.getUser().then(function (r) {
    var user = r.data && r.data.user;
    if (user) {
      // Replace CTA with Dashboard button
      cta.textContent = 'Dashboard';
      cta.onclick = function () { location.href = 'dashboard.html'; };

      // Add sign-out pill next to CTA (desktop)
      var pill = document.createElement('div');
      pill.className = 'nav-auth-pill';
      var av = document.createElement('div');
      av.className = 'nav-auth-avatar';
      av.textContent = (user.email || '?')[0].toUpperCase();
      var so = document.createElement('button');
      so.className = 'nav-auth-signout';
      so.textContent = 'Sign Out';
      so.addEventListener('click', async function () {
        await window._supabase.auth.signOut();
        location.reload();
      });
      pill.appendChild(av);
      pill.appendChild(so);
      cta.parentNode.insertBefore(pill, cta.nextSibling);

      // Mobile menu sign-out link
      if (mobileMenu) {
        var dash = document.createElement('a');
        dash.href = 'dashboard.html';
        dash.textContent = 'My Plans';
        mobileMenu.appendChild(dash);
        var soLink = document.createElement('a');
        soLink.href = '#';
        soLink.textContent = 'Sign Out';
        soLink.addEventListener('click', async function (e) {
          e.preventDefault();
          await window._supabase.auth.signOut();
          location.reload();
        });
        mobileMenu.appendChild(soLink);
      }
    } else {
      // Not logged in — CTA goes to login
      cta.textContent = 'Log In';
      cta.onclick = function () { location.href = 'login.html'; };
    }
  }).catch(function () { initNavDefault(); });
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
