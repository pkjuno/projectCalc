const pool = require('../config/database');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const nodemailer = require('nodemailer');


/** 회원가입 */
exports.registerUser = async (req, res) => {
  try {
    const { username, password, email } = req.body;

    // 1. 입력값 유효성 검사
    if (!username || !password || !email) {
      return res.status(400).json({ message: '모든 필드를 입력해주세요.' });
    }

    // 2. 중복 사용자 검사
    const [existingUser] = await pool.query('SELECT * FROM USERS WHERE nickname = ? OR email = ?', [username, email]);
    if (existingUser.length > 0) {
      return res.status(409).json({ message: '이미 존재하는 사용자입니다.' });
    }

    // 3. 비밀번호 해싱 및 사용자 등록
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    const query = 'INSERT INTO USERS (nickname, password, email, status, created_at, updated_at) VALUES (?, ?, ?, \'ACTIVE\', NOW(), NOW())';
    await pool.query(query, [username, hashedPassword, email]);

    res.status(201).json({ message: '회원가입이 완료되었습니다.' });
  } catch (error) {
    console.error('회원가입 중 오류 발생:', error);
    res.status(500).json({ message: '서버 오류로 인해 회원가입이 실패했습니다.' });
  }
};


/** 이메일 기반 회원가입 (email, password) */
exports.registerByEmail = async (req, res) => {
  try {
    const { email, password, nickname } = req.body;

    // 입력값 검사
    if (!email || !password || !nickname) {
      return res.status(400).json({ message: '이메일, 비밀번호, 닉네임을 입력해주세요.' });
    }

    // 이메일 형식 검사
    const isValidEmail = (e) => {
      const re = /^[\w.%+-]+@[\w.-]+\.[A-Za-z]{2,}$/;
      return re.test(e);
    };

    if (!isValidEmail(email)) {
      return res.status(400).json({ message: '유효한 이메일 형식을 입력해주세요.' });
    }

    // 비밀번호 정책 검사
    const validatePassword = (pw) => {
//      if (pw.length < 8) return { ok: false, message: '비밀번호는 최소 8자 이상이어야 합니다.' };
//      if (pw.length > 128) return { ok: false, message: '비밀번호는 128자 이하여야 합니다.' };
//      if (!/[a-z]/.test(pw)) return { ok: false, message: '비밀번호에 소문자 문자가 하나 이상 포함되어야 합니다.' };
//      if (!/[A-Z]/.test(pw)) return { ok: false, message: '비밀번호에 대문자 문자가 하나 이상 포함되어야 합니다.' };
//      if (!/[0-9]/.test(pw)) return { ok: false, message: '비밀번호에 숫자가 하나 이상 포함되어야 합니다.' };
//      if (!/[!@#$%^&*(),.?":{}|<>\[\]\\/\\~`_+=;:'-]/.test(pw)) return { ok: false, message: '비밀번호에 특수문자가 하나 이상 포함되어야 합니다.' };
      return { ok: true };
    };

    const pwCheck = validatePassword(password);
    if (!pwCheck.ok) {
      return res.status(400).json({ message: pwCheck.message });
    }

    // 중복 이메일 검사
    const [existing] = await pool.query('SELECT * FROM USERS WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.status(409).json({ message: '이미 사용중인 이메일입니다.' });
    }

    // 비밀번호 해싱
    const saltRounds = 10;
    const hashed = await bcrypt.hash(password, saltRounds);

    // username 필드가 필수일 수 있어 이메일을 username으로 사용
    const paramEmail = email;
    const paramNickname = nickname || email.split('@')[0]; // 닉네임이 없으면 이메일 앞부분 사용
    const insertQuery = 'INSERT INTO USERS (email, password, nickname, status, created_at, updated_at) VALUES (?, ?, ?, \'ACTIVE\', NOW(), NOW())';
    const [insertResult] = await pool.query(insertQuery, [paramEmail, hashed, paramNickname]);
    const userId = insertResult.insertId;

    // 이메일 검증 토큰 생성 및 저장
    /*try {
      const token = crypto.randomBytes(32).toString('hex');
      const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24시간
      const verQuery = 'INSERT INTO TBL_EMAIL_VERIFICATION (user_id, token, expires_at, used, created_at) VALUES (?, ?, ?, 0, NOW())';
      await pool.query(verQuery, [userId, token, expiresAt]);

      // 검증 이메일 전송
      const baseUrl = process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`;
      const verifyLink = `${baseUrl}/user/verify-email?token=${token}`;
      await sendVerificationEmail(email, verifyLink);
    } catch (e) {
      console.error('이메일 검증 토큰 저장/전송 중 오류:', e);
      // 토큰 저장 실패 시에도 회원가입은 완료로 처리하되, 로그를 남김
    }*/

    res.status(201).json({ message: '회원가입이 완료되었습니다. 이메일을 확인해주세요.' });
  } catch (error) {
    console.error('이메일 회원가입 중 오류 발생:', error);
    res.status(500).json({ message: '서버 오류로 인해 회원가입이 실패했습니다.' });
  }
};

