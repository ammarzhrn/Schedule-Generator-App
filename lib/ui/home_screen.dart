import 'package:flutter/material.dart';
import 'package:schedule_generator_app/services/gemini_service.dart';
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];
  bool isLoading = false;
  String scheduleResult = "";
  String? priority;
  final taskController = TextEditingController();
  final durationController = TextEditingController();
  final deadlineController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Generator", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputCard(),
            const SizedBox(height: 20),
            Expanded(child: _buildTaskList()),
            const SizedBox(height: 20),
            _buildGenerateButton(),
            const SizedBox(height: 20),
            _buildScheduleResult(),
          ],
        ),
      ),
      backgroundColor: Colors.grey[850],
    );
  }

  Widget _buildInputCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(taskController, "Task Name", Icons.task),
            const SizedBox(height: 10),
            _buildTextField(durationController, "Duration (minutes)", Icons.timer, isNumber: true),
            const SizedBox(height: 10),
            _buildTextField(deadlineController, "Deadline", Icons.date_range),
            const SizedBox(height: 10),
            _buildDropdown(),
            const SizedBox(height: 20),
            _buildAddTaskButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: priority,
      decoration: InputDecoration(
        labelText: "Priority",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: ["High", "Medium", "Low"]
          .map((priority) => DropdownMenuItem(value: priority, child: Text(priority)))
          .toList(),
      onChanged: (value) => setState(() => priority = value),
    );
  }

  Widget _buildAddTaskButton() {
    return ElevatedButton(
      onPressed: _addTask,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      child: const Text("Add Task", style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  void _addTask() {
    if (taskController.text.isNotEmpty && durationController.text.isNotEmpty && deadlineController.text.isNotEmpty && priority != null) {
      setState(() {
        tasks.add(Task(
          name: taskController.text,
          priority: priority!,
          duration: int.tryParse(durationController.text) ?? 5,
          deadline: deadlineController.text,
        ));
      });
      _clearInputs();
    }
  }

  void _clearInputs() {
    taskController.clear();
    durationController.clear();
    deadlineController.clear();
    setState(() => priority = null);
  }

  Future<void> _generateSchedule() async {
    setState(() => isLoading = true);
    try {
      String schedule = await GeminiService().generateSchedule(tasks);
      setState(() => scheduleResult = schedule);
    } catch (e) {
      setState(() => scheduleResult = "Failed to Generate Schedule: $e");
    }
    setState(() => isLoading = false);
  }

  Widget _buildTaskList() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Priority: ${task.priority} | Duration: ${task.duration} min | Deadline: ${task.deadline}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => tasks.removeAt(index)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return isLoading
        ? const CircularProgressIndicator()
        : ElevatedButton(
      onPressed: _generateSchedule,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      child: const Text("Generate Schedule", style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildScheduleResult() {
    return scheduleResult.isNotEmpty
        ? Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Text(scheduleResult, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    )
        : Container();
  }
}