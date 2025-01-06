import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  final String medicineName;
  final String dose;
  final String time;
  final int remainingDays;
  final VoidCallback onDelete;

  const ReminderCard({
    Key? key,
    required this.medicineName,
    required this.dose,
    required this.time,
    required this.remainingDays,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicineName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dosis: $dose',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            Text(
              'Hora: $time',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            Text(
              'Días restantes: $remainingDays',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
