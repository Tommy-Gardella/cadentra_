$file = 'C:\Users\bigto\cadentra\how-it-works.html'
$content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

$startIdx = $content.LastIndexOf('  <script>')
$endIdx   = $content.LastIndexOf('  </script>') + '  </script>'.Length

$before = $content.Substring(0, $startIdx)
$after  = $content.Substring($endIdx)

$newScript = @'
  <script>
  (function () {
    var q1 = null;
    var q2 = null;
    var q3 = [];

    var generateBtn = document.getElementById('builder-generate-btn');
    var hintEl      = document.getElementById('builder-hint');
    var chatWrapper = document.getElementById('ai-chat-wrapper');
    var messagesEl  = document.getElementById('ai-chat-messages');
    var inputEl     = document.getElementById('ai-chat-input');
    var sendBtn     = document.getElementById('ai-chat-send');
    var resetBtn    = document.getElementById('ai-reset');

    var conversationHistory = [];
    var isWaiting = false;
    var chatStarted = false;

    document.querySelectorAll('.distance-badge.selectable').forEach(function(badge) {
      badge.addEventListener('click', function() {
        document.querySelectorAll('.distance-badge.selectable').forEach(function(b) { b.classList.remove('selected'); });
        badge.classList.add('selected');
        q1 = badge.getAttribute('data-value');
        updateBtn();
      });
    });

    document.querySelectorAll('#q2-mileage .option-badge').forEach(function(badge) {
      badge.addEventListener('click', function() {
        document.querySelectorAll('#q2-mileage .option-badge').forEach(function(b) { b.classList.remove('selected'); });
        badge.classList.add('selected');
        q2 = badge.getAttribute('data-value');
        updateBtn();
      });
    });

    document.querySelectorAll('#q3-workouts .option-badge').forEach(function(badge) {
      badge.addEventListener('click', function() {
        badge.classList.toggle('selected');
        var val = badge.getAttribute('data-value');
        if (badge.classList.contains('selected')) {
          q3.push(val);
        } else {
          q3 = q3.filter(function(v) { return v !== val; });
        }
      });
    });

    function updateBtn() {
      var ready = q1 && q2;
      generateBtn.disabled = !ready;
      hintEl.textContent = ready
        ? 'Ready! Click Build My Plan to generate your training block.'
        : 'Select your race distance and weekly mileage to continue';
    }

    generateBtn.addEventListener('click', function() {
      if (!q1 || !q2) return;
      chatWrapper.style.display = 'block';
      chatWrapper.scrollIntoView({ behavior: 'smooth', block: 'start' });
      if (!chatStarted) {
        chatStarted = true;
        var workoutStr = q3.length > 0 ? q3.join(', ') : 'no specific preference';
        var openingMsg = 'I am training for a ' + q1 + '. I currently run ' + q2 + '. My favourite workouts are: ' + workoutStr + '. Please build me a full training plan.';
        sendMessage(openingMsg);
      }
    });

    resetBtn && resetBtn.addEventListener('click', function() {
      conversationHistory = [];
      messagesEl.innerHTML = '';
      chatWrapper.style.display = 'none';
      chatStarted = false;
      q1 = null; q2 = null; q3 = [];
      document.querySelectorAll('.selectable.selected, .option-badge.selected').forEach(function(b) { b.classList.remove('selected'); });
      generateBtn.disabled = true;
      hintEl.textContent = 'Select your race distance and weekly mileage to continue';
      var section = document.getElementById('training-block-builder');
      if (section) window.scrollTo({ top: section.offsetTop - 80, behavior: 'smooth' });
    });

    function scrollToBottom() { messagesEl.scrollTop = messagesEl.scrollHeight; }

    function addMessage(role, text) {
      var isPlan = role === 'coach' && text.indexOf('CADENTRA TRAINING PLAN') > -1;
      var wrapper = document.createElement('div');
      wrapper.className = 'ai-msg ' + (role === 'user' ? 'ai-msg-user' : (isPlan ? 'ai-msg-plan' : 'ai-msg-coach'));
      var sender = document.createElement('div');
      sender.className = 'ai-msg-sender';
      sender.textContent = role === 'user' ? 'You' : 'Cadentra Coach';
      var bubble = document.createElement('div');
      bubble.className = 'ai-msg-bubble';
      bubble.textContent = text;
      wrapper.appendChild(sender);
      wrapper.appendChild(bubble);
      messagesEl.appendChild(wrapper);
      scrollToBottom();
    }

    function showTyping() {
      var el = document.createElement('div');
      el.className = 'ai-typing';
      el.id = 'ai-typing-indicator';
      el.innerHTML = '<span></span><span></span><span></span>';
      messagesEl.appendChild(el);
      scrollToBottom();
    }

    function removeTyping() {
      var el = document.getElementById('ai-typing-indicator');
      if (el) el.remove();
    }

    function setInputEnabled(enabled) {
      if (inputEl) inputEl.disabled = !enabled;
      if (sendBtn) sendBtn.disabled = !enabled;
      if (enabled && inputEl) inputEl.focus();
    }

    function sendMessage(userText) {
      if (isWaiting) return;
      isWaiting = true;
      setInputEnabled(false);
      if (userText) {
        conversationHistory.push({ role: 'user', content: userText });
        addMessage('user', userText);
      }
      showTyping();
      fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ messages: conversationHistory })
      })
      .then(function(res) {
        removeTyping();
        if (!res.ok) {
          addMessage('coach', 'Something went wrong. Please try again.');
          isWaiting = false; setInputEnabled(true); return null;
        }
        return res.json();
      })
      .then(function(data) {
        if (!data) return;
        var reply = data.reply;
        conversationHistory.push({ role: 'assistant', content: reply });
        var calMatch = reply.match(/\[CALENDAR_DATA\]([\s\S]*?)\[\/CALENDAR_DATA\]/);
        if (calMatch) {
          try {
            var planData = JSON.parse(calMatch[1].trim());
            sessionStorage.setItem('cadentaPlan', JSON.stringify(planData));
            addMessage('coach', 'Your training plan is ready! Building your calendar now...');
            setTimeout(function() { window.location.href = 'plan.html'; }, 1800);
          } catch(e) {
            addMessage('coach', reply.replace(/\[CALENDAR_DATA\][\s\S]*?\[\/CALENDAR_DATA\]/, '').trim());
          }
        } else {
          addMessage('coach', reply);
        }
        isWaiting = false; setInputEnabled(true);
      })
      .catch(function() {
        removeTyping();
        addMessage('coach', 'Connection error. Please try again.');
        isWaiting = false; setInputEnabled(true);
      });
    }

    sendBtn && sendBtn.addEventListener('click', function() {
      var text = inputEl.value.trim();
      if (!text || isWaiting) return;
      inputEl.value = ''; sendMessage(text);
    });

    inputEl && inputEl.addEventListener('keydown', function(e) {
      if (e.key === 'Enter') {
        var text = inputEl.value.trim();
        if (!text || isWaiting) return;
        inputEl.value = ''; sendMessage(text);
      }
    });

  })();
  </script>
'@

$newContent = $before + $newScript + $after
[System.IO.File]::WriteAllText($file, $newContent, [System.Text.Encoding]::UTF8)
Write-Host 'Done'
