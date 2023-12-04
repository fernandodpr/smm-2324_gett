#!/bin/bash

directorio="./ingest"  # Reemplaza con la ruta de tu directorio
archivos_procesados=()

while true;
do
    if [ "$(ls -A "$directorio")" ]; then

        for archivo in "$directorio"/*; do

            nombre_con_extension=$(basename "$archivo")
            nombre_sin_extension=$(basename -- "$nombre_con_extension" | cut -f 1 -d '.')

            
            # Agrega aquí las acciones que deseas realizar cuando se detecta un nuevo archivo
            nombre_mpd="${nombre_sin_extension}.mpd"

            ## cambio de calidades
            # Video a 144p
            ffmpeg -i "$directorio"/"${nombre_con_extension}" -c:v libx264 -vf "scale=256:144" -crf 35 -c:a aac -b:a 48k "./ingest/${nombre_sin_extension}_144p.mp4"
            nombre_ext_144="${nombre_sin_extension}_144p.mp4"
            nombre_sin_ext_144="${nombre_sin_extension}_144"
            nombre_mpd_144="${nombre_sin_extension}_144p.mpd"
            
            sleep 1
            # Video al 50% de la calidad original
            #ffmpeg -i "$directorio"/"${nombre_con_extension}" -c:v libx264 -crf 23 -vf "scale=iw*0.5:ih*0.5" -c:a aac -b:a 128k "./ingest/${nombre_sin_extension}_50percent_quality.mp4"
            #   ffmpeg -i "$directorio"/"${nombre_con_extension}" -c:v libx264 -crf 23 -vf "scale=iw*0.5:ih*0.5:flags=lanczos+full_chroma_inp+full_chroma_int,format=yuv420p" -c:a aac -b:a 128k "./ingest/${nombre_sin_extension}_50percent_quality.mp4"
ffmpeg -i "$directorio"/"${nombre_con_extension}" \
-c:v libx264 -crf 23 \
-vf "scale='trunc(iw/2)*2:trunc(ih/2)*2'" \
-c:a aac -b:a 128k "./ingest/${nombre_sin_extension}_50percent_quality.mp4"

            
            
            
            nombre_ext_50="${nombre_sin_extension}_50percent_quality.mp4"
            nombre_sin_ext_50="${nombre_sin_extension}_50percent_quality"
            nombre_mpd_50="${nombre_sin_extension}_50percent_quality.mpd"

            sleep 1
            # Comando Shaka Packager
            # Habría que hacer que meta los archivos procesados ya en /webmedia, ya le he pasado al contenedor esa ruta dejar los archivos de salida en:
            # "/webmedia"

            # Todo esto hay que meterlo en una sola línea, volver a ver referencia en Discord del ejemplo que pasé de windows.
            # La idea es tener un sólo manifest con todos los videos dentro, shacka ya es después capaz de indetificar de que calidad es cada uno
            # Además es necesario generar un apr de key en unas variables, una que haga de key-id y de key y meterlo también el comando de shacka

            echo $nombre_con_extension
            comando1="packager input=/media/${nombre_con_extension},stream=audio,output=/webmedia/${nombre_sin_extension}_audio.mp4 input=/media/${nombre_con_extension},stream=video,output=/webmedia/${nombre_sin_extension}_video.mp4 --mpd_output /webmedia/${nombre_mpd}"
            comando2="packager input=/media/${nombre_ext_144},stream=audio,output=/webmedia/${nombre_sin_ext_144}_audio.mp4 input=/media/${nombre_ext_144},stream=video,output=/webmedia/${nombre_sin_ext_144}_video.mp4 --mpd_output /webmedia/${nombre_mpd_144}"
            comando3="packager input=/media/${nombre_ext_50},stream=audio,output=/webmedia/${nombre_sin_ext_50}_audio.mp4 input=/media/${nombre_ext_50},stream=video,output=/webmedia/${nombre_sin_ext_50}_video.mp4 --mpd_output /webmedia/${nombre_mpd_50}"


            # Ejecutar el comando y redirigir la salida a un archivo
            #echo $comando > shaka-packager
            
            
            docker exec smm-2324_gett_shaka-packager_1 $comando1
            docker exec smm-2324_gett_shaka-packager_1 $comando2
            docker exec smm-2324_gett_shaka-packager_1 $comando3

            curl -k -X POST https://sisflix.net:8443/api/video -H 'Content-Type: application/json' -d '{"titulo": "$nombre_sin_extension", "src": "https://sisflix.net:9443/$nombre_sin_extension.mpd", "keyid": "501e9eb249d7efdf1162b07c32842c31","key":"47c003c601fd6838a610a49e1c67cd4c"}'


            #Antes de borrar nada diría de hacer el curl

            sleep 5
            rm "$directorio"/"${nombre_con_extension}"
            rm "$directorio"/"${nombre_ext_144}"
            rm "$directorio"/"${nombre_ext_50}"
        

        done

        sleep 3
    fi


done



