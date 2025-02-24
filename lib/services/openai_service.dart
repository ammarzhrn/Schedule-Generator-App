import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String apiKey = "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";
  static const String baseUrl = "https://api.openai.com/v1/chat/completions";

  static Future<String> genereteSchedule(
      List<Map<String, dynamic>> tasks) async {
    final prompt = _buildPrompt(tasks);

    final response = await http.post(Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey ",
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "store": true,
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful assistant that can generate a schedule for a given list of tasks."
            },
            {
              "role": "user",
              "content": prompt
            }
          ],
          "max_tokens": 500
        }));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      throw Exception("failed to generate schedule");
    }
  }

  static String _buildPrompt(List<Map<String, dynamic>> tasks) {
    String taskList = tasks.map((task) =>
    "- ${task['name']} (Priority: ${task['priority']},Duration: ${task['duration']} minutes),Deadline:${task['deadline']}"
    ).join("\n");
    return "buatkan jadwal harian yg optimal untuk tugas tugas berikut: \n $taskList \n susun jadwal dari pagi hingga malam dengan efisien dan pastikan jadwal tersebut sesuai dengan deadline dari setia[ tugas";
  }

}

