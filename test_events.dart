import 'package:supabase/supabase.dart';

void main() async {
  final url = 'https://anlixjwtmbduosemcwpv.supabase.co';
  final key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFubGl4and0bWJkdW9zZW1jd3B2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIxNjA3MzgsImV4cCI6MjA3NzczNjczOH0.iyNA0Kg0cFMKqmi-VaPcGjPzu3UJ_srXzIog0kiQeAc';

  final supabase = SupabaseClient(url, key);

  try {
    // Check DISTINCT event_types
    final events = await supabase
      .from('analytics_events')
      .select('event_type')
      .limit(100);
    
    final types = events.map((e) => e['event_type']).toSet();
    print('Recent event types: $types');
    
    // Test the Analytics View
    final view = await supabase.from('deal_analytics').select().limit(5);
    print('Deal analytics view sample: $view');
    
  } catch (e) {
    print('Error: \$e');
  }
}
