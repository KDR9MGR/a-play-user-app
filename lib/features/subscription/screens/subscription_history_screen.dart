import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../provider/subscription_provider.dart';
import '../model/subscription_model.dart';

class SubscriptionHistoryScreen extends ConsumerWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionHistoryAsync = ref.watch(subscriptionHistoryProvider);
    final paymentHistoryAsync = ref.watch(paymentHistoryProvider);
    //added a comment

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Subscription History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Subscriptions'),
              Tab(text: 'Payments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Subscriptions tab
            subscriptionHistoryAsync.when(
              data: (subscriptions) {
                if (subscriptions.isEmpty) {
                  return const Center(
                    child: Text('No subscription history found.'),
                  );
                }
                return _buildSubscriptionsList(context, subscriptions);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading subscription history: $error'),
              ),
            ),
            
            // Payments tab
            paymentHistoryAsync.when(
              data: (payments) {
                if (payments.isEmpty) {
                  return const Center(
                    child: Text('No payment history found.'),
                  );
                }
                return _buildPaymentsList(context, payments);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading payment history: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionsList(BuildContext context, List<UserSubscription> subscriptions) {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        
        // Define color based on status
        Color statusColor;
        IconData statusIcon;
        
        switch (subscription.status.toLowerCase()) {
          case 'active':
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
            break;
          case 'expired':
            statusColor = Colors.orange;
            statusIcon = Icons.timer_off;
            break;
          case 'cancelled':
            statusColor = Colors.red;
            statusIcon = Icons.cancel;
            break;
          default:
            statusColor = Colors.grey;
            statusIcon = Icons.help_outline;
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        subscription.subscriptionType ?? 'Subscription',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            subscription.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Date'),
                          Text(
                            dateFormatter.format(subscription.startDate),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('End Date'),
                          Text(
                            dateFormatter.format(subscription.endDate),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${subscription.currency ?? 'GHS'} ${(subscription.amount ?? 0).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Ref: ${subscription.paymentReference?.substring(0, 10) ?? 'N/A'}...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsList(BuildContext context, List<SubscriptionPayment> payments) {
    final dateFormatter = DateFormat('MMM dd, yyyy HH:mm');
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        
        // Define color based on status
        Color statusColor;
        IconData statusIcon;
        
        switch (payment.paymentStatus.toLowerCase()) {
          case 'success':
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
            break;
          case 'pending':
            statusColor = Colors.orange;
            statusIcon = Icons.pending;
            break;
          case 'failed':
            statusColor = Colors.red;
            statusIcon = Icons.error_outline;
            break;
          default:
            statusColor = Colors.grey;
            statusIcon = Icons.help_outline;
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${payment.currency} ${payment.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            payment.paymentStatus.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  dateFormatter.format(payment.paymentDate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payment Method: ${payment.paymentMethod.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Reference: ${payment.paymentReference}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 
