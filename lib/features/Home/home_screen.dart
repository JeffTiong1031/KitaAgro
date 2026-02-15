import 'package:flutter/material.dart';

import 'package:kita_agro/features/Home/Planting/planting_screen.dart';
import 'package:kita_agro/features/Home/community/community_screen.dart';
import 'package:kita_agro/features/Home/Dictionary/dictionary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  final PageController _gardenCarouselController = PageController(viewportFraction: 0.85);
  int _currentGardenPage = 0;

  final List<Map<String, dynamic>> _myGardenPlants = [
    {
      'name': 'Tomato',
      'scientificName': 'Solanum lycopersicum',
      'daysPlanted': 45,
      'totalDays': 60,
      'icon': Icons.circle,
      'color': Color(0xFFE53935),
    },
    {
      'name': 'Chili',
      'scientificName': 'Capsicum annuum',
      'daysPlanted': 30,
      'totalDays': 75,
      'icon': Icons.local_fire_department,
      'color': Color(0xFFD32F2F),
    },
    {
      'name': 'Pandan',
      'scientificName': 'Pandanus amaryllifolius',
      'daysPlanted': 120,
      'totalDays': 180,
      'icon': Icons.grass,
      'color': Color(0xFF388E3C),
    },
  ];

  @override
  void dispose() {
    _gardenCarouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: null,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search crops, pests...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.notifications, color: Colors.grey[700], size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Dashboard Section
          SliverToBoxAdapter(
            child: _buildDashboard(),
          ),
          // My Garden Carousel
          SliverToBoxAdapter(
            child: _buildMyGardenCarousel(),
          ),
          // Action Buttons Section
          SliverToBoxAdapter(
            child: _buildActionButtons(),
          ),
          // Tab Navigation
          SliverToBoxAdapter(
            child: _buildTabNavigation(),
          ),
          // Community Posts
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCommunityPost(index),
              childCount: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Growth Stage Card with Weather and Reminder
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Growth Stage Circle
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer circle
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 8,
                                ),
                              ),
                            ),
                            // Progress circle
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: 0.75,
                                strokeWidth: 8,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[400]!),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                            // Center circle with plant icon
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: const Icon(Icons.eco, color: Colors.white, size: 32),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '75%',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[400],
                        ),
                      ),
                      Text(
                        'Growth Stage',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Weather and Reminder
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Weather Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Icon(Icons.wb_sunny, color: Colors.amber, size: 20),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '24°C',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Sunny',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Reminder Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Reminder',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Icon(Icons.water_drop, color: Colors.red, size: 20),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Watering',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            label: 'My Journey',
            color: Colors.teal[100]!,
            icon: Icons.favorite,
            iconColor: Colors.teal,
          ),
          _buildActionButton(
            label: 'Dictionary',
            color: Colors.orange[100]!,
            icon: Icons.description,
            iconColor: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DictionaryScreen()),
              );
            },
          ),
          _buildActionButton(
            label: 'AI Assistant',
            color: Colors.purple[100]!,
            icon: Icons.smart_toy,
            iconColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    final tabs = ['Community', 'Recommend', 'Market', 'Q&A'];
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
                        color: _selectedTabIndex == index ? Colors.teal : Colors.grey,
                      ),
                    ),
                  ),
                  if (_selectedTabIndex == index)
                    Container(
                      height: 3,
                      color: Colors.teal,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityPost(int index) {
    final users = [
      {'name': 'David Miller', 'role': 'Urban Gardener', 'time': '2h ago'},
      {'name': 'Sarah Jenkins', 'role': 'Expert Farmer', 'time': '5h ago'},
      {'name': 'John Smith', 'role': 'Crop Specialist', 'time': '3h ago'},
      {'name': 'Emma Wilson', 'role': 'Soil Expert', 'time': '1h ago'},
      {'name': 'Robert Brown', 'role': 'Farmer', 'time': '4h ago'},
    ];

    final posts = [
      {
        'title': 'First harvest of my hydroponic lettuce!',
        'content': 'Look at these vibrant colors 🌱 #UrbanFarming #Hydroponics',
        'hasImage': true,
        'likes': 245,
        'comments': 42,
        'shares': 12,
      },
      {
        'title': 'Tips for pest control this season',
        'content': 'Tips for pest control this season without harmful chemicals. Check out my new guide!',
        'hasImage': false,
        'likes': 89,
        'comments': 15,
        'shares': 8,
      },
      {
        'title': 'New greenhouse setup completed!',
        'content': 'Finally completed my greenhouse. Super excited to start growing vegetables!',
        'hasImage': true,
        'likes': 156,
        'comments': 28,
        'shares': 10,
      },
      {
        'title': 'Soil preparation tips',
        'content': 'Best practices for preparing your soil before planting season starts.',
        'hasImage': false,
        'likes': 120,
        'comments': 22,
        'shares': 9,
      },
      {
        'title': 'Composting guide for farmers',
        'content': 'Learn how to make your own compost at home and improve soil quality.',
        'hasImage': true,
        'likes': 198,
        'comments': 35,
        'shares': 14,
      },
    ];

    final user = users[index % users.length];
    final post = posts[index % posts.length];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.teal[300],
                      radius: 24,
                      child: Text(
                        user['name']![0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name']!,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${user['role']} • ${user['time']}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
              ],
            ),
            const SizedBox(height: 12),

            // Post Title
            Text(
              post['title']! as String,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Post Content
            Text(
              post['content']! as String,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),

            // Post Image (if available)
            if (post['hasImage'] == true)
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage('assets/images/ArgiPic.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            if (post['hasImage'] == true) const SizedBox(height: 12),

            // Engagement Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEngagementButton(
                  icon: Icons.favorite_outline,
                  count: post['likes']! as int,
                ),
                _buildEngagementButton(
                  icon: Icons.comment_outlined,
                  count: post['comments']! as int,
                ),
                _buildEngagementButton(
                  icon: Icons.share_outlined,
                  count: post['shares']! as int,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyGardenCarousel() {
    if (_myGardenPlants.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.yard_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No plants in your garden yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add plants to start tracking their growth',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Garden',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${_currentGardenPage + 1}/${_myGardenPlants.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _gardenCarouselController,
            onPageChanged: (index) {
              setState(() {
                _currentGardenPage = index;
              });
            },
            itemCount: _myGardenPlants.length,
            itemBuilder: (context, index) {
              final plant = _myGardenPlants[index];
              final progress = plant['daysPlanted'] / plant['totalDays'];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      plant['color'].withOpacity(0.8),
                      plant['color'],
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: plant['color'].withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        plant['icon'],
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                plant['icon'],
                                color: Colors.white,
                                size: 32,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Day ${plant['daysPlanted']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            plant['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plant['scientificName'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Growth Progress',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${plant['totalDays'] - plant['daysPlanted']} days to harvest',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _myGardenPlants.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentGardenPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentGardenPage == index
                        ? Colors.green[700]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEngagementButton({
    required IconData icon,
    required int count,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
