import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payapp/controller/auth_controller.dart';
import 'package:payapp/controller/location_controller.dart';
import 'package:payapp/controller/order_controller.dart';
import 'package:payapp/controller/parcel_controller.dart';
import 'package:payapp/controller/splash_controller.dart';
import 'package:payapp/controller/user_controller.dart';
import 'package:payapp/data/model/body/place_order_body.dart';
import 'package:payapp/data/model/response/address_model.dart';
import 'package:payapp/data/model/response/parcel_category_model.dart';
import 'package:payapp/data/model/response/zone_response_model.dart';
import 'package:payapp/helper/price_converter.dart';
import 'package:payapp/helper/responsive_helper.dart';
import 'package:payapp/helper/route_helper.dart';
import 'package:payapp/util/app_constants.dart';
import 'package:payapp/util/dimensions.dart';
import 'package:payapp/util/images.dart';
import 'package:payapp/util/styles.dart';
import 'package:payapp/view/base/custom_app_bar.dart';
import 'package:payapp/view/base/custom_button.dart';
import 'package:payapp/view/base/custom_image.dart';
import 'package:payapp/view/base/custom_snackbar.dart';
import 'package:payapp/view/base/custom_text_field.dart';
import 'package:payapp/view/base/footer_view.dart';
import 'package:payapp/view/base/menu_drawer.dart';
import 'package:payapp/view/base/not_logged_in_screen.dart';
import 'package:payapp/view/screens/checkout/widget/condition_check_box.dart';
import 'package:payapp/view/screens/checkout/widget/payment_button.dart';
import 'package:payapp/view/screens/checkout/widget/tips_widget.dart';
import 'package:payapp/view/screens/parcel/widget/card_widget.dart';
import 'package:payapp/view/screens/parcel/widget/details_widget.dart';
import 'package:universal_html/html.dart' as html;

class ParcelRequestScreen extends StatefulWidget {
  final ParcelCategoryModel parcelCategory;
  final AddressModel pickedUpAddress;
  final AddressModel destinationAddress;
  const ParcelRequestScreen(
      {super.key,
      required this.parcelCategory,
      required this.pickedUpAddress,
      required this.destinationAddress});

  @override
  State<ParcelRequestScreen> createState() => _ParcelRequestScreenState();
}

