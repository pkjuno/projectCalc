const express = require('express');
const router = express.Router();
const path = require('path');
const userController = require('../../controllers/userController');
const authMiddleware = require('../../controllers/authMiddleware');

// 회원가입 / 로그인 페이지 제공
router.get('/signup', (req, res) => {
	res.sendFile(path.join(__dirname, '..', '..', 'public', 'views', 'signup.html'));
});

router.get('/login', (req, res) => {
	res.sendFile(path.join(__dirname, '..', '..', 'public', 'views', 'login.html'));
});

// 이메일 기반 회원가입
router.post('/register-email', userController.registerByEmail);

// 이메일 중복 검사
router.post('/check-email', userController.checkEmailDuplicate);

// 통신 테스트 (DB 체크)
router.get('/check', userController.checkDatabaseConnection);

// 로그인
router.post('/login', userController.loginUser);

// 토큰 갱신
router.post('/refresh', userController.refreshToken);

// 이메일 검증 (링크 클릭)
router.get('/verify-email', userController.verifyEmail);

// 로그아웃
router.post('/logout', userController.logoutUser);

// 회원정보 수정
router.put('/update', authMiddleware, userController.updateUserInfo);

module.exports = router;
