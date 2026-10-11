import 'package:flutter/material.dart';
import 'package:manocerca/core/models/chat_msg.dart';
import 'package:manocerca/core/models/pro.dart';
import 'package:manocerca/core/theme/app_theme.dart';
import 'package:manocerca/core/theme/colors.dart';
import 'package:manocerca/core/widgets/avatar.dart';

class ChatScreen extends StatefulWidget {
  final Pro pro;
  const ChatScreen({super.key, required this.pro});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMsg> _msgs = [
    ChatMsg('Hola, ¿en qué puedo ayudarte?', '10:24', false),
    ChatMsg('Hola, necesito una revisión de la instalación eléctrica en mi casa.',
        '10:25', true),
    ChatMsg('Claro, ¿para cuándo lo necesitas?', '10:26', false),
    ChatMsg('¿Podrías el sábado por la mañana?', '10:27', true),
    ChatMsg('Sí, perfecto. Te confirmo la hora.', '10:28', false),
  ];

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    final now = TimeOfDay.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    setState(() => _msgs.add(ChatMsg(t, time, true)));
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pro;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Avatar(name: p.name, size: 40),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Text('En línea', style: TextStyle(color: C.green, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: const [
          Icon(Icons.phone, color: C.primary),
          SizedBox(width: 14),
          Icon(Icons.more_horiz, color: C.primary),
          SizedBox(width: 14),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length,
              itemBuilder: (_, i) {
                final m = _msgs[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment:
                        m.mine ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!m.mine) ...[
                        Avatar(name: p.name, size: 30),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 260),
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                          decoration: BoxDecoration(
                            color: m.mine ? C.primary : C.card,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(m.mine ? 16 : 4),
                              bottomRight: Radius.circular(m.mine ? 4 : 16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.text,
                                  style: const TextStyle(fontSize: 14.5, height: 1.3)),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(m.time,
                                        style: TextStyle(
                                            fontSize: 10.5,
                                            color: m.mine
                                                ? Colors.white70
                                                : C.muted)),
                                    if (m.mine) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.done_all,
                                          size: 14, color: Colors.white70),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: C.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      onSubmitted: (_) => _send(),
                      decoration: inputDeco('Escribe un mensaje...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                          color: C.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
