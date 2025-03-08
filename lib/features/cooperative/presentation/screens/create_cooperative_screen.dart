import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/cooperative/presentation/widgets/member_search_dialog.dart';
import 'package:cropconnect/features/cooperative/presentation/widgets/member_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_cooperative_controller.dart';

class CreateCooperativeScreen extends GetView<CreateCooperativeController> {
  const CreateCooperativeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Cooperative',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20, // Reduced icon size
            color: theme.colorScheme.primary,
          ),
          onPressed: () => Get.back(),
        ),
        toolbarHeight: 56, // Slightly reduced app bar height
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Compact Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: 20), // Reduced padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    padding: const EdgeInsets.all(12), // Smaller padding
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16), // Reduced radius
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      size: 36, // Reduced size
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Your Cooperative',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4), // Reduced spacing
                        Text(
                          'Create a community of farmers working together',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(16.0), // Reduced padding
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: controller.nameController,
                      label: 'Cooperative Name',
                      hint: 'Enter cooperative name',
                      icon: Icons.business_rounded,
                      theme: theme,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16), // Reduced spacing
                    _buildTextField(
                      controller: controller.descriptionController,
                      label: 'Description',
                      hint: 'Describe your cooperative\'s mission and goals',
                      icon: Icons.description_rounded,
                      theme: theme,
                      maxLines: 3,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Description is required'
                          : null,
                    ),
                    const SizedBox(height: 16), // Reduced spacing
                    MemberSelectionWidget(
                      title: 'Select Members',
                      selectedMembers: controller.selectedMembers,
                      onMemberRemoved: (member) =>
                          controller.selectedMembers.remove(member),
                      onAddTapped: () => _showMemberSearchDialog(context),
                      showMinimumText: true,
                    ),
                    const SizedBox(height: 24),
                    _buildCreateButton(theme),
                    const SizedBox(height: 16), // Reduced spacing
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          hintText: hint,
          hintStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 18,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildCreateButton(ThemeData theme) {
    return Obx(() => Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.createCooperative,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: controller.isLoading.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Creating...',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_business_rounded,
                        color: AppColors.backgroundLight,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Create Cooperative',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }

  void _showMemberSearchDialog(BuildContext context) {
    Get.dialog(
      MemberSearchDialog(
        onSearch: controller.searchMembers,
        searchResults: controller.searchResults,
        onMemberSelected: (user) {
          controller.selectedMembers.add(user);
        },
      ),
    );
  }
}
