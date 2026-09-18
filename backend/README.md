# OfficialAI Backend

Production-ready AI-powered official document assistant backend.

## Tech Stack
- Node.js, Express, TypeScript
- Prisma ORM, PostgreSQL
- JWT, Firebase Auth
- Google Gemini AI
- Cloudinary
- Helmet, CORS, Rate Limiting

## Installation
1. Copy .env.example to .env and fill in all required variables
2. Install dependencies: npm install
3. Run database migrations: npx prisma migrate dev
4. Generate Prisma client: npx prisma generate
5. Start server: npm run dev

## API Endpoints

### Auth
- POST /api/v1/auth/register
- POST /api/v1/auth/login
- POST /api/v1/auth/refresh
- POST /api/v1/auth/logout

### AI
- POST /api/v1/ai/petition
- POST /api/v1/ai/email
- POST /api/v1/ai/cv

### Users
- GET /api/v1/users/profile
- PUT /api/v1/users/profile

## Project Structure
```
backend/
├── prisma/
├── src/
│   ├── ai/
│   ├── config/
│   ├── constants/
│   ├── controllers/
│   ├── middlewares/
│   ├── prompts/
│   ├── repositories/
│   ├── routes/
│   ├── services/
│   ├── types/
│   ├── utils/
│   ├── app.ts
│   └── server.ts
├── tests/
└── package.json
```
