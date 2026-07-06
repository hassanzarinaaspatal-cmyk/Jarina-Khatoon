const express = require('express');
const cors = require('cors');
require('dotenv').config();

// Fail-fast if JWT secret missing (helps avoid runtime 500s during login)
if (!process.env.JWT_SECRET) {
  console.error('FATAL: JWT_SECRET is not set. Please add JWT_SECRET to backend/.env');
  // process.exit(1); // uncomment to stop startup when misconfigured
}

const authRoutes = require('./routes/authRoutes');
const patientRoutes = require('./routes/patientRoutes');

const app = express();

// मिडिलवेयर
app.use(cors());
app.use(express.json());

// हेल्थ चेक
app.get('/', (req, res) => {
  res.json({ success: true, message: 'Hasan Babu Ka Aspataal API chal raha hai.' });
});

// रूट्स
app.use('/api/auth', authRoutes);
app.use('/api/patients', patientRoutes);

// सर्वर चालू करना
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
