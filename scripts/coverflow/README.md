# Coverflow 3D — Selector de temas y wallpapers

Carrusel 3D para Hyprland: navega entre wallpapers y paletas, y aplica el
fondo, la paleta del terminal y los colores de la interfaz de una vez.

```
SUPER + T  ──▶  quickshell coverflow.qsl
                       │
                   selector de modo (QML)
                       ▼
                                            │
                        ┌───────────────────┴──────────────────┐
                        ▼                                      ▼
              coverflow.sh list <modo>              coverflow.sh apply <ruta>
              (JSON por stdout, cachea                    │
               miniaturas con ImageMagick)        awww img  +  wallust run
```

La navegación entera vive en QML. El script solo lista y aplica, así que
moverse por el carrusel no lanza ningún proceso: por eso las animaciones
van fluidas.

## Piezas

| Herramienta | Papel | Nota |
|---|---|---|
| `quickshell` | Interfaz del carrusel | QtQuick, perspectiva 3D real |
| `awww` | Transiciones del fondo | Sustituye a `swww`, que ya no existe |
| `wallust` | Extrae la paleta y la reparte | |
| `imagemagick` | Miniaturas cacheadas | |

## Instalación

```bash
~/.config/hypr/scripts/coverflow/install.sh
hyprctl reload
```

El script instala `quickshell` e `imagemagick`, todos de los
repositorios oficiales. No hay nada que compilar.

## Uso

| Atajo | Acción |
|---|---|
| `SUPER + T` | Abrir el selector de modo |
| `SUPER + SHIFT + T` | Abrir directo en modo Wallpapers |
| `←` `→` (o `h` `l`) | Mover un paso, con resorte |
| `↑` `↓` (o `k` `j`) | Igual que `←` `→`, para trackpads |
| Rueda | Un paso por muesca, con empujón de velocidad |
| Arrastrar | Mover la tira; al soltar, inercia |
| `Enter` o `Espacio` | Aplicar el central (o cerrar la vista ampliada) |
| Clic en una carta | Llevarla al marco; en la central, **ampliarla** |
| `Q` o `Retroceso` | Volver al selector (desde el selector, salir) |
| `1` `2` | Saltar directo a Wallpapers / Paletas |
| `Inicio` | Volver al principio |
| `F5` | Recargar la lista |
| `Esc` | Cerrar la vista ampliada, o la ventana |
| Clic fuera del panel | Cerrar |

La rueda y el arrastre funcionan **con el cursor en cualquier parte de la
pantalla**: la ventana no lleva máscara de entrada, así que toda su superficie
es interactiva. Antes sí la llevaba, y quedaba interactivo solo el panel
(1100×440 de 1920×1080), de modo que la rueda solo respondía si el cursor caía
encima de él. El "clic fuera cierra" ya no viene del focus grab —que solo veía
la zona con máscara— sino de un `MouseArea` en el fondo que comprueba el punto
antes de cerrar, para que un clic en hueco dentro del panel no lo haga.

La tira **se mueve siempre**: deriva lenta permanente, sin importar el modo.
No tiene extremos, así que `Fin` no hace nada y `Inicio` vuelve al principio.
Nada lleva `Behavior`; el movimiento lo lleva un integrador por frame, para
que la tira vaya exactamente a la deriva que se le pida aunque el equipo no
llegue a 60 fps.

Cerrar también pasa por `Esc`, por `Q` en el selector y por el propio grab:
`HyprlandFocusGrab` emite `cleared` al pulsar fuera de la ventana.

### Modos

- **Wallpapers** — todas las imágenes de `themes/wallpapers/`, sin subdirectorios
- **Paletas de wallust** — los 614 temas integrados (`wallust theme`), cada uno
  con sus 16 colores de muestra

La tira no tiene principio ni final en ninguno de los dos: al llegar al
último elemento sigue y aparece el primero por el otro lado.

