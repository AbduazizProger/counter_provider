import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class User {
  final int num;

  User(this.num);

  User copyWith({
    int? num,
  }) {
    return User(
      num ?? this.num,
    );
  }
}

class NumService {
  var _user = User(0);
  User get user => _user;

  NumService() {
    loadValue();
  }

  Future<void> loadValue() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final num = sharedPreferences.getInt('num') ?? 0;
    _user = User(num);
  }

  void saveValue() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt('num', _user.num);
  }

  void incrementNum() {
    _user = _user.copyWith(num: _user.num + 1);
  }

  void decrementNum() {
    _user = _user.copyWith(num: _user.num - 1);
  }
}

class ViewModelState {
  final String ageTitle;

  ViewModelState({required this.ageTitle});
}

class ViewModel extends ChangeNotifier {
  final _numService = NumService();

  var _state = ViewModelState(ageTitle: '');
  ViewModelState get state => _state;

  ViewModel() {
    loadValue();
  }

  Future<void> loadValue() async {
    await _numService.loadValue();
    updateState();
  }

  Future<void> onIncrementButtonPressed() async {
    _numService.incrementNum();
    updateState();
  }

  Future<void> onDecrementButtonPressed() async {
    _numService.decrementNum();
    updateState();
  }

  void updateState() {
    final user = _numService._user;
    _state = ViewModelState(ageTitle: _numService._user.num.toString());
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (context) => ViewModel(),
        child: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _NumWidget(),
            _IncrementWidget(),
            _DecrementWidget(),
          ],
        ),
      ),
    );
  }
}

class _NumWidget extends StatelessWidget {
  const _NumWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final title = context.select((ViewModel vm) => vm.state.ageTitle);
    return Text(
      title,
      style: const TextStyle(fontSize: 20),
    );
  }
}

class _IncrementWidget extends StatelessWidget {
  const _IncrementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ViewModel>();
    return ElevatedButton(
      onPressed: viewModel.onIncrementButtonPressed,
      child: const Text("+"),
    );
  }
}

class _DecrementWidget extends StatelessWidget {
  const _DecrementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ViewModel>();
    return ElevatedButton(
      onPressed: viewModel.onDecrementButtonPressed,
      child: const Text("-"),
    );
  }
}
