import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _addEvent() async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _titleController.text.isEmpty ||
        _venueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final DateTime finalDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    await FirebaseFirestore.instance.collection('events').add({
      'title': _titleController.text.trim(),
      'venue': _venueController.text.trim(),
      'description': _descriptionController.text.trim(),
      'date': Timestamp.fromDate(finalDateTime),
      'createdAt': Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Event"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Event Title"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: "Venue"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickDate,
                child: Text(
                  _selectedDate == null
                      ? "Select Date"
                      : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _pickTime,
                child: Text(
                  _selectedTime == null
                      ? "Select Time"
                      : _selectedTime!.format(context),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _addEvent,
                child: const Text("Add Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}