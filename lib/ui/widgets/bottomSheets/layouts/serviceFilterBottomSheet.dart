import 'package:edemand_partner/ui/widgets/closeAndConfirmButton.dart';
import 'package:edemand_partner/ui/widgets/customCheckbox.dart';
import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class FilterByBottomSheet extends StatefulWidget {
  const FilterByBottomSheet({
    super.key,
    required this.minRange,
    required this.maxRange,
    required this.selectedMaxRange,
    required this.selectedMinRange,
    this.selectedRating,
  });

  final double minRange;
  final double maxRange;
  final double selectedMinRange;
  final double selectedMaxRange;
  final String? selectedRating;

  @override
  State<FilterByBottomSheet> createState() => _FilterByBottomSheetState();
}

class _FilterByBottomSheetState extends State<FilterByBottomSheet> {
  late String selectedRating = widget.selectedRating ?? 'All';
  late double startRange = widget.minRange;
  late double endRange = widget.maxRange;
  List<CategoryModel>? selectedCategories;
  late RangeValues filterPriceRange = RangeValues(
    widget.minRange > widget.selectedMinRange
        ? widget.minRange
        : widget.selectedMinRange,
    widget.maxRange < widget.selectedMaxRange
        ? widget.selectedMaxRange
        : widget.maxRange,
  );
  List ratingFilterValues = ['All', '5', '4', '3', '2', '1'];

  String? _getCategoryNames() {
    final List<String?>? categoriesName = selectedCategories
        ?.map((CategoryModel category) => category.name)
        .toList();

    return categoriesName?.join(',');
  }

  Widget _getTitle(String title) {
    return CustomText(
      title,
      color: Theme.of(context).colorScheme.blackColor,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      fontSize: 16.0,
      textAlign: TextAlign.left,
    );
  }

