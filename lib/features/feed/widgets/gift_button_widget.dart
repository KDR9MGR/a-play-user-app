import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/feed_model.dart';
import '../model/post_gift_model.dart';
import '../service/gift_service.dart';

/// Gift button widget for feed posts
class GiftButtonWidget extends ConsumerStatefulWidget {
  final FeedModel feed;
  final VoidCallback? onGiftSuccess;

  const GiftButtonWidget({
    super.key,
    required this.feed,
    this.onGiftSuccess,
  });

  @override
  ConsumerState<GiftButtonWidget> createState() => _GiftButtonWidgetState();
}

class _GiftButtonWidgetState extends ConsumerState<GiftButtonWidget> {
  final GiftService _giftService = GiftService();
  bool _isLoading = false;
  PostGiftSummary? _giftSummary;

  @override
  void initState() {
    super.initState();
    _loadGiftSummary();
  }

  Future<void> _loadGiftSummary() async {
    final summary = await _giftService.getPostGiftSummary(widget.feed.id);
    if (mounted) {
      setState(() {
        _giftSummary = summary;
      });
    }
  }

  void _showGiftDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GiftDialogContent(
        feed: widget.feed,
        giftService: _giftService,
        currentSummary: _giftSummary,
        onSuccess: () {
          _loadGiftSummary();
          widget.onGiftSuccess?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasGifts = _giftSummary?.hasGifts ?? false;
    final totalPoints = _giftSummary?.totalPoints ?? 0;
    final userHasGifted = _giftSummary?.userHasGifted ?? false;

    return InkWell(
      onTap: userHasGifted ? null : _showGiftDialog,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: userHasGifted
                ? Colors.amber.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
          color: userHasGifted
              ? Colors.amber.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              userHasGifted ? Icons.star : Icons.star_border,
              size: 18,
              color: userHasGifted ? Colors.amber : Colors.grey[600],
            ),
            if (hasGifts) ...[
              const SizedBox(width: 4),
              Text(
                _giftSummary!.formattedPoints,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: userHasGifted ? Colors.amber[700] : Colors.grey[700],
                ),
              ),
            ],
            if (userHasGifted) ...[
              const SizedBox(width: 4),
              Text(
                'Gifted',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ] else ...[
              const SizedBox(width: 4),
              Text(
                'Gift',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Gift dialog content
class _GiftDialogContent extends StatefulWidget {
  final FeedModel feed;
  final GiftService giftService;
  final PostGiftSummary? currentSummary;
  final VoidCallback onSuccess;

  const _GiftDialogContent({
    required this.feed,
    required this.giftService,
    required this.currentSummary,
    required this.onSuccess,
  });

  @override
  State<_GiftDialogContent> createState() => _GiftDialogContentState();
}

class _GiftDialogContentState extends State<_GiftDialogContent> {
  GiftType? _selectedGiftType;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController();
  bool _isProcessing = false;
  int _userBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    final balance = await widget.giftService.getUserPointsBalance();
    if (mounted) {
      setState(() {
        _userBalance = balance;
      });
    }
  }

  Future<void> _processGift() async {
    if (_selectedGiftType == null) {
      _showError('Please select a gift amount');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    int pointsAmount = _selectedGiftType!.defaultPoints;

    // Handle custom amount
    if (_selectedGiftType == GiftType.custom) {
      final customAmount = int.tryParse(_customAmountController.text);
      if (customAmount == null || customAmount <= 0) {
        setState(() {
          _isProcessing = false;
        });
        _showError('Please enter a valid amount');
        return;
      }
      pointsAmount = customAmount;
    }

    // Validate balance
    if (pointsAmount > _userBalance) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Insufficient points. You have $_userBalance points.');
      return;
    }

    final response = await widget.giftService.giftPointsToPost(
      feedId: widget.feed.id,
      receiverUserId: widget.feed.userId,
      pointsAmount: pointsAmount,
      giftType: _selectedGiftType!,
      message: _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim(),
    );

    setState(() {
      _isProcessing = false;
    });

    if (response.success) {
      if (mounted) {
        Navigator.pop(context);
        _showSuccess(
          'Gift sent! ${response.remainingPoints} points remaining.',
        );
        widget.onSuccess();
      }
    } else {
      _showError(response.errorMessage);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authorName = widget.feed.authorName ?? 'User';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Gift Points to $authorName',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Your balance: $_userBalance points',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Gift options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Amount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Gift type buttons
                  Row(
                    children: [
                      Expanded(
                        child: _GiftTypeButton(
                          giftType: GiftType.small,
                          isSelected: _selectedGiftType == GiftType.small,
                          onTap: () {
                            setState(() {
                              _selectedGiftType = GiftType.small;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GiftTypeButton(
                          giftType: GiftType.medium,
                          isSelected: _selectedGiftType == GiftType.medium,
                          onTap: () {
                            setState(() {
                              _selectedGiftType = GiftType.medium;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GiftTypeButton(
                          giftType: GiftType.large,
                          isSelected: _selectedGiftType == GiftType.large,
                          onTap: () {
                            setState(() {
                              _selectedGiftType = GiftType.large;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Custom amount option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGiftType = GiftType.custom;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedGiftType == GiftType.custom
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withOpacity(0.3),
                          width: _selectedGiftType == GiftType.custom ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '💎',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _customAmountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Enter custom amount',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedGiftType = GiftType.custom;
                                });
                              },
                            ),
                          ),
                          Text(
                            'points',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Optional message
                  Text(
                    'Add a Message (Optional)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: 'Write a message to the author...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Send gift button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processGift,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Text(
                              'Send Gift',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gift type button widget
class _GiftTypeButton extends StatelessWidget {
  final GiftType giftType;
  final bool isSelected;
  final VoidCallback onTap;

  const _GiftTypeButton({
    required this.giftType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Column(
          children: [
            Text(
              giftType.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              giftType.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${giftType.defaultPoints} pts',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
