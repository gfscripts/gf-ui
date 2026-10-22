// ===== GF UI: interfaz =====
(() => {
  const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'gf-ui';
  const $ = (id) => document.getElementById(id);
  let textPosition = 'left';

  const ICONS = {
    success: 'M5 12.5l4.2 4.2L19 7',
    error: 'M7 7l10 10M17 7L7 17',
    inform: 'M12 11v6M12 7.2v.1',
    warning: 'M12 7v6M12 16.8v.1',
  };

  const TITLES = { success: 'Hecho', error: 'Error', inform: 'Información', warning: 'Aviso' };

  // Quita los códigos de color de GTA (~r~, ~s~...) y cambia ~INPUT_...~ por la tecla
  const KEYS = { INPUT_CONTEXT: 'E', INPUT_PICKUP: 'E', INPUT_DETONATE: 'G', INPUT_VEH_HEADLIGHT: 'H', INPUT_ENTER: 'F', INPUT_REPLAY_START_STOP_RECORDING: 'F1' };
  // Máximo 500 caracteres: un texto enorme no puede tapar la pantalla
  const clean = (text) =>
    String(text ?? '')
      .replace(/~(INPUT_[A-Z_]+)~/g, (_, name) => `[${KEYS[name] || 'E'}]`)
      .replace(/~[a-zA-Z]~/g, '')
      .replace(/<[^>]*>/g, '')
      .trim()
      .slice(0, 500);

  const escape = (text) => String(text).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

  // ===== Config =====
  const setPosition = (element, prefix, position) => {
    element.className = element.className
      .split(' ')
      .filter((name) => !name.startsWith(`${prefix}-`))
      .concat(`${prefix}-${position}`)
      .join(' ');
  };

  const applyConfig = (config) => {
    if (!config) return;

    let hex = String(config.color || '#3b82f6').replace('#', '');
    if (!/^[0-9a-fA-F]{6}$/.test(hex)) hex = '3b82f6';
    const rgb = [0, 2, 4].map((i) => parseInt(hex.slice(i, i + 2), 16) || 0).join(', ');
    document.documentElement.style.setProperty('--accent', rgb);

    setPosition($('toasts'), 'toasts', config.notify || 'top');
    setPosition($('progress'), 'progress', config.progress || 'bottom');
    textPosition = config.text || 'left';
    setPosition($('textui'), 'textui', textPosition);
    $('progress-key').textContent = config.cancelKey || 'X';
    if (config.cancelText) $('progress-cancel').lastChild.textContent = ` ${config.cancelText}`;
    if (config.titles) Object.assign(TITLES, config.titles);
  };

  // ===== Avisos =====
  const toasts = $('toasts');

  const notify = (data) => {
    const type = ICONS[data.type] ? data.type : 'inform';
    const description = clean(data.description);
    const title = clean(data.title) || TITLES[type];
    const duration = Math.min(Math.max(Number(data.duration) || 4000, 1500), 20000);

    // El mismo aviso seguido no se repite
    for (const old of toasts.querySelectorAll('.toast')) {
      if (old.dataset.key === `${type}|${description}`) old.remove();
    }

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.dataset.key = `${type}|${description}`;
    toast.innerHTML = `
      <span class="toast-icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="${ICONS[type]}"/></svg></span>
      <div class="toast-text"><strong>${escape(title)}</strong>${description ? `<span>${escape(description)}</span>` : ''}</div>
      <i class="toast-bar" style="animation-duration:${duration}ms"></i>`;

    toasts.appendChild(toast);
    while (toasts.children.length > 5) toasts.firstChild.remove();

    setTimeout(() => toast.classList.add('leaving'), duration);
    setTimeout(() => toast.remove(), duration + 220);
  };

  // ===== Barra de progreso =====
  const progress = $('progress');
  let frame = null;

  const startProgress = (data) => {
    cancelAnimationFrame(frame);
    progress.classList.remove('cancelled');
    $('progress-label').textContent = clean(data.label);
    $('progress-cancel').style.display = data.canCancel ? '' : 'none';

    const duration = Math.max(Number(data.duration) || 1, 1);
    const start = performance.now();

    const tick = (now) => {
      const value = Math.min((now - start) / duration, 1);
      $('progress-fill').style.width = `${value * 100}%`;
      $('progress-percent').textContent = `${Math.floor(value * 100)}%`;
      if (value < 1) frame = requestAnimationFrame(tick);
    };

    frame = requestAnimationFrame(tick);
    progress.classList.add('show');
  };

  const endProgress = (data) => {
    cancelAnimationFrame(frame);

    if (data && data.cancelled) {
      progress.classList.add('cancelled');
      setTimeout(() => progress.classList.remove('show'), 350);
    } else {
      $('progress-fill').style.width = '100%';
      $('progress-percent').textContent = '100%';
      setTimeout(() => progress.classList.remove('show'), 120);
    }
  };

  // ===== Texto de ayuda =====
  const textui = $('textui');

  const showText = (data) => {
    if (!data) {
      textui.classList.remove('show');
      return;
    }

    let text = clean(data.text);
    let key = data.key || '';

    // "[E] Abrir garaje" o "[E] - Abrir garaje" -> tecla E
    const match = text.match(/^\[([^\]]{1,12})\]\s*[-:]?\s*/);
    if (!key && match) {
      key = match[1];
      text = text.slice(match[0].length);
    }

    $('textui-key').textContent = key;
    // Las teclas en mitad del texto ("Pulsa [E] para hablar") salen como teclita
    $('textui-text').innerHTML = escape(text).replace(/\[([^\]]{1,12})\]/g, '<kbd class="inline">$1</kbd>');
    textui.classList.toggle('no-key', !key);
    setPosition(textui, 'textui', data.position || textPosition);
    textui.classList.add('show');
  };

  // ===== Mensajes del Lua =====
  window.addEventListener('message', (event) => {
    const { action, data } = event.data || {};

    if (action === 'notify') notify(data || {});
    else if (action === 'progress') startProgress(data || {});
    else if (action === 'progressEnd') endProgress(data);
    else if (action === 'text') showText(data);
  });

  // Pedir el config. Si el Lua aún no está listo (puede pasar al entrar), se reintenta.
  const askConfig = (tries) => {
    fetch(`https://${resource}/ready`, { method: 'POST', body: '{}' })
      .then((response) => response.json())
      .then(applyConfig)
      .catch(() => { if (tries > 0) setTimeout(() => askConfig(tries - 1), 1000); });
  };
  askConfig(10);
})();
