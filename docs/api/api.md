# OfficialAI API Documentation

## Base URL
`https://api.officialai.com/v1`

## Authentication
All authenticated endpoints require a Bearer token in the Authorization header.

## Endpoints

### 1. Auth

#### 1.1 Register
- **POST** `/auth/register`
- **Body**: `{ email, password, name }`
- **Response**: `{ token, user }`

#### 1.2 Login
- **POST** `/auth/login`
- **Body**: `{ email, password }`
- **Response**: `{ token, user }`

#### 1.3 Forgot Password
- **POST** `/auth/forgot-password`
- **Body**: `{ email }`
- **Response**: `{ message }`

### 2. Users

#### 2.1 Get Profile
- **GET** `/users/profile`
- **Auth**: Required
- **Response**: `{ id, email, name, avatarUrl }`

#### 2.2 Update Profile
- **PUT** `/users/profile`
- **Auth**: Required
- **Body**: `{ name, avatarUrl }`
- **Response**: `{ user }`

### 3. Documents

#### 3.1 Create Document
- **POST** `/documents`
- **Auth**: Required
- **Body**: `{ type, title, content, metadata }`
- **Response**: `{ document }`

#### 3.2 Get Documents
- **GET** `/documents`
- **Auth**: Required
- **Query**: `page, limit, type`
- **Response**: `{ documents, total, page, limit }`

#### 3.3 Get Document
- **GET** `/documents/:id`
- **Auth**: Required
- **Response**: `{ document }`

#### 3.4 Delete Document
- **DELETE** `/documents/:id`
- **Auth**: Required
- **Response**: `{ message }`

### 4. Favorites

#### 4.1 Add Favorite
- **POST** `/favorites`
- **Auth**: Required
- **Body**: `{ documentId }`
- **Response**: `{ favorite }`

#### 4.2 Remove Favorite
- **DELETE** `/favorites/:documentId`
- **Auth**: Required
- **Response**: `{ message }`

### 5. AI

#### 5.1 Generate Petition
- **POST** `/ai/petition`
- **Auth**: Required
- **Body**: `{ category, answers }`
- **Response**: `{ content }`

#### 5.2 Generate Email
- **POST** `/ai/email`
- **Auth**: Required
- **Body**: `{ type, tone, language, context }`
- **Response**: `{ content }`

#### 5.3 Generate CV
- **POST** `/ai/cv`
- **Auth**: Required
- **Body**: `{ personalInfo, education, experience, skills }`
- **Response**: `{ content }`

#### 5.4 Document Assistant
- **POST** `/ai/assistant`
- **Auth**: Required
- **Body**: `{ question }`
- **Response**: `{ answer }`
