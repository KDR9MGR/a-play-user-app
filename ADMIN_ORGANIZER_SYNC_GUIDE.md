# Admin Panel & Organizer App Sync Guide

**Date:** June 2, 2026
**Purpose:** Sync admin panel and organizer app with new booking system and QR tickets
**Affected Apps:** Admin Web Panel, Organizer Mobile App

---

## 📋 Changes Summary

### 1. Payment System
- ✅ PayStack WebView integration
- ✅ Transaction verification
- ✅ Payment status tracking

### 2. Database Schema
- ✅ Added `transaction_id` to all booking tables
- ✅ Added payment fields (`payment_status`, `payment_method`, etc.)
- ✅ Added booking-specific columns (`zone_id`, `amount`, `booking_date`)

### 3. QR Ticket System (NEW)
- ✅ Unique serial numbers (format: `AP-EVT-20260602-A3F7K`)
- ✅ Secure QR data with JSON payload
- ✅ Expiration logic (24 hours after event ends)
- ✅ One-time scan validation
- ✅ Auto-invalidation on cancellation
- ✅ Scan tracking (who, when, where)

---

## 🗄️ Database Changes to Sync

### All Booking Tables

#### Common Columns Added:
```sql
transaction_id TEXT                    -- PayStack transaction reference
payment_status TEXT                    -- 'pending', 'paid', 'failed', 'refunded'
payment_method TEXT                    -- 'paystack', 'apple_pay', etc.
payment_reference TEXT                 -- Unique payment reference
amount_paid DECIMAL(10,2)             -- Amount paid
currency TEXT DEFAULT 'GHS'            -- Currency code
```

### Event Bookings (`bookings` table)

#### New Columns:
```sql
-- Booking fields
zone_id UUID                          -- References zones(id)
amount DECIMAL(10,2)                  -- Total amount (mirrors total_price)
booking_date TIMESTAMP WITH TIME ZONE -- When booking was made

-- QR Ticket fields (SECURITY CRITICAL)
qr_code_serial TEXT UNIQUE            -- e.g., 'AP-EVT-20260602-A3F7K'
qr_code_data TEXT                     -- JSON data encoded in QR
qr_scanned_at TIMESTAMP               -- When ticket was scanned
qr_scanned_by UUID                    -- Who scanned it (organizer)
qr_scan_location TEXT                 -- Where it was scanned
qr_expires_at TIMESTAMP               -- Expiration time
qr_is_valid BOOLEAN DEFAULT true      -- Is ticket still valid
```

### Restaurant Bookings (`restaurant_bookings` table)

Already has payment fields (since March 2026). Just verify:
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'restaurant_bookings'
AND column_name IN ('transaction_id', 'payment_status', 'amount_paid');
```

### Club Bookings (`club_bookings` table)

Payment fields added by migration:
```sql
transaction_id TEXT
payment_status TEXT
payment_method TEXT
payment_reference TEXT
amount_paid DECIMAL(10,2)
currency TEXT DEFAULT 'GHS'
```

### New Tables Created

#### `pub_bookings`
```sql
CREATE TABLE pub_bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  pub_id UUID NOT NULL REFERENCES pubs(id),
  booking_date DATE NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  party_size INTEGER NOT NULL,

  -- Payment fields
  transaction_id TEXT,
  payment_status TEXT,
  payment_method TEXT,
  amount_paid DECIMAL(10,2),
  currency TEXT DEFAULT 'GHS',

  -- Status
  status TEXT NOT NULL DEFAULT 'pending',
  special_requests TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### `beach_bookings`
```sql
CREATE TABLE beach_bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  beach_id UUID NOT NULL REFERENCES beaches(id),
  booking_date DATE NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  party_size INTEGER NOT NULL,

  -- Beach-specific
  cabana_rental BOOLEAN DEFAULT false,
  equipment_rental TEXT[],

  -- Payment fields
  transaction_id TEXT,
  payment_status TEXT,
  payment_method TEXT,
  amount_paid DECIMAL(10,2),
  currency TEXT DEFAULT 'GHS',

  -- Status
  status TEXT NOT NULL DEFAULT 'pending',
  special_requests TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## 🔐 QR Ticket System Integration

### For Organizer App (CRITICAL)

#### 1. QR Scanning Function

**Supabase RPC Call:**
```dart
// Scan QR ticket
final response = await supabase.rpc('scan_qr_ticket', params: {
  'p_serial': scannedQRCode,           // e.g., 'AP-EVT-20260602-A3F7K'
  'p_scanned_by': organizerId,         // UUID of organizer/staff
  'p_scan_location': 'Main Entrance'   // Optional: gate/entrance name
});

