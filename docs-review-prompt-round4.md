# Prompt para la cuarta sesión adversarial · validar los cambios, y nada más

> **Exento de la regla de idioma del repositorio, y lo declara aquí porque una exención
> estructural que no se declara es la clase de hueco que este método persigue.** Está en
> español, es un encargo para una persona hispanohablante, y no aparece en `MANIFEST`.

Pegar en una sesión de Cowork nueva, sin contexto previo.

---

```
Cuarta ronda adversarial sobre una skill de Cowork, en ~/claude/gtd-with-claude.
Pide acceso. Solo lectura, salvo tu informe.

  Informe: ~/claude/gtd-with-claude/docs-review-findings-r4.md

QUIERO HALLAZGOS, NO UN JUICIO. Nada de valoraciones de conjunto, nada de "en
general esto esta bien/mal", nada de recomendar si publicar. Un hallazgo trae su
reproduccion y cualquiera lo puede volver a ejecutar; un veredicto no trae nada
y es lo primero que la gente se cree. Cada cosa que encuentres, con el comando
que la ensena. El resto, no.

Hay tres informes adversariales previos en el arbol (docs-review-findings*.md).
NO los repitas. Lo tuyo es lo que se hizo DESPUES del tercero.

CUATRO HECHOS, y el tercero es material:

  - La skill se llama ahora gtd-with-agents. El repositorio y el titulo siguen
    diciendo "with Claude"; solo cambio el identificador
  - El arbol puede tener cambios sin confirmar. Mira git status y DI sobre que
    estas trabajando: confirmado, sin confirmar, o mezcla
  - DOS RELEASES SE PUBLICARON Y NO SE INSTALARON. v0.1.1 por la forma del zip
    (entradas de directorio, compresion mezclada) y v0.1.2 porque el nombre
    contenia una palabra reservada. Las dos pasaron el pipeline entero en verde
    Y el validador de referencia
  - Los cambios que vas a validar los escribio la misma sesion que causo esos
    dos fallos, en una sola pasada, sin que nadie los haya mirado

Esta es la lista de lo que se dice haber cambiado. NO TE FIES DE ELLA: es la
lista del que hizo el trabajo, y una lista escrita a mano mide a quien la
escribio. Comprueba tambien que no hay cambios FUERA de ella.

═══════════════════════════════════════════════════════════════════════
1 · scripts/check_doc_commands.py, REESCRITO ENTERO
═══════════════════════════════════════════════════════════════════════

Antes comparaba totales de lineas por bloque; ahora dice comparar CONJUNTOS de
nombres de fichero por consulta. Y su fixture ya no esta reimplementado a mano:
dice extraer y ejecutar el bloque escritor de assets/message-template.md.

  a) EJECUTALO. Sale en verde. ¿Verde por el motivo correcto, o porque ya no
     mira lo que miraba? Cuenta cuantas consultas compara y contra que
  b) LA PRUEBA QUE IMPORTA: reintroduce R2-01 como el PAR que era -- el escritor
     con dos espacios Y la consulta con uno -- y comprueba que lo caza. Se dice
     verificado; verificalo tu
  c) SU CLASIFICADOR decide que verdad de referencia aplica a cada consulta
     mirando texto: "state: +escalated" antes que "state: +open" antes que
     "from: +owner". ¿Que consulta razonable clasifica MAL? Escribe una
  d) DECLARA "12 unidades no son consultas de canal y 27 bloques van en vallas
     que no son ```sh". ¿Es cierto? ¿Y que hay en esas 27, exactamente? Los dos
     prompts de arranque estan ahi dentro, y son los comandos que los agentes
     ejecutan de verdad
  e) SU SELF-TEST compara conjuntos de hallazgos y corre contra consultas
     canonicas guardadas en el propio fichero. Borra una regla del comprobador
     y mira si el self-test grita. Si no grita, es R2-04 otra vez

