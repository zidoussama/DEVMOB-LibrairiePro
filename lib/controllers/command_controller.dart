import '../Models/command.dart';
import '../services/command_service.dart';

class CommandController {
  final CommandService _service = CommandService();

  Stream<List<CommandModel>> fetchCommands(String userId) {
    if (userId.trim().isEmpty) {
      throw Exception('L\'identifiant utilisateur est obligatoire');
    }
    return _service.getCommands(userId);
  }

  Future<CommandModel?> getCommand({
    required String userId,
    required String commandId,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('L\'identifiant utilisateur est obligatoire');
    }
    if (commandId.trim().isEmpty) {
      throw Exception('L\'identifiant de la commande est obligatoire');
    }
    return _service.getCommandById(userId: userId, commandId: commandId);
  }

  Future<String> createCommand({
    required String userId,
    required CommandModel command,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('L\'identifiant utilisateur est obligatoire');
    }
    if (command.items.isEmpty) {
      throw Exception('La commande doit contenir au moins un article');
    }
    if (command.total <= 0) {
      throw Exception('Le total de la commande doit être supérieur à 0');
    }
    return _service.addCommand(userId: userId, command: command);
  }

  Future<void> updateCommand({
    required String userId,
    required CommandModel command,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('L\'identifiant utilisateur est obligatoire');
    }
    if (command.id.trim().isEmpty) {
      throw Exception('L\'identifiant de la commande est obligatoire');
    }
    await _service.updateCommand(userId: userId, command: command);
  }

  Future<void> deleteCommand({
    required String userId,
    required String commandId,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('L\'identifiant utilisateur est obligatoire');
    }
    if (commandId.trim().isEmpty) {
      throw Exception('L\'identifiant de la commande est obligatoire');
    }
    await _service.deleteCommand(userId: userId, commandId: commandId);
  }

  Future<void> clearCommands(String userId) async {
    if (userId.trim().isEmpty) {
      throw Exception('L\'identifiant utilisateur est obligatoire');
    }
    await _service.clearCommands(userId);
  }
}