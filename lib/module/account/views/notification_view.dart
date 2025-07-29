// import 'package:etegram_business/app_widget/app_text.dart';
// import 'package:etegram_business/app_widget/custom_appbar.dart';
// import 'package:etegram_business/app_widget/custom_listtile.dart';
// import 'package:etegram_business/base/base_ui.dart';
// import 'package:etegram_business/constants/colors.dart';
// import 'package:etegram_business/constants/reuseable.dart';
// import 'package:etegram_business/constants/strings.dart';
// import 'package:etegram_business/constants/style.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:line_awesome_flutter/line_awesome_flutter.dart';
//
// import '../../../core/model/notification_model.dart';
// import '../viewmodel/notification_vm.dart';
//
// class NotificationView extends StatelessWidget {
//   const NotificationView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseView<NotificationViewModel>(
//       onModelReady: (model) {
//         model.init();
//       },
//       builder: (_, model, child) => Scaffold(
//         backgroundColor: ColorValues.backgroundColor,
//         appBar: CustomAppBar(
//           title: StringValues.notifications,
//           onBackPressed: () => navigationService.goBack(),
//           showNotificationIcon: false,
//           showMenuIcon: true,
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               AppText(
//                 'During the internal testing period, all notification features are accessible.',
//                 style: normalTextStyle12.copyWith(color: Colors.grey),
//               ),
//               const SizedBox(height: 10),
//               NxListTile(
//                 showBorder: false,
//                 trailing: Switch(
//                   value: model.isPushNotificationEnabled,
//                   onChanged: (value) async {
//                     await model.togglePushNotification(value);
//                   },
//                   activeColor: ColorValues.primaryColor,
//                 ),
//                 title: AppText(
//                   StringValues.pushNotification,
//                   style: normalTextStyle,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   AppText(
//                     'Recent Notifications',
//                     style: subHeaderTextStyle,
//                   ),
//                   ValueListenableBuilder<int>(
//                     valueListenable: model.unreadCount,
//                     builder: (context, unreadCount, _) => AppText(
//                       'Unread: $unreadCount',
//                       style: normalTextStyle12.copyWith(
//                         color: ColorValues.primaryColor,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: StreamBuilder<List<NotificationModel>>(
//                   stream: model.notificationsStream,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     if (snapshot.hasError) {
//                       return Center(
//                         child: AppText(
//                           'Error loading notifications: ${snapshot.error}',
//                           style: normalTextStyle12,
//                         ),
//                       );
//                     }
//                     final notifications = snapshot.data ?? [];
//                     if (notifications.isEmpty) {
//                       return Center(
//                         child: AppText(
//                           'No notifications available',
//                           style: normalTextStyle12,
//                         ),
//                       );
//                     }
//                     return ListView.builder(
//                       itemCount: notifications.length,
//                       itemBuilder: (context, index) {
//                         final notification = notifications[index];
//                         return GestureDetector(
//                           onTap: () async {
//                             if (!notification.isRead) {
//                               await model
//                                   .markNotificationAsRead(notification.id);
//                             }
//                           },
//                           child: NxListTile(
//                             showBorder: false,
//                             leading: CircleAvatar(
//                               backgroundColor: notification.isRead
//                                   ? ColorValues.greyColor
//                                   : ColorValues.primaryColor,
//                               child: Icon(
//                                 _getIconForType(notification.type),
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                             ),
//                             title: AppText(
//                               notification.title,
//                               style: normalTextStyle.copyWith(
//                                 fontWeight: notification.isRead
//                                     ? FontWeight.normal
//                                     : FontWeight.bold,
//                               ),
//                             ),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 AppText(
//                                   notification.body,
//                                   style: normalTextStyle12.copyWith(
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 AppText(
//                                   DateFormat('MMM dd, yyyy • HH:mm')
//                                       .format(notification.createdAt),
//                                   style: normalTextStyle12.copyWith(
//                                     fontSize: 10,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   IconData _getIconForType(String? type) {
//     switch (type) {
//       case 'ORDER':
//         return LineAwesomeIcons.shopping_cart_solid;
//       case 'SUBSCRIPTION':
//         return LineAwesomeIcons.star;
//       case 'LOW_STOCK':
//         return LineAwesomeIcons.exclamation_triangle_solid;
//       case 'PROMOTIONAL':
//         return LineAwesomeIcons.bullhorn_solid;
//       default:
//         return LineAwesomeIcons.bell;
//     }
//   }
// }

import 'package:etegram_business/app_widget/app_text.dart';
import 'package:etegram_business/app_widget/custom_appbar.dart';
import 'package:etegram_business/app_widget/custom_listtile.dart';
import 'package:etegram_business/base/base_ui.dart';
import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/constants/reuseable.dart';
import 'package:etegram_business/constants/strings.dart';
import 'package:etegram_business/constants/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../core/model/notification_model.dart';
import '../../../utils/snack_message.dart';
import '../viewmodel/notification_vm.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  Widget build(BuildContext context) {
    return BaseView<NotificationViewModel>(
      onModelReady: (model) {
        model.init();
      },
      builder: (_, model, child) => Scaffold(
        backgroundColor: ColorValues.backgroundColor,
        appBar: CustomAppBar(
          title: StringValues.notifications,
          onBackPressed: () => navigationService.goBack(),
          showNotificationIcon: false,
          showMenuIcon: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'During the internal testing period, all notification features are accessible.',
                style: normalTextStyle12.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              NxListTile(
                showBorder: false,
                trailing: Switch(
                  value: model.isPushNotificationEnabled,
                  onChanged: (value) async {
                    await model.togglePushNotification(value);
                  },
                  activeColor: ColorValues.primaryColor,
                ),
                title: AppText(
                  StringValues.pushNotification,
                  style: normalTextStyle,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'Recent Notifications',
                    style: subHeaderTextStyle,
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: model.unreadCount,
                    builder: (context, unreadCount, _) {
                      return AppText(
                        unreadCount >= 0
                            ? 'Unread: $unreadCount'
                            : 'Unread: --',
                        style: normalTextStyle12.copyWith(
                          color: ColorValues.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (!model.isFetching &&
                        scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent * 0.8) {
                      model.fetchNotifications(loadMore: true);
                    }
                    return false;
                  },
                  child: StreamBuilder<List<NotificationModel>>(
                    stream: model.notificationsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: AppText(
                            'Error loading notifications: ${snapshot.error}',
                            style: normalTextStyle12,
                          ),
                        );
                      }
                      final notifications = snapshot.data ?? [];
                      if (notifications.isEmpty) {
                        return Center(
                          child: AppText(
                            'No notifications available',
                            style: normalTextStyle12,
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          print(
                              'NotificationView: Building notification: ${notification.id}');
                          return GestureDetector(
                            onTap: () async {
                              if (model.isTapping) {
                                print(
                                    'NotificationView: Tap ignored due to ongoing tap');
                                return;
                              }
                              if (notification.id.isEmpty) {
                                print(
                                    'NotificationView: Invalid notification ID: ${notification.toJson()}');
                                showCustomToast('Invalid notification ID',
                                    success: false);
                                return;
                              }
                              model.setTapping(true);
                              try {
                                if (!notification.isRead) {
                                  print(
                                      'NotificationView: Marking notification ${notification.id} as read');
                                  await model
                                      .markNotificationAsRead(notification.id);
                                }
                              } finally {
                                await Future.delayed(
                                    const Duration(milliseconds: 500));
                                model.setTapping(false);
                              }
                            },
                            child: NxListTile(
                              showBorder: false,
                              leading: CircleAvatar(
                                backgroundColor: notification.isRead
                                    ? ColorValues.greyColor
                                    : ColorValues.primaryColor,
                                child: Icon(
                                  _getIconForType(notification.type),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: AppText(
                                notification.title,
                                style: normalTextStyle.copyWith(
                                  fontWeight: notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    notification.body,
                                    style: normalTextStyle12.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AppText(
                                    DateFormat('MMM dd, yyyy • HH:mm')
                                        .format(notification.createdAt),
                                    style: normalTextStyle12.copyWith(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'ORDER':
        return LineAwesomeIcons.shopping_cart_solid;
      case 'SUBSCRIPTION':
        return LineAwesomeIcons.star;
      case 'LOW_STOCK':
        return LineAwesomeIcons.exclamation_triangle_solid;
      case 'PROMOTIONAL':
        return LineAwesomeIcons.bullhorn_solid;
      default:
        return LineAwesomeIcons.bell;
    }
  }
}
