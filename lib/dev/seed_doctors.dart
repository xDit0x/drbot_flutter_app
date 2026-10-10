import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class SeedResult {
  final int created;
  final List<String> warnings;
  const SeedResult({required this.created, required this.warnings});
}

class DoctorsSeeder {
  final AssetBundle _bundle;
  final FirebaseFirestore _firestore;

  DoctorsSeeder({AssetBundle? bundle, FirebaseFirestore? firestore})
    : _bundle = bundle ?? rootBundle,
      _firestore = firestore ?? FirebaseFirestore.instance;

  static const List<String> _days = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  Future<SeedResult> seed() async {
    final hospitals = await _loadCsv('assets/data/hospitals.csv');
    final doctors = await _loadCsv('assets/data/doctors.csv');

    final centerByCode = <String, _Center>{};
    for (final r in hospitals.rows) {
      final code = _at(
        r,
        hospitals.col('Código de Centro Normalizado REGCESS (CCN)'),
      );
      centerByCode[code] = _Center(
        name: _at(r, hospitals.col('Nombre de Centro')),
        region: _at(r, hospitals.col('Comunidad Autónoma')),
        insurers: _insurers(_at(r, hospitals.col('Aseguradoras'))),
      );
    }

    final warnings = <String>[];
    var batch = _firestore.batch();
    var pending = 0;
    var created = 0;

    for (final r in doctors.rows) {
      final centerCode = _at(r, doctors.col('centerCode'));
      final name = _at(r, doctors.col('name'));
      if (centerCode.isEmpty || name.isEmpty) {
        continue;
      }

      final center = centerByCode[centerCode];
      if (center == null) {
        warnings.add('$name: centerCode $centerCode no está en hospitals.csv');
      }

      final insurers = _insurers(_at(r, doctors.col('insurers')));
      final centerInsurers = center?.insurers ?? const <String>[];
      if (insurers.any((i) => !centerInsurers.contains(i))) {
        warnings.add('$name: insurers fuera del concierto de $centerCode');
      }

      final weekly = <String, dynamic>{};
      for (final day in _days) {
        weekly[day] = _shifts(_at(r, doctors.col(day)));
      }

      final id = '${centerCode}_${_slug(name)}';
      batch.set(_firestore.collection('Doctors').doc(id), {
        'name': name,
        'specialty': _at(r, doctors.col('specialty')),
        'insurers': insurers,
        'centerCode': centerCode,
        'centerName': center?.name ?? '',
        'region': center?.region ?? '',
        'slotMinutes': int.tryParse(_at(r, doctors.col('slotMinutes'))) ?? 20,
        'weekly': weekly,
      }, SetOptions(merge: true));
      created++;

      if (++pending >= 400) {
        await batch.commit();
        batch = _firestore.batch();
        pending = 0;
      }
    }
    if (pending > 0) {
      await batch.commit();
    }

    return SeedResult(created: created, warnings: warnings);
  }

  List<Map<String, String>> _shifts(String cell) {
    if (cell.trim().isEmpty) {
      return const [];
    }
    return cell.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).map((
      t,
    ) {
      final parts = t.split('-');
      return {
        'start': parts.first.trim(),
        'end': parts.length > 1 ? parts[1].trim() : '',
      };
    }).toList();
  }

  List<String> _insurers(String cell) {
    return cell
        .split(',')
        .map((s) => s.trim().toUpperCase())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String _slug(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String _at(List<String> row, int index) {
    if (index < 0 || index >= row.length) {
      return '';
    }
    return row[index].trim();
  }

  Future<_Csv> _loadCsv(String path) async {
    final data = await _bundle.load(path);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final rows = _parseRows(_decode(bytes));
    final headers = rows.first.map(_normalize).toList();
    int column(String name) => headers.indexOf(_normalize(name));
    return _Csv(
      rows: rows
          .skip(1)
          .where((r) => r.any((c) => c.trim().isNotEmpty))
          .toList(),
      col: column,
    );
  }

  String _normalize(String value) {
    return value
        .replaceFirst('\uFEFF', '')
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  String _decode(List<int> bytes) {
    try {
      return utf8.decode(bytes).replaceFirst('\uFEFF', '');
    } catch (_) {
      return latin1.decode(bytes).replaceFirst('\uFEFF', '');
    }
  }

  List<List<String>> _parseRows(String csv) {
    final rows = <List<String>>[];
    var row = <String>[];
    var field = StringBuffer();
    var insideQuotes = false;

    final text = csv.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    for (var i = 0; i < text.length; i++) {
      final character = text[i];

      if (character == '"') {
        if (insideQuotes && i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          insideQuotes = !insideQuotes;
        }
      } else if (!insideQuotes && character == ';') {
        row.add(field.toString());
        field = StringBuffer();
      } else if (!insideQuotes && character == '\n') {
        row.add(field.toString());
        rows.add(row);
        row = <String>[];
        field = StringBuffer();
      } else {
        field.write(character);
      }
    }

    if (field.isNotEmpty || row.isNotEmpty) {
      row.add(field.toString());
      rows.add(row);
    }

    return rows;
  }
}

class _Csv {
  final List<List<String>> rows;
  final int Function(String) col;
  const _Csv({required this.rows, required this.col});
}

class _Center {
  final String name;
  final String region;
  final List<String> insurers;
  const _Center({
    required this.name,
    required this.region,
    required this.insurers,
  });
}
