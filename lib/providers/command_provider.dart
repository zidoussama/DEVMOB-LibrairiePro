import 'dart:async';

import 'package:flutter/foundation.dart';

import '../Models/command.dart';
import '../controllers/command_controller.dart';

class CommandProvider extends ChangeNotifier {
  final CommandController _controller;

  CommandProvider({CommandController? controller})
      : _controller = controller ?? CommandController();

  StreamSubscription<List<CommandModel>>? _commandsSub;
  List<CommandModel> _commands = <CommandModel>[];
  bool _isLoading = false;
  String? _error;
  String? _activeUserId;

  List<CommandModel> get commands => _commands;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenCommands(String userId) {
    if (_activeUserId == userId && _commandsSub != null) return;

    _commandsSub?.cancel();
    _activeUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    _commandsSub = _controller.fetchCommands(userId).listen(
      (items) {
        _commands = items;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> addCommand({
    required String userId,
    required CommandModel command,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _controller.createCommand(userId: userId, command: command);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCommand(CommandModel command) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _controller.updateCommand(userId: command.userId, command: command);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCommand({
    required String userId,
    required String commandId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _controller.deleteCommand(userId: userId, commandId: commandId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearCommands(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _controller.clearCommands(userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<CommandModel?> getCommandById({
    required String userId,
    required String commandId,
  }) async {
    try {
      return await _controller.getCommand(userId: userId, commandId: commandId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _commandsSub?.cancel();
    super.dispose();
  }
}