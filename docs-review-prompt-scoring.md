# Prompt de valoración · puntuar la skill contra sus propios objetivos

> **Exento de la regla de idioma del repositorio, y lo declara aquí porque una exención
> estructural que no se declara es la clase de hueco que este método persigue.** Está en
> español, es un encargo para una persona hispanohablante, y no aparece en `MANIFEST`.

Pegar en una sesión de Cowork nueva, sin contexto previo. **Lanzar después de que hayan
entrado los arreglos de la ronda 3**, no antes: puntuar un árbol que va a cambiar mañana es
medir un objeto que se movió.

---

```
Quiero una VALORACION NUMERICA de una skill de Cowork, en ~/claude/gtd-with-claude.
Pide acceso. Solo lectura, salvo tu informe.

No es una ronda de revision. Hay tres informes adversariales en el arbol
(docs-review-findings*.md) y NO los quiero repetidos. Quiero una cifra defendida.

  Informe: ~/claude/gtd-with-claude/docs-review-scoring.md

CUATRO HECHOS QUE NECESITAS ANTES DE EMPEZAR, y el tercero es material:

  - La skill se llama gtd-with-agents. El repositorio y el titulo siguen diciendo
    "with Claude"; solo cambio el identificador, porque el instalador prohibe la
    palabra reservada
  - El bundle lo construye scripts/package_skill.py, no zip. Hay tag y pipeline
  - DOS RELEASES SE PUBLICARON Y NO SE INSTALARON. v0.1.1 por la forma del zip
    (entradas de directorio) y v0.1.2 por el nombre. Las dos pasaron el pipeline
    entero en verde y el validador de referencia. Eso es informacion sobre la
    calidad del metodo, no solo sobre dos bugs, y quiero que pese en la nota
  - Hay una tabla nueva en config-template.md, "Where the method itself is
    installed": cada agente declara si tiene la skill, con fecha. NO es
    verificacion mutua y el documento dice que no lo es

═══════════════════════════════════════════════════════════════════════
LO QUE SE PUNTUA
═══════════════════════════════════════════════════════════════════════

La skill declara TRES objetivos, y dice explicitamente que PESAN IGUAL:

  1. MINIMIZAR la interaccion de la persona
  2. MANTENERLA INFORMADA de lo que se hace, en todo momento
  3. GARANTIZAR que lo que le toca decidir, lo decide SIEMPRE

Y cuatro decisiones cerradas que NO se reabren, pero SI se puntua si se
cumplen: metodo completo y no solo el canal; ingles en todo el contenido del
repositorio; SKILL instalable con README de cara a GitHub; nucleo agnostico
con anexo para lo que dependa de una herramienta.

Seis notas de 0 a 10, cada una con su justificacion:

  A · Objetivo 1 — minimizar interaccion
  B · Objetivo 2 — mantener informado
  C · Objetivo 3 — garantizar la decision
  D · Coherencia con sus propias decisiones cerradas
  E · Instalacion — de descargar el .skill a tenerlo funcionando en los dos lados
  F · GLOBAL — y NO es la media. Di por que no lo es

═══════════════════════════════════════════════════════════════════════
COMO QUIERO QUE PUNTUES, QUE ES LA MITAD DEL ENCARGO
═══════════════════════════════════════════════════════════════════════

1. ANCLA LA ESCALA ANTES DE USARLA. Para cada uno de los tres objetivos,
   escribe PRIMERO que aspecto tendria un 10 y que aspecto tendria un 5, en
   terminos de lo que la persona observa. Despues puntua. Una nota sin escala
   escrita antes es una impresion con un numero encima

2. CADA PUNTO QUE QUITAS TIENE NOMBRE, FICHERO Y LINEA. "Le falta madurez" no
   es una resta. "El arranque en frio no tiene consulta de escaladas
   (bootstrap-cowork.md:31) asi que el objetivo 3 depende de que alguien se
   acuerde" si lo es

3. PUNTUA EL ARTEFACTO, NO SU HISTORIA. Da igual cuanto se ha arreglado, ni
   cuantas rondas ha aguantado, ni lo bien escrito que este. Puntua lo que
   recibe alguien que se lo instala hoy sin conocer nada de esto

4. LA PROSA NO PUNTUA. Este repositorio escribe muy bien y eso es un riesgo de
   medicion, no un merito: un documento persuasivo se lee como un sistema que
   funciona. Si una afirmacion no la sostiene un fichero o un comando, no suma

5. DOS NOTAS EN EL TIEMPO PARA CADA OBJETIVO, y la distancia entre ellas es
   informacion:
     - la que le pondrias tras UNA HORA de uso
     - la que le pondrias tras UN MES, cuando el canal tenga 200 ficheros,
       nadie haya vuelto a leer la configuracion y alguien haya abierto una
       sesion sin el prompt de arranque
   Si la segunda es mucho mas baja, eso es el hallazgo, no la primera nota

6. EJECUTA LO QUE PUEDAS. Hay scripts, hay pipeline, hay un tag. Una nota
   sobre comportamiento sin haber abierto la funcion que lo produce no vale.
   Lo que no puedas ejecutar, dilo como no ejecutado — "no me consta" es un
   resultado

7. NO INFLES Y NO CASTIGUES POR DEPORTE. Un 7 defendido vale mas que un 9
   amable o que un 4 con pose. Si algo esta bien, la nota lo dice

═══════════════════════════════════════════════════════════════════════
LAS PREGUNTAS DIFICILES, UNA POR OBJETIVO
═══════════════════════════════════════════════════════════════════════

  A · ¿Cuanta interaccion quita DE VERDAD? El metodo dice que no despierta a
      nadie y que no contesta un permiso modal. Descontado eso, ¿que queda?
      ¿Y cuanta interaccion NUEVA introduce — escribir mensajes, mantener la
      configuracion, leer el canal? Nota neta, no bruta

  B · ¿Puede la persona contestar "¿que ha pasado desde ayer?" sin preguntar a
      ningun agente? Ejecutalo. Y luego la de fondo: informar exige que
      alguien lea. ¿Que pasa cuando no lee? ¿El metodo lo detecta o sigue
      igual de verde?

  C · ¿Que impide de verdad que se delegue algo del suelo? Distingue lo que
      IMPIDE de lo que es disciplina escrita. Si la respuesta es "nada
      mecanico en dos de las cuatro clases", eso no baja la nota por si solo
      — lo que la baja o la sube es si el metodo LO DICE CLARO

  D · ¿El nucleo es agnostico de verdad, o hay un fichero que asume una
      herramienta concreta sin estar marcado como anexo? Compruebalo, no lo
      supongas

  E · INSTALALA. Es la casilla que nunca se ha cerrado en tres rondas. Coge el
      .skill del release, metelo en las dos partes -- perfil de Claude y
      ~/.claude/skills o .claude/skills -- y comprueba que los comandos de
      instalacion del README hacen lo que dicen. Si algo falla ahi, es la nota
      mas importante del informe, porque es lo primero que le pasa a cualquiera

  F · LA TABLA DE INSTALACION, que es lo ultimo que se ha anadido y por tanto lo
      menos probado. Cada agente declara si tiene la skill y compara con su fila;
      si discrepan, corrige el fichero y lo anota. Preguntas: ¿que pasa si los
      dos agentes corrigen la misma fila a la vez? ¿que pasa la primera vez, con
      el fichero recien escrito y ninguna sesion abierta? ¿anade mas interaccion
      de la que quita? ¿y es honesta la distincion entre autoinforme y
      verificacion, o se lee como si el metodo comprobara algo que no comprueba?

═══════════════════════════════════════════════════════════════════════
COMO QUIERO EL INFORME
═══════════════════════════════════════════════════════════════════════

  1. Que ejecutaste y que no. Al principio, antes de cualquier nota
  2. Las escalas ancladas: que es un 10 y que es un 5, por objetivo
  3. Las seis notas, con las restas nombradas
  4. La tabla una hora / un mes
  5. LO QUE MAS SUBE LA NOTA MAS BAJA con un solo cambio. Uno, no una lista
  6. ¿Que nota le pondrias a esta skill frente a NO USAR NINGUN METODO y
     limitarse a copiar y pegar entre las dos sesiones? Es la comparacion
     honesta, y puede salir mal
  7. La E va con su propio relato: dos releases no instalaron, asi que di
     tambien que habria hecho falta para cazarlos ANTES de publicar
  8. La pregunta que no te he hecho y que habria cambiado alguna nota

No quiero elogios, ni reescrituras de estilo, ni propuestas de funcionalidad
nueva. Quiero seis numeros que aguanten que alguien discuta cada uno.
```
