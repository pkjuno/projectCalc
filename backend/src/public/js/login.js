document.getElementById('loginForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const username = document.getElementById('username').value.trim();
  const password = document.getElementById('password').value;
  const msgEl = document.getElementById('message');
  msgEl.textContent = '';

  try {
    const res = await fetch('/user/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password })
    });

    const data = await res.json();
    if (res.ok) {
      // 성공 시 토큰 저장 및 리다이렉트 (필요 시 쿠키로 변경)
      if (data.token) {
        localStorage.setItem('token', data.token);
      }
      msgEl.style.color = 'green';
      msgEl.textContent = data.message || '로그인 성공';
      setTimeout(() => { window.location.href = '/'; }, 600);
    } else {
      msgEl.style.color = 'red';
      msgEl.textContent = data.message || '로그인 실패';
    }
  } catch (err) {
    msgEl.style.color = 'red';
    msgEl.textContent = '서버에 연결할 수 없습니다.';
  }
});
