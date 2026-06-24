import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
    required this.latitude,
    required this.longitude,
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
  final double latitude;
  final double longitude;
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
    latitude: 40.758,
    longitude: -73.9855,
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
    latitude: 40.7851,
    longitude: -73.9683,
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
    latitude: 40.742,
    longitude: -74.0048,
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
    latitude: 40.7306,
    longitude: -73.9866,
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
    latitude: 40.7527,
    longitude: -73.9772,
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
  Position? _userPosition;
  bool _isLocating = false;
  String _locationStatus = 'Use location to sort vendors by distance.';

  List<String> get _categories => ['All', ...{for (final v in vendors) v.category}];

  List<Vendor> get _filteredVendors {
    final lowerQuery = _query.trim().toLowerCase();
    final filtered = vendors.where((vendor) {
      final matchesQuery = lowerQuery.isEmpty ||
          vendor.name.toLowerCase().contains(lowerQuery) ||
          vendor.category.toLowerCase().contains(lowerQuery) ||
          vendor.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      final matchesCategory = _category == 'All' || vendor.category == _category;
      final matchesBudget = vendor.priceFrom >= _budget.start && vendor.priceFrom <= _budget.end;
      return matchesQuery && matchesCategory && matchesBudget;
    }).toList();

    if (_userPosition != null) {
      filtered.sort((a, b) => _distanceTo(a).compareTo(_distanceTo(b)));
    }

    return filtered;
  }

  double _distanceTo(Vendor vendor) {
    final position = _userPosition;
    if (position == null) return double.infinity;
    return Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          vendor.latitude,
          vendor.longitude,
        ) /
        1000;
  }

  Future<void> _suggestNearbyVendors() async {
    setState(() {
      _isLocating = true;
      _locationStatus = 'Checking location permission...';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationStatus = 'Turn on location services to see nearest vendors first.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() => _locationStatus = 'Location permission denied. Showing vendors by rating and relevance.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium));
      setState(() {
        _userPosition = position;
        _locationStatus = 'Nearest vendors are now suggested automatically.';
      });
    } catch (_) {
      setState(() => _locationStatus = 'Unable to read location right now. Showing default vendor order.');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
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
                    _NearbyLocationCard(
                      status: _locationStatus,
                      isLoading: _isLocating,
                      onPressed: _suggestNearbyVendors,
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
                      itemBuilder: (context, index) {
                        final vendor = filteredVendors[index];
                        return VendorCard(vendor: vendor, distanceKm: _userPosition == null ? null : _distanceTo(vendor));
                      },
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

class _NearbyLocationCard extends StatelessWidget {
  const _NearbyLocationCard({required this.status, required this.isLoading, required this.onPressed});

  final String status;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.near_me_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(status)),
            TextButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Nearby'),
            ),
          ],
        ),
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
  const VendorCard({required this.vendor, this.distanceKm, super.key});

  final Vendor vendor;
  final double? distanceKm;

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
                  if (distanceKm != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.place_rounded, color: Color(0xFF6750A4), size: 20),
                    Text(' ${distanceKm!.toStringAsFixed(1)} km'),
                  ],
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
    if (uri.scheme != 'tel' && uri.scheme != 'mailto' && uri.scheme != 'https') {
      _showMessage('Unsupported contact method blocked for your safety.');
      return;
    }

    if (uri.scheme == 'https' && uri.host != 'www.google.com') {
      _showMessage('Only trusted map links are allowed.');
      return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showMessage('Could not open this contact method on your device.');
    }
  }

  void _openMap() {
    final vendor = widget.vendor;
    final query = Uri.encodeComponent('${vendor.latitude},${vendor.longitude} ${vendor.name}');
    _launchTrustedUri(Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'));
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openMap,
                            icon: const Icon(Icons.map_rounded),
                            label: const Text('Map'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _submitEnquiry,
                            icon: const Icon(Icons.lock_rounded),
                            label: const Text('Email'),
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

// Uses the platform geolocation permission flow; no precise location is stored.
