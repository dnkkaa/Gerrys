import 'package:flutter/material.dart';

class ChangePasswordTile extends StatelessWidget {
  const ChangePasswordTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.lock),
      title: const Text('Change Password'),
      onTap: () {
        // Navigate to change password page or perform action
      },
    );
  }
}