// Response will be JSON
final result = response as Map<String, dynamic>;

if (result['success'] == true) {
  // ✅ Valid ticket
  print('Welcome ${result['attendee_name']}!');
  print('Event: ${result['event_title']}');
  print('Scanned at: ${result['scanned_at']}');

  // Show success screen
  showSuccessDialog(result);
} else {
  // ❌ Invalid ticket
  String error = result['error'];
  String message = result['message'];

  switch (error) {
    case 'INVALID_QR':
      // Fake or non-existent ticket
      showErrorDialog('Invalid QR Code', message);
      break;
    case 'ALREADY_SCANNED':
      // Duplicate entry attempt
      showErrorDialog('Already Scanned', message);
      break;
    case 'EXPIRED':
      // Ticket expired
      showErrorDialog('Ticket Expired', message);
      break;
    case 'CANCELLED':
      // Booking was cancelled
      showErrorDialog('Cancelled Booking', message);
      break;
    case 'UNPAID':
      // Payment not completed
      showErrorDialog('Payment Pending', message);
      break;
  }
}
```

#### 2. Get Ticket Info (Before Scanning)

```dart
// Preview ticket information
final info = await supabase.rpc('get_qr_ticket_info', params: {
  'p_serial': scannedQRCode
});

final ticketInfo = info as Map<String, dynamic>;

print('Attendee: ${ticketInfo['attendee']['name']}');
print('Email: ${ticketInfo['attendee']['email']}');
print('Event: ${ticketInfo['event']['title']}');
print('Status: ${ticketInfo['status']}');
print('Is Valid: ${ticketInfo['is_valid']}');
print('Scanned: ${ticketInfo['scanned_at'] ?? 'Not yet'}');
```

#### 3. QR Code Format

**Serial Number Pattern:**
```
AP-{TYPE}-{YYYYMMDD}-{XXXXX}

Examples:
AP-EVT-20260602-A3F7K  (Event)
AP-CLB-20260603-B8K2M  (Club)
AP-RST-20260604-C9N4P  (Restaurant)
```

**QR Data (JSON):**
```json
{
  "serial": "AP-EVT-20260602-A3F7K",
  "booking_id": "uuid-here",
  "user_id": "user-uuid",
  "event_id": "event-uuid",
  "issued_at": "2026-06-02T10:30:00Z",
  "version": "1.0"
}
```

**What to Encode in QR:**
- **Option 1 (Recommended):** Just the serial number
  ```
  AP-EVT-20260602-A3F7K
  ```
  - Simpler, shorter QR code
  - Lookup booking via `scan_qr_ticket()` function

- **Option 2:** Full JSON payload
  - More data, larger QR code
  - Can verify offline (if needed)

---

### For Admin Panel

#### 1. Booking List View Updates

**Add These Columns:**
```typescript
interface Booking {
  // Existing fields
  id: string;
  user_id: string;
  event_id: string;
  status: string;

  // NEW: Payment fields
  transaction_id?: string;
  payment_status: 'pending' | 'paid' | 'failed' | 'refunded';
  payment_method?: string;
  payment_reference?: string;
  amount_paid?: number;
  currency?: string;

  // NEW: QR Ticket fields
  qr_code_serial?: string;        // Display this to user
  qr_scanned_at?: string;         // Show scan status
  qr_scanned_by?: string;         // Who scanned
  qr_scan_location?: string;      // Where scanned
  qr_expires_at?: string;         // Expiration time
  qr_is_valid?: boolean;          // Valid status
}
```

**Query Example:**
```sql
SELECT
  b.id,
  b.status,
  b.payment_status,
  b.transaction_id,
  b.amount_paid,
  b.qr_code_serial,
  b.qr_scanned_at,
  b.qr_is_valid,
  b.qr_expires_at,
  p.full_name AS attendee_name,
  p.email AS attendee_email,
  e.title AS event_title,
  e.start_date,
  z.name AS zone_name
