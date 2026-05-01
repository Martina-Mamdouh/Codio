import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/models/company_model.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/companies_management_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/deals_management_viewmodel.dart';
import '../views/widgets/company_editor_form.dart';

enum _DealTypeFilter { both, link, code }

class MapManagementView extends StatefulWidget {
  const MapManagementView({super.key});

  @override
  State<MapManagementView> createState() => _MapManagementViewState();
}

class _MapManagementViewState extends State<MapManagementView> {
  _DealTypeFilter _selectedFilter = _DealTypeFilter.both;
  bool _showMapStats = false;

  static const LatLng _fallbackCenter = LatLng(24.7136, 46.6753);

  bool _matchesFilter(String dealType) {
    final normalized = dealType.trim().toLowerCase();
    switch (_selectedFilter) {
      case _DealTypeFilter.both:
        return normalized == 'code' || normalized == 'link' || normalized == 'both';
      case _DealTypeFilter.link:
        return normalized == 'link' || normalized == 'both';
      case _DealTypeFilter.code:
        return normalized == 'code' || normalized == 'both';
    }
  }

  LatLng _getCompanyLocation(CompanyModel company) {
    if (company.lat != 0 && company.lng != 0) {
      return LatLng(company.lat, company.lng);
    }
    if (company.branches != null) {
      for (var b in company.branches!) {
        if (b.lat != 0 && b.lng != 0) return LatLng(b.lat, b.lng);
      }
    }
    return _fallbackCenter;
  }

