/// Chat Screen
/// One-to-one or group encrypted chat interface
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../models/message.dart';
import '../models/message_reaction.dart';
import '../services/conversation_service.dart';
import '../services/message_service.dart';
import '../../realtime/services/typing_service.dart';
import '../../media/presentation/media_picker_widget.dart';
import '../../media/services/media_service.dart';
import '../../presentation/widgets/empty_state.dart';
import 'widgets/message_date_separator.dart';
import 'widgets/message_menu.dart';
import 'widgets/media_message_bubble.dart';
import 'widgets/reaction_picker.dart';
import 'widgets/message_reactions.dart';
import '../services/reaction_service.dart';
import 'search_messages_screen.dart';
import 'forward_message_screen.dart';
import 'message_info_screen.dart';
import '../../core/utils/text_direction_helper.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String conversationName;
  final bool isAnonymous;
  final DateTime? sessionExpiresAt;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.conversationName,
    this.isAnonymous = false,
    this.sessionExpiresAt,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode(); // Add FocusNode

  List<DecryptedMessage> _messages = [];
  Uint8List? _conversationKey;
  bool _isLoading = true;
  bool _isSending = false;
  List<String> _typingUsers = [];
  bool _isTyping = false;
  bool _hasMoreMessages = true;
  static const int _messagesPerPage = 50;
  Map<String, List<String>> _readStatus = {}; // messageId -> list of user IDs
  DecryptedMessage? _replyingTo; // Message being replied to
  ui.TextDirection _inputTextDirection =
      ui.TextDirection.ltr; // Track input field text direction

  @override
  void initState() {
    super.initState();
    _loadConversation();
    _subscribeToTyping();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Mark messages as read when they become visible
    if (_scrollController.hasClients && _messages.isNotEmpty) {
      final lastMessage = _messages.last;
      _markLastVisibleAsRead(lastMessage.id);
    }
  }

  Future<void> _markLastVisibleAsRead(String messageId) async {
    final messageService = ref.read(messageServiceProvider);
    await messageService.markAsRead(
      conversationId: widget.conversationId,
      messageId: messageId,
    );
  }

  void _subscribeToTyping() {
    final typingService = ref.read(typingServiceProvider);
    typingService.subscribeToTyping(widget.conversationId).listen((userIds) {
      if (mounted) {
        setState(() {
          final currentUserId = Supabase.instance.client.auth.currentUser?.id;
          _typingUsers = userIds.where((id) => id != currentUserId).toList();
        });
      }
    });
  }

  void _onTextChanged(String text) {
    final typingService = ref.read(typingServiceProvider);
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      typingService.startTyping(widget.conversationId);
    } else if (text.isEmpty && _isTyping) {
      _isTyping = false;
      typingService.stopTyping(widget.conversationId);
    }

    // Update text direction based on content
    final newDirection = startsWithArabic(text)
        ? ui.TextDirection.rtl
        : ui.TextDirection.ltr;
    if (newDirection != _inputTextDirection) {
      setState(() {
        _inputTextDirection = newDirection;
      });
    }
  }

  @override
  void dispose() {
    if (_isTyping) {
      final typingService = ref.read(typingServiceProvider);
      typingService.stopTyping(widget.conversationId);
    }
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose(); // Dispose FocusNode
    super.dispose();
  }

  Future<void> _loadConversation() async {
    final conversationService = ref.read(conversationServiceProvider);
    final messageService = ref.read(messageServiceProvider);

    // Get conversation with key
    final convResult = await conversationService.getConversation(
      widget.conversationId,
    );

    if (convResult.isFailure) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load conversation')));
      }
      return;
    }

    final convWithKey = convResult.valueOrNull!;
    _conversationKey = convWithKey.key;

    // Load messages
    final messagesResult = await messageService.fetchMessages(
      conversationId: widget.conversationId,
      conversationKey: _conversationKey!,
      limit: _messagesPerPage,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (messagesResult.isSuccess) {
          final newMessages = messagesResult.valueOrNull ?? [];
          _messages = newMessages;
          _hasMoreMessages = newMessages.length == _messagesPerPage;
        }
      });

      // Load read status
      _loadReadStatus();

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _loadReadStatus() async {
    final messageService = ref.read(messageServiceProvider);
    final result = await messageService.getReadStatus(
      conversationId: widget.conversationId,
    );

    if (result.isSuccess && mounted) {
      setState(() {
        _readStatus = result.valueOrNull ?? {};
      });
    }
  }

  Future<void> _loadMoreMessages() async {
    if (!_hasMoreMessages || _conversationKey == null || _messages.isEmpty) {
      return;
    }

    final messageService = ref.read(messageServiceProvider);

    // Get oldest message timestamp for pagination
    final oldestMessage = _messages.first;

    final messagesResult = await messageService.fetchMessages(
      conversationId: widget.conversationId,
      conversationKey: _conversationKey!,
      limit: _messagesPerPage,
      before: oldestMessage.createdAt,
    );

    if (mounted && messagesResult.isSuccess) {
      setState(() {
        final newMessages = messagesResult.valueOrNull ?? [];
        _messages.insertAll(0, newMessages);
        _hasMoreMessages = newMessages.length == _messagesPerPage;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _conversationKey == null) {
      return;
    }

    final content = _messageController.text.trim();
    final replyToId = _replyingTo?.id;

    _messageController.clear();
    setState(() {
      _isSending = true;
      _replyingTo = null; // Clear reply state
    });

    final messageService = ref.read(messageServiceProvider);
    final result = await messageService.sendMessage(
      conversationId: widget.conversationId,
      content: content,
      conversationKey: _conversationKey!,
      replyToId: replyToId,
    );

    setState(() => _isSending = false);

    if (result.isSuccess) {
      // Reload messages to show the new one
      await _loadConversation();
    } else {
      if (mounted) {
        final errorMessage = result.errorOrNull?.message ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $errorMessage')),
        );
      }
    }
  }

  void _showMediaPicker(BuildContext context) {
    MediaPickerWidget.show(
      context,
      onFilePicked: (file, type) async {
        await _sendMediaMessage(file.path, type);
      },
    );
  }

  Future<void> _sendMediaMessage(String filePath, String mediaType) async {
    if (_conversationKey == null) return;

    setState(() => _isSending = true);

    final mediaService = ref.read(mediaServiceProvider);

    // Upload encrypted file
    final uploadResult = await mediaService.encryptAndUpload(
      file: File(filePath),
      conversationId: widget.conversationId,
    );

    if (uploadResult.isFailure) {
      setState(() => _isSending = false);
      if (mounted) {
        final errorMessage =
            uploadResult.errorOrNull?.message ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload media: $errorMessage')),
        );
      }
      return;
    }

    final mediaUrl = uploadResult.valueOrNull!;

    // Send message with media reference
    final messageService = ref.read(messageServiceProvider);
    final result = await messageService.sendMessage(
      conversationId: widget.conversationId,
      content: '[${mediaType == 'image' ? 'Image' : 'File'}] $mediaUrl',
      conversationKey: _conversationKey!,
    );

    setState(() => _isSending = false);

    if (result.isSuccess) {
      await _loadConversation();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.conversationName),
            _typingUsers.isNotEmpty
                ? Text(
                    '${_typingUsers.length > 1 ? '${_typingUsers.length} people are' : 'Someone is'} typing...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Text(
                    'Encrypted',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.success),
                  ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final messageId = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => SearchMessagesScreen(
                    conversationId: widget.conversationId,
                    messages: _messages,
                  ),
                ),
              );

              // TODO: Scroll to message if messageId is returned
              if (messageId != null) {
                // Find and scroll to message
                final index = _messages.indexWhere((m) => m.id == messageId);
                if (index != -1 && _scrollController.hasClients) {
                  // Scroll to approximate position
                  _scrollController.animateTo(
                    index * 80.0, // Approximate message height
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show conversation settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Anonymous session banner
          if (widget.isAnonymous && widget.sessionExpiresAt != null)
            _buildAnonymousBanner(),

          // Messages list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? EmptyState(
                    icon: Icons.lock_outlined,
                    title: 'No messages yet',
                    subtitle: 'Start an encrypted conversation',
                  )
                : RefreshIndicator(
                    onRefresh: _loadMoreMessages,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(AppTheme.spacing16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final currentUser =
                            Supabase.instance.client.auth.currentUser;
                        final isMe = message.senderId == currentUser?.id;

                        // Find replied-to message if available locally
                        DecryptedMessage? replyToMessage;
                        if (message.replyToId != null) {
                          try {
                            replyToMessage = _messages.firstWhere(
                              (m) => m.id == message.replyToId,
                            );
                          } catch (_) {
                            // Message not in current list
                          }
                        }

                        // Show date separator if this is the first message
                        // or if the date changed from previous message
                        bool showDateSeparator = false;
                        if (index == 0) {
                          showDateSeparator = true;
                        } else {
                          final prevMessage = _messages[index - 1];
                          final currentDate = DateTime(
                            message.createdAt!.year,
                            message.createdAt!.month,
                            message.createdAt!.day,
                          );
                          final prevDate = DateTime(
                            prevMessage.createdAt!.year,
                            prevMessage.createdAt!.month,
                            prevMessage.createdAt!.day,
                          );
                          showDateSeparator = currentDate != prevDate;
                        }

                        return Dismissible(
                          key: Key('reply_${message.id}'),
                          direction: DismissDirection.startToEnd,
                          confirmDismiss: (direction) async {
                            setState(() {
                              _replyingTo = message;
                            });
                            _focusNode.requestFocus();
                            return false;
                          },
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            color: Colors.transparent,
                            child: Icon(
                              Icons.reply,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (showDateSeparator &&
                                  message.createdAt != null)
                                MessageDateSeparator(date: message.createdAt!),
                              _MessageBubble(
                                message: message,
                                replyToMessage: replyToMessage,
                                isMe: isMe,
                                readByUserIds: _readStatus[message.id] ?? [],
                                conversationKey: _conversationKey!,
                                onLongPress: (BuildContext bubbleContext) {
                                  // Show quick reactions on long press
                                  // Get the position of the message bubble
                                  final RenderBox? box =
                                      bubbleContext.findRenderObject()
                                          as RenderBox?;
                                  final Offset? position = box?.localToGlobal(
                                    Offset.zero,
                                  );
                                  final Size? size = box?.size;

                                  ReactionPicker.showQuick(
                                    context: context,
                                    position: position,
                                    size: size,
                                    isMe: isMe,
                                    onReactionSelected: (emoji) async {
                                      final reactionService = ref.read(
                                        reactionServiceProvider,
                                      );
                                      await reactionService.addReaction(
                                        messageId: message.id,
                                        emoji: emoji,
                                      );
                                    },
                                  );
                                },
                                onDoubleTap: () {
                                  // Double tap to like (heart)
                                  final reactionService = ref.read(
                                    reactionServiceProvider,
                                  );
                                  reactionService.addReaction(
                                    messageId: message.id,
                                    emoji: '\u2764\ufe0f',
                                  );
                                },
                                onShowMenu: () {
                                  MessageMenu.show(
                                    context: context,
                                    messageContent: message.content,
                                    isMe: isMe,
                                    onReply: () {
                                      setState(() {
                                        _replyingTo = message;
                                      });
                                      _focusNode.requestFocus();
                                    },
                                    onReact: () {
                                      ReactionPicker.show(
                                        context: context,
                                        onReactionSelected: (emoji) async {
                                          final reactionService = ref.read(
                                            reactionServiceProvider,
                                          );
                                          await reactionService.addReaction(
                                            messageId: message.id,
                                            emoji: emoji,
                                          );
                                        },
                                      );
                                    },
                                    onForward: () {
                                      _showForwardDialog(message);
                                    },
                                    onInfo: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MessageInfoScreen(
                                                message: message,
                                              ),
                                        ),
                                      );
                                    },
                                    onDelete: () {
                                      // TODO: Implement message deletion
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Delete - Coming soon'),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),

          // Reply preview (if replying to a message)
          if (_replyingTo != null)
            Container(
              padding: EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Replying to ${_replyingTo!.senderName ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _replyingTo!.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() => _replyingTo = null);
                    },
                  ),
                ],
              ),
            ),

          // Message input
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.all(AppTheme.spacing12),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () {
                      _showMediaPicker(context);
                    },
                  ),
                  Expanded(
                    child: Directionality(
                      textDirection: _inputTextDirection,
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode, // Attach FocusNode
                        decoration: InputDecoration(
                          hintText: 'Message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusLarge,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing16,
                            vertical: AppTheme.spacing12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onChanged: _onTextChanged,
                        onSubmitted: (_) {
                          _sendMessage();
                          if (_isTyping) {
                            final typingService = ref.read(
                              typingServiceProvider,
                            );
                            typingService.stopTyping(widget.conversationId);
                            _isTyping = false;
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing8),
                  IconButton.filled(
                    icon: _isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    onPressed: _isSending ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForwardDialog(DecryptedMessage message) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ForwardMessageScreen(message: message),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message forwarded successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildAnonymousBanner() {
    final expiresIn = widget.sessionExpiresAt!.difference(DateTime.now());
    final hoursLeft = expiresIn.inHours;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_clock,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: Text(
              hoursLeft < 1
                  ? 'Anonymous session expires in ${expiresIn.inMinutes}m'
                  : 'Anonymous session expires in ${expiresIn.inHours}h',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.shield_outlined,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends ConsumerStatefulWidget {
  final DecryptedMessage message;
  final DecryptedMessage? replyToMessage;
  final bool isMe;
  final List<String> readByUserIds;
  final void Function(BuildContext)? onLongPress;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onShowMenu;
  final Uint8List conversationKey;

  const _MessageBubble({
    required this.message,
    this.replyToMessage,
    required this.isMe,
    required this.readByUserIds,
    this.onLongPress,
    this.onDoubleTap,
    this.onShowMenu,
    required this.conversationKey,
  });

  @override
  ConsumerState<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<_MessageBubble> {
  List<ReactionSummary> _reactions = [];
  StreamSubscription? _reactionSubscription;
  DecryptedMessage? _fetchedReplyMessage;

  @override
  void initState() {
    super.initState();
    _loadReactions();
    _subscribeToReactions();
    _loadReplyMessageIfNeeded();
  }

  @override
  void didUpdateWidget(_MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.id != widget.message.id) {
      _reactionSubscription?.cancel();
      _loadReactions();
      _subscribeToReactions();
    }
    if (widget.replyToMessage == null &&
        widget.message.replyToId != null &&
        _fetchedReplyMessage == null) {
      _loadReplyMessageIfNeeded();
    }
  }

  @override
  void dispose() {
    _reactionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadReplyMessageIfNeeded() async {
    if (widget.replyToMessage != null || widget.message.replyToId == null) {
      return;
    }

    final messageService = ref.read(messageServiceProvider);
    final result = await messageService.getMessage(
      messageId: widget.message.replyToId!,
      conversationKey: widget.conversationKey,
    );

    if (result.isSuccess && mounted) {
      setState(() {
        _fetchedReplyMessage = result.valueOrNull;
      });
    }
  }

  void _subscribeToReactions() {
    final reactionService = ref.read(reactionServiceProvider);
    _reactionSubscription = reactionService
        .subscribeToReactions(widget.message.id)
        .listen((reactions) {
          if (mounted) {
            setState(() {
              _reactions = reactions;
            });
          }
        });
  }

  Future<void> _loadReactions() async {
    final reactionService = ref.read(reactionServiceProvider);
    final result = await reactionService.getReactions(
      messageId: widget.message.id,
    );

    if (result.isSuccess && mounted) {
      final reactions = result.valueOrNull ?? [];
      setState(() {
        _reactions = reactions;
      });
    }
  }

  void _handleReactionTap(String emoji) async {
    final reactionService = ref.read(reactionServiceProvider);
    await reactionService.addReaction(
      messageId: widget.message.id,
      emoji: emoji,
    );
    await _loadReactions();
  }

  void _showReactionPicker() {
    ReactionPicker.show(
      context: context,
      onReactionSelected: (emoji) async {
        final reactionService = ref.read(reactionServiceProvider);
        await reactionService.addReaction(
          messageId: widget.message.id,
          emoji: emoji,
        );
        await _loadReactions();
      },
    );
  }

  Widget _buildMessageContent(
    BuildContext context,
    DecryptedMessage message,
    bool isMe,
  ) {
    // Check if this is a media message
    if (message.type != MessageType.text && message.metadata != null) {
      return MediaMessageBubble(message: message, isMe: isMe);
    }

    // Default text message
    // Determine text direction based on first character
    final textDir = startsWithArabic(message.content)
        ? ui.TextDirection.rtl
        : ui.TextDirection.ltr;

    return Directionality(
      textDirection: textDir,
      child: Text(
        message.content,
        style: TextStyle(
          color: isMe
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (bubbleContext) => GestureDetector(
        onLongPress: () {
          widget.onLongPress?.call(bubbleContext);
        },
        onDoubleTap: widget.onDoubleTap,
        child: Padding(
          padding: EdgeInsets.only(bottom: AppTheme.spacing8),
          child: Row(
            mainAxisAlignment: widget.isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.isMe) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    (widget.message.senderName ?? 'U')[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.spacing8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing16,
                        vertical: AppTheme.spacing12,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isMe
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusLarge,
                        ),
                        border: widget.isMe
                            ? null
                            : Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!widget.isMe &&
                              widget.message.senderName != null) ...[
                            Text(
                              widget.message.senderName!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: 4),
                          ],
                          // Show replied-to message if exists
                          if (widget.message.replyToId != null)
                            _buildReplyPreview(
                              context,
                              widget.message.replyToId!,
                            ),
                          // Show media or text content
                          _buildMessageContent(
                            context,
                            widget.message,
                            widget.isMe,
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(widget.message.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.isMe
                                      ? Theme.of(context).colorScheme.onPrimary
                                            .withValues(alpha: 0.7)
                                      : Theme.of(context).colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                ),
                              ),
                              if (widget.isMe) ...[
                                SizedBox(width: 4),
                                _buildReadStatusIcon(context),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Reactions display - ALWAYS show (with + button)
                    MessageReactions(
                      reactions: _reactions,
                      onReactionTap: _handleReactionTap,
                      onAddReaction: _showReactionPicker,
                    ),
                  ],
                ),
              ),
              if (widget.isMe) SizedBox(width: AppTheme.spacing48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyPreview(BuildContext context, String replyToId) {
    final replyMessage = widget.replyToMessage ?? _fetchedReplyMessage;
    final hasContent = replyMessage != null;
    final senderName = hasContent
        ? (replyMessage.senderName ?? 'Unknown')
        : 'Loading...';

    String content = 'Message not found';
    if (hasContent) {
      if (replyMessage.type == MessageType.text) {
        content = replyMessage.content;
      } else {
        content = '[${replyMessage.type.name.toUpperCase()}]';
      }
    }

    return GestureDetector(
      onTap: () {
        // TODO: Scroll to message
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border(
            left: BorderSide(
              color: widget.isMe
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              senderName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: widget.isMe
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Directionality(
              textDirection: startsWithArabic(content)
                  ? ui.TextDirection.rtl
                  : ui.TextDirection.ltr,
              child: Text(
                content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: widget.isMe
                      ? Theme.of(
                          context,
                        ).colorScheme.onPrimary.withValues(alpha: 0.8)
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadStatusIcon(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final othersRead = widget.readByUserIds
        .where((id) => id != currentUserId)
        .toList();

    IconData icon;
    Color color = Theme.of(
      context,
    ).colorScheme.onPrimary.withValues(alpha: 0.7);

    switch (widget.message.status) {
      case MessageStatus.sending:
        icon = Icons.schedule;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Theme.of(context).colorScheme.error;
        break;
    }

    if (othersRead.isNotEmpty) {
      icon = Icons.done_all;
      color = Colors.blue;
    }

    return Icon(icon, size: 14, color: color);
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday ${DateFormat('HH:mm').format(time)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(time);
    }
  }
}
