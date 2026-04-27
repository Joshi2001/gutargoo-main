import 'dart:ui';
import 'package:flutter/material.dart';

void showComingSoonPlansPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (context) => const _PlansDialog(),
  );
}

class _PlansDialog extends StatelessWidget {
  const _PlansDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A0A0A), Color(0xFF1A0505)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB91C1C).withOpacity(0.25),
              blurRadius: 40,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPlanCard(
              title: "Monthly",
              price: "₹199",
              period: "per month",
              isFeatured: false,
              saving: null,
            ),
            const SizedBox(height: 12),
            _buildPlanCard(
              title: "Yearly",
              price: "₹999",
              period: "per year",
              isFeatured: true,
              saving: "Save 58%",
            ),
            const SizedBox(height: 20),
            _buildFeatureList(),
            const SizedBox(height: 20),
            _buildCTAButton(context),
            const SizedBox(height: 12),
            Text(
              "We'll notify you the moment it's live ✨",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB91C1C).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFB91C1C).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: const Color(0xFFB91C1C).withOpacity(0.4)),
          ),
          child: const Text(
            "✦  COMING SOON  ✦",
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: Color(0xFFF87171),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Unlock Premium",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Choose a plan that works for you",
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.45),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required bool isFeatured,
    String? saving,
  }) {
    const red = Color(0xFFB91C1C);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: isFeatured
                  ? LinearGradient(
                      colors: [
                        red.withOpacity(0.25),
                        red.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isFeatured ? null : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFeatured
                    ? red.withOpacity(0.7)
                    : Colors.white.withOpacity(0.1),
                width: isFeatured ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          if (saving != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF22C55E)
                                      .withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                saving,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        period,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isFeatured
                        ? const Color(0xFFFCA5A5)
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Blur + Lock overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          color: Colors.white.withOpacity(0.65),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Coming Soon",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildFeatureList() {
  final features = [
    (Icons.high_quality_rounded, "Stream in 4K Quaily"),
    (Icons.download_rounded, "Download and watch offline anytime"),
    (Icons.block_rounded, "Completely ad-free streaming experience"),
  ];

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withOpacity(0.07)),
    ),
    child: Column(
      children: features.map((f) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFB91C1C).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  f.$1,
                  size: 14,
                  color: const Color(0xFFFCA5A5),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  f.$2,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

  Widget _buildCTAButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB91C1C).withOpacity(0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.notifications_active_rounded, size: 18),
          label: const Text(
            "Notify Me at Launch",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}