FROM bookings b
JOIN profiles p ON b.user_id = p.id
JOIN events e ON b.event_id = e.id
LEFT JOIN zones z ON b.zone_id = z.id
WHERE b.event_id = ?
ORDER BY b.created_at DESC;
```

#### 2. Booking Detail View

**Add QR Ticket Section:**
```typescript
// QR Ticket Status Card
<Card title="QR Ticket">
  <div>
    <strong>Serial:</strong> {booking.qr_code_serial || 'Not generated'}
  </div>

  {booking.qr_code_serial && (
    <>
      <QRCode value={booking.qr_code_serial} size={200} />

      <div>
        <strong>Status:</strong>
        {booking.qr_is_valid ? (
          <Badge color="green">Valid</Badge>
        ) : (
          <Badge color="red">Invalid</Badge>
        )}
      </div>

      <div>
        <strong>Expires:</strong> {formatDate(booking.qr_expires_at)}
      </div>

      {booking.qr_scanned_at && (
        <div>
          <strong>Scanned:</strong> {formatDate(booking.qr_scanned_at)}
          <br />
          <strong>Location:</strong> {booking.qr_scan_location}
        </div>
      )}
    </>
  )}
</Card>
```

#### 3. Event Dashboard - Scan Statistics

**New Metrics to Display:**
```typescript
interface EventScanStats {
  total_bookings: number;
  total_paid: number;
  total_scanned: number;      // NEW
  scan_rate: number;           // NEW: percentage scanned
  pending_entry: number;       // NEW: paid but not scanned
  invalid_tickets: number;     // NEW: cancelled or expired
}

// Query for stats
SELECT
  COUNT(*) AS total_bookings,
  COUNT(*) FILTER (WHERE payment_status = 'paid') AS total_paid,
  COUNT(*) FILTER (WHERE qr_scanned_at IS NOT NULL) AS total_scanned,
  COUNT(*) FILTER (WHERE payment_status = 'paid' AND qr_scanned_at IS NULL) AS pending_entry,
  COUNT(*) FILTER (WHERE qr_is_valid = false) AS invalid_tickets,
  ROUND(
    COUNT(*) FILTER (WHERE qr_scanned_at IS NOT NULL)::numeric /
    NULLIF(COUNT(*) FILTER (WHERE payment_status = 'paid'), 0) * 100,
    2
  ) AS scan_rate
FROM bookings
WHERE event_id = ?;
```

#### 4. Manual Ticket Operations

**Admin Actions:**
```sql
-- Regenerate QR for booking
UPDATE bookings
SET
  qr_code_serial = generate_qr_serial('EVT'),
  qr_code_data = generate_qr_data(id, qr_code_serial, user_id, event_id),
  qr_is_valid = true,
  qr_scanned_at = NULL,
  qr_scanned_by = NULL
WHERE id = ?;

-- Manually invalidate ticket
UPDATE bookings
SET qr_is_valid = false
WHERE id = ?;

