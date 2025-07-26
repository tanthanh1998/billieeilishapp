import 'package:flutter/material.dart';

class PlaySong extends StatefulWidget {
  const PlaySong({super.key});

  @override
  State<PlaySong> createState() => _PlaySongState();
}

class _PlaySongState extends State<PlaySong> {
  @override
  Widget build(BuildContext context) {
    return const Text('Play Song');
  }
}
