import 'package:carzigo_partner/common_widgets/app_bottom_sheet.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<String?> showAppOptionSheet({
  required BuildContext context,
  required String title,
  required List<String> options,
  String? selected,
  String? searchHint,
}) {
  return showAppBottomSheet<String>(
    context: context,
    topRadius: 16,
    builder: (sheetContext) {
      return _AppOptionSheetBody(
        title: title,
        options: options,
        selected: selected,
        searchHint: searchHint ?? AppStrings.search.tr(),
      );
    },
  );
}

class _AppOptionSheetBody extends StatefulWidget {
  const _AppOptionSheetBody({
    required this.title,
    required this.options,
    required this.selected,
    required this.searchHint,
  });

  final String title;
  final List<String> options;
  final String? selected;
  final String searchHint;

  @override
  State<_AppOptionSheetBody> createState() => _AppOptionSheetBodyState();
}

class _AppOptionSheetBodyState extends State<_AppOptionSheetBody> {
  late final TextEditingController _searchController;
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filtered = widget.options;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = widget.options;
      } else {
        _filtered = widget.options
            .where((e) => e.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;

    return AppBottomSheetBody(
      scrollable: false,
      padding: const EdgeInsets.only(bottom: kAppSheetBottomGap),
      child: SizedBox(
        height: maxHeight,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  widget.title,
                  style: AppTextStyles.style(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  autofocus: widget.options.length > 20,
                  style: AppTextStyles.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    hintStyle: AppTextStyles.style(
                      fontSize: 14,
                      color: AppColors.textFieldHint,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.noResultsFound.tr(),
                          style: AppTextStyles.style(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final option = _filtered[index];
                          final isSelected = option == widget.selected;
                          return InkWell(
                            onTap: () => Navigator.pop(context, option),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.peach
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                option,
                                style: AppTextStyles.style(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
    );
  }
}
