import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_service.dart';
import 'chatbot.dart';

class ChatHistoryScreen extends StatelessWidget {
  ChatHistoryScreen({super.key});

  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation History', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No conversations yet.',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final conversations = snapshot.data!.docs;
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final convo = conversations[index];
              final data = convo.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Untitled';
              final updatedAt = data['updatedAt'] as Timestamp?;
              final dateStr = updatedAt != null
                  ? _formatDate(updatedAt.toDate())
                  : '';

              return ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(dateStr),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    await _chatService.deleteConversation(convo.id);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatBotScreen(conversationId: convo.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatBotScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year} ${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour < 12 ? 'AM' : 'PM'}';
  }
}
