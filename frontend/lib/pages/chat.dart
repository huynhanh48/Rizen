import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:mobileapp/api/chatAgent.dart';
import 'package:mobileapp/api/getChats.dart';
import 'package:mobileapp/services/authservice.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';

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
  bool isTyping = false;
  File? isImage = null;

  @override
  void initState() {
    super.initState();
    final username = authservice.getUser()?["username"] ?? "Guest";
    user = ChatUser(id: '1', firstName: username);
    chatbox = ChatUser(
      id: '2',
      firstName: 'Stock',
      profileImage: "assets/ai.png",
    );
  }

  Future<void> fetchChats(String username, String slug) async {
    try {
      final result = await getChats(username: username, slug: slug);
      final chats = result?['Chats'] as List<dynamic>;
      final newMessages = chats.map((chat) {
        final isUser = chat['role'] == 'user';
        String? imgUrl;
        String textContent = '';
        if (chat['content'] is Map) {
          textContent = chat['content']['text'] ?? '';
          imgUrl = chat['content']['img'];
        } else {
          textContent = chat['content'] ?? '';
          imgUrl = chat['img'];
        }

        return ChatMessage(
          text: textContent,
          user: isUser ? user : chatbox,
          createdAt: DateTime.parse(chat['createdAt']),
          customProperties: imgUrl != null ? {'img': imgUrl} : {},
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage("assets/ai.png"),
                radius: 15,
              ),
            ),
            Text(
              'Stock',
              style: TextStyle(
                color: Colors.lightBlueAccent.shade700,
                fontWeight: FontWeight.w600, // dày vừa phải, không thô
                fontSize: 20,
                letterSpacing: 1,
              ),
            ),
            SizedBox(width: 45),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2, // nhẹ nhàng tạo cảm giác nổi
        centerTitle: true, // căn giữa title cho hiện đại
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
                    final imgUrl = msg.customProperties?['img'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarkdownBody(
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
                        ),
                        imgUrl != null && imgUrl.isNotEmpty
                            ? Column(
                                children: [
                                  const SizedBox(height: 6),
                                  Text(" ** Biểu đồ tham khảo **"),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => Dialog(
                                          child: InteractiveViewer(
                                            child: Image.network(
                                              imgUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    },

                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imgUrl,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(), // không hiển thị gì nếu imgUrl null
                      ],
                    );
                  },
            ),
            inputOptions: InputOptions(
              trailing: [
                SizedBox(
                  width: 40,
                  child: IconButton(
                    onPressed: () async {
                      final result = await sendImage(context);
                      if (result != null) {
                        setState(() {
                          isImage = result;
                        });
                      }
                    },
                    icon: Icon(Icons.image),
                  ),
                ),
              ],
            ),
            typingUsers: isTyping ? [chatbox] : [],
            onSend: (ChatMessage m) async {
              if (isImage != null) {
                m.medias = [
                  ChatMedia(
                    url: isImage?.path ?? "",
                    fileName: "",
                    type: MediaType.image,
                  ),
                ];
              }
              setState(() {
                messages.insert(0, m);
                isTyping = true;
              });

              final res = await sendQuestion(
                username: username,
                question: m.text,
                labelname: slug,
                hadFile: isImage != null ? true : false,
                file: isImage ?? null,
              );

              setState(() {
                isTyping = false;
                isImage = null;
              });

              if (res != null && res['message'] == 'successful') {
                final data = res['data'];

                String replyText = '';
                String? imgUrl;

                if (data['content'] is Map) {
                  replyText = data['content']['text'] ?? '';
                  imgUrl = data['content']['img'];
                } else {
                  replyText = data['content']?.toString() ?? '';
                }

                final reply = ChatMessage(
                  text: replyText,
                  user: chatbox,
                  createdAt: DateTime.parse(data['createdAt']),
                  customProperties: imgUrl != null ? {'img': imgUrl} : {},
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

Future<File?> sendImage(BuildContext context) async {
  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (picked == null) return null;
  return File(picked.path);
}
