import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/chatbot/data/service/speech_service.dart';
import 'package:cropconnect/features/chatbot/presentation/controllers/chatbot_controller.dart';
import 'package:cropconnect/features/chatbot/presentation/widgets/chat_bubble.dart';
import 'package:cropconnect/features/chatbot/presentation/widgets/speech_popup.dart';
import 'package:cropconnect/features/chatbot/presentation/widgets/suggestion_chip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatbotScreen extends GetView<ChatbotController> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final RxBool _isServiceReady = false.obs;
  late final SpeechService _speechService;

  ChatbotScreen({super.key}) {
    checkMicrophonePermission();
    _initializeServices();
  }

  Future<bool> checkMicrophonePermission() async {
    if (await Permission.microphone.status.isDenied) {
      final status = await Permission.microphone.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> _initializeServices() async {
    _speechService = SpeechService();
    if (!Get.isRegistered<SpeechService>()) {
      Get.put(_speechService, permanent: true);
    }

    // Auto-enable after timeout
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isServiceReady.value) {
        _isServiceReady.value = true;
      }
    });

    try {
      await _speechService.initializeSpeech();
      if (_speechService.isInitialized.value) {
        await _speechService.setLanguage(controller.currentLanguage.value);
        _isServiceReady.value = true;
      } else {
        _isServiceReady.value = true;
      }
    } catch (e) {
      _isServiceReady.value = true;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutQuart,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.colorScheme.background,
      appBar: _buildAppBar(context, appLocalizations, theme),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildChatArea(context),
                _buildSuggestionsBar(context),
                _buildInputField(context),
                SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 6),
              ],
            ),
            _buildSpeechRecognitionOverlay(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context,
      AppLocalizations? appLocalizations, ThemeData theme) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.agriculture_rounded,
            size: 20,
            color: theme.colorScheme.onPrimary.withOpacity(0.9),
          ),
          const SizedBox(width: 8),
          Text(
            appLocalizations?.chatbotTitle ?? 'Kisaan Mithraa',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      actions: [
        _buildResetButton(appLocalizations, theme),
      ],
    );
  }

  Widget _buildResetButton(
      AppLocalizations? appLocalizations, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: const Icon(
          Icons.refresh_rounded,
          size: 18,
        ),
        tooltip: appLocalizations?.resetConversation ?? 'Reset Conversation',
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.primaryFixed,
          foregroundColor: AppColors.backgroundLight,
          padding: const EdgeInsets.all(8),
        ),
        onPressed: () {
          controller.resetConversation();
          HapticFeedback.mediumImpact();
        },
      ),
    );
  }

  Widget _buildChatArea(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final displayMessages = controller.messages.toList();
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return displayMessages.isEmpty
            ? _buildEmptyState(context)
            : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(10, 14, 10, 20),
                  itemCount: displayMessages.length,
                  itemBuilder: (context, index) {
                    final message = displayMessages[index];
                    return ChatBubble(message: message);
                  },
                ),
              );
      }),
    );
  }

  Widget _buildSpeechRecognitionOverlay() {
    return Obx(() => Positioned.fill(
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
        ));
  }

  Widget _buildEmptyState(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmptyStateIcon(theme),
            const SizedBox(height: 20),
            Text(
              appLocalizations?.farmingAssistant ?? 'Your Farming Assistant',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations?.askAnything ?? 'Ask me anything about farming',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            _buildSpeakButton(context, appLocalizations, theme),
            const SizedBox(height: 30),
            _buildSuggestedQuestions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateIcon(ThemeData theme) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withOpacity(0.1),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSpeakButton(BuildContext context,
      AppLocalizations? appLocalizations, ThemeData theme) {
    return Obx(() => ElevatedButton.icon(
          icon: Icon(
            Icons.mic_rounded,
            color: Colors.white,
            size: 18,
          ),
          label: Text(
            _isServiceReady.value
                ? appLocalizations?.startSpeaking ?? 'Start Speaking'
                : appLocalizations?.initializing ?? 'Initializing...',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          onPressed: _isServiceReady.value
              ? () => _startSpeechRecognition(context)
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            shadowColor: theme.colorScheme.primary.withOpacity(0.3),
          ),
        ));
  }

  Widget _buildSuggestedQuestions(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final questions = [
      appLocalizations?.bestCropsQuestion ??
          'What are the best crops to plant this season?',
      appLocalizations?.pestControlQuestion ??
          'How can I deal with common pests?',
      appLocalizations?.waterConservationQuestion ??
          'How can I conserve water?',
      appLocalizations?.organicFarmingQuestion ?? 'Tips for organic farming?',
    ];

    final icons = [
      Icons.grass_rounded,
      Icons.bug_report_rounded,
      Icons.water_drop_rounded,
      Icons.eco_rounded,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                appLocalizations?.suggestedQuestions ?? 'Try asking:',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(
          questions.length,
          (index) => _buildQuestionCard(
            context,
            theme,
            questions[index],
            icons[index],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(
      BuildContext context, ThemeData theme, String question, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _handleSuggestion(question, context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: theme.colorScheme.primary.withOpacity(0.4),
              ),
            ],
          ),
        ),
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    controller.isListeningToSpeech.value = true;
    HapticFeedback.mediumImpact();

    try {
      await _speechService.startListening((recognizedText) {
        if (recognizedText.isNotEmpty) {
          _textController.text = recognizedText;
        }
        controller.isListeningToSpeech.value = false;
      });
    } catch (e) {
      controller.isListeningToSpeech.value = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${appLocalizations?.speechError ?? 'Speech recognition error: '}${e.toString()}'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildSuggestionsBar(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    final suggestions = [
      QuickSuggestion(
          label: appLocalizations?.bestCrops ?? 'Best crops for this season',
          question: appLocalizations?.bestCropsQuestion ??
              'What are the best crops to plant this season?'),
      QuickSuggestion(
          label: appLocalizations?.pestControl ?? 'Pest control tips',
          question: appLocalizations?.pestControlQuestion ??
              'How can I deal with common pests?'),
      QuickSuggestion(
          label: appLocalizations?.waterConservation ?? 'Water conservation',
          question: appLocalizations?.waterConservationQuestion ??
              'How can I conserve water?'),
      QuickSuggestion(
          label: appLocalizations?.organicFarming ?? 'Organic farming',
          question: appLocalizations?.organicFarmingQuestion ??
              'Tips for organic farming?'),
    ];

    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return SuggestionChip(
            label: suggestions[index].label,
            onTap: () =>
                _handleSuggestion(suggestions[index].question, context),
          );
        },
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Changed from end to center
        children: [
          // Microphone Button
          _buildMicButton(context, primaryColor),

          // Vertical divider
          Container(
            height: 24,
            width: 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey.shade200,
          ),

          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: appLocalizations?.askFarmingQuestion ??
                      'Ask anything about farming...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12), // Fixed padding
                  counterText: '',
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),

          // Send button
          _buildSendButton(primaryColor),
        ],
      ),
    );
  }

  Widget _buildMicButton(BuildContext context, Color primaryColor) {
    return Obx(() => Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isServiceReady.value
                ? () => _startSpeechRecognition(context)
                : null,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.mic_rounded,
                    color: _isServiceReady.value
                        ? primaryColor
                        : Colors.grey.shade400,
                    size: 18,
                  ),
                  if (controller.isListeningToSpeech.value)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildSendButton(Color primaryColor) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final isEmpty = _textController.text.trim().isEmpty;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isEmpty ? Colors.grey.shade100 : primaryColor,
          shape: BoxShape.circle,
          boxShadow: isEmpty
              ? []
              : [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final text = _textController.text.trim();
              if (text.isNotEmpty && !isLoading) {
                _sendMessage(text);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 18,
                        height: 18,
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
                            ? primaryColor.withOpacity(0.4)
                            : Colors.white,
                        size: 18,
                      ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isNotEmpty) {
      HapticFeedback.mediumImpact();
      controller.sendMessage(text);
      _textController.clear();
      FocusScope.of(Get.context!).unfocus();
    }
  }

  void _handleSuggestion(String suggestion, BuildContext context) {
    _textController.text = suggestion;
    FocusScope.of(context).requestFocus(FocusNode());
  }
}

extension ChatbotControllerExtension on ChatbotController {
  void resetConversation() {
    messages.clear();
  }
}
