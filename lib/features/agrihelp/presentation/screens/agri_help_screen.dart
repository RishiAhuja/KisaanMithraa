import 'package:cropconnect/core/presentation/widgets/bottom_nav_bar.dart';
import 'package:cropconnect/features/agrihelp/domain/models/emergency_contact_model.dart';
import 'package:cropconnect/features/agrihelp/domain/models/faq_model.dart';
import 'package:cropconnect/features/agrihelp/presentation/widgets/emergency_contact_card.dart';
import 'package:cropconnect/features/agrihelp/presentation/widgets/faq_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AgriHelpScreen extends StatelessWidget {
  const AgriHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.agriHelp),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Emergency Section
          _buildSectionHeader(context, localizations.emergencyContacts,
              Icons.emergency_outlined),
          const SizedBox(height: 12),
          _buildEmergencyContactsList(context, localizations),

          const SizedBox(height: 24),

          // FAQ Section
          _buildSectionHeader(context, localizations.frequentlyAskedQuestions,
              Icons.question_answer_outlined),
          const SizedBox(height: 12),
          _buildFAQList(context, localizations),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactsList(
      BuildContext context, AppLocalizations localizations) {
    // Get localized emergency contacts
    final contacts = _getEmergencyContacts(localizations);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        return EmergencyContactCard(
          contact: contacts[index],
          onCall: () => _makePhoneCall(contacts[index].phoneNumber),
        );
      },
    );
  }

  Widget _buildFAQList(BuildContext context, AppLocalizations localizations) {
    // Get localized FAQs
    final faqs = _getFAQs(localizations);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        return FAQItem(faq: faqs[index]);
      },
    );
  }

  List<EmergencyContactModel> _getEmergencyContacts(
      AppLocalizations localizations) {
    return [
      EmergencyContactModel(
        id: 'kisan-call-center',
        name: localizations.kisanCallCenter,
        phoneNumber: '1800-180-1551',
        description: localizations.kisanCallCenterDesc,
        iconName: 'phone',
      ),
      EmergencyContactModel(
        id: 'agri-insurance',
        name: localizations.agriInsuranceHelpline,
        phoneNumber: '1800-11-6666',
        description: localizations.agriInsuranceDesc,
        iconName: 'insurance',
      ),
      EmergencyContactModel(
        id: 'plant-protection',
        name: localizations.plantProtectionHelpline,
        phoneNumber: '1800-425-1429',
        description: localizations.plantProtectionDesc,
        iconName: 'plant',
      ),
      EmergencyContactModel(
        id: 'seed-helpline',
        name: localizations.seedHelpline,
        phoneNumber: '1800-11-1128',
        description: localizations.seedHelplineDesc,
        iconName: 'seed',
      ),
    ];
  }

  List<FAQModel> _getFAQs(AppLocalizations localizations) {
    return [
      FAQModel(
        id: 'faq1',
        question: localizations.faqSubsidyQuestion,
        answer: localizations.faqSubsidyAnswer,
        category: 'finance',
      ),
      FAQModel(
        id: 'faq2',
        question: localizations.faqPestControlQuestion,
        answer: localizations.faqPestControlAnswer,
        category: 'pest',
      ),
      FAQModel(
        id: 'faq3',
        question: localizations.faqSoilHealthQuestion,
        answer: localizations.faqSoilHealthAnswer,
        category: 'soil',
      ),
      FAQModel(
        id: 'faq4',
        question: localizations.faqWeatherImpactQuestion,
        answer: localizations.faqWeatherImpactAnswer,
        category: 'weather',
      ),
      FAQModel(
        id: 'faq5',
        question: localizations.faqCropInsuranceQuestion,
        answer: localizations.faqCropInsuranceAnswer,
        category: 'finance',
      ),
    ];
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }
}
