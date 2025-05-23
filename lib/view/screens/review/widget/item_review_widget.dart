import 'package:payapp/controller/item_controller.dart';
import 'package:payapp/controller/splash_controller.dart';
import 'package:payapp/data/model/body/review_body.dart';
import 'package:payapp/data/model/response/order_details_model.dart';
import 'package:payapp/helper/price_converter.dart';
import 'package:payapp/util/dimensions.dart';
import 'package:payapp/util/styles.dart';
import 'package:payapp/view/base/custom_button.dart';
import 'package:payapp/view/base/custom_image.dart';
import 'package:payapp/view/base/custom_snackbar.dart';
import 'package:payapp/view/base/footer_view.dart';
import 'package:payapp/view/base/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemReviewWidget extends StatefulWidget {
  final List<OrderDetailsModel> orderDetailsList;
  const ItemReviewWidget({super.key, required this.orderDetailsList});

  @override
  State<ItemReviewWidget> createState() => _ItemReviewWidgetState();
}

class _ItemReviewWidgetState extends State<ItemReviewWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      return Scrollbar(child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: ListView.builder(
          itemCount: widget.orderDetailsList.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 2, offset: const Offset(0, 1))],
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
              ),
              child: Column(children: [

                // Product details
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImage(
                        height: 70, width: 85, fit: BoxFit.cover,
                        image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                            '/${widget.orderDetailsList[index].itemDetails!.image}',
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.orderDetailsList[index].itemDetails!.name!, style: robotoMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 10),
                        Text(PriceConverter.convertPrice(widget.orderDetailsList[index].itemDetails!.price), style: robotoBold, textDirection: TextDirection.ltr),
                      ],
                    )),
                    Row(children: [
                      Text(
                        '${'quantity'.tr}: ',
                        style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.orderDetailsList[index].quantity.toString(),
                        style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]),
                  ],
                ),
                const Divider(height: 20),

                // Rate
                Text(
                  'rate_the_item'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      return InkWell(
                        child: Icon(
                          itemController.ratingList[index] < (i + 1) ? Icons.star_border : Icons.star,
                          size: 25,
                          color: itemController.ratingList[index] < (i + 1) ? Theme.of(context).disabledColor
                              : Theme.of(context).primaryColor,
                        ),
                        onTap: () {
                          if(!itemController.submitList[index]) {
                            itemController.setRating(index, i + 1);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                Text(
                  'share_your_opinion'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                MyTextField(
                  maxLines: 3,
                  capitalization: TextCapitalization.sentences,
                  isEnabled: !itemController.submitList[index],
                  hintText: 'write_your_review_here'.tr,
                  fillColor: Theme.of(context).disabledColor.withOpacity(0.05),
                  onChanged: (text) => itemController.setReview(index, text),
                ),
                const SizedBox(height: 20),

                // Submit button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: !itemController.loadingList[index] ? CustomButton(
                    buttonText: itemController.submitList[index] ? 'submitted'.tr : 'submit'.tr,
                    onPressed: itemController.submitList[index] ? null : () {
                      if(!itemController.submitList[index]) {
                        if (itemController.ratingList[index] == 0) {
                          showCustomSnackBar('give_a_rating'.tr);
                        } else if (itemController.reviewList[index].isEmpty) {
                          showCustomSnackBar('write_a_review'.tr);
                        } else {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          ReviewBody reviewBody = ReviewBody(
                            productId: widget.orderDetailsList[index].itemDetails!.id.toString(),
                            rating: itemController.ratingList[index].toString(),
                            comment: itemController.reviewList[index],
                            orderId: widget.orderDetailsList[index].orderId.toString(),
                          );
                          itemController.submitReview(index, reviewBody).then((value) {
                            if (value.isSuccess) {
                              showCustomSnackBar(value.message, isError: false);
                              itemController.setReview(index, '');
                            } else {
                              showCustomSnackBar(value.message);
                            }
                          });
                        }
                      }
                    },
                  ) : const Center(child: CircularProgressIndicator()),
                ),

              ]),
            );
          },
        ))),
      ));
    });
  }
}
