# Decisions

## ADR-001: Keine Phenotype-Schicht in Slice 1

Status: akzeptiert

Der `BodyBlueprint` uebernimmt in Slice 1 die Rolle des ausgepraegten Koerpers. Eine separate `phenotype/`-Schicht wird nicht angelegt, weil sie mit dem Blueprint ueberlappt und frueh Begriffsdrift erzeugen wuerde.

Konsequenz: Die Uebersetzung `Genome -> BodyBlueprint` liegt im `BlueprintBuilder`.

## ADR-002: Module sind in Slice 1 Daten-Tags

Status: akzeptiert

`core`, `shell`, `metabolism`, `photosynthesis` und `intake` werden in Slice 1 als Modul-Tags im Blueprint modelliert. Es entstehen keine `CoreModule.gd`-, `ShellModule.gd`- oder aehnliche Verhaltensklassen.

Konsequenz: Der Renderer kann Module darstellen, aber keine Modulprozesse ausfuehren.

## ADR-003: Kein lokaler Schaden in Slice 1

Status: akzeptiert

Lokale Schadenslogik, Shell-Segmentintegritaet, Containment und Leckage bleiben ausserhalb von Slice 1.

Konsequenz: `OrganismRuntimeState` bleibt minimal und enthaelt nur einfache Zustandswerte fuer Anzeige und spaetere Erweiterung.

## ADR-004: Renderer startet als eine Klasse

Status: akzeptiert

Der visuelle Layer-Aufbau wird in `CellRenderer` durch private Draw-Methoden strukturiert. Separate Renderer-Dateien entstehen erst, wenn ein Layer eigene Daten, Performance-Pfade oder Lebenszyklen braucht.

Konsequenz: Slice 1 bleibt klein und schichtsauber, ohne eine Renderer-Klassenfamilie vorwegzunehmen.
