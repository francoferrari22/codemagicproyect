# FerrariPOS Mobile + API + CodeMagic

Arquitectura preparada a partir del FerrariPOS existente.

FerrariPOS Desktop (.NET 8 + SQLite) -> FerrariPOS.Api (.NET 8, lectura segura) -> FerrariPOS Mobile (Flutter/Android).

## Estructura
- `mobile/`: aplicación Flutter Android.
- `api/`: API puente .NET 8 para consultar `FerrarisPOS.db`.
- `codemagic.yaml`: pipeline oficial de CodeMagic para APK release.

## Flujo recomendado
1. PC con FerrariPOS: ejecuta `FerrariPOS.Api` y apunta a la SQLite real.
2. Router/red local: permite TCP 5080 solamente en la LAN.
3. Teléfono Android: en Configuración coloca `http://IP-DE-LA-PC:5080`.
4. CodeMagic: conecta el repositorio, detecta `codemagic.yaml` y ejecuta el workflow `FerrariPOS Mobile Android`.

## Seguridad antes de producción
- Cambiar el secreto JWT.
- Sustituir la contraseña temporal por el mismo verificador de hashes de FerrariPOS.
- Usar HTTPS mediante reverse proxy/VPN cuando el teléfono esté fuera de la LAN.
- Mantener SQLite en la PC y evitar acceso remoto directo al archivo.
- Para escritura desde móvil, agregar endpoints transaccionales, roles y auditoría antes de habilitarlos.