  Widget _showSelectedCategory() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomSizedBox(
          width: MediaQuery.sizeOf(context).width * 0.80,
          child: Text(
            selectedCategories == null
                ? 'allCategories'.translate(context: context)
                : _getCategoryNames() ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.lightGreyColor,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 12.0,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(
          child: CustomInkWellContainer(
            onTap: () async {
              selectedCategories = await UiUtils.showModelBottomSheets(
                enableDrag: true,
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8),
                isScrollControlled: true,
                context: context,
                child: CategoryBottomSheet(
                  initialySelected: selectedCategories,
                ),
              );
              setState(() {});
            },
            child: Text(
              'edit'.translate(context: context),
              style: TextStyle(
                color: Theme.of(context).colorScheme.accentColor,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 14.0,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        )
      ],
    );
  }

  Widget _getBudgetFilterLableAndPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _getTitle('budget'.translate(context: context)),
        Text(
          '${filterPriceRange.start.toStringAsFixed(2).priceFormat()}-${filterPriceRange.end.toStringAsFixed(2).priceFormat()}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 14.0,
          ),
          textAlign: TextAlign.right,
        )
      ],
    );
  }

  Widget _getBudgetFilterRangeSlider() {
    return RangeSlider(
      activeColor: Theme.of(context).colorScheme.accentColor,
      inactiveColor: Theme.of(context).colorScheme.lightGreyColor,
      values: filterPriceRange,
      max: widget.maxRange,
      min: widget.minRange,
      onChanged: (RangeValues newValue) {
        filterPriceRange = newValue;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetLayout(
        title: "filter".translate(context: context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _getTitle('category'.translate(context: context)),
                      const Spacer(),
                      if (selectedCategories != null) ...[
                        GestureDetector(
                          onTap: () {
                            selectedCategories = null;
                            setState(() {});
                          },
                          child: Text(
                            'clear'.translate(context: context),
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Theme.of(context).colorScheme.blackColor,
                              fontSize: 12,
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                  const CustomSizedBox(
                    height: 10,
                  ),
                  _showSelectedCategory(),
                  if (widget.maxRange > 1) ...{
                    Divider(
                        color: Theme.of(context)
                            .colorScheme
                            .lightGreyColor
                            .withValues(alpha: 0.4)),
                    _getBudgetFilterLableAndPrice(),
                    _getBudgetFilterRangeSlider(),
                  },
                  Divider(
                      color: Theme.of(context)
                          .colorScheme
                          .lightGreyColor
                          .withValues(alpha: 0.4)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: _getTitle('rating'.translate(context: context)),
            ),
            _getRatingFilterValues(),
            const CustomSizedBox(
              height: 15,
            ),
            CloseAndConfirmButton(
              confirmButtonName: 'applyFilter',
              closeButtonName: "close",
              confirmButtonPressed: () {
                ServiceFilterDataModel? filterModel;
                // if (selectedCategories?.length == 1) {
                //   filterModel = ServiceFilterDataModel(
                //     rating: selectedRating,
                //     categoryId: selectedCategories?[0].id.toString(),
                //     maxBudget: filterPriceRange.end.toString(),
                //     minBudget: filterPriceRange.start.toString(),
                //   );
                // } else
                if (selectedCategories?.isNotEmpty ?? false) {
                  final String categoryIDs = selectedCategories!
                      .map((CategoryModel e) => e.id)
                      .toList()
                      .join(',');
                  filterModel = ServiceFilterDataModel(
                    rating: selectedRating,
                    caetgoryIds: categoryIDs,
                    maxBudget: filterPriceRange.end.toString(),
                    minBudget: filterPriceRange.start.toString(),
                  );
                  // if (selectedCategories!.length > 1) {
                  //   final String categoryIDs = selectedCategories!
                  //       .map((CategoryModel e) => e.id)
                  //       .toList()
                  //       .join(',');
                  //   filterModel = ServiceFilterDataModel(
                  //     rating: selectedRating,
                  //     caetgoryIds: categoryIDs,
                  //     maxBudget: filterPriceRange.end.toString(),
                  //     minBudget: filterPriceRange.start.toString(),
                  //   );
                  // }
                } else {
                  filterModel = ServiceFilterDataModel(
                    rating: selectedRating.toLowerCase() == 'all'
                        ? null
                        : selectedRating,
                    maxBudget: filterPriceRange.end.toString(),
                    minBudget: filterPriceRange.start.toString(),
                  );
                }

                Navigator.pop(context, filterModel);
              },
              closeButtonPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ));
  }

  Widget _getRatingFilterValues() {
    return CustomContainer(
      padding: const EdgeInsetsDirectional.only(top: 10.0),
      height: 50,
      width: double.infinity,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        children: List.generate(
          ratingFilterValues.length,
          (int index) => GestureDetector(
            onTap: () {
              selectedRating = ratingFilterValues[index];
              setState(() {});
            },
            child: CustomContainer(
              margin: const EdgeInsetsDirectional.only(
                end: 15.0,
              ),
              width: 60,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                    Radius.circular(UiUtils.borderRadiusOf10)),
                color: ratingFilterValues[index] == selectedRating
                    ? Theme.of(context).colorScheme.accentColor
                    : null,
                border: Border.all(
                  color: ratingFilterValues[index] == selectedRating
                      ? Theme.of(context).colorScheme.accentColor
                      : Theme.of(context).colorScheme.lightGreyColor,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star,
                        color: AppColors.starRatingColor, size: 18),
                    const CustomSizedBox(
                      width: 3,
                    ),
                    Text(
                      '${ratingFilterValues[index]}',
                      style: TextStyle(
                        color: ratingFilterValues[index] == selectedRating
                            ? AppColors.whiteColors
                            : null,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryBottomSheet extends StatefulWidget {
  const CategoryBottomSheet({super.key, this.initialySelected});

  final List<CategoryModel>? initialySelected;

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  late List<CategoryModel> selectedCategory = widget.initialySelected ?? [];
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListen);

  void _pageScrollListen() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchServiceCategoryCubit>().hasMoreData()) {
        context.read<FetchServiceCategoryCubit>().fetchMoreCategories();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetLayout(
      title: "category",
      child: Column(
        children: [
          BlocBuilder<FetchServiceCategoryCubit, FetchServiceCategoryState>(
            builder: (BuildContext context, FetchServiceCategoryState state) {
              if (state is FetchServiceCategoryInProgress) {
                return Center(
                  child: CustomCircularProgressIndicator(
                    color: AppColors.whiteColors,
                  ),
                );
              }

              if (state is FetchServiceCategorySuccess) {
                if (state.serviceCategories.isEmpty) {
                  return NoDataContainer(
                      titleKey: 'noDataFound'.translate(context: context));
                }

                return CustomContainer(
                  constraints: BoxConstraints(
                      minHeight: 100,
                      maxHeight: MediaQuery.sizeOf(context).height * 0.6),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(state.serviceCategories.length,
                          (index) {
                        return recursiveExpansionList(
                          state.serviceCategories[index].toJson(),
                        );
                      }),
                    ),
                  ),
                );
              }
              return const CustomContainer();
            },
          ),
          CloseAndConfirmButton(
            confirmButtonName: 'apply',
            closeButtonName: "close",
            confirmButtonPressed: () {
              Navigator.pop(context, selectedCategory);
            },
            closeButtonPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  Widget getCategoryTile(
      {required String title,
      required bool? value,
      required Function(bool?)? onChanged,
      VoidCallback? onTap}) {
    return CustomInkWellContainer(
      onTap: onTap?.call,
      child: CustomContainer(
        height: 40,
        child: Row(
          children: [
            CustomText(
              title,
              maxLines: 1,
              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: value ?? false ? FontWeight.bold : FontWeight.normal,
            ),
            const CustomContainer(width: 5),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: CustomSizedBox(
                    height: 25,
                    width: 25,
                    child: CustomCheckBox(
                      onChanged: (p0) {
                        return onTap?.call();
                      },
                      value: value,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget recursiveExpansionList(Map map) {
    List subList = [];
    subList = map['subCategory'] ?? [];
    final bool contains = selectedCategory
        .where((CategoryModel element) {
          return element.id == map['id'];
        })
        .toSet()
        .isNotEmpty;

    if (subList.isNotEmpty) {
      if (map['level'] == 0) {
        return ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(
            map['name'],
          ),
          children: subList.map((e) => recursiveExpansionList(e)).toList(),
        );
      } else {
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 15.0),
          child: ExpansionTile(
            title: Text(map['name']),
            children: subList.map((e) => recursiveExpansionList(e)).toList(),
          ),
        );
      }
    } else {
      if (map['level'] == 0) {
        return getCategoryTile(
          value: contains,
          title: map['name'],
          onChanged: (bool? val) {
            final CategoryModel categoryModel = CategoryModel(
              id: map['id'],
              name: map['name'],
            );
            if (contains) {
              selectedCategory
                  .removeWhere((CategoryModel e) => e.id == map['id']);
            } else {
              selectedCategory.add(categoryModel);
            }

            setState(() {});
          },
        );
      } else {
        return getCategoryTile(
            onTap: () {
              final CategoryModel categoryModel = CategoryModel(
                id: map['id'],
                name: map['name'],
              );
              if (contains) {
                selectedCategory
                    .removeWhere((CategoryModel e) => e.id == map['id']);
              } else {
                selectedCategory.add(categoryModel);
              }

              setState(() {});
            },
            onChanged: (bool? val) {
              final CategoryModel categoryModel = CategoryModel(
                id: map['id'],
                name: map['name'],
              );
              if (contains) {
                selectedCategory
                    .removeWhere((CategoryModel e) => e.id == map['id']);
              } else {
                selectedCategory.add(categoryModel);
              }

              setState(() {});
            },
            title: map['name'],
            value: contains);
      }
    }
  }
}
