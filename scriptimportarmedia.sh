#!/bin/bash

directorio="./media"  # Reemplaza con la ruta de tu directorio
archivos_procesados=()

echo "Archivos procesados:"
    for archivo in "${archivos_procesados[@]}"; do
        echo "$archivo"
    done

# '''
# PS D:\Datos\Escritorio> D:\Datos\Descargas\packager-win-x64.exe 
# >> in="D:\Datos\Descargas\file_example_MP4_480_1_5MG.mp4",stream=audio,output=audio_enc.mp4,drm_label=AUDIO 
# >> in="D:\Datos\Descargas\video_500k.mp4",stream=video,output=video_500k_enc.mp4,drm_label=SD 
# >> in="D:\Datos\Descargas\file_example_MP4_480_1_5MG.mp4",stream=video,output=video_1500k_enc.mp4,drm_label=HD 
# >> --enable_raw_key_encryption 
# >> --keys label=AUDIO:key_id=501e9eb249d7efdf1162b07c32842c31:key=47c003c601fd6838a610a49e1c67cd4c,label=SD:key_id=501e9eb249d7efdf1162b07c32842c31:key=47c003c601fd6838a610a49e1c67cd4c,label=HD:key_id=501e9eb249d7efdf1162b07c32842c31:key=47c003c601fd6838a610a49e1c67cd4c 
# >> --mpd_output manifest_enc.mpd `
# >> --hls_master_playlist_output playlist_enc.m3u8^C
# PS D:\Datos\Escritorio> openssl rand -hex 16
# WARNING: can't open config file: C:\Program Files (x86)\VMware\OpenSSL/openssl.cnf
# faa13fed78458df86b3b81502a729ec7
# PS D:\Datos\Escritorio> openssl rand -hex 16
# WARNING: can't open config file: C:\Program Files (x86)\VMware\OpenSSL/openssl.cnf
# 0ac8673f17af3f121a3ea7c58fd71723

# '''





#inotifywait -m -e moved_to --format "%f" "$directorio" | while read nuevo_archivo

inotifywait -m -e close_write,moved_to --format "%f" "$directorio" | while read nuevo_archivo

do
    nombre_con_extension="$nuevo_archivo"
    nombre_sin_extension=$(basename -- "$nuevo_archivo" | cut -f 1 -d '.')

    if [[ ! " ${archivos_procesados[@]} " =~ " ${nombre_sin_extension} " ]]; then
        echo "¡Nuevo archivo detectado: $nombre_sin_extension!"
        archivos_procesados+=("$nombre_sin_extension")

        # Agrega aquí las acciones que deseas realizar cuando se detecta un nuevo archivo
        nombre_mpd="${nombre_sin_extension}.mpd"

        ## cambio de calidades
        # Video a 144p
        ffmpeg -i "$nombre_con_extension" -c:v libx264 -vf "scale=256:144" -crf 35 -c:a aac -b:a 48k ${nombre_sin_extension}_144p.mp4

        # Video al 50% de la calidad original
        ffmpeg -i "$nombre_con_extension" -c:v libx264 -crf 23 -vf "scale=iw*0.5:ih*0.5" -c:a aac -b:a 128k ${nombre_sin_extension}_50percent_quality.mp4


        # Comando Shaka Packager
        comando="packager input=/media/${nombre_con_extension},stream=audio,output=/media/${nombre_sin_extension}_audio.mp4 input=/media/${nombre_con_extension},stream=video,output=/media/${nombre_sin_extension}_video.mp4 --mpd_output /media/${nombre_mpd}"

        # Ejecutar el comando y redirigir la salida a un archivo
        echo $comando > shaka-packager

        # Engadir script ao contenedor
        chmod +x shaka-packager
        docker cp ./shaka-packager shaka-packager-container:shaka-packager
        #docker exec shaka-packager-container chmod +x shaka-packager.sh
        docker exec shaka-packager-container sh shaka-packager

    else
        echo "Archivo duplicado: $nuevo_archivo. No se mostrará el mensaje."
    fi

echo "Archivos procesados:"
    for archivo in "${archivos_procesados[@]}"; do
        echo "$archivo"
    done


done



