# Widget Tests for Components

This folder contains unit tests for widget components used throughout the application.

## Test Files

- **app_button_test.dart**: Tests for `AppButton` widget
  - Tests button text display
  - Tests button press callbacks
  - Tests disabled state
  - Tests all button variants (primary, secondary, destructive, outline, ghost)
  - Tests icon display
  - Tests expanded/not expanded states
  - Tests custom height and border radius

- **app_input_test.dart**: Tests for `AppInput` widget
  - Tests label and description display
  - Tests error text display
  - Tests prefix and suffix icons
  - Tests text input callbacks (onChanged, onSubmitted)
  - Tests disabled and read-only states
  - Tests obscure text mode
  - Tests keyboard type
  - Tests button integration
  - Tests error border colors

- **app_checkbox_test.dart**: Tests for `AppCheckbox` widget
  - Tests checked/unchecked states
  - Tests checkbox toggle functionality
  - Tests label display
  - Tests error text display
  - Tests disabled state
  - Tests error colors
  - Tests checkbox size

## Running Tests

To run all widget tests:
```bash
flutter test lib/test/widgets/components/
```

To run a specific test file:
```bash
flutter test lib/test/widgets/components/app_button_test.dart
```

## Test Coverage

These tests cover:
- Widget rendering
- User interactions (taps, text input)
- State management
- Conditional rendering
- Error states
- Disabled states
- Visual appearance (colors, borders, sizes)