  @override
  Widget build(BuildContext context) {
    final companiesVm = context.watch<CompaniesManagementViewModel>();
    final companiesVmRead = context.read<CompaniesManagementViewModel>();
    final dealsVm = context.watch<DealsManagementViewModel>();
    final dashboardVm = context.watch<DashboardViewModel>();

    final bool canFilterByDeals = dealsVm.deals.isNotEmpty;
    final filteredCompanyIds = dealsVm.deals
        .where((deal) => _matchesFilter(deal.dealType))
        .map((deal) => deal.companyId)
        .toSet();

    final visibleCompanies = canFilterByDeals
        ? companiesVm.companies
              .where((company) => filteredCompanyIds.contains(company.id))
              .toList()
        : companiesVm.companies;

    final validCompanies = visibleCompanies
        .where((c) => (c.lat != 0 && c.lng != 0) || (c.branches?.any((b) => b.lat != 0 && b.lng != 0) ?? false))
        .toList();

    final selectedCompany = companiesVm.selectedCompany;
    final selectedCompanyIsVisible = selectedCompany != null
        ? visibleCompanies.any((company) => company.id == selectedCompany.id)
        : false;

    final LatLng center = selectedCompany != null && selectedCompanyIsVisible
        ? _getCompanyLocation(selectedCompany)
        : validCompanies.isNotEmpty
        ? _getCompanyLocation(validCompanies.first)
        : _fallbackCenter;

    final List<Marker> mapMarkers = [];
    for (var company in validCompanies) {
      final isSelected = companiesVm.selectedCompany?.id == company.id;
      final int clickCount = dashboardVm.companyPerformance.firstWhere(
        (c) => c['id'] == company.id,
        orElse: () => {'map_click_count': 0},
      )['map_click_count'] as int? ?? 0;

      Widget buildMarkerIcon(Color color, double size) {
        return GestureDetector(
          onTap: () => companiesVmRead.selectCompanyForEdit(company),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showMapStats)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.kElectricLime, width: 0.5),
                  ),
                  child: Text(
                    '$clickCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Icon(
                Icons.location_pin,
                color: color,
                size: size,
              ),
            ],
          ),
        );
      }

      if (company.lat != 0 && company.lng != 0) {
        mapMarkers.add(
          Marker(
            point: LatLng(company.lat, company.lng),
            width: 60,
            height: 60,
            child: buildMarkerIcon(
              isSelected ? AppTheme.kElectricLime : Colors.redAccent,
              isSelected ? 42 : 34,
            ),
          ),
        );
      }
      if (company.branches != null) {
        for (var branch in company.branches!) {
          if (branch.lat != 0 && branch.lng != 0) {
            mapMarkers.add(
              Marker(
                point: LatLng(branch.lat, branch.lng),
                width: 60,
                height: 60,
                child: buildMarkerIcon(
                  isSelected ? AppTheme.kElectricLime : Colors.orangeAccent,
                  isSelected ? 38 : 30,
                ),
              ),
            );
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      body: Row(
        children: [
          Expanded(
            flex: companiesVm.isEditorVisible ? 3 : 5,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MapManagementHeader(
                    totalCompanies: visibleCompanies.length,
                    companiesWithLocation: validCompanies.length,
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (newFilter) {
                      setState(() => _selectedFilter = newFilter);
                    },
                    onRefresh: () async {
                      await companiesVmRead.fetchCompanies();
                      if (!context.mounted) return;
                      await context.read<DealsManagementViewModel>().fetchDeals();
                      if (!context.mounted) return;
                      await context.read<DashboardViewModel>().loadDashboardData();
                    },
                    showMapStats: _showMapStats,
                    onToggleStats: (val) {
                      setState(() => _showMapStats = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 3,
                    child: Card(
                      color: AppTheme.kLightBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: companiesVm.isLoading && companiesVm.companies.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.kElectricLime,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: center,
                                  initialZoom: 11.5,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.kodio.app',
                                  ),
                                  MarkerLayer(
                                    markers: mapMarkers,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 2,
                    child: Card(
                      color: AppTheme.kLightBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: visibleCompanies.isEmpty
                          ? const Center(
                              child: Text(
                                'لا توجد شركات حالياً',
                                style: TextStyle(color: AppTheme.kSubtleText),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: visibleCompanies.length,
                              separatorBuilder: (_, __) => const Divider(
                                color: Colors.white10,
                                height: 12,
                              ),
                              itemBuilder: (context, index) {
                                final company = visibleCompanies[index];
                                final hasLocation =
                                    company.lat != 0 && company.lng != 0;
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    company.name,
                                    style: const TextStyle(
                                      color: AppTheme.kLightText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    hasLocation
                                        ? 'lat: ${company.lat.toStringAsFixed(6)} | lng: ${company.lng.toStringAsFixed(6)}'
                                        : 'لا يوجد موقع محدد',
                                    style: const TextStyle(
                                      color: AppTheme.kSubtleText,
                                      fontSize: 12,
                                    ),
                                  ),
                                  leading: Icon(
                                    hasLocation
                                        ? Icons.location_on
                                        : Icons.location_off,
                                    color: hasLocation
                                        ? AppTheme.kElectricLime
                                        : Colors.orangeAccent,
                                  ),
                                  trailing: TextButton.icon(
                                    onPressed: () =>
                                        companiesVmRead.selectCompanyForEdit(company),
                                    icon: const Icon(Icons.edit_location_alt),
                                    label: const Text('تعديل الموقع'),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (companiesVm.isEditorVisible) ...[
            const VerticalDivider(thickness: 1, width: 1, color: Colors.black),
            const Expanded(flex: 2, child: CompanyEditorForm()),
          ],
        ],
      ),
    );
  }
}

class _MapManagementHeader extends StatelessWidget {
  final int totalCompanies;
  final int companiesWithLocation;
  final _DealTypeFilter selectedFilter;
  final ValueChanged<_DealTypeFilter> onFilterChanged;
  final Future<void> Function() onRefresh;
  final bool showMapStats;
  final ValueChanged<bool> onToggleStats;

  const _MapManagementHeader({
    required this.totalCompanies,
    required this.companiesWithLocation,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onRefresh,
    required this.showMapStats,
    required this.onToggleStats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'إدارة المواقع على الخريطة',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.kLightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.kElectricLime.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$companiesWithLocation / $totalCompanies',
                style: const TextStyle(
                  color: AppTheme.kElectricLime,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRefresh,
              tooltip: 'تحديث',
              icon: const Icon(Icons.refresh, color: AppTheme.kElectricLime),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('Both'),
              selected: selectedFilter == _DealTypeFilter.both,
              onSelected: (_) => onFilterChanged(_DealTypeFilter.both),
            ),
            ChoiceChip(
              label: const Text('Link'),
              selected: selectedFilter == _DealTypeFilter.link,
              onSelected: (_) => onFilterChanged(_DealTypeFilter.link),
            ),
            ChoiceChip(
              label: const Text('Code'),
              selected: selectedFilter == _DealTypeFilter.code,
              onSelected: (_) => onFilterChanged(_DealTypeFilter.code),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.analytics_outlined,
                    size: 16,
                    color: AppTheme.kSubtleText,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'إحصائيات النقرات',
                    style: TextStyle(
                      color: AppTheme.kLightText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: showMapStats,
                    onChanged: onToggleStats,
                    activeColor: AppTheme.kElectricLime,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
