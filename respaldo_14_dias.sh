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
    fecha="$3"

    cp -r "$directorio"/ "$ruta_respaldo"/${directorio##/*/}+$fecha
    cd "$ruta_respaldo"/
    zip -r ${directorio##/*/}+$fecha.zip ${directorio##/*/}+$fecha
    rm -r ${directorio##/*/}+$fecha
}

function eliminar_respaldos_antiguos() {
    # Se considera como archivo de respaldo antiguo aquellos que cuenten con 14 dias de antiguedad
    directorio="$1"
    ruta_respaldo="$2"
    nombre_corto_directorio=${directorio##/*/}
    fecha_indicada_antiguedad=$(date +"%d-%m-%Y" -d "2 weeks ago")

    for fecha_respaldo in $(ls $ruta_respaldo | grep -oP "$nombre_corto_directorio\+\K[0-9\-]*"); do
        dia_directorio=$(echo "$fecha_respaldo"| grep -oP "^\K[0-9]*(?=[\-0-9]*)")
        mes_directorio=$(echo "$fecha_respaldo" | grep -oP "[0-9]*-\K[0-9]{2}(?=-[0-9]*)")
        anio_directorio=$(echo $fecha_respaldo | grep -oP "[0-9]*-[0-9]{2}-\K[0-9]*(?=$)")
        dia_indicado_antiguedad=$(echo "$fecha_indicada_antiguedad"| grep -oP "^\K[0-9]*(?=[\-0-9]*)")
        mes_indicado_antiguedad=$(echo $fecha_indicada_antiguedad | grep -oP "[0-9]*-\K[0-9]{2}(?=-[0-9]*)")
        anio_indicado_antiguedad=$(echo $fecha_indicada_antiguedad | grep -oP "[0-9]*-[0-9]{2}-\K[0-9]*(?=$)")

        if [ "$mes_indicado_antiguedad" -eq "$mes_directorio" ] ; then
            if [ $dia_indicado_antiguedad -eq $dia_directorio ] ; then
                if [ $anio_indicado_antiguedad -eq $anio_directorio ] ; then
                    ruta=$ruta_respaldo/$nombre_corto_directorio"+"$fecha_respaldo.zip
                    rm -r $ruta
                    bitacora $ruta "1" ;
                fi
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

generar_respaldo $directorio $ruta_respaldo $fecha;
eliminar_respaldos_antiguos $directorio $ruta_respaldo;



IFS=$separador
