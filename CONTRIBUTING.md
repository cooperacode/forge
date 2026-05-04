# Contributing to wiki-wonka

Thank you for your interest in contributing to this project!

## Branching Model: Gitflow

We use the **Gitflow** workflow to manage development. Please follow these guidelines:

### Main Branches
- **main**: Always production-ready. Only stable, released code is merged here.
- **develop**: Integration branch for features. All completed features and fixes are merged here before release.

### Supporting Branches
- **feature/**: For new features. Branch off from `develop`.
- **hotfix/**: For urgent fixes to `main`. Branch off from `main`.
- **release/**: For preparing a new production release. Branch off from `develop`.
- **bugfix/**: For non-urgent bug fixes. Branch off from `develop`.

### Typical Workflow
1. **Fork** the repository and clone your fork.
2. Create a branch:
   - For features: `git checkout -b feature/your-feature-name develop`
   - For bugfixes: `git checkout -b bugfix/your-bug-description develop`
   - For hotfixes: `git checkout -b hotfix/your-hotfix-description main`
3. Make your changes and commit with clear messages.
4. Push your branch and open a Pull Request (PR) against the appropriate branch (`develop` for features/bugfixes, `main` for hotfixes).
5. Wait for review and feedback.

### Code Style & Best Practices
- Follow the existing code style and conventions.
- Write clear, descriptive commit messages.
- Add or update documentation as needed.
- Ensure all tests pass before submitting a PR.

### Questions?
If you have any questions, open an issue or start a discussion.

Thank you for helping make wiki-wonka better!
