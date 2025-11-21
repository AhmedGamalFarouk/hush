# Reply and React Implementation Guide

## Overview
This document describes the implementation of **message replies** and **emoji reactions** in the Hush chat application.

---

## Features Implemented

### 1. Message Replies
Users can reply to any message in a conversation, creating a threaded conversation experience.

**How to Reply:**
- **Swipe right** on any message to quickly reply
- **Long-press** on a message → Select "Reply" from the menu
- A preview of the message you're replying to appears above the input field
- Type your response and send

**UI Elements:**
- **Reply Preview Bar**: Shows above the message input when replying
  - Displays the sender's name
  - Shows a preview of the message content (truncated)
  - Has a close button (X) to cancel the reply
- **Quoted Message in Bubble**: Messages that are replies show:
  - A semi-transparent box with the original message
  - A colored vertical bar on the left
  - Sender name and content preview
  - Tap to scroll to the original message (TODO)

### 2. Emoji Reactions
Users can add emoji reactions to any message, similar to modern messaging apps.

**How to React:**
- **Long-press** on a message → Select "Add Reaction"
- Choose from 12 quick reactions: 👍 ❤️ 😂 😮 😢 🙏 🔥 🎉 👏 💯 ✅ ❌
- Or tap the "+" button below a message that already has reactions

**UI Elements:**
- **Reaction Chips**: Displayed below messages
  - Show emoji + count if multiple people reacted
  - Highlighted when you've reacted
  - Tap to toggle your reaction
- **Reaction Picker**: Bottom sheet with common emoji options

---

## Database Schema

### Messages Table
```sql
CREATE TABLE public.messages (
    id UUID PRIMARY KEY,
    conversation_id UUID NOT NULL,
    sender_id UUID,
    ciphertext TEXT NOT NULL,
    nonce TEXT NOT NULL,
    reply_to_id UUID REFERENCES messages(id), -- <-- Reply support
    ...
);
```

### Message Reactions Table
```sql
CREATE TABLE public.message_reactions (
    id UUID PRIMARY KEY,
    message_id UUID NOT NULL REFERENCES messages(id),
    user_id UUID NOT NULL REFERENCES profiles(id),
    emoji TEXT NOT NULL,
    created_at TIMESTAMPTZ,
    UNIQUE(message_id, user_id, emoji) -- One emoji per user per message
);
```

---

## Code Architecture

### Reply Implementation

**Files Modified:**
1. `lib/chat/services/message_service.dart`
   - Added `getMessage()` to fetch individual messages for reply preview
   - Modified `sendMessage()` to accept `replyToId` parameter
   - Fixed: No longer removes `reply_to_id` when inserting to database

2. `lib/chat/presentation/chat_screen.dart`
   - Added `_replyingTo` state to track which message is being replied to
   - Added `_focusNode` to manage text field focus
   - Wrapped messages in `Dismissible` widget for swipe-to-reply gesture
   - Added reply preview bar above message input
   - Updated message bubble to show quoted message for replies

3. `lib/chat/models/message.dart`
   - Already had `replyToId` field in the model
   - `DecryptedMessage` exposes this via the encrypted message

**Flow:**
1. User swipes or long-presses → Sets `_replyingTo` state
2. UI shows preview bar with message content
3. User types and sends → `sendMessage()` includes `replyToId`
4. Message saved to database with `reply_to_id` column
5. When loading messages, if `reply_to_id` exists:
   - Try to find message in current loaded messages
   - If not found, fetch it via `getMessage()` API
6. Display quoted message preview inside the bubble

### Reaction Implementation

**Files Created/Modified:**
1. `lib/chat/services/reaction_service.dart`
   - `addReaction()` - Toggle reaction (add if new, remove if exists)
   - `removeReaction()` - Remove a specific reaction
   - `getReactions()` - Get all reactions for a message
   - `subscribeToReactions()` - Real-time updates via Supabase

2. `lib/chat/models/message_reaction.dart`
   - `MessageReaction` - Individual reaction record
   - `ReactionSummary` - Aggregated view (emoji, count, reactedByMe)

3. `lib/chat/presentation/widgets/reaction_picker.dart`
   - Bottom sheet with 12 quick emoji options
   - Clean, grid layout

4. `lib/chat/presentation/widgets/message_reactions.dart`
   - Displays reaction chips below message bubbles
   - Shows count and highlights user's reactions
   - Includes "+" button to add more reactions

5. `lib/chat/presentation/chat_screen.dart`
   - `_MessageBubble` loads and subscribes to reactions
   - Displays `MessageReactions` widget below each message
   - Handles tap to toggle reactions

**Flow:**
1. User long-presses message → Menu shows "Add Reaction"
2. Reaction picker appears
3. User selects emoji → `addReaction()` called
4. If user already reacted with that emoji → removes it (toggle)
5. Otherwise → adds new reaction to database
6. Real-time subscription updates all connected clients
7. UI shows updated reaction chips with counts

---

## Testing Checklist

### Reply Testing
- [ ] Swipe right on a message → reply preview appears
- [ ] Long-press → Menu → Reply → reply preview appears
- [ ] Type and send a reply → message shows quoted original
- [ ] Reply to an old message (scrolled out of view) → fetches and displays it
- [ ] Cancel reply by tapping X → preview disappears
- [ ] Quoted message shows sender name and content preview
- [ ] Replies work in both one-to-one and group chats

