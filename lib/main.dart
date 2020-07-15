import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:state_notifier/state_notifier.dart';

final idProvider = Provider((_) => 0);
final counterStateProvider =
    StateNotifierProvider<CounterState>((ref) => CounterState(ref));

class CounterState extends StateNotifier<int> {
  final ProviderReference ref;
  CounterState(this.ref) : super(0);
  void increment() {
    state++;
  }

  // I actually do stuff with the id in my case
  int get id => ref.read(idProvider);
}

void main() {
  const deviceHeight = 700.0;
  const deviceWidth = 350.0;
  const numDevices = 2;
  runApp(
    ProviderScope(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: deviceWidth * (5 / 4) * numDevices,
            height: deviceHeight,
            child: ListView.separated(
              itemCount: 2,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) => SizedBox(
                width: deviceWidth,
                height: deviceHeight,
                child: ProviderScope(
                  // TODO: The goal would be to get rid of this and the need to override each provider individually
                  // Essentially the list of things that change per subtree (idProvider),
                  // is much smaller than the things that don't change, but depend on the idProvider
                  // (counterStateProvider + a lot of other state in my case)
                  overrides: [
                    idProvider.overrideAs(Provider((_) => i)),
                    counterStateProvider.overrideAs(
                        StateNotifierProvider((ref) => CounterState(ref))),
                  ],
                  child: MyApp(),
                ),
              ),
              separatorBuilder: (context, index) =>
                  const SizedBox(width: deviceWidth / 4, height: deviceHeight),
            ),
          ),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final provider = useProvider(counterStateProvider);
    final state = useProvider(counterStateProvider.state);
    return Scaffold(
      appBar: AppBar(
        title: Text('An app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You (${provider.id}) have pushed the button this many times:',
            ),
            Text(
              '$state',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: provider.increment,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
