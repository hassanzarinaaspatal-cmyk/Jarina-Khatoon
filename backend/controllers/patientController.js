const pool = require('../config/db');

// Helper: generates next HBA-XXXX id
async function generateHbaId() {
  const [rows] = await pool.query('SELECT COUNT(*) AS total FROM patients');
  const nextNumber = rows[0].total + 1;
  return 'HBA-' + String(nextNumber).padStart(4, '0');
}

// POST /api/patients
async function registerPatient(req, res) {
  try {
    const { full_name, age, gender, phone, address, guardian_name, photo_path } = req.body;

    if (!full_name) {
      return res.status(400).json({ success: false, message: 'Patient ka naam zaroori hai.' });
    }

    const hba_id = await generateHbaId();
    const registered_by = req.user ? req.user.id : null;

    const [result] = await pool.query(
      `INSERT INTO patients
        (hba_id, full_name, age, gender, phone, address, guardian_name, photo_path, registered_by)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [hba_id, full_name, age || null, gender || null, phone || null, address || null, guardian_name || null, photo_path || null, registered_by]
    );

    res.status(201).json({
      success: true,
      message: 'Patient register ho gaya.',
      patient_id: result.insertId,
      hba_id
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Server error.', error: err.message });
  }
}

// GET /api/patients
async function getAllPatients(req, res) {
  try {
    const [rows] = await pool.query('SELECT * FROM patients ORDER BY created_at DESC');
    res.json({ success: true, patients: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Server error.', error: err.message });
  }
}

// GET /api/patients/:hba_id
async function getPatientByHbaId(req, res) {
  try {
    const [rows] = await pool.query('SELECT * FROM patients WHERE hba_id = ?', [req.params.hba_id]);
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Patient nahi mila.' });
    }
    res.json({ success: true, patient: rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Server error.', error: err.message });
  }
}

// GET /api/patients/today-queue  (for reception OPD dashboard)
async function getTodayQueue(req, res) {
  try {
    const [rows] = await pool.query(
      `SELECT v.id AS visit_id, v.token_number, v.status, v.complaint,
              p.hba_id, p.full_name, p.age, p.gender, p.phone
       FROM opd_visits v
       JOIN patients p ON v.patient_id = p.id
       WHERE v.visit_date = CURDATE()
       ORDER BY v.token_number ASC`
    );
    res.json({ success: true, queue: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Server error.', error: err.message });
  }
}

module.exports = { registerPatient, getAllPatients, getPatientByHbaId, getTodayQueue };