-- Extend expiration
UPDATE bookings
SET qr_expires_at = qr_expires_at + INTERVAL '24 hours'
WHERE id = ?;
```

---

## 📱 User App Updates (Already Done)

### Event Booking Flow
✅ Payment WebView working
✅ Transaction ID stored
✅ QR code auto-generated on confirmation
✅ Ticket visible in "My Bookings"

### Ticket Display
```dart
// Show QR ticket to user
Widget buildTicketCard(Booking booking) {
  return Card(
    child: Column(
      children: [
        // Event info
        Text(booking.eventTitle),
        Text('${booking.zoneName} - Qty: ${booking.quantity}'),

        // QR Code
        if (booking.qrCodeSerial != null)
          Column(
            children: [
              QrImageView(
                data: booking.qrCodeSerial!,
                size: 250,
              ),
              Text(
                booking.qrCodeSerial!,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Status badges
              if (booking.qrIsValid == false)
                Chip(
                  label: Text('USED'),
                  backgroundColor: Colors.grey,
                ),

              if (booking.qrScannedAt != null)
                Text('Scanned: ${formatDate(booking.qrScannedAt)}'),

              // Expiration warning
              if (booking.qrExpiresAt != null &&
                  DateTime.parse(booking.qrExpiresAt).isBefore(DateTime.now()))
                Chip(
                  label: Text('EXPIRED'),
                  backgroundColor: Colors.red,
                ),
            ],
          ),
      ],
    ),
  );
}
```

---

## 🚀 Migration Steps

### For Admin Panel

#### Step 1: Update Database Queries

1. **Update booking list query:**
   - Add `transaction_id`, `payment_status`, `qr_code_serial`, `qr_scanned_at`, `qr_is_valid`
   - Add filters for payment status
   - Add filters for scan status

2. **Update booking detail query:**
   - Include all QR ticket fields
   - Include payment fields

3. **Add event scan statistics query:**
   - Total scanned vs. total paid
   - Scan rate percentage
   - Pending entries

#### Step 2: Update UI Components

1. **Booking List:**
   - Add "Payment Status" column
   - Add "QR Status" column (Valid/Scanned/Expired)
   - Add "Transaction ID" column
   - Add color coding (green=paid, yellow=pending, red=failed)

2. **Booking Detail:**
   - Add payment information card
   - Add QR ticket card with QR code display
   - Add scan history (if scanned)

3. **Event Dashboard:**
   - Add scan statistics widgets
   - Add real-time entry counter
   - Add scan rate graph

#### Step 3: Add Export Features

```typescript
// Export attendee list with QR status
const exportAttendees = async (eventId: string) => {
  const { data } = await supabase
    .from('bookings')
    .select(`
      *,
      profiles(full_name, email, phone),
      zones(name)
    `)
    .eq('event_id', eventId)
    .eq('payment_status', 'paid')
    .csv();

  // Download as CSV with columns:
  // Name, Email, Phone, Zone, QR Serial, Scanned, Scan Time
};
```

---

### For Organizer App

#### Step 1: Install QR Scanner

**Dependencies:**
```yaml
# pubspec.yaml
dependencies:
  qr_code_scanner: ^1.0.1
  mobile_scanner: ^3.5.2  # Alternative, better performance
```

#### Step 2: Create Scanner Screen

```dart
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final String eventId;
  final String organizerId;

  const QRScannerScreen({
    required this.eventId,
    required this.organizerId,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = false;

  Future<void> scanTicket(String qrCode) async {
    if (isScanning) return;
    setState(() => isScanning = true);

    try {
      final response = await Supabase.instance.client.rpc(
        'scan_qr_ticket',
        params: {
          'p_serial': qrCode,
          'p_scanned_by': widget.organizerId,
          'p_scan_location': 'Main Entrance',
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        // Success - show green screen
        await showSuccessDialog(
          attendeeName: result['attendee_name'],
          eventTitle: result['event_title'],
        );

        // Play success sound
        playSuccessSound();

        // Vibrate
        Vibration.vibrate(duration: 200);
      } else {
        // Failure - show red screen
        await showErrorDialog(
          error: result['error'],
          message: result['message'],
        );

        // Play error sound
        playErrorSound();

        // Vibrate differently
        Vibration.vibrate(pattern: [0, 200, 100, 200]);
      }
    } catch (e) {
      showErrorDialog(
        error: 'ERROR',
        message: 'Failed to verify ticket: $e',
      );
    } finally {
      setState(() => isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Tickets')),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  scanTicket(barcode.rawValue!);
                }
              }
            },
          ),

          // Scanning indicator
          if (isScanning)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Scan frame overlay
          CustomPaint(
            painter: ScanFramePainter(),
            child: Container(),
          ),
        ],
      ),
    );
  }
}
```

#### Step 3: Create Success/Error Dialogs

```dart
Future<void> showSuccessDialog({
  required String attendeeName,
  required String eventTitle,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.green[700],
      icon: Icon(Icons.check_circle, size: 80, color: Colors.white),
      title: Text(
        'VALID TICKET',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            attendeeName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            eventTitle,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

Future<void> showErrorDialog({
  required String error,
  required String message,
}) async {
  Color errorColor;
  String title;

  switch (error) {
    case 'ALREADY_SCANNED':
      errorColor = Colors.orange[700]!;
      title = 'ALREADY SCANNED';
      break;
    case 'EXPIRED':
      errorColor = Colors.red[700]!;
      title = 'TICKET EXPIRED';
      break;
    case 'CANCELLED':
      errorColor = Colors.red[900]!;
      title = 'BOOKING CANCELLED';
      break;
    case 'UNPAID':
      errorColor = Colors.amber[700]!;
      title = 'PAYMENT PENDING';
      break;
    default:
      errorColor = Colors.red[700]!;
      title = 'INVALID TICKET';
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: errorColor,
      icon: Icon(Icons.cancel, size: 80, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('CLOSE', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
```

#### Step 4: Add Event Selection

```dart
// Event selection screen for organizers
class EventSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Event to Scan')),
      body: FutureBuilder<List<Event>>(
        future: getMyEvents(),  // Get events organizer has access to
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final event = snapshot.data![index];
              return ListTile(
                title: Text(event.title),
                subtitle: Text(formatDate(event.startDate)),
                trailing: FutureBuilder<ScanStats>(
                  future: getEventScanStats(event.id),
                  builder: (context, stats) {
                    if (!stats.hasData) return SizedBox();
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${stats.data!.scanned}/${stats.data!.total}'),
                        Text('${stats.data!.scanRate}%', style: TextStyle(fontSize: 12)),
                      ],
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QRScannerScreen(
                        eventId: event.id,
                        organizerId: currentUser.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## 🔒 Security Considerations

### For Organizer App

1. **Rate Limiting:**
   ```sql
   -- Add rate limiting to scan function
   -- Maximum 100 scans per minute per organizer
   ```

2. **Permission Checks:**
   ```sql
   -- Only allow organizers of the specific event to scan
   CREATE POLICY "organizers_can_scan"
   ON bookings
   FOR UPDATE
   USING (
     EXISTS (
       SELECT 1 FROM event_organizers
       WHERE event_id = bookings.event_id
       AND user_id = auth.uid()
     )
   );
   ```

3. **Offline Mode:**
   - Download attendee list before event
   - Sync scans when back online
   - Handle conflicts (same ticket scanned twice)

### For Admin Panel

1. **Audit Logging:**
   ```sql
   CREATE TABLE qr_scan_audit_log (
     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
     booking_id UUID REFERENCES bookings(id),
     serial TEXT,
     scanned_by UUID REFERENCES profiles(id),
     scan_result TEXT,  -- 'success', 'already_scanned', 'expired', etc.
     scan_location TEXT,
     ip_address TEXT,
     user_agent TEXT,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );
   ```

2. **Suspicious Activity Detection:**
   - Multiple failed scan attempts
   - Same QR scanned from different locations
   - Expired tickets being presented

---

## 📊 Reporting Features to Add

### For Admin Panel

1. **Entry Report:**
   - Total entries by hour
   - Peak entry times
   - Average scan time per attendee

2. **Zone Report:**
   - Entries by zone (VIP, General, etc.)
   - Revenue by zone

3. **Payment Report:**
   - Total revenue
   - Payment methods breakdown
   - Failed/refunded transactions

4. **No-Show Report:**
   - Paid but not scanned tickets
   - Revenue at risk

---

## ✅ Testing Checklist

### Admin Panel
- [ ] Can view booking with payment status
- [ ] Can view booking with QR serial
- [ ] Can see scan status (scanned/not scanned)
- [ ] Can view event scan statistics
- [ ] Can export attendee list with QR codes
- [ ] Can manually invalidate tickets

### Organizer App
- [ ] Can select event to scan
- [ ] Camera opens and scans QR codes
- [ ] Valid ticket shows green success screen
- [ ] Already scanned ticket shows orange error
- [ ] Expired ticket shows red error
- [ ] Can see scan statistics for event
- [ ] Offline mode works (if implemented)

### User App (Already Done)
- [x] Booking creates with payment
- [x] QR code visible in ticket
- [x] QR expires after event
- [x] QR invalidates on cancellation

---

## 🎯 Summary

**What Changed:**
1. ✅ Payment system with transaction tracking
2. ✅ Secure QR tickets with unique serials
3. ✅ Expiration and validation logic
4. ✅ Scan tracking and verification
5. ✅ New tables for pubs and beaches

**What to Update:**
- **Admin Panel:** Add payment columns, QR ticket display, scan statistics
- **Organizer App:** Add QR scanner, ticket verification, success/error screens

**Migrations to Run:**
1. ✅ `FIX_BOOKINGS_SIMPLE.sql` (already done)
2. ✅ `20260602_fix_all_booking_tables.sql` (already done)
3. ⏳ `20260602_secure_qr_tickets.sql` (run next)

**Estimated Implementation Time:**
- Admin Panel updates: 4-6 hours
- Organizer App QR scanner: 6-8 hours
- Testing: 2-3 hours
- **Total:** 12-17 hours

---

**Files Created:**
1. [`supabase/migrations/20260602_secure_qr_tickets.sql`](supabase/migrations/20260602_secure_qr_tickets.sql) - QR system migration
2. [`ADMIN_ORGANIZER_SYNC_GUIDE.md`](ADMIN_ORGANIZER_SYNC_GUIDE.md) - This guide

**Ready for Implementation!** 🚀
