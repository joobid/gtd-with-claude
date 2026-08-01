# Prompt para una sesión de revisión crítica

> **Exento de la regla de idioma del repositorio, y lo declara aquí porque una exención
> estructural que no se declara es la clase de hueco que este método persigue.** Está en
> español porque es un encargo para una persona hispanohablante, y no se empaqueta: no
> aparece en `MANIFEST`, así que no viaja dentro de la skill.

Pegar en una sesión de Cowork nueva, sin contexto previo del proyecto.

---

```
Vas a hacer una revisión crítica adversarial de una skill de Cowork. Está en
~/claude/gtd-with-claude y hay que pedir acceso a esa carpeta para leerla.

NO ESCRIBAS NADA EN ELLA. Esta sesión solo lee.

EL ENCARGO, y quiero que lo tomes literalmente: NO BUSCO QUE ME DES LA RAZON.
Busco lo que está mal, lo que falta, lo que es ambiguo, y lo que se rompe la
primera vez que alguien lo use de verdad. Un informe que diga que está bien es
un informe que no ha mirado: yo ya sé lo que quería escribir, lo que necesito
saber es qué he escrito.

═══════════════════════════════════════════════════════════════════════
QUE ES
═══════════════════════════════════════════════════════════════════════

Un método de trabajo para proyectos donde Claude Code implementa, Claude Cowork
revisa y planifica, y una persona decide lo que los dos agentes no pueden
decidir entre ellos. Tres piezas:

  - un CANAL: un directorio con un fichero inmutable por mensaje, que sustituye
    a la persona como cable entre las dos sesiones
  - un CONTRATO DE DELEGACION: un cuestionario que registra qué decide la
    persona y qué delega, con un suelo de clases no delegables
  - una CULTURA DE VERIFICACION que pretende hacer que el acuerdo entre dos
    agentes valga algo

Lee, en este orden: README.md, SKILL.md, y luego reference/ y assets/ enteros.
Son unos 14 ficheros y ninguno es largo. RESUELVE LAS RUTAS CONTRA EL ARBOL, no
contra este mensaje.

═══════════════════════════════════════════════════════════════════════
COMO QUIERO QUE ATAQUES
═══════════════════════════════════════════════════════════════════════

1. APUNTA EL INSTRUMENTO A SI MISMO. Es lo que el propio documento dice que es
   la práctica de mayor rendimiento, así que aplícasela: ¿el método cumple sus
   propias reglas? ¿Hay alguna regla que no diga si se aplica a sí misma? ¿Algún
   control que el documento exija y que el propio repositorio no tenga? ¿Alguna
   promesa que ninguna comprobación respalde?

2. SIMULA UN USO REAL, no leas en abstracto. Coge un proyecto imaginario
   concreto y recorre el método paso a paso: la instalación, el cuestionario, la
   primera semana, el mes tres, la llegada de una sesión nueva en frío. Dime en
   qué punto exacto se atasca, se vuelve ceremonia, o deja de contestar una
   pregunta que la persona sí tiene.

3. BUSCA LA INDEFINICION, que es más peligrosa que el error. Un error se ve; una
   ambigüedad la resuelve cada agente a su manera y nadie se entera hasta que
   las dos resoluciones chocan. ¿Qué frase admite dos lecturas razonables?

4. PREGUNTA POR LO QUE PASA CUANDO FALLA. El documento describe el camino bueno
   con detalle. ¿Qué ocurre cuando dos agentes escriben a la vez? ¿Cuando el
   canal tiene 400 ficheros? ¿Cuando alguien registra mal lo que dijo la
   persona? ¿Cuando la persona contradice hoy lo que decidió la semana pasada?

5. Y LO MAS IMPORTANTE: EL SUELO. El método promete que hay clases que NO se
   pueden delegar -- datos personales, borrados sin inversa, gasto, cualquier
   cosa que salga hacia un tercero. Pregúntate qué IMPIDE eso de verdad, y
   distingue entre lo que impide algo y lo que solo lo desaconseja. Si la
   respuesta es "una regla escrita en un documento que lee el propio agente al
   que restringe", dilo con todas las letras y valora si eso invalida la
   promesa central del método.

═══════════════════════════════════════════════════════════════════════
CUATRO SITIOS DONDE YO YA SOSPECHO
═══════════════════════════════════════════════════════════════════════

Te los doy para que no gastes tiempo en encontrar lo obvio, NO para que te
limites a ellos ni para que los confirmes. Si crees que alguno NO es un
problema, dímelo: eso también me sirve.

  a) NADA DE ESTO SE HA EJECUTADO NUNCA. El cuestionario no se ha corrido, el
     suelo no se ha visto rechazar nada, la skill no se ha visto activarse. Es
     un diseño que se presenta como mecanismo. ¿Cuánto de lo que afirma
     depende de que funcione algo que nadie ha visto funcionar?

  b) EL CAMPO head: SIN REPOSITORIO. Con git es un SHA. Sin git digo
     "timestamp, versión, lo que identifique el estado en ese proyecto". ¿Puede
     una comprobación de obsolescencia apoyarse en eso? ¿O el núcleo agnóstico
     está prometiendo una garantía que solo existe con repositorio?

  c) EL VOCABULARIO DE state:. Son tres valores -- open, consensus, escalated --
     y consensus lo uso para dos cosas: "los dos agentes acordaron" y "esto está
     zanjado", que es lo que aplica a una decisión de la persona. ¿Es un
     solapamiento inocente o produce lecturas distintas?

  d) EL CANAL EN INGLES CON UNA PERSONA QUE NO LEE INGLES. El método fuerza el
     canal a inglés siempre, y a la vez promete "mantener informada a la
     persona en todo momento". Si la persona eligió otro idioma, el registro de
     sus propias decisiones está en uno que no audita. ¿Es una contradicción
     real o la he resuelto en algún sitio que se me olvida?

═══════════════════════════════════════════════════════════════════════
COMO QUIERO EL INFORME
═══════════════════════════════════════════════════════════════════════

CADA HALLAZGO CON SU EVIDENCIA: fichero y línea, y la frase concreta. Un
hallazgo sin cita es una impresión, y no puedo actuar sobre una impresión.

Ordénalos por lo que costaría si nadie los arregla, no por dónde aparecen en el
texto. Y para cada uno:

    QUE dice hoy el documento
    POR QUE es un problema -- el escenario concreto en que muerde
    QUE PROPONES, o "no lo sé, pero hay que decidirlo", que es una respuesta
      válida y a veces la única honesta

SEPARA TRES COSAS que es fácil mezclar:

    DEFECTO       está mal y hay que cambiarlo
    LAGUNA        no está y hace falta
    DECISION SIN TOMAR   está ambiguo porque nadie eligió, y hay que elegir

Y AL FINAL, dos cosas que me interesan más que la lista:

  - LO QUE NO ARREGLARIA. Qué de lo que has encontrado es aceptable tal cual, y
    por qué. Un revisor que encuentra treinta problemas y considera los treinta
    graves no ha priorizado.

  - LA PREGUNTA QUE NO SE HACE EL DOCUMENTO. Si hay una, es lo más valioso que
    puedes darme, porque es lo único que no puedo encontrar yo leyéndolo otra
    vez.

═══════════════════════════════════════════════════════════════════════
LO QUE NO QUIERO
═══════════════════════════════════════════════════════════════════════

  - Elogios. Si algo está bien, no hace falta decirlo salvo que sea para
    explicar por qué NO lo cambiarías
  - Reescrituras de estilo. El tono es deliberado
  - Reabrir cuatro decisiones ya cerradas: que el alcance es el método completo
    y no solo el canal; que todo el contenido del repositorio va en inglés; que
    el formato es skill instalable más README para GitHub; y que el núcleo es
    agnóstico con un anexo para proyectos con repositorio. Puedes decirme que
    una de ellas tiene una consecuencia que no vi -- eso es útil -- pero no
    propongas cambiarlas
  - Que te limites a mis cuatro sospechas. Son un suelo, no un guion
```
