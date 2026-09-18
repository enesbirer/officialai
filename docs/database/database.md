# OfficialAI Database Documentation

## 1. Overview
PostgreSQL database with Prisma ORM, using UUIDs as primary keys for scalability.

## 2. ER Diagram (Mermaid)

```mermaid
erDiagram
    USER {
        uuid id PK
        string email
        string password_hash
        string name
        string avatar_url
        timestamp created_at
        timestamp updated_at
    }
    
    DOCUMENT {
        uuid id PK
        uuid user_id FK
        string type
        string title
        text content
        json metadata
        boolean is_favorite
        timestamp created_at
        timestamp updated_at
    }
    
    FAVORITE {
        uuid id PK
        uuid user_id FK
        uuid document_id FK
        timestamp created_at
    }
    
    TEMPLATE {
        uuid id PK
        string category
        string name
        string description
        json structure
        boolean is_active
        timestamp created_at
    }
    
    USER ||--o{ DOCUMENT : creates
    USER ||--o{ FAVORITE : has
    DOCUMENT ||--o{ FAVORITE : is_favorited
```

## 3. Tables

### 3.1 users
| Column           | Type      | Constraints               |
|-------------------|-----------|---------------------------|
| id                | UUID      | Primary Key               |
| email             | VARCHAR   | Unique, Not Null          |
| password_hash     | VARCHAR   | Not Null                  |
| name              | VARCHAR   | Not Null                  |
| avatar_url        | VARCHAR   | Nullable                  |
| created_at        | TIMESTAMP | Default: NOW()            |
| updated_at        | TIMESTAMP | Default: NOW()            |

### 3.2 documents
| Column           | Type      | Constraints               |
|-------------------|-----------|---------------------------|
| id                | UUID      | Primary Key               |
| user_id           | UUID      | Foreign Key to users.id   |
| type              | VARCHAR   | Not Null                  |
| title             | VARCHAR   | Not Null                  |
| content           | TEXT      | Not Null                  |
| metadata          | JSONB     | Nullable                  |
| is_favorite       | BOOLEAN   | Default: FALSE            |
| created_at        | TIMESTAMP | Default: NOW()            |
| updated_at        | TIMESTAMP | Default: NOW()            |

### 3.3 favorites
| Column           | Type      | Constraints               |
|-------------------|-----------|---------------------------|
| id                | UUID      | Primary Key               |
| user_id           | UUID      | Foreign Key to users.id   |
| document_id       | UUID      | Foreign Key to documents.id |
| created_at        | TIMESTAMP | Default: NOW()            |

### 3.4 templates
| Column           | Type      | Constraints               |
|-------------------|-----------|---------------------------|
| id                | UUID      | Primary Key               |
| category          | VARCHAR   | Not Null                  |
| name              | VARCHAR   | Not Null                  |
| description       | TEXT      | Nullable                  |
| structure         | JSONB     | Not Null                  |
| is_active         | BOOLEAN   | Default: TRUE             |
| created_at        | TIMESTAMP | Default: NOW()            |
