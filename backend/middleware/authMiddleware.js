const jwt = require('jsonwebtoken');
require('dotenv').config();

// Verifies JWT token sent in Authorization header: "Bearer <token>"
function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ success: false, message: 'Token nahi mila. Login karein.' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({ success: false, message: 'Token invalid ya expire ho gaya.' });
    }
    req.user = decoded; // { id, username, role }
    next();
  });
}

// Optional: restrict route to specific roles
// usage: allowRoles('admin', 'doctor')
function allowRoles(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ success: false, message: 'Is action ki permission nahi hai.' });
    }
    next();
  };
}

module.exports = { verifyToken, allowRoles };
