import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../providers/auth_provider.dart';
import '../../providers/print_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import 'upload_screen.dart';
import '../settings/settings_screen.dart';
import '../../models/print_request_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final print = Provider.of<PrintProvider>(context, listen: false);
    final uid = auth.user?.uid ?? '';
    if (uid.isNotEmpty) {
      print.startListeningToStudent(uid);
    }
  }

  Future<void> _refreshRequests() async {
    setState(() => _isRefreshing = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final print = Provider.of<PrintProvider>(context, listen: false);

    final uid = auth.user?.uid ?? '';
    if (uid.isNotEmpty) {
      print.startListeningToStudent(uid);
    }

    await Future.delayed(const Duration(milliseconds: 700));
    setState(() => _isRefreshing = false);
  }

  @override
  void dispose() {
    Provider.of<PrintProvider>(context, listen: false).stopListening();
    super.dispose();
  }

  String _displayNameFromAuth(AuthProvider auth) {
    // Prefer email's local-part, else name, else 'Student'
    final email = auth.user?.email ?? '';
    if (email.isNotEmpty) {
      final local = email.split('@').first;
      // take up to first 8 chars for compactness
      return local.length <= 8 ? local : local.substring(0, 8);
    }
    final name = auth.user?.name ?? '';
    if (name.isNotEmpty) {
      return name.split(' ').first;
    }
    return 'Student';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final print = Provider.of<PrintProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;

    final displayName = _displayNameFromAuth(auth);
    final studentId = auth.user?.studentId ?? '';

    final gradientColors = isDark
        ? [const Color(0xFF2A2A2A), const Color(0xFF181818)]
        : [const Color(0xFF5C6BC0), const Color(0xFF3F51B5)];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FB),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.transparent,
          elevation: 0,
          title: Text(
            AppConstants.appName,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.indigo,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.settings_outlined,
                  color: isDark ? Colors.white70 : Colors.indigo),
              tooltip: "Settings",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                color: isDark ? Colors.white70 : Colors.indigo,
              ),
              tooltip: "Toggle Theme",
              onPressed: () => theme.toggleTheme(),
            ),
            IconButton(
              icon: Icon(Icons.logout, color: isDark ? Colors.white70 : Colors.indigo),
              tooltip: "Logout",
              onPressed: () async {
                final should = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    final isDarkLocal = Provider.of<ThemeProvider>(context).isDarkMode;
                    return AlertDialog(
                      backgroundColor: isDarkLocal ? const Color(0xFF1E1E1E) : Colors.white,
                      title: const Text('Confirm Logout', style: TextStyle(fontFamily: 'Poppins')),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkLocal ? Colors.tealAccent[700] : Colors.indigo,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    );
                  },
                );
                if (should == true) {
                  await auth.logout();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: isDark ? Colors.tealAccent : Colors.indigo,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'History'),
            ],
          ),
        ),

        floatingActionButton: Hero(
          tag: 'uploadHero',
          child: FloatingActionButton.extended(
            icon: const Icon(Icons.upload_file),
            label: const Text("Upload"),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadScreen()),
              );
              await _refreshRequests();
            },
          ),
        ),

        body: TabBarView(
          children: [
            // --- Active Tab: pending / ready
            RefreshIndicator(
              onRefresh: _refreshRequests,
              color: isDark ? Colors.tealAccent : Colors.indigo,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Welcome back,", style: TextStyle(color: Colors.white70, fontFamily: 'Poppins', fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(displayName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 8),
                            Text('Student ID: $studentId', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text("Your Print Requests", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 10),

                      if (print.isLoading || _isRefreshing)
                        const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: CircularProgressIndicator()))
                      else
                        Builder(builder: (_) {
                          final activeRequests = print.printRequests.where((r) => r.status == 'pending' || r.status == 'ready').toList();
                          if (activeRequests.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 160, child: Lottie.asset('assets/lottie/empty.json', repeat: true)),
                                    const SizedBox(height: 20),
                                    Text('No active print requests', style: TextStyle(fontFamily: 'Poppins', color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text('Tap Upload to add a new document', style: TextStyle(fontFamily: 'Poppins', color: isDark ? Colors.white54 : Colors.grey[600])),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: List.generate(activeRequests.length, (i) {
                              final req = activeRequests[i];
                              return _PrintCard(request: req, isDark: isDark);
                            }),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),

            // --- History Tab: collected (or completed) requests
            RefreshIndicator(
              onRefresh: _refreshRequests,
              color: isDark ? Colors.tealAccent : Colors.indigo,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Text("History", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 10),
                      if (print.isLoading || _isRefreshing)
                        const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: CircularProgressIndicator()))
                      else
                        Builder(builder: (_) {
                          final historyRequests = print.printRequests.where((r) => r.status == 'collected' || r.status == 'cancelled').toList();
                          if (historyRequests.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 140, child: Lottie.asset('assets/lottie/empty.json', repeat: true)),
                                    const SizedBox(height: 16),
                                    Text('No history yet', style: TextStyle(fontFamily: 'Poppins', color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: List.generate(historyRequests.length, (i) {
                              final req = historyRequests[i];
                              return _PrintCard(request: req, isDark: isDark);
                            }),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrintCard extends StatelessWidget {
  final PrintRequest request;
  final bool isDark;
  const _PrintCard({required this.request, required this.isDark});

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orangeAccent;
      case 'ready':
        return Colors.green;
      case 'collected':
        return Colors.blueAccent;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(request.status);
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(request.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: isDark ? Colors.black45 : Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        leading: Icon(Icons.picture_as_pdf, color: color, size: 30),
        title: Text(request.fileName, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('Pages: ${request.totalPages} | Copies: ${request.preferences.copies}\n$formattedDate', style: TextStyle(fontFamily: 'Poppins', color: isDark ? Colors.white70 : Colors.black54, height: 1.3)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
          child: Text(request.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ),
    );
  }
}
