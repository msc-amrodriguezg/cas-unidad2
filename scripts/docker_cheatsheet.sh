# Lista todos los contenedores en ejecución en el sistema.
docker ps

# Detiene un contenedor en ejecución especificando su ID o nombre.
docker stop (container id)

# Elimina un contenedor detenido especificando su ID o nombre.
docker rm (container id)

# Muestra todas las imágenes de Docker almacenadas localmente.
docker images

# Elimina una imagen de Docker especificando su repositorio o ID.
docker rmi (image repository)

# Construye una nueva imagen de Docker a partir de un Dockerfile en el directorio actual y la etiqueta con un nombre y versión.
docker build -t anmrodriguezga/sitioweb:latest .

# Sube la imagen etiquetada al repositorio de Docker Hub.
docker push anmrodriguezga/sitioweb:latest

# Crea una red personalizada de tipo "bridge" llamada `mi_red_bridge`.
docker network create mi_red_bridge

# Ejecuta un contenedor en segundo plano (modo "detached") en la red `mi_red_bridge` con el nombre `servidor-web` usando la imagen `nginx`.
docker run -d --network mi_red_bridge --name servidor-web nginx

# Ejecuta un contenedor interactivo en la red `mi_red_bridge` con el nombre `cliente` usando la imagen `alpine` y abre un shell dentro del contenedor.
docker run -it --network mi_red_bridge --name cliente alpine /bin/sh

# Ejecuta un contenedor en segundo plano (modo "detached") mapeando el puerto 8080 del host al puerto 80 del contenedor, con el nombre `mi-nginx` y usando la imagen `nginx:latest`.
docker run -d -p 8080:80 --name mi-nginx nginx:latest

# Abre una sesión interactiva dentro de un contenedor en ejecución especificando su ID (en este caso, `c35e2066f028`) y accede al shell bash.
docker exec -it c35e2066f028 /bin/bash

# Ejecuta un contenedor en segundo plano (modo "detached") asignando automáticamente puertos del host, con el nombre `mi-nginx-4` y usando la imagen `nginx:latest`.
docker run -d -P --name mi-nginx-4 nginx:latest

# Muestra los puertos asignados automáticamente al contenedor `mi-nginx-4` en el host.
docker port mi-nginx-4

# Detiene todos los contenedores en ejecución o detenidos.
docker stop $(docker ps -q -a)

# Elimina todos los contenedores detenidos.
docker rm $(docker ps -q -a)

# Elimina todas las imágenes almacenadas localmente.
docker rmi $(docker images -q -a)

# Borra todas las imágenes sin etiqueta
docker image prune -a

#Borra todos los contenedores detenidos
docker container prune

#Borra todos los volúmenes no utilizadas
docker volume prune

#Borra todas las imágenes, contenedores y volúmenes no utilizados
docker system prune

#Borra el caché de compilación de Docker
docker builder prune