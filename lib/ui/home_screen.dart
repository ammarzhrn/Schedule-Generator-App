import 'package:flutter/material.dart';
import 'package:schedule_generator_app/services/openai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> tasks = [];
  final TextEditingController taskController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  String? priority;
  bool isLoading = false;
  String? scheduleResult;

  void _addTask() {
    if (taskController.text.isNotEmpty &&
        priority != null &&
        durationController.text.isNotEmpty) {
      setState(() {tasks.add({
        "name": taskController.text,
        "priority": priority!,
        "duration": int.tryParse(durationController.text) ?? 30,
        "deadline": "Tidak ada"
      });
      });
      taskController.clear();
      durationController.clear();
      priority = null;
    }
  }

  Future<void> _generateSchedule() async {
    setState(() => isLoading = true);
    try {
      String schedule = await OpenAIService.genereteSchedule(tasks);
      setState(() => scheduleResult = schedule);
    } catch (e) {
      setState(() => scheduleResult = "Failed to generate schedule: $e");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,children: [
            // Input Tugas
            TextField(
              controller: taskController,
              decoration: const InputDecoration(
                labelText: 'Nama Tugas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Input Durasi
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Durasi (menit)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Dropdown Prioritas
            DropdownButtonFormField<String>(
              value: priority,
              decoration: const InputDecoration(
                labelText: 'Prioritas',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Tinggi', child: Text('Tinggi')),
                DropdownMenuItem(value: 'Sedang', child: Text('Sedang')),
                DropdownMenuItem(value: 'Rendah', child: Text('Rendah')),
              ],
              onChanged: (value) {
                setState(() {
                  priority = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Tombol Tambah Tugas
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('Tambah Tugas'),
            ),
            const SizedBox(height: 24),
            // Daftar Tugas
            const Text(
              'Daftar Tugas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  child: ListTile(
                    title: Text(task['name']),
                    subtitle: Text(
                        'Prioritas: ${task['priority']}, Durasi: ${task['duration']} menit'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Tombol Generate Schedule
            ElevatedButton(onPressed: isLoading ? null : _generateSchedule,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Generate Schedule'),
            ),
            const SizedBox(height: 24),
            // Hasil Jadwal
            if (scheduleResult != null)
              Text(
                'Hasil Jadwal:\n$scheduleResult',
                style: const TextStyle(fontSize: 16),
              ),
          ],
          ),
        ),
      ),
    );
  }
}