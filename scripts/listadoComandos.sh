#!/usr/bin/env bash
# =============================================================================
# Listado de comandos Docker del README (57 comandos)
# Proyecto: Biblioteca con Docker - MySQL + Node.js
#
# Los comandos van en una sola linea para que funcionen igual
# en PowerShell, CMD y Bash.
# =============================================================================

# -----------------------------------------------------------------------------
# ESCENA 1: Instalacion de Docker Desktop y primeros comandos
# Descarga Docker Desktop desde docker.com, ejecuta el instalador, reinicia si
# lo solicita, abre Docker Desktop, espera el estado "Engine running" y abre la
# consola.
# -----------------------------------------------------------------------------
docker --version                      # 1
docker version                        # 2
docker info                           # 3
docker run hello-world                # 4  descarga la imagen y crea un contenedor
docker ps                             # 5  contenedores en ejecucion (vacio)
docker ps -a                          # 6  se ve hello-world en estado "Exited"
docker images                         # 7  se ve la imagen hello-world

# -----------------------------------------------------------------------------
# ESCENA 2: Crear y eliminar una imagen y un contenedor
# -----------------------------------------------------------------------------
docker pull alpine                                  # 8  descargar una imagen
docker run -it --name prueba alpine /bin/sh         # 9  contenedor interactivo (escribe `exit` para salir)
docker ps -a                                        # 10 localizar el ID/nombre
docker rm prueba                                    # 11 eliminar el contenedor detenido
docker rm $(docker ps -q -a)                        # 12 eliminar todos los contenedores (hello-world)
docker rmi hello-world                              # 13 eliminar la imagen por nombre
docker images                                       # 14 verificar que solo queda alpine

# -----------------------------------------------------------------------------
# ESCENA 3: Red y volumen
# -----------------------------------------------------------------------------
docker network create mi_red_bridge                 # 15 red bridge personalizada
docker network ls                                   # 16
docker volume create mysql_data                     # 17 volumen para que los datos persistan

# -----------------------------------------------------------------------------
# ESCENA 4: Imagen de la base de datos (MySQL) y contenedor
# -----------------------------------------------------------------------------
docker build -t mscamarodriguezg/mysql-biblioteca:1.0 ./db                                  # 18 construir imagen de BD
docker run -d --network mi_red_bridge --name mysql-db -e MYSQL_ROOT_PASSWORD=Clave123 -v mysql_data:/var/lib/mysql mscamarodriguezg/mysql-biblioteca:1.0   # 19
docker logs mysql-db                                # 20 esperar "ready for connections"
docker exec -it mysql-db mysql -uroot -pClave123 biblioteca    # 21 entrar al cliente MySQL

# Dentro de MySQL (escribe `exit` al terminar):
#   SHOW TABLES;
#   DESCRIBE autores;
#   DESCRIBE libros;
#   SELECT id, nombre, pais FROM autores;
#   -- Demostrar la dependencia entre tablas (falla porque no existe el autor 99):
#   INSERT INTO libros (autor_id,titulo,isbn,fecha_publicacion,precio) VALUES (99,'Prueba','1234567890123','2024-01-01',10);

# -----------------------------------------------------------------------------
# ESCENA 5: Imagen del servidor web (Node.js) y despliegue
# -----------------------------------------------------------------------------
docker build -t mscamarodriguezg/sitioweb:latest ./web         # 22 construir imagen del servidor
docker images                                                  # 23 se ven mysql-biblioteca y sitioweb
docker run -d -p 8080:3000 --network mi_red_bridge --name servidor-web -e DB_HOST=mysql-db -e DB_PASSWORD=Clave123 mscamarodriguezg/sitioweb:latest   # 24
docker ps                                                      # 25 ambos contenedores corriendo
docker logs servidor-web                                       # 26 "Servidor listo en el puerto 3000"
docker port servidor-web                                       # 27 puerto 3000 -> 8080 del host

# Abrir http://localhost:8080 y mostrar que la pagina (con la imagen/logo) la
# sirve el contenedor, con el ID del contenedor en el pie de pagina.

