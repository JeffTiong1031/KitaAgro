import 'package:flutter/material.dart';

import 'package:kita_agro/features/Home/Planting/planting_screen.dart';
import 'package:kita_agro/features/Home/community/community_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kita Agro'),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Dashboard Section (Fixed at top)
          SliverToBoxAdapter(
            child: _buildDashboard(),
          ),
          // Community Forum Section (Scrollable)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                'Community Forum',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildForumPost(index),
              childCount: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Container(
      color: Colors.green[50],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Text(
            'Welcome, Farmer!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Dashboard Cards
          Row(
            children: [
              Expanded(
                child: _buildDashboardCard(
                  title: 'Crop Health',
                  value: '92%',
                  icon: Icons.eco,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDashboardCard(
                  title: 'Weather',
                  value: '28°C',
                  icon: Icons.cloud,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDashboardCard(
                  title: 'Soil Moisture',
                  value: '65%',
                  icon: Icons.water_drop,
                  color: Colors.cyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDashboardCard(
                  title: 'Yield Forecast',
                  value: '120 kg',
                  icon: Icons.trending_up,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.add_a_photo,
                label: 'Log Activity',
              ),
              _buildActionButton(
                icon: Icons.bug_report,
                label: 'Report Issue',
              ),
              _buildActionButton(
                icon: Icons.info,
                label: 'Get Advice',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(icon, color: Colors.green[700]),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _buildForumPost(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[300 + (index % 5) * 100],
                  child: Text('F${index + 1}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farmer ${index + 1}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${index + 1} hour${index + 1 == 1 ? '' : 's'} ago',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Post Content
            Text(
              _getForumPostTitle(index),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getForumPostContent(index),
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Engagement Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${10 + index}', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.comment_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${5 + index}', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.share_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${3 + index}', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getForumPostTitle(int index) {
    final titles = [
      'Best time to plant tomatoes?',
      'How to deal with leaf spots?',
      'Irrigation tips for dry season',
      'Pest control methods',
      'Fertilizer recommendations',
      'Harvesting strategies',
      'Soil preparation guide',
      'Market prices discussion',
      'Weather impact on crops',
      'Crop rotation advice',
      'Water conservation tips',
      'Disease prevention',
      'Equipment sharing group',
      'New farming techniques',
      'Community harvest event',
    ];
    return titles[index % titles.length];
  }

  String _getForumPostContent(int index) {
    final contents = [
      'Anyone here growing tomatoes? I\'m looking for advice on the best planting time.',
      'My plants are showing signs of leaf spots. What\'s the best treatment?',
      'With the dry season coming, I need irrigation tips. Please share your experience.',
      'Looking for organic pest control methods. Any suggestions?',
      'What fertilizers work best for your crops? Share your experience.',
      'When and how do you harvest your crops? Tips welcome!',
      'Preparing my soil for the next season. What\'s your method?',
      'Current market prices are interesting. Let\'s discuss commodity prices.',
      'Weather forecast shows heavy rain. How will this affect our crops?',
      'Should I rotate my crops this season? Any good rotation patterns?',
      'Saving water is important. Share your water conservation methods.',
      'Disease outbreaks reported nearby. How can we prevent them?',
      'Looking to share farming equipment with neighbors. Anyone interested?',
      'Heard about new sustainable farming techniques. Let\'s learn together!',
      'Planning a community harvest event. Who would like to join?',
    ];
    return contents[index % contents.length];
  }
}
