const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const patientRoutes = require('./routes/patientRoutes');

const app = express();

// डेटाबेस कनेक्शन
const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT
});

// कनेक्शन चेक करना
connection.connect((err) => {
  if (err) {
    console.error('डेटाबेस जुड़ने में दिक्कत आई: ' + err.stack);
    return;
  }
  console.log('मुबारक हो! डेटाबेस से जुड़ गए हैं।');
});

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
