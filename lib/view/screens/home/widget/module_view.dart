import 'package:payapp/core/utils/helper/helper.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:payapp/controller/auth_controller.dart';
import 'package:payapp/controller/banner_controller.dart';
import 'package:payapp/controller/location_controller.dart';
import 'package:payapp/controller/splash_controller.dart';
import 'package:payapp/data/model/response/address_model.dart';
import 'package:payapp/helper/responsive_helper.dart';
import 'package:payapp/util/dimensions.dart';
import 'package:payapp/util/styles.dart';
import 'package:payapp/view/base/custom_loader.dart';
import 'package:payapp/view/base/title_widget.dart';
import 'package:payapp/view/screens/address/widget/address_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payapp/view/screens/home/widget/banner_view.dart';
import 'package:payapp/view/screens/home/widget/popular_store_view.dart';

class ModuleView extends StatelessWidget {
  final SplashController splashController;

  const ModuleView({super.key, required this.splashController});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GetBuilder<BannerController>(builder: (bannerController) {
        return const BannerView(isFeatured: true);
      }),
      splashController.moduleList != null
          ? splashController.moduleList!.isNotEmpty
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: Dimensions.paddingSizeSmall,
                    crossAxisSpacing: Dimensions.paddingSizeSmall,
                    childAspectRatio: (1 / 1),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  itemCount: splashController.moduleList!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => splashController.switchModule(index, true),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 0.15),
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3)
                          ],
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 60,
                                width: Get.size.width,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10)),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          '${splashController.configModel!.baseUrls!.moduleImageUrl}/${splashController.moduleList![index].icon}',
                                        ))),
                              ),
                              height(5),
                              Center(
                                  child: Text(
                                splashController.moduleList![index].moduleName!,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: robotoMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: Dimensions.fontSizeExtraSmall),
                              )),
                            ]),
                      ),
                    );
                  },
                )
              : Center(
                  child: Padding(
                  padding:
                      const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  child: Text('no_module_found'.tr),
                ))
          : ModuleShimmer(isEnabled: splashController.moduleList == null),
      GetBuilder<LocationController>(builder: (locationController) {
        List<AddressModel?> addressList = [];
        if (Get.find<AuthController>().isLoggedIn() &&
            locationController.addressList != null) {
          addressList = [];
          bool contain = false;
          if (locationController.getUserAddress()?.id != null) {
            for (int index = 0;
                index < locationController.addressList!.length;
                index++) {
              if (locationController.addressList![index].id ==
                  locationController.getUserAddress()!.id) {
                contain = true;
                break;
              }
            }
          }
          if (contain) {
            addressList.add(Get.find<LocationController>().getUserAddress());
          }
          addressList.addAll(locationController.addressList!);
        }
        return (!Get.find<AuthController>().isLoggedIn() ||
                locationController.addressList != null)
            ? addressList.isNotEmpty
                ? Column(
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall),
                        child: TitleWidget(title: 'deliver_to'.tr),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      SizedBox(
                        height: 75,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: addressList.length,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall),
                          itemBuilder: (context, index) {
                            return Container(
                              width: 300,
                              padding: const EdgeInsets.only(
                                  right: Dimensions.paddingSizeSmall),
                              child: AddressWidget(
                                address: addressList[index],
                                fromAddress: false,
                                onTap: () {
                                  if (locationController.getUserAddress()!.id !=
                                      addressList[index]!.id) {
                                    Get.dialog(const CustomLoader(),
                                        barrierDismissible: false);
                                    locationController.saveAddressAndNavigate(
                                      addressList[index],
                                      null,
                                      false,
                                      ResponsiveHelper.isDesktop(context),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : const SizedBox()
            : AddressShimmer(
                isEnabled: Get.find<AuthController>().isLoggedIn() &&
                    locationController.addressList == null);
      }),
      const BannerView(
        isFeatured: false,
      ),
      const PopularStoreView(isPopular: false, isFeatured: true),
      const SizedBox(height: 30),
    ]);
  }
}

class ModuleShimmer extends StatelessWidget {
  final bool isEnabled;

  const ModuleShimmer({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        childAspectRatio: (1 / 1),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[Get.isDarkMode ? 700 : 200]!,
                  spreadRadius: 1,
                  blurRadius: 5)
            ],
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: isEnabled,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Colors.grey[300]),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Center(
                  child: Container(
                      height: 15, width: 50, color: Colors.grey[300])),
            ]),
          ),
        );
      },
    );
  }
}

class AddressShimmer extends StatelessWidget {
  final bool isEnabled;

  const AddressShimmer({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Dimensions.paddingSizeLarge),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall),
          child: TitleWidget(title: 'deliver_to'.tr),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        SizedBox(
          height: 70,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: 5,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall),
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                padding:
                    const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context)
                      ? Dimensions.paddingSizeDefault
                      : Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                          blurRadius: 5,
                          spreadRadius: 1)
                    ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      Icons.location_on,
                      size: ResponsiveHelper.isDesktop(context) ? 50 : 40,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Shimmer(
                        duration: const Duration(seconds: 2),
                        enabled: isEnabled,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  height: 15,
                                  width: 100,
                                  color: Colors.grey[300]),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall),
                              Container(
                                  height: 10,
                                  width: 150,
                                  color: Colors.grey[300]),
                            ]),
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
