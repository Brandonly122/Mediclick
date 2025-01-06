import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/add_card.dart';

class AddReminderScreen extends StatefulWidget {
  final Map<String, dynamic>? reminderData;
  const AddReminderScreen({Key? key, this.reminderData}) : super(key: key);

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  TimeOfDay? _selectedTime;
  String? documentId;

  @override
  void initState() {
    super.initState();
    if (widget.reminderData != null) {
      _medicineNameController.text = widget.reminderData!['medicineName'] ?? '';
      _doseController.text = widget.reminderData!['dose'] ?? '';
      _durationController.text =
          widget.reminderData!['duration']?.toString() ?? '';
      _descriptionController.text = widget.reminderData!['description'] ?? '';
      documentId = widget.reminderData!['id'];

      if (widget.reminderData!['time'] is Timestamp) {
        final timestamp = widget.reminderData!['time'] as Timestamp;
        final time = timestamp.toDate();
        _selectedTime = TimeOfDay(hour: time.hour, minute: time.minute);
        _timeController.text = _selectedTime!.format(context);
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _timeController.text = _selectedTime!.format(context);
      });
    }
  }

  Future<void> _saveReminder() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado. Inicia sesión.')),
      );
      return;
    }

    if (_medicineNameController.text.isEmpty ||
        _doseController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    final reminderData = {
      'medicineName': _medicineNameController.text.trim(),
      'dose': _doseController.text.trim(),
      'duration': int.tryParse(_durationController.text.trim()) ?? 0,
      'remainingDays': widget.reminderData?['remainingDays'] ??
          int.tryParse(_durationController.text.trim()) ??
          0,
      'description': _descriptionController.text.trim(),
      'time': Timestamp.fromDate(DateTime(
        DateTime.now().toLocal().year,
        DateTime.now().toLocal().month,
        DateTime.now().toLocal().day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      )),
    };

    try {
      final userRemindersRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders');

      if (documentId != null) {
        // Actualiza un recordatorio existente
        await userRemindersRef.doc(documentId).update(reminderData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recordatorio actualizado con éxito.')),
        );
      } else {
        // Agrega un nuevo recordatorio
        await userRemindersRef.add(reminderData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recordatorio agregado con éxito.')),
        );
      }

      Navigator.pop(context); // Regresa a la pantalla anterior
    } on FirebaseException catch (e) {
      // Maneja errores específicos de Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de Firebase: ${e.message}')),
      );
    } catch (e) {
      // Maneja otros errores inesperados
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error inesperado. Inténtalo de nuevo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text(
          widget.reminderData != null
              ? 'Editar Recordatorio'
              : 'Agregar Recordatorio',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              AddCard(
                label: 'Nombre de la Medicina',
                icon: Icons.medical_services,
                controller: _medicineNameController,
              ),
              const SizedBox(height: 10),
              AddCard(
                label: 'Dosis',
                icon: Icons.science,
                controller: _doseController,
              ),
              const SizedBox(height: 10),
              AddCard(
                label: 'Hora (HH:MM)',
                icon: Icons.access_time,
                controller: _timeController,
                onTap: () => _selectTime(context),
                isReadOnly: true,
              ),
              const SizedBox(height: 10),
              AddCard(
                label: 'Duración (en días)',
                icon: Icons.calendar_today,
                controller: _durationController,
                isNumberInput: true,
              ),
              const SizedBox(height: 10),
              AddCard(
                label: 'Descripción (opcional)',
                icon: Icons.description,
                controller: _descriptionController,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  widget.reminderData != null
                      ? 'Guardar Cambios'
                      : 'Agregar Recordatorio',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
