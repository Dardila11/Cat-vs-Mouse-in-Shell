#! /bin/sh
echo out > /sys/class/gpio/gpio39/direction
echo out > /sys/class/gpio/gpio38/direction
echo out > /sys/class/gpio/gpio25/direction
echo out > /sys/class/gpio/gpio16/direction
echo out > /sys/class/gpio/gpio19/direction
echo out > /sys/class/gpio/gpio26/direction
echo out > /sys/class/gpio/gpio27/direction
echo out > /sys/class/gpio/gpio24/direction

echo out > /sys/class/gpio/gpio17/direction

echo in > /sys/class/gpio/gpio32/direction
echo in > /sys/class/gpio/gpio18/direction
#reset
echo in > /sys/class/gpio/gpio28/direction

echo out > /sys/class/gpio/gpio30/direction
echo out > /sys/class/gpio/gpio31/direction
echo 1 > /sys/class/gpio/gpio30/value
echo 1 > /sys/class/gpio/gpio31/value


#variables
var="39 38 25 16 19 26 27 24"
waitTime=500000 #tiempo el cual el raton está en un posicion determinada
catLed=0
catPosition=0
mouseLed=0
mousePosition=0
cont=0
movR=0
movL=0
Xo=4
a=5
c=7
m=8

# el raton se mueve al $1 (gpio) con la instruccion $2 (apagado o encendido)
move_mouse(){
	echo $2 > /sys/class/gpio/gpio$1/value	
}
# para evitar confusiones durante el desarrollo se crea la misma funcion para el gato
move_cat(){
	echo $2 > /sys/class/gpio/gpio$1/value
}
move_right(){
	#move_cat #valorGpio #estado
	move_cat $catLed 0
	if [ $catPosition -eq 7 ] ; then
		catPosition=0
	else
		catPosition=$((catPosition + 1))
	fi
	getLedByPos $catPosition
	catLed=$?
	move_cat $catLed 1
}
move_left(){
	move_cat $catLed 0
	if [ $catPosition -eq 0 ] ; then
		catPosition=7
	else
		catPosition=$((catPosition - 1))
	fi
	getLedByPos $catPosition
	catLed=$?
	move_cat $catLed 1
	
}
func_random(){
    #congruencial mixta
	aXn=$((a * $1))
	res=$((aXn + c))
	Xo=$((res % m))
	return $Xo
}
# genera una posicion alateoria, retorna el led (gpio) que se encuentra en esa posicion
pos_random(){
	#var="39 38 25 16 19 26 27 24"
	#num=`shuf -i 0-4 -n 1`
	func_random $Xo
	ret=$?
	cont=0
	for i in $var
	do
		if [ $cont -eq $ret ] ; then
			break
		else
			cont=$((cont + 1))
		fi
	done
	return $i
}
# obtiene una posicion segun el led enviado como parametro
getPosByLed(){
	#var="39 38 25 16 19 26 27 24"
	cont=0
	for i in $var
	do
		if [ $i -eq $1 ] ; then
			break
		else
			cont=$((cont + 1))
		fi	
	done
	return $cont
}
# obtiene un led segun la posicion enviada como parametro
getLedByPos(){
	#var="39 38 25 16 19 26 27 24"
	cont=0
	for i in $var
	do
		if [ $cont -eq $1 ] ; then
			break
		else
			cont=$((cont + 1))
		fi
	done
	return $i #el valor del led (gpio) 
}
#posicionamos el gato y raton. asignamos la posicion de cada uno
func_cat_rat(){
    pos_random #posicionamos el gato en un led
    catLed=$?
    move_cat $catLed 1 #movemos el gato al led obtenido con estado 1
    getPosByLed $catLed
    catPosition=$?

    pos_random #posicionamos el rato en un led
    mouseLed=$?
    getPosByLed $mouseLed
    mousePosition=$?
    move_mouse $mouseLed 1
}
# si el ratón se moverá en la posicion del gato, busca otra posicion
func_ratPosCat(){
    while [ $catPosition -eq $mousePosition ]
    do
        pos_random
        mouseLed=$?
        getPosByLed $mouseLed
        mousePosition=$?
    done
}
func_cat_rat
while true
do
	pulLeft=`cat /sys/class/gpio/gpio32/value`  #mov izquierda
	pulRight=`cat /sys/class/gpio/gpio18/value` #mov derecha
	pulReset=`cat /sys/class/gpio/gpio28/value` #reseteamos el juego

    if [ $cont -eq 18 ] ; then
        move_mouse $mouseLed 0
        pos_random #posicionamos el rato en un led
        mouseLed=$?
        getPosByLed $mouseLed
        mousePosition=$?
        func_ratPosCat # verificamos que el raton NO esté en la misma posicion que el gato
        move_mouse $mouseLed 1
        cont=0
    fi
	# ya que al presionar el boton el gato no se mueve, elegimos utilizar una bandera
    if [ $pulLeft -eq 1 ] ; then
		movL=1
    fi
	# Si la bandera es igual a 1 y ademas el pulsador ha dejado de estar presionado
	# se realiza el movimiento del gato.
    if [ $movL -eq 1 -a $pulLeft -eq 0 ] ; then
        move_left
        movL=0
    fi
    if [ $pulRight -eq 1 ] ; then
        movR=1
    fi
    if [ $movR -eq 1 -a $pulRight -eq 0 ] ; then
        move_right
        movR=0
    fi
    
    if [ $pulReset -eq 1 ] ; then
        echo "se ha reseteado el juego"
        move_mouse $mouseLed 0
		move_cat $catLed 0
		echo 0 > /sys/class/gpio/gpio17/value
		sleep 2
        Xo=4
		func_cat_rat
	fi	

	if [ $catPosition -eq $mousePosition ] ; then
		echo "el gato ha atrapado al raton"
		echo 1 > /sys/class/gpio/gpio17/value
		move_cat $catLed 0
		move_mouse $mouseLed 0
        sleep 2

        echo 0 > /sys/class/gpio/gpio17/value
        Xo=4
        func_cat_rat		
	fi
    cont=$((cont + 1))
done