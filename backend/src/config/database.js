const mysql = require('mysql2/promise'); // # async/await 사용을 위해 promise 버전을 로드한다.
const dotenv = require('dotenv');  // # db 설정파일을 읽는다

dotenv.config();

// # 커넥션 풀 생성
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
  waitForConnections: true,
  connectionLimit: parseInt(process.env.DB_CONNECTION_LIMIT) || 10,
  queueLimit: 0
});

// # 연결 테스트용 함수 ( 서버 실행시 확인용 )
const testConnection = async () => {
  try {
    const connection = await pool.getConnection();  
    console.log('데이터베이스 연결 성공');
    connection.release();
    } catch (error) {
    console.error('데이터베이스 연결 실패:', error);
  }
};

testConnection();

// # 모듈 익스포트  app.js에서 불러옴
module.exports = pool;