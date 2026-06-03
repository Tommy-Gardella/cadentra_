/* ── State ── */
let parts      = load('asx_parts')      || [];
let categories = load('asx_categories') || ['Engine', 'Suspension', 'Brakes', 'Electrical', 'Body'];
let sortCol    = 'name';
let sortDir    = 1;  // 1 = asc, -1 = desc
let editingId  = null;
let detailId   = null;

/* ── Storage helpers ── */
function load(key) {
  try { return JSON.parse(localStorage.getItem(key)); } catch { return null; }
}
function save() {
  localStorage.setItem('asx_parts',      JSON.stringify(parts));
  localStorage.setItem('asx_categories', JSON.stringify(categories));
}

/* ── DOM refs ── */
const $ = id => document.getElementById(id);
const searchInput    = $('search');
const categoryFilter = $('category-filter');
const partsBody      = $('parts-body');
const emptyState     = $('empty-state');

/* ── Render ── */
function getFiltered() {
  const q   = searchInput.value.trim().toLowerCase();
  const cat = categoryFilter.value;
  return parts
    .filter(p => {
      const matchQ = !q ||
        p.name.toLowerCase().includes(q) ||
        (p.category || '').toLowerCase().includes(q) ||
        (p.condition || '').toLowerCase().includes(q) ||
        (p.description || '').toLowerCase().includes(q);
      const matchCat = !cat || p.category === cat;
      return matchQ && matchCat;
    })
    .sort((a, b) => {
      const av = sortCol === 'date' ? (a.dateRaw || '') : (a.name || '').toLowerCase();
      const bv = sortCol === 'date' ? (b.dateRaw || '') : (b.name || '').toLowerCase();
      return av < bv ? -sortDir : av > bv ? sortDir : 0;
    });
}

function renderTable() {
  const list = getFiltered();
  emptyState.classList.toggle('hidden', list.length > 0);
  partsBody.innerHTML = list.map(p => `
    <tr data-id="${p.id}">
      <td class="col-name">${esc(p.name)}</td>
      <td class="col-qty">${esc(p.qty)}×</td>
      <td class="col-cat">${p.category ? `<span class="chip">${esc(p.category)}</span>` : '<span style="color:#ccc">—</span>'}</td>
      <td class="col-cond"><span class="badge badge-${esc(p.condition)}">${esc(p.condition)}</span></td>
      <td class="col-date">${esc(p.date)}</td>
      <td class="col-actions" onclick="event.stopPropagation()">
        <button class="btn-icon edit"   onclick="openEdit('${p.id}')">✎</button>
        <button class="btn-icon delete" onclick="deletePart('${p.id}')">✕</button>
      </td>
    </tr>
  `).join('');
}

function renderCategoryDropdowns() {
  const opts = categories.map(c => `<option value="${esc(c)}">${esc(c)}</option>`).join('');
  categoryFilter.innerHTML = '<option value="">All Categories</option>' + opts;
  $('f-category').innerHTML  = '<option value="">Uncategorised</option>' + opts;
}

function renderCatList() {
  $('cat-list').innerHTML = categories.map(c => `
    <li>
      <span>${esc(c)}</span>
      <button class="btn-icon delete" onclick="deleteCategory('${esc(c)}')">✕</button>
    </li>
  `).join('');
}

