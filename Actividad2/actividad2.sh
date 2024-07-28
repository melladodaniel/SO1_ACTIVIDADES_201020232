#!/bin/bash

# Leer la variable GITHUB_USER
GITHUB_USER="melladodaniel"

# Consultar la URL de la API de GitHub
RESPONSE=$(curl -s "https://api.github.com/users/$GITHUB_USER")

# Extraer los datos necesarios del JSON
USER_ID=$(echo $RESPONSE | jq -r '.id')
CREATED_AT=$(echo $RESPONSE | jq -r '.created_at')

# Imprimir el mensaje
MESSAGE="Hola $GITHUB_USER. User ID: $USER_ID. Cuenta fue creada el: $CREATED_AT."
echo $MESSAGE

# Obtener la ruta del script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Crear el archivo de log en la misma ubicación que el script
LOG_FILE="$SCRIPT_DIR/saludos_$(date +%Y-%m-%d).log"
echo $MESSAGE >> "$LOG_FILE"

