const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');
require('dotenv').config();

// ============================================================
// POST /api/auth/register
// Kisi bhi role ka naya user banane ke liye (Doctor/Reception/Pharmacy/Admin)
// ============================================================
async function register(req, res) {
  try {
    const { full_name, username, password, role, phone } = req.body;

    if (!full_name || !username || !password || !role) {
      return res.status(400).json({ 
        success: false, 
        message: 'Saari zaroori fields bharein.' 
      });
    }

    const validRoles = ['doctor', 'reception', 'pharmacy', 'admin'];
    if (!validRoles.includes(role)) {
      return res.status(400).json({ 
        success: false, 
        message: 'Role invalid hai. Valid roles: doctor, reception, pharmacy, admin' 
      });
    }

    // Check if username already exists
    const [existing] = await pool.query('SELECT id FROM users WHERE username = ?', [username]);
    if (existing.length > 0) {
      return res.status(409).json({ 
        success: false, 
        message: 'Ye username pehle se maujood hai.' 
      });
    }

    // Hash password
    const password_hash = await bcrypt.hash(password, 10);

    // Insert new user
    const [result] = await pool.query(
      'INSERT INTO users (full_name, username, password_hash, role, phone, is_active, created_at) VALUES (?, ?, ?, ?, ?, TRUE, NOW())',
      [full_name, username, password_hash, role, phone || null]
    );

    console.log(`✅ User registered: ${username} (Role: ${role})`);

    res.status(201).json({
      success: true,
      message: 'User successfully register ho gaya.',
      user_id: result.insertId,
      user: {
        id: result.insertId,
        full_name,
        username,
        role
      }
    });
  } catch (err) {
    console.error('❌ Register error:', err);
    res.status(500).json({ 
      success: false, 
      message: 'Server error - registration fail ho gaya.',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
}

// ============================================================
// POST /api/auth/login
// Sabhi roles (doctor, reception, pharmacy, admin) isi ek endpoint se login karte hain
// ============================================================
async function login(req, res) {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Username aur password dono chahiye.' 
      });
    }

    console.log(`🔐 Login attempt: ${username}`);

    // Find user
    const [rows] = await pool.query(
      'SELECT * FROM users WHERE username = ? AND is_active = TRUE',
      [username]
    );

    if (rows.length === 0) {
      console.log(`❌ User not found: ${username}`);
      return res.status(401).json({ 
        success: false, 
        message: 'User nahi mila ya account inactive hai.' 
      });
    }

    const user = rows[0];

    // Verify password
    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      console.log(`❌ Wrong password for: ${username}`);
      return res.status(401).json({ 
        success: false, 
        message: 'Password galat hai.' 
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { 
        id: user.id, 
        username: user.username, 
        role: user.role, 
        full_name: user.full_name 
      },
      process.env.JWT_SECRET || 'your-secret-key-change-this',
      { expiresIn: process.env.JWT_EXPIRES_IN || '12h' }
    );

    console.log(`✅ Login successful: ${username} (Role: ${user.role})`);

    res.status(200).json({
      success: true,
      message: 'Login safal raha.',
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        username: user.username,
        role: user.role
      }
    });
  } catch (err) {
    console.error('❌ Login error:', err);
    res.status(500).json({ 
      success: false, 
      message: 'Server error - login fail ho gaya.',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
}

module.exports = { register, login };
