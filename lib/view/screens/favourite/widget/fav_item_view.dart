import 'package:payapp/controller/wishlist_controller.dart';
import 'package:payapp/util/dimensions.dart';
import 'package:payapp/view/base/footer_view.dart';
import 'package:payapp/view/base/item_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavItemView extends StatelessWidget {
  final bool isStore;
  final bool isSearch;
  const FavItemView({super.key, required this.isStore, this.isSearch = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<WishListController>(builder: (wishController) {
        return RefreshIndicator(
          onRefresh: () async {
            await wishController.getWishList();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FooterView(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: ItemsView(
                  isStore: isStore, items: wishController.wishItemList, stores: wishController.wishStoreList,
                  noDataText: 'no_wish_data_found'.tr, isFeatured: true,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
