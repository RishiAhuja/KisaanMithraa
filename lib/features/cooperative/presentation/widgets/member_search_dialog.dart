import 'package:cropconnect/features/auth/domain/model/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberSearchDialog extends StatelessWidget {
  final Function(String) onSearch;
  final RxList<UserModel> searchResults; // Change to RxList
  final Function(UserModel) onMemberSelected;

  const MemberSearchDialog({
    Key? key,
    required this.onSearch,
    required this.searchResults,
    required this.onMemberSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search by name or phone...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: onSearch,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Obx(() {
                  // Add Obx here
                  if (searchResults.isEmpty) {
                    return const Center(
                      child: Text('No results found'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final user = searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        title: Text(user.name),
                        subtitle: Text(user.phoneNumber),
                        onTap: () {
                          onMemberSelected(user);
                          Get.back();
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
