# Firebase Schema Documentation - CropConnect/Kisaan Mithraa

## Database Structure Overview

Based on actual codebase analysis, the Firebase Firestore database structure is as follows:

```
firestore/
├── users/                     # User profiles and authentication data
├── cooperatives/              # Agricultural cooperatives
│   └── {cooperativeId}/
│       └── resource_listings/ # Resource pooling listings
├── podcasts/                  # Audio content and metadata
├── notifications/             # System notifications
├── faqs/                      # Knowledge base questions
├── emergency_contacts/        # Agricultural helpline information
└── debug/                     # Debug and development data
```

## Detailed Schema Definitions

### Users Collection
**Path**: `/users/{userId}`

Based on `UserModel` from `/lib/features/auth/domain/model/user/user_model.dart`:

```typescript
interface UserDocument {
  uid: string;                    // Firebase Auth UID (primary key)
  email: string;                  // User email address
  phoneNumber: string;            // User phone number
  firstName: string;              // User's first name
  lastName: string;               // User's last name
  profileImageUrl?: string;       // Optional profile image URL
  dateOfBirth?: string;           // Date of birth (ISO string)
  location?: {
    state?: string;               // State name
    district?: string;            // District name
    pincode?: string;             // PIN code
    address?: string;             // Full address
    latitude?: double;            // GPS latitude
    longitude?: double;           // GPS longitude
  };
  farmingExperience?: string;     // Years of farming experience
  preferredLanguage: string;      // Language preference (en/hi/pa)
  createdAt: Timestamp;           // Account creation timestamp
  updatedAt: Timestamp;           // Last profile update
  isActive: boolean;              // Account status
  deviceTokens?: string[];        // FCM tokens for notifications
}
```

### Cooperatives Collection
**Path**: `/cooperatives/{cooperativeId}`

Based on `CooperativeModel` from `/lib/features/cooperative/domain/models/cooperative_model.dart`:

```typescript
interface CooperativeDocument {
  id: string;                     // Cooperative ID (primary key)
  name: string;                   // Cooperative name
  description: string;            // Detailed description
  location: {
    state: string;                // State name
    district: string;             // District name
    pincode: string;              // PIN code
    address: string;              // Full address
    coordinates: {
      latitude: double;           // GPS latitude
      longitude: double;          // GPS longitude
    };
  };
  adminId: string;                // User ID of the admin
  memberIds: string[];            // Array of member user IDs
  pendingInvites: {
    email: string;                // Invited user's email
    phoneNumber: string;          // Invited user's phone
    invitedAt: Timestamp;         // Invitation timestamp
    invitedBy: string;            // User ID who sent invite
  }[];
  createdAt: Timestamp;           // Creation timestamp
  updatedAt: Timestamp;           // Last update timestamp
  isActive: boolean;              // Active status
  maxMembers?: number;            // Maximum allowed members
  cooperativeType?: string;       // Type of cooperative
  registrationNumber?: string;    // Official registration number
}
```

### Resource Listings Subcollection
**Path**: `/cooperatives/{cooperativeId}/resource_listings/{listingId}`

Based on `ResourceListingModel` from `/lib/features/resource_pooling/domain/resouce_listing_model.dart`:

```typescript
interface ResourceListingDocument {
  id: string;                     // Listing ID (primary key)
  cooperativeId: string;          // Parent cooperative ID
  title: string;                  // Resource title
  description: string;            // Detailed description
  resourceType: string;           // Type of resource (equipment, labor, etc.)
  category: string;               // Resource category
  availability: {
    startDate: Timestamp;         // Available from date
    endDate: Timestamp;           // Available until date
    isFlexible: boolean;          // Flexible timing
  };
  pricing: {
    amount: double;               // Price amount
    currency: string;             // Currency (default: INR)
    unit: string;                 // Pricing unit (per hour, per day, etc.)
    isNegotiable: boolean;        // Price negotiable flag
  };
  owner: {
    userId: string;               // Owner's user ID
    name: string;                 // Owner's display name
    contactPhone: string;         // Contact phone number
    contactEmail?: string;        // Optional contact email
  };
  location: {
    state: string;                // State name
    district: string;             // District name
    pincode?: string;             // PIN code
    address?: string;             // Detailed address
    coordinates?: {
      latitude: double;           // GPS latitude
      longitude: double;          // GPS longitude
    };
  };
  images: string[];               // Array of image URLs
  status: string;                 // Status: available, booked, unavailable
  bookings: {
    userId: string;               // Booking user ID
    startDate: Timestamp;         // Booking start date
    endDate: Timestamp;           // Booking end date
    status: string;               // Booking status
    totalAmount: double;          // Total booking amount
    createdAt: Timestamp;         // Booking creation time
  }[];
  tags: string[];                 // Search tags
  createdAt: Timestamp;           // Creation timestamp
  updatedAt: Timestamp;           // Last update timestamp
  isActive: boolean;              // Active status
  viewCount: number;              // View counter
  inquiryCount: number;           // Inquiry counter
}
```

