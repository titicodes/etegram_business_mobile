// import 'dart:convert';
// import 'package:etegram_business/base/base_ui.dart';
// import 'package:etegram_business/constants/assets.dart';
// import 'package:etegram_business/module/account/viewmodel/profile_vw.dart';
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/utils/snack_message.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:etegram_business/locator.dart';
//
// import '../../../service/local/user_service.dart';
// import '../model/chat_message.dart';
//
// class LiveChatView extends StatefulWidget {
//   const LiveChatView({super.key});
//
//   @override
//   _LiveChatViewState createState() => _LiveChatViewState();
// }
//
// class _LiveChatViewState extends State<LiveChatView> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final customerService = locator<CustomerService>();
//
//     return BaseView<ProfileViewModel>(
//       builder: (_, logic, child) => Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           automaticallyImplyLeading: false,
//           backgroundColor: Colors.white,
//           flexibleSpace: SafeArea(
//             child: Container(
//               padding: const EdgeInsets.only(right: 16),
//               child: Row(
//                 children: <Widget>[
//                   IconButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(
//                       Icons.arrow_back,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const SizedBox(width: 2),
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundColor: Colors.grey.shade200,
//                     backgroundImage: customerService.customer?.profilePhoto !=
//                             null
//                         ? NetworkImage(customerService.customer!.profilePhoto!)
//                         : null,
//                     child: customerService.customer?.profilePhoto == null
//                         ? SvgPicture.asset(
//                             SvgAssets.avatar,
//                             height: 24,
//                             width: 24,
//                           )
//                         : null,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Text(
//                           customerService.customer != null
//                               ? '${customerService.customer!.firstName ?? ''} ${customerService.customer!.lastName ?? ''}'
//                                   .trim()
//                               : 'Support Team',
//                           style: const TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.w600),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           'Support Team',
//                           style: TextStyle(
//                               color: Colors.grey.shade600, fontSize: 13),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Icon(
//                     Icons.settings,
//                     color: Colors.black54,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         body: Stack(
//           children: <Widget>[
//             ValueListenableBuilder<bool>(
//               valueListenable: logic.isLoading,
//               builder: (context, isLoading, child) {
//                 if (isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 return FutureBuilder<List<ChatMessage>>(
//                   future: logic.getMessages(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     if (snapshot.hasError ||
//                         !snapshot.hasData ||
//                         snapshot.data!.isEmpty) {
//                       return const Center(child: Text('No messages available'));
//                     }
//                     final messages = snapshot.data!;
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       if (_scrollController.hasClients) {
//                         _scrollController.animateTo(
//                           _scrollController.position.maxScrollExtent,
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeOut,
//                         );
//                       }
//                     });
//                     return ListView.builder(
//                       controller: _scrollController,
//                       itemCount: messages.length,
//                       shrinkWrap: true,
//                       padding: const EdgeInsets.only(top: 10, bottom: 70),
//                       itemBuilder: (context, index) {
//                         return Container(
//                           padding: const EdgeInsets.only(
//                               left: 14, right: 14, top: 10, bottom: 10),
//                           child: Align(
//                             alignment: messages[index].messageType == 'receiver'
//                                 ? Alignment.topLeft
//                                 : Alignment.topRight,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(20),
//                                 color: messages[index].messageType == 'receiver'
//                                     ? Colors.grey.shade200
//                                     : Colors.blue[200],
//                               ),
//                               padding: const EdgeInsets.all(16),
//                               child: Text(
//                                 messages[index].messageContent,
//                                 style: const TextStyle(fontSize: 15),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//             Align(
//               alignment: Alignment.bottomLeft,
//               child: Container(
//                 padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
//                 height: 60,
//                 width: double.infinity,
//                 color: Colors.white,
//                 child: Row(
//                   children: <Widget>[
//                     GestureDetector(
//                       onTap: () {
//                         showCustomToast('Attachments not implemented yet',
//                             success: false);
//                       },
//                       child: Container(
//                         height: 30,
//                         width: 30,
//                         decoration: BoxDecoration(
//                           color: Colors.lightBlue,
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: const Icon(
//                           Icons.add,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 15),
//                     Expanded(
//                       child: TextField(
//                         controller: _messageController,
//                         decoration: const InputDecoration(
//                           hintText: 'Write message...',
//                           hintStyle: TextStyle(color: Colors.black54),
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 15),
//                     FloatingActionButton(
//                       onPressed: () async {
//                         if (_messageController.text.trim().isEmpty) {
//                           showCustomToast('Please enter a message',
//                               success: false);
//                           return;
//                         }
//                         await logic.sendMessage(_messageController.text.trim());
//                         if (logic.errorMessage != null) {
//                           showCustomToast(logic.errorMessage!, success: false);
//                           return;
//                         }
//                         _messageController.clear();
//                         if (_scrollController.hasClients) {
//                           _scrollController.animateTo(
//                             _scrollController.position.maxScrollExtent,
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeOut,
//                           );
//                         }
//                         setState(() {});
//                       },
//                       backgroundColor: Colors.blue,
//                       elevation: 0,
//                       child: const Icon(
//                         Icons.send,
//                         color: Colors.white,
//                         size: 18,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
    final customerService = locator<CustomerService>();

    return BaseView<ProfileViewModel>(
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
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: customerService.customer?.profilePhoto !=
                            null
                        ? NetworkImage(customerService.customer!.profilePhoto!)
                        : null,
                    child: customerService.customer?.profilePhoto == null
                        ? SvgPicture.asset(
                            SvgAssets.avatar,
                            height: 24,
                            width: 24,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          customerService.customer != null
                              ? '${customerService.customer!.firstName ?? ''} ${customerService.customer!.lastName ?? ''}'
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
                  const Icon(
                    Icons.settings,
                    color: Colors.black54,
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
                        setState(() {}); // Refresh to show new messages
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
}
