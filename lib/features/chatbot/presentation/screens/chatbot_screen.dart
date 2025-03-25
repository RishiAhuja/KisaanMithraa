import 'package:cropconnect/core/presentation/widgets/bottom_nav_bar.dart';
import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/chatbot/data/service/speech_service.dart';
import 'package:cropconnect/features/chatbot/domain/models/chat_message_model.dart';
import 'package:cropconnect/features/chatbot/presentation/controllers/chatbot_controller.dart';
import 'package:cropconnect/features/chatbot/presentation/widgets/speech_popup.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class ChatbotScreen extends GetView<ChatbotController> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final RxBool _isServiceReady = false.obs;
  late final SpeechService _speechService;

  ChatbotScreen() {
    checkMicrophonePermission();
    _initializeServices();
  }

  Future<bool> checkMicrophonePermission() async {
    AppLogger.debug('checking microphone permission');
    if (await Permission.microphone.status.isDenied) {
      AppLogger.debug('requesting microphone permission');
      final status = await Permission.microphone.request();
      AppLogger.debug('requesting microphone granted');
      return status.isGranted;
    }
    return true;
  }

  Future<void> _initializeServices() async {
    _speechService = SpeechService();
    if (!Get.isRegistered<SpeechService>()) {
      Get.put(_speechService, permanent: true);
    }

    AppLogger.debug('ChatbotScreen: Starting speech service initialization');

    Future.delayed(const Duration(seconds: 6), () {
      if (!_isServiceReady.value) {
        AppLogger.debug(
            'ChatbotScreen: Forcing service ready state after timeout');
        _isServiceReady.value = true;
      }
    });

    try {
      await _speechService.initializeSpeech();

      if (_speechService.isInitialized.value) {
        AppLogger.debug(
            'ChatbotScreen: Speech service initialized successfully');
        await _speechService.setLanguage(controller.currentLanguage.value);
        _isServiceReady.value = true;
      } else {
        AppLogger.debug(
            'ChatbotScreen: Speech service initialization failed, setting ready anyway');
        _isServiceReady.value = true;
      }
    } catch (e) {
      AppLogger.error('ChatbotScreen: Error during initialization: $e');
      _isServiceReady.value = true;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      extendBody: true,
      appBar: AppBar(
        title: Text(appLocalizations?.appTitle ?? 'Kisan Mitra'),
        elevation: 0,
        actions: [
          Obx(() {
            if (_isServiceReady.value && _speechService.isInitialized.value) {
              _speechService.setLanguage(controller.currentLanguage.value);
            }
            return TextButton.icon(
              icon: const Icon(Icons.language),
              label: Text(
                controller.getCurrentLanguageName(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                if (_isServiceReady.value) {
                  _speechService.setLanguage(controller.currentLanguage.value);
                }
              },
            );
          }),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.resetConversation();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Obx(() {
                  final displayMessages = controller.messages.toList();

                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());

                  return displayMessages.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: displayMessages.length,
                          itemBuilder: (context, index) {
                            final message = displayMessages[index];
                            return ChatBubble(message: message);
                          },
                        );
                }),
              ),
              _buildSuggestionsBar(context),
              _buildInputField(context),
              const SizedBox(height: 60),
            ],
          ),
          Obx(() => Positioned.fill(
                child: _isServiceReady.value
                    ? SpeechRecognitionPopup(
                        isListening: controller.isListeningToSpeech.value,
                        onCancel: () {
                          _speechService.stopListening();
                          controller.isListeningToSpeech.value = false;
                        },
                        volumeStream: _speechService.volumeController,
                      )
                    : const SizedBox.shrink(),
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 60,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            appLocalizations?.askAnything ?? 'Ask me anything about farming',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          Obx(() => ElevatedButton.icon(
                icon: Icon(Icons.mic, color: AppColors.backgroundLight),
                label: Text(_isServiceReady.value
                    ? appLocalizations?.startSpeaking ?? 'Start Speaking'
                    : appLocalizations?.initializing ?? 'Initializing...'),
                onPressed: _isServiceReady.value
                    ? () => _startSpeechRecognition(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _startSpeechRecognition(BuildContext context) async {
    final appLocalizations = AppLocalizations.of(context);

    if (!_isServiceReady.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations?.speechInitializing ??
              'Speech recognition is initializing. Please wait...'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    AppLogger.debug('Starting speech recognition');

    controller.isListeningToSpeech.value = true;
    HapticFeedback.mediumImpact();

    try {
      await _speechService.startListening((recognizedText) {
        AppLogger.debug('Recognized text: $recognizedText');

        if (recognizedText.isNotEmpty) {
          _textController.text = recognizedText;

          // Show a brief confirmation toast
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${appLocalizations?.recognized ?? 'Recognized: "'}"$recognizedText"'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }

        controller.isListeningToSpeech.value = false;
      });
    } catch (e) {
      AppLogger.debug('Error in speech recognition: $e');
      controller.isListeningToSpeech.value = false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${appLocalizations?.speechError ?? 'Speech recognition error: '}${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildSuggestionsBar(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          _SuggestionChip(
            label: appLocalizations?.bestCrops ?? 'Best crops for this season',
            onTap: () => _handleSuggestion(
                appLocalizations?.bestCropsQuestion ??
                    'What are the best crops to plant this season?',
                context),
          ),
          const SizedBox(width: 8),
          _SuggestionChip(
            label: appLocalizations?.pestControl ?? 'Pest control tips',
            onTap: () => _handleSuggestion(
                appLocalizations?.pestControlQuestion ??
                    'How can I deal with common pests?',
                context),
          ),
          const SizedBox(width: 8),
          _SuggestionChip(
            label: appLocalizations?.waterConservation ?? 'Water conservation',
            onTap: () => _handleSuggestion(
                appLocalizations?.waterConservationQuestion ??
                    'How can I conserve water?',
                context),
          ),
          const SizedBox(width: 8),
          _SuggestionChip(
            label: appLocalizations?.organicFarming ?? 'Organic farming',
            onTap: () => _handleSuggestion(
                appLocalizations?.organicFarmingQuestion ??
                    'Tips for organic farming?',
                context),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Microphone Button
            Obx(() => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isServiceReady.value
                        ? () => _startSpeechRecognition(context)
                        : null,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.mic,
                        color: _isServiceReady.value
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        size: 22,
                      ),
                    ),
                  ),
                )),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 0, right: 8),
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: appLocalizations?.askFarmingQuestion ??
                        'Ask anything about farming...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      HapticFeedback.mediumImpact();
                      controller.sendMessage(text);
                      _textController.clear();
                    }
                  },
                ),
              ),
            ),
            Obx(() {
              final isLoading = controller.isLoading.value;
              final isEmpty = _textController.text.trim().isEmpty;
              final primaryColor = Theme.of(context).colorScheme.primary;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isEmpty ? Colors.grey.shade200 : primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: isEmpty
                      ? []
                      : [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      final text = _textController.text.trim();
                      if (text.isNotEmpty && !isLoading) {
                        HapticFeedback.mediumImpact();
                        controller.sendMessage(text);
                        _textController.clear();
                        // Request focus to dismiss keyboard
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isLoading
                            ? SizedBox(
                                key: const ValueKey('loading'),
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isEmpty ? primaryColor : Colors.white,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.send_rounded,
                                key: const ValueKey('send'),
                                color: isEmpty
                                    ? primaryColor.withOpacity(0.7)
                                    : Colors.white,
                                size: 22,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _handleSuggestion(String suggestion, BuildContext context) {
    _textController.text = suggestion;
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // void _showImageSourceDialog(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SafeArea(
  //         child: Wrap(
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.photo_library),
  //               title: const Text('Gallery'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 // TODO: Implement gallery picker
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.photo_camera),
  //               title: const Text('Camera'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 // TODO: Implement camera
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.backgroundLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  TextStyle _getLanguageTextStyle(BuildContext context, bool isUser) {
    final controller = Get.find<ChatbotController>();

    switch (controller.currentLanguage.value) {
      case 'hi':
        return GoogleFonts.notoSansDevanagari().copyWith(
          color: isUser ? Colors.white : Colors.black87,
          fontSize: 15,
          height: 1.3,
        );
      case 'pa':
        return GoogleFonts.notoSansGurmukhi(
          color: isUser ? Colors.white : Colors.black87,
          fontSize: 15,
          height: 1.3,
        );
      default:
        return GoogleFonts.notoSans(
          color: isUser ? Colors.white : Colors.black87,
          fontSize: 15,
          height: 1.3,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.smart_toy_rounded,
                size: 16,
                color: AppColors.backgroundLight,
              ),
            ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: isUser ? 40 : 8,
                right: isUser ? 0 : 40,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => MarkdownBody(
                        data: message.text,
                        styleSheet: MarkdownStyleSheet(
                          p: _getLanguageTextStyle(context, isUser),
                          blockquote:
                              _getLanguageTextStyle(context, isUser).copyWith(
                            color: isUser ? Colors.white70 : Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                          code: _getLanguageTextStyle(context, isUser).copyWith(
                            backgroundColor:
                                isUser ? Colors.white24 : Colors.grey[300],
                            color: isUser
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                          ),
                          listBullet: _getLanguageTextStyle(context, isUser),
                          h1: _getLanguageTextStyle(context, isUser).copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          h2: _getLanguageTextStyle(context, isUser).copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          h3: _getLanguageTextStyle(context, isUser).copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          em: _getLanguageTextStyle(context, isUser).copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                          strong:
                              _getLanguageTextStyle(context, isUser).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTapLink: (text, href, title) {
                          // Handle link taps
                        },
                      )),
                  if (!isUser &&
                      message.navigations != null &&
                      message.navigations!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: _buildNavigationButton(context),
                    ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isUser ? Colors.white70 : Colors.black45,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(BuildContext context) {
    // If navigations is empty, return nothing
    if (message.navigations == null || message.navigations!.isEmpty) {
      return SizedBox.shrink();
    }

    // Get the navigation route (we'll use /podcasts or the second navigation route if available)
    String navigationRoute = '/podcasts';

    // If /podcasts specifically exists in navigations, use that
    if (message.navigations!.contains('/podcasts')) {
      navigationRoute = '/podcasts';
    }
    // Otherwise if there's a second navigation, use that
    else if (message.navigations!.length > 1) {
      navigationRoute = message.navigations![1];
    }
    // Last resort: use the first navigation
    else if (message.navigations!.isNotEmpty) {
      navigationRoute = message.navigations![0];
    }

    // Determine the appropriate icon and label
    Widget icon = _getIconForRoute(navigationRoute);
    String label = _getLabelForRoute(navigationRoute);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Text(
          'Related Content:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            Get.toNamed(navigationRoute);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    child: icon,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _getDescriptionForRoute(navigationRoute),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper to get appropriate icon for each route
  Widget _getIconForRoute(String route) {
    switch (route) {
      case '/podcasts':
        return Icon(Icons.headset, size: 18);
      case '/community':
        return Icon(Icons.people, size: 18);
      case '/marketplace':
        return Icon(Icons.shopping_cart, size: 18);
      case '/resources':
        return Icon(Icons.book, size: 18);
      case '/weather':
        return Icon(Icons.cloud, size: 18);
      default:
        return Icon(Icons.arrow_forward, size: 18);
    }
  }

  String _getLabelForRoute(String route) {
    switch (route) {
      case '/podcasts':
        return 'Listen our Podcast';
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

extension ChatbotControllerExtension on ChatbotController {
  void resetConversation() {
    messages.clear();
  }
}

extension ChatBubbleTTSExtension on ChatBubble {
  Widget buildWithTTS(BuildContext context, SpeechService speechService) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.backgroundLight,
              child: Icon(
                Icons.smart_toy_rounded,
                size: 16,
                color: AppColors.backgroundLight,
              ),
            ),
          Flexible(
            child: GestureDetector(
              onTap: isUser ? null : () => speechService.speak(message.text),
              child: Container(
                margin: EdgeInsets.only(
                  left: isUser ? 40 : 8,
                  right: isUser ? 0 : 40,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isUser
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isUser ? 16 : 4),
                    topRight: Radius.circular(isUser ? 4 : 16),
                    bottomLeft: const Radius.circular(16),
                    bottomRight: const Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => MarkdownBody(
                          data: message.text,
                          styleSheet: MarkdownStyleSheet(
                            p: _getLanguageTextStyle(context, isUser),
                            blockquote:
                                _getLanguageTextStyle(context, isUser).copyWith(
                              color: isUser ? Colors.white70 : Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                            code:
                                _getLanguageTextStyle(context, isUser).copyWith(
                              backgroundColor:
                                  isUser ? Colors.white24 : Colors.grey[300],
                              color: isUser
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                            ),
                            listBullet: _getLanguageTextStyle(context, isUser),
                            h1: _getLanguageTextStyle(context, isUser).copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: _getLanguageTextStyle(context, isUser).copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            h3: _getLanguageTextStyle(context, isUser).copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            em: _getLanguageTextStyle(context, isUser).copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                            strong:
                                _getLanguageTextStyle(context, isUser).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTapLink: (text, href, title) {
                            // Handle link taps
                          },
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!isUser)
                          StreamBuilder<double>(
                              stream: speechService.volumeController,
                              initialData: 0.0,
                              builder: (context, snapshot) {
                                final isActive = (snapshot.data ?? 0.0) > 0.0;
                                return IconButton(
                                  iconSize: 16,
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(
                                    isActive ? Icons.pause : Icons.volume_up,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.7),
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    if (isActive) {
                                      speechService.stop();
                                    } else {
                                      speechService.speak(message.text);
                                    }
                                  },
                                );
                              }),
                        Spacer(),
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: isUser ? Colors.white70 : Colors.black45,
                          ),
                        ),
                      ],
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
}
