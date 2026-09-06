const express   = require('express');
const cors      = require('cors');
const path      = require('path');

const database  = require('./config/database');  // # db모듈 불러오기 

const dotenv    = require('dotenv');

// # 1. 환경 변수 로드 (.env 파일 읽기). 시스템 전역 메모리에 올리기 위해 최 상단에서 실행
dotenv.config();

const app   = express();
const PORT  = process.env.PORT || 3000;

// # 2. 미들웨어 설정
app.use(cors());
app.use(express.json());

// # 3. 라우터 설정
const userRoute       = require('./routes/userRoutes/userRoute');
const commonCodeRoute = require('./routes/adminRoutes/commonCodeRoute');
const codeRoutes      = require('./routes/userRoutes/codeRoutes');

app.use('/user', userRoute);
app.use('/admin', commonCodeRoute);

app.get('/api', (req, res) => {
  res.json({ message: 'API is working!' });
});

app.use('/api', codeRoutes); // /api 경로로 들어오는 요청을 codeRoutes로 전달

// 루트 레벨 접근을 위해 /signup, /login으로 들어오면 userRoute로 리다이렉트
app.get('/signup', (req, res) => res.redirect('/user/signup'));
app.get('/login', (req, res) => res.redirect('/user/login'));

app.get('/admin', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'views', 'admin', 'index.html'));
});

app.get('/admin/common-code', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'views', 'admin', 'common-code.html'));
});

// API 라우트들이 먼저 처리된 후, 일치하는 라우트가 없을 때 static 파일들을 서비스하도록 미들웨어 순서를 조정합니다.
app.use(express.static(path.join(__dirname, 'public')));

// # 4. 서버 시작 (listen)
app.listen(PORT, () => {
  console.log(`Server is running on all interfaces at port ${PORT}`);
});
