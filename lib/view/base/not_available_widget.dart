import 'package:payapp/util/dimensions.dart';
import 'package:payapp/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotAvailableWidget extends StatelessWidget {
  final double fontSize;
  final bool isStore;
  final bool isAllSideRound;
  const NotAvailableWidget({super.key, this.fontSize = 8, this.isStore = false, this.isAllSideRound = true});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0, left: 0, bottom: 0, right: 0,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: isAllSideRound ? BorderRadius.circular(Dimensions.radiusSmall) : const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)), color: Colors.black.withOpacity(0.6)),
        child: Text(
          isStore ? 'closed_now'.tr : 'not_available_now_break'.tr, textAlign: TextAlign.center,
          style: robotoRegular.copyWith(color: Colors.white, fontSize: fontSize),
        ),
      ),
    );
  }
}