/** 이메일 중복 검사 */
exports.checkEmailDuplicate = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: '이메일을 입력해주세요.' });
    }

    const isValidEmail = (e) => {
      const re = /^[\w.%+-]+@[\w.-]+\.[A-Za-z]{2,}$/;
      return re.test(e);
    };

    if (!isValidEmail(email)) {
      return res.status(400).json({ message: '유효한 이메일 형식을 입력해주세요.' });
    }

    const [existing] = await pool.query('SELECT * FROM USERS WHERE email = ?', [email]);
    const exists = existing.length > 0;

    return res.status(200).json({
      exists,
      message: exists ? '이미 가입된 이메일입니다.' : '사용 가능한 이메일입니다.',
    });
  } catch (error) {
    console.error('이메일 중복 검사 중 오류 발생:', error);
    res.status(500).json({ message: '서버 오류로 인해 중복 확인에 실패했습니다.' });
  }
};


/** 이메일 전송 유틸리티 */
const sendVerificationEmail = async (toEmail, link) => {
  const host = process.env.SMTP_HOST;
  const port = process.env.SMTP_PORT;
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;

  if (!host || !user || !pass) {
    console.warn('SMTP 환경변수가 설정되어 있지 않습니다. 이메일 전송을 건너뜁니다.');
    console.log(`Verify link: ${link}`);
    return;
  }

  const transporter = nodemailer.createTransport({
    host,
    port: port ? Number(port) : undefined,
    secure: false,
    auth: { user, pass },
  });

  const info = await transporter.sendMail({
    from: process.env.SMTP_FROM || user,
    to: toEmail,
    subject: '이메일 인증을 완료해주세요',
    html: `<p>회원가입을 위해 아래 링크를 클릭하세요:</p><p><a href="${link}">${link}</a></p>`
  });
  console.log('Verification email sent:', info.messageId);
};



/** 로그인 */
exports.loginUser = async (req, res) => {
  try {
    const { username, password } = req.body;

    // 1. 입력값 유효성 검사
    if (!username || !password) {
      return res.status(400).json({ message: '모든 필드를 입력해주세요.' });
    }

    // 2. 사용자 조회 (이메일로만 조회)
    // 비밀번호는 DB에서 직접 비교하지 않고 해시된 비밀번호와 bcrypt.compare로 검증합니다.
    const [rows] = await pool.query('SELECT * FROM USERS WHERE email = ?', [username]);
      
    if (rows.length === 0) {
      return res.status(401).json({ message: '아이디 또는 비밀번호가 잘못되었습니다.' });
    }

    const userRow = rows[0];
    const match = await bcrypt.compare(password, userRow.password);
    if (!match) {
      return res.status(401).json({ message: '아이디 또는 비밀번호가 잘못되었습니다.' });
    }

    // 3. 로그인 성공 - Access & Refresh Token 발급
    const accessToken = generateAccessToken(userRow);
    const refreshToken = generateRefreshToken(userRow);

    // 4. Refresh Token을 DB에 저장
    await pool.query('UPDATE USERS SET refresh_token = ? WHERE id = ?', [refreshToken, userRow.id]);

    const safeUser = { ...userRow };
    if (safeUser.password) delete safeUser.password;
    if (safeUser.refresh_token) delete safeUser.refresh_token;

    res.status(200).json({ 
      message: '로그인이 성공했습니다.', 
      user: safeUser, 
      accessToken, 
      refreshToken 
    });
  } catch (error) {
    console.error('로그인 중 오류 발생:', error);
    res.status(500).json({ message: '서버 오류로 인해 로그인이 실패했습니다.' });
  }
};


/** Access Token 생성 (짧은 수명) */
const generateAccessToken = (user) => {
  return jwt.sign(
    { nickname: user.nickname, userId: user.id },
    process.env.JWT_SECRET || 'access_secret',
    { expiresIn: '1h' }
  );
};

/** Refresh Token 생성 (긴 수명) */
const generateRefreshToken = (user) => {
  return jwt.sign(
    { userId: user.id },
    process.env.JWT_REFRESH_SECRET || 'refresh_secret',
    { expiresIn: '14d' }
  );
};

