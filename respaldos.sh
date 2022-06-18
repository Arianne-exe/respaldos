#!/bin/bash
function bitacora() {
    ruta="$1"
    tipo="$2"
    if [[ $tipo -eq 2 ]] ;  then
        echo -e "[ ERROR ] $fecha $(date +'%r') - Ocurrió un problema con el directorio $ruta, por favor verifique su estado\n" >> /home/arianne/logs.log
    elif [[ $tipo -eq 1 ]] ; then
        echo -e "[ INFO ] $fecha $(date +'%r') - El directorio $ruta ha sido eliminado debido a su antiguedad\n" >> /home/arianne/logs.log
    fi
}


function generar_respaldo() {
    directorio="$1"
    ruta_respaldo="$2"

    cp -r "$directorio"/ "$ruta_respaldo"/${directorio##/*/}+$fecha
    cd "$ruta_respaldo"/
    zip -r ${directorio##/*/}+$fecha.zip ${directorio##/*/}+$fecha
    rm -r ${directorio##/*/}+$fecha
}

function eliminar_respaldos_antiguos() {
    # Se considera como archivo de respaldo antiguo aquellos que cuenten con un mes de antiguedad
    directorio="$1"
    ruta_respaldo="$2"
    fecha="$3"
    nombre_corto_directorio=${directorio##/*/}

    for fecha_respaldo in $(ls $ruta_respaldo | grep -oP "$nombre_corto_directorio\+\K[0-9\-]*"); do
        mes_directorio=$(echo "$fecha_respaldo" | grep -oP "[0-9]*-\K[0-9]{2}(?=-[0-9]*)")
        mes_actual=$(echo $fecha | grep -oP "[0-9]*-\K[0-9]{2}(?=-[0-9]*)")
        dia_directorio=$(echo "$fecha_respaldo"| grep -oP "^\K[0-9]*(?=[\-0-9]*)")
        dia_actual=$(echo "$fecha"| grep -oP "^\K[0-9]*(?=[\-0-9]*)")

        if [ "$mes_actual" -gt "$mes_directorio" ] ; then
            if [ $dia_actual -gt $dia_directorio ] || [ $dia_actual -eq $dia_directorio ] ; then
                ruta=$ruta_respaldo/$nombre_corto_directorio"+"$fecha_respaldo.zip
                rm -r $ruta
                bitacora $ruta "1" ;
            fi
        elif [ $mes_actual -eq 1 ] ; then
            if [ $mes_directorio -eq 12 ] ; then
                ruta=$ruta_respaldo/$nombre_corto_directorio"+"$fecha_respaldo.zip
                rm -r $ruta
                bitacora $ruta "1" ;
            fi
        fi
    done

}

separador=$IFS
IFS=$(echo -en "\n\b")

fecha=$(date +"%d-%m-%Y")


directorio="/home/arianne/compartido"
ruta_respaldo="/media/arianne/AnnIvn/8voDebian/respaldo"


[ -d "$directorio" ] || { bitacora "$directorio" "2" ; exit 1; }
[ -d "$ruta_respaldo" ] || { bitacora "$ruta_respaldo" "2"; exit 1; }

generar_respaldo $directorio $ruta_respaldo;
eliminar_respaldos_antiguos $directorio $ruta_respaldo $fecha;



IFS=$separador


#CRON 10 14 * * * /home/lahe/Scripts/comBackup.sh
#diarios  las 10pm
#comprime
#/home/samba/shares

#Dlahe61218
#0 22 * * * /home/lahe/Scripts/comBackup.sh
#diarios  las 10pm