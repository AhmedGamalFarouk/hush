/// Media Message Bubble Widget
/// Displays image/video/file messages with thumbnails and tap-to-view
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/message.dart';
import '../../../media/services/media_service.dart';

class MediaMessageBubble extends ConsumerStatefulWidget {
  final DecryptedMessage message;
  final bool isMe;

  const MediaMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  ConsumerState<MediaMessageBubble> createState() => _MediaMessageBubbleState();
}

class _MediaMessageBubbleState extends ConsumerState<MediaMessageBubble> {
  File? _cachedFile;
  bool _isDownloading = false;
  final double _downloadProgress = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    if (widget.message.metadata == null) return;

    final mediaUrl = widget.message.metadata!['encrypted_media_url'] as String?;
    if (mediaUrl == null) return;

    setState(() {
      _isDownloading = true;
      _error = null;
    });

    try {
      final mediaService = ref.read(mediaServiceProvider);

      // Parse encrypted media from metadata
      final encryptedMedia = EncryptedMedia.fromJson(widget.message.metadata!);

      // Download and decrypt
      final result = await mediaService.downloadAndDecrypt(
        media: encryptedMedia,
      );

      if (mounted) {
        result.when(
          success: (file) {
            setState(() {
              _cachedFile = file;
              _isDownloading = false;
            });
          },
          failure: (error) {
            setState(() {
              _error = 'Failed to load media';
              _isDownloading = false;
            });
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load media';
          _isDownloading = false;
        });
      }
    }
  }

  void _viewFullScreen() {
    if (_cachedFile == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenMediaViewer(
          file: _cachedFile!,
          messageType: widget.message.type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _cachedFile != null ? _viewFullScreen : null,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250, maxHeight: 300),
        decoration: BoxDecoration(
          color: widget.isMe
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _buildMediaContent(context),
        ),
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    if (_error != null) {
      return _buildErrorState(context);
    }

    if (_isDownloading) {
      return _buildLoadingState(context);
    }

    if (_cachedFile == null) {
      return _buildPlaceholder(context);
    }

    switch (widget.message.type) {
      case MessageType.image:
        return _buildImage();
      case MessageType.video:
        return _buildVideo();
      case MessageType.file:
        return _buildFile(context);
      default:
        return _buildPlaceholder(context);
    }
  }

  Widget _buildImage() {
    return Image.file(
      _cachedFile!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorState(context);
      },
    );
  }

  Widget _buildVideo() {
    // Video thumbnail with play icon
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.file(
          _cachedFile!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.black12,
              child: const Icon(Icons.videocam, size: 64),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
        ),
      ],
    );
  }

  Widget _buildFile(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = widget.message.metadata?['file_name'] ?? 'Unknown file';
    final fileSize = widget.message.metadata?['file_size'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.insert_drive_file,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatFileSize(fileSize),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(value: _downloadProgress),
          const SizedBox(height: 8),
          Text(
            '${(_downloadProgress * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 32),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Failed to load',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _loadMedia, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Icon(Icons.image, size: 48),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Full-screen media viewer
class _FullScreenMediaViewer extends StatelessWidget {
  final File file;
  final MessageType messageType;

  const _FullScreenMediaViewer({required this.file, required this.messageType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: messageType == MessageType.image
            ? InteractiveViewer(child: Image.file(file))
            : messageType == MessageType.video
            ? _buildVideoPlayer()
            : _buildFileViewer(context),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    // Placeholder - would integrate video_player package
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam, size: 64, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Video player integration needed',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFileViewer(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Open with system default app
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open with...'),
          ),
        ],
      ),
    );
  }
}
