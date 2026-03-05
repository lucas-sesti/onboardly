import 'package:flutter/material.dart';
import 'package:onboardly/spotlight/spotlight_controller.dart';
import 'package:onboardly/onboarding/onboarding_controller.dart';
import 'package:onboardly/onboarding/onboarding_step.dart';

class ComplexExampleScreen extends StatefulWidget {
  const ComplexExampleScreen({super.key});

  @override
  State<ComplexExampleScreen> createState() => _ComplexExampleScreenState();
}

class _ComplexExampleScreenState extends State<ComplexExampleScreen>
    with TickerProviderStateMixin {
  late final SpotlightService _spotlightService;
  late final OnboardingService _onboardingService;
  late final TabController _tabController;

  final GlobalKey _appBarTitleKey = GlobalKey();
  final GlobalKey _tabBarKey = GlobalKey();
  final GlobalKey _firstItemKey = GlobalKey();
  final GlobalKey _filterChipKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _item25Key = GlobalKey();

  final List<String> _categories = ['All', 'Featured', 'Recent', 'Popular'];
  int _selectedCategory = 0;
  bool _showFavorites = false;

  @override
  void initState() {
    super.initState();
    _spotlightService = SpotlightService();
    _onboardingService = OnboardingService(_spotlightService);
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startComplexOnboarding();
    });
  }

  @override
  void dispose() {
    _onboardingService.dismissSilently();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              key: _appBarTitleKey, 
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Complex Layout Demo',
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade400,
                        Colors.purple.shade400,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.layers,
                      size: 80,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  key: _tabBarKey,
                  controller: _tabController,
                  labelColor: Colors.blue.shade700,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue.shade700,
                  tabs: const [
                    Tab(icon: Icon(Icons.list), text: 'List'),
                    Tab(icon: Icon(Icons.grid_view), text: 'Grid'),
                    Tab(icon: Icon(Icons.dashboard), text: 'Mixed'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListView(),
                  _buildGridView(),
                  _buildMixedView(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: _fabKey,
        onPressed: _startComplexOnboarding,
        icon: const Icon(Icons.school),
        label: const Text('Start Tour'),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_categories.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      key: index == 0 ? _filterChipKey : null,
                      label: Text(_categories[index]),
                      selected: _selectedCategory == index,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = index;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _showFavorites ? Icons.favorite : Icons.favorite_border,
              color: _showFavorites ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _showFavorites = !_showFavorites;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 50,
      itemBuilder: (context, index) {
        return Card(
          key: index == 0
              ? _firstItemKey
              : index == 24
                  ? _item25Key
                  : null,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.primaries[index % Colors.primaries.length],
              child: Text('${index + 1}'),
            ),
            title: Text('Item ${index + 1}'),
            subtitle: Text('This is item number ${index + 1} in a long scrollable list'),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped item ${index + 1}')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 50,
      itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  size: 48,
                  color: Colors.primaries[index % Colors.primaries.length],
                ),
                const SizedBox(height: 8),
                Text(
                  'Grid ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Subtitle',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMixedView() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 20,
      itemBuilder: (context, index) {
        if (index % 3 == 0) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.primaries[index % Colors.primaries.length],
                        Colors.primaries[(index + 1) % Colors.primaries.length],
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.photo, size: 64, color: Colors.white70),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Item ${index + 1}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('This is a featured card with image and description'),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.article),
              title: Text('Regular Item ${index + 1}'),
              subtitle: const Text('Standard list item'),
              trailing: Chip(
                label: Text('${index + 1}'),
                backgroundColor: Colors.blue.shade100,
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _scrollToItem25() async {
    final firstItemCtx = _firstItemKey.currentContext;
    if (firstItemCtx == null) return;

    final scrollable = Scrollable.of(firstItemCtx);
    await scrollable.position.animateTo(
      24 * 80.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _startComplexOnboarding() {
    final steps = [
      OnboardingStep(
        targetKey: _appBarTitleKey,
        description: '🎨 This is a custom collapsible AppBar.\n'
            'Try scrolling to see the effect!',
        position: OnboardingTooltipPosition.below,
      ),
      OnboardingStep(
        targetKey: _tabBarKey,
        description: '📑 These tabs show different view modes.\n'
            'The onboarding works across all tabs!',
        position: OnboardingTooltipPosition.below,
      ),
      OnboardingStep(
        targetKey: _filterChipKey,
        description: '🏷️ Filter chips work with scrollable content.\n'
            'Notice how the spotlight handles sticky headers.',
        position: OnboardingTooltipPosition.below,
      ),
      OnboardingStep(
        targetKey: _firstItemKey,
        description: '📜 This is a long scrollable list with 50 items.\n'
            'The spotlight correctly highlights items in NestedScrollView.',
        position: OnboardingTooltipPosition.below,
      ),
      OnboardingStep(
        targetKey: _item25Key,
        description: '📌 This is item 25, deep in the list!\n'
            'Onboardly scrolled here automatically.',
        position: OnboardingTooltipPosition.below,
      ),
      OnboardingStep(
        targetKey: _fabKey,
        description: '🎓 Tap here anytime to restart the tour!\n'
            'This demonstrates that Onboardly works perfectly with complex layouts.',
        position: OnboardingTooltipPosition.above,
      ),
    ];

    _onboardingService.start(
      context,
      steps,
      onStepChanged: (index) {
        if (index == 4) {
          _scrollToItem25();
        }
      },
      onFinish: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complex example tour completed! 🎉')),
        );
      },
      onSkip: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tour skipped')),
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
