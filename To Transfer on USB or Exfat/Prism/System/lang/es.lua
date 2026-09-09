-- Prism PS2 Launcher - lang/es.lua
-- Español / Spanish: every text of the interface. Fills the TEXT_* tables.
-- Split from the original language.lua (RETROLauncher, Spaghetticode / Boon Tobias).

function lang_es(actual)
	-- Nota. ------------------------------------------------------------------------
	-- Evite utilizar palabras o frases que excedan el límite de caracteres de los originales, para evitar textos fuera de cuadro.
	-- ...? - Es una pregunta que puede variar, por lo que finaliza en otra parte del código, en estos casos omita el carácter "?" al final.
	-- \n - Es un salto de línea, por lo que no debe existir espacio entre ellos y la palabra que les sigue.
	-- \" - Se utiliza para escapar de un carácter especial utilizado por el código que podría causar conflictos.

	-- Textos de uso general. -------------------------------------------------------
	TEXT_GEN = {
		"Salir"; -- 1
		"No"; -- 2
		"Sí"; -- 3
		"Atrás"; -- 4
		"Elegir"; -- 5
		"Cancelar"; -- 6
		"Salir"; -- 7
		"Cambiar"; -- 8
		"No"; -- 9
		"Sí"; -- 10
		"Reiniciar"; -- 11
		"Guardar"; -- 12
		"Encendido"; -- 13
		"Apagado"; -- 14
	};

	-- Menú de configuraciones para juegos de PS1. ----------------------------------
	TEXT_M_PS1 = {
		"Instalar archivo \"CHEATS.TXT\""; -- 1
		"Buscando archivos \"CHEATS.TXT\""; -- 2
		"Descripción"; -- 3
		"Control de códigos"; -- 4
		"¿Guardar códigos seleccionados"; -- 5 ...?
		"Guardando códigos"; -- 6
		"Instalando parches"; -- 7
		"Buscando parches"; -- 8
		"Cargando configuraciones del juego"; -- 9
		"Limpiando configuraciones del juego"; -- 10
		"Parches de uso general encontrados"; -- 11
		"Se reemplazarán los parches con el mismo nombre."; -- 12
		"Parches de juegos encontrados"; -- 13
		"Se eliminarán todos los parches anteriores."; -- 14
		"Instalar parche"; -- 15
		"Nombre del parche que se instalará"; -- 16
		"Instalar"; -- 17
		"¿Instalar parches seleccionados"; -- 18 ...?
		"Instalar parches para juegos específicos"; -- 19
		"Instalar parches generales"; -- 20
		"Configuraciones extras"; -- 21
		"Limpiar configuraciones del juego"; -- 22
		"Seleccionar el tipo de configuración"; -- 23
		"Solo parches"; -- 24
		"Solo códigos"; -- 25
		"Todas las configuraciones"; -- 26
		"¿Limpiar configuraciones seleccionadas"; -- 27 ...?
		"Limpiar"; -- 28
		"\"CHEATS.TXT\" de juegos encontrados"; -- 29
		"Se eliminará el \"CHEATS.TXT\" anterior."; -- 30
		"¿Instalar \"CHEATS.TXT\" seleccionado"; -- 31 ...?
		"\"CHEATS.TXT\" del juego que se instalará"; -- 32
		"Instalando \"CHEATS.TXT\""; -- 33
	};

	-- Descripciones para las opciones de POPStarter. -------------------------------
	TEXT_POPS_DESCR = {
		-- Descripción de los códigos para POPStarter. ------------------------------
		"Desactiva el motor de trucos y solo lo\nactiva después de que POPS abandone el OSD\nde PS1. Debe estar siempre activado."; -- 1
		"Habilita el mapeo de textura suave al\ninicio."; -- 2
		"Configura el retardo USB del contenedor PFS.\nPara dispositivos USB que tienen problemas\nal ejecutar \"POPStarter\"."; -- 3
		"Fuerza la activación del parcheador PAL y\naplica el código de región a Europa.\nÚtil para VCD PAL sin un texto de licencia\nválido en el sector de arranque."; -- 4
		"Desactiva el parcheador POPStarters PAL.\nNo está diseñado para convertir juegos NTSC\na PAL."; -- 5
		"Centra la pantalla verticalmente. No hay un\nvalor predeterminado; depende del juego; hay\nque experimentar. Cuanto mayor sea el valor,\nmás se desplaza la pantalla hacia abajo."; -- 6
		"Centra la pantalla horizontalmente. El valor\npredeterminado es 640; un valor inferior a\n640 moverá la pantalla a la izquierda; un\nvalor superior a 640, a la derecha."; -- 7
		"Extiende la pantalla horizontalmente.\nEl valor predeterminado es 2559; auméntalo\npara extender la pantalla a la derecha y\ndisminúyelo para estrecharla a la izquierda."; -- 8
		"Reduce/expande el ancho del área de\nvisualización. El valor máximo es 2560;\nredúzcalo para recortar la pantalla a la\nderecha."; -- 9
		"Activar las líneas de escaneo. Los juegos se\nven con este tipo de líneas, propias de los\nantiguos televisores y monitores de tubo."; -- 10
		"El control permanece en modo digital.\nHabilita la compatibilidad con joysticks en\njuegos que no lo admiten de forma nativa."; -- 11
		"El control permanece en modo analógico.\nHabilita la compatibilidad con joysticks en\njuegos que no lo admiten de forma nativa."; -- 12
		"Ayuda con televisores HDTV que no admiten\nresoluciones entrelazadas por componentes.\nNo compatible con algunos televisores CRT."; -- 13
		"Silenciar los sonidos y la música basados en\nVAB/VAG/VB+VH en los juegos. Puede ser útil\npara juegos antiguos que generan efectos de\nsonido distorsionados o ruidos molestos."; -- 14
		"Abre el menú IGR.\nCombinación:\nL1 + L2 + R1 + R2 + X + DOWN"; -- 15
		"Abre el menú IGR.\nCombinación:\nSELECT + START"; -- 16
		"Abre el menú IGR.\nCombinación:\nL1 + L2 + R1 + R2 + SELECT + START"; -- 17
		"La combinación \"IGR\" finaliza POPS\n(no hay menú \"IGR\").\nCombinación:\nL1 + L2 + R1 + R2 + X + DOWN"; -- 18
		"La combinación \"IGR\" finaliza POPS\n(no hay menú \"IGR\").\nCombinación:\nSELECT + START"; -- 19
		"La combinación \"IGR\" finaliza POPS\n(no hay menú \"IGR\").\nCombinación:\nL1 + L2 + R1 + R2 + SELECT + START"; -- 20
		"Desactiva el menú IGR."; -- 21
		"Carga una palabra mágica LibCrypt nula en el\nregistro cop0.\nPuede ser necesario en algunos discos con\nprotección LibCrypt defectuosa."; -- 22
		"Permite el hack de pantalla ancha de POPS\nGTE y fuerza la relación de aspecto 16:9.\nNo se adapta a elementos como HUD, textos,\nni fondos 2D (este hack no está terminado)."; -- 23
		"Igual que WIDESCREEN, pero con un campo de\nvisión más amplio.\nNo se adapta a elementos como HUD, textos,\nni fondos 2D (este hack no está terminado)."; -- 24
		"Igual que WIDESCREEN, pero con una relación\nde aspecto de 3×16:9.\nNo se adapta a elementos como HUD, textos,\nni fondos 2D (este hack no está terminado)."; -- 25
		"Fuerza 480p. No es compatible con XPOS,\nYPOS, DWSTRETCH ni DWCROP.\nEvite usarlo, no es fiable."; -- 26
		"habilitar solamente \"Virtual Memory Card 1\"."; -- 27
		"habilitar solamente \"Virtual Memory Card 0\"."; -- 28
		"Impide que POPStarter active correcciones\ndel juego. Es posible que este comando no\nfuncione en algunos juegos."; -- 29
		"Ayuda a restaurar la música y las voces en\nvarios juegos.\nDesactívala si usas parches \".bin\"."; -- 30
		"Una variante del modo 0×01, con un segundo\ntruco para no romper el MDECoding de FMVs\n(fue diseñado para la serie Colony Wars).\nDesactívala si usas parches \".bin\"."; -- 31
		"Se puede utilizar si el modo 0×01 no\nproporciona los resultados esperados.\nDesactívala si usas parches \".bin\"."; -- 32
		"Corrige ralentizaciones, parpadeos y muchos\notros fallos.\nDesactívala si usas parches \".bin\"."; -- 33
		"Hecho para arreglar las escenas de corte del\nResident Evil: Director’s Cut (PAL).\nDesactívala si usas parches \".bin\"."; -- 34
		"Desactiva el shell OSD del BIOS integrado\ndel emulador, lo que hace que se ejecuten\nalgunos juegos que se congelan al iniciarse.\nDesactívala si usas parches \".bin\"."; -- 35
		-- Descripción de los parches para POPStarter. ------------------------------
		"Posiblemente solucione juegos con problemas\n3D/2D.\nHack / +4 de brillo / DQA, DQB"; -- 36
		"Posiblemente solucione juegos con problemas\n3D/2D.\nHack / Brillo normal / DQA, DQB"; -- 37
		"Posiblemente solucione juegos con problemas\n3D/2D.\nHack / -4 de brillo / DQA, DQB"; -- 38
		"Posiblemente solucione juegos con problemas\n3D/2D.\nHack / -16 de brillo / DQA, DQB"; -- 39
		"Posiblemente solucione juegos con problemas\n3D/2D.\nHack / DQA, DQB"; -- 40
		"Posiblemente solucione juegos con problemas\n3D/2D.\nHack / IR0"; -- 41
		"Posiblemente solucione juegos con problemas\n3D/2D.\nEl más compatible y recomendado."; -- 42
		"Corrige fallos a nivel del recompilador en\nmuy pocos casos, solo cuando el problema es\nuna mala actualización del código en la\ncaché de instrucciones del recompilador."; -- 43
		"Estos mods evitan fallos de audio.\nSe recomienda usar \"SPU_IRQ_ON_STABLE\", ya\nque es el más estable; el audio se omitirá,\npor lo que no lo oirás."; -- 44
		"Esto aplica overclocking al emulador,\ncompatible con PAL y NTSC.\nPrecaución: Valores superiores a +40 pueden\ncausar problemas de guardado."; -- 45
		"Sin overclocking de GPU.\nRequerido para algunas combinaciones de\noverclocking de CPU."; -- 46
		"Puede que solucione algunos problemas, pero\nsu uso debe compensarse con overclocking.\nSe recomienda que la frecuencia de la GPU\nsea un 20% inferior a la de la CPU."; -- 47
		"Deshabilitar el Dithering, este es un filtro\nespecial utilizado en los juegos de PS1."; -- 48
		"Sin descripción."; -- 49
	};

	-- Menú de configuraciones para juegos de PS2. ----------------------------------
	TEXT_M_PS2 = {
		"Buscando configuración del juego"; -- 1
		"Usar tarjeta de memoria virtual"; -- 2
		"Sin tarjeta de memoria virtual"; -- 3
		"Modos de compatibilidad"; -- 4
		"IOP: Fast Reads"; -- 5
		"Dummy"; -- 6
		"IOP: Sync Reads"; -- 7
		"EE : Unhook Syscalls"; -- 8
		"IOP: Emulate DVD-DL"; -- 9
		"IOP: Fix game buffer overrun"; -- 10
		"Modo sintetizador gráfico"; -- 11
		"Modo de vídeo forzado"; -- 12
		"Modo de compatibilidad"; -- 13
		"No usado"; -- 14
		"Guardar configuración del juego"; -- 15
		"OPL"; -- 16
		"Neutrino"; -- 17
		"VMC no encontrada"; -- 18
		"Guardando la configuración del juego"; -- 19
		"Accurate Reads"; -- 20
		"Synchronous Reads"; -- 21
		"Unhook Syscalls"; -- 22
		"Skip videos"; -- 23
		"Emulate DVD-DL"; -- 24
		"Disable IGR"; -- 25
		"Ajuste horizontal"; -- 26
		"Ajuste vertical"; -- 27
		"¿Guardar configuración?"; -- 28
		"ADVERTENCIA:\nSe recomienda que configure sus juegos dentro de\n\"OPL\", ya que puede haber conflictos entre las\ndiferentes versiones de \"OPL\" y sus archivos de\nconfiguración."; -- 29
	};

	-- Menú de explorador. ----------------------------------------------------------
	TEXT_M_EXP = {
		"La carpeta está vacía o los archivos no son compatibles"; -- 1
		"No hay archivos válidos"; -- 2
		"Elementos"; -- 3
	};

	-- Menú de configuraciones para Prism. ----------------------------------
	TEXT_M_CON = {
		"Efecto RGB"; -- 1
		"Color sobre los fondos"; -- 2
		"Fijar un color sobre el fondo"; -- 3
		"Rojo"; -- 4
		"Verde"; -- 5
		"Azul"; -- 6
		"Estilo de lista"; -- 7
		"Fuente de texto"; -- 8
		"Fondo de pantalla"; -- 9
		"GUI limpia"; -- 10
		"Forzar la recolección de basura"; -- 11
		"Salida personalizada"; -- 12
		"Directorio"; -- 13
		"Rutas completas en menú de APPS"; -- 14
		"Sonidos en el menú"; -- 15
		"Volumen del sonido"; -- 16
		"Capturas de pantalla como fondos"; -- 17
		"Modo de vídeo"; -- 18
		"Vibración en el menú"; -- 19
		"Directorios adicionales"; -- 20
		"Restablecer todos los ajustes"; -- 21
		"Créditos"; -- 22
		"Guardar configuración"; -- 23
		"Página 1"; -- 24
		"Página 2"; -- 25
		"Cambios no guardados. ¿Deseas salir?"; -- 26
		"Todos los cambios realizados se perderán."; -- 27
		"Seleccionar dispositivo de búsqueda"; -- 28
		"Buscar"; -- 29
		"Ajustar ancho"; -- 30
		"Ajustar altura"; -- 31
		"Ajustar fondos del texto"; -- 32
		"Ajustar el desplazamiento del texto"; -- 33
		"Aumente o disminuya el número mínimo de desplazamientos hasta que el número \"0\" sea visible junto al cuadro de color"; -- 34
		"Configurar la fuente de texto"; -- 35
		"Encaja el texto en los recuadros oscuros"; -- 36
		"Intente colocar el \"0\" en el cuadro de color"; -- 37
		"Intenta que la barra oscura cubra el texto"; -- 38
		"Ejemplo de texto fijo"; -- 39
		"Restablecer"; -- 40
		"Establecer"; -- 41
		"¿Liberar el resto de listas?"; -- 42
		"Si se activa, el movimiento será más fluido"; -- 43
		"a costa de pausas al cambiar de sistemas."; -- 44
		"¿Deshabilitar \"wLaunchELF\"?"; -- 45
		"Espere, por favor"; -- 46
		"¿Música de fondo en bucle?"; -- 47
		"Usar solo si RetroArch presenta cortes de audio"; -- 48
		"o si no posee otro medio para cambiar de formato"; -- 49
		"¿Restablecer"; -- 50 ...?
		"¿Borrar partidas guardadas?"; -- 51
		"¿Cambiar el modo de video a"; -- 52 ...?
		"¿Restablecer todas las configuraciones?"; -- 53
		"Estándar"; -- 54
		"(habilitar colores de depuración)"; -- 55
		"Simple"; -- 56
		"Cover art"; -- 57
		"Full art"; -- 58
		"Big cover"; -- 59
		"Big art"; -- 60
		"Big list"; -- 61
		"Custom"; -- 62
		"Nivel de zoom"; -- 63
		"Activar sistemas"; -- 64
		"Transparencia"; -- 65
		"Sin transparencia"; -- 66
		"Seleccionar aplicación"; -- 67
		"Seleccionar versión de OPL"; -- 68
		"(configuración del usuario)"; -- 69
		"Eliminar partidas guardadas"; -- 70
		"Restableciendo"; -- 71
		"Cambiando la configuración de video"; -- 72
		"Cargando listas de juegos y configuraciones"; -- 73
		"Restableciendo todas las configuraciones"; -- 74
		"W"; -- 75 Ejemplo para configuración de fuente.
		"M"; -- 76 Ejemplo para configuración de fuente.
		"Columnas"; -- 77
		"Filas"; -- 78
		"Número de animaciones"; -- 79
		"¿Renombrar imagen para su autoconfiguración"; -- 80 ...?
		"Nombre actual"; -- 81
		"Nuevo nombre"; -- 82
		"Configuración de POPStarter"; -- 83
		"\"IGR\" direcciona hacia \"OSDSYS\""; -- 84
		"Desactivar \"Dithering\" en los juegos"; -- 85
		"Instalar traducción en \"IGR\""; -- 86
		"Configurar animación de capas"; -- 87
		"Tipo de animación"; -- 88
		"Velocidad de animación"; -- 89
		"Multiplicador de velocidad"; -- 90
		"Tipo de transparencia"; -- 91
		"Nivel de transparencia"; -- 92
		"Velocidad de transparencia"; -- 93
		"Tipo de rotación"; -- 94
		"Velocidad de rotación"; -- 95
		"Capas afectadas"; -- 96
		"Girar a la\nderecha"; -- 97
		"Girar a la\nizquierda"; -- 98
		"Alternar\ndirección"; -- 99
		"Transparencia\nfija"; -- 100
		"Alternar\nmínimo/máximo"; -- 101
		"Alternar\nmitad/máximo"; -- 102
		"Alternar capas\nmínimo/máximo"; -- 103
		"Alternar capas\nmitad/máximo"; -- 104
		"¿Mostrar índices de juegos?"; -- 105
		"Configuración de sprites"; -- 106
		"Activar sprites en menú"; -- 107
		"Sprite correspondiente a"; -- 108
		"Tipo de animación"; -- 109
		"Velocidad de animación"; -- 110
		"Transparencias en animación"; -- 111
		"Rotaciones en animación"; -- 112
		"Reflejar sprites"; -- 113
		"Blanco"; -- 114
		"Tamaño del radio"; -- 115
		"Seleccionar menú de configuración"; -- 116
		"Editor de estilo"; -- 117
		"Configuración de sprites"; -- 118
		"Transparencia de los screenshots"; -- 119
		"Mostrar siempre el menú de ejecución alternativo"; -- 120
		"Color de las sombras detrás de los elementos"; -- 121
	};

	-- Nombre de los estilos de animación para los sprites. -------------------------
	TEXT_SPR_T = {
		"Sprite\nfijo"; -- 1
		"Mover a la\nderecha\nsobre el eje\nhorizontal"; -- 2
		"Mover a la\nizquierda\nsobre el eje\nhorizontal"; -- 3
		"Mover a la\nderecha\nsobre el eje\nhorizontal\n+zigzag\nsobre el eje\nvertical\n(corto)"; -- 4
		"Mover a la\nizquierda\nsobre el eje\nhorizontal\n+zigzag\nsobre el eje\nvertical\n(corto)"; -- 5
		"Mover a la\nderecha\nsobre el eje\nhorizontal\n+zigzag\nsobre el eje\nvertical\n(largo)"; -- 6
		"Mover a la\nizquierda\nsobre el eje\nhorizontal\n+zigzag\nsobre el eje\nvertical\n(largo)"; -- 7
		"Mover de\nderecha a\nizquierda\nsobre el eje\nhorizontal\n(corto)"; -- 8
		"Mover de\nderecha a\nizquierda\nsobre el eje\nhorizontal\n(medio)"; -- 9
		"Mover de\nderecha a\nizquierda\nsobre el eje\nhorizontal\n(largo)"; -- 10
		"Mover de\nderecha a\nizquierda\nsobre el eje\nhorizontal\n(corto)\n+zigzag\nsobre el eje\nvertical"; -- 11
		"Mover de\nderecha a\nizquierda\nsobre el eje\nhorizontal\n(medio)\n+zigzag\nsobre el eje\nvertical"; -- 12
		"Mover de\nderecha a\nizquierda\nsobre el eje\nhorizontal\n(largo)\n+zigzag\nsobre el eje\nvertical"; -- 13
		"Bajar\nsobre el eje\nvertical"; -- 14
		"Subir\nsobre el eje\nvertical"; -- 15
		"Bajar\nsobre el eje\nvertical\n+zigzag\nsobre el eje\nhorizontal\n(corto)"; -- 16
		"Subir\nsobre el eje\nvertical\n+zigzag\nsobre el eje\nhorizontal\n(corto)"; -- 17
		"Bajar\nsobre el eje\nvertical\n+zigzag\nsobre el eje\nhorizontal\n(largo)"; -- 18
		"Subir\nsobre el eje\nvertical\n+zigzag\nsobre el eje\nhorizontal\n(largo)"; -- 19
		"Subir y\nbajar\nsobre el eje\nvertical\n(corto)"; -- 20
		"Subir y\nbajar\nsobre el eje\nvertical\n(medio)"; -- 21
		"Subir y\nbajar\nsobre el eje\nvertical\n(largo)"; -- 22
		"Subir y\nbajar\nsobre el eje\nvertical\n(corto)\n+zigzag\nsobre el eje\nhorizontal"; -- 23
		"Subir y\nbajar\nsobre el eje\nvertical\n(medio)\n+zigzag\nsobre el eje\nhorizontal"; -- 24
		"Subir y\nbajar\nsobre el eje\nvertical\n(largo)\n+zigzag\nsobre el eje\nhorizontal"; -- 25
		"Aceleración\nal bajar a\nla derecha"; -- 26
		"Aceleración\nal bajar a\nla izquierda"; -- 27
		"Aceleración\nal subir a\nla derecha"; -- 28
		"Aceleración\nal subir a\nla izquierda"; -- 29
		"Aceleración\nde derecha\na izquierda"; -- 30
		"Aceleración\nde izquierda\na derecha"; -- 31
		"Aceleración\nde derecha\na izquierda\n+cambio\nsobre el eje\nvertical"; -- 32
		"Aceleración\nde izquierda\na derecha\n+cambio\nsobre el eje\nvertical"; -- 33
		"Desacelerar\nde derecha\na izquierda"; -- 34
		"Desacelerar\nde izquierda\na derecha"; -- 35
		"Aceleración\nal bajar a\nla izquierda"; -- 36
		"Aceleración\nal subir a\nla izquierda"; -- 37
		"Aceleración\nal bajar a\nla derecha"; -- 38
		"Aceleración\nal subir a\nla derecha"; -- 39
		"Aceleración\nal bajar"; -- 40
		"Aceleración\nal subir"; -- 41
		"Aceleración\nal bajar\n+cambio\nsobre el eje\nhorizontal"; -- 42
		"Aceleración\nal subir\n+cambio\nsobre el eje\nhorizontal"; -- 43
		"Desacelerar\nal bajar"; -- 44
		"Desacelerar\nal subir"; -- 45
		"Flotar\nen diagonal\nversión 1"; -- 46
		"Flotar\nen diagonal\nversión 2"; -- 47
		"Diagonal\nabajo\nderecha"; -- 48
		"Diagonal\nabajo\nizquierda"; -- 49
		"Diagonal\narriba\nderecha"; -- 50
		"Diagonal\narriba\nizquierda"; -- 51
		"Recorrer\nel marco de\nla pantalla\nen sentido\nhorario"; -- 52
		"Recorrer\nel marco de\nla pantalla\nen sentido\nantihorario"; -- 53
		"Dar vueltas\nen círculos\nen sentido\nhorario\n(corto)"; -- 54
		"Dar vueltas\nen círculos\nen sentido\nantihorario\n(corto)"; -- 55
		"Dar vueltas\nen círculos\nen sentido\nhorario\n(medio)"; -- 56
		"Dar vueltas\nen círculos\nen sentido\nantihorario\n(medio)"; -- 57
		"Dar vueltas\nen círculos\nen sentido\nhorario\na pantalla\ncompleta"; -- 58
		"Dar vueltas\nen círculos\nen sentido\nantihorario\na pantalla\ncompleta"; -- 59
		"Rebotar en\nlos marcos\nde la\npantalla"; -- 60
		"Hacer zoom\n(corto)"; -- 61
		"Hacer zoom\n(medio)"; -- 62
		"Controlar\nsprite con\nel stick\nderecho"; -- 63
		"Fijar\nnivel de\ntransparencia"; -- 64
		"Alternar\nentre el\nmínimo y\nel máximo"; -- 65
		"Alternar\nentre la\nmitad y\nel máximo"; -- 66
		"Reflejar\nel eje\nhorizontal\nde forma\nautomática\ny acorde al\nmovimiento"; -- 67
		"Reflejar\nel eje\nvertical\nde forma\nautomática\ny acorde al\nmovimiento"; -- 68
		"Reflejar\nambos ejes\nde forma\nautomática\ny acorde al\nmovimiento"; -- 69
		"Reflejar\nel eje\nhorizontal\nde forma\nmanual\na través\ndel stick\nderecho"; -- 70
		"Reflejar\nel eje\nvertical\nde forma\nmanual\na través\ndel stick\nderecho"; -- 71
		"Reflejar\nambos ejes\nde forma\nmanual\na través\ndel stick\nderecho"; -- 72
		"Fijar\nreflejo\nen eje\nhorizontal"; -- 73
		"Fijar\nreflejo\nen eje\nvertical"; -- 74
		"Fijar\nreflejo en\nambos ejes"; -- 75
		"Coloque el\nnúmero de\ncolumnas\nque contiene\nla imagen\n(vertical)"; -- 76
		"Coloque el\nnúmero de\nfilas\nque contiene\nla imagen\n(horizontal)"; -- 77
	};

	-- Nombre de los estilos de animación para las capas. ---------------------------
	TEXT_LAY_T = {
		"Capas fijas"; -- 1
		"Derecha\nhorizontal v1"; -- 2
		"Izquierda\nhorizontal v1"; -- 3
		"Zigzag derecha\nvertical"; -- 4
		"Zigzag izquierda\nvertical"; -- 5
		"Derecha\nfrontal v1"; -- 6
		"Izquierda\nfrontal v1"; -- 7
		"Zigzag centro\nhorizontal v1"; -- 8
		"Derecha\nhorizontal v2"; -- 9
		"Izquierda\nhorizontal v2"; -- 10
		"Izquierda\nfrontal v2"; -- 11
		"Derecha\nfrontal v2"; -- 12
		"Derecha\nfrontal v3"; -- 13
		"Izquierda\nfrontal v3"; -- 14
		"Derecha\npanorámica v1"; -- 15
		"Izquierda\npanorámica v1"; -- 16
		"Derecha\npanorámica v2"; -- 17
		"Izquierda\npanorámica v2"; -- 18
		"Entrecruzar\nhorizontal"; -- 19
		"Zigzag centro\nhorizontal v2"; -- 20
		"Abajo\nvertical v1"; -- 21
		"Arriba\nvertical v1"; -- 22
		"Zigzag abajo\nhorizontal"; -- 23
		"Zigzag arriba\nhorizontal"; -- 24
		"Arriba\nfrontal v1"; -- 25
		"Abajo\nfrontal v1"; -- 26
		"Zigzag centro\nvertical v1"; -- 27
		"Abajo\nvertical v2"; -- 28
		"Arriba\nvertical v2"; -- 29
		"Arriba\nfrontal v2"; -- 30
		"Abajo\nfrontal v2"; -- 31
		"Abajo\nfrontal v3"; -- 32
		"Arriba\nfrontal v3"; -- 33
		"Abajo\npanorámica v1"; -- 34
		"Arriba\npanorámica v1"; -- 35
		"Abajo\npanorámica v2"; -- 36
		"Arriba\npanorámica v2"; -- 37
		"Entrecruzar\nvertical"; -- 38
		"Zigzag centro\nvertical v2"; -- 39
		"Derecha\nremolino"; -- 40
		"Izquierda\nremolino"; -- 41
		"Zoom 3-4\nPíxel zoom"; -- 42
		"Zoom 1-2\nPíxel zoom"; -- 43
		"Zoom 2-3\nPíxel zoom"; -- 44
		"Zoom 1-4\nPíxel zoom"; -- 45
		"Zoom 1-3-4\nPíxel zoom"; -- 46
		"Zoom 1-2-3\nPíxel zoom"; -- 47
		"Zoom 2-3-4\nPíxel zoom"; -- 48
		"Zoom 1-2-4\nPíxel zoom"; -- 49
		"Zoom 1-2-3-4\nPíxel zoom"; -- 50
		"Zoom 3-4 v2\nPíxel zoom"; -- 51
		"Zoom 1-2 v2\nPíxel zoom"; -- 52
		"Zoom 2-3 v2\nPíxel zoom"; -- 53
		"Zoom 1-4 v2\nPíxel zoom"; -- 54
		"Zoom 1-3-4 v2\nPíxel zoom"; -- 55
		"Zoom 1-2-3 v2\nPíxel zoom"; -- 56
		"Zoom 2-3-4 v2\nPíxel zoom"; -- 57
		"Zoom 1-2-4 v2\nPíxel zoom"; -- 58
		"Zoom 1-2-3-4 v2\nPíxel zoom"; -- 59
		"Derecha\nhorizontal v3"; -- 60
		"Izquierda\nhorizontal v3"; -- 61
		"Abajo\nvertical v3"; -- 62
		"Arriba\nvertical v3"; -- 63
	};

	-- Menú editor de estilos. ------------------------------------------------------
	TEXT_M_STI = {
		"Ejemplo de nombre de juego.zip"; -- 1
		"Centro / Ejemplo de nombre de juego.zip"; -- 2
		"Derecho / Ejemplo de nombre de juego.zip"; -- 3
		"Izquierdo / Ejemplo de nombre de juego.zip"; -- 4
		"Nº de juegos"; -- 5
		"Salir"; -- 6
		"Configuraciones"; -- 7
		"Cambiar arte"; -- 8
		"Ampliar arte"; -- 9
		"Ejecutar"; -- 10
		"Actualizar"; -- 11
		"Lista"; -- 12
		"Arte"; -- 13
		"Arte extra"; -- 14
		"Cover flow"; -- 15
		"Logo"; -- 16
		"Botón Cruz"; -- 17
		"Botón Triángulo"; -- 18
		"Botón Cuadrado"; -- 19
		"Botón L1"; -- 20
		"Botón R1"; -- 21
		"Botón R3"; -- 22
		"Botón START"; -- 23
		"Botón SELECT"; -- 24
		"Tipo de transición"; -- 25
		"Velocidad"; -- 26
		"Restaurar todo"; -- 27
		"Guardar estilo"; -- 28
		"Salir del editor"; -- 29
		"Bloquear"; -- 30
		"Guías"; -- 31
		"Posición"; -- 32
		"Tamaño"; -- 33
		"Pixels"; -- 34
		"Restaurar"; -- 35
		"Siguiente"; -- 36
		"Anterior"; -- 37
		"Ayuda"; -- 38
		"Elementos"; -- 39
		"Guardar"; -- 40
		"Menú"; -- 41
		"Pixels"; -- 42
		"Activar elementos"; -- 43
		"Sombra"; -- 44
		"Opciones adicionales"; -- 45
		"¿Restablecer todos los elementos?"; -- 46
		"¿Guardar cambios?"; -- 47
		"Al guardar, si existe una configuración previa\nse creará una copia de seguridad de la misma\n(reemplazando la última copia existente)."; -- 48
	};

	-- Menú principal. --------------------------------------------------------------
	TEXT_M_PRI = {
		"-Cargando Arte-"; -- 1
		"Salir"; -- 2
		"Configuraciones"; -- 3
		"Cambiar arte"; -- 4
		"Ampliar arte"; -- 5
		"Ejecutar"; -- 6
		"Actualizar"; -- 7
		"Configurar"; -- 8
		"Menú"; -- 9
		"Arte"; -- 10
		"Zoom"; -- 11
		"Jugar"; -- 12
		"Cargando"; -- 13
		"Sin elementos"; -- 14
		"¡Error!"; -- 15
		"¡Juegos o RetroArch"; -- 16
		"¡Aplicación O ELF"; -- 17
		"¡POPS O Binarios"; -- 18
		"¡Neutrino/OPL O ISO"; -- 19
		"No encontrados!"; -- 20
		"Nº de juegos"; -- 21
		"Nº de APPS"; -- 22
		"¿Reiniciar Prism?"; -- 23
		"¿Salir de Prism?"; -- 24
		"¡ADVERTENCIA!"; -- 25
		"Todas las opciones de RetroArch se restablecerán"; -- 26
		"Cargando Arte"; -- 27
		"¿Dónde desea crear el ejecutable del juego?"; -- 28
		"Directorio \"POPS\""; -- 29
		"Directorio \"APPS\""; -- 30
		"Configurar"; -- 31
		"Alternativo"; -- 32
		"Variante"; -- 33
		"Explorador"; -- 34
		"Seleccione el dispositivo a examinar"; -- 35
		"¡Ember o Bios/CUE"; -- 36
	};

	-- Menú de reubicación. ---------------------------------------------------------
	TEXT_M_REL = {
		"ADVERTENCIA\nEste programa se creó para ejecutarse desde el\nprimer puerto (USB) de PS2.\nVuelva a conectar el USB al primer puerto y\nreinicie el programa."; -- 1
		"ADVERTENCIA\nDispositivo de almacenamiento USB detectado en\nel segundo puerto (USB).\nDesconecte el USB del segundo puerto y reinicie\nel programa."; -- 2
		"El directorio actual no coincide\nCon su configuración.\n¿Quieres reubicar las configuraciones\nen este directorio?\n¡ADVERTENCIA!\nLas opciones de RetroArch se restablecerán"; -- 3
		"Reubicar"; -- 4
		"Reubicando"; -- 5
		"Reubicando todos los ajustes"; -- 6
	};

-------------------------------------------------------------------------------------
-- Português. -----------------------------------------------------------------------
end