### Podcasts Collection
**Path**: `/podcasts/{podcastId}`

Based on `PodcastModel` from `/lib/features/podcasts/domain/model/podcast_model.dart`:

```typescript
interface PodcastDocument {
  id: string;                     // Podcast ID (primary key)
  title: string;                  // Podcast title
  description: string;            // Episode description
  audioUrl: string;               // Audio file URL
  thumbnailUrl?: string;          // Thumbnail image URL
  duration: number;               // Duration in seconds
  category: string;               // Podcast category
  tags: string[];                 // Search tags
  language: string;               // Audio language (en/hi/pa)
  publishedAt: Timestamp;         // Publication timestamp
  createdAt: Timestamp;           // Creation timestamp
  updatedAt: Timestamp;           // Last update timestamp
  isActive: boolean;              // Active status
  playCount: number;              // Play counter
  downloadCount: number;          // Download counter
  host: {
    name: string;                 // Host name
    bio?: string;                 // Host biography
    imageUrl?: string;            // Host image URL
  };
  transcript?: string;            // Audio transcript
  relatedTopics: string[];        // Related topics/tags
  difficulty: string;             // Content difficulty level
  targetAudience: string[];       // Target audience tags
}
```

### Notifications Collection
**Path**: `/notifications/{userId}/items/{notificationId}`

Based on `NotificationModel` from `/lib/features/notification/domain/model/notifications_model.dart` and actual usage in `NotificationController`:

```typescript
interface NotificationDocument {
  id: string;                     // Notification ID (primary key)
  userId: string;                 // Target user ID (matches parent document)
  type: string;                   // NotificationType: cooperativeInvite, generalMessage, offerReceived, offerAccepted, offerRejected
  title: string;                  // Notification title
  message: string;                // Notification message/body text
  cooperativeId?: string;         // Related cooperative ID (for coop notifications)
  createdAt: Timestamp;           // Creation timestamp
  isRead: boolean;                // Read status
  action: string;                 // NotificationAction: acceptInvite, declineInvite, viewListing, viewProfile, none
  actionData?: Record<string, any>; // Additional action-specific data
}

// Notes:
// - Each user has their own notifications document: /notifications/{userId}
// - Individual notifications are stored in the "items" subcollection
// - This structure allows for user-specific notification management
// - The userId field in the notification document matches the parent document ID
```

### App Configuration Collection
**Path**: `/app_config/{configKey}`

```typescript
interface AppConfigDocument {
  configKey: string;
  value: any;                   // Configuration value
  description: string;
  environment: "development" | "staging" | "production";
  metadata: {
    createdAt: Timestamp;
    updatedAt: Timestamp;
    version: string;
  };
}

// Common config keys:
// - "api_endpoints"
// - "feature_flags"
// - "maintenance_mode"
// - "supported_languages"
// - "emergency_contacts_cache_duration"
// - "weather_update_interval"
```

### Chat Messages Collection
**Path**: `/users/{userId}/chat_messages/{messageId}` or `/chat_sessions/{sessionId}/messages/{messageId}`

Based on `ChatMessageModel` from `/lib/features/chatbot/domain/models/chat_message_model.dart`:

```typescript
interface ChatMessageDocument {
  id: string;                     // Message ID (primary key)
  content: string;                // Message content/text
  isUser: boolean;                // true if from user, false if from bot
  timestamp: Timestamp;           // Message timestamp
  sessionId?: string;             // Chat session ID
  userId?: string;                // User ID (for user messages)
  messageType: string;            // Type: text, image, audio, etc.
  language?: string;              // Message language
  metadata?: {
    audioUrl?: string;            // Audio message URL
    imageUrl?: string;            // Image message URL
    speechInput?: boolean;        // Was input via speech
    confidence?: double;          // Speech recognition confidence
    processingTime?: number;      // AI processing time (ms)
    tokens?: number;              // Token count for AI response
  };
  botResponse?: {
    intent?: string;              // Detected user intent
    entities?: Record<string, any>; // Extracted entities
    suggestions?: string[];       // Follow-up suggestions
    navigation?: string[];        // App navigation suggestions
  };
  isEdited: boolean;              // Edit status
  editedAt?: Timestamp;           // Edit timestamp
  parentMessageId?: string;       // Reply to message ID
}
```

### FAQ Collection
**Path**: `/faqs/{faqId}`

```typescript
interface FAQDocument {
  id: string;                     // FAQ ID (primary key)
  question: {
    en: string;                   // Question in English
    hi: string;                   // Question in Hindi
    pa: string;                   // Question in Punjabi
  };
  answer: {
    en: string;                   // Answer in English
    hi: string;                   // Answer in Hindi
    pa: string;                   // Answer in Punjabi
  };
  category: string;               // FAQ category
  tags: string[];                 // Search tags
  priority: number;               // Display priority
  isActive: boolean;              // Active status
  createdAt: Timestamp;           // Creation timestamp
  updatedAt: Timestamp;           // Last update timestamp
  viewCount: number;              // View counter
  helpfulVotes: number;           // Helpful vote count
  relatedFAQs: string[];          // Related FAQ IDs
}
```

