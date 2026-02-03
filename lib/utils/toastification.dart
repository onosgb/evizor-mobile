import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

errorSnack(String message) {
  toastification.show(
    type: ToastificationType.error,
    style: ToastificationStyle.minimal,
    autoCloseDuration: const Duration(seconds: 5),
    title: Text(message),
    alignment: Alignment.topRight,
    animationDuration: const Duration(milliseconds: 300),
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    icon: const Icon(Icons.error),
    primaryColor: Colors.red,
    showProgressBar: false,
    borderRadius: BorderRadius.circular(12),
    closeButton: ToastCloseButton(),
    closeOnClick: false,
    pauseOnHover: true,
    dragToClose: true,
  );
}

infoSnack(String message) {
  toastification.show(
    type: ToastificationType.info,
    style: ToastificationStyle.minimal,
    autoCloseDuration: const Duration(seconds: 5),
    title: Text(message),
    alignment: Alignment.topRight,
    animationDuration: const Duration(milliseconds: 300),
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    icon: const Icon(Icons.info),
    primaryColor: Colors.blue,
    borderRadius: BorderRadius.circular(12),
    showProgressBar: false,
    closeButton: ToastCloseButton(),
    closeOnClick: false,
    pauseOnHover: true,
    dragToClose: true,
  );
}

successSnack(String message) {
  toastification.show(
    type: ToastificationType.success,
    style: ToastificationStyle.minimal,
    autoCloseDuration: const Duration(seconds: 5),
    title: Text(message),
    alignment: Alignment.topRight,
    animationDuration: const Duration(milliseconds: 300),
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    icon: const Icon(Icons.check),
    primaryColor: Colors.green,
    borderRadius: BorderRadius.circular(12),
    showProgressBar: false,
    closeButton: ToastCloseButton(),
    closeOnClick: false,
    pauseOnHover: true,
    dragToClose: true,
  );
}