### Reaction Testing
- [ ] Long-press → Add Reaction → picker appears
- [ ] Select emoji → reaction appears below message
- [ ] Tap reaction chip → toggles on/off
- [ ] Multiple users react → count increments
- [ ] Your reactions are highlighted differently
- [ ] Real-time: Other users' reactions appear instantly
- [ ] Tap "+" button on reacted message → picker appears
- [ ] Reactions work in both one-to-one and group chats

---

## Database Migrations Required

**Important:** Before testing, ensure the database has the correct schema.

### Option 1: Run Migrations (Recommended)
```bash
# Navigate to your Supabase project dashboard
# Go to SQL Editor
# Run the migration file:
supabase/migrations/20251121_add_reply_support.sql
```

This migration:
- Adds `reply_to_id` column if not exists
- Renames `reply_to_message_id` to `reply_to_id` for consistency
- Adds index for performance

### Option 2: Manual SQL
If you set up from `DATABASE_SETUP.md`, the schema already includes `reply_to_id`.

Check if the column exists:
```sql
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'messages' 
  AND column_name IN ('reply_to_id', 'reply_to_message_id');
```

If it shows `reply_to_message_id`, rename it:
```sql
ALTER TABLE messages RENAME COLUMN reply_to_message_id TO reply_to_id;
```

---

## Troubleshooting

### Replies Not Showing
1. **Check database column**: Ensure `messages` table has `reply_to_id` column
2. **Check RLS policies**: User must have SELECT permission on messages
3. **Check console logs**: Look for "Error inserting message" or decryption errors
4. **Verify `sendMessage` call**: Ensure `replyToId` is passed correctly

### Reactions Not Showing
1. **Check database table**: Ensure `message_reactions` table exists
2. **Check RLS policies**: Users need SELECT, INSERT, DELETE on `message_reactions`
3. **Check subscription**: Look for "subscribeToReactions" errors in console
4. **Verify real-time**: Check Supabase Realtime is enabled for the table

### Swipe to Reply Not Working
- Ensure you're swiping from **left to right**
- Check that `Dismissible` widget is present in `chat_screen.dart`
- Verify `_focusNode` is initialized and not null

### Real-time Not Working
```sql
-- Enable Realtime for message_reactions
ALTER PUBLICATION supabase_realtime ADD TABLE public.message_reactions;
```

---

## Code Quality & Best Practices

### Security
- ✅ All message content remains encrypted
- ✅ Reactions are only visible to conversation members (RLS)
- ✅ Reply metadata (IDs) are safe to store unencrypted
- ✅ No plaintext stored on server

### Performance
- ✅ Reply messages fetched lazily (only when needed)
- ✅ Reactions use real-time subscriptions (efficient updates)
- ✅ Database indexes on `reply_to_id` and `message_id`
- ✅ Reactions aggregated client-side to reduce queries

### UX
- ✅ Swipe gesture for quick replies
- ✅ Visual feedback (preview bars, highlights)
- ✅ Toggle behavior for reactions (tap to remove)
- ✅ Pill-shaped reaction chips (modern design)
- ✅ Auto-focus on input when replying

---

## Future Enhancements

### Replies
- [ ] Scroll to original message when tapping quoted preview
- [ ] Support for reply chains (reply to a reply)
- [ ] Show reply count on messages
- [ ] "View thread" for heavily replied messages

### Reactions
- [ ] Full emoji picker (not just quick reactions)
- [ ] Show list of users who reacted (tap reaction chip)
- [ ] Reaction animations (bounce, fade in)
- [ ] Custom emoji/stickers support
- [ ] Reaction suggestions based on message content

---

## API Reference

### MessageService

```dart
// Send a message with optional reply
Future<Result<Message, AppError>> sendMessage({
  required String conversationId,
  required String content,
  required Uint8List conversationKey,
  MessageType type = MessageType.text,
  String? replyToId, // <-- Reply support
  Map<String, dynamic>? metadata,
});

// Fetch a single message (for reply preview)
Future<Result<DecryptedMessage, AppError>> getMessage({
  required String messageId,
  required Uint8List conversationKey,
});
```

### ReactionService

```dart
// Add or toggle reaction
Future<Result<void, AppError>> addReaction({
  required String messageId,
  required String emoji,
});

// Remove reaction
Future<Result<void, AppError>> removeReaction({
  required String messageId,
  required String emoji,
});

// Get reactions for a message
Future<Result<List<ReactionSummary>, AppError>> getReactions({
  required String messageId,
});

// Real-time subscription
Stream<List<ReactionSummary>> subscribeToReactions(String messageId);
```

---

## Developer Notes

- **No gradients**: Design follows flat, modern UI principles
- **Riverpod**: All state management uses Riverpod providers
- **E2EE maintained**: Reply metadata is minimal, reactions are non-sensitive
- **Clean architecture**: Services layer handles all business logic
- **Testable**: All crypto functions have unit tests

For questions or issues, refer to the main documentation in `.github/copilot-instructions.md`.