function esc(s) {
  return String(s ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

/* ── Sort ── */
document.querySelectorAll('th.sortable').forEach(th => {
  th.addEventListener('click', () => {
    const col = th.dataset.col;
    if (sortCol === col) { sortDir *= -1; }
    else { sortCol = col; sortDir = 1; }
    document.querySelectorAll('th.sortable').forEach(t => {
      t.classList.remove('active');
      t.querySelector('.sort-arrow').textContent = '';
    });
    th.classList.add('active');
    th.querySelector('.sort-arrow').textContent = sortDir === 1 ? '↑' : '↓';
    renderTable();
  });
});

/* ── Search & filter ── */
searchInput.addEventListener('input', renderTable);
categoryFilter.addEventListener('change', renderTable);

/* ── Row click → detail ── */
partsBody.addEventListener('click', e => {
  const row = e.target.closest('tr[data-id]');
  if (row) openDetail(row.dataset.id);
});

/* ── Part modal ── */
$('btn-add-part').addEventListener('click', () => {
  editingId = null;
  $('modal-part-title').textContent = 'Add Part';
  $('form-part').reset();
  $('edit-id').value = '';
  clearErrors();
  $('modal-part').classList.remove('hidden');
  $('f-name').focus();
});

function openEdit(id) {
  const p = parts.find(x => x.id === id);
  if (!p) return;
  editingId = id;
  $('modal-part-title').textContent = 'Edit Part';
  $('edit-id').value    = p.id;
  $('f-name').value     = p.name;
  $('f-qty').value      = p.qty;
  $('f-condition').value = p.condition;
  $('f-category').value = p.category || '';
  $('f-description').value = p.description || '';
  clearErrors();
  $('modal-part').classList.remove('hidden');
  $('f-name').focus();
  $('modal-detail').classList.add('hidden');
}

$('btn-cancel-part').addEventListener('click', () => $('modal-part').classList.add('hidden'));

$('form-part').addEventListener('submit', e => {
  e.preventDefault();
  if (!validate()) return;

  const name      = $('f-name').value.trim();
  const qty       = parseInt($('f-qty').value, 10);
  const condition = $('f-condition').value;
  const category  = $('f-category').value;
  const desc      = $('f-description').value.trim();
  const now       = new Date();
  const dateStr   = now.toLocaleDateString('en-AU', { day:'2-digit', month:'short', year:'numeric' });
  const dateRaw   = now.toISOString();

  if (editingId) {
    const p = parts.find(x => x.id === editingId);
    Object.assign(p, { name, qty, condition, category, description: desc });
  } else {
    parts.push({ id: uid(), name, qty, condition, category, description: desc, date: dateStr, dateRaw });
  }

  save();
  renderTable();
  $('modal-part').classList.add('hidden');
});

function validate() {
  clearErrors();
  let ok = true;
  if (!$('f-name').value.trim())    { showError('f-name',      'Part name is required.');  ok = false; }
  if (!$('f-qty').value || $('f-qty').value < 1) { showError('f-qty', 'Enter a valid quantity.'); ok = false; }
  if (!$('f-condition').value)       { showError('f-condition', 'Select a condition.');     ok = false; }
  return ok;
}
function showError(fieldId, msg) {
  const el = $(fieldId);
  el.classList.add('error');
  const err = document.createElement('p');
  err.className = 'error-msg';
  err.textContent = msg;
  el.after(err);
}
function clearErrors() {
  document.querySelectorAll('.error').forEach(el => el.classList.remove('error'));
  document.querySelectorAll('.error-msg').forEach(el => el.remove());
}

/* ── Delete part ── */
function deletePart(id) {
  if (!confirm('Delete this part?')) return;
  parts = parts.filter(p => p.id !== id);
  save();
  renderTable();
}

/* ── Detail modal ── */
function openDetail(id) {
  const p = parts.find(x => x.id === id);
  if (!p) return;
  detailId = id;
  $('modal-detail-title').textContent = p.name;
  $('detail-body').innerHTML = `
    <div class="detail-grid">
      <span class="dl">Quantity</span>  <span>${esc(p.qty)}×</span>
      <span class="dl">Condition</span> <span><span class="badge badge-${esc(p.condition)}">${esc(p.condition)}</span></span>
      <span class="dl">Category</span>  <span>${p.category ? `<span class="chip">${esc(p.category)}</span>` : '—'}</span>
      <span class="dl">Date Added</span><span>${esc(p.date)}</span>
    </div>
    ${p.description ? `<div class="detail-desc">${esc(p.description)}</div>` : ''}
  `;
  $('modal-detail').classList.remove('hidden');
}
$('btn-close-detail').addEventListener('click', () => $('modal-detail').classList.add('hidden'));
$('btn-edit-from-detail').addEventListener('click', () => openEdit(detailId));

/* ── Category modal ── */
$('btn-manage-categories').addEventListener('click', () => {
  renderCatList();
  $('modal-cats').classList.remove('hidden');
  $('new-cat-input').focus();
});
$('btn-close-cats').addEventListener('click', () => $('modal-cats').classList.add('hidden'));

$('btn-add-cat').addEventListener('click', addCategory);
$('new-cat-input').addEventListener('keydown', e => { if (e.key === 'Enter') { e.preventDefault(); addCategory(); } });

function addCategory() {
  const name = $('new-cat-input').value.trim();
  if (!name) return;
  if (categories.includes(name)) { alert(`"${name}" already exists.`); return; }
  categories.push(name);
  categories.sort((a, b) => a.localeCompare(b));
  save();
  renderCategoryDropdowns();
  renderCatList();
  $('new-cat-input').value = '';
  $('new-cat-input').focus();
}

function deleteCategory(name) {
  if (!confirm(`Delete category "${name}"? Parts will become Uncategorised.`)) return;
  categories = categories.filter(c => c !== name);
  parts.forEach(p => { if (p.category === name) p.category = ''; });
  save();
  renderCategoryDropdowns();
  renderCatList();
  renderTable();
}

/* ── Close modals on overlay click ── */
['modal-part','modal-cats','modal-detail'].forEach(id => {
  $(id).addEventListener('click', e => {
    if (e.target === $(id)) $(id).classList.add('hidden');
  });
});

/* ── Utility ── */
function uid() {
  return Date.now().toString(36) + Math.random().toString(36).slice(2, 7);
}

/* ── Init ── */
renderCategoryDropdowns();
renderTable();
