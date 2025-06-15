# GitHub Copilot Instructions for Kisaan Mithraa Agricultural App

## Project Context
You are assisting with Kisaan Mithraa, a Flutter-based agricultural assistance app for Indian farmers. The app features AI chatbot, weather integration, marketplace, emergency contacts, and multi-language support (English, Hindi, Punjabi).

## Code Style & Architecture

### Flutter/Dart Standards
- Use Clean Architecture pattern with feature-based folder structure
- Follow GetX for state management and dependency injection
- Implement reactive programming with .obs variables
- Use proper error handling with try-catch blocks
- Follow Dart naming conventions (camelCase for variables, PascalCase for classes)
- Add comprehensive documentation comments for public methods
- Prefer composition over inheritance
- Use const constructors where possible for performance

### Project Structure
```
lib/
├── core/              # Shared utilities, themes, constants
├── features/          # Feature modules (auth, chatbot, weather, etc.)
│   └── feature_name/
│       ├── data/      # Models, repositories, services
│       ├── domain/    # Business entities, abstract repositories
│       └── presentation/ # Controllers, screens, widgets
├── shared/            # Shared widgets, models
└── main.dart
```

### State Management Patterns
- Use GetxController for business logic
- Declare reactive variables with .obs
- Wrap UI updates with Obx() or GetBuilder()
- Implement proper dependency injection with Get.put() or Get.lazyPut()
- Follow controller lifecycle methods (onInit, onReady, onClose)

## Feature-Specific Guidelines

### Chatbot Development
- Handle inconsistent JSON responses from backend gracefully
- Implement proper error handling for speech services
- Support multi-language content rendering
- Use markdown formatting for bot responses
- Implement TTS with word highlighting
- Add haptic feedback for interactions

### UI/UX Standards
- Use semantic colors from themes folder and theme specific files
- Implement proper accessibility features
- Add loading states and error handling
- Use consistent spacing (multiples of 4px)
- Implement responsive design for different screen sizes

### Localization
- Use AppLocalizations for all user-facing text
- Support RTL languages if needed
- Implement proper font selection for Indian languages
- Use language-specific formatting for dates, numbers

### API Integration
- we are using firebase, so make proper services for that

## Code Generation Preferences

### When generating classes:
- Include proper constructor parameters
- Add toJson/fromJson methods for data models
- Implement toString() for debugging
- Add proper null safety annotations
- Include validation where appropriate

### When generating widgets:
- Use const constructors where possible
- Include proper key parameters
- Add semantic labels for accessibility
- Implement proper dispose methods for controllers
- Use proper widget lifecycle methods

### When generating API services:
- Include proper error handling
- Add request/response logging
- Use environment-specific configurations
- Implement proper timeout handling
- Add unit tests alongside implementation

## Best Practices to Follow

### Performance
- Use ListView.builder for large lists
- Implement proper image caching
- Avoid rebuilding widgets unnecessarily
- Use const widgets where possible
- Implement proper memory management

### Security
- Never hardcode API keys or sensitive data
- Use secure storage for authentication tokens
- Implement proper input validation
- Sanitize user inputs before API calls

### Documentation in docs/ 
- use docs/ directory for all documentation
- Add comprehensive comments for complex logic
- Include usage examples in documentation
- Document API endpoints and responses
- Maintain README files for each feature
- Update changelog for significant changes

## Agricultural Domain Knowledge

### Context Awareness
- Understand Indian farming practices and seasons (Kharif, Rabi)
- Consider regional variations in farming
- Be aware of common agricultural challenges (weather, pests, market access)
- Understand government schemes and helplines
- Consider literacy levels of target users

### Language Considerations
- Hindi and Punjabi language support is critical
- Use simple, clear language in user interfaces
- Consider voice-first interactions for low-literacy users
- Implement proper text-to-speech functionality

## Code Review Checklist
When suggesting code, ensure:
- [ ] Follows clean architecture principles
- [ ] Implements proper error handling
- [ ] Includes null safety considerations
- [ ] Uses appropriate GetX patterns
- [ ] Has proper documentation
- [ ] Follows project naming conventions
- [ ] Includes appropriate tests
- [ ] Considers performance implications
- [ ] Implements accessibility features
- [ ] Supports multi-language requirements

## Priority Areas
1. **Chatbot Excellence**: Focus on making the AI chatbot robust and user-friendly
2. **Performance**: Ensure smooth operation on budget Android devices
3. **Offline Capability**: Critical for rural areas with poor connectivity
4. **Localization**: Proper multi-language support for Indian farmers