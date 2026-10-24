import 'package:flutter/material.dart';

import '../data/devices.dart';
import '../logic/commands.dart';
import '../state/home_controller.dart';
import '../widgets/controls.dart';

class VoiceSheet extends StatefulWidget {
  const VoiceSheet({super.key, required this.controller});

  final HomeController controller;

  @override
  State<VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends State<VoiceSheet> {
  final TextEditingController _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _run(String text) {
    if (text.trim().isEmpty) return;
    widget.controller.run(text);
    _input.clear();
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final height = (MediaQuery.sizeOf(context).height - bottom) * 0.92;
    final latest = c.results.isEmpty ? null : c.results.first;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: height,
        child: Container(
          decoration: const BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFE1E5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Voice control',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                              color: kInk,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Type a command. Same rules as the assistant.',
                            style: TextStyle(fontSize: 11.5, color: kMuted),
                          ),
                        ],
                      ),
                    ),
                    RoundIconButton(
                      icon: Icons.close,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _input,
                        textInputAction: TextInputAction.done,
                        onSubmitted: _run,
                        decoration: InputDecoration(
                          hintText: 'turn on the kitchen lights',
                          hintStyle: const TextStyle(
                              fontSize: 13, color: kMuted),
                          prefixIcon:
                              const Icon(Icons.mic_none, size: 20),
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                          filled: true,
                          fillColor: const Color(0xFFFAFBFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: kLine),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: kLine),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: kAccent),
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _run(_input.text),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 15),
                        decoration: BoxDecoration(
                          color: kInk,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Run',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: latest == null
                    ? const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Try 'turn on the bedroom lights' or pick a command below.",
                          style:
                              TextStyle(fontSize: 12, color: kMuted),
                        ),
                      )
                    : _ResultCard(result: latest),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 14, 18, 6),
                child: Divider(height: 1, color: kLine),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  children: <Widget>[
                    ...commandGroups.expand((group) {
                      return <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 14, bottom: 8),
                          child: Text(
                            group.title.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.7,
                              color: kMuted,
                            ),
                          ),
                        ),
                        ...group.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _CommandTile(
                              item: item,
                              onTap: () => _run(item.phrase),
                            ),
                          );
                        }),
                      ];
                    }),
                    const Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: Text(
                        'Spoken input runs through assistant.py with Whisper. '
                        'This panel runs the same 59 rules on the demo home.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.5,
                          color: kMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final CommandResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: result.ok ? kAccentSoft : const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                result.ok ? Icons.check : Icons.close,
                size: 15,
                color: result.ok ? kAccentDeep : kMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.text,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
          if (result.action.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.action,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: kInkSoft,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommandTile extends StatelessWidget {
  const _CommandTile({required this.item, required this.onTap});

  final CommandItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kLine),
        ),
        child: Row(
          children: <Widget>[
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kInk,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.phrase,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, color: kMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
