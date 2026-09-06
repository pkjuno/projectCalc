const express = require('express');
const router = express.Router();
const pool = require('../../config/database');

router.get('/common-codes', async (req, res) => {
  try {
    const [mstRows] = await pool.query(
      'SELECT mst_code, mst_code_nm, description, use_yn, created_at, updated_at FROM code_mst ORDER BY created_at DESC'
    );
    const [dtlRows] = await pool.query(
      'SELECT mst_code, dtl_code, dtl_code_nm, sort_order, use_yn, created_at, updated_at FROM code_dtl ORDER BY mst_code, sort_order, dtl_code'
    );

    res.json({ masters: mstRows, details: dtlRows });
  } catch (error) {
    console.error('공통코드 조회 실패:', error);
    res.status(500).json({ message: '공통코드 조회 실패' });
  }
});

router.post('/common-codes', async (req, res) => {
  const { mstCode, mstCodeNm, description, useYn, details, detailCode, detailCodeNm, sortOrder, editingMstCode } = req.body;

  if (!mstCode || !mstCodeNm || !description) {
    return res.status(400).json({ message: '마스터 코드의 필수값이 누락되었습니다.' });
  }

  const detailList = Array.isArray(details)
    ? details
    : (detailCode || detailCodeNm ? [{ detailCode, detailCodeNm, sortOrder }] : []);

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const createdAt = new Date();
    await connection.query(
      `INSERT INTO code_mst (mst_code, mst_code_nm, description, use_yn, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE mst_code_nm = VALUES(mst_code_nm), description = VALUES(description), use_yn = VALUES(use_yn), updated_at = VALUES(updated_at)`,
      [mstCode, mstCodeNm, description, useYn || 'Y', createdAt, createdAt]
    );

    if (editingMstCode && editingMstCode !== mstCode) {
      await connection.query('DELETE FROM code_dtl WHERE mst_code = ?', [editingMstCode]);
    }

    if (editingMstCode) {
      await connection.query('DELETE FROM code_dtl WHERE mst_code = ?', [mstCode]);
    }

    for (const item of detailList) {
      if (!item || (!item.detailCode && !item.detailCodeNm)) {
        continue;
      }

      await connection.query(
        `INSERT INTO code_dtl (mst_code, dtl_code, dtl_code_nm, sort_order, use_yn, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE dtl_code_nm = VALUES(dtl_code_nm), sort_order = VALUES(sort_order), use_yn = VALUES(use_yn), updated_at = VALUES(updated_at)`,
        [mstCode, item.detailCode, item.detailCodeNm, item.sortOrder || 0, 'Y', createdAt, createdAt]
      );
    }

    await connection.commit();
    res.status(201).json({ message: '공통코드가 저장되었습니다.' });
  } catch (error) {
    await connection.rollback();
    console.error('공통코드 저장 실패:', error);
    res.status(500).json({ message: '공통코드 저장 실패' });
  } finally {
    connection.release();
  }
});

router.delete('/common-codes/:mstCode', async (req, res) => {
  const { mstCode } = req.params;
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();
    await connection.query('DELETE FROM code_dtl WHERE mst_code = ?', [mstCode]);
    await connection.query('DELETE FROM code_mst WHERE mst_code = ?', [mstCode]);
    await connection.commit();
    res.json({ message: '공통코드가 삭제되었습니다.' });
  } catch (error) {
    await connection.rollback();
    console.error('공통코드 삭제 실패:', error);
    res.status(500).json({ message: '공통코드 삭제 실패' });
  } finally {
    connection.release();
  }
});

module.exports = router;
