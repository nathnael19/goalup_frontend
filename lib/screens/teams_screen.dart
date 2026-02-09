import 'package:flutter/material.dart';
import 'team_detail_screen.dart';

/// Screen displaying a directory of all teams
class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _teams = [
    {
      'name': 'Software Engineering',
      'tournament': 'Batch Cup 2024',
      'members': 14,
      'color': Colors.blue,
    },
    {
      'name': 'Computer Science',
      'tournament': 'Batch Cup 2024',
      'members': 12,
      'color': Colors.indigo,
    },
    {
      'name': 'Information Systems',
      'tournament': 'Batch Cup 2024',
      'members': 15,
      'color': Colors.teal,
    },
    {
      'name': 'Electrical Engineering',
      'tournament': '4th Year League',
      'members': 14,
      'color': Colors.orange,
    },
    {
      'name': 'Mechanical Engineering',
      'tournament': '4th Year League',
      'members': 16,
      'color': Colors.red,
    },
    {
      'name': 'Civil Engineering',
      'tournament': '4th Year League',
      'members': 15,
      'color': Colors.brown,
    },
    {
      'name': 'Architecture',
      'tournament': '4th Year League',
      'members': 12,
      'color': Colors.purple,
    },
    {
      'name': 'Chemical Engineering',
      'tournament': 'Batch Cup 2024',
      'members': 14,
      'color': Colors.green,
    },
    {
      'name': 'Bio Engineering',
      'tournament': 'Batch Cup 2024',
      'members': 13,
      'color': Colors.lightGreen,
    },
    {
      'name': 'Mining Engineering',
      'tournament': 'Batch Cup 2024',
      'members': 11,
      'color': Colors.grey,
    },
    {
      'name': 'Urban Planning',
      'tournament': 'Half Life-Cup',
      'members': 12,
      'color': Colors.cyan,
    },
    {
      'name': 'Geology',
      'tournament': 'Half Life-Cup',
      'members': 14,
      'color': Colors.deepOrange,
    },
  ];

  List<Map<String, dynamic>> get _filteredTeams {
    if (_searchQuery.isEmpty) return _teams;
    return _teams.where((team) {
      return team['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          team['tournament'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search teams or tournaments...',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.primary,
                size: 20,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        // Teams Grid
        Expanded(
          child: _filteredTeams.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filteredTeams.length,
                  itemBuilder: (context, index) {
                    final team = _filteredTeams[index];
                    return _buildTeamCard(team);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> team) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TeamDetailScreen(team: team)),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: (team['color'] as Color).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  team['name'][0],
                  style: TextStyle(
                    color: team['color'],
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              team['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              (team['tournament'] as String).toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${team['members']} PLAYERS',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text(
            'NO TEAMS FOUND',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