═══════════════════════════════════════════════════════════════════════
2 · scripts/package_skill.py, NUEVO — es el que arreglo v0.1.1
═══════════════════════════════════════════════════════════════════════

Construye el .skill desde Python y comprueba la FORMA: solo ficheros, todo
deflated, exactamente el manifest, una raiz.

  a) Sus tres defectos de forma se prueban rompiendolos. ¿Falta alguno? ¿Que
     otra propiedad de un zip puede impedir una instalacion y no esta mirada?
  b) COMPARALO contra la implementacion de referencia real, que esta en la skill
     skill-creator del sistema (scripts/package_skill.py). ¿Se parece en todo lo
     que importa, o solo en lo que se miro?
  c) Las reglas de forma se dedujeron de UN fallo observado. ¿Que mas rechaza el
     instalador que aqui no se comprueba? El precedente es la palabra reservada:
     estaba en el instalador y no en el validador de referencia
  d) validate_skill.py tiene ahora --exact y una lista RESERVED_IN_NAME donde
     "claude" es observado y "anthropic" es INFERIDO, y lo declara. ¿Correcto,
     o es una entrada que rompera un nombre legitimo algun dia?

═══════════════════════════════════════════════════════════════════════
3 · reference/floor-mechanism.md, REORDENADO
═══════════════════════════════════════════════════════════════════════

Cuatro pasos agnosticos arriba, Claude Code como ejemplo etiquetado debajo.
Cinco peticiones de prueba en vez de cuatro. Los patrones se declaran
ilustrativos e incompletos. El log nace con las peticiones dentro y los
resultados vacios, y se puede comprobar con un grep.

  a) ¿SON EJECUTABLES LOS CUATRO PASOS por alguien que use OTRA herramienta, o
     siguen necesitando el ejemplo? Leelos como si no conocieras Claude Code
  b) LAS CINCO PETICIONES dicen probar cinco propiedades distintas. ¿Es cierto
     ahora? La ronda 3 encontro dos que probaban la misma
  c) EJECUTA el bloque del log. ¿Un log a medias se distingue de uno completo?
     ¿El grep de comprobacion hace lo que dice?
  d) La regla nueva es que "attempted, not verified" es el valor por defecto.
     ¿Lo dicen TODOS los sitios que enumeran los tres valores, o solo dos?

═══════════════════════════════════════════════════════════════════════
4 · reference/approvals.md — las 24 redacciones (R2-10, dado por cerrado)
═══════════════════════════════════════════════════════════════════════

Llevaba tres rondas abierto. Se dice que ahora estan las 24.

  a) CUENTALAS. 8 actividades x 3 niveles. ¿Estan las 24 o hay 21 y tres huecos?
  b) LA REGLA es que cada opcion lleva su GANANCIA y su COSTE en la misma frase.
     ¿Cuantos de esos costes son costes de verdad y cuantos son la ganancia
     dicha al reves? "menos control" no es un coste; "aprendes la forma del
     historial despues de escrito" si
  c) ¿HAY ALGUNA QUE MIENTA? Un coste que exagera para empujar hacia DECIDE es
     tan manipulador como uno que se calla
  d) NOT APPLICABLE pasa a escribirse "NOT APPLICABLE — <motivo>" como un solo
     valor. ¿Esta asi en los CUATRO sitios que enumeran niveles? La ronda 3
     encontro que estaba en dos de cuatro

═══════════════════════════════════════════════════════════════════════
5 · La tabla de instalacion — LO ULTIMO ESCRITO, LO MENOS PROBADO
═══════════════════════════════════════════════════════════════════════

