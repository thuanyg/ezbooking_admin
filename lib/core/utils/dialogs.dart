import 'dart:ui';

import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:ezbooking_admin/core/configs/break_points.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum MessageType { success, error, warning }

class DialogUtils {

  static void showLoadingDialog(BuildContext context)  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Lottie.asset(
                'assets/animations/loading.json',
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }


  static void showConfirmationDialog({
    required BuildContext context,
    required Size size,
    required String title,
    required String textCancelButton,
    required String textAcceptButton,
    required VoidCallback acceptPressed,
    bool reverseButton = false,
  }) {
    final isDesktop = Breakpoints.isDesktop(context);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (BuildContext context, _, __) {
        return Container(
          margin: const EdgeInsets.only(left: 12, right: 12),
          alignment: Alignment.center,
          child: Material(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 130,
              width: isDesktop ? size.width * 0.3 : size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(width: isDesktop ? (size.height * 0.4) / 3 : 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: const Color(0xffEEEEEE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                textCancelButton,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isDesktop ? (size.height * 0.4) / 3 : 16),

                      Expanded(
                        child: InkWell(
                          onTap: acceptPressed,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                textAcceptButton,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isDesktop ? (size.height * 0.4) / 3 : 16),

                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
