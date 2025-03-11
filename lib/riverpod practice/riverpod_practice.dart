import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: RiverpodPractice()));
}

class RiverpodPractice extends StatelessWidget {
  const RiverpodPractice({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EasyRiverpod(),
    );
  }
}

class EasyRiverpod extends ConsumerWidget {
  const EasyRiverpod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(ref.watch(riverpodEasy).toString()),
            ElevatedButton(
                onPressed: () {
                  ref.read(riverpodEasy.notifier).state++;
                },
                child: Text('increase')),
            ElevatedButton(
                onPressed: () {
                  ref.read(riverpodEasy.notifier).state--;
                },
                child: Text('decrease')),
          ],
        ),
      ),
    );
  }
}

final riverpodEasy = StateProvider<int>((ref) {
  return 0;
});
