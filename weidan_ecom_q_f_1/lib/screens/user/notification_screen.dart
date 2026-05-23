import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // ── Cached docs — only updated when stream emits, never reset by rebuild ───
  List<QueryDocumentSnapshot> _docs = [];
  bool _loading = true;

  // IDs dismissed this session — filtered before rendering
  final Set<String> _dismissed = {};

  // IDs marked as read this session
  final Set<String> _read = {};

  // Stream subscription — cancelled in dispose
  StreamSubscription<QuerySnapshot>? _sub;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    _sub = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      setState(() {
        // Merge incoming docs — keep dismissed ones out, preserve existing order
        final incoming = snap.docs;
        // Add any new doc IDs not yet seen; update existing ones in place
        final existingIds = _docs.map((d) => d.id).toSet();
        final newDocs = incoming.where((d) => !existingIds.contains(d.id)).toList();
        // Update existing docs with fresh data
        final updatedDocs = _docs.map((old) {
          final updated = incoming.firstWhere(
            (d) => d.id == old.id,
            orElse: () => old as QueryDocumentSnapshot<Map<String, dynamic>>,
          );
          return updated;
        }).toList();
        // Append new docs at the end (they are newer due to descending order on Firestore)
        // Actually prepend since Firestore returns descending
        _docs = [...newDocs, ...updatedDocs];
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ── Relative timestamp ──────────────────────────────────────────────────────
  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24) return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ── Style resolver ──────────────────────────────────────────────────────────
  _NotifStyle _styleFor(String title) {
    final t = title.toLowerCase();
    if (t.contains('order') && t.contains('place')) return const _NotifStyle(icon: Icons.shopping_bag_rounded, iconBg: Color(0xFFE8F5E9), iconColor: Color(0xFF2E7D32), accentColor: Color(0xFF2E7D32));
    if (t.contains('ship') || t.contains('dispatch')) return const _NotifStyle(icon: Icons.local_shipping_rounded, iconBg: Color(0xFFE3F2FD), iconColor: Color(0xFF1565C0), accentColor: Color(0xFF1565C0));
    if (t.contains('deliver')) return const _NotifStyle(icon: Icons.check_circle_rounded, iconBg: Color(0xFFE8F5E9), iconColor: Color(0xFF2E7D32), accentColor: Color(0xFF2E7D32));
    if (t.contains('cancel')) return const _NotifStyle(icon: Icons.cancel_rounded, iconBg: Color(0xFFFFEBEE), iconColor: Color(0xFFE53935), accentColor: Color(0xFFE53935));
    if (t.contains('offer') || t.contains('deal') || t.contains('discount')) return const _NotifStyle(icon: Icons.local_offer_rounded, iconBg: Color(0xFFFFF3E0), iconColor: Color(0xFFE65100), accentColor: Color(0xFFE65100));
    if (t.contains('payment') || t.contains('paid')) return const _NotifStyle(icon: Icons.payment_rounded, iconBg: Color(0xFFEDE7F6), iconColor: Color(0xFF6A1B9A), accentColor: Color(0xFF6A1B9A));
    if (t.contains('return') || t.contains('refund')) return const _NotifStyle(icon: Icons.replay_rounded, iconBg: Color(0xFFFFF3E0), iconColor: Color(0xFFE65100), accentColor: Color(0xFFE65100));
    return const _NotifStyle(icon: Icons.notifications_rounded, iconBg: Color(0xFFF5F5F5), iconColor: Color(0xFF555555), accentColor: Color(0xFF555555));
  }

  String _chipLabel(String title) {
    final t = title.toLowerCase();
    if (t.contains('order') && t.contains('place')) return 'Order Placed';
    if (t.contains('ship') || t.contains('dispatch')) return 'Shipped';
    if (t.contains('deliver')) return 'Delivered';
    if (t.contains('cancel')) return 'Cancelled';
    if (t.contains('offer') || t.contains('deal')) return 'Offer';
    if (t.contains('payment') || t.contains('paid')) return 'Payment';
    if (t.contains('return') || t.contains('refund')) return 'Return';
    return 'New';
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Visible docs = cached list minus locally dismissed ones
    final visibleDocs = _docs.where((d) => !_dismissed.contains(d.id)).toList();
    final unreadCount = visibleDocs.where((d) => !_read.contains(d.id)).length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        appBar: _buildAppBar(user, visibleDocs),
        body: user == null
            ? _buildLoginPrompt()
            : _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF111111), strokeWidth: 2.5))
                : visibleDocs.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          if (unreadCount > 0)
                            _buildUnreadBanner(unreadCount, visibleDocs),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                              itemCount: visibleDocs.length,
                              itemBuilder: (_, i) => _buildCard(
                                visibleDocs[i],
                                _read.contains(visibleDocs[i].id),
                              ),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(User? user, List<QueryDocumentSnapshot> visibleDocs) => AppBar(
        backgroundColor: const Color(0xFFF5F6F8),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF111111)),
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0D0D0D), fontFamily: 'SF Pro Display', letterSpacing: -0.3),
        ),
        actions: [
          if (user != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Mark all visible docs as read directly from cached list — no Firestore call needed
                setState(() {
                  for (final d in visibleDocs) _read.add(d.id);
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: const Text('Mark all read', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF111111), fontFamily: 'SF Pro Display')),
              ),
            ),
        ],
      );

  // ── Unread banner ───────────────────────────────────────────────────────────
  Widget _buildUnreadBanner(int count, List<QueryDocumentSnapshot> docs) => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
              child: Center(child: Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'SF Pro Display'))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text('$count unread notification${count == 1 ? '' : 's'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'SF Pro Display'))),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() { for (final d in docs) _read.add(d.id); });
              },
              child: const Text('Mark all read', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70, fontFamily: 'SF Pro Display')),
            ),
          ],
        ),
      );

  // ── Notification card ───────────────────────────────────────────────────────
  Widget _buildCard(QueryDocumentSnapshot doc, bool isRead) {
    final data = doc.data() as Map<String, dynamic>;
    final title = (data['title'] ?? 'Notification') as String;
    final message = (data['message'] ?? '') as String;
    final ts = data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : DateTime.now();
    final style = _styleFor(title);
    final imageUrls = (data['imageUrls'] as List<dynamic>? ?? []).map((e) => e as String).toList();
    final hasImages = imageUrls.isNotEmpty;

    return Dismissible(
      key: ValueKey(doc.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (_) {
        HapticFeedback.heavyImpact();
        // ── THE REAL FIX: remove from _docs directly ──────────────────────
        // This means even when Firestore stream re-emits, the doc is gone
        // from our local cache and will NOT reappear unless undo is tapped.
        final removedDoc = doc;
        setState(() {
          _docs.removeWhere((d) => d.id == doc.id);
          _dismissed.add(doc.id);
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification removed'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  // Re-insert at original position
                  _dismissed.remove(removedDoc.id);
                  if (!_docs.any((d) => d.id == removedDoc.id)) {
                    _docs.insert(0, removedDoc);
                  }
                });
              },
            ),
          ),
        );
      },
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFCDD2), Color(0xFFEF5350)], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'SF Pro Display', letterSpacing: 0.3)),
          ],
        ),
      ),
      background: Container(color: Colors.transparent),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          if (!isRead) setState(() => _read.add(doc.id));
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => _buildActionSheet(docId: doc.id, isRead: isRead, title: title),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isRead ? const Color(0xFFFAFAFA) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isRead ? Colors.transparent : style.accentColor.withOpacity(0.22),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isRead ? 0.03 : 0.07),
                blurRadius: isRead ? 6 : 16,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    hasImages ? _thumbnailStack(imageUrls, style, isRead) : _iconBadge(style, isRead),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w800,
                                    color: isRead ? const Color(0xFFAAAAAA) : const Color(0xFF0D0D0D),
                                    fontFamily: 'SF Pro Display',
                                    letterSpacing: -0.1,
                                    height: 1.3,
                                  ),
                                  child: Text(title),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isRead ? const Color(0xFFCCCCCC) : style.accentColor,
                                  fontFamily: 'SF Pro Display',
                                  fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                                ),
                                child: Text(_relativeTime(ts)),
                              ),
                            ],
                          ),
                          if (message.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 12,
                                color: isRead ? const Color(0xFFCCCCCC) : const Color(0xFF777777),
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                              ),
                              child: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                          const SizedBox(height: 9),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: ScaleTransition(scale: anim, child: child)),
                            child: Container(
                              key: ValueKey(isRead),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isRead ? const Color(0xFFF0F0F0) : style.iconBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(isRead ? Icons.done_all_rounded : style.icon, size: 10, color: isRead ? const Color(0xFFBBBBBB) : style.iconColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    isRead ? 'Read' : _chipLabel(title),
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isRead ? const Color(0xFFBBBBBB) : style.iconColor, fontFamily: 'SF Pro Display'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (hasImages && imageUrls.length > 1) ...[
                const SizedBox(height: 12),
                _thumbnailStrip(imageUrls, isRead),
              ],
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  // ── Icon badge ──────────────────────────────────────────────────────────────
  Widget _iconBadge(_NotifStyle style, bool isRead) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: isRead ? const Color(0xFFF0F0F0) : style.iconBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(style.icon, size: 22, color: isRead ? const Color(0xFFBBBBBB) : style.iconColor),
      );

  // ── Thumbnail stack (single image) ─────────────────────────────────────────
  Widget _thumbnailStack(List<String> urls, _NotifStyle style, bool isRead) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          urls.first,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _iconBadge(style, isRead),
        ),
      );

  // ── Thumbnail strip (multiple images) ──────────────────────────────────────
  Widget _thumbnailStrip(List<String> urls, bool isRead) => SizedBox(
        height: 64,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: urls.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              urls[i],
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );

  // ── Action sheet ────────────────────────────────────────────────────────────
  Widget _buildActionSheet({required String docId, required bool isRead, required String title}) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0D0D0D), fontFamily: 'SF Pro Display'), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            if (!isRead)
              _sheetAction(
                icon: Icons.done_all_rounded,
                label: 'Mark as read',
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _read.add(docId));
                },
              ),
            _sheetAction(
              icon: Icons.delete_outline_rounded,
              label: 'Remove',
              color: const Color(0xFFE53935),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _docs.removeWhere((d) => d.id == docId);
                  _dismissed.add(docId);
                });
              },
            ),
          ],
        ),
      );

  Widget _sheetAction({required IconData icon, required String label, Color? color, required VoidCallback onTap}) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: const Color(0xFFF5F6F8), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color ?? const Color(0xFF111111)),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color ?? const Color(0xFF111111), fontFamily: 'SF Pro Display')),
            ],
          ),
        ),
      );

  // ── Empty state ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: const Color(0xFFF0F0F0), shape: BoxShape.circle),
              child: const Icon(Icons.notifications_off_rounded, size: 36, color: Color(0xFFBBBBBB)),
            ),
            const SizedBox(height: 16),
            const Text('No notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF333333), fontFamily: 'SF Pro Display')),
            const SizedBox(height: 6),
            const Text("You're all caught up!", style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA), fontFamily: 'SF Pro Display')),
          ],
        ),
      );

  // ── Login prompt ────────────────────────────────────────────────────────────
  Widget _buildLoginPrompt() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 48, color: Color(0xFFBBBBBB)),
            const SizedBox(height: 16),
            const Text('Please login to view notifications', style: TextStyle(fontSize: 14, color: Color(0xFFAAAAAA), fontFamily: 'SF Pro Display')),
          ],
        ),
      );
}

// ── Style data class ──────────────────────────────────────────────────────────
class _NotifStyle {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color accentColor;

  const _NotifStyle({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.accentColor,
  });
}
