const express = require('express');
const router = express.Router();
const pool = require('../../config/database');

router.get('/common-codes', async (req, res) => {
  const { mst_code } = req.query;
  if (!mst_code) {
    return res.status(400).json({ message: 'mst_code 쿼리 파라미터가 필요합니다.' });
  }

  try {
    const [dtlRows] = await pool.query(
      "SELECT MST_CODE, DTL_CODE, DTL_CODE_NM FROM CODE_DTL WHERE MST_CODE = ? ORDER BY SORT_ORDER",
      [mst_code]
    );
    res.json({ details: dtlRows });
  } catch (error) {
    console.error('공통코드 조회 실패:', error);
    res.status(500).json({ message: '공통코드 조회 실패' });
  }
});


router.get('/test', (req, res) => {
  console.log("herererererererererererere");
  console.log("herererererererererererere");
  console.log("herererererererererererere");
  console.log("herererererererererererere");
  console.log("herererererererererererere");
    res.json({ message: 'API is working!' });
});

module.exports = router;
