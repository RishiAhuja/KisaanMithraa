import 'package:cropconnect/features/chatbot/data/service/speech_service.dart';
import 'package:cropconnect/features/chatbot/domain/models/chat_message_model.dart';
import 'package:cropconnect/features/chatbot/presentation/controllers/chatbot_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  TextStyle _getLanguageTextStyle(BuildContext context, bool isUser) {
    final controller = Get.find<ChatbotController>();
    final baseStyle = TextStyle(
      color: isUser ? Colors.white : Colors.black87,
      fontSize: 14,
      height: 1.4,
      letterSpacing: 0.1,
    );

    switch (controller.currentLanguage.value) {
      case 'hi':
        return GoogleFonts.notoSansDevanagari(textStyle: baseStyle);
      case 'pa':
        return GoogleFonts.notoSansGurmukhi(textStyle: baseStyle);
      default:
        return GoogleFonts.notoSans(textStyle: baseStyle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.brightness == Brightness.light
                        ? Colors.white
                        : theme.colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 18 : 4),
                  topRight: Radius.circular(isUser ? 4 : 18),
                  bottomLeft: const Radius.circular(18),
                  bottomRight: const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 18 : 4),
                  topRight: Radius.circular(isUser ? 4 : 18),
                  bottomLeft: const Radius.circular(18),
                  bottomRight: const Radius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser) _buildBubbleHeader(context),
                    _buildMessageContent(context, isUser),
                    if (!isUser &&
                        message.navigations != null &&
                        message.navigations!.isNotEmpty)
                      _buildNavigationButton(context),
                    _buildMessageFooter(context, isUser),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.smart_toy_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Kisaan Mithraa',
            style: TextStyle(
              color: theme.colorScheme.primary.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          _buildTtsButton(context),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, bool isUser) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Obx(() => MarkdownBody(
            data: message.text,
            styleSheet: MarkdownStyleSheet(
              p: _getLanguageTextStyle(context, isUser),
              blockquote: _getLanguageTextStyle(context, isUser).copyWith(
                color: isUser ? Colors.white70 : Colors.black54,
                fontStyle: FontStyle.italic,
              ),
              code: _getLanguageTextStyle(context, isUser).copyWith(
                backgroundColor: isUser
                    ? Colors.white.withOpacity(0.2)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                color: isUser
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
              listBullet: _getLanguageTextStyle(context, isUser),
              h1: _getLanguageTextStyle(context, isUser).copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              h2: _getLanguageTextStyle(context, isUser).copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              h3: _getLanguageTextStyle(context, isUser).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              em: _getLanguageTextStyle(context, isUser).copyWith(
                fontStyle: FontStyle.italic,
              ),
              strong: _getLanguageTextStyle(context, isUser).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            onTapLink: (text, href, title) {
              // Handle link taps
            },
          )),
    );
  }

  Widget _buildMessageFooter(BuildContext context, bool isUser) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 8),
      decoration: BoxDecoration(
        color: isUser
            ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
            : Theme.of(context).brightness == Brightness.light
                ? Color(0xFFF8F8F8)
                : Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Spacer(),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              fontSize: 10,
              color: isUser
                  ? Colors.white.withOpacity(0.7)
                  : Colors.black.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTtsButton(BuildContext context) {
    final SpeechService speechService = Get.find<SpeechService>();

    return StreamBuilder<double>(
        stream: speechService.volumeController,
        initialData: 0.0,
        builder: (context, snapshot) {
          final isActive = (snapshot.data ?? 0.0) > 0.0;
          return Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              iconSize: 14,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              icon: Icon(
                isActive ? Icons.pause : Icons.volume_up,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                size: 14,
              ),
              onPressed: () {
                if (isActive) {
                  speechService.stop();
                } else {
                  speechService.speak(message.text);
                }
              },
            ),
          );
        });
  }

  Widget _buildNavigationButton(BuildContext context) {
    if (message.navigations == null || message.navigations!.isEmpty) {
      return SizedBox.shrink();
    }

    // Get the navigation route
    String navigationRoute = '/podcasts';
    if (message.navigations!.contains('/podcasts')) {
      navigationRoute = '/podcasts';
    } else if (message.navigations!.length > 1) {
      navigationRoute = message.navigations![1];
    } else if (message.navigations!.isNotEmpty) {
      navigationRoute = message.navigations![0];
    }

    Widget icon = _getIconForRoute(navigationRoute);
    String label = _getLabelForRoute(navigationRoute);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
      color: theme.brightness == Brightness.light
          ? Color(0xFFF8F8F8)
          : theme.colorScheme.primaryContainer.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 20, thickness: 0.5),
          Text(
            'Related Content',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            color: theme.colorScheme.primary.withOpacity(0.05),
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                Get.toNamed(navigationRoute);
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          color: theme.colorScheme.primary,
                          size: 16,
                        ),
                        child: icon,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            _getDescriptionForRoute(navigationRoute),
                            style: TextStyle(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get appropriate icon for each route
  Widget _getIconForRoute(String route) {
    switch (route) {
      case '/podcasts':
        return Icon(Icons.headset, size: 16);
      case '/community':
        return Icon(Icons.people, size: 16);
      case '/marketplace':
        return Icon(Icons.shopping_cart, size: 16);
      case '/resources':
        return Icon(Icons.book, size: 16);
      case '/weather':
        return Icon(Icons.cloud, size: 16);
      default:
        return Icon(Icons.arrow_forward, size: 16);
    }
  }

  String _getLabelForRoute(String route) {
    switch (route) {
      case '/podcasts':
        return 'Listen to our Podcast';
      case '/community':
        return 'Join Discussion';
      case '/marketplace':
        return 'Go to Marketplace';
      case '/resources':
        return 'Explore Resources';
      case '/weather':
        return 'Check Weather';
      default:
        return 'Learn More';
    }
  }

  String _getDescriptionForRoute(String route) {
    switch (route) {
      case '/podcasts':
        return 'Audio content on farming topics';
      case '/community':
        return 'Connect with other farmers';
      case '/marketplace':
        return 'Buy and sell farm products';
      case '/resources':
        return 'Farming guides and resources';
      case '/weather':
        return 'Check local weather forecasts';
      default:
        return 'Related information';
    }
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

extension ChatBubbleTTSExtension on ChatBubble {
  Widget buildWithTTS(BuildContext context, SpeechService speechService) {
    return ChatBubble(message: message);
  }
}
