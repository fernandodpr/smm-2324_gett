#!/bin/bash

directorio="./ingest"  # Directorio donde dejaremos los vídeos
directoriotmp="./videoencode"  # Directorio de paso necesario en el proceso
archivos_procesados=()

while true;
do
    if [ "$(ls -A "$directorio")" ]; then

        for archivo in "$directorio"/*; do

            nombre_con_extension=$(basename "$archivo")
            nombre_sin_extension=$(basename -- "$nombre_con_extension" | cut -f 1 -d '.')
            
            # Nombre del fichero al que aplicaremos DRM
            nombre_mpd="${nombre_sin_extension}.mpd"

            ## cambio de calidades
            # Video a 144p
            ffmpeg -i "$directorio"/"${nombre_con_extension}" -c:v libx264 -vf "scale=256:144" -crf 35 -c:a aac -b:a 48k "./videoencode/${nombre_sin_extension}_144p.mp4"
            nombre_ext_144="${nombre_sin_extension}_144p.mp4"
            nombre_sin_ext_144="${nombre_sin_extension}_144"
            
            sleep 1

            # Video al 50% de la calidad original
            ffmpeg -i "$directorio/$nombre_con_extension" \
            -c:v libx264 -crf 23 \
            -vf "scale=960:540" \
            -c:a aac -b:a 128k "./videoencode/${nombre_sin_extension}_50percent_quality.mp4"

            nombre_ext_50="${nombre_sin_extension}_50percent_quality.mp4"
            nombre_sin_ext_50="${nombre_sin_extension}_50percent_quality"

            echo "Copiando de: $directorio/$nombre_con_extension a $directoriotmp/$nombre_con_extension"
            cp "$directorio/$nombre_con_extension" "$directoriotmp/$nombre_con_extension"

            sleep 1
            
            # Generación de valores de clave
            key=$(openssl rand -hex 16)
            key_id=$(openssl rand -hex 16)
            iv=$(openssl rand -hex 16)

            # Comando de packager
            packager_command="packager \
              in=\"/videoencode/${nombre_con_extension}\",stream=audio,output=/webmedia/${nombre_sin_extension}_audio.mp4,playlist_name=${nombre_sin_extension}_audio.m3u8,drm_label=AUDIO \
              in=\"/videoencode/${nombre_con_extension}\",stream=video,output=/webmedia/${nombre_sin_extension}_video.mp4,playlist_name=${nombre_sin_extension}_video.m3u8,drm_label=HD \
              in=\"/videoencode/${nombre_ext_144}\",stream=video,output=/webmedia/${nombre_sin_extension}_144p_video.mp4,playlist_name=${nombre_sin_extension}_144p_video.m3u8,drm_label=SD \
              in=\"/videoencode/${nombre_ext_50}\",stream=video,output=/webmedia/${nombre_sin_extension}_50p_video.mp4,playlist_name=${nombre_sin_extension}_50p_video.m3u8,drm_label=SD \
              --enable_raw_key_encryption \
              --keys label=AUDIO:key_id=${key_id}:key=${key},label=HD:key_id=${key_id}:key=${key},label=SD:key_id=${key_id}:key=${key} \
              --mpd_output /webmedia/${nombre_mpd} \
              --hls_master_playlist_output /webmedia/${nombre_sin_extension}_playlist_enc.m3u8"

            # Imprimir el comando
            echo "Ejecutando el comando:"
            echo $packager_command
            
            # Ejecutar el comando en el contenedor Docker
            docker exec smm-2324_gett_shaka-packager_1 sh -c "$packager_command"
            
            sleep 25
            
            # Solicitud curl
            curl -k -X POST https://sisflix.net:8443/api/video -H 'Content-Type: application/json' -d "{\"titulo\": \"${nombre_sin_extension}\", \"src\": \"https://sisflix.net:9443/${nombre_sin_extension}.mpd\", \"keyid\": \"${key_id}\",\"key\":\"${key}\"}"

            # Borrado de archivos
            sleep 5
            echo "Borrando..."
            rm "$directorio/${nombre_con_extension}"
            rm "$directoriotmp/${nombre_con_extension}"
            rm "$directoriotmp/${nombre_ext_144}"
            rm "$directoriotmp/${nombre_ext_50}"
        done

        sleep 3
    fi


done



