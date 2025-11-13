import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notesheet_provider.dart';
import '../widgets/notesheet_card.dart';
import '../widgets/stats_card.dart';
import 'create_notesheet_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final notesheetProvider = Provider.of<NotesheetProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await notesheetProvider.loadUserNotesheets();

    if (authProvider.user?.isReviewer == true) {
      await notesheetProvider.loadNotesheetsForReview();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              } else if (value == 'logout') {
                authProvider.signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildMyNotesheets(),
          if (user.isReviewer) _buildReviewNotesheets(),
          if (user.isAdmin) _buildAdminPanel(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(user),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateNotesheetScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'My Notesheets';
      case 1:
        return 'Review Notesheets';
      case 2:
        return 'Admin Panel';
      default:
        return 'Notesheet Tracker';
    }
  }

  Widget _buildMyNotesheets() {
    return Consumer<NotesheetProvider>(
      builder: (context, notesheetProvider, child) {
        if (notesheetProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notesheetProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Error: ${notesheetProvider.error}',
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final notesheets = notesheetProvider.notesheets;

        return RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'Total',
                        value: '${notesheets.length}',
                        icon: Icons.description,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatsCard(
                        title: 'Approved',
                        value:
                            '${notesheets.where((n) => n.status.name == 'approved').length}',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatsCard(
                        title: 'Pending',
                        value:
                            '${notesheets.where((n) => n.status.name == 'underReview' || n.status.name == 'submitted').length}',
                        icon: Icons.pending,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Recent Notesheets',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Notesheets List
                if (notesheets.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.description,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notesheets yet',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first notesheet to get started',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notesheets.length,
                    itemBuilder: (context, index) {
                      return NotesheetCard(
                        notesheet: notesheets[index],
                        onTap: () {
                          // Navigate to notesheet detail
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewNotesheets() {
    return Consumer<NotesheetProvider>(
      builder: (context, notesheetProvider, child) {
        if (notesheetProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviewNotesheets = notesheetProvider.reviewNotesheets;

        return RefreshIndicator(
          onRefresh: () async {
            await notesheetProvider.loadNotesheetsForReview();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notesheets for Review',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                if (reviewNotesheets.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.rate_review,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notesheets to review',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviewNotesheets.length,
                    itemBuilder: (context, index) {
                      return NotesheetCard(
                        notesheet: reviewNotesheets[index],
                        showReviewActions: true,
                        onTap: () {
                          // Navigate to review screen
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Panel',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
              subtitle: const Text('Manage users and roles'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to user management
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.description),
              title: const Text('All Notesheets'),
              subtitle: const Text('View and manage all notesheets'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to all notesheets
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              subtitle: const Text('View system analytics'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to analytics
              },
            ),
          ),
        ],
      ),
    );
  }
}
