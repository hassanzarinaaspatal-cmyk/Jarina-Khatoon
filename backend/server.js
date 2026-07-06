
const express = require('express'); // ये लाइन शायद पहले से हो
const mysql = require('mysql2');    // आप अपनी ये नई लाइन यहाँ डालें

// बाकी पुराना कोड यहाँ होगा...

const connection = mysql.createConnection({
  //... आपका कनेक्शन का कोड
});

const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const patientRoutes = require('./routes/patientRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// Health check
app.get('/', (req, res) => {
  res.json({ success: true, message: 'Hasan Babu Ka Aspataal API chal raha hai.' });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/patients', patientRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route nahi mila.' });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server chal raha hai on port ${PORT}`);
});
