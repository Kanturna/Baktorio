# Status

## Aktueller Stand

Projektfundament fuer Slice 1 ist angelegt.

Bestehendes Projekt:

- Godot-Projekt `Baktorio`
- Addons fuer antialiased lines, debug menu und shaderV
- Startszene `res://scenes/body_lab.tscn`
- Doku- und Architekturvertrag fuer Slice 1
- minimale Datenpipeline und Renderer
- Architekturentscheidung Hull-and-Fluid-Modell fixiert (ADR-007/008/009/010); Code-Migration steht aus.

## Slice 1

Name: One Organism Body Pipeline

Ziel:

```text
Genome -> BodyBlueprint -> OrganismRuntimeState -> CellRenderer
```

Acceptance-Fragen:

1. Erzeugt gleicher Seed denselben Blueprint?
2. Sind 20 bis 30 Seeds visuell unterscheidbar?
3. Sind Materialklassen lesbar?
4. Bleibt Renderer frei von Simulationsentscheidungen?
5. Sind zentrale Tuningwerte als Resources editierbar?

## Implementiert

- `SeededRng` als deterministischer RNG-Wrapper
- `GeneSchema`, `GeneConfig`, `Genome`, `GenomeFactory`
- `BodyBlueprint`, `BodyZone`, `BlueprintBuilder`
- `BodySurfaceSegment` als Blueprint-Topologie fuer Aussenflaechen
- minimaler `OrganismRuntimeState`
- `CellRenderer` mit internem Layer-Aufbau
- `BodyLabPanel` und `BlueprintInspector`
- Review-Navigation fuer Seed-Reihe `1001..1024`
- Debug-Overlay-Toggle ueber Runtime-RenderConfig-Kopie
- Config-Resources unter `resources/config/`
- Headless-Validierung unter `tools/validate_body_pipeline.gd`

## Letzte Validierung

```text
godot_console.exe --headless --path . --quit --editor --check-only
godot_console.exe --headless --path . --script res://tools/validate_body_pipeline.gd
godot_console.exe --headless --path . --quit-after 1
```

Ergebnis:

```text
Body pipeline validation passed: 24 review variants, 24 unique summaries.
```

## Offene Punkte

- Seed-Reihe `1001..1024` im Godot-Editor visuell pruefen.
- Materiallesbarkeit, SurfaceSegments und Debug Overlay manuell bewerten.
- Code-Slice `Hull-and-Fluid Topology v1` planen und umsetzen.
- Erst danach entscheiden, ob Antialiasing, Mutation Preview oder Kontaktlogik als naechster Slice kommt.
