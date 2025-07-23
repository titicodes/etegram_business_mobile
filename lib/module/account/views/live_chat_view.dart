import 'dart:convert';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/assets.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/utils/snack_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:etegram_business/locator.dart';
import '../../../service/local/user_service.dart';
import '../../profile/vm/profle_vm.dart';
import '../model/chat_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:etegram_business/constants/style.dart';

class LiveChatView extends StatefulWidget {
  const LiveChatView({super.key});

  @override
  State<LiveChatView> createState() => _LiveChatViewState();
}

class _LiveChatViewState extends State<LiveChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = locator<ProfileViewModel>();

    return BaseView<ProfileViewModel>(
      onModelReady: (model) {
        model.init();
      },
      builder: (_, logic, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 2),
                  ValueListenableBuilder<String?>(
                    valueListenable: logic.profileImageUrl,
                    builder: (context, imageUrl, _) => CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      child: imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  SvgPicture.asset(
                                SvgAssets.avatar,
                                height: 24,
                                width: 24,
                              ),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : SvgPicture.asset(
                              SvgAssets.avatar,
                              height: 24,
                              width: 24,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          logic.customerService.customer != null
                              ? '${logic.customerService.customer!.firstName ?? ''} ${logic.customerService.customer!.lastName ?? ''}'
                                  .trim()
                              : 'Support Team',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Support Team',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showSettingsDialog(context, logic);
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'During the internal testing period, all chat features are accessible.',
                    style: normalTextStyle.copyWith(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: logic.isLoading,
                    builder: (context, isLoading, _) {
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
                                    'Error loading messages'));
                          }
                          final messages = snapshot.data!;
                          if (messages.isEmpty) {
                            return const Center(
                                child: Text('No messages available'));
                          }
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_scrollController.hasClients) {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          });
                          return ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length,
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 10, bottom: 70),
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return Container(
                                padding: const EdgeInsets.only(
                                    left: 14, right: 14, top: 10, bottom: 10),
                                child: Align(
                                  alignment: message.messageType == 'receiver'
                                      ? Alignment.topLeft
                                      : Alignment.topRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: message.messageType == 'receiver'
                                          ? Colors.grey.shade200
                                          : Colors.blue[200],
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      message.messageContent,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        showCustomToast('Attachments not implemented yet',
                            success: false);
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Write message...',
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    FloatingActionButton(
                      onPressed: () async {
                        if (_messageController.text.trim().isEmpty) {
                          showCustomToast('Please enter a message',
                              success: false);
                          return;
                        }
                        await logic.sendMessage(_messageController.text.trim());
                        if (logic.errorMessage != null) {
                          showCustomToast(logic.errorMessage!, success: false);
                          return;
                        }
                        _messageController.clear();
                      },
                      backgroundColor: Colors.blue,
                      elevation: 0,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Clear Chat History'),
              onTap: () async {
                await viewModel.clearChatHistory();
                if (viewModel.errorMessage != null) {
                  showCustomToast(viewModel.errorMessage!, success: false);
                } else {
                  showCustomToast('Chat history cleared', success: true);
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Toggle Notifications'),
              trailing: Switch(
                value: viewModel.isPushNotificationSelected,
                onChanged: (value) async {
                  await viewModel.togglePushNotification(value);
                  if (viewModel.errorMessage != null) {
                    showCustomToast(viewModel.errorMessage!, success: false);
                  } else {
                    showCustomToast(
                        'Notifications ${value ? 'enabled' : 'disabled'}',
                        success: true);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
