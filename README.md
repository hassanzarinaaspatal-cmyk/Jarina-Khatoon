# हसन बाबू का अस्पताल — Clinic Management System

3 parts hain: **database**, **backend** (Node.js/Express), aur **mobile_app** (Flutter).

## 1. Database Setup (MySQL)
```bash
mysql -u root -p < database/schema.sql
```
Ye `hasan_babu_clinic` naam ka database aur saari tables bana dega (users, patients, opd_visits, medicines).

## 2. Backend Setup
```bash
cd backend
npm install
cp .env.example .env
# .env file kholkar apna MySQL password aur JWT_SECRET bharein
npm start
```
Server `http://localhost:5000` pe chalega. Deploy karne ke liye (Railway, Render, ya apna VPS) same steps follow karein, bas `.env` me production DB credentials daalein.

Pehla admin user banane ke liye Postman/curl se:
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"full_name":"Admin","username":"admin","password":"admin123","role":"admin"}'
```
Isi tarah doctor, reception, pharmacy role ke users bhi bana sakte hain — role field me sirf ye 4 values chalengi: `doctor`, `reception`, `pharmacy`, `admin`.

## 3. Mobile App Setup (Flutter)
```bash
cd mobile_app
flutter pub get
```
`lib/config/api_config.dart` file me apna deployed backend URL daalein:
```dart
static const String baseUrl = "https://your-actual-server.com/api";
```
Phir:
```bash
flutter run
```

## Login
Ek hi login screen hai — Doctor, Reception, Pharmacy, Admin sabhi apne username/password se login karte hain. App role ke hisaab se aage dashboard dikhayega (abhi Reception Dashboard ready hai; Doctor/Pharmacy dashboards isi pattern pe add ho sakte hain).

## Ab tak kya bana hai
- Login (JWT-based, sabhi roles)
- Patient registration (auto HBA-XXXX ID)
- Reception dashboard + aaj ki OPD queue

## Aage kya add ho sakta hai
- Doctor dashboard (diagnosis/prescription likhna)
- Pharmacy dashboard (medicine stock, sale)
- Admin dashboard (user management, reports)
- Photo upload (prescription/patient photo)
- Offline sync agar internet na ho
