import 'package:flutter/material.dart';

class PrivacySettingsTile extends StatelessWidget {
  const PrivacySettingsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.privacy_tip),
      title: const Text('Privacy Settings'),
      onTap: () {
        // Handle privacy settings
      },
    );
  }
}
