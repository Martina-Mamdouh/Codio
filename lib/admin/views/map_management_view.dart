import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../viewmodels/companies_management_viewmodel.dart';
import '../views/widgets/company_editor_form.dart';

class MapManagementView extends StatelessWidget {
  const MapManagementView({super.key});

  static const LatLng _fallbackCenter = LatLng(24.7136, 46.6753);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompaniesManagementViewModel>();
    final vmRead = context.read<CompaniesManagementViewModel>();
    final validCompanies = vm.companies
        .where((c) => c.lat != 0 && c.lng != 0)
        .toList();

    final LatLng center = vm.selectedCompany != null
        ? LatLng(vm.selectedCompany!.lat, vm.selectedCompany!.lng)
        : validCompanies.isNotEmpty
        ? LatLng(validCompanies.first.lat, validCompanies.first.lng)
        : _fallbackCenter;

    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      body: Row(
        children: [
          Expanded(
            flex: vm.isEditorVisible ? 3 : 5,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MapManagementHeader(
                    totalCompanies: vm.companies.length,
                    companiesWithLocation: validCompanies.length,
                    onRefresh: vmRead.fetchCompanies,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 3,
                    child: Card(
                      color: AppTheme.kLightBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: vm.isLoading && vm.companies.isEmpty
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
                                          vm.selectedCompany?.id == company.id;
                                      return Marker(
                                        point: LatLng(company.lat, company.lng),
                                        width: 44,
                                        height: 44,
                                        child: GestureDetector(
                                          onTap: () =>
                                              vmRead.selectCompanyForEdit(company),
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
                      child: vm.companies.isEmpty
                          ? const Center(
                              child: Text(
                                'لا توجد شركات حالياً',
                                style: TextStyle(color: AppTheme.kSubtleText),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: vm.companies.length,
                              separatorBuilder: (_, __) => const Divider(
                                color: Colors.white10,
                                height: 12,
                              ),
                              itemBuilder: (context, index) {
                                final company = vm.companies[index];
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
                                        vmRead.selectCompanyForEdit(company),
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
          if (vm.isEditorVisible) ...[
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
  final Future<void> Function() onRefresh;

  const _MapManagementHeader({
    required this.totalCompanies,
    required this.companiesWithLocation,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
