# FerrariPOS API

API puente para que FerrariPOS Mobile consulte la SQLite local de FerrariPOS sin exponer el archivo `.db` directamente.

## Configuración
1. Instalar .NET 8 Runtime/SDK en la PC donde está FerrariPOS.
2. Definir `FerrariPOS__DatabasePath` con la ruta absoluta de `FerrarisPOS.db`.
3. Definir `Jwt__Key` con un secreto largo y aleatorio.
4. Para esta primera base técnica, definir `FERRARIPOS_MOBILE_DEV_PASSWORD` y luego reemplazar la validación temporal por la misma rutina de hash que usa `LoginForm`/`Session` de FerrariPOS.
5. Ejecutar `dotnet run --urls http://0.0.0.0:5080`.

**Importante:** el API está diseñado inicialmente en modo lectura (`Mode=ReadOnly`) para no modificar la base de producción. Las operaciones de escritura se agregan después con endpoints transaccionales y auditoría.
