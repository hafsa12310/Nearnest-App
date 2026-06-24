import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const NearnestApp());
}

class NearnestApp extends StatelessWidget {
  const NearnestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nearnest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF8FF),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class Vendor {
  const Vendor({
    required this.name,
    required this.category,
    required this.description,
    required this.priceFrom,
    required this.rating,
    required this.responseTime,
    required this.location,
    required this.phone,
    required this.email,
    required this.tags,
    this.verified = true,
  });

  final String name;
  final String category;
  final String description;
  final int priceFrom;
  final double rating;
  final String responseTime;
  final String location;
  final String phone;
  final String email;
  final List<String> tags;
  final bool verified;
}

const List<Vendor> vendors = [
  Vendor(
    name: 'Aarav Moments',
    category: 'Photography',
    description: 'Event, wedding, birthday, and same-day candid photography.',
    priceFrom: 120,
    rating: 4.9,
    responseTime: '10 min',
    location: 'Downtown',
    phone: '+15550101001',
    email: 'bookings@aaravmoments.example',
    tags: ['Urgent booking', 'Edited photos', '4K video'],
  ),
  Vendor(
    name: 'Bloom & Drape',
    category: 'Decoration',
    description: 'Modern home, party, proposal, and festive decoration packages.',
    priceFrom: 180,
    rating: 4.8,
    responseTime: '15 min',
    location: 'North Side',
    phone: '+15550101002',
    email: 'hello@bloomdrape.example',
    tags: ['Flowers', 'Balloon wall', 'Theme setup'],
  ),
  Vendor(
    name: 'Saffron Bites',
    category: 'Catering',
    description: 'Fresh buffet, snack boxes, desserts, and custom event menus.',
    priceFrom: 250,
    rating: 4.7,
    responseTime: '20 min',
    location: 'West Market',
    phone: '+15550101003',
    email: 'orders@saffronbites.example',
    tags: ['Veg options', 'Halal', 'Desserts'],
  ),
  Vendor(
    name: 'Glow Studio',
    category: 'Makeup',
    description: 'On-location party, bridal, and photoshoot makeup artists.',
    priceFrom: 95,
    rating: 4.9,
    responseTime: '12 min',
    location: 'City Center',
    phone: '+15550101004',
    email: 'care@glowstudio.example',
    tags: ['At-home', 'Hair styling', 'Trial available'],
  ),
  Vendor(
    name: 'PlanSwift Events',
    category: 'Planning',
    description: 'Last-minute coordination for birthdays, meetings, and family events.',
    priceFrom: 300,
    rating: 4.6,
    responseTime: '18 min',
    location: 'East Avenue',
    phone: '+15550101005',
    email: 'team@planswift.example',
    tags: ['Vendor bundle', 'Timeline', 'Guest desk'],
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  String _category = 'All';
  RangeValues _budget = const RangeValues(50, 350);

  List<String> get _categories => ['All', ...{for (final v in vendors) v.category}];

  List<Vendor> get _filteredVendors {
    final lowerQuery = _query.trim().toLowerCase();
    return vendors.where((vendor) {
      final matchesQuery = lowerQuery.isEmpty ||
          vendor.name.toLowerCase().contains(lowerQuery) ||
          vendor.category.toLowerCase().contains(lowerQuery) ||
          vendor.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      final matchesCategory = _category == 'All' || vendor.category == _category;
      final matchesBudget = vendor.priceFrom >= _budget.start && vendor.priceFrom <= _budget.end;
      return matchesQuery && matchesCategory && matchesBudget;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredVendors = _filteredVendors;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeroHeader(),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'Search photographer, decoration, catering...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CategoryChips(
                      categories: _categories,
                      selected: _category,
                      onSelected: (category) => setState(() => _category = category),
                    ),
                    const SizedBox(height: 16),
                    _BudgetFilter(
                      values: _budget,
                      onChanged: (values) => setState(() => _budget = values),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${filteredVendors.length} trusted vendors available now',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              sliver: filteredVendors.isEmpty
                  ? const SliverToBoxAdapter(child: _EmptyState())
                  : SliverList.separated(
                      itemBuilder: (context, index) => VendorCard(vendor: filteredVendors[index]),
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemCount: filteredVendors.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6750A4), Color(0xFF9C6ADE)]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6750A4).withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('Nearby verified services', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Book trusted local vendors fast.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Compare price, rating, response time, and contact vendors without sharing unnecessary personal data.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.88)),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.categories, required this.selected, required this.onSelected});

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories
            .map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: selected == category,
                  onSelected: (_) => onSelected(category),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _BudgetFilter extends StatelessWidget {
  const _BudgetFilter({required this.values, required this.onChanged});

  final RangeValues values;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Budget range: \$${values.start.round()} - \$${values.end.round()}'),
            RangeSlider(
              values: values,
              min: 50,
              max: 400,
              divisions: 7,
              labels: RangeLabels('\$${values.start.round()}', '\$${values.end.round()}'),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class VendorCard extends StatelessWidget {
  const VendorCard({required this.vendor, super.key});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VendorDetailsScreen(vendor: vendor))),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(_iconForCategory(vendor.category), color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(child: Text(vendor.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                            if (vendor.verified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, color: Color(0xFF1E88E5), size: 18),
                            ],
                          ],
                        ),
                        Text('${vendor.category} • ${vendor.location}'),
                      ],
                    ),
                  ),
                  Text('\$${vendor.priceFrom}+', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 14),
              Text(vendor.description),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: vendor.tags.map((tag) => Chip(label: Text(tag), visualDensity: VisualDensity.compact)).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 20),
                  Text(' ${vendor.rating}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.bolt_rounded, color: Color(0xFF43A047), size: 20),
                  Text(' Replies in ${vendor.responseTime}'),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VendorDetailsScreen extends StatefulWidget {
  const VendorDetailsScreen({required this.vendor, super.key});

  final Vendor vendor;

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _eventController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _launchTrustedUri(Uri uri) async {
    if (uri.scheme != 'tel' && uri.scheme != 'mailto') {
      _showMessage('Unsupported contact method blocked for your safety.');
      return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showMessage('Could not open this contact method on your device.');
    }
  }

  void _submitEnquiry() {
    if (!_formKey.currentState!.validate()) return;
    final subject = Uri.encodeComponent('Booking enquiry for ${widget.vendor.name}');
    final body = Uri.encodeComponent('Event: ${_eventController.text.trim()}\nNotes: ${_notesController.text.trim()}');
    _launchTrustedUri(Uri.parse('mailto:${widget.vendor.email}?subject=$subject&body=$body'));
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;

    return Scaffold(
      appBar: AppBar(title: Text(vendor.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          VendorCard(vendor: vendor),
          const SizedBox(height: 18),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick secure enquiry', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text('Only share details needed for this booking. Payments and identity documents should be handled through verified channels only.'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _eventController,
                      maxLength: 60,
                      decoration: const InputDecoration(labelText: 'Event type', hintText: 'Birthday, wedding, corporate event...'),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.length < 3) return 'Enter at least 3 characters.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 240,
                      decoration: const InputDecoration(labelText: 'Need and budget', hintText: 'Date, location area, budget, and must-haves'),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.length < 10) return 'Add a few details so the vendor can respond accurately.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _launchTrustedUri(Uri.parse('tel:${vendor.phone}')),
                            icon: const Icon(Icons.call_rounded),
                            label: const Text('Call'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _submitEnquiry,
                            icon: const Icon(Icons.lock_rounded),
                            label: const Text('Email safely'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.manage_search_rounded, size: 56, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('No vendors match your filters', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          const Text('Try a different category, keyword, or budget range.'),
        ],
      ),
    );
  }
}

IconData _iconForCategory(String category) {
  return switch (category) {
    'Photography' => Icons.photo_camera_rounded,
    'Decoration' => Icons.celebration_rounded,
    'Catering' => Icons.restaurant_rounded,
    'Makeup' => Icons.brush_rounded,
    'Planning' => Icons.event_available_rounded,
    _ => Icons.handshake_rounded,
  };
}
