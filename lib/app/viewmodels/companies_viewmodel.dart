import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/company_model.dart';
import '../../core/services/supabase_service.dart';

class CompaniesViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<CompanyModel> companies = [];
  bool isLoading = false;
  String? errorMessage;

  // تتبع حالة المتابعة والتحميل لكل شركة
  final Map<int, bool> _followStatus = {};
  final Map<int, bool> _followLoading = {};

  // قناة Realtime
  RealtimeChannel? _companiesChannel;

  bool isFollowed(int companyId) => _followStatus[companyId] ?? false;
  bool isFollowLoading(int companyId) => _followLoading[companyId] ?? false;

  Future<void> loadCompanies() async {
    isLoading = true;
    errorMessage = null;
    if (hasListeners) {
      notifyListeners();
    }

    try {
      // Reverting to sequential loading to avoid saturating network on low-end devices
      companies = await _supabaseService.getCompanies();
      await _getInitialFollowStatus();
      
      // Subscribe to Realtime after loading
      _subscribeToCompanies();
      _subscribeToFollowing();
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء تحميل الشركات';
      debugPrint('❌ Error loading companies: $e');
    } finally {
      isLoading = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  Future<void> _getInitialFollowStatus() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await _loadFollowingStatus(userId);
    }
  }

  Future<void> _loadFollowingStatus(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('following')
          .select('company_id')
          .eq('user_id', userId);

      _followStatus.clear();
      for (final row in data) {
        _followStatus[row['company_id'] as int] = true;
      }
    } catch (e) {
      debugPrint('❌ Error loading following status: $e');
    }
  }

  // Realtime for companies updates
  void _subscribeToCompanies() {
    if (_companiesChannel != null) {
      Supabase.instance.client.removeChannel(_companiesChannel!);
    }

    _companiesChannel = Supabase.instance.client
        .channel('public:companies')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'companies',
          callback: (payload) async {
            final companyId = payload.newRecord['id'] as int;
            debugPrint('🔄 Realtime update for company $companyId in list');

            try {
              final refreshed = await _supabaseService.getCompanyById(
                companyId,
              );
              if (refreshed == null) return;

              final index = companies.indexWhere((c) => c.id == companyId);
              if (index != -1) {
                companies[index] = refreshed;
                if (hasListeners) {
                  notifyListeners();
                }
              }
            } catch (e) {
              debugPrint('❌ Error refreshing company $companyId: $e');
            }
          },
        )
        .subscribe();
  }
  // Realtime for following changes

  RealtimeChannel? _followingChannel;

  void _subscribeToFollowing() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _followingChannel = Supabase.instance.client
        .channel('user_following')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'following',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            if (payload.eventType == PostgresChangeEvent.insert) {
              final companyId = payload.newRecord['company_id'] as int;
              _followStatus[companyId] = true;
              debugPrint('🔄 Following added: $companyId');
            } else if (payload.eventType == PostgresChangeEvent.delete) {
              final companyId = payload.oldRecord['company_id'] as int;
              _followStatus[companyId] = false;
              debugPrint('🔄 Following removed: $companyId');
            }
            if (hasListeners) {
              notifyListeners();
            }
          },
        )
        .subscribe();
  }

  Future<void> toggleFollow(int companyId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      errorMessage = 'يجب تسجيل الدخول أولاً';
      if (hasListeners) {
        notifyListeners();
      }
      return;
    }

    _followLoading[companyId] = true;
    if (hasListeners) {
      notifyListeners();
    }

    try {
      final isCurrentlyFollowed = _followStatus[companyId] ?? false;

      if (isCurrentlyFollowed) {
        // إلغاء المتابعة
        await Supabase.instance.client
            .from('following')
            .delete()
            .eq('user_id', userId)
            .eq('company_id', companyId);

        _followStatus[companyId] = false;

        // حدّث العداد محلياً في القائمة (فوري)
        _updateCompanyFollowersCount(companyId, -1);
      } else {
        // متابعة
        await Supabase.instance.client.from('following').insert({
          'user_id': userId,
          'company_id': companyId,
        });

        _followStatus[companyId] = true;

        // حدّث العداد محلياً في القائمة (فوري)
        _updateCompanyFollowersCount(companyId, 1);
      }

      if (hasListeners) {
        notifyListeners();
      }
      // Realtime هيأكد القيمة من السيرفر بعد كده
    } catch (e) {
      errorMessage = 'حدث خطأ في المتابعة';
      debugPrint('❌ Error toggling follow: $e');
      if (hasListeners) {
        notifyListeners();
      }
    } finally {
      _followLoading[companyId] = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  void _updateCompanyFollowersCount(int companyId, int delta) {
    final index = companies.indexWhere((c) => c.id == companyId);
    if (index != -1) {
      final company = companies[index];
      companies[index] = company.copyWith(
        followersCount: (company.followersCount ?? 0) + delta,
      );
    }
  }

  @override
  void dispose() {
    if (_companiesChannel != null) {
      Supabase.instance.client.removeChannel(_companiesChannel!);
    }
    if (_followingChannel != null) {
      Supabase.instance.client.removeChannel(_followingChannel!);
    }
    super.dispose();
  }
}
