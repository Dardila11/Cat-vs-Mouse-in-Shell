# Cat-vs-Mouse-in-Shell
Small program written in shell (sh) to work with Intel Galileo or Raspberry PI (ports need to be configured)

Diseñar el juego gatos y ratones en la Intel Galileo usando sh.

Requisitos:

• 1 pulsador de reset

• 2 pulsadores para controlar el movimiento del gato. Se detecta movimiento al soltar el pulsador. Mientras se tenga pulsado, no se realiza ningún movimiento.

• 8 leds en los que se mueven el gato y el ratón. 

• 1 led para indicar que el gato atrapó al ratón. 

• Una luz que oscila con un tiempo fijo (ratón) aparece cada cierto tiempo (consultar como se genera un número pseudo- aleatorio) en alguno de los 8 leds y permanece ahí por un tiempo determinado. 

• Otra luz que siempre está encendida (gato) se mueve con los dos botones de dirección para desplazarse hasta el ratón. 

• Si el gato alcanza al ratón (la luz del gato y la del ratón coinciden) lo atrapa y se enciende un led.
Para usar los pines 1 y 0 (gpio50 y gpio51), es necesario configurar los pines GPIO40 y GPIO41 y asignarles al valor de 1. 
En caso de que los pines 2 y 3 (gpio32 y gpio18), no funcionen, configurar los pines GPIO31 y GPIO30 como salida y asignarles el valor de 1.
