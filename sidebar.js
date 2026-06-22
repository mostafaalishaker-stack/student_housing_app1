function initSidebar() {
  if (document.getElementById('sidebar')) return;

  const sidebarHtml = `
    <div id="sidebar" class="sidebar">
      <div class="sidebar-header">
        <span class="sidebar-logo">سكنكم</span>
        <button class="sidebar-close" onclick="toggleSidebar()">✕</button>
      </div>
      <div class="sidebar-user" id="sidebarUser">
        <div class="sidebar-avatar">👤</div>
        <div>
          <div class="sidebar-name">...</div>
          <div class="sidebar-role">زائر</div>
        </div>
      </div>
      <nav class="sidebar-nav">
        <a href="/dashboard.html" class="sidebar-link">🏠 الرئيسية</a>
        <a href="/my-bookings.html" class="sidebar-link" id="sidebarBookingsLink" style="display:none;">📋 حجوزاتي</a>
        <a href="/admin.html" class="sidebar-link" id="sidebarAdminLink" style="display:none;">🛠 لوحة التحكم</a>
        <button class="sidebar-link" onclick="contactWhatsApp()">📱 تواصل معنا</button>
      </nav>
      <div class="sidebar-footer">
        <button class="sidebar-logout" id="sidebarLogoutBtn" onclick="sidebarLogout()" style="display:none;">🚪 تسجيل خروج</button>
        <button class="sidebar-login" id="sidebarLoginBtn" onclick="sidebarShowLogin()">تسجيل الدخول</button>
      </div>
    </div>
    <div class="sidebar-overlay" onclick="toggleSidebar()"></div>
  `;
  document.body.insertAdjacentHTML('beforeend', sidebarHtml);

  const style = document.createElement('style');
  style.textContent = `
    .hamburger { background:rgba(255,255,255,0.15); border:1px solid rgba(255,255,255,0.3); border-radius:8px; width:38px; height:38px; display:flex; align-items:center; justify-content:center; cursor:pointer; font-size:20px; color:white; margin-left:12px; flex-shrink:0; }
    
    .sidebar { position:fixed; top:0; right:-300px; width:280px; height:100vh; background:white; z-index:3000; display:flex; flex-direction:column; transition:right 0.3s; box-shadow:-4px 0 20px rgba(0,0,0,0.15); }
    .sidebar.open { right:0; }
    .sidebar-overlay { position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.4); z-index:2999; display:none; }
    .sidebar-overlay.open { display:block; }
    
    .sidebar-header { display:flex; justify-content:space-between; align-items:center; padding:16px 20px; border-bottom:1px solid #eee; }
    .sidebar-logo { font-size:20px; font-weight:700; color:#1565C0; }
    .sidebar-close { background:none; border:none; font-size:22px; cursor:pointer; color:#888; padding:4px; }
    
    .sidebar-user { display:flex; align-items:center; gap:12px; padding:16px 20px; border-bottom:1px solid #f0f0f0; }
    .sidebar-avatar { font-size:32px; }
    .sidebar-name { font-size:15px; font-weight:600; }
    .sidebar-role { font-size:12px; color:#888; }
    
    .sidebar-nav { flex:1; padding:12px 0; overflow-y:auto; }
    .sidebar-link { display:flex; align-items:center; gap:10px; width:100%; padding:12px 20px; border:none; background:none; font-family:'Cairo',sans-serif; font-size:14px; color:#333; cursor:pointer; text-decoration:none; text-align:right; transition:background 0.15s; }
    .sidebar-link:hover { background:#f5f8ff; color:#1565C0; }
    
    .sidebar-footer { padding:12px 20px 20px; border-top:1px solid #eee; }
    .sidebar-logout, .sidebar-login { width:100%; padding:10px; border:none; border-radius:8px; font-family:'Cairo',sans-serif; font-size:14px; font-weight:600; cursor:pointer; }
    .sidebar-logout { background:#ffebee; color:#d32f2f; }
    .sidebar-login { background:#1565C0; color:white; }
    .sidebar-logout:hover { background:#ffcdd2; }
    .sidebar-login:hover { background:#0D47A1; }
  `;
  document.head.appendChild(style);

  updateSidebarUser();
}

function toggleSidebar() {
  document.getElementById('sidebar').classList.toggle('open');
  document.querySelector('.sidebar-overlay').classList.toggle('open');
}

function closeSidebar() {
  document.getElementById('sidebar')?.classList.remove('open');
  document.querySelector('.sidebar-overlay')?.classList.remove('open');
}

function updateSidebarUser() {
  const name = localStorage.getItem('userName');
  const role = localStorage.getItem('userRole');
  const token = localStorage.getItem('token');
  const el = document.getElementById('sidebarUser');
  if (!el) return;
  if (name && token) {
    el.innerHTML = `
      <div class="sidebar-avatar">👤</div>
      <div>
        <div class="sidebar-name">${name}</div>
        <div class="sidebar-role">${role === 'admin' ? 'مشرف' : 'طالب'}</div>
      </div>`;
    document.getElementById('sidebarBookingsLink').style.display = 'flex';
    document.getElementById('sidebarLogoutBtn').style.display = 'block';
    document.getElementById('sidebarLoginBtn').style.display = 'none';
    if (role === 'admin') document.getElementById('sidebarAdminLink').style.display = 'flex';
  } else {
    el.innerHTML = `
      <div class="sidebar-avatar">👤</div>
      <div>
        <div class="sidebar-name">زائر</div>
        <div class="sidebar-role">لم تسجل الدخول</div>
      </div>`;
    document.getElementById('sidebarBookingsLink').style.display = 'none';
    document.getElementById('sidebarAdminLink').style.display = 'none';
    document.getElementById('sidebarLogoutBtn').style.display = 'none';
    document.getElementById('sidebarLoginBtn').style.display = 'block';
  }
}

function sidebarLogout() {
  if (typeof google !== 'undefined' && google.accounts) google.accounts.id.disableAutoSelect();
  localStorage.removeItem('token');
  localStorage.removeItem('userName');
  localStorage.removeItem('userRole');
  updateSidebarUser();
  closeSidebar();
  location.href = '/dashboard.html';
}

function sidebarShowLogin() {
  closeSidebar();
  const modal = document.getElementById('loginModal');
  if (modal) modal.classList.add('show');
}

function contactWhatsApp() {
  const num = '201112291736';
  const text = encodeURIComponent('مرحباً، أريد الاستفسار عن حجز شقة في سكنكم');
  window.open(`https://wa.me/${num}?text=${text}`, '_blank');
}
