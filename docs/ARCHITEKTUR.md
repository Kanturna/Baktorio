# Architektur

## Leitsatz

Daten, Gene, BodyBlueprint und RuntimeState sind Wahrheit. Renderer, UI, Debug und Szenen sind Projektion.

## Slice-1 Pipeline

```text
Genome
  -> BodyBlueprint
  -> OrganismRuntimeState
  -> CellRenderer
```

`Phenotype` ist in Slice 1 keine eigene Schicht. Der `BodyBlueprint` ist der ausgepraegte Koerperausdruck des Genoms.

## Schichten

```text
core/       deterministische Hilfen und kleine Utilities
config/     Resource-basierte Tuningwerte
genetics/   Genome, GeneSchema, GenomeFactory
body/       BodyBlueprint, BodyZone, BlueprintBuilder
runtime/    minimaler lebendiger Zustand
rendering/  visuelle Projektion aus Blueprint und RuntimeState
ui/         Body-Lab-Bedienung und Inspector
debug/      reine Entwicklerdiagnose
scenes/     Godot-Szenenverdrahtung
docs/       Projektvertrag und Architekturentscheidungen
```

## Harte Verbote

- Keine Simulationslogik in `rendering/`, `ui/`, `debug/` oder `scenes/`.
- Keine Organismusvariation durch feste Sprite-Familien.
- Keine Rueckabhaengigkeit von Body/Genetics auf Renderer oder UI.
- Keine zentrale Manager-Klasse, die alle Schichten entscheidet.
- Keine Stub-Systeme fuer spaetere Phasen ohne reale Slice-1-Aufgabe.

## Dependency-Richtung

Abhaengigkeiten duerfen nach unten in der Pipeline greifen, aber nicht zurueck:

```text
ui/debug/scenes -> rendering -> runtime -> body -> genetics -> config/core
```

Ausnahme: Config-Resources duerfen von mehreren Schichten gelesen werden, duerfen aber keine Runtime-Wahrheit speichern.
