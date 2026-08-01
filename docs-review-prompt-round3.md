# Prompt para la tercera sesión adversarial

> **Exento de la regla de idioma del repositorio, y lo declara aquí porque una exención
> estructural que no se declara es la clase de hueco que este método persigue.** Está en
> español, es un encargo para una persona hispanohablante, y no aparece en `MANIFEST`.

Pegar en una sesión de Cowork nueva, sin contexto previo.

---

```
Tercera ronda sobre una skill de Cowork, en ~/claude/gtd-with-claude. Pide acceso.

Las dos anteriores encontraron 17 y 18 cosas. La primera leyendo, la segunda
EJECUTANDO -- y la segunda encontro que los cinco defectos mas caros estaban en
comandos que se habian escrito y nunca corrido, incluida la consulta mas citada
del sistema, que no casaba con nada.

Esta ronda existe porque de ahi salio una regla nueva, y las reglas nuevas son
donde aparecen los defectos nuevos:

    UN BLOQUE DE COMANDOS EN LA DOCUMENTACION ES UNA AFIRMACION, Y SE EJECUTA.

Hay un scripts/check_doc_commands.py que lo intenta. NO TE FIES DE EL: lo escribio
la misma sesion que escribio los comandos que debe comprobar, y ya se sabe que su
comparacion es tosca. Es el primer objetivo.

Y hay un hecho nuevo que las dos rondas anteriores no tuvieron: EL REPOSITORIO
EXISTE, TIENE UN TAG v0.1, Y EL PIPELINE DE RELEASE SE HA EJECUTADO DE VERDAD.
Fallo. Abajo esta su salida literal.

  ~/claude/gtd-with-claude   SOLO LECTURA, salvo tu informe
  /tmp/gtd-qa3-<fecha>/      tuyo
  Informe: ~/claude/gtd-with-claude/docs-review-findings-r3.md

═══════════════════════════════════════════════════════════════════════
0 · LA EVIDENCIA QUE YA HAY, Y QUE NADIE HA INTERPRETADO
═══════════════════════════════════════════════════════════════════════

Run 30708254775, 18 segundos, paso "The documented commands do what they claim":

    FAIL assets/exchange-README.md:70 returned 18, the fixture has 3 open
        ['20260801-100000-cowork-q1.md', '20260801-100100-cowork-q2.md',
         '20260801-100200-code-q3.md', '20260801-100500-code-esc-live.md']
    FAIL reference/protocol.md:289 returned 14, the fixture has 2 owner
        ['20260801-100700-cowork-decision.md', '20260801-100800-code-decision.md',
         '20260801-100000-cowork-q1.md', '20260801-100100-cowork-q2.md']
    FAIL assets/config-template.md:96 returned 17, the fixture has 1 escalated
        ['./message-template.md', './20260801-100200-code-q3.md',
         './20260801-100800-code-decision.md', './20260801-100700-cowork-decision.md']

    EXAMINED: 5 command blocks over 8 documents, against a 10-message fixture
      ok   notices an extra owner message

Tres cosas de ahi, y quiero tu lectura de las tres, no la mia:

  - El self-test salio VERDE y la comprobacion real ROJA. O el instrumento
    funciona y la documentacion esta mal, o el self-test prueba algo que no es
    lo que falla. Decide cual
  - Los ficheros devueltos NO CUADRAN con la etiqueta. El primero devuelve una
    escalacion contando "abiertas"; el tercero devuelve message-template.md, que
    es el instrumento, contando "escaladas"
  - Corriendo en local, el tercero devolvia 18 y config-template.md estaba en la
    linea 88, no en la 96. LAS CIFRAS NO SON ESTABLES ENTRE ENTORNOS. Averigua
    por que: si un comprobador da numeros distintos segun donde corra, ninguno
    de los dos numeros significa nada todavia

═══════════════════════════════════════════════════════════════════════
1 · EL COMPROBADOR DE PROSA, QUE ES EL SOSPECHOSO PRINCIPAL
═══════════════════════════════════════════════════════════════════════

  a) EJECUTALO Y DECIDE, discrepancia por discrepancia, cual de las dos partes
     esta mal. Es la pregunta que la sesion que lo escribio no puede contestar
     sobre si misma
  b) SU HEURISTICA: mapea un bloque entero a UNA expectativa mirando si el texto
     contiene "open", "escalated" u "owner". Un bloque con tres consultas cuenta
     todas sus lineas contra una sola cifra. ¿Cuanto de lo que reporta es eso?
     Y si es todo: el comprobador no ha encontrado ningun defecto de la
     documentacion todavia, y decirlo asi es parte del hallazgo
  c) ROMPELO A PROPOSITO: mete un comando roto en un documento y mira si lo caza.
     Mete uno correcto que el no sepa clasificar y mira si lo llama defecto.
     Un comprobador que solo se ha visto fallar de una manera no esta probado
  d) SU AMBITO: declara "5 bloques sobre 8 documentos". ¿Cuantos bloques ```sh
     hay de verdad en el arbol? Si mira menos de los que hay, es la forma exacta
     -- ambito declarado que nadie juzga -- que las dos rondas anteriores
     encontraron tres veces
  e) Y LA PREGUNTA DE FONDO: ¿es este el instrumento correcto, o solo el primero
     que se le ocurrio a quien tenia el problema delante?

  NO LO ARREGLES HASTA HABER CONTESTADO (a). Un comprobador que su autor ajusta
  hasta que sale verde no vale nada, y aqui el autor es la sesion anterior.

