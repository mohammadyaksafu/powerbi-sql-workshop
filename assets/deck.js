/* ============================================================
   Power BI with SQL — tiny slide engine (shared by every day)
   Keys: → / Space / PageDown = next · ← / PageUp = back
         Home / End = first / last · F = fullscreen
   ============================================================ */
(function () {
  const stage = document.querySelector('.stage');
  const slides = [...stage.querySelectorAll('.slide')];
  const label = stage.dataset.label || '';
  let cur = -1;

  // ---- Presenter UI ----
  stage.insertAdjacentHTML('beforeend', `
    <div class="ui-foot"><span class="brand"><b>Power BI with SQL</b> · ${label}</span><span class="count"></span></div>
    <div class="progress"><span></span></div>
    <button class="nav prev" aria-label="Previous slide">&#8249;</button>
    <button class="nav next" aria-label="Next slide">&#8250;</button>`);
  const countEl = stage.querySelector('.count');
  const bar = stage.querySelector('.progress span');
  stage.querySelector('.nav.prev').onclick = () => back();
  stage.querySelector('.nav.next').onclick = () => next();

  const hint = document.createElement('div');
  hint.className = 'hint';
  hint.innerHTML = 'Use <kbd>&larr;</kbd> <kbd>&rarr;</kbd> or <kbd>Space</kbd> to move &middot; <kbd>F</kbd> fullscreen';
  document.body.appendChild(hint);
  setTimeout(() => (hint.style.opacity = 0), 4500);

  // ---- Scale the 1280x720 stage to fit the window ----
  function fit() {
    const s = Math.min(innerWidth / 1280, innerHeight / 720);
    stage.style.transform = `scale(${s})`;
  }
  addEventListener('resize', fit);
  fit();

  // ---- Navigation ----
  function go(n, fromBack) {
    n = Math.max(0, Math.min(slides.length - 1, n));
    if (n === cur) return;
    slides.forEach((s, i) => {
      s.classList.toggle('active', i === n);
      s.classList.toggle('past', i < n);
    });
    // Fragments: hidden when arriving forwards, all shown when coming back
    slides[n].querySelectorAll('.frag').forEach(f => f.classList.toggle('on', !!fromBack));
    cur = n;
    stage.dataset.theme = slides[n].classList.contains('dark') ? 'dark' : 'light';
    countEl.textContent = `${n + 1} / ${slides.length}`;
    bar.style.width = `${((n + 1) / slides.length) * 100}%`;
    history.replaceState(null, '', '#' + (n + 1));
    runCounters(slides[n]);
    document.dispatchEvent(new CustomEvent('slidechange', { detail: { index: n, slide: slides[n] } }));
  }
  function next() {
    const hidden = slides[cur].querySelector('.frag:not(.on)');
    if (hidden) return hidden.classList.add('on');
    go(cur + 1);
  }
  function back() {
    const shown = [...slides[cur].querySelectorAll('.frag.on')];
    if (shown.length) return shown.pop().classList.remove('on');
    go(cur - 1, true);
  }

  addEventListener('keydown', e => {
    if (['ArrowRight', 'PageDown', ' ', 'Enter'].includes(e.key)) { e.preventDefault(); next(); }
    else if (['ArrowLeft', 'PageUp', 'Backspace'].includes(e.key)) { e.preventDefault(); back(); }
    else if (e.key === 'Home') go(0, true);
    else if (e.key === 'End') go(slides.length - 1, true);
    else if (e.key.toLowerCase() === 'f') {
      document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen?.();
    }
  });

  // Touch swipe
  let x0 = null;
  addEventListener('touchstart', e => (x0 = e.touches[0].clientX), { passive: true });
  addEventListener('touchend', e => {
    if (x0 === null) return;
    const dx = e.changedTouches[0].clientX - x0;
    if (Math.abs(dx) > 40) (dx < 0 ? next() : back());
    x0 = null;
  });

  // ---- Count-up numbers: <span data-count="1240" data-prefix="৳" data-dec="1"> ----
  function runCounters(slide) {
    slide.querySelectorAll('[data-count]').forEach(el => {
      const end = parseFloat(el.dataset.count), dec = +(el.dataset.dec || 0);
      const pre = el.dataset.prefix || '', suf = el.dataset.suffix || '';
      const delay = +(el.dataset.delay || 400), dur = 1400;
      el.textContent = pre + (0).toFixed(dec) + suf;
      setTimeout(() => {
        const t0 = performance.now();
        (function tick(t) {
          const p = Math.max(0, Math.min(1, (t - t0) / dur)), e = 1 - Math.pow(1 - p, 3);
          el.textContent = pre + (end * e).toLocaleString('en-US', { minimumFractionDigits: dec, maximumFractionDigits: dec }) + suf;
          if (p < 1) requestAnimationFrame(tick);
        })(t0);
      }, delay);
    });
  }

  const start = parseInt(location.hash.slice(1), 10);
  go(Number.isFinite(start) ? start - 1 : 0, true);
  if (!Number.isFinite(start) || start === 1) slides[0].querySelectorAll('.frag').forEach(f => f.classList.remove('on'));
})();
