import 'package:payapp/controller/category_controller.dart';
import 'package:payapp/controller/splash_controller.dart';
import 'package:payapp/core/utils/helper/helper.dart';
import 'package:payapp/helper/constants.dart';
import 'package:payapp/helper/responsive_helper.dart';
import 'package:payapp/helper/route_helper.dart';
import 'package:payapp/util/dimensions.dart';
import 'package:payapp/util/styles.dart';
import 'package:payapp/view/base/custom_image.dart';
import 'package:payapp/view/base/footer_view.dart';
import 'package:payapp/view/base/menu_drawer.dart';
import 'package:payapp/view/base/no_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payapp/view/base/web_page_title_widget.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<CategoryController>().getCategoryList(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("categories".tr),
        centerTitle: true,
        leading: back(),
        actions: [width(0)],
      ),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
          child: Scrollbar(
              controller: scrollController,
              child: SingleChildScrollView(
                  controller: scrollController,
                  child: FooterView(
                      child: Column(
                    children: [
                      WebScreenTitleWidget(title: 'categories'.tr),
                      SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: GetBuilder<CategoryController>(
                            builder: (catController) {
                          return catController.categoryList != null
                              ? catController.categoryList!.isNotEmpty
                                  ? GridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: ResponsiveHelper
                                                .isDesktop(context)
                                            ? 6
                                            : ResponsiveHelper.isTab(context)
                                                ? 4
                                                : 3,
                                        childAspectRatio: (1 / 1),
                                        mainAxisSpacing:
                                            Dimensions.paddingSizeSmall,
                                        crossAxisSpacing:
                                            Dimensions.paddingSizeSmall,
                                      ),
                                      padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall),
                                      itemCount:
                                          catController.categoryList!.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () => Get.toNamed(
                                              RouteHelper.getCategoryItemRoute(
                                            catController
                                                .categoryList![index].id,
                                            catController
                                                .categoryList![index].name!,
                                          )),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radiusSmall),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 5,
                                                    spreadRadius: 1)
                                              ],
                                            ),
                                            alignment: Alignment.center,
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .radiusSmall),
                                                    child: CustomImage(
                                                      height: 50,
                                                      width: 50,
                                                      fit: BoxFit.cover,
                                                      image:
                                                          '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${catController.categoryList![index].image}',
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeExtraSmall),
                                                  Text(
                                                    catController
                                                        .categoryList![index]
                                                        .name!,
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        robotoMedium.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ]),
                                          ),
                                        );
                                      },
                                    )
                                  : NoDataScreen(text: 'no_category_found'.tr)
                              : const Center(
                                  child: CircularProgressIndicator());
                        }),
                      ),
                    ],
                  ))))),
    );
  }
}