class _ParcelRequestScreenState extends State<ParcelRequestScreen> {
  final TextEditingController _tipController = TextEditingController();
  bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();
  bool? _isCashOnDeliveryActive = false;
  bool? _isDigitalPaymentActive = false;
  bool? _isPluginPaymentActive = false;
  bool canCheckSmall = false;

  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall() {
    if (_isLoggedIn) {
      Get.find<OrderController>().getDmTipMostTapped();
      Get.find<ParcelController>().setPaymentIndex(-1, false);
      Get.find<ParcelController>()
          .getDistance(widget.pickedUpAddress, widget.destinationAddress);
      Get.find<ParcelController>().setPayerIndex(0, false);
      for (ZoneData zData
          in Get.find<LocationController>().getUserAddress()!.zoneData!) {
        if (zData.id ==
            Get.find<LocationController>().getUserAddress()!.zoneId) {
          _isCashOnDeliveryActive = zData.cashOnDelivery! &&
              Get.find<SplashController>().configModel!.cashOnDelivery!;
          _isDigitalPaymentActive = zData.digitalPayment! &&
              Get.find<SplashController>().configModel!.digitalPayment!;
          _isPluginPaymentActive = Get.find<SplashController>()
              .configModel!
              .digitalPaymentInfo!
              .pluginPaymentGateways!;
          // if(Get.find<ParcelController>().payerIndex == 0) {
          //   Get.find<ParcelController>().setPaymentIndex(_isCashOnDeliveryActive! ? 0 : _isDigitalPaymentActive! ? 1 : 2, false);
          // }else{
          //   Get.find<ParcelController>().setPaymentIndex(0, false);
          // }
        }
      }
      if (Get.find<UserController>().userInfoModel == null) {
        Get.find<UserController>().getUserInfo();
      }
      Get.find<OrderController>().updateTips(
        Get.find<AuthController>().getDmTipIndex().isNotEmpty
            ? int.parse(Get.find<AuthController>().getDmTipIndex())
            : 0,
        notify: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Scaffold(
      appBar: CustomAppBar(title: 'parcel_request'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: GetBuilder<OrderController>(builder: (orderController) {
          return GetBuilder<ParcelController>(builder: (parcelController) {
            double charge = -1;
            double total = 0;
            double dmTips = 0;
            double additionalCharge = Get.find<SplashController>()
                    .configModel!
                    .additionalChargeStatus!
                ? Get.find<SplashController>().configModel!.additionCharge!
                : 0;

            if (parcelController.distance != -1 &&
                _isLoggedIn &&
                parcelController.extraCharge != null) {
              double parcelPerKmShippingCharge =
                  widget.parcelCategory.parcelPerKmShippingCharge! > 0
                      ? widget.parcelCategory.parcelPerKmShippingCharge!
                      : Get.find<SplashController>()
                          .configModel!
                          .parcelPerKmShippingCharge!;
              double parcelMinimumShippingCharge =
                  widget.parcelCategory.parcelMinimumShippingCharge! > 0
                      ? widget.parcelCategory.parcelMinimumShippingCharge!
                      : Get.find<SplashController>()
                          .configModel!
                          .parcelMinimumShippingCharge!;
              charge = parcelController.distance! * parcelPerKmShippingCharge;
              if (charge < parcelMinimumShippingCharge) {
                charge = parcelMinimumShippingCharge;
              }

              if (parcelController.extraCharge != null) {
                charge = charge + parcelController.extraCharge!;
              }
              dmTips = orderController.tips;
              total = charge + dmTips + additionalCharge;
            }

            return _isLoggedIn
                ? Column(children: [
                    Expanded(
                        child: SingleChildScrollView(
                      padding: ResponsiveHelper.isDesktop(context)
                          ? null
                          : const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: FooterView(
                          child: SizedBox(
                              width: Dimensions.webMaxWidth,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CardWidget(
                                        child: Row(children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.3),
                                            shape: BoxShape.circle),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          child: CustomImage(
                                            image:
                                                '${Get.find<SplashController>().configModel!.baseUrls!.parcelCategoryImageUrl}'
                                                '/${widget.parcelCategory.image}',
                                            height: 40,
                                            width: 40,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          width: Dimensions.paddingSizeSmall),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Text(widget.parcelCategory.name!,
                                                style: robotoMedium.copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColor)),
                                            Text(
                                              widget
                                                  .parcelCategory.description!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: robotoRegular.copyWith(
                                                  color: Theme.of(context)
                                                      .disabledColor),
                                            ),
                                          ])),
                                    ])),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    CardWidget(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                          DetailsWidget(
                                              title: 'sender_details'.tr,
                                              address: widget.pickedUpAddress),
                                          const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeLarge),
                                          DetailsWidget(
                                              title: 'receiver_details'.tr,
                                              address:
                                                  widget.destinationAddress),
                                        ])),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    CardWidget(
                                        child: Row(children: [
                                      Expanded(
                                          child: Row(children: [
                                        Image.asset(Images.distance,
                                            height: 30, width: 30),
                                        const SizedBox(
                                            width: Dimensions.paddingSizeSmall),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('distance'.tr,
                                                  style: robotoRegular),
                                              Text(
                                                parcelController.distance == -1
                                                    ? 'calculating'.tr
                                                    : '${parcelController.distance!.toStringAsFixed(2)} ${'km'.tr}',
                                                style: robotoBold.copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              ),
                                            ]),
                                      ])),
                                      Expanded(
                                          child: Row(children: [
                                        Image.asset(Images.delivery,
                                            height: 30, width: 30),
                                        const SizedBox(
                                            width: Dimensions.paddingSizeSmall),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('delivery_fee'.tr,
                                                  style: robotoRegular),
                                              Text(
                                                parcelController.distance == -1
                                                    ? 'calculating'.tr
                                                    : PriceConverter
                                                        .convertPrice(charge),
                                                style: robotoBold.copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                                textDirection:
                                                    TextDirection.ltr,
                                              ),
                                            ]),
                                      ]))
                                    ])),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeLarge),
                                    (Get.find<SplashController>()
                                                .configModel!
                                                .dmTipsStatus ==
                                            1)
                                        ? GetBuilder<OrderController>(
                                            builder: (orderController) {
                                            return Container(
                                              color:
                                                  Theme.of(context).cardColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: Dimensions
                                                          .paddingSizeLarge,
                                                      horizontal: Dimensions
                                                          .paddingSizeSmall),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('delivery_man_tips'.tr,
                                                        style: robotoMedium),
                                                    const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeSmall),
                                                    SizedBox(
                                                      height: (orderController
                                                                      .selectedTips ==
                                                                  AppConstants
                                                                          .tips
                                                                          .length -
                                                                      1) &&
                                                              orderController
                                                                  .canShowTipsField
                                                          ? 0
                                                          : 60,
                                                      child: (orderController
                                                                      .selectedTips ==
                                                                  AppConstants
                                                                          .tips
                                                                          .length -
                                                                      1) &&
                                                              orderController
                                                                  .canShowTipsField
                                                          ? const SizedBox()
                                                          : ListView.builder(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              shrinkWrap: true,
                                                              physics:
                                                                  const BouncingScrollPhysics(),
                                                              itemCount:
                                                                  AppConstants
                                                                      .tips
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return TipsWidget(
                                                                  title: AppConstants.tips[
                                                                              index] ==
                                                                          '0'
                                                                      ? 'not_now'
                                                                          .tr
                                                                      : (index !=
                                                                              AppConstants.tips.length -
                                                                                  1)
                                                                          ? PriceConverter.convertPrice(double.parse(AppConstants.tips[index].toString()),
                                                                              forDM:
                                                                                  true)
                                                                          : AppConstants
                                                                              .tips[index]
                                                                              .tr,
                                                                  isSelected:
                                                                      orderController
                                                                              .selectedTips ==
                                                                          index,
                                                                  isSuggested: index !=
                                                                          0 &&
                                                                      AppConstants.tips[
                                                                              index] ==
                                                                          orderController
                                                                              .mostDmTipAmount
                                                                              .toString(),
                                                                  onTap: () {
                                                                    orderController
                                                                        .updateTips(
                                                                            index);
                                                                    if (orderController.selectedTips !=
                                                                            0 &&
                                                                        orderController.selectedTips !=
                                                                            AppConstants.tips.length -
                                                                                1) {
                                                                      orderController
                                                                          .addTips(
                                                                              double.parse(AppConstants.tips[index]));
                                                                    }
                                                                    if (orderController
                                                                            .selectedTips ==
                                                                        AppConstants.tips.length -
                                                                            1) {
                                                                      orderController
                                                                          .showTipsField();
                                                                    }
                                                                    _tipController
                                                                            .text =
                                                                        orderController
                                                                            .tips
                                                                            .toString();
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                    ),
                                                    SizedBox(
                                                        height: (orderController
                                                                        .selectedTips ==
                                                                    AppConstants
                                                                            .tips
                                                                            .length -
                                                                        1) &&
                                                                orderController
                                                                    .canShowTipsField
                                                            ? Dimensions
                                                                .paddingSizeExtraSmall
                                                            : 0),
                                                    orderController
                                                                .selectedTips ==
                                                            AppConstants.tips
                                                                    .length -
                                                                1
                                                        ? const SizedBox()
                                                        : ListTile(
                                                            onTap: () =>
                                                                orderController
                                                                    .toggleDmTipSave(),
                                                            leading: Checkbox(
                                                              visualDensity:
                                                                  const VisualDensity(
                                                                      horizontal:
                                                                          -4,
                                                                      vertical:
                                                                          -4),
                                                              activeColor: Theme
                                                                      .of(context)
                                                                  .primaryColor,
                                                              value: orderController
                                                                  .isDmTipSave,
                                                              onChanged: (bool?
                                                                      isChecked) =>
                                                                  orderController
                                                                      .toggleDmTipSave(),
                                                            ),
                                                            title: Text(
                                                                'save_for_later'
                                                                    .tr,
                                                                style: robotoMedium.copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor)),
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            visualDensity:
                                                                const VisualDensity(
                                                                    horizontal:
                                                                        0,
                                                                    vertical:
                                                                        -4),
                                                            dense: true,
                                                            horizontalTitleGap:
                                                                0,
                                                          ),
                                                    SizedBox(
                                                        height: orderController
                                                                    .selectedTips ==
                                                                AppConstants
                                                                        .tips
                                                                        .length -
                                                                    1
                                                            ? Dimensions
                                                                .paddingSizeDefault
                                                            : 0),
                                                    orderController
                                                                .selectedTips ==
                                                            AppConstants.tips
                                                                    .length -
                                                                1
                                                        ? Row(children: [
                                                            Expanded(
                                                              child:
                                                                  CustomTextField(
                                                                titleText:
                                                                    'enter_amount'
                                                                        .tr,
                                                                controller:
                                                                    _tipController,
                                                                inputAction:
                                                                    TextInputAction
                                                                        .done,
                                                                inputType:
                                                                    TextInputType
                                                                        .number,
                                                                onSubmit:
                                                                    (value) {
                                                                  if (value
                                                                      .isNotEmpty) {
                                                                    if (double.parse(
                                                                            value) >=
                                                                        0) {
                                                                      orderController
                                                                          .addTips(
                                                                              double.parse(value));
                                                                    } else {
                                                                      showCustomSnackBar(
                                                                          'tips_can_not_be_negative'
                                                                              .tr);
                                                                    }
                                                                  } else {
                                                                    orderController
                                                                        .addTips(
                                                                            0.0);
                                                                  }
                                                                },
                                                                onChanged:
                                                                    (String
                                                                        value) {
                                                                  if (value
                                                                      .isNotEmpty) {
                                                                    if (double.parse(
                                                                            value) >=
                                                                        0) {
                                                                      orderController
                                                                          .addTips(
                                                                              double.parse(value));
                                                                    } else {
                                                                      showCustomSnackBar(
                                                                          'tips_can_not_be_negative'
                                                                              .tr);
                                                                    }
                                                                  } else {
                                                                    orderController
                                                                        .addTips(
                                                                            0.0);
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: Dimensions
                                                                    .paddingSizeSmall),
                                                            InkWell(
                                                              onTap: () {
                                                                orderController
                                                                    .updateTips(
                                                                        0);
                                                                orderController
                                                                    .showTipsField();
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          0.5),
                                                                ),
                                                                padding: const EdgeInsets
                                                                    .all(
                                                                    Dimensions
                                                                        .paddingSizeSmall),
                                                                child: const Icon(
                                                                    Icons
                                                                        .clear),
                                                              ),
                                                            ),
                                                          ])
                                                        : const SizedBox(),
                                                  ]),
                                            );
                                          })
                                        : const SizedBox.shrink(),
                                    SizedBox(
                                        height: (Get.find<SplashController>()
                                                    .configModel!
                                                    .dmTipsStatus ==
                                                1)
                                            ? Dimensions.paddingSizeExtraSmall
                                            : 0),
                                    Text('charge_pay_by'.tr,
                                        style: robotoMedium),
                                    const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall),
                                    Row(children: [
                                      Expanded(
                                          child: InkWell(
                                        onTap: () => parcelController
                                            .setPayerIndex(0, true),
                                        child: Row(children: [
                                          Radio<String>(
                                            value:
                                                parcelController.payerTypes[0],
                                            groupValue: parcelController
                                                    .payerTypes[
                                                parcelController.payerIndex],
                                            activeColor:
                                                Theme.of(context).primaryColor,
                                            onChanged: (String? payerType) =>
                                                parcelController.setPayerIndex(
                                                    0, true),
                                          ),
                                          Text(
                                              parcelController.payerTypes[0].tr,
                                              style: robotoRegular),
                                        ]),
                                      )),
                                      _isCashOnDeliveryActive!
                                          ? Expanded(
                                              child: InkWell(
                                              onTap: () => parcelController
                                                  .setPayerIndex(1, true),
                                              child: Row(children: [
                                                Radio<String>(
                                                  value: parcelController
                                                      .payerTypes[1],
                                                  groupValue: parcelController
                                                          .payerTypes[
                                                      parcelController
                                                          .payerIndex],
                                                  activeColor: Theme.of(context)
                                                      .primaryColor,
                                                  onChanged:
                                                      (String? payerType) =>
                                                          parcelController
                                                              .setPayerIndex(
                                                                  1, true),
                                                ),
                                                Text(
                                                    parcelController
                                                        .payerTypes[1].tr,
                                                    style: robotoRegular),
                                              ]),
                                            ))
                                          : const SizedBox(),
                                    ]),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeLarge),
                                    Row(children: [
                                      _isCashOnDeliveryActive!
                                          ? Expanded(
                                              child: PaymentButton(
                                                icon: Images.cashOnDelivery,
                                                title: 'cash_on_delivery'.tr,
                                                subtitle:
                                                    'pay_your_payment_after_getting_item'
                                                        .tr,
                                                isSelected: parcelController
                                                        .paymentIndex ==
                                                    0,
                                                onTap: () => parcelController
                                                    .setPaymentIndex(0, true),
                                              ),
                                            )
                                          : const SizedBox(),
                                      SizedBox(
                                          width: (Get.find<SplashController>()
                                                          .configModel!
                                                          .customerWalletStatus ==
                                                      1 &&
                                                  parcelController.payerIndex ==
                                                      0)
                                              ? Dimensions.paddingSizeLarge
                                              : 0),
                                      (Get.find<SplashController>()
                                                      .configModel!
                                                      .customerWalletStatus ==
                                                  1 &&
                                              parcelController.payerIndex == 0)
                                          ? Expanded(
                                              child: PaymentButton(
                                                icon: Images.wallet,
                                                title: 'wallet_payment'.tr,
                                                subtitle:
                                                    'pay_from_your_existing_balance'
                                                        .tr,
                                                isSelected: parcelController
                                                        .paymentIndex ==
                                                    1,
                                                onTap: () => parcelController
                                                    .setPaymentIndex(1, true),
                                              ),
                                            )
                                          : const SizedBox(),
                                    ]),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    (!_isPluginPaymentActive! &&
                                            _isDigitalPaymentActive! &&
                                            parcelController.payerIndex == 0)
                                        ? PaymentButton(
                                            icon: Images.digitalPayment,
                                            title: 'digital_payment'.tr,
                                            subtitle: 'faster_and_safe_way'.tr,
                                            isSelected:
                                                parcelController.paymentIndex ==
                                                    2,
                                            onTap: () => parcelController
                                                .setPaymentIndex(2, true),
                                          )
                                        : const SizedBox(),
                                    (_isPluginPaymentActive! &&
                                            _isDigitalPaymentActive! &&
                                            parcelController.payerIndex == 0)
                                        ? Column(children: [
                                            Row(children: [
                                              Text('pay_via_online'.tr,
                                                  style: robotoBold.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault)),
                                              Text(
                                                'faster_and_secure_way_to_pay_bill'
                                                    .tr,
                                                style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(context)
                                                        .hintColor),
                                              ),
                                            ]),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeLarge),
                                            ListView.builder(
                                                itemCount: Get.find<
                                                        SplashController>()
                                                    .configModel!
                                                    .activePaymentMethodList!
                                                    .length,
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  bool isSelected = parcelController
                                                              .paymentIndex ==
                                                          2 &&
                                                      Get.find<SplashController>()
                                                              .configModel!
                                                              .activePaymentMethodList![
                                                                  index]
                                                              .getWay! ==
                                                          parcelController
                                                              .digitalPaymentName;
                                                  return InkWell(
                                                    onTap: () {
                                                      parcelController
                                                          .setPaymentIndex(
                                                              2, true);
                                                      parcelController
                                                          .changeDigitalPaymentName(Get
                                                                  .find<
                                                                      SplashController>()
                                                              .configModel!
                                                              .activePaymentMethodList![
                                                                  index]
                                                              .getWay!);
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: isSelected
                                                              ? Colors.blue
                                                                  .withOpacity(
                                                                      0.05)
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius: BorderRadius
                                                              .circular(Dimensions
                                                                  .radiusDefault)),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeSmall,
                                                          vertical: Dimensions
                                                              .paddingSizeLarge),
                                                      child: Row(children: [
                                                        Container(
                                                          height: 20,
                                                          width: 20,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: isSelected
                                                                  ? Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                  : Theme.of(
                                                                          context)
                                                                      .cardColor,
                                                              border: Border.all(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .disabledColor)),
                                                          child: Icon(
                                                              Icons.check,
                                                              color: Theme.of(
                                                                      context)
                                                                  .cardColor,
                                                              size: 16),
                                                        ),
                                                        const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeDefault),
                                                        CustomImage(
                                                          height: 20,
                                                          fit: BoxFit.contain,
                                                          image:
                                                              '${Get.find<SplashController>().configModel!.baseUrls!.gatewayImageUrl}/${Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImage!}',
                                                        ),
                                                        const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeSmall),
                                                        Text(
                                                          Get.find<
                                                                  SplashController>()
                                                              .configModel!
                                                              .activePaymentMethodList![
                                                                  index]
                                                              .getWayTitle!,
                                                          style: robotoMedium
                                                              .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeDefault),
                                                        ),
                                                      ]),
                                                    ),
                                                  );
                                                })
                                          ])
                                        : const SizedBox(),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    Text('order_summary'.tr,
                                        style: robotoMedium),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('delivery_fee'.tr,
                                              style: robotoRegular),
                                          Text(
                                            parcelController.distance == -1
                                                ? 'calculating'.tr
                                                : PriceConverter.convertPrice(
                                                    charge),
                                            style: robotoRegular.copyWith(
                                                color:
                                                    parcelController.distance ==
                                                            -1
                                                        ? Colors.red
                                                        : Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .color),
                                          ),
                                        ]),
                                    SizedBox(
                                        height: Get.find<SplashController>()
                                                    .configModel!
                                                    .dmTipsStatus ==
                                                1
                                            ? Dimensions.paddingSizeSmall
                                            : 0.0),
                                    (Get.find<SplashController>()
                                                .configModel!
                                                .dmTipsStatus ==
                                            1)
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('delivery_man_tips'.tr,
                                                  style: robotoRegular),
                                              Text(
                                                  '(+) ${PriceConverter.convertPrice(dmTips)}',
                                                  style: robotoRegular,
                                                  textDirection:
                                                      TextDirection.ltr),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                    SizedBox(
                                        height: Get.find<SplashController>()
                                                .configModel!
                                                .additionalChargeStatus!
                                            ? Dimensions.paddingSizeSmall
                                            : 0),
                                    Get.find<SplashController>()
                                            .configModel!
                                            .additionalChargeStatus!
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                                Text(
                                                    Get.find<SplashController>()
                                                        .configModel!
                                                        .additionalChargeName!,
                                                    style: robotoRegular),
                                                Text(
                                                  '(+) ${PriceConverter.convertPrice(Get.find<SplashController>().configModel!.additionCharge)}',
                                                  style: robotoRegular,
                                                  textDirection:
                                                      TextDirection.ltr,
                                                ),
                                              ])
                                        : const SizedBox(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical:
                                              Dimensions.paddingSizeSmall),
                                      child: Divider(
                                          thickness: 1,
                                          color: Theme.of(context)
                                              .hintColor
                                              .withOpacity(0.5)),
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('total_amount'.tr,
                                              style: robotoMedium),
                                          PriceConverter.convertAnimationPrice(
                                              total,
                                              textStyle: robotoMedium),
                                        ]),
                                    const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall),
                                    CheckoutCondition(
                                        orderController:
                                            Get.find<OrderController>(),
                                        parcelController: parcelController,
                                        isParcel: true),
                                    SizedBox(
                                        height:
                                            ResponsiveHelper.isDesktop(context)
                                                ? Dimensions.paddingSizeLarge
                                                : 0),
                                    ResponsiveHelper.isDesktop(context)
                                        ? _bottomButton(
                                            parcelController, charge)
                                        : const SizedBox(),
                                  ]))),
                    )),
                    ResponsiveHelper.isDesktop(context)
                        ? const SizedBox()
                        : _bottomButton(parcelController, charge),
                  ])
                : NotLoggedInScreen(callBack: (value) {
                    initCall();
                    setState(() {});
                  });
          });
        }),
      ),
    );
  }

  void orderCallback(bool isSuccess, String? message, String orderID,
      int? zoneID, double orderAmount, double? maxCodAmount) {
    Get.find<ParcelController>().startLoader(false);
    if (isSuccess) {
      if (Get.find<OrderController>().isDmTipSave) {
        Get.find<AuthController>().saveDmTipIndex(
            Get.find<OrderController>().selectedTips.toString());
      }
      if (Get.find<ParcelController>().paymentIndex == 2) {
        if (GetPlatform.isWeb) {
          Get.back();
          String? hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          String selectedUrl =
              '${AppConstants.eComBaseUrl}/payment-mobile?order_id=$orderID&&customer_id=${Get.find<UserController>().userInfoModel!.id}&payment_method=${Get.find<ParcelController>().digitalPaymentName}&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&status=';
          html.window.open(selectedUrl, "_self");
        } else {
          Get.offNamed(RouteHelper.getPaymentRoute(
              orderID,
              Get.find<UserController>().userInfoModel!.id,
              'parcel',
              orderAmount,
              _isCashOnDeliveryActive,
              Get.find<ParcelController>().digitalPaymentName));
        }
      } else {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID));
      }
      Get.find<OrderController>().updateTips(-1, notify: false);
    } else {
      showCustomSnackBar(message);
    }
  }

  Widget _bottomButton(ParcelController parcelController, double charge) {
    return CustomButton(
      buttonText: 'confirm_parcel_request'.tr,
      isLoading: parcelController.isLoading,
      margin: ResponsiveHelper.isDesktop(context)
          ? null
          : const EdgeInsets.all(Dimensions.paddingSizeSmall),
      onPressed: parcelController.acceptTerms
          ? () {
              if (parcelController.distance == -1) {
                showCustomSnackBar('delivery_fee_not_set_yet'.tr);
              } else if (Get.find<OrderController>().tips < 0) {
                showCustomSnackBar('tips_can_not_be_negative'.tr);
              } else if (parcelController.paymentIndex == -1) {
                showCustomSnackBar('please_select_payment_method_first'.tr);
              } else {
                Get.find<ParcelController>().startLoader(true);
                Get.find<OrderController>().placeOrder(
                    PlaceOrderBody(
                      cart: [],
                      couponDiscountAmount: null,
                      distance: parcelController.distance,
                      scheduleAt: null,
                      orderAmount: charge,
                      orderNote: '',
                      orderType: 'parcel',
                      receiverDetails: widget.destinationAddress,
                      paymentMethod: parcelController.paymentIndex == 0
                          ? 'cash_on_delivery'
                          : parcelController.paymentIndex == 1
                              ? 'wallet'
                              : 'digital_payment',
                      couponCode: null,
                      storeId: null,
                      address: widget.pickedUpAddress.address,
                      latitude: widget.pickedUpAddress.latitude,
                      longitude: widget.pickedUpAddress.longitude,
                      addressType: widget.pickedUpAddress.addressType,
                      contactPersonName:
                          widget.pickedUpAddress.contactPersonName ?? '',
                      contactPersonNumber:
                          widget.pickedUpAddress.contactPersonNumber ?? '',
                      streetNumber: widget.pickedUpAddress.streetNumber ?? '',
                      house: widget.pickedUpAddress.house ?? '',
                      floor: widget.pickedUpAddress.floor ?? '',
                      discountAmount: 0,
                      taxAmount: 0,
                      parcelCategoryId: widget.parcelCategory.id.toString(),
                      chargePayer: parcelController
                          .payerTypes[parcelController.payerIndex],
                      dmTips: Get.find<OrderController>().tips.toString(),
                      cutlery: 0,
                      unavailableItemNote: '',
                      deliveryInstruction: '',
                      partialPayment: 0,
                    ),
                    widget.pickedUpAddress.zoneId,
                    orderCallback,
                    0,
                    0);
              }
            }
          : null,
    );
  }
}
