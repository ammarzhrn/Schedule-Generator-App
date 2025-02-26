import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:schedule_generator_app/models/task.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";
  final String apiKey;
  GeminiService() : apiKey = dotenv.env["GEMINI_API_KEY"] ?? "" {
    if (apiKey.isEmpty) {
      throw ArgumentError("API Key is missing");
    }
  }

  Future<String> generateSchedule(List<Task> tasks) async {
    _validateTasks(tasks);
    final prompt = _buildPrompt(tasks);
    try {
      print("Prompt: $prompt");
      final response = await http.post(
        Uri.parse("$_baseUrl?key=$apiKey"),
        headers: {
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "contents" : [
            {
              "role" : "user",
              "parts" : [
                {"text": prompt}
              ]
            }
          ]
        }));
      return _handleResponse(response);
    } catch (e) {
      throw ArgumentError("Failed to generate schedule: $e");
    }
  }

  String _handleResponse(http.Response response) {
    final data = json.decode(response.body);
    if (response.statusCode == 401) {
      throw ArgumentError("API Key is invalid or Unauthorized Access");
    } else if (response.statusCode == 429) {
      throw ArgumentError("API Key is rate limited");
    } else if (response.statusCode == 500) {
      throw ArgumentError("Internal Server Error");
    } else if (response.statusCode == 503) {
      throw ArgumentError("Service Unavailable");
    } else if (response.statusCode == 200) {
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      throw ArgumentError("Unknown Error");
    }
  }

  String _buildPrompt(List<Task> tasks) {
    final tasksList = tasks.map((task) => "Task: ${task.name}, Priority: ${task.priority}, Duration: ${task.duration} minutes, Deadline: ${task.deadline}").map((task) => task.toString()).join("\n");
    return "Buatkan jadwal harian yang sesuai dengan tugas-tugas berikut: $tasksList";
  }

  void _validateTasks(List<Task> tasks) {
    if (tasks.isEmpty) {
      throw ArgumentError("Task cannot be empty");
    }
  }
}