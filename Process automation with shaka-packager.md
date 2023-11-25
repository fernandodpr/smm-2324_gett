# Process automation with shaka-packager
## Preparación
### 1. Árbore de directorios
`/home/martina/Documents/teleco23-24/cuatri_1/SMM/proxecto/shaka-packager-testing/media/` é a ubicación do directorio no que teremos os ficheiros que queremos porcesar.

### 2. Lanzar docker do shaka-packager
`docker run -v /home/martina/Documents/teleco23-24/cuatri_1/SMM/proxecto/shaka-packager-testing/media/:/media --name shaka-packager-container -it --rm google/shaka-packager`

Non atopo xeito de lanzalo e que quede correndo sen ter que iniciar a súa terminal (-it).

### 3. Script shaka-packager.sh

#### Engadir ao contenedor
Nunha terminal distinta e estando ubicados onde temos o script shaka-packager.sh en local executamos os seguintes comandos:

`docker cp ./shaka-packager.sh shaka-packager-container:shaka-packager.sh`
#### Permisos
`docker exec shaka-packager-container chmod +x shaka-packager.sh`