# Variante con puertos automaticos:
docker run -d -P --network mi_red_bridge --name servidor-web-auto -e DB_HOST=mysql-db -e DB_PASSWORD=Clave123 mscamarodriguezg/sitioweb:latest   # 28
docker port servidor-web-auto                                  # 29 muestra el puerto aleatorio asignado

# Prueba entre contenedores por nombre (DNS de la red):
docker run -it --network mi_red_bridge --name cliente alpine /bin/sh      # 30
# Dentro del contenedor, luego `exit`:
#   wget -qO- http://servidor-web:3000/libros | head -n 15

# -----------------------------------------------------------------------------
# ESCENA 6: Ingreso de 15 datos y verificacion
# 1. En http://localhost:8080 registrar 15 libros con el formulario (ISBN de 13
#    digitos, por ejemplo 9780000000001 al 9780000000015). Cada guardado
#    redirige a /libros.
# 2. Abrir http://localhost:8080/libros: deben aparecer los 15 registros y el
#    titulo debe indicar "(15)".
# 3. Verificar en el contenedor de la BD que los datos estan guardados:
# -----------------------------------------------------------------------------
docker exec mysql-db mysql -uroot -pClave123 -e "SELECT COUNT(*) AS total FROM libros;" biblioteca      # 31
docker exec -it mysql-db mysql -uroot -pClave123 -e "SELECT l.id,l.titulo,a.nombre FROM libros l JOIN autores a ON a.id=l.autor_id;" biblioteca   # 32
docker exec -it mysql-db /bin/bash                                  # 33 shell dentro del contenedor (`exit` para salir)

# -----------------------------------------------------------------------------
# ESCENA 7: Evidenciar el uso del contenedor
# -----------------------------------------------------------------------------
docker ps                                           # 34
docker stats --no-stream                            # 35 CPU y memoria de cada contenedor
docker top servidor-web                             # 36 procesos dentro del contenedor (node server.js)
docker inspect servidor-web --format "{{.NetworkSettings.Networks.mi_red_bridge.IPAddress}}"   # 37 IP en la red
docker network inspect mi_red_bridge                # 38 contenedores conectados
docker history mscamarodriguezg/sitioweb:latest     # 39 capas de la imagen
docker cp mysql-db:/docker-entrypoint-initdb.d/init.sql ./init_copia.sql      # 40 copiar archivo desde el contenedor

# Persistencia de datos:
docker restart mysql-db                             # 41
docker stop servidor-web                            # 42
docker start servidor-web                           # 43 recargar /libros: los 15 datos siguen ahi

# -----------------------------------------------------------------------------
# ESCENA 8: Publicar las imagenes en Docker Hub
# Docker Hub gratuito permite repositorios publicos ilimitados y uno privado.
# -----------------------------------------------------------------------------
docker login                                                                          # 44
docker tag mscamarodriguezg/sitioweb:latest mscamarodriguezg/sitioweb:1.0             # 45
docker push mscamarodriguezg/sitioweb:latest                                          # 46
docker push mscamarodriguezg/mysql-biblioteca:1.0                                     # 47

# -----------------------------------------------------------------------------
# ESCENA 9: Limpieza (adaptada de borraTodo.sh)
# ADVERTENCIA: Estos comandos eliminan TODOS los contenedores, imagenes y
# volumenes del equipo, no solo los de este proyecto. Usalos unicamente al
# final y si no tienes otros proyectos Docker que conservar. Si aparece el error
# "requires at least 1 argument", significa que ya no hay contenedores o
# imagenes que borrar y es inofensivo.
# -----------------------------------------------------------------------------
docker system df                                    # 48 espacio usado
docker stop $(docker ps -q -a)                      # 49 detener todos
docker rm $(docker ps -q -a)                        # 50 eliminar todos los contenedores
docker rmi $(docker images -q -a)                   # 51 eliminar todas las imagenes
docker image prune -a -f                            # 52 imagenes sin uso
docker container prune -f                           # 53 contenedores detenidos
docker volume prune -a -f                           # 54 volumenes sin uso (borra mysql_data)
docker system prune -a -f                           # 55 todo lo no usado
docker builder prune -a -f                          # 56 cache de compilacion
docker ps -a ; docker images ; docker volume ls     # 57 todo vacio
