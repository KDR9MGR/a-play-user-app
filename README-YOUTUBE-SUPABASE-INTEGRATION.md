# YouTube Content Integration with Supabase

## Overview
Successfully integrated YouTube content management system with Supabase database, implementing proper Row Level Security (RLS) policies for admin-only content management while allowing all users to view content.

## Database Schema

### Table: `youtube_content`
```sql
CREATE TABLE public.youtube_content (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  video_id VARCHAR(20) NOT NULL UNIQUE,
  title TEXT NOT NULL,
  description TEXT,
  category VARCHAR(100),
  year INTEGER,
  maturity_rating VARCHAR(20),
  seasons VARCHAR(50),
  content_type VARCHAR(20) DEFAULT 'video',
  section_name VARCHAR(50),
  is_featured BOOLEAN DEFAULT false,
  display_order INTEGER DEFAULT 0,
  image_url TEXT,
  thumbnail_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);
```

### Indexes
- `idx_youtube_content_video_id` on `video_id`
- `idx_youtube_content_section` on `section_name`
- `idx_youtube_content_featured` on `is_featured`
- `idx_youtube_content_type` on `content_type`

## Row Level Security (RLS) Policies

### 1. View Policy (All Users)
```sql
CREATE POLICY "Anyone can view youtube content" 
ON public.youtube_content FOR SELECT 
USING (true);
```

### 2. Insert Policy (Admin Only)
```sql
CREATE POLICY "Only admins can insert youtube content" 
ON public.youtube_content FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.role = 'admin'
  )
);
```

### 3. Update Policy (Admin Only)
```sql
CREATE POLICY "Only admins can update youtube content" 
ON public.youtube_content FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.role = 'admin'
  )
);
```

### 4. Delete Policy (Admin Only)
```sql
CREATE POLICY "Only admins can delete youtube content" 
ON public.youtube_content FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.id = auth.uid() 
    AND profiles.role = 'admin'
  )
);
```

## Flutter Implementation

### Architecture
Following the established Riverpod architecture pattern:

```
lib/features/podcast/
├── model/
│   ├── youtube_content.dart
│   ├── youtube_content.freezed.dart
│   └── youtube_content.g.dart
├── service/
│   └── youtube_content_service.dart
├── controller/
│   └── youtube_content_controller.dart
├── provider/
│   ├── youtube_content_provider.dart
│   └── admin_check_provider.dart
├── screens/
│   ├── podcast_screen.dart
│   ├── admin_content_screen.dart
│   └── video_player_screen.dart
└── test_youtube_content.dart
```

### Key Features

#### 1. Data Model (Freezed)
```dart
@freezed
class YoutubeContent with _$YoutubeContent {
  const factory YoutubeContent({
    required String id,
    required String videoId,
    required String title,
    String? description,
    String? category,
    int? year,
    String? maturityRating,
    String? seasons,
    @Default('video') String contentType,
    String? sectionName,
    @Default(false) bool isFeatured,
    @Default(0) int displayOrder,
    String? imageUrl,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) = _YoutubeContent;

  factory YoutubeContent.fromJson(Map<String, dynamic> json) =>
      _$YoutubeContentFromJson(json);
}
```

#### 2. Service Layer
- Handles all Supabase database interactions
- Maps database snake_case to Dart camelCase
- Implements CRUD operations with proper error handling
- Auto-handles RLS policy enforcement

#### 3. State Management (Riverpod)
```dart
final youtubeContentProvider = AsyncNotifierProvider<YoutubeContentController, YoutubeContentSections>(
  () => YoutubeContentController(),
);
```

#### 4. Admin Features
- Admin role checking provider
- Full content management interface
- Add, Edit, Delete functionality
- Form validation and error handling

## Content Sections

The system organizes content into the following sections:

1. **Featured** - Highlighted content shown in carousel
2. **Popular on APlay** - Popular content section
3. **Trending Now** - Trending content
4. **Action** - Action genre content
5. **Custom Sections** - Additional configurable sections

## Admin Interface

### Features
- **Add Content**: Form-based content creation
- **Edit Content**: Inline editing of existing content
- **Delete Content**: Safe deletion with confirmation
- **Section Management**: Organize content by sections
- **Featured Content**: Mark content as featured for carousel
- **Display Order**: Control content ordering

### Access Control
- Admin button only visible to users with `role = 'admin'` in profiles table
- All admin operations protected by RLS policies
- Automatic error handling for permission denied scenarios

## Sample Data

The system comes pre-loaded with 12 sample items across all sections:

### Featured Content (3 items)
- Epic Action Movie Trailer
- Mystery Drama Series  
- Comedy Special Live

### Popular on APlay (3 items)
- Tech Talk Podcast
- Cooking Masterclass
- Travel Adventures

### Trending Now (3 items)
- Gaming Championship
- Music Documentary
- Science Explained

### Action Section (3 items)
- Superhero Origins
- Martial Arts Master
- Car Chase Thriller

## Usage Instructions

### For Developers

1. **Adding Content Programmatically**:
```dart
final controller = ref.read(youtubeContentProvider.notifier);
await controller.addContent(
  videoId: 'your_video_id',
  title: 'Your Title',
  description: 'Your description',
  sectionName: 'Popular on APlay',
  isFeatured: false,
);
```

2. **Fetching Content**:
```dart
final contentState = ref.watch(youtubeContentProvider);
```

3. **Admin Role Check**:
```dart
final isAdmin = ref.watch(isAdminProvider);
```

### For Admins

1. Navigate to the Podcast screen
2. Look for the settings icon in the top-right corner (only visible to admins)
3. Use the admin interface to manage content

## Testing

A test screen is available at `lib/features/podcast/test_youtube_content.dart` for development verification.

## Security Considerations

- All admin operations require authentication
- RLS policies enforce role-based access control
- Content viewing is public but creation/modification is restricted
- Automatic timestamp management for audit trails

## Performance

- Database indexes on frequently queried fields
- Efficient data mapping between database and Dart models
- Cached provider state management
- Optimized queries with proper ordering

## Troubleshooting

### Common Issues

#### DateTime Type Casting Error
If you encounter an error like "type 'DateTime' is not a subtype of type 'String'", this is due to Supabase returning DateTime objects directly instead of strings. The service includes proper DateTime handling:

- `_formatDateTimeForJson()` - Converts DateTime objects to ISO8601 strings for JSON serialization
- `_parseDateTime()` - Safely parses DateTime from various formats

#### Service Initialization Error
If you see a `LateInitializationError`, ensure the service is properly initialized using the lazy getter pattern implemented in the controller.

## Future Enhancements

- Bulk content import/export
- Content analytics and viewing statistics
- Advanced filtering and search
- Content versioning and approval workflows
- Integration with YouTube API for automatic metadata fetching 