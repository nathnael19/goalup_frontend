import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../cubits/teams_cubit.dart';
import '../models/team.dart' as model;
import '../services/api_service.dart';
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

  List<model.Team> _getFilteredTeams(List<model.Team> allTeams) {
    if (_searchQuery.isEmpty) return allTeams;
    return allTeams.where((team) {
      return team.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _handleRefresh() async {
    await context.read<TeamsCubit>().fetchTeams();
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
          child: BlocBuilder<TeamsCubit, TeamsState>(
            builder: (context, state) {
              if (state is TeamsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TeamsLoaded) {
                final filteredTeams = _getFilteredTeams(state.teams);

                if (filteredTeams.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: _buildEmptyState(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filteredTeams.length,
                    itemBuilder: (context, index) {
                      final team = filteredTeams[index];
                      return _buildTeamCard(team);
                    },
                  ),
                );
              } else if (state is TeamsError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard(model.Team team) {
    final colorScheme = Theme.of(context).colorScheme;
    final logoUrl = ApiService.getImageFullUrl(team.logoUrl);

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
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: logoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: logoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, error, stackTrace) =>
                            _buildLogoPlaceholder(team, colorScheme),
                      )
                    : _buildLogoPlaceholder(team, colorScheme),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              team.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              (team.tournament?.name ?? 'TOURNAMENT').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder(model.Team team, ColorScheme colorScheme) {
    return Center(
      child: Text(
        team.name.isNotEmpty ? team.name[0] : '?',
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 24,
          fontWeight: FontWeight.w900,
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
