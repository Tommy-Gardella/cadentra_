$file = 'C:\Users\bigto\cadentra\plan.html'
$bytes = [System.IO.File]::ReadAllBytes($file)
$content = [System.Text.Encoding]::UTF8.GetString($bytes)

# 1. Add Save button before "Rebuild Plan" button in plan-actions
$old1 = '<a href="how-it-works.html#training-block-builder" class="btn btn-outline">Rebuild Plan</a>'
$new1 = '<button id="save-plan-btn" class="btn btn-accent" style="display:none;">Save to Library</button>' + "`r`n" + '            ' + $old1
$content = $content.Replace($old1, $new1)

# 2. Add Supabase CDN before script.js tag
$old2 = '  <script src="script.js"></script>'
$new2 = '  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>' + "`r`n" + '  <script src="js/supabase-client.js"></script>' + "`r`n" + '  <script src="script.js"></script>'
$content = $content.Replace($old2, $new2)

# 3. Add unlimited-chat + save-modal script block before </body>
$old3 = '</body>'
$saveModalAndScript = @'
  <!-- Save Plan Modal -->
  <div id="save-modal-overlay" class="save-modal-overlay" style="display:none;">
    <div class="save-modal-box">
      <button class="save-modal-close" id="save-modal-close">&#10005;</button>

      <div id="save-modal-no-auth" style="display:none; text-align:center; padding:12px 0 4px;">
        <div style="font-size:2rem; margin-bottom:12px;">&#128274;</div>
        <h3 style="font-size:1.4rem; margin-bottom:8px;">Log In to Save</h3>
        <p style="font-size:0.85rem; color:var(--muted); margin-bottom:20px;">Create a free account to save plans, get unlimited coaching adjustments, and organise your training library.</p>
        <a href="login.html" class="btn btn-primary" style="margin-right:10px;">Log In</a>
        <a href="login.html" class="btn btn-outline">Create Account</a>
      </div>

      <div id="save-modal-form" style="display:none;">
        <div class="save-modal-title">Save Plan</div>
        <div class="save-modal-subtitle">Add this training block to your library.</div>
        <div id="save-modal-error" class="save-modal-error" style="display:none;"></div>
        <div class="save-form-group">
          <label>Plan Name</label>
          <input type="text" id="save-plan-name" maxlength="80" placeholder="e.g. Spring Marathon Block" />
        </div>
        <div class="save-form-group">
          <label>Folder <span style="font-weight:400; text-transform:none; letter-spacing:0; color:var(--muted-2);">(optional)</span></label>
          <select id="save-folder-select"><option value="">No Folder</option></select>
          <span class="save-add-folder-link" id="save-toggle-new-folder">+ Create new folder</span>
          <div class="save-new-folder-row" id="save-new-folder-row" style="display:none;">
            <input type="text" id="save-new-folder-name" placeholder="Folder name..." maxlength="60" />
            <button id="save-new-folder-add">Add</button>
          </div>
        </div>
        <div class="save-modal-actions">
          <button class="save-modal-confirm" id="save-modal-confirm">Save Plan</button>
          <button class="save-modal-cancel" id="save-modal-cancel">Cancel</button>
        </div>
      </div>

      <div id="save-modal-success" class="save-modal-success" style="display:none;">
        <div class="save-modal-success-icon">&#10003;</div>
        <h3>Saved!</h3>
        <p>Your plan is in your library.</p>
        <a href="dashboard.html" class="btn btn-primary">Go to My Plans</a>
      </div>
    </div>
  </div>

  <script>
  (function () {
    if (!window._supabase) return;
    var sb = window._supabase;
    var saveBtn     = document.getElementById('save-plan-btn');
    var overlay     = document.getElementById('save-modal-overlay');
    var closeBtn    = document.getElementById('save-modal-close');
    var noAuthDiv   = document.getElementById('save-modal-no-auth');
    var formDiv     = document.getElementById('save-modal-form');
    var successDiv  = document.getElementById('save-modal-success');
    var errDiv      = document.getElementById('save-modal-error');
    var nameInput   = document.getElementById('save-plan-name');
    var folderSel   = document.getElementById('save-folder-select');
    var confirmBtn  = document.getElementById('save-modal-confirm');
    var cancelBtn   = document.getElementById('save-modal-cancel');
    var toggleNewFolder = document.getElementById('save-toggle-new-folder');
    var newFolderRow    = document.getElementById('save-new-folder-row');
    var newFolderInput  = document.getElementById('save-new-folder-name');
    var newFolderAddBtn = document.getElementById('save-new-folder-add');

    var currentUser = null;
    var userFolders = [];

    // Check auth + unlock unlimited chat
    sb.auth.getUser().then(function (r) {
      if (r.data && r.data.user) {
        currentUser = r.data.user;
        if (saveBtn) saveBtn.style.display = '';
        // Unlock unlimited adjustments
        if (typeof window._unlockUnlimitedChat === 'function') window._unlockUnlimitedChat();
      }
    });

    if (!saveBtn) return;

    function openModal() {
      overlay.style.display = 'flex';
      noAuthDiv.style.display   = 'none';
      formDiv.style.display     = 'none';
      successDiv.style.display  = 'none';
      errDiv.style.display      = 'none';

      if (!currentUser) {
        noAuthDiv.style.display = '';
        return;
      }

      // Pre-fill plan name from sessionStorage
      var raw = sessionStorage.getItem('cadentaPlan');
      if (raw) {
        try {
          var pj = JSON.parse(raw);
          nameInput.value = pj.planName || '';
        } catch(e) {}
      }

      // Load folders
      sb.from('folders').select('*').order('created_at', { ascending: true }).then(function (res) {
        userFolders = res.data || [];
        folderSel.innerHTML = '<option value="">No Folder</option>';
        userFolders.forEach(function (f) {
          var opt = document.createElement('option');
          opt.value = f.id;
          opt.textContent = f.name;
          folderSel.appendChild(opt);
        });
      });

      newFolderRow.style.display = 'none';
      formDiv.style.display = '';
      nameInput.focus();
    }

    function closeModal() { overlay.style.display = 'none'; }

    saveBtn.addEventListener('click', openModal);
    closeBtn.addEventListener('click', closeModal);
    cancelBtn.addEventListener('click', closeModal);
    overlay.addEventListener('click', function (e) { if (e.target === overlay) closeModal(); });

    // Toggle new folder input
    toggleNewFolder.addEventListener('click', function () {
      var open = newFolderRow.style.display !== 'none';
      newFolderRow.style.display = open ? 'none' : 'flex';
      toggleNewFolder.textContent = open ? '+ Create new folder' : '- Cancel';
      if (!open) newFolderInput.focus();
    });

    newFolderAddBtn.addEventListener('click', async function () {
      var name = newFolderInput.value.trim();
      if (!name) return;
      newFolderAddBtn.disabled = true;
      var { data, error } = await sb.from('folders').insert({ name: name }).select().single();
      newFolderAddBtn.disabled = false;
      if (error) { errDiv.textContent = error.message; errDiv.style.display = ''; return; }
      userFolders.push(data);
      var opt = document.createElement('option');
      opt.value = data.id; opt.textContent = data.name; opt.selected = true;
      folderSel.appendChild(opt);
      newFolderInput.value = '';
      newFolderRow.style.display = 'none';
      toggleNewFolder.textContent = '+ Create new folder';
    });

    confirmBtn.addEventListener('click', async function () {
      var name = nameInput.value.trim();
      if (!name) { errDiv.textContent = 'Please enter a plan name.'; errDiv.style.display = ''; return; }
      var raw = sessionStorage.getItem('cadentaPlan');
      if (!raw) { errDiv.textContent = 'No plan data found.'; errDiv.style.display = ''; return; }

      confirmBtn.disabled = true;
      var payload = {
        name: name,
        plan_json: JSON.parse(raw),
        folder_id: folderSel.value || null
      };
      var { error } = await sb.from('plans').insert(payload);
      confirmBtn.disabled = false;
      if (error) { errDiv.textContent = error.message; errDiv.style.display = ''; return; }
      formDiv.style.display = 'none';
      successDiv.style.display = '';
    });

  })();
  </script>
