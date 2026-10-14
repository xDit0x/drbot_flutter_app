from pathlib import Path
import pandas as pd

# Carpeta donde está este script y los Excel
carpeta_entrada = Path(__file__).resolve().parent
categoria = carpeta_entrada.name

archivo_excel_salida = carpeta_entrada / f"{categoria}_unificado.xlsx"
archivo_csv_salida = carpeta_entrada / f"{categoria}.csv"

tablas = []

for archivo in sorted(carpeta_entrada.iterdir()):
    extension = archivo.suffix.lower()

    if extension not in {".xlsx", ".xlsm", ".xls"}:
        continue

    # Evita volver a leer el Excel unificado si ejecutas el script otra vez
    if archivo.name == archivo_excel_salida.name:
        continue

    motor = "xlrd" if extension == ".xls" else "openpyxl"

    hojas = pd.read_excel(
        archivo,
        sheet_name=None,  # Lee todas las hojas del Excel
        dtype=str,
        engine=motor,
    )

    for tabla in hojas.values():
        tabla = tabla.dropna(how="all")

        if not tabla.empty:
            tablas.append(tabla)

if not tablas:
    raise RuntimeError(f"No se encontraron datos Excel en {carpeta_entrada}")

resultado = pd.concat(tablas, ignore_index=True, sort=False)

# Guarda primero un Excel con todos los datos unidos
resultado.to_excel(
    archivo_excel_salida,
    index=False,
    sheet_name="Datos",
)

# Genera el CSV usando punto y coma como separador
resultado.to_csv(
    archivo_csv_salida,
    index=False,
    sep=";",
    encoding="utf-8-sig",
)

print(f"Excel unificado: {archivo_excel_salida}")
print(f"CSV creado: {archivo_csv_salida}")
print(f"Filas combinadas: {len(resultado)}")