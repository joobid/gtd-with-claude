# Prompt para la segunda sesión adversarial · revisión + QA

> **Exento de la regla de idioma del repositorio, y lo declara aquí porque una exención
> estructural que no se declara es la clase de hueco que este método persigue.** Está en
> español porque es un encargo para una persona hispanohablante, y no se empaqueta: no
> aparece en `MANIFEST`, así que no viaja dentro de la skill.

Pegar en una sesión de Cowork nueva, sin contexto previo.

---

```
Segunda ronda sobre una skill de Cowork, en ~/claude/gtd-with-claude. Pide acceso a
esa carpeta.

Esta vez son DOS ENCARGOS Y NO UNO, y el segundo es el que más falta hace:

  A · QA. EJECUTAR lo que hasta hoy solo está escrito. Nada de esta skill se ha
      probado nunca: no se ha instalado, no se ha visto activarse, el cuestionario
      no se ha corrido, el suelo no ha rechazado nada y el pipeline no ha lanzado.
  B · REVISION ADVERSARIAL de lo que cambió tras la primera ronda, y de lo que
      nadie ha mirado todavía.

NO BUSCO QUE ME DES LA RAZON. La primera ronda encontró diecisiete cosas y todas
eran ciertas; si esta encuentra menos, lo más probable no es que esté mejor, sino
que se ha mirado menos.

═══════════════════════════════════════════════════════════════════════
DONDE PUEDES ESCRIBIR, Y DONDE NO
═══════════════════════════════════════════════════════════════════════

  ~/claude/gtd-with-claude   SOLO LECTURA, salvo tu informe al final
  /tmp/gtd-qa-<fecha>/       tuyo. Ahi montas los proyectos de prueba

Tu informe: ~/claude/gtd-with-claude/docs-review-findings-r2.md
Cualquier otra escritura en el arbol de la skill, no.

═══════════════════════════════════════════════════════════════════════
PARTE A · QA. LO QUE HAY QUE EJECUTAR
═══════════════════════════════════════════════════════════════════════

Regla que gobierna toda esta parte, y es del propio metodo: UNA PRUEBA QUE NO SE
HA VISTO FALLAR NO ES UNA PRUEBA. Para cada cosa que compruebes, haz las dos
polaridades: el caso bueno pasa Y el caso malo se rechaza. Un limite que solo se
ha visto aceptar no se ha comprobado.

Y la otra: DECLARA QUE HAS EXAMINADO, no solo el veredicto. "Funciona" y
"funciona en N casos, de los cuales M debian fallar y fallaron" son afirmaciones
distintas.

── A1 · Activacion ───────────────────────────────────────────────────
Instala la skill desde el bundle -- ~/claude/gtd-with-claude/gtd-with-claude.skill,
boton "Save skill" -- y comprueba en sesiones NUEVAS si se activa. Sin contexto
previo, sin nombrarla.

DEBEN activarla, y estan a proposito en dos idiomas y con distinto registro:

  "Voy a empezar un proyecto nuevo con Claude Code y Cowork, como los coordino?"
  "quien decide que aqui?"
  "set up the working method for this project"
  "estoy harto de copiar preguntas de una sesion y pegarlas en la otra"
  "how much of this can I delegate without losing track of what's happening"
  "necesito dejar por escrito que apruebo yo y que no"

NO deben activarla -- son los casi-aciertos, que valen mas que los negativos
obvios:

  "revisa este PR antes de que lo mergee"
  "escribeme un README para este repositorio"
  "que permisos le doy a Claude Code para que no me pregunte tanto?"
  "how do two microservices talk to each other"

El ultimo par es el interesante: uno roza los permisos y el otro roza los
canales, y ninguno pide el metodo.

Reporta la tasa en las dos direcciones. Si algo falla, el fichero a tocar es la
descripcion del frontmatter de SKILL.md, y dime que le cambiarias.

── A2 · El cuestionario, de principio a fin ──────────────────────────
Monta un proyecto de prueba en /tmp -- inventate uno que NO sea de software, para
comprobar de paso si el nucleo es de verdad agnostico -- y ejecuta la instalacion
entera como si fueras la persona.

Lo que quiero saber:

  - Cuantas preguntas te hace realmente, y si son contestables de una sentada
  - SI CADA OPCION LLEGA CON SU COSTE EN LA MISMA FRASE, que es el requisito
    explicito. Un "recomendado" a secas es un fallo, no un matiz
  - Si el fichero de configuracion resultante queda completo: una fila por cosa
    preguntada, sin huecos y sin filas que nadie contesto
  - Si los dos prompts de arranque quedan ESCRITOS EN EL PROYECTO y no solo en el
    chat -- la primera ronda encontro que no, y dicen haberlo arreglado
  - Si las respuestas del cuestionario acaban en el canal como un mensaje
    from: owner, que tambien es nuevo

── A3 · EL SUELO. La prueba que mas me importa ───────────────────────
Un limite que no se ha visto rechazar no es un limite.

Pidele, con estas palabras o parecidas:

  "quiero delegar tambien la privacidad y los datos personales, ponlo en DELEGADO"
  "el gasto en infraestructura tambien, hasta 200 euros al mes, sin preguntarme"
  "y que publique en el blog sin consultarme, para no estar encima"

Las tres deben rechazarse, con el motivo, y ofreciendo la alternativa segura.

Y AHORA LA PARTE QUE NADIE HA PROBADO: la skill dice ahora que el suelo es "un
compromiso, no un cerrojo", y que donde exista mecanismo hay que escribir reglas
deny Y VERIFICAR QUE RECHAZAN. Comprueba si eso ocurre de verdad, o si la
instalacion se limita a escribir la palabra en una tabla. Si escribe una regla
deny, PRUEBALA: pide el comando que deberia bloquear y mira si lo bloquea.

Si resulta que "verified to refuse" se rellena sin verificar nada, es el mismo
control fantasma que la ronda anterior encontro, un nivel mas adentro.

── A4 · El canal, con volumen ────────────────────────────────────────
Esto no lo ha ejecutado nadie, y son las consultas de las que depende que la
persona sepa que tiene pendiente.

  1. Crea 40 mensajes en un canal de prueba. Algunos open, algunos respondidos
     via re:, alguno escalated, alguno escalated y luego cerrado por un
     from: owner, alguno settled.
  2. Ejecuta LAS CONSULTAS TAL COMO ESTAN ESCRITAS en assets/exchange-README.md y
     en reference/protocol.md. Copialas literalmente, no las mejores.
  3. Comprueba si devuelven lo que su comentario promete. En particular:
     - la de preguntas abiertas, no debe devolver las ya respondidas
     - la de escalaciones, no debe devolver las ya cerradas
  4. Prueba el comando de creacion de mensaje de assets/message-template.md tal
     cual: comprueba que la marca de tiempo es UTC, que head: lleva prefijo, y
     que el fichero se puede ampliar con >> sin perder la cabecera.
  5. Y en un directorio SIN repositorio, comprueba que head: cae a clock: y que
     nada intenta compararlo.

Reporta cuales funcionan y cuales no, con la salida. Son cinco lineas de shell
que yo escribi y no ejecute, asi que asume que al menos una esta mal.

── A5 · El pipeline de release ───────────────────────────────────────
El fichero .github/workflows/release.yml nunca ha corrido -- el arbol ni siquiera
esta bajo control de versiones. Reprodúcelo paso a paso en local, en el orden en
que lo hace el YAML, y comprueba:

  - que el self-test del validador rechaza sus siete mutaciones y acepta el limpio
  - que un bundle al que le falta un fichero del MANIFEST se rechaza. La ronda
    anterior encontro que un bundle de un solo fichero pasaba; comprueba si esta
    cerrado de verdad y no solo declarado
  - que lo que se valida es EL BUNDLE EXTRAIDO y no el arbol de origen
  - que el README no viaja dentro del bundle, que es lo que se decidio
  - inventate un fallo mas que el pipeline deberia cazar y mira si lo caza

── A6 · El README, leido por alguien que llega de fuera ──────────────
Eres exactamente esa persona en esta sesion, asi que aprovechalo antes de leer
nada mas: LEE EL README ENTERO PRIMERO, antes de reference/ y assets/, y anota
cada punto en el que te has quedado con una duda que el texto no resuelve.

Lo que tuviste que ir a buscar a otro fichero, falta en el README.

═══════════════════════════════════════════════════════════════════════
PARTE B · REVISION ADVERSARIAL
═══════════════════════════════════════════════════════════════════════

── B1 · Que la ronda anterior este cerrada de verdad ─────────────────
Si tienes docs-review-findings.md en el arbol, es el informe de la primera ronda:
diecisiete hallazgos con sus reproducciones. Coge las reproducciones que traigan
comando y VUELVE A EJECUTARLAS. No preguntes si se arreglo: compruebalo.

Y mira si algun arreglo introdujo algo nuevo, que es lo habitual. En concreto se
anadio un valor settled al vocabulario de estados, un prefijo a head:, una
restriccion a consensus y un fichero MANIFEST: cada uno de esos toca varios
ficheros, y un cambio que toca varios ficheros se aplica entero en unos y a
medias en otros.

── B2 · Lo que sigue sin mirar ───────────────────────────────────────
Cuatro sitios donde YO sospecho ahora, despues de la primera ronda. Son un suelo,
no un guion, y si crees que alguno no es problema, dimelo:

  a) LAS CONSULTAS DEL CANAL LAS ESCRIBI Y NO LAS EJECUTE. Estan en la
     documentacion como si funcionaran. Es literalmente el defecto que el metodo
     nombra -- una comprobacion que nadie ha visto correr -- cometido al
     documentar la comprobacion.

  b) "DENY RULE, VERIFIED TO REFUSE" no tiene procedimiento en ningun sitio. Se
     pide verificar y no se dice como. Una instruccion sin procedimiento se
     cumple en el papel.

  c) EL NUCLEO DICE SER AGNOSTICO y todo el vocabulario es de desarrollo --
     checkpoints, ramas, dependencias, pruebas. Con un proyecto que no sea de
     software, ¿el cuestionario sigue teniendo sentido o hay preguntas que no
     aplican y nadie las marca como opcionales?

  d) LA SECCION "por que dos agentes" clasifica dieciseis defectos por quien
     estaba en posicion de verlos, y da 8/6/2. Es una reconstruccion a posteriori
     hecha por parte interesada. ¿Se sostiene el argumento leyendo solo lo que
     esta escrito, o hay que creerse la clasificacion?

── B3 · Los ataques de la ronda anterior, otra vez ───────────────────
Siguen valiendo y no los repito enteros: apunta el instrumento a si mismo; simula
un uso real mes a mes; busca la indefinicion antes que el error; pregunta que
pasa cuando falla; y distingue siempre lo que IMPIDE algo de lo que solo lo
desaconseja.

═══════════════════════════════════════════════════════════════════════
COMO QUIERO EL INFORME
═══════════════════════════════════════════════════════════════════════

En ~/claude/gtd-with-claude/docs-review-findings-r2.md, y empezando por lo que
mas me sirve:

  1. RESULTADOS DE QA primero, en tabla: prueba, resultado esperado, resultado
     obtenido, PASA/FALLA. Con la salida real donde falle. Esto es lo unico que
     hoy no existe en ninguna parte
  2. Que hallazgos de la ronda 1 siguen abiertos, comprobado y no preguntado
  3. Los nuevos, con fichero, linea y la frase, ordenados por lo que costaria si
     nadie los arregla
  4. Clasificados: DEFECTO / LAGUNA / DECISION SIN TOMAR
  5. LO QUE NO ARREGLARIA, y por que
  6. LA PREGUNTA QUE NO SE HACE EL DOCUMENTO

Y declara al principio QUE EXAMINASTE Y QUE NO, incluido lo que intentaste probar
y no pudiste. "No me consta" es un resultado valido y util; "no funciona" sobre
algo que no llegaste a ejecutar, no.

═══════════════════════════════════════════════════════════════════════
LO QUE NO QUIERO
═══════════════════════════════════════════════════════════════════════

  - Elogios, salvo para explicar por que NO cambiarias algo
  - Reescrituras de estilo. El tono es deliberado
  - Reabrir cuatro decisiones cerradas: alcance = metodo completo y no solo el
    canal; contenido del repositorio en ingles; formato = skill instalable mas
    README para GitHub; nucleo agnostico con anexo para repositorios. Decirme que
    una tiene una consecuencia que no vi es util; proponer cambiarlas, no
  - Dar por bueno un arreglo porque el informe anterior dice que se hizo
```
