# OfficialAI Architecture Documentation

## 1. Overview
OfficialAI is a production-ready AI-powered mobile assistant for Turkish users. Built using Clean Architecture, SOLID Principles, and MVVM patterns.

## 2. Tech Stack

### 2.1 Frontend (Mobile)
- **Framework**: Flutter (Latest Stable)
- **Language**: Dart
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Networking**: Dio
- **Local Storage**: Hive
- **Secure Storage**: flutter_secure_storage
- **Authentication**: Firebase Authentication
- **PDF Generation**: pdf
- **Printing**: printing
- **OCR**: Google ML Kit

### 2.2 Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Authentication**: JWT
- **ORM**: Prisma ORM
- **AI Integration**: Google Gemini API

### 2.3 Database
- **Database**: PostgreSQL (Hosted on Neon)

### 2.4 Infrastructure
- **Image Storage**: Cloudinary
- **Hosting**: Railway
- **CI/CD**: GitHub Actions

## 3. Architecture Principles
- **Clean Architecture**
- **SOLID Principles**
- **MVVM (Model-View-ViewModel)**
- **Repository Pattern**
- **Dependency Injection**

## 4. Frontend Project Structure
```
frontend/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── usecases/
│   │   ├── utils/
│   │   └── theme/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       ├── widgets/
│   │   │       └── providers/
│   │   ├── home/
│   │   ├── chat/
│   │   ├── petition/
│   │   ├── email/
│   │   ├── cv/
│   │   ├── documents/
│   │   ├── history/
│   │   ├── favorites/
│   │   ├── profile/
│   │   └── settings/
│   ├── injection_container.dart
│   └── main.dart
├── test/
└── assets/
```

## 5. Backend Project Structure
```
backend/
├── prisma/
│   └── schema.prisma
├── src/
│   ├── config/
│   ├── controllers/
│   ├── middlewares/
│   ├── models/
│   ├── routes/
│   ├── services/
│   ├── utils/
│   └── app.ts
├── test/
└── package.json
```
