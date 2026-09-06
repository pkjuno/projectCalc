document.getElementById('signupForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const email = document.getElementById('email').value.trim();
  const password = document.getElementById('password').value;
  const nickname = document.getElementById('nickname').value.trim();
  const msgEl = document.getElementById('message');
  msgEl.textContent = '';

  const isValidEmail = (e) => {
    const re = /^[\w.%+-]+@[\w.-]+\.[A-Za-z]{2,}$/;
    return re.test(e);
  };

  const validatePassword = (pw) => {
    if (pw.length < 8) return { ok: false, message: '비밀번호는 최소 8자 이상이어야 합니다.' };
    if (pw.length > 128) return { ok: false, message: '비밀번호는 128자 이하여야 합니다.' };
    if (!/[a-z]/.test(pw)) return { ok: false, message: '비밀번호에 소문자가 필요합니다.' };
    if (!/[A-Z]/.test(pw)) return { ok: false, message: '비밀번호에 대문자가 필요합니다.' };
    if (!/[0-9]/.test(pw)) return { ok: false, message: '비밀번호에 숫자가 필요합니다.' };
    if (!/[!@#$%^&*(),.?":{}|<>\[\]\\/\\~`_+=;:'-]/.test(pw)) return { ok: false, message: '비밀번호에 특수문자가 필요합니다.' };
    return { ok: true };
  };

  if (!isValidEmail(email)) {
    msgEl.style.color = 'red';
    msgEl.textContent = '유효한 이메일을 입력해주세요.';
    return;
  }

  const pwCheck = validatePassword(password);
  if (!pwCheck.ok) {
    msgEl.style.color = 'red';
    msgEl.textContent = pwCheck.message;
    return;
  }

  try {
    const res = await fetch('/user/register-email', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, nickname })
    });

    const data = await res.json();
    if (res.ok) {
      msgEl.style.color = 'green';
      msgEl.textContent = data.message || '회원가입 성공';

      // 자동 로그인 로직(주석 처리됨) - 사용할 경우 주석 해제
      /*
      try {
        const loginRes = await fetch('/user/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ username: email, password })
        });
        const loginData = await loginRes.json();
        if (loginRes.ok && loginData.token) {
          // 예: 토큰을 localStorage에 저장하고 메인 페이지로 이동
          localStorage.setItem('token', loginData.token);
          window.location.href = '/';
          return;
        }
      } catch (e) {
        // 자동 로그인 실패 시에는 로그인 페이지로 이동
      }
      */

      // 기본 동작: 로그인 페이지로 리다이렉트
      setTimeout(() => { window.location.href = '/views/login.html'; }, 800);
    } else {
      msgEl.style.color = 'red';
      msgEl.textContent = data.message || '오류가 발생했습니다.';
    }
  } catch (err) {
    msgEl.style.color = 'red';
    msgEl.textContent = '서버에 연결할 수 없습니다.';
  }
});
