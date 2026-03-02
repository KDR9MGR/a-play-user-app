# 🎁 Post Gifts System - Implementation Guide

**Status**: Ready to Deploy ✅
**Created**: December 24, 2024
**Feature**: Allow users to gift points to bloggers/content creators for interesting posts

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Database Schema](#database-schema)
3. [How It Works](#how-it-works)
4. [Installation Steps](#installation-steps)
5. [Flutter Integration](#flutter-integration)
6. [Testing Guide](#testing-guide)
7. [API Reference](#api-reference)
8. [UI Components](#ui-components)
9. [Business Logic](#business-logic)
10. [Future Enhancements](#future-enhancements)

---

## 🎯 Overview

The Post Gifts System allows users to appreciate quality content by gifting points to post authors. This creates a reward mechanism for content creators and encourages high-quality posts.

### Key Features

- ✅ **3 Preset Gift Amounts**: 👍 Like (10pts), ❤️ Love (50pts), 🔥 Fire (100pts)
- ✅ **Custom Amounts**: Users can gift any amount they choose
- ✅ **Optional Messages**: Include a personal message with gifts
- ✅ **One Gift Per Post**: Users can only gift each post once
- ✅ **Real-time Balance**: Shows current points balance
- ✅ **Gift Summary**: Display total gifts received on posts
- ✅ **Transaction History**: Track gifts sent and received
- ✅ **Secure Processing**: Atomic transactions prevent double-spending

---

## 🗄️ Database Schema

### Tables Created

#### 1. `post_gifts`
Tracks all gift transactions.

```sql
CREATE TABLE post_gifts (
  id UUID PRIMARY KEY,
  feed_id UUID NOT NULL,                    -- Post being gifted
  gifter_user_id UUID NOT NULL,             -- User giving the gift
  receiver_user_id UUID NOT NULL,            -- Post author receiving
  points_amount INTEGER NOT NULL,            -- Points gifted
  gift_type TEXT NOT NULL,                   -- 'small', 'medium', 'large', 'custom'
  message TEXT,                              -- Optional message
  status TEXT NOT NULL,                      -- 'pending', 'completed', 'refunded', 'failed'
  created_at TIMESTAMP WITH TIME ZONE,

  UNIQUE(feed_id, gifter_user_id)           -- One gift per user per post
);
```

#### 2. `gift_presets`
Stores predefined gift configurations.

```sql
CREATE TABLE gift_presets (
  id TEXT PRIMARY KEY,                       -- 'small', 'medium', 'large'
  name TEXT NOT NULL,                        -- 'Like', 'Love', 'Fire'
  emoji TEXT NOT NULL,                       -- '👍', '❤️', '🔥'
  points_amount INTEGER NOT NULL,            -- 10, 50, 100
  display_order INTEGER,
  is_active BOOLEAN,
  created_at TIMESTAMP WITH TIME ZONE
);
```

#### 3. Updates to `feed` table
```sql
ALTER TABLE feed
  ADD COLUMN gift_count INTEGER DEFAULT 0,
  ADD COLUMN total_points_received INTEGER DEFAULT 0;
```

### Database Functions

#### `process_post_gift()`
Main function that handles the complete gift transaction:

```sql
process_post_gift(
  p_feed_id UUID,
  p_gifter_user_id UUID,
  p_receiver_user_id UUID,
  p_points_amount INTEGER,
  p_gift_type TEXT,
  p_message TEXT
) RETURNS JSONB
```

**What it does:**
1. ✅ Validates gifter has enough points
2. ✅ Checks user hasn't already gifted this post
3. ✅ Creates gift record
4. ✅ Deducts points from gifter
5. ✅ Adds points to receiver
6. ✅ Updates post statistics
7. ✅ Returns success/error response

**Response:**
```json
{
  "success": true,
  "gift_id": "uuid",
  "points_gifted": 50,
  "remaining_points": 450
}
```

#### `get_post_gift_summary()`
Get aggregated gift statistics for a post.

```sql
get_post_gift_summary(p_feed_id UUID) RETURNS JSONB
```

**Response:**
```json
{
  "total_gifts": 15,
  "total_points": 750,
  "unique_gifters": 12,
  "gift_breakdown": [
    {"gift_type": "small", "count": 8},
    {"gift_type": "medium", "count": 5},
    {"gift_type": "large", "count": 2}
  ]
}
```

#### `get_user_gift_history()`
Get user's gifting history (gifts sent).

#### `get_user_gifts_received()`
Get user's received gifts history.

---

## ⚙️ How It Works

### User Flow

```
1. User sees interesting post
   ↓
2. Clicks "Gift" button
   ↓
3. Bottom sheet opens showing:
   - Current points balance
   - 3 preset options (👍 10pts, ❤️ 50pts, 🔥 100pts)
   - Custom amount option (💎 Custom)
   - Optional message field
   ↓
4. User selects gift amount
   ↓
5. User clicks "Send Gift"
   ↓
6. System validates:
   - User has enough points
   - User hasn't gifted this post before
   - Post author exists
   ↓
7. Transaction processes atomically:
   - Points deducted from gifter
   - Points added to receiver
   - Gift record created
   - Post stats updated
   ↓
8. Success message shown
   ↓
9. Gift button shows "Gifted" status
```

### Business Rules

1. **One Gift Per Post**: Users can only gift each post once (enforced by UNIQUE constraint)
2. **Sufficient Balance**: Gift amount cannot exceed user's points balance
3. **Active Subscription**: Users must have an active subscription to gift points
4. **Atomic Transactions**: All operations happen atomically - either all succeed or all fail
5. **No Self-Gifting**: Users cannot gift their own posts (validated in UI)

---

## 🚀 Installation Steps

### Step 1: Run Database Migration

Run the migration file in your Supabase SQL Editor:

```bash
supabase/migrations/04_post_gifts_system.sql
```

This will create:
- ✅ 2 new tables (`post_gifts`, `gift_presets`)
- ✅ 4 database functions
- ✅ RLS policies
- ✅ Indexes for performance
- ✅ Default gift presets

### Step 2: Generate Flutter Code

Run build_runner to generate Freezed models:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `post_gift_model.freezed.dart`
- `post_gift_model.g.dart`

### Step 3: Verify Installation

Run these queries in Supabase SQL Editor:

```sql
-- Check tables exist
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('post_gifts', 'gift_presets');

-- Check gift presets
SELECT * FROM gift_presets ORDER BY display_order;

-- Check functions exist
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%gift%';
```

**Expected Results:**
- 2 tables found
- 3 gift presets (small, medium, large)
- 4 functions (process_post_gift, get_post_gift_summary, get_user_gift_history, get_user_gifts_received)

---

## 📱 Flutter Integration

### Files Created

#### 1. Model Layer
**File**: [lib/features/feed/model/post_gift_model.dart](lib/features/feed/model/post_gift_model.dart)

**Models:**
- `PostGift` - Individual gift record
- `GiftPreset` - Gift configuration
- `PostGiftSummary` - Aggregated gift stats
- `GiftBreakdown` - Gift breakdown by type
- `GiftResponse` - API response
- `GiftType` - Enum for gift types
- `GiftStatus` - Enum for gift status

#### 2. Service Layer
**File**: [lib/features/feed/service/gift_service.dart](lib/features/feed/service/gift_service.dart)

**Methods:**
```dart
class GiftService {
  // Gift points to a post
  Future<GiftResponse> giftPointsToPost({
    required String feedId,
    required String receiverUserId,
    required int pointsAmount,
    required GiftType giftType,
    String? message,
  });

  // Get gift summary for a post
  Future<PostGiftSummary> getPostGiftSummary(String feedId);

  // Get user's gifting history
  Future<List<PostGift>> getUserGiftHistory({int limit, int offset});

  // Get gifts received by user
  Future<List<PostGift>> getUserGiftsReceived({int limit, int offset});

  // Get available gift presets
  Future<List<GiftPreset>> getGiftPresets();

  // Get user's points balance
  Future<int> getUserPointsBalance();

  // Check if user can gift
  Future<bool> canUserGift({required int pointsRequired});
}
```

#### 3. UI Layer
**File**: [lib/features/feed/widgets/gift_button_widget.dart](lib/features/feed/widgets/gift_button_widget.dart)

**Widget**: `GiftButtonWidget`
- Shows gift icon with count
- Opens gift dialog on tap
- Updates after successful gift

**Widget**: `_GiftDialogContent`
- Shows user's points balance
- Displays 3 preset options + custom
- Optional message field
- Send gift button with loading state

#### 4. Integration
**File**: [lib/features/feed/screen/instagram_feed_page.dart](lib/features/feed/screen/instagram_feed_page.dart:444-450)

Added gift button next to like count on each post.

---

## 🧪 Testing Guide

### Manual Testing Checklist

#### Database Testing

- [ ] Run migration file successfully
- [ ] Verify tables created
- [ ] Check gift presets inserted
- [ ] Test `process_post_gift()` function directly
- [ ] Verify RLS policies work

#### App Testing

**Scenario 1: Successful Gift**
1. Login with test user A
2. View a post by user B
3. Click "Gift" button
4. Select gift amount (e.g., ❤️ Love - 50pts)
5. Add optional message
6. Click "Send Gift"
7. ✅ Success message appears
8. ✅ Points deducted from user A
9. ✅ Points added to user B
10. ✅ Button shows "Gifted" status
11. ✅ Gift count shows on post

**Scenario 2: Insufficient Points**
1. Login with user with < 10 points
2. Try to gift 10 points
3. ✅ Error message: "Insufficient points"

**Scenario 3: Duplicate Gift Prevention**
1. Gift a post successfully
2. Try to gift the same post again
3. ✅ Error message: "You have already gifted this post"
4. ✅ Button shows "Gifted" status (disabled)

**Scenario 4: Custom Amount**
1. Click "Gift" button
2. Select custom amount option (💎)
3. Enter 75 in the field
4. Send gift
5. ✅ 75 points transferred

**Scenario 5: With Message**
1. Gift a post with a message "Great content!"
2. ✅ Message saved in database
3. ✅ Receiver can see message in gift history

**Scenario 6: Gift History**
1. Gift multiple posts
2. Check gifting history
3. ✅ All gifts listed with details

### SQL Test Queries

```sql
-- Test gifting function
SELECT process_post_gift(
  'feed_id_here'::uuid,
  'gifter_id_here'::uuid,
  'receiver_id_here'::uuid,
  50,
  'medium',
  'Great post!'
);

-- Check user's balance
SELECT reward_points FROM user_subscriptions
WHERE user_id = 'user_id_here' AND status = 'active';

-- View all gifts for a post
SELECT * FROM post_gifts WHERE feed_id = 'feed_id_here';

-- Get gift summary
SELECT get_post_gift_summary('feed_id_here'::uuid);
```

---

## 📚 API Reference

### Supabase RPC Calls

#### Gift Points to Post
```dart
final response = await supabase.rpc(
  'process_post_gift',
  params: {
    'p_feed_id': feedId,
    'p_gifter_user_id': currentUserId,
    'p_receiver_user_id': receiverUserId,
    'p_points_amount': 50,
    'p_gift_type': 'medium',
    'p_message': 'Great content!',
  },
);
```

#### Get Gift Summary
```dart
final response = await supabase.rpc(
  'get_post_gift_summary',
  params: {'p_feed_id': feedId},
);
```

#### Get Gift History
```dart
final response = await supabase.rpc(
  'get_user_gift_history',
  params: {
    'p_user_id': userId,
    'p_limit': 20,
    'p_offset': 0,
  },
);
```

### Direct Table Access

#### Get User's Points Balance
```dart
final response = await supabase
  .from('user_subscriptions')
  .select('reward_points')
  .eq('user_id', userId)
  .eq('status', 'active')
  .single();

final points = response['reward_points'] as int;
```

#### Check if User Gifted Post
```dart
final response = await supabase
  .from('post_gifts')
  .select()
  .eq('feed_id', feedId)
  .eq('gifter_user_id', userId)
  .maybeSingle();

final hasGifted = response != null;
```

---

## 🎨 UI Components

### Gift Button States

**1. Default State** (User hasn't gifted)
```
┌─────────────┐
│ ⭐ Gift     │
└─────────────┘
```

**2. With Gifts** (Shows total points)
```
┌─────────────┐
│ ⭐ 450 Gift │
└─────────────┘
```

**3. User Gifted** (Disabled state)
```
┌──────────────────┐
│ ⭐ 450 Gifted   │ (amber background)
└──────────────────┘
```

### Gift Dialog Layout

```
┌─────────────────────────────────┐
│  Gift Points to John Doe        │
│  💰 Your balance: 500 points    │
├─────────────────────────────────┤
│  Select Amount                  │
│                                 │
│  ┌────┐  ┌────┐  ┌────┐       │
│  │ 👍 │  │ ❤️ │  │ 🔥 │       │
│  │Like│  │Love│  │Fire│       │
│  │10pt│  │50pt│  │100 │       │
│  └────┘  └────┘  └────┘       │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 💎 Enter custom amount... │ │
│  └───────────────────────────┘ │
│                                 │
│  Add a Message (Optional)       │
│  ┌───────────────────────────┐ │
│  │ Write a message...        │ │
│  │                           │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │      Send Gift            │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

---

## 💼 Business Logic

### Points Flow

```
User A (Gifter)                Post Author (Receiver)
━━━━━━━━━━━━━━                ━━━━━━━━━━━━━━━━━━━━━━
Balance: 500 pts               Balance: 200 pts
    ↓
Gifts 50 pts
    ↓
Balance: 450 pts               Balance: 250 pts
                                    ↑
                              Receives 50 pts
```

### Error Handling

| Error | User Message | HTTP Code |
|-------|-------------|-----------|
| Insufficient points | "Not enough points. You need X but have Y." | 400 |
| Already gifted | "You've already gifted this post!" | 409 |
| No active subscription | "Please subscribe to gift points." | 403 |
| Post not found | "Post not found" | 404 |
| Network error | "Failed to gift points. Please try again." | 500 |

### Security Measures

1. **RLS Policies**: Users can only insert gifts from their own account
2. **UNIQUE Constraint**: Prevents duplicate gifts (feed_id + gifter_user_id)
3. **CHECK Constraints**: Ensures points_amount > 0
4. **Atomic Transactions**: All operations succeed or fail together
5. **Function SECURITY DEFINER**: Controlled execution with elevated privileges
6. **Balance Validation**: Server-side validation of sufficient points

---

## 🚀 Future Enhancements

### Phase 2 Features

- [ ] **Gift Leaderboards**: Top gifters and top recipients
- [ ] **Gift Badges**: Special badges for generous users
- [ ] **Gift Notifications**: Push notifications when receiving gifts
- [ ] **Gift Multipliers**: Events where gifts count 2x during promotions
- [ ] **Gift Emojis**: Animated emoji reactions when gifting
- [ ] **Thank You Messages**: Auto-response option for receivers
- [ ] **Gift Bundles**: Preset bundles with discounts
- [ ] **Gift Analytics**: Dashboard showing gift trends
- [ ] **Gift Refunds**: Allow refunds within 24 hours (with conditions)
- [ ] **Gift Limits**: Daily/weekly gifting limits per user

### Phase 3 Features

- [ ] **Charity Gifts**: Option to donate to charity instead
- [ ] **Group Gifts**: Multiple users contribute to one big gift
- [ ] **Scheduled Gifts**: Schedule gifts for future delivery
- [ ] **Gift Subscriptions**: Recurring gifts to favorite creators
- [ ] **NFT Gifts**: Special digital collectibles as gifts
- [ ] **Gift Marketplace**: Trade gift items

---

## 📊 Analytics & Metrics

### Key Metrics to Track

1. **Gift Conversion Rate**: % of users who gift after viewing
2. **Average Gift Amount**: Mean points gifted per transaction
3. **Gift Frequency**: Gifts per user per day/week/month
4. **Top Gifters**: Most generous users
5. **Top Recipients**: Most gifted content creators
6. **Gift Retention**: Repeat gifting behavior
7. **Revenue Impact**: Correlation between gifting and subscriptions

### Sample Analytics Queries

```sql
-- Top gifted posts this week
SELECT
  f.id,
  f.content,
  COUNT(pg.id) as gift_count,
  SUM(pg.points_amount) as total_points
FROM feed f
JOIN post_gifts pg ON pg.feed_id = f.id
WHERE pg.created_at > NOW() - INTERVAL '7 days'
  AND pg.status = 'completed'
GROUP BY f.id
ORDER BY total_points DESC
LIMIT 10;

-- Most generous users this month
SELECT
  p.full_name,
  COUNT(pg.id) as gifts_sent,
  SUM(pg.points_amount) as points_gifted
FROM profiles p
JOIN post_gifts pg ON pg.gifter_user_id = p.id
WHERE pg.created_at > NOW() - INTERVAL '30 days'
  AND pg.status = 'completed'
GROUP BY p.id
ORDER BY points_gifted DESC
LIMIT 10;

-- Gift type distribution
SELECT
  gift_type,
  COUNT(*) as count,
  SUM(points_amount) as total_points,
  AVG(points_amount) as avg_points
FROM post_gifts
WHERE status = 'completed'
GROUP BY gift_type;
```

---

## ✅ Completion Checklist

Before marking this feature as complete, verify:

### Database
- [ ] Migration file runs without errors
- [ ] All tables created with correct schema
- [ ] Gift presets inserted (3 defaults)
- [ ] All 4 functions created and working
- [ ] RLS policies active and tested
- [ ] Indexes created for performance

### Flutter App
- [ ] Models generated with build_runner
- [ ] GiftService all methods working
- [ ] GiftButtonWidget displays correctly
- [ ] Gift dialog opens and closes smoothly
- [ ] Gift transaction processes successfully
- [ ] Error messages display appropriately
- [ ] Success messages confirm actions
- [ ] UI updates after gifting

### Testing
- [ ] Can gift a post successfully
- [ ] Insufficient points error works
- [ ] Duplicate gift prevention works
- [ ] Custom amount option works
- [ ] Message saves correctly
- [ ] Points balance updates correctly
- [ ] Gift history displays
- [ ] RLS prevents unauthorized access

### Documentation
- [ ] README updated with new feature
- [ ] API documentation complete
- [ ] Database schema documented
- [ ] Testing guide provided
- [ ] Known issues documented

---

## 🎉 Congratulations!

You've successfully implemented the Post Gifts System! Users can now reward great content and content creators can earn points through quality posts.

**Next Steps:**
1. Run the migration: `04_post_gifts_system.sql`
2. Generate models: `flutter packages pub run build_runner build`
3. Test thoroughly using the testing guide
4. Monitor analytics to measure success
5. Plan for Phase 2 enhancements

---

**Questions or Issues?**
Check the troubleshooting section or review the implementation files.

**Happy Gifting! 🎁✨**
