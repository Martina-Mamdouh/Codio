import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../viewmodels/companies_management_viewmodel.dart';
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

  @override
  Widget build(BuildContext context) {
    final companiesVm = context.watch<CompaniesManagementViewModel>();
    final companiesVmRead = context.read<CompaniesManagementViewModel>();
    final dealsVm = context.watch<DealsManagementViewModel>();

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
        .where((c) => c.lat != 0 && c.lng != 0)
        .toList();

    final selectedCompany = companiesVm.selectedCompany;
    final selectedCompanyIsVisible = selectedCompany != null
        ? visibleCompanies.any((company) => company.id == selectedCompany.id)
        : false;

    final LatLng center = selectedCompany != null && selectedCompanyIsVisible
        ? LatLng(selectedCompany.lat, selectedCompany.lng)
        : validCompanies.isNotEmpty
        ? LatLng(validCompanies.first.lat, validCompanies.first.lng)
        : _fallbackCenter;

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
                                    markers: validCompanies.map((company) {
                                      final isSelected =
                                          companiesVm.selectedCompany?.id == company.id;
                                      return Marker(
                                        point: LatLng(company.lat, company.lng),
                                        width: 44,
                                        height: 44,
                                        child: GestureDetector(
                                          onTap: () =>
                                              companiesVmRead.selectCompanyForEdit(company),
                                          child: Icon(
                                            Icons.location_pin,
                                            color: isSelected
                                                ? AppTheme.kElectricLime
                                                : Colors.redAccent,
                                            size: isSelected ? 42 : 34,
                                          ),
                                        ),
                                      );
                                    }).toList(),
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

  const _MapManagementHeader({
    required this.totalCompanies,
    required this.companiesWithLocation,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onRefresh,
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
          ],
        ),
      ],
    );
  }
}