</body>
'@

$content = $content.Replace($old3, $saveModalAndScript)

# 4. Patch the alter-chat IIFE to support unlimited requests for logged-in users
$old4 = '    var MAX_REQUESTS = 3;
    var requestsLeft = MAX_REQUESTS;
    var isWaiting = false;'
$new4 = '    var MAX_REQUESTS = 3;
    var requestsLeft = MAX_REQUESTS;
    var isWaiting = false;
    var isUnlimited = false;

    // Called by save-plan script when auth resolves
    window._unlockUnlimitedChat = function () {
      isUnlimited = true;
      requestsLeft = 9999;
      var credEl = document.getElementById(''alter-credits'');
      if (credEl) credEl.style.display = ''none'';
      var introEl = document.querySelector(''.alter-intro p'');
      if (introEl) introEl.innerHTML = ''Your plan is live above. As a logged-in member you have <strong>unlimited adjustments</strong> &mdash; ask your coach anything.'';
    };'
$content = $content.Replace($old4, $new4)

# 5. Patch updateCounter to skip when unlimited
$old5 = '    function updateCounter() {
      alterCount.textContent = requestsLeft;
      alterCredits.classList.toggle(''warn'', requestsLeft === 1);
      alterCredits.classList.toggle(''empty'', requestsLeft === 0);
    }'
$new5 = '    function updateCounter() {
      if (isUnlimited) return;
      alterCount.textContent = requestsLeft;
      alterCredits.classList.toggle(''warn'', requestsLeft === 1);
      alterCredits.classList.toggle(''empty'', requestsLeft === 0);
    }'
$content = $content.Replace($old5, $new5)

# 6. Patch lockInput to skip when unlimited
$old6 = '        if (requestsLeft <= 0) {
          lockInput();
        } else {'
$new6 = '        if (requestsLeft <= 0 && !isUnlimited) {
          lockInput();
        } else {'
$content = $content.Replace($old6, $new6)

[System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
Write-Host 'Done'
