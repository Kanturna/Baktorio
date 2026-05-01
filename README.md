# Baktorio

Baktorio ist eine Godot-Simulation fuer zellulaere Evolution.

Der erste Slice beweist nur die One Organism Body Pipeline:

```text
Genome -> BodyBlueprint -> RuntimeState -> Renderer
```

Simulation data is the truth. Rendering, UI, Debug-Views und Szenen sind Projektionen dieser Daten.

## Aktueller Fokus

Slice 1 erzeugt einen einzelnen Organismus deterministisch aus einem Seed, baut daraus einen `BodyBlueprint` und rendert ihn im Body Lab. Noch nicht enthalten sind Populationen, Kampf, Fusion, Mutation, Evolution, Observer-Mode und lokale Schadenslogik.

## Wichtige Dokumente

- `AGENTS.md`: Arbeitsregeln fuer Codex, Claude und GPT.
- `docs/ARCHITEKTUR.md`: Schichten, Pipeline und Verbote.
- `docs/BODY_SYSTEM.md`: Koerper-, Material- und Blueprint-Spezifikation fuer Slice 1.
- `docs/STATUS.md`: Aktueller Projektstand.
- `docs/NEXT_STEPS.md`: Naechster Arbeitsblock.
- `docs/DECISIONS.md`: Architekturentscheidungen.
