import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:docsease/edit_profile.dart';
import 'package:docsease/navigator_transition.dart';
import 'package:docsease/info_model.dart';
import 'package:docsease/information.dart';
import 'package:docsease/firebase_services.dart';
import 'package:docsease/app_localizations.dart';
import 'package:docsease/settings_provider.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  final Function(String) onTitleChange;

  const Profile({super.key, required this.onTitleChange});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Track which service is currently loading
  String? _loadingServiceId;

  // Persist streams so they don't reload on setState
  Stream<DocumentSnapshot>? _userDataStream;
  Stream<QuerySnapshot>? _serviceHistoryStream;

  @override
  void initState() {
    super.initState();

    // Initialize the streams exactly ONCE when the profile screen loads
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userDataStream = FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();

      _serviceHistoryStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('service_history')
          .orderBy('last_updated', descending: true)
          .snapshots();
    }
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  void _navigateToService(BuildContext context, String serviceId) async {
    // Prevent multiple taps while it's already loading
    if (serviceId.isEmpty || _loadingServiceId == serviceId) return;

    // Trigger the inline UI spinner
    setState(() {
      _loadingServiceId = serviceId;
    });

    try {
      final getService = FirebaseServices();

      // Using the FAST fetcher instead of downloading everything!
      ServiceDetail? foundService = await getService.getServiceById(serviceId);

      if (foundService != null && context.mounted) {
        widget.onTitleChange('Information');
        Navigator.push(
          context,
          SlideRoute(page: InformationScreen(detail: foundService)),
        ).then((_) => widget.onTitleChange('Profile'));
      } else if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Service details not found.')));
      }
    } catch (e) {
      print("Error fetching service details: $e");
    } finally {
      // Stop the spinner whether it succeeded or failed
      if (mounted) {
        setState(() {
          _loadingServiceId = null;
        });
      }
    }
  }

  String _tr(String key) {
    final lang = Provider.of<SettingsProvider>(context, listen: false).language;
    return AppLocalizations.translate(key, lang);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider so UI rebuilds on language change
    Provider.of<SettingsProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _userDataStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _SkeletonProfileHeader();
                    }

                    String currentUsername = 'Loading...';
                    String currentProfile = 'assets/default_profile.png';

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      currentUsername = data['username'] ?? 'Guest Account';
                      currentProfile = data['profile_img'] ?? 'assets/default_profile.png';
                    }

                    bool hasDefaultProfile = currentProfile == 'assets/default_profile.png';

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: ClipOval(
                                child: hasDefaultProfile
                                    ? Image.asset(
                                        currentProfile,
                                        width: 95,
                                        height: 95,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        currentProfile,
                                        width: 95,
                                        height: 95,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  widget.onTitleChange('Edit Profile');
                                  Navigator.push(
                                    context,
                                    SlideRoute(page: const EditProfile()),
                                  ).then((_) {
                                    widget.onTitleChange('Profile');
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/edit_icon.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            widget.onTitleChange('Edit Profile');
                            Navigator.push(context, SlideRoute(page: const EditProfile())).then((
                              _,
                            ) {
                              widget.onTitleChange('Profile');
                            });
                          },
                          child: Text(
                            currentUsername,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _tr('Citizen User'),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          // Service History
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 50,
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.primary,
                ),
                // Replaced SingleChildScrollView with Padding
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.tertiary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Allows the card to shrink-wrap its contents
                      children: [
                        Text(
                          _tr('Service History'),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                        const Divider(height: 25, thickness: 0.8, indent: 90, endIndent: 90),
                        const SizedBox(height: 10),

                        // Wrapped the stream builder in a Flexible so the list scrolls INSIDE the card
                        Flexible(child: _buildServiceHistoryStream()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHistoryStream() {
    if (_serviceHistoryStream == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _serviceHistoryStream, // Use persisted stream
      builder: (context, snapshot) {
        // Render Skeleton Loading UI when waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            shrinkWrap: true,
            // Restored scrolling capabilities to the inner lists
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: 4,
            separatorBuilder: (context, index) => const SizedBox(height: 35),
            itemBuilder: (context, index) => const _SkeletonHistoryItem(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20, bottom: 30),
            child: Text(
              _tr('No service history yet.\nStart a service to track your progress!'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          // Restored scrolling capabilities to the inner lists
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const Divider(height: 35, thickness: 0.8),
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

            Timestamp? ts = data['last_updated'] as Timestamp?;
            String dateStr = ts != null ? _formatDate(ts.toDate()) : "Unknown date";

            String serviceId = data['service_id'] ?? '';
            String serviceName = data['service_name'] ?? 'Unknown Service';
            double progress = (data['progress'] ?? 0.0).toDouble();
            String status = data['status'] ?? 'In Progress';

            bool isCompleted = progress >= 1.0;
            Color statusColor = isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFFF7043);

            return _buildServiceItem(
              iconData: UIHelper.getIconForService(serviceName),
              title: serviceName,
              status: status,
              date: dateStr,
              statusColor: statusColor,
              progress: progress,
              showProgress: !isCompleted,
              iconBg: UIHelper.getBgColorForService(serviceName),
              isLoading: _loadingServiceId == serviceId,
              onTap: () => _navigateToService(context, serviceId),
            );
          },
        );
      },
    );
  }

  Widget _buildServiceItem({
    required IconData iconData,
    required String title,
    required String status,
    required String date,
    required Color statusColor,
    double progress = 0.0,
    bool showProgress = true,
    required Color iconBg,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                  child: Icon(iconData, size: 24, color: Colors.black),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            status,
                            style: GoogleFonts.inter(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "• $date",
                            style: GoogleFonts.inter(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(right: 6.0, bottom: 4.0),
                        child: SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    else
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        size: 28,
                      ),

                    if (showProgress)
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (showProgress) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- SKELETON WIDGETS FOR PROFILE --- //

class _ShimmerEffect extends StatefulWidget {
  final Widget child;
  const _ShimmerEffect({required this.child});

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 0.8).animate(_controller),
      child: widget.child,
    );
  }
}

class _SkeletonHistoryItem extends StatelessWidget {
  const _SkeletonHistoryItem();

  @override
  Widget build(BuildContext context) {
    return _ShimmerEffect(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: double.infinity, height: 16, color: Colors.grey.shade300),
                      const SizedBox(height: 6),
                      Container(width: 120, height: 12, color: Colors.grey.shade300),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Container(width: 20, height: 20, color: Colors.grey.shade300),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonProfileHeader extends StatelessWidget {
  const _SkeletonProfileHeader();

  @override
  Widget build(BuildContext context) {
    return _ShimmerEffect(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Fake Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 20),
          // Fake Username
          Container(
            width: 160,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 8),
          // Fake Subtitle
          Container(
            width: 90,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