═══════════════════════════════════════════════════════════════════════
2 · LO QUE LA RONDA 2 ARREGLO, COMPROBADO Y NO PREGUNTADO
═══════════════════════════════════════════════════════════════════════

docs-review-findings-r2.md tiene 18 hallazgos con sus reproducciones. REEJECUTA
las que traigan comando. Y presta atencion especial a estos cuatro, porque cada
arreglo toco varios ficheros y un cambio que toca varios ficheros se aplica
entero en unos y a medias en otros -- que es como la ronda 2 encontro la mitad
de lo suyo:

  - Se quito el relleno del front matter y se endurecieron ~40 consultas a
    -E '^clave: +valor'. ¿Queda alguna con un solo espacio? ¿Alguna sin ancla $
    que vuelva a casar con la documentacion del formato?
  - El parrafo que partia la tabla del semaforo se movio debajo. ¿RENDERIZA la
    tabla con sus tres filas? Comprueba el render, no el texto
  - El self-test del validador ahora corre cada mutacion con y sin manifest.
    ¿Prueba cada mutacion la regla que NOMBRA, o hay otra que la caza antes?
    Borra una regla a proposito -- la comprobacion Y su retorno temprano -- y
    mira si grita
  - El validador ahora busca MANIFEST por defecto. ¿Que pasa si lo invocas desde
    otro directorio? ¿Y si hay dos MANIFEST?

═══════════════════════════════════════════════════════════════════════
3 · LO QUE SIGUE ABIERTO, Y ES DECISION DE UNA PERSONA
═══════════════════════════════════════════════════════════════════════

R2-06 Y R2-11 SE CERRARON AYER, y quiero que ataques los cierres -- no que
compruebes que existen. Un arreglo reciente escrito por la misma sesion que
causo el defecto es el sospechoso natural, y las dos rondas anteriores
encontraron que CADA arreglo metio un defecto nuevo en otro fichero.

  R2-06 · hay un reference/floor-mechanism.md NUEVO con el procedimiento: donde
          viven las reglas, que escribir, cuatro peticiones que las prueban, y
          que aspecto tiene una regla inerte. Y la casilla de configuracion pasa
          a exigir RUTA A UN LOG: nunca "verified" sin fichero.

          ATACALO: ¿las reglas deny de ejemplo son correctas? ¿alguna caza a su
          vecina, como paso con --force y --force-with-lease? ¿las cuatro
          peticiones de prueba distinguen de verdad los cuatro casos, o hay dos
          que dan el mismo resultado por motivos distintos? ¿el fichero es
          especifico de una herramienta en un nucleo que dice ser agnostico?
          Y la de fondo: un procedimiento escrito y nunca ejecutado es
          exactamente lo que la ronda 2 encontro seis veces.

  R2-11 · se anadio NOT APPLICABLE como cuarto valor, con la obligacion de
          escribir el motivo.

          ATACALO: la ronda 2 critico el vocabulario de estados por sobrecargado
          y ahora hay un cuarto valor en OTRO vocabulario. ¿Esta en TODOS los
          sitios que enumeran niveles, o solo en dos? ¿Que hace un agente con
          NOT APPLICABLE en un grupo de tres actividades donde solo una no
          aplica? ¿Y como se distingue de un hueco sin rellenar?