Hubo un tercer modo, **Albums**, que agrupaba las imágenes por subdirectorio y
dejaba recorrerlas con `R` sin aplicarlas. Se quitó por sobra: la lista se
eliminó del script y sus seis imágenes se movieron a la raíz de
`themes/wallpapers/`, así que ahora se ven todas en Wallpapers.

## Wallpapers

```
themes/wallpapers/
├── wallhaven-1234_1920x1080.png     ← modo Wallpapers
├── bosque.png
├── naturaleza.png
└── noche.png
```

El listado usa `find -maxdepth 1 -type f`: los subdirectorios no se miran, así
que cualquier imagen que se meta en una carpeta propia no aparecerá en la tira.
Por eso las seis del antiguo modo Albums se movieron a la raíz en vez de dejar
los directorios puestos.

## Comandos

```bash
coverflow.sh open [modo]            # abrir (sin modo: selector en QML)
coverflow.sh list [modo]            # volcar items en JSON
coverflow.sh apply <ruta>           # aplicar wallpaper
coverflow.sh preset builtin:<tema>  # aplicar paleta
coverflow.sh cache-palettes         # rehacer la caché de paletas
coverflow.sh clean                  # borrar cachés (miniaturas y paletas)
coverflow.sh log [n]                # últimas n líneas del log de la interfaz
coverflow.sh show_log                # abrir el log en la terminal
coverflow.sh help
```

## Diagnóstico

Quickshell se lanza con la salida apuntando a un log en vez de a `/dev/null`,
porque sus errores no se ven en pantalla:

```
~/.cache/coverflow/quickshell.log
```

La interfaz **no funciona sin ese log**. En una sesión anterior el QML no
cargaba por usar `Keys.onEndPressed` —una señal que el tipo adjunto `Keys` de
Qt 6 no tiene— y sin log habría sido un panel que no aparece y sin explicación.
Cada arranque escribe una cabecera `=== <fecha> :: open <modo> ===`, así que se
puede ver a qué ejecución pertenece cada línea.

Un par de avisos que salen y **se pueden ignorar**:

- `Setting width is deprecated` — solo aparece en `PopupWindow`.
- `eglSwapBuffers failed` — ocurre al cerrar la superficie.

### Comprobar el teclado, la rueda y el clic

Hyprland 0.56 no dice por `hyprctl layers` qué capa tiene el foco, ni qué
región de entrada tiene la superficie, y en la mayoría de sistemas no hay
`wtype` ni `ydotool` para inyectar teclas o rueda. Así que el QML deja una
traza de lo que llega al log:

```bash
coverflow.sh open wallpapers   # en una terminal
coverflow.sh log 40 | grep -E 'key|wheel|click'
```

| Al hacer esto… | Y en el log sale… | Entonces |
|---|---|---|
| Pulsar `←` | `key code=16777237` | el teclado llega |
| Mover la rueda | `wheel y=-120 x=0` | la rueda llega |
| Clic en el fondo | `click fuera del panel: (x,y) -> cerrar` | el clic llega |

Si el `wheel` no aparece pero el `key` sí, el ratón llega a la capa pero el
`WheelHandler` no está haciendo lo suyo: el problema sería de los handlers
de puntero, no de la ventana.

Estas trazas se pueden quitar cuando ya no las necesites: son tres
`console.log` en `Keys.onPressed`, en `onWheel` y en el `onClicked` del fondo.

`qmllint` no sirve como prueba aquí: sale con código 0 incluso sobre un QML con
propiedades inventadas. Solo detecta sintaxis rota e imports mal puestos.

## Colores

`wallust` lee el wallpaper y escribe:

- `~/.config/quickshell/colors.json` → lo lee la interfaz QML
- `~/.config/kitty/themes/wallust.conf` → lo incluye `kitty.conf`

Las plantillas están en `~/.config/wallust/templates/`. Son de Tera
(`{{ color5 }}`), no de pywal, porque wallust v3 usa ese formato.

