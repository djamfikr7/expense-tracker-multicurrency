# Contributing to Expense Tracker

First off, thank you for considering contributing to Expense Tracker! It's people like you that make this app better for emerging market users worldwide.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps which reproduce the problem**
* **Provide specific examples to demonstrate the steps**
* **Describe the behavior you observed after following the steps**
* **Explain which behavior you expected to see instead and why**
* **Include screenshots if possible**
* **Include your environment details** (OS, Flutter version, device)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a step-by-step description of the suggested enhancement**
* **Provide specific examples to demonstrate the steps**
* **Describe the current behavior and explain the behavior you expected**
* **Explain why this enhancement would be useful**

### Pull Requests

* Fill in the required template
* Follow the Dart/Flutter style guide
* Include appropriate test coverage
* Update documentation as needed
* End all files with a newline

## Development Setup

1. **Fork and clone the repo**
```bash
git clone https://github.com/your-username/expense-tracker.git
cd expense-tracker
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Create a branch**
```bash
git checkout -b feature/my-new-feature
```

4. **Make your changes**
- Write code
- Add tests
- Update documentation

5. **Test your changes**
```bash
flutter test
flutter analyze
dart format .
```

6. **Commit your changes**
```bash
git add .
git commit -m "Add some feature"
```

7. **Push and create PR**
```bash
git push origin feature/my-new-feature
```

## Styleguides

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

**Examples:**
```
feat: Add transaction editing functionality
fix: Correct currency conversion for DZD
docs: Update README with installation instructions
style: Format code according to Dart style guide
refactor: Extract currency conversion logic
test: Add tests for parallel rate calculation
chore: Update dependencies
```

### Dart Style Guide

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

* Use `lowerCamelCase` for variables, methods, parameters
* Use `UpperCamelCase` for classes, enums, typedefs
* Prefer single quotes for strings
* Use trailing commas for better diffs
* Maximum line length: 80 characters
* Use `const` constructors when possible

### Documentation

* Document all public APIs
* Use `///` for documentation comments
* Include examples in documentation
* Keep comments up to date with code changes

## Project Structure

```
lib/
├── data/         # Static data (categories)
├── models/       # Data models
├── services/     # Business logic services
└── screens/      # UI screens
```

## Testing

* Write unit tests for services
* Write widget tests for UI components
* Aim for >80% code coverage
* Test edge cases and error handling

## Currency Rate Guidelines

When working with currency features:

* Always use USD as the base for storage
* Calculate parallel rates using documented multipliers
* Test conversions thoroughly
* Document any changes to rate calculation logic
* Consider impact on existing user data

## Questions?

Feel free to open an issue with the `question` label or reach out to the maintainers.

Thank you! ❤️
