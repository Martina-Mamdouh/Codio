import 'package:supabase/supabase.dart';
import 'dart:io';

Future<void> main() async {
  final supabase = SupabaseClient(
    'https://anlixjwtmbduosemcwpv.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFubGl4and0bWJkdW9zZW1jd3B2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIxNjA3MzgsImV4cCI6MjA3NzczNjczOH0.iyNA0Kg0cFMKqmi-VaPcGjPzu3UJ_srXzIog0kiQeAc',
  );

  try {
    final response = await supabase.from('top_deals_by_views').select().limit(1);
    
    if (response.isNotEmpty) {
      final columns = response.first.keys.toList();
      print('Columns of top_deals_by_views: ' + columns.toString());
    } else {
      print('Table is empty, cannot infer columns from a row.');
    }

    final response2 = await supabase.from('company_performance').select().limit(1);
    if (response2.isNotEmpty) {
      final columns2 = response2.first.keys.toList();
      print('Columns of company_performance: ' + columns2.toString());
    } else {
      print('Table is empty, cannot infer columns from a row.');
    }
    
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
