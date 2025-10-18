import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:mobileapp/api/chatAgent.dart';
import 'package:mobileapp/api/getChats.dart';
import 'package:mobileapp/services/authservice.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBox extends StatefulWidget {
  const ChatBox({super.key});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  late ChatUser user;
  late ChatUser chatbox;
  List<ChatMessage> messages = [];
  final Authservice authservice = Authservice();
  bool isTyping = false; // flag hiển thị đang gõ

  @override
  void initState() {
    super.initState();
    final username = authservice.getUser()?["username"] ?? "Guest";
    user = ChatUser(id: '1', firstName: username);
    chatbox = ChatUser(id: '2', firstName: 'AI Stock');
  }

  Future<void> fetchChats(String username, String slug) async {
    try {
      final result = await getChats(username: username, slug: slug);
      final chats = result?['Chats'] as List<dynamic>;
      final newMessages = chats.map((chat) {
        final isUser = chat['role'] == 'user';
        return ChatMessage(
          text: chat['content'],
          user: isUser ? user : chatbox,
          createdAt: DateTime.parse(chat['createdAt']),
        );
      }).toList();

      setState(() {
        messages = newMessages.reversed.toList();
      });
    } catch (e) {
      print("Error loading chats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final slug = args?['slug'] ?? '';
    final username = authservice.getUser()?["username"] ?? "Guest";

    if (messages.isEmpty && slug.isNotEmpty) {
      fetchChats(username, slug);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Stock'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          DashChat(
            currentUser: user,
            messages: messages,
            messageOptions: MessageOptions(
              currentUserContainerColor: Colors.grey.shade300,
              currentUserTextColor: Colors.black,
              containerColor: Colors.grey.shade200,
              textColor: Colors.black,
              messageTextBuilder:
                  (ChatMessage msg, ChatMessage? prev, ChatMessage? next) {
                    return MarkdownBody(
                      data: msg.text,
                      selectable: true,
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(
                            Theme.of(context),
                          ).copyWith(
                            p: const TextStyle(fontSize: 13, height: 1.4),
                            strong: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    );
                  },
            ),
            inputOptions: InputOptions(
              trailing: [
                SizedBox(
                  width: 40,
                  child: IconButton(onPressed: () {}, icon: Icon(Icons.image)),
                ),
              ],
            ),
            typingUsers: isTyping ? [chatbox] : [], // hiển thị đang gõ
            onSend: (ChatMessage m) async {
              setState(() {
                messages.insert(0, m);
                isTyping = true; // bật typing
              });

              // tạo tin nhắn "đang soạn..."
              final loadingMsg = ChatMessage(
                text: "",
                user: chatbox,
                createdAt: DateTime.now(),
              );
              setState(() {
                messages.insert(0, loadingMsg);
              });

              final res = await sendQuestion(
                username: username,
                question: m.text,
                labelname: slug,
              );

              setState(() {
                isTyping = false; // tắt typing
                messages.remove(loadingMsg); // xoá loading
              });

              if (res != null && res['message'] == 'successful') {
                final data = res['data'];
                final reply = ChatMessage(
                  text: data['content'] ?? 'Không có phản hồi từ AI',
                  user: chatbox,
                  createdAt: DateTime.parse(data['createdAt']),
                );
                setState(() {
                  messages.insert(0, reply);
                });
              } else {
                setState(() {
                  messages.insert(
                    0,
                    ChatMessage(
                      text: "Lỗi: ${res?['message'] ?? 'Unknown error'}",
                      user: chatbox,
                      createdAt: DateTime.now(),
                    ),
                  );
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
