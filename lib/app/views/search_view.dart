import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/deal_model.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import 'widgets/deal_card.dart';
import 'deal_details_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _supabaseService = SupabaseService();
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<DealModel> _searchResults = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  static const String _recentSearchesKey = 'recent_searches';

  final List<String> _popularSearches = [
    'نايكي',
    'أمازون',
    'ستاربكس',
    'ملابس',
    'إلكترونيات',
    'طعام',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_recentSearchesKey) ?? [];
    setState(() {
      _recentSearches = searches;
    });
  }

  Future<void> _saveSearch(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 5) {
      _recentSearches = _recentSearches.take(5).toList();
    }

    await prefs.setStringList(_recentSearchesKey, _recentSearches);

    setState(() {});
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
    setState(() {
      _recentSearches.clear();
    });
  }

  Future<void> _performSearch(
    String query, {
    bool saveToHistory = false,
  }) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    if (saveToHistory) {
      await _saveSearch(query);
    }

    final results = await _supabaseService.searchDeals(query);

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  void _selectSuggestion(String query) {
    _searchController.text = query;
    _performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.kDarkBackground,
        appBar: AppBar(
          toolbarHeight: 60.h,
          backgroundColor: AppTheme.kDarkBackground,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
          ),
          title: Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Material(
              color: Colors.transparent,
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ابحث عن المتاجر والعروض...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.kElectricLime,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            _performSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppTheme.kLightBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 12.h,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                  if (value.length >= 2) {
                    _performSearch(value, saveToHistory: false);
                  } else if (value.isEmpty) {
                    _performSearch('');
                  }
                },
                onSubmitted: (value) {
                  _performSearch(value, saveToHistory: true);
                },
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.kElectricLime,
                  ),
                )
              : _hasSearched
              ? _buildSearchResults()
              : _buildSuggestions(),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'آخر عمليات البحث',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _clearRecentSearches,
                  child: Text(
                    'مسح الكل',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.start,
              children: _recentSearches.map((search) {
                return InkWell(
                  onTap: () => _selectSuggestion(search),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.kLightBackground,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, size: 18.w, color: Colors.grey),
                        SizedBox(width: 8.w),
                        Text(
                          search,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
          ],

          Row(
            children: [
              Expanded(
                child: Text(
                  'مقترحات شائعة',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.start,
            children: _popularSearches.map((search) {
              return InkWell(
                onTap: () => _selectSuggestion(search),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.kElectricLime.withValues(alpha: 0.2),
                        AppTheme.kElectricLime.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppTheme.kElectricLime.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 18.w,
                        color: AppTheme.kElectricLime,
                      ),
                      SizedBox(width: 8.w),
                      Text(search, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80.w, color: Colors.grey[700]),
            SizedBox(height: 16.h),
            Text(
              'لا توجد نتائج',
              style: TextStyle(color: Colors.grey[600], fontSize: 18.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'جرب كلمات بحث مختلفة',
              style: TextStyle(color: Colors.grey[700], fontSize: 14.sp),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Text(
            'النتائج (${_searchResults.length})',
            style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          ),
        ),
        Expanded(
          child: Consumer<UserProfileViewModel>(
            builder: (context, profileVm, _) {
                  return RefreshIndicator(
                    onRefresh: () => _performSearch(_searchController.text),
                    color: AppTheme.kElectricLime,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        vertical: 16.h,
                        horizontal: 16.w,
                      ),
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) => SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final deal = _searchResults[index];
                        final isFav = profileVm.isDealFavorite(deal.id);

                        return DealCard(
                          deal: deal,
                          isFavorite: isFav,
                          showCategory: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DealDetailsView(deal: deal),
                              ),
                            );
                          },
                          onFavoriteToggle: () async {
                            final success = await profileVm
                                .toggleFavoriteForDeal(deal.id);
                            if (!success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'تعذّر تحديث المفضّلة، حاول مرة أخرى',
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
            },
          ),
        ),
      ],
    );
  }
}
