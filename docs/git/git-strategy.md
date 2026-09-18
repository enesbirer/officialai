# OfficialAI Git Strategy

## 1. Branch Strategy (Git Flow)

### Main Branches
- **main**: Production-ready code (stable)
- **develop**: Integration branch for features

### Supporting Branches
- **feature/***: New features (branched from develop)
- **hotfix/***: Critical bug fixes (branched from main)
- **release/***: Preparing releases (branched from develop)

## 2. Commit Rules (Conventional Commits)

### Commit Message Format
```
<type>(<scope>): <subject>
```

### Type Options
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes
- **refactor**: Refactoring code
- **test**: Testing changes
- **chore**: Build/tooling changes

### Examples
- `feat(auth): add login with email and password`
- `fix(home): resolve dashboard loading issue`
- `docs(architecture): update folder structure`

## 3. Pull Request Guidelines
- All PRs must be reviewed
- PRs must pass CI/CD checks
- PRs should be small and focused
