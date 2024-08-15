import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp/Services/NavigationService.dart';
import 'package:get_it/get_it.dart';

class AlertService {
  GetIt getIt = GetIt.instance;
  late NavigationService _navigationService;
  AlertService() {
    _navigationService = getIt.get<NavigationService>();
  }

  void showToastMessage(String title,
      {Icon icon = const Icon(
        Icons.info,
        color: Colors.green,
      )}) {
    DelightToastBar(
        position: DelightSnackbarPosition.top,
        autoDismiss: true,
        builder: (BuildContext context) {
          return ToastCard(leading: icon, title: Text(title));
        }).show(_navigationService.navigatorService!.currentContext!);
  }
}