Las terminales abiertas reciben `SIGUSR1` para recargar el include.

## Ajustes

En la cabecera de `coverflow.qsl`:

```qml
readonly property int cardWidth: 320
readonly property int cardHeight: 180   // 16:9
readonly property int reach: 4          // ranuras a cada lado (9 cartas)
readonly property real pxPerCard: 235   // desplazamiento por tarjeta
readonly property real driftVel: 0.42   // tarjetas/s de deriva permanente
```

### La tira

`stripPos` es una posición **real**, no un índice: crece sin límite y los
índices salen por módulo. Por eso la tira no se acaba — es lo que se buscaba.
El item seleccionado es el que queda en el marco central, y se deriva de la
posición, no se asigna a mano.

Todo el movimiento sale de **un solo integrador** (`integrate()`), no de
animaciones encadenadas. La deriva, la inercia de la rueda y el resorte de las
teclas tienen que poder convivir, y con animaciones sueltas mientras una corre
las otras pelean por `stripPos` y la tira da saltos:

| Estado | Qué manda |
|---|---|
| Reposo | `velocidad = driftVel + flickVel`, y `flickVel` se apaga sola |
| Tecla / rueda | Un resorte hacia `targetPos`; la deriva se aparta y vuelve al asentar |

Al soltar una tecla el resorte **aterriza justo en la tarjeta** y la deriva sigue
desde ahí, así que las cartas pasan por el marco sin encajar de golpe.

La profundidad sale de `cardTransform(d)`, que depende de `|d|` de forma
continua y sin escalones, así que el giro 3D no da tirones. `d` lleva la
fracción de `stripPos`, que es lo que lo hace continuo de verdad.

Dos detalles que no son evidentes:

- **Nada lleva `Behavior`.** `x`, `scale` y `opacity` los fija el integrador
  cada 16 ms; una animación de QML por encima solo añadiría retardo y rompería
  la continuidad del arrastre.
- **Los índices se envuelven siempre con `wrapIndex()`.** Sin el `+ n` del
  módulo, al derivar a la izquierda salen índices negativos y aparecen huecos
  en la tira.

La rueda y el arrastre mueven un paso **e inyectan velocidad**. Solo con la
posición el scroll se nota seco; solo con la velocidad se pierde el marco
central como referencia de dónde estás.

La sensibilidad de la rueda se iguala entre dispositivos acumulando el
`angleDelta`: 120 unidades —una muesca de ratón— valen una tarjeta. Antes era
un paso entero por **cada** evento, así que un ratón de muescas iba bien pero
un trackpad, que emite decenas de eventos diminutos por el mismo golpe,
recorría la tira entera de un scroll corto. El sobrante se guarda sin caducidad
—un scroll lento suma y acaba cruzando la muesca— y el acumulador se recorta a
tres muescas para que un bote absurdo no deje un montón pendiente.

En `apply_wallpaper()` del script, la transición:

```bash
--transition-type wipe    # wipe | wave | grow | fade | left | right | top | bottom
--transition-duration 1.5
--transition-fps 60
```

## Caché de paletas

Los temas de wallust van compilados dentro del binario: no hay ficheros TOML
que leer. Para que cada paleta muestre su color de verdad hay que preguntárselo
a wallust con `wallust theme <tema> -p`, que imprime los 16 colores como
secuencias ANSI `48;2;R;G;B`.

Son 614 llamadas, pero en total tardan ~2,5 s, así que el resultado se guarda
en `cache/palettes.json` y se reutiliza (13 ms). Se rehace sola si wallust
expone otra cantidad de temas, y a mano con `coverflow.sh cache-palettes`.

Sin esta caché, todas las paletas se veían iguales: la muestra usaba
`accent` y `accentAlt` de la paleta **actual**, que en una paleta gris
coinciden y salen como un rectángulo liso.

## Notas

