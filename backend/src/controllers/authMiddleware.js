const jwt = require('jsonwebtoken');

/** JWT 토큰 인증 미들웨어 */
const authMiddleware = (req, res, next) => {
  // 1. 헤더에서 토큰 추출 (Bearer TOKEN)
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: '인증 토큰이 없습니다. 로그인이 필요합니다.' });
  }

  // 2. 토큰 검증
  const secret = process.env.JWT_SECRET || 'change_this_secret';
  jwt.verify(token, secret, (err, decoded) => {
    if (err) {
      return res.status(403).json({ message: '유효하지 않거나 만료된 토큰입니다.' });
    }
    // 3. 검증된 사용자 정보를 req.user에 저장하여 다음 로직에서 사용 가능하게 함
    req.user = decoded;
    next();
  });
};

module.exports = authMiddleware;