import 'package:a_play/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class AdminServiceRequestsPage extends StatefulWidget {
  const AdminServiceRequestsPage({super.key});

  @override
  State<AdminServiceRequestsPage> createState() => _AdminServiceRequestsPageState();
}

class _AdminServiceRequestsPageState extends State<AdminServiceRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAdmin = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkAdminStatus();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _checkAdminStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _isAdmin = false;
        });
        return;
      }
      
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();
      
      setState(() {
        _isLoading = false;
        _isAdmin = adminDoc.exists;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isAdmin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.shield_cross,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to access this area',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Requests Admin'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsList('pending'),
          _buildRequestsList('inProgress'),
          _buildRequestsList('completed'),
        ],
      ),
    );
  }
  
  Widget _buildRequestsList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('serviceRequests')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        
        final requests = snapshot.data?.docs ?? [];
        
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.document_text,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Requests',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'There are no ${_getStatusText(status)} service requests',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          );
        }
        
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final request = requests[index];
            final data = request.data() as Map<String, dynamic>;
            
            return ServiceRequestCard(
              requestId: request.id,
              data: data,
              onStatusChange: () {
                // This will trigger a rebuild when status changes
              },
            );
          },
        );
      },
    );
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'pending';
      case 'inProgress':
        return 'in progress';
      case 'completed':
        return 'completed';
      default:
        return status;
    }
  }
}

class ServiceRequestCard extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> data;
  final VoidCallback onStatusChange;
  
  const ServiceRequestCard({
    super.key,
    required this.requestId,
    required this.data,
    required this.onStatusChange,
  });
  
  @override
  Widget build(BuildContext context) {
    final category = data['category'] ?? '';
    final service = data['service'] ?? '';
    final details = data['details'] ?? '';
    final requestDate = data['requestDate'] ?? '';
    final status = data['status'] ?? '';
    final userEmail = data['userEmail'] ?? '';
    
    // Format timestamp
    String formattedDate = 'Unknown date';
    if (data['createdAt'] != null) {
      final timestamp = data['createdAt'] as Timestamp;
      formattedDate = DateFormat('MMM d, yyyy h:mm a').format(timestamp.toDate());
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    '$category - $service',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(context, status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Iconsax.calendar, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Requested for: $requestDate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Iconsax.clock, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Created: $formattedDate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Iconsax.user, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'User: $userEmail',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Details:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              details,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _showDetailsDialog(context);
                  },
                  icon: const Icon(Iconsax.eye),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    _showUpdateStatusDialog(context);
                  },
                  icon: const Icon(Iconsax.edit),
                  label: const Text('Update Status'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'pending':
        color = Colors.amber;
        text = 'Pending';
        break;
      case 'inProgress':
        color = Colors.blue;
        text = 'In Progress';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Completed';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
  
  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(requestId),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem(context, 'Category', data['category'] ?? ''),
              _buildDetailItem(context, 'Service', data['service'] ?? ''),
              _buildDetailItem(context, 'Details', data['details'] ?? ''),
              _buildDetailItem(context, 'Requested Date', data['requestDate'] ?? ''),
              _buildDetailItem(context, 'Status', data['status'] ?? ''),
              _buildDetailItem(context, 'User Email', data['userEmail'] ?? ''),
              _buildDetailItem(context, 'User ID', data['userId'] ?? ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  void _showUpdateStatusDialog(BuildContext context) {
    final currentStatus = data['status'] as String? ?? 'pending';
    String newStatus = currentStatus;
    final TextEditingController notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Status: ${_getStatusText(currentStatus)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'New Status:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: newStatus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'pending',
                    child: Text(_getStatusText('pending')),
                  ),
                  DropdownMenuItem(
                    value: 'inProgress',
                    child: Text(_getStatusText('inProgress')),
                  ),
                  DropdownMenuItem(
                    value: 'completed',
                    child: Text(_getStatusText('completed')),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    newStatus = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Status Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) return;
                
                // Update the service request status
                await FirebaseFirestore.instance
                    .collection('serviceRequests')
                    .doc(requestId)
                    .update({
                  'status': newStatus,
                  'statusNotes': notesController.text,
                  'lastUpdatedBy': currentUser.uid,
                  'lastUpdatedAt': FieldValue.serverTimestamp(),
                });
                
                onStatusChange();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Status updated to ${_getStatusText(newStatus)}')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating status: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'inProgress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }
} 