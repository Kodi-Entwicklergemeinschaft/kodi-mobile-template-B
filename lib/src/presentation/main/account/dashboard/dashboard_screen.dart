import 'package:flutter/material.dart';
import 'package:your_app_name/src/data/model/model_user.dart';
import 'package:your_app_name/src/data/repository/list_repository.dart';
import 'package:your_app_name/src/data/repository/user_repository.dart';
import 'package:your_app_name/src/presentation/widget/badge_widget.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';
import 'package:your_app_name/src/utils/translate.dart';

class DashboardScreen extends StatefulWidget {
  final bool isEditable;

  const DashboardScreen({required this.isEditable, super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = getDashboardData();
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    final prefs = await Preferences.openBox();
    final userId = prefs.getKeyValue(Preferences.userId, 0);
    final user = await UserRepository.fetchUser(userId);
    
    int pendingRequestsCount = 0;
    
    // Fetch pending requests count if user is admin
    if (user?.roleId == 1) {
      try {
        pendingRequestsCount = await ListRepository.getPendingListingsCount();
      } catch (e) {
        // Handle error silently, keep count as 0
      }
    }
    
    return {
      'user': user,
      'pendingCount': pendingRequestsCount,
    };
  }

  void _refreshDashboard() {
    setState(() {
      _dashboardFuture = getDashboardData();
    });
  }

  Future<void> _navigateToRequests(UserModel? user) async {
    final result = await Navigator.of(context)
        .pushNamed(Routes.allRequests, arguments: {
      "user": user,
      "onStatusChanged": _refreshDashboard,
    });
    
    // Refresh dashboard if changes were made
    if (result == true) {
      _refreshDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Translate.of(context).translate("dashboard")),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!;
              final UserModel? user = data['user'] as UserModel?;
              final int pendingCount = data['pendingCount'] as int;
              
              return Center(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16.0),
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  children: <Widget>[
                    if (user?.roleId == 1)
                      BadgeWidget(
                        count: pendingCount,
                        child: GridItemButton(
                          icon: Icons.group,
                          title: Translate.of(context).translate("requests"),
                          onPressed: () {
                            _navigateToRequests(user);
                          },
                        ),
                      ),
                    if (user?.roleId == 1)
                      GridItemButton(
                        icon: Icons.list,
                        title: Translate.of(context).translate("all_listings"),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(Routes.allListings, arguments: {
                            "user": user,
                          });
                        },
                      ),
                    GridItemButton(
                      icon: Icons.local_offer,
                      title: Translate.of(context).translate("my_listings"),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Routes.myListings,
                          arguments: {'user': user, 'editable': true},
                        );
                      },
                    ),
                    GridItemButton(
                      icon: Icons.group,
                      title: Translate.of(context).translate("my_groups"),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Routes.myGroups,
                        );
                        // Add your action here
                      },
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(Translate.of(context).translate("error_message")),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}

class GridItemButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const GridItemButton(
      {super.key,
      required this.title,
      required this.icon,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3D3D3D),
        padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: 48.0,
            color: Colors.white,
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: const TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
