# Booking Details Screen

## Overview
The Booking Details Screen displays a complete booking summary with a ticket-style UI including:
- QR Code for verification
- Complete booking information
- Car details
- Pickup location and time
- Payment details
- Status badge
- Action buttons (Download, Get Directions, Cancel)

## Features

### 1. QR Code
- Displays a scannable QR code containing the booking ID
- Instructions for scanning at the parking lot
- Bordered container for better visibility

### 2. Booking Information
- Vehicle name and brand
- Pickup location
- Date range with formatted dates
- Pickup time
- Total days calculation
- Booking date
- Payment method

### 3. Status Badge
- Active (Green)
- Completed (Blue)
- Cancelled (Red)

### 4. Ticket UI Design
- White card with rounded corners and shadow
- Dotted divider line with circular cutouts (ticket-style)
- Color-coded sections
- Icon-based detail rows

### 5. Action Buttons (for active bookings)
- **Download Ticket**: Downloads/shares the booking details
- **Get Directions**: Opens navigation to pickup location
- **Cancel Booking**: Shows confirmation dialog and cancels booking

## Navigation

### From History Screen
```dart
context.push('/booking-details', extra: booking);
```

### From Any Screen with Booking Object
```dart
// Navigate to booking details
context.push('/booking-details', extra: bookingObject);
```

## Example Booking Object
```dart
final booking = Booking(
  id: 'BOOK-2024-001',
  car: car, // Car object
  startDate: DateTime(2024, 12, 16),
  endDate: DateTime(2024, 12, 18),
  pickupTime: 'OF AM-3PM',
  pickupLocation: 'Son Mandia',
  paymentMethod: 'Visa',
  totalPrice: 378.99,
  bookingDate: DateTime.now(),
  status: 'active',
);
```

## Customization

### Change Status Colors
Modify the `_getStatusColor` method in the BookingDetailsScreen:
```dart
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return Colors.green; // Change to your color
    // ... other cases
  }
}
```

### Modify Action Buttons
The action buttons are only shown for active bookings. You can modify this behavior in the build method.

## Dependencies
- `qr_flutter: ^4.1.0` - For QR code generation
- `intl` - For date formatting
- `go_router` - For navigation
