#!/bin/bash

# Detiene todos los contenedores en ejecución o detenidos.
docker stop $(docker ps -q -a)

# Elimina todos los contenedores detenidos.
docker rm $(docker ps -q -a)

# Elimina todas las imágenes almacenadas localmente.
docker rmi $(docker images -q -a)

# Borra todas las imágenes sin etiqueta
docker image prune -a -f

#Borra todos los contenedores detenidos
docker container prune -f

#Borra todos los volúmenes no utilizadas
docker volume prune -a -f

#Borra todas las imágenes, contenedores y volúmenes no utilizados
docker system prune -a -f

#Borra el caché de compilación de Docker
docker builder prune -a -f