/** 토큰 갱신 (Refresh Token 활용) */
exports.refreshToken = async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return res.status(401).json({ message: 'Refresh Token이 필요합니다.' });
  }

  try {
    // 1. Refresh Token 검증
    const secret = process.env.JWT_REFRESH_SECRET || 'refresh_secret';
    const decoded = jwt.verify(refreshToken, secret);

    // 2. DB에 저장된 토큰과 일치하는지 확인
    const [rows] = await pool.query('SELECT * FROM USERS WHERE id = ? AND refresh_token = ?', [decoded.userId, refreshToken]);
    
    if (rows.length === 0) {
      return res.status(403).json({ message: '유효하지 않은 Refresh Token입니다.' });
    }

    // 3. 새로운 Access Token 발급
    const user = rows[0];
    const newAccessToken = generateAccessToken(user);

    res.status(200).json({ accessToken: newAccessToken });
  } catch (error) {
    console.error('Token Refresh Error:', error);
    res.status(403).json({ message: 'Refresh Token이 만료되었거나 유효하지 않습니다.' });
  }
};


/** 이메일 검증 처리 */
exports.verifyEmail = async (req, res) => {
  try {
    const { token } = req.query;
    if (!token) return res.status(400).send('<h3>유효하지 않은 요청입니다.</h3>');

    const [rows] = await pool.query('SELECT * FROM TBL_EMAIL_VERIFICATION WHERE token = ?', [token]);
    if (rows.length === 0) return res.status(400).send('<h3>토큰을 찾을 수 없습니다.</h3>');

    const rec = rows[0];
    const now = new Date();
    if (rec.used) return res.status(400).send('<h3>이미 인증된 토큰입니다.</h3>');
    if (rec.expires_at && new Date(rec.expires_at) < now) return res.status(400).send('<h3>토큰이 만료되었습니다.</h3>');

    // 사용자 이메일 인증 상태 업데이트 (컬럼이 없을 경우 에러가 발생할 수 있음)
    try {
      await pool.query('UPDATE USERS SET email_verified = 1 WHERE id = ?', [rec.user_id]);
    } catch (e) {
      console.warn('email_verified 컬럼 업데이트 실패(컬럼이 없을 수 있음):', e.message);
    }

    // 토큰 사용 처리
    await pool.query('UPDATE TBL_EMAIL_VERIFICATION SET used = 1, used_at = NOW() WHERE id = ?', [rec.id]);

    res.send('<h3>이메일 인증이 완료되었습니다. 로그인하세요.</h3>');
  } catch (e) {
    console.error('이메일 검증 처리 중 오류:', e);
    res.status(500).send('<h3>서버 오류가 발생했습니다.</h3>');
  }
};

/** 로그아웃 */
exports.logoutUser = async (req, res) => {
  try {
    // 로그아웃 로직 구현
    res.status(200).json({ message: '로그아웃이 성공했습니다.' });
  } catch (error) {
    console.error('로그아웃 중 오류 발생:', error);
    res.status(500).json({ message: '서버 오류로 인해 로그아웃이 실패했습니다.' });
  }
};

/** 회원정보 수정 */
exports.updateUserInfo = async (req, res) => {
  try {
    const { username, password, email } = req.body;

    // 1. 입력값 유효성 검사
    if (!username || !password || !email) {
      return res.status(400).json({ message: '모든 필드를 입력해주세요.' });
    }

    // 2. 사용자 정보 업데이트
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    const query = 'UPDATE USERS SET password = ?, email = ?, updated_at = NOW() WHERE nickname = ?';
    await pool.query(query, [hashedPassword, email, username]);

    res.status(200).json({ message: '회원정보가 성공적으로 수정되었습니다.' });
  } catch (error) {
    console.error('회원정보 수정 중 오류 발생:', error);
    res.status(500).json({ message: '서버 오류로 인해 회원정보 수정이 실패했습니다.' });
  }
};

/** 회원 탈퇴 */

/** 통신 테스트 (DB 체크) */
exports.checkDatabaseConnection = async (req, res) => {
  try {
    console.log("DB 연결 테스트 시작");
    const [rows] = await pool.query('SELECT * FROM USERS');
    res.status(200).json({ message: '통신 성공', count: rows.length });
  } catch (error) {
    console.error('통신 테스트 중 오류 발생:', error);
    res.status(500).json({ message: '통신 실패', error: error.message });
  }
};

/** 회원 정보 조회 */
