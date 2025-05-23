import 'package:payapp/controller/campaign_controller.dart';
import 'package:payapp/controller/splash_controller.dart';
import 'package:payapp/data/model/response/basic_campaign_model.dart';
import 'package:payapp/helper/date_converter.dart';
import 'package:payapp/helper/responsive_helper.dart';
import 'package:payapp/util/dimensions.dart';
import 'package:payapp/util/styles.dart';
import 'package:payapp/view/base/custom_image.dart';
import 'package:payapp/view/base/footer_view.dart';
import 'package:payapp/view/base/item_view.dart';
import 'package:payapp/view/base/menu_drawer.dart';
import 'package:payapp/view/base/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CampaignScreen extends StatefulWidget {
  final BasicCampaignModel campaign;
  const CampaignScreen({super.key, required this.campaign});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {

  @override
  void initState() {
    super.initState();

    Get.find<CampaignController>().getBasicCampaignDetails(widget.campaign.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<CampaignController>(builder: (campaignController) {
        return CustomScrollView(
          slivers: [

            ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFF171A29),
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CustomImage(
                    fit: BoxFit.cover, height: 220, width: 1150,
                    image: '${Get.find<SplashController>().configModel!.baseUrls!.campaignImageUrl}/${widget.campaign.image}',
                  ),
                ),
              ),
            ) : SliverAppBar(
              expandedHeight: 230,
              toolbarHeight: 50,
              pinned: true,
              floating: false,
              backgroundColor: Theme.of(context).primaryColor,
              leading: IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => Get.back()),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.campaign.title!,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.white),
                ),
                background: CustomImage(
                  fit: BoxFit.cover,
                  image: '${Get.find<SplashController>().configModel!.baseUrls!.campaignImageUrl}/${widget.campaign.image}',
                ),
              ),
            ),

            SliverToBoxAdapter(child: FooterView(child: Container(
              width: Dimensions.webMaxWidth,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
              ),
              child: Column(children: [

                campaignController.campaign != null ? Column(
                  children: [

                    Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        child: CustomImage(
                          image: '${Get.find<SplashController>().configModel!.baseUrls!.campaignImageUrl}/${campaignController.campaign!.image}',
                          height: 40, width: 50, fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          campaignController.campaign!.title!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          campaignController.campaign!.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        ),
                      ])),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    campaignController.campaign!.startTime != null ? Row(children: [
                      Text('campaign_schedule'.tr, style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                      )),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        '${DateConverter.stringToLocalDateOnly(campaignController.campaign!.availableDateStarts!)}'
                            ' - ${DateConverter.stringToLocalDateOnly(campaignController.campaign!.availableDateEnds!)}',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                      ),
                    ]) : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    campaignController.campaign!.startTime != null ? Row(children: [
                      Text('daily_time'.tr, style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                      )),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        '${DateConverter.convertTimeToTime(campaignController.campaign!.startTime!)}'
                            ' - ${DateConverter.convertTimeToTime(campaignController.campaign!.endTime!)}',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                      ),
                    ]) : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  ],
                ) : const SizedBox(),

                ItemsView(
                  isStore: true, items: null,
                  stores: campaignController.campaign?.store,
                ),

              ]),
            ))),
          ],
        );
      }),
    );
  }
}