## Script en Bash

```bash
#!/bin/bash

GITHUB_USER="melladodaniel"

RESPONSE=$(curl -s "https://api.github.com/users/$GITHUB_USER")

USER_ID=$(echo $RESPONSE | jq -r '.id')
CREATED_AT=$(echo $RESPONSE | jq -r '.created_at')

MESSAGE="Hola $GITHUB_USER. User ID: $USER_ID. Cuenta fue creada el: $CREATED_AT."
echo $MESSAGE

SCRIPT_DIR=$(dirname "$(realpath "$0")")

LOG_FILE="$SCRIPT_DIR/saludos_$(date +%Y-%m-%d).log"
echo $MESSAGE >> "$LOG_FILE"
```
## Creación del cronjob

1. Abrir el archivo Crontab

```bash
crontab -e
```

2. Añadir la siguiente línea al final del archivo

```bash
*/5 * * * * /ruta/al/script/actividad2.sh
``` 

## Instalación y Configuración

1. Guardar el script en un archivo, por ejemplo, actividad2.sh

2. Dar permisos de ejecución al script:

```bash
chmod +x /ruta/al/script/actividad2.sh
``` 

3. Asegurarse de tener instalado jq para procesar el JSON de la API de GitHub. Puedes instalarse con:

```bash
sudo apt-get install jq
```

## Nota

* El script creará un archivo de log con el nombre saludos_fecha.log en la misma ubicación donde se encuentra el script.
