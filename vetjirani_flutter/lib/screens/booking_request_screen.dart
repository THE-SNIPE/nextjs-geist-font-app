import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingRequestScreen extends StatefulWidget {
  final String vetId;

  BookingRequestScreen({required this.vetId});

  @override
  _BookingRequestScreenState createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _issue = '';
  String _animalType = 'Cattle';

  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedTime == null) {
      setState(() {
        _errorMessage = 'Please fill all fields and select date/time.';
      });
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      final farmerId = user?.uid ?? '';

      final bookingData = {
        'vetId': widget.vetId,
        'dateTime': Timestamp.fromDate(dateTime),
        'issue': _issue,
        'animalType': _animalType,
        'status': 'pending',
        'createdAt': Timestamp.now(),
        'farmerId': farmerId,
      };

      await FirebaseFirestore.instance.collection('bookings').add(bookingData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking request sent.')));
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send booking request: $e';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Appointment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(_selectedDate == null ? 'Select Date' : _selectedDate!.toLocal().toString().split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: Text(_selectedTime == null ? 'Select Time' : _selectedTime!.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              DropdownButtonFormField<String>(
                value: _animalType,
                decoration: InputDecoration(labelText: 'Animal Type'),
                items: ['Cattle', 'Goats', 'Sheep', 'Poultry', 'Equine', 'Swine'].map((animal) {
                  return DropdownMenuItem(value: animal, child: Text(animal));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _animalType = val ?? 'Cattle';
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Issue Description'),
                maxLines: 3,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please describe the issue' : null,
                onSaved: (val) => _issue = val!.trim(),
              ),
              SizedBox(height: 20),
              if (_errorMessage != null)
                Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              if (_isSubmitting)
                Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitBooking,
                  child: Text('Send Request'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