config-template.md gana "Where the method itself is installed": una fila por
agente, con fecha. Cada sesion compara su propia fila al arrancar; si coincide,
silencio; si no, corrige el fichero y lo anota en el canal. El lado revisor lee
ademas la fila del otro.

  a) ¿QUE PASA LA PRIMERA VEZ, con el fichero recien escrito y ninguna sesion
     abierta todavia?
  b) ¿Y SI LOS DOS AGENTES corrigen la misma fila a la vez? El fichero de
     configuracion pasa a tener dos escritores, que es exactamente lo que
     protocol.md rechaza para un fichero de estado. ¿Es el mismo defecto?
  c) ¿ANADE MAS INTERACCION DE LA QUE QUITA? Cuentala
  d) LA PREGUNTA HONESTA: el documento insiste en que es un autoinforme y no una
     verificacion. ¿Se LEE asi, o se lee como si el metodo comprobara algo? Si
     alguien acaba creyendo que los agentes se verifican entre si, la tabla ha
     empeorado el sistema aunque cada frase suya sea cierta
  e) ¿Y QUE PASA CUANDO LA FILA MIENTE? Un agente sin la skill que igualmente
     dice tenerla, o una fila de enero leida en marzo

═══════════════════════════════════════════════════════════════════════
6 · INSTALALA, que es la casilla que tres rondas no han cerrado
═══════════════════════════════════════════════════════════════════════

Coge el .skill, metelo en las dos partes -- perfil de Claude y ~/.claude/skills
o .claude/skills -- y comprueba que los comandos de instalacion del README hacen
exactamente lo que dicen. Es lo primero que le pasa a cualquiera que llegue al
repositorio, y es lo unico que dos releases seguidas no consiguieron.

Sin valorarlo. Si falla, describe como falla y en que paso.

═══════════════════════════════════════════════════════════════════════
7 · Y LA PREGUNTA DE LAS TRES RONDAS ANTERIORES
═══════════════════════════════════════════════════════════════════════

CADA ARREGLO INTRODUJO UN DEFECTO NUEVO EN OTRO FICHERO. Las tres veces.
Buscalo explicitamente: no preguntes "¿esta arreglado?", pregunta "¿QUE ROMPIO
EL ARREGLO?".

Sospechas concretas para empezar:
  - Se anclaron ~14 consultas de ^from:/^re: y se metio una linea en blanco en
    dos bloques para que el comprobador los separase. ¿Cambio eso lo que alguna
    consulta devuelve? Se dice comprobado; comprueba
  - verification.md gano una seccion 11 con seis filas. ¿Contradice alguna a las
    diez secciones anteriores?
  - README.md y SKILL.md se tocaron cuatro veces en la misma sesion. ¿Siguen
    diciendo lo mismo entre si y que reference/?
  - El renombrado toco cinco ficheros con un reemplazo de texto. ¿Quedo algo?

═══════════════════════════════════════════════════════════════════════
COMO QUIERO EL INFORME
═══════════════════════════════════════════════════════════════════════

  1. Que examinaste y que no, ANTES de cualquier hallazgo. Incluido lo que
     intentaste y no pudiste. "No me consta" es un resultado; "no funciona"
     sobre algo no ejecutado, no
  2. QA: prueba, esperado, obtenido, PASA/FALLA, con la salida real
  3. Los hallazgos con fichero y linea, ordenados por coste
  4. DEFECTO / LAGUNA / DECISION SIN TOMAR
  5. Que rompio cada arreglo
  6. Lo que NO cambiarias, y por que
  7. La pregunta que el documento no se hace

Y lo del principio, que es lo que hace que este informe siga sirviendo dentro de
un mes: NINGUN VEREDICTO GLOBAL, ninguna valoracion de conjunto, ningun "esto ya
esta listo". Solo lo que encontraste y como reproducirlo. Un hallazgo envejece
bien porque se puede reejecutar; una opinion sobre el estado general envejece el
mismo dia y arrastra a quien la lea.

Tampoco quiero elogios, ni reescrituras de estilo, ni funcionalidad nueva, ni
reabrir las cuatro decisiones cerradas -- alcance, ingles, formato, nucleo
agnostico con anexo.
```