R2-10 SIGUE ABIERTO y no se ha tocado: la regla dice que CADA opcion lleva su
coste en la misma frase, y hay 3 redacciones de las 24 que hacen falta. Con
NOT APPLICABLE ahora son mas. Dime si eso lo empeora.

═══════════════════════════════════════════════════════════════════════
4 · Y LO QUE NADIE HA MIRADO TODAVIA
═══════════════════════════════════════════════════════════════════════

Cuatro sospechas mias, suelo y no guion. Si alguna no es problema, dimelo:

  a) EL PIPELINE CORRIO Y PARO EN EL SEXTO PASO. Los pasos POSTERIORES -- montar
     desde MANIFEST, empaquetar, validar el bundle extraido, publicar -- NUNCA
     SE HAN EJECUTADO. Ni una vez, ni aqui ni en las dos rondas anteriores.
     Todo lo que el repositorio afirma sobre el empaquetado sigue siendo
     reconstruccion. Reproducelos a mano si puedes y di que encuentras
  b) EJECUTA LO QUE PUEDAS DEL PIPELINE DE VERDAD en vez de reproducirlo -- es
     la diferencia entre evidencia y reconstruccion. Hay tag, hay remoto, hay
     historial de runs. Lo que no puedas ejecutar, dilo como no ejecutado
  c) DOS RONDAS DE ARREGLOS Y NADIE HA VUELTO A LEER EL METODO ENTERO DE
     PRINCIPIO A FIN. Los parches son locales; la coherencia es global. ¿Sigue
     diciendo lo mismo README.md, SKILL.md y reference/ sobre las mismas cosas?
  d) LA SKILL SIGUE SIN INSTALARSE NUNCA de verdad, y ahora ademas NO HAY BUNDLE
     PUBLICADO porque el release fallo. La ronda 2 lo midio con un proxy y lo
     declaro como tal. ¿Puedes hacer mejor, o hay que aceptar que esa casilla
     solo la cierra una persona?

═══════════════════════════════════════════════════════════════════════
COMO QUIERO EL INFORME
═══════════════════════════════════════════════════════════════════════

  1. QA primero: prueba, esperado, obtenido, PASA/FALLA, con la salida real
  2. Las tres discrepancias del run, una a una: ¿documentacion o comprobador?
  3. Que hallazgos de r1 y r2 siguen abiertos, comprobado
  4. Los nuevos, con fichero y linea, por coste
  5. DEFECTO / LAGUNA / DECISION SIN TOMAR
  6. Lo que NO arreglarias
  7. La pregunta que el documento no se hace

Declara al principio que examinaste y que no, incluido lo que intentaste y no
pudiste. "No me consta" es un resultado; "no funciona" sobre algo no ejecutado,
no.

Y UNA COSA MAS, que es la razon de esta ronda: LAS DOS ANTERIORES ENCONTRARON
QUE CADA ARREGLO INTRODUJO UN DEFECTO NUEVO EN OTRO FICHERO. Busca eso
explicitamente. No preguntes solo "¿esta arreglado?", pregunta "¿que rompio el
arreglo?".

No quiero elogios, ni reescrituras de estilo, ni reabrir las cuatro decisiones
cerradas -- alcance, ingles, formato, nucleo agnostico con anexo -- y no des por
bueno nada porque un informe anterior diga que se hizo.
```
