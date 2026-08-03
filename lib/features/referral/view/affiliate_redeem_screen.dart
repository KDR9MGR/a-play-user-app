import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../model/referral_model.dart';
import '../provider/referral_provider.dart';

class AffiliateRedeemScreen extends ConsumerWidget {
  const AffiliateRedeemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affiliatesAsync = ref.watch(activeAffiliatesProvider);
    final userPointsAsync = ref.watch(userPointsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      appBar: AppBar(
        title: const Text(
          'Redeem at Partners',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              Color(0xFF1A1A1D),
              Color(0xFF0A0A0B),
            ],
          ),
        ),
        child: RefreshIndicator(
          color: const Color(0xFF6366F1),
          backgroundColor: const Color(0xFF1F1F23),
          onRefresh: () async {
            ref.invalidate(activeAffiliatesProvider);
          },
          child: affiliatesAsync.when(
            data: (affiliates) {
              final availablePoints =
                  userPointsAsync.asData?.value?.availablePoints ?? 0;

              if (affiliates.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(
                      child: Text(
                        'No partner businesses available right now.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                );
              }

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: affiliates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final affiliate = affiliates[index];
                  return _AffiliateTile(
                    affiliate: affiliate,
                    availablePoints: availablePoints,
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
            error: (error, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Text(
                    'Failed to load partners.\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AffiliateTile extends StatelessWidget {
  final Affiliate affiliate;
  final int availablePoints;

  const _AffiliateTile({
    required this.affiliate,
    required this.availablePoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1F23), Color(0xFF2A2A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3A3E), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Iconsax.shop, color: Color(0xFF8B8BF1)),
        ),
        title: Text(
          affiliate.businessName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          [
            if (affiliate.category != null && affiliate.category!.isNotEmpty)
              affiliate.category!,
            if (affiliate.address != null && affiliate.address!.isNotEmpty)
              affiliate.address!,
          ].join(' • '),
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        trailing: const Icon(Iconsax.arrow_right_3, color: Colors.grey, size: 18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _AffiliateRedeemDetailScreen(
                affiliate: affiliate,
                availablePoints: availablePoints,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AffiliateRedeemDetailScreen extends ConsumerStatefulWidget {
  final Affiliate affiliate;
  final int availablePoints;

  const _AffiliateRedeemDetailScreen({
    required this.affiliate,
    required this.availablePoints,
  });

  @override
  ConsumerState<_AffiliateRedeemDetailScreen> createState() =>
      _AffiliateRedeemDetailScreenState();
}

class _AffiliateRedeemDetailScreenState
    extends ConsumerState<_AffiliateRedeemDetailScreen> {
  final TextEditingController _pointsController = TextEditingController();
  bool _isSubmitting = false;
  PointRedemption? _result;

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _pointsController.text.trim();
    final points = int.tryParse(text);

    if (points == null || points <= 0) {
      _showSnack('Enter a valid number of points');
      return;
    }

    if (points > widget.availablePoints) {
      _showSnack('You only have ${widget.availablePoints} points available');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Redemption'),
        content: Text(
            'Redeem $points points at ${widget.affiliate.businessName}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      final redemption = await ref
          .read(userPointsProvider.notifier)
          .redeemAtAffiliate(widget.affiliate.id, points);
      if (!mounted) return;
      setState(() => _result = redemption);
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      _showSnack(message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      appBar: AppBar(
        title: Text(
          widget.affiliate.businessName,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1A1A1D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _result != null ? _buildResult(_result!) : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You have ${widget.availablePoints} points available',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _pointsController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Points to redeem',
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: const Color(0xFF2A2A2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Redeem',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(PointRedemption redemption) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Icon(Iconsax.tick_circle, color: Colors.green, size: 56),
        const SizedBox(height: 20),
        const Text(
          'Redemption confirmed!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Show this code to staff at ${widget.affiliate.businessName} to redeem your discount.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F23),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
          ),
          child: Column(
            children: [
              Text(
                redemption.redemptionCode ?? '—',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: redemption.redemptionCode == null
                    ? null
                    : () {
                        Clipboard.setData(
                            ClipboardData(text: redemption.redemptionCode!));
                        _showSnack('Code copied to clipboard');
                      },
                icon: const Icon(Iconsax.copy, size: 18),
                label: const Text('Copy code'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF3A3A3E)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