### Emergency Contacts Collection
**Path**: `/emergency_contacts/{contactId}`

```typescript
interface EmergencyContactDocument {
  id: string;                     // Contact ID (primary key)
  name: {
    en: string;                   // Name in English
    hi: string;                   // Name in Hindi
    pa: string;                   // Name in Punjabi
  };
  description: {
    en: string;                   // Description in English
    hi: string;                   // Description in Hindi
    pa: string;                   // Description in Punjabi
  };
  phoneNumber: string;            // Contact phone number
  email?: string;                 // Optional email
  website?: string;               // Optional website URL
  type: string;                   // Contact type: government/private/ngo
  category: string;               // Service category
  services: string[];             // Array of services offered
  coverage: {
    states: string[];             // States covered (empty = national)
    districts?: string[];         // Specific districts (if applicable)
    isNational: boolean;          // National coverage flag
  };
  availability: {
    hours: string;                // Availability hours
    languages: string[];          // Supported languages
    isEmergencyOnly: boolean;     // Emergency only service
  };
  priority: number;               // Display priority
  isActive: boolean;              // Active status
  isVerified: boolean;            // Verification status
  lastVerified: Timestamp;        // Last verification date
  createdAt: Timestamp;           // Creation timestamp
  updatedAt: Timestamp;           // Last update timestamp
}
```

### Debug Collection (Development Only)
**Path**: `/debug/{documentId}`

Based on `DebugService` from `/lib/core/services/debug/debug_service.dart`:

```typescript
interface DebugDocument {
  id: string;                     // Debug entry ID
  type: string;                   // Debug type (error, info, warning)
  message: string;                // Debug message
  data: Record<string, any>;      // Debug data payload
  userId?: string;                // Associated user ID
  deviceInfo?: {
    platform: string;            // Platform (android/ios)
    version: string;              // App version
    deviceModel: string;          // Device model
  };
  stackTrace?: string;            // Error stack trace
  timestamp: Timestamp;           // Debug timestamp
  environment: string;            // Environment (dev/staging/prod)
  severity: string;               // Severity level
  resolved: boolean;              // Resolution status
  tags: string[];                 // Classification tags
}
```

## 🔐 Security Rules Considerations

Based on the analyzed code, the following security patterns are recommended:

1. **Users**: Users can only read/write their own documents
2. **Cooperatives**: Members can read cooperative data, admins can write
3. **Resource Listings**: Cooperative members can read, owners can write
4. **Podcasts**: Public read access, admin write access
5. **Notifications**: Users can only access their own notifications
6. **FAQs**: Public read access, admin write access
7. **Emergency Contacts**: Public read access, admin write access
8. **Debug**: Restricted to development environment only

## 📊 Required Indexes

Based on the queries found in the codebase:

```yaml
# Cooperatives
- collection: cooperatives
  fields:
    - location.state: ASCENDING
    - location.district: ASCENDING
    - isActive: ASCENDING

# Resource Listings
- collection: cooperatives
  collectionGroup: resource_listings
  fields:
    - status: ASCENDING
    - createdAt: DESCENDING

- collection: cooperatives
  collectionGroup: resource_listings
  fields:
    - category: ASCENDING
    - availability.startDate: ASCENDING

# Podcasts
- collection: podcasts
  fields:
    - category: ASCENDING
    - publishedAt: DESCENDING
    - isActive: ASCENDING

- collection: podcasts
  fields:
    - language: ASCENDING
    - publishedAt: DESCENDING

# Notifications
- collection: notifications
  collectionGroup: items
  fields:
    - userId: ASCENDING
    - createdAt: DESCENDING
    - isRead: ASCENDING

- collection: notifications
  collectionGroup: items
  fields:
    - type: ASCENDING
    - createdAt: DESCENDING

# Chat Messages
- collection: users
  collectionGroup: chat_messages
  fields:
    - sessionId: ASCENDING
    - timestamp: ASCENDING

# FAQs
- collection: faqs
  fields:
    - category: ASCENDING
    - priority: ASCENDING
    - isActive: ASCENDING
```

## 🚀 Collection Usage Patterns

### High-Traffic Collections
- `users` - Frequent profile updates and authentication
- `chat_messages` - Real-time messaging data
- `notifications` - Push notification delivery

### Medium-Traffic Collections  
- `cooperatives` - Community management
- `resource_listings` - Resource sharing and booking
- `podcasts` - Content consumption

### Low-Traffic Collections
- `faqs` - Knowledge base queries
- `emergency_contacts` - Reference data
- `debug` - Development logging

## 📝 Notes

1. This schema is based on actual model classes and service implementations found in the codebase
2. All timestamps use Firestore `Timestamp` type
3. Geographic data uses `double` type for coordinates
4. Multi-language support is implemented using nested objects with language keys
5. The schema supports offline-first architecture with proper conflict resolution
6. Debug collection should only exist in development/staging environments
