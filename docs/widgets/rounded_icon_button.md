# RoundedIconButton Widget

## Overview

The `RoundedIconButton` is a reusable widget that provides a consistent rounded icon button style throughout the Kisaan Mithraa app. It follows the design system established by the home screen and AppBar components.

## Purpose

- **Consistency**: Ensures all rounded icon buttons have the same visual appearance
- **Maintainability**: Centralizes styling in one place for easy updates
- **Accessibility**: Includes built-in tooltip support and haptic feedback
- **Flexibility**: Customizable while maintaining design consistency

## Design Specifications

### Default Styling
- **Border Radius**: 14px
- **Padding**: 10px all around
- **Icon Size**: 22px
- **Border**: 1.5px width with `theme.colorScheme.onBackground.withOpacity(0.1)`
- **Background**: `theme.colorScheme.background`
- **Shadow**: Subtle shadow with 3% black opacity, 8px blur, 2px offset
- **Haptic Feedback**: Light impact on tap

### Visual Appearance
```
┌─────────────────────┐
│  ┌───────────────┐  │ ← 10px padding
│  │               │  │
│  │      Icon     │  │ ← 22px icon
│  │               │  │
│  └───────────────┘  │ ← 14px border radius
└─────────────────────┘
```

## Usage

### Basic Usage
```dart
RoundedIconButton(
  icon: Icons.search,
  onTap: () => Get.toNamed('/search'),
)
```

### With Tooltip
```dart
RoundedIconButton(
  icon: Icons.refresh,
  onTap: () => controller.refresh(),
  tooltip: 'Refresh Data',
)
```

### With Custom Styling
```dart
RoundedIconButton(
  icon: Icons.settings,
  onTap: () => showSettings(),
  iconColor: Colors.blue,
  backgroundColor: Colors.blue.withOpacity(0.1),
  margin: EdgeInsets.only(right: 8),
)
```

### With Custom Dimensions
```dart
RoundedIconButton(
  icon: Icons.close,
  onTap: () => Navigator.pop(context),
  size: 18,
  padding: EdgeInsets.all(8),
  borderRadius: 12,
)
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `icon` | `IconData` | **required** | The icon to display |
| `onTap` | `VoidCallback` | **required** | Callback when button is tapped |
| `tooltip` | `String?` | `null` | Tooltip text for accessibility |
| `iconColor` | `Color?` | `theme.colorScheme.onBackground` | Icon color |
| `backgroundColor` | `Color?` | `theme.colorScheme.background` | Button background color |
| `borderColor` | `Color?` | `theme.colorScheme.onBackground.withOpacity(0.1)` | Border color |
| `size` | `double` | `22` | Icon size in pixels |
| `padding` | `EdgeInsets` | `EdgeInsets.all(10)` | Internal padding |
| `borderRadius` | `double` | `14` | Corner radius |
| `borderWidth` | `double` | `1.5` | Border thickness |
| `enableShadow` | `bool` | `true` | Whether to show shadow |
| `margin` | `EdgeInsets?` | `null` | External margin |

## Implementation Examples

### AppBar Actions
```dart
CommonAppBar(
  title: 'My Screen',
  customActions: [
    RoundedIconButton(
      icon: Icons.search,
      onTap: () => Get.toNamed('/search'),
      tooltip: 'Search',
      margin: EdgeInsets.only(right: 16),
    ),
  ],
)
```

### Floating Action Button Alternative
```dart
RoundedIconButton(
  icon: Icons.add,
  onTap: () => showCreateDialog(),
  backgroundColor: theme.colorScheme.primary,
  iconColor: Colors.white,
  tooltip: 'Add New Item',
)
```

### Disabled State
```dart
RoundedIconButton(
  icon: Icons.send,
  onTap: isEnabled ? () => sendMessage() : () {},
  iconColor: isEnabled 
    ? theme.colorScheme.primary 
    : theme.colorScheme.onSurface.withOpacity(0.4),
  backgroundColor: isEnabled 
    ? theme.colorScheme.background 
    : Colors.grey.withOpacity(0.1),
)
```

## Accessibility Features

- **Tooltip Support**: Automatically wraps button with Tooltip widget when `tooltip` is provided
- **Haptic Feedback**: Provides light impact feedback on tap for better user experience
- **Theme Aware**: Automatically adapts to current theme colors
- **Touch Target**: Minimum 44px touch target (with default padding)

## Migration from Hardcoded Buttons

### Before (Hardcoded)
```dart
Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: () => Get.toNamed('/search'),
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.search,
        color: theme.colorScheme.onBackground,
        size: 22,
      ),
    ),
  ),
)
```

### After (Using RoundedIconButton)
```dart
RoundedIconButton(
  icon: Icons.search,
  onTap: () => Get.toNamed('/search'),
  tooltip: 'Search',
)
```

## Best Practices

1. **Always provide tooltips** for accessibility and better UX
2. **Use consistent margins** when placing in AppBar actions (typically `EdgeInsets.only(right: 16)`)
3. **Prefer default styling** unless custom colors are specifically needed for the design
4. **Consider visual hierarchy** when choosing icon colors and backgrounds
5. **Test with different themes** to ensure proper contrast and visibility

## Related Components

- `CommonAppBar` - Uses RoundedIconButton for default notification and profile icons
- `HomeAppBar` - Uses RoundedIconButton for notification and profile actions
- Custom action implementations in various screens

## Maintenance Notes

- All styling changes should be made to this widget to maintain consistency
- When updating design system colors, verify they work well with the button's theming
- Consider adding new parameters instead of hardcoding values for future flexibility
