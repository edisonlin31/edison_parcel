import 'package:payapp/helper/responsive_helper.dart';
import 'package:payapp/util/dimensions.dart';
import 'package:payapp/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  const TitleWidget({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: robotoMedium.copyWith(fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraLarge : Dimensions.fontSizeLarge)),
      (onTap != null && !ResponsiveHelper.isDesktop(context)) ? InkWell(
        onTap: onTap as void Function()?,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
          child: Text(
            'view_all'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
          ),
        ),
      ) : const SizedBox(),
    ]);
  }
}
