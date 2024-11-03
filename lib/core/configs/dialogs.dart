import 'dart:ui';

import 'package:flutter/material.dart';

enum MessageType { success, error, warning }

class DialogUtils {

  static void showConfirmationDialog({
    required BuildContext context,
    required Size size,
    required String title,
    required String textCancelButton,
    required String textAcceptButton,
    required VoidCallback acceptPressed,
    bool reverseButton = false,
  }) {
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
              height: 110,
              width: size.width,
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
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  reverseButton
                      ? Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: acceptPressed,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: const Color(0xff603F26),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      textAcceptButton,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 28,
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
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        )
                      : Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 28,
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
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: acceptPressed,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: const Color(0xff603F26),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      textAcceptButton,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
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
