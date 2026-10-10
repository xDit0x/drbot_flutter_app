import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_learning/domain/entities/clinical/medical_center.dart';

class MedicalCenterCsv
{
  final AssetBundle _bundle;

  MedicalCenterCsv({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  Future<List<MedicalCenter>> loadHealthCenters()
  {
    return _loadFile('assets/data/medicalCenters.csv');
  }

  Future<List<MedicalCenter>> loadHospitals()
  {
    return _loadFile('assets/data/hospitals.csv');
  }

  Future<List<MedicalCenter>> _loadFile(String path) async
  {
    final data = await _bundle.load(path);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    final csv = _decode(bytes);
    final rows = _parseRows(csv);

    if(rows.isEmpty) { return []; }

    String normalizeHeader(String value)
    {
      return value.replaceFirst('\uFEFF', '').trim().toLowerCase().replaceAll('á', 'a').replaceAll('é', 'e')
      .replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');
    }

    final headers = rows.first.map(normalizeHeader).toList();

    int column(String name) => headers.indexOf(normalizeHeader(name));


    final codeColumn = column('Código de Centro Normalizado REGCESS (CCN)');
    final nameColumn = column('Nombre de Centro');
    final regionColumn = column('Comunidad Autónoma');
    final provinceColumn = column('Provincia');
    final municipalityColumn = column('Municipio');
    final typeColumn = column('Clase de Centro');
    final dependenceColumn = column('Dependencia Funcional');
    final insurerColumn = column('Aseguradoras');

    String valueAt(List<String> row, int index)
    {
      if(index < 0 || index >= row.length) { return ''; }
      return row[index].trim();
    }


    return rows.skip(1).map((row) 
    {
      final insurers = valueAt(row, insurerColumn).split(',').map((name) => name.trim().toUpperCase()).where((name) => name.isNotEmpty).toList();

      return MedicalCenter
      (
        code: valueAt(row, codeColumn),
        name: valueAt(row, nameColumn),
        region: valueAt(row, regionColumn),
        province: valueAt(row, provinceColumn),
        municipality: valueAt(row, municipalityColumn),
        type: valueAt(row, typeColumn),
        dependence: valueAt(row, dependenceColumn),
        insurers: insurers,
      );
    }).toList();
  }

  String _decode(List<int> bytes)
  {
    try
    {
      return utf8.decode(bytes).replaceFirst('\uFEFF', '');
    }
    catch(e)
    {
      return latin1.decode(bytes).replaceFirst('\uFEFF', '');
    }
  }

  List<List<String>> _parseRows(String csv)
  {
    final rows = <List<String>>[];
    var row = <String>[];
    var field = StringBuffer();
    var insideQuotes = false;

    final text = csv.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    for(var i = 0; i < text.length; i++)
    {
      final character = text[i];

      if(character == '"')
      {
        if(insideQuotes && i + 1 < text.length && text[i + 1] == '"')
        {
          field.write('"');
          i++;
        }
        else
        {
          insideQuotes = !insideQuotes;
        }
      }
      else if(!insideQuotes && character == ';')
      {
        row.add(field.toString());
        field = StringBuffer();
      }
      else if(!insideQuotes && character == '\n')
      {
        row.add(field.toString());
        rows.add(row);
        row = <String>[];
        field = StringBuffer();
      }
      else
      {
        field.write(character);
      }
    }

    if(field.isNotEmpty || row.isNotEmpty)
    {
      row.add(field.toString());
      rows.add(row);
    }

    return rows;
  }
}