- `swww` se eliminó de los repos: ahora las transiciones las da `awww`.
- `rofi` se usó primero para el menú de modos, pero bajo Hyprland las flechas
  llegaban y el `Enter` no. El menú se hizo en QML y rofi dejó de hacer falta.
- **La ventana es un único `PanelWindow` a pantalla completa, no un `PopupWindow`
  encima.** Se intentó lo segundo para que el compositor entregara el teclado
  mientras el panel estuviera abierto, y no funciona: un popup no puede
  anclarse a una superficie `wlr-layer-shell`, así que Qt no lograba crearlo
  (`Cannot attach popup ... as the popup is not an xdg_popup`) y el panel no
  aparecía nunca. Comprobado con tres QML mínimo de prueba, no es una suposición.
- El foco de teclado lo lleva un `HyprlandFocusGrab`, que es la vía nativa de
  Hyprland: mientras está activo la ventana conserva el foco aunque el ratón se
  vaya del panel. Eso es lo que arregla que las flechas llegaran de forma
  intermitente. `PanelWindow` por sí solo no es modal: está pensado para barras y
  docks, no agarra el teclado por composición.
- **La ventana no lleva `mask: Region`.** Se puso al principio para que solo
  fuera interactivo el panel y el fondo quedara transparente al ratón, de modo
  que el clic fuera cerrara la ventana. El problema es que con la ventana a
  pantalla completa eso dejaba interactivo un 24% del escritorio: la rueda solo
  respondía con el cursor encima del panel, y en cualquier otro sitio se la
  quedaba la ventana que hubiera debajo. Ahora toda la superficie es
  interactiva y el cierre lo hace un `MouseArea` en el fondo que comprueba el
  punto antes de cerrar, para que un clic en hueco *dentro* del panel no lo
  haga. El `onCleared` del grab se queda como red de seguridad.
- El `WheelHandler` cuelga de la ventana, no del panel. Los handlers de puntero
  solo atienden los eventos que caen dentro de su item padre, así que puesto en
  el panel era sordo fuera de sus bordes. Lleva
  `grabPermissions: PointerHandler.CanTakeOverFromAnything` porque en Qt 6 la
  rueda viaja por el flujo de eventos del puntero: sin ese permiso, el
  `DragHandler` de la tira se la queda cuando agarra el ratón al pulsar.
- El destino de un paso se mide desde `targetPos` mientras el resorte va en
  marcha, no desde `stripPos`. Medido desde `stripPos`, dos pulsaciones seguidas
  se pisan —la tira casi no se ha movido todavía— y solo avanzaba una tarjeta,
  que es justo lo que hace que la rueda parezca muerta.
- El cierre no dispara mientras hay un `apply` en marcha: al cambiar el fondo
  Hyprland puede soltar el foco, y cerrar ahí mataría el script a medio camino.
- El tipo `Perspective` de Qt 6 ya no existe. La proyección se hace con una
  tabla por distancia (`cardTransform`), no con matrices.
- La vista ampliada **no** es un `PopupWindow`: es un `Rectangle` dentro de la
  misma ventana, por lo mismo del popup que no se podía anclar. Con `z: 2000` y
  su propio `MouseArea` tapa el fondo, así que sus clics cierran la lupa y no la
  ventana; al no haber máscara, no necesita una `Region` propia.
- Los degradados de los bordes miden 190 px y van por encima de las cartas
  (`z: 900`), no en el panel entero: si no, la tira se cortaría en seco.
- `eww` no se usa. Se probó primero, pero no puede generar widgets en
  bucle sobre un array, que es justo lo que necesita un carrusel. QML sí.
- El overlay usa `exclusionMode: Ignore` y `exclusiveZone: 0`, así que no
  reserva espacio ni redimensiona lo que hay debajo.
- `awww-daemon` se levanta en el autostart de Hyprland vía `restore.sh`,
  que además recupera el último wallpaper aplicado.
- Cuando montes la barra en Quickshell, `coverflow.qsl` se integra como una
  ventana más del shell principal.
