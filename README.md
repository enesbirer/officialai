# OfficialAI

AI-powered official document assistant for Turkish users!

## Features

- AI Petition Generator
- AI Email Writer
- AI CV Builder
- Document Scanner & OCR
- PDF Generator
- Document History & Favorites
- Dark/Light Mode
- Turkish/English
- Localization
- Privacy-focused

## Screenshots

| Home Screen | Petition Generator |
|-------------|-------------------|
| [placeholder] | [placeholder]     |

## Quick Start

### Windows (One-Command Setup)

```powershell
# Start PostgreSQL
pg_ctl start -D "C:\PostgreSQL\data"

# Backend (Terminal 1)
cd backend
npm install
npx prisma generate
npx prisma migrate dev
npm run dev

# Frontend (Terminal 2)
cd frontend
flutter pub get
flutter pub run build_runner build
flutter pub run pdfx:install_web
flutter run -d chrome
```

### Installation

#### Backend
1. Navigate to `backend/`
2. Copy `env.example` to `.env` and fill in
3. `npm install`
4. `npx prisma generate && npx prisma migrate dev`
5. `npm run dev`

#### Frontend
1. Navigate to `frontend/`
2. `flutter pub get`
3. `flutter pub run build_runner build`
4. `flutter pub run pdfx:install_web` (for web)
5. `flutter run -d chrome`

## Tech Stack

### Backend
- Node.js
- Express
- TypeScript
- Prisma ORM
- PostgreSQL
- JWT
- Google Gemini

### Frontend
- Flutter
- Dart
- Riverpod
- GoRouter
- Dio

## Legal Disclaimer

**IMPORTANT**: AI-generated documents should be reviewed by the user before official submission! This app is not a law firm and does not provide legal advice!

## License

MIT
