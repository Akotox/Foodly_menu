import 'package:flutter/material.dart';
import 'package:foodly/components/menu_card.dart';
import 'package:foodly/components/restaruant_categories.dart';
import 'package:foodly/components/restaurant_appbar.dart';
import 'package:foodly/components/restaurant_info.dart';
import 'package:foodly/models/menu.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({Key? key}) : super(key: key);

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final scrollController = ScrollController();

  int selectedCategoryIndex = 0;

  double restaurantInfoHeight = 200 + 170 - kToolbarHeight;

  @override
  void initState() {
    super.initState();
    createBreakPoint();
    scrollController.addListener(() {
      updateCategoryIndexOnScroll(scrollController.offset);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollToCategory(int index) {
    if (selectedCategoryIndex != index) {
      int totalItems = 0;
      for (var i = 0; i < index; i++) {
        totalItems += demoCategoryMenus[i].items.length;
      }

      scrollController.animateTo(
          restaurantInfoHeight + (116 * totalItems) + (50 * index),
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease);
    }
    setState(() {
      selectedCategoryIndex = index;
    });
  }

  List<double> breakPoint = [];
  void createBreakPoint() {
    double firstBreakPoint =
        restaurantInfoHeight + 50 + (116 * demoCategoryMenus[0].items.length);

    breakPoint.add(firstBreakPoint);

    for (var i = 1; i < demoCategoryMenus.length; i++) {
      double breakPoints =
          breakPoint.last + 50 + (116 * demoCategoryMenus[i].items.length);
      breakPoint.add(breakPoints);
    }
  }

  void updateCategoryIndexOnScroll(double offset) {
    for (var i = 0; i < demoCategoryMenus.length; i++) {
      if (i == 0) {
        if ((offset < breakPoint.first) & (selectedCategoryIndex != 0)) {
          setState(() {
            selectedCategoryIndex = 0;
          });
        }
      } else if ((breakPoint[i - 1] <= offset) & (offset < breakPoint[i])) {
        if (selectedCategoryIndex != i) {
          setState(() {
            selectedCategoryIndex = i;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          const RestaurantAppBar(),
          const SliverToBoxAdapter(child: RestaurantInfo()),
          SliverPersistentHeader(
              delegate: RestaurantCategories(
                onChanged: scrollToCategory,
                selectedIndex: selectedCategoryIndex,
              ),
              pinned: true),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, categoryIndex) {
                List<Menu> items = demoCategoryMenus[categoryIndex].items;
                return MenuCategoryItem(
                    title: demoCategoryMenus[categoryIndex].category,
                    items: List.generate(
                        items.length,
                        (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: MenuCard(
                                  image: items[index].image,
                                  title: items[index].title,
                                  price: items[index].price),
                            )));
              }, childCount: demoCategoryMenus.length),
            ),
          ),
        ],
      ),
    );
  }
}
