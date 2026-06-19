import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:your_app_name/src/presentation/widget/app_button.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';
import 'package:your_app_name/src/utils/translate.dart';

class AddListingSuccessScreen extends StatefulWidget {
  const AddListingSuccessScreen({super.key});

  @override
  State<AddListingSuccessScreen> createState() =>
      _AddListingSuccessScreenState();
}

class _AddListingSuccessScreenState extends State<AddListingSuccessScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
  }

  @override
  void dispose() {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    super.dispose();
  }

  void _navigateBack() {
    Navigator.popUntil(
      context,
      (route) =>
          route.isFirst ||
          (route.settings.name != null &&
              route.settings.name != Routes.submitSuccess &&
              route.settings.name != Routes.submit),
    );
  }

  void _onAddMore() {
    _navigateBack();
    Navigator.pushNamed(context, Routes.submit, arguments: {'isNewList': true});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _navigateBack();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _navigateBack,
          ),
          title: Text(
            Translate.of(context).translate('completed'),
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Translate.of(context).translate('completed'),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Translate.of(context).translate(
                            'submit_success_message',
                          ),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: AppButton(
                    Translate.of(context).translate('add_more'),
                    mainAxisSize: MainAxisSize.max,
                    onPressed: _onAddMore,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
