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
            ffmpeg -i "$directorio"/"${nombre_con_extension}" -c:v libx264 -crf 23 -vf "scale=iw*0.5:ih*0.5" -c:a aac -b:a 128k "./ingest/${nombre_sin_extension}_50percent_quality.mp4"
            nombre_ext_50="${nombre_sin_extension}_50percent_quality.mp4"
            nombre_sin_ext_50="${nombre_sin_extension}_50percent_quality"
            nombre_mpd_50="${nombre_sin_extension}_50percent_quality.mpd"

            sleep 1
            # Comando Shaka Packager
            # Habría que hacer que meta los archivos procesados ya en /webmedia, ya le he pasado al contenedor esa ruta dejar los archivos de salida en:
            # "/webmedia"
            echo $nombre_con_extension
            comando1="packager input=/media/${nombre_con_extension},stream=audio,output=/webmedia/${nombre_sin_extension}_audio.mp4 input=/media/${nombre_con_extension},stream=video,output=/webmedia/${nombre_sin_extension}_video.mp4 --mpd_output /webmedia/${nombre_mpd}"
            comando2="packager input=/media/${nombre_ext_144},stream=audio,output=/webmedia/${nombre_sin_ext_144}_audio.mp4 input=/media/${nombre_ext_144},stream=video,output=/webmedia/${nombre_sin_ext_144}_video.mp4 --mpd_output /webmedia/${nombre_mpd_144}"
            comando3="packager input=/media/${nombre_ext_50},stream=audio,output=/webmedia/${nombre_sin_ext_50}_audio.mp4 input=/media/${nombre_ext_50},stream=video,output=/webmedia/${nombre_sin_ext_50}_video.mp4 --mpd_output /webmedia/${nombre_mpd_50}"


            # Ejecutar el comando y redirigir la salida a un archivo
            #echo $comando > shaka-packager
            
            
            docker exec smm-2324_gett_shaka-packager_1 $comando1
            docker exec smm-2324_gett_shaka-packager_1 $comando2
            docker exec smm-2324_gett_shaka-packager_1 $comando3

            sleep 5
            rm "$directorio"/"${nombre_con_extension}"
            rm "$directorio"/"${nombre_ext_144}"
            rm "$directorio"/"${nombre_ext_50}"
            

            # No hace falta mover el scritpr al contenedor, con hacer el docker exec debería de llegar
            # Engadir script ao contenedor
            #chmod +x shaka-packager
            #docker cp ./shaka-packager shaka-packager-container:shaka-packager
            #docker exec shaka-packager-container chmod +x shaka-packager.sh
            #docker exec shaka-packager-container sh shaka-packager



        done

        sleep 3
    fi


done



