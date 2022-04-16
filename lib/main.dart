import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => ObjectProvider(),
    child: MaterialApp(
      title: "Providers Detail",
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    ),
  ));
}

@immutable
class BaseObject {
  final String id;
  final String lastUpdated;

  BaseObject()
      : id = const Uuid().v4(),
        lastUpdated = DateTime.now().toIso8601String();
  @override
  bool operator ==(covariant BaseObject other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class ExpensiveObject extends BaseObject {}

@immutable
class CheapObject extends BaseObject {}

class ObjectProvider extends ChangeNotifier {
  late String id;
  late CheapObject _cheapObject;
  late StreamSubscription _cheapObjectStreamSubs;
  late ExpensiveObject _expensiveObject;
  late StreamSubscription _expensiveObjectStreamSubs;

  CheapObject get cheapObject => _cheapObject;
  ExpensiveObject get expensiveObject => _expensiveObject;

  ObjectProvider()
      : id = const Uuid().v4(),
        _cheapObject = CheapObject(),
        _expensiveObject = ExpensiveObject() {
    start();
  }

  @override
  void notifyListeners() {
    id = const Uuid().v4();
    super.notifyListeners();
  }

  void start() {
    _cheapObjectStreamSubs = Stream.periodic(
      const Duration(
        seconds: 1,
      ),
    ).listen((_) {
      _cheapObject = CheapObject();
      notifyListeners();
    });
    _expensiveObjectStreamSubs = Stream.periodic(
      const Duration(
        seconds: 10,
      ),
    ).listen((_) {
      _expensiveObject = ExpensiveObject();
      notifyListeners();
    });
  }

  void stop() {
    _cheapObjectStreamSubs.cancel();
    _expensiveObjectStreamSubs.cancel();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            children: const [
              Expanded(flex: 1, child: CheapWidget()),
              Expanded(flex: 1, child: ExpensiveWidget()),
            ],
          ),
          Row(
            children: const [
              Expanded(flex: 1, child: ObjectProviderWidget()),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context.read<ObjectProvider>().stop();
                },
                child: const Text("Stop"),
              ),
              TextButton(
                onPressed: () {
                  context.read<ObjectProvider>().start();
                },
                child: const Text("Start"),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CheapWidget extends StatelessWidget {
  const CheapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cheapObject = context.select<ObjectProvider, CheapObject>(
        (provider) => provider.cheapObject);
    return Container(
      height: 100,
      color: Colors.yellow,
      child: Column(
        children: [
          const Text("Cheap Widget"),
          const Text("Last Updated"),
          Text(cheapObject.lastUpdated)
        ],
      ),
    );
  }
}

class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expensiveObject = context.select<ObjectProvider, ExpensiveObject>(
        (provider) => provider.expensiveObject);
    return Container(
      height: 100,
      color: Colors.blue,
      child: Column(
        children: [
          const Text("Expensive Widget"),
          const Text("Last Updated"),
          Text(expensiveObject.lastUpdated)
        ],
      ),
    );
  }
}

class ObjectProviderWidget extends StatelessWidget {
  const ObjectProviderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObjectProvider>();
    return Container(
      height: 100,
      color: Colors.purple,
      child: Column(
        children: [
          const Text("Object Provider"),
          const Text("ID"),
          Text(provider.id)
        ],
      ),
    );
  }
}
