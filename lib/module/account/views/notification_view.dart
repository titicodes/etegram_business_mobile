import 'package:etegram_business/app_widget/app_button.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/custom_listtile.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:etegram_business/app_widget/input_fields.dart';
import '../../profile/vm/profle_vm.dart';
import '../model/chat_message.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProfileViewModel>(
      builder: (_, logic, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: StringValues.notifications,
          onBackPressed: () => navigationService.goBack(),
          showNotificationIcon: false,
          showMenuIcon: true,
        ),
        body: Padding(
          padding: 16.0.padA,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'During the internal testing period, all notification features are accessible.',
                style: normalTextStyle.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              NxListTile(
                showBorder: false,
                trailing: Switch(
                  value: logic.isPushNotificationSelected,
                  onChanged: logic.togglePushedNotificationSwitch,
                  activeColor: ColorValues.primaryColor,
                ),
                title: Text(
                  StringValues.pushNotification,
                  style: normalTextStyle,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Recent Notifications',
                style: subHeaderTextStyle,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: logic.isLoading,
                  builder: (context, isLoading, child) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return FutureBuilder<List<ChatMessage>>(
                      future: logic.getMessages(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Center(
                              child: Text(logic.errorMessage ??
                                  'Error loading notifications'));
                        }
                        final messages = snapshot.data!;
                        if (messages.isEmpty) {
                          return const Center(
                              child: Text('No notifications available'));
                        }
                        return ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return NxListTile(
                              showBorder: false,
                              title: Text(
                                message.messageContent,
                                style: normalTextStyle,
                              ),
                              subtitle: Text(
                                message.messageType == 'receiver'
                                    ? 'System Notification'
                                    : 'User Response',
                                style: normalTextStyle.copyWith(
                                    color: Colors.grey),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Send a Message',
                style: subHeaderTextStyle,
              ),
              const SizedBox(height: 10),
              AppTextField(
                hintText: 'Type your message...',
                onChanged: (value) {
                  logic.messageContent = value;
                },
              ),
              const SizedBox(height: 10),
              AppButton(
                text: "Send Message",
                onTap: () async {
                  if (logic.messageContent.isNotEmpty) {
                    await logic.sendMessage(logic.messageContent);
                    if (logic.errorMessage == null) {
                      (context as Element).markNeedsBuild();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(logic.errorMessage!)),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message cannot be empty')),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
