import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  // Get -> Name
  Future<String> getName() async {
    try {
      final snapshot = await _databaseReference.child('app-data/name').get();
      return snapshot.exists ? snapshot.value.toString() : '';
    } catch (e) {
      print('Erro ao buscar nome do usuário: $e');
      return '';
    }
  }

  // Set -> Name
  Future<void> setName(String userName) async {
    try {
      await _databaseReference.child("app-data").set({
        'name': userName,
      });
      print('Nome do usuário salvo com sucesso.');
    } catch (e) {
      print('Erro ao salvar nome do usuário: $e');
    }
  }

  // Clear -> Name
  Future<void> clearName() async {
    try {
      await _databaseReference.child("app-data").remove();
      print('Nome do usuário limpo com sucesso.');
    } catch (e) {
      print('Erro ao limpar os nomes: $e');
    }
  }

  // Get -> Lado torto
  Future<Map<String, bool>> getLadoTorto() async {
    try {
      DatabaseEvent event = await _databaseReference.child('lado-torto').once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        return {
          'ladodireito': snapshot.child('ladodireito').value as bool,
          'ladoesquerdo': snapshot.child('ladoesquerdo').value as bool,
          'ladofrente': snapshot.child('ladofrente').value as bool,
          'ladotras': snapshot.child('ladotras').value as bool,
        };
      }
    } catch (e) {
      print('Erro ao buscar dados de lado torto: $e');
    }
    return {
      'ladodireito': false,
      'ladoesquerdo': false,
      'ladofrente': false,
      'ladotras': false,
    };
  }

  // Set -> Lado torto, para iniciar o APP
  Future<void> setLadoTortoFalse() async {
    try {
      await _databaseReference.child('lado-torto').set({
        'ladodireito': false,
        'ladoesquerdo': false,
        'ladofrente': false,
        'ladotras': false,
      });
      print('Dados do lado torto resetados com sucesso.');
    } catch (e) {
      print('Erro ao resetar dados do lado torto: $e');
    }
  }

  // Set -> Contagem do Lado Torto
  Future<void> setContLadoTorto(
      {Map<String, dynamic>? data, Map<String, int>? counts}) async {
    try {
      if (data != null) {
        await _databaseReference.child('app-data').set(data);
        print('Dados do usuário salvos com sucesso.');
      }
      if (counts != null) {
        await _databaseReference.child('app-data/cont-lado-torto').set(counts);
        print('Contagens de lado torto salvas com sucesso.');
      }
    } catch (e) {
      print('Erro ao salvar dados do usuário ou contagens de lado torto: $e');
    }
  }

  // Get -> Contagem do lado torto
  Future<Map<String, int>> getContLadoTorto() async {
    try {
      DatabaseEvent event =
          await _databaseReference.child('app-data/cont-lado-torto').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        return {
          'Direito': (snapshot.child('cont-ladodireito').value as int?) ?? 0,
          'Esquerdo': (snapshot.child('cont-ladoesquerdo').value as int?) ?? 0,
          'Frente': (snapshot.child('cont-ladofrente').value as int?) ?? 0,
          'Trás': (snapshot.child('cont-ladotras').value as int?) ?? 0,
        };
      }
    } catch (e) {
      print('Erro ao buscar contagens de lado torto: $e');
    }
    return {
      'Direito': 0,
      'Esquerdo': 0,
      'Frente': 0,
      'Trás': 0,
    };
  }
}
