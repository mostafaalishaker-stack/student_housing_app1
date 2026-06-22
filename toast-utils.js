function showToast(message, type) {
  const existing = document.querySelector('.toast-container');
  if (!existing) {
    const c = document.createElement('div');
    c.className = 'toast-container';
    c.innerHTML = '<div class="toast-wrap"></div>';
    document.body.appendChild(c);
  }
  const wrap = document.querySelector('.toast-wrap');
  const t = document.createElement('div');
  t.className = 'toast toast-' + (type || 'info');
  t.innerHTML = message;
  wrap.appendChild(t);
  setTimeout(() => { t.classList.add('show'); }, 10);
  setTimeout(() => {
    t.classList.remove('show');
    setTimeout(() => t.remove(), 300);
  }, 3500);
}

function showLoading(container) {
  if (typeof container === 'string') container = document.getElementById(container);
  if (container) container.innerHTML = '<div class="loading">جاري التحميل...</div>';
}
