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

## ADR-005: Visual Body Lab v1 before mutation

Status: akzeptiert

Vor Mutation Preview, Simulation oder Evolution wird das Body Lab als visuelles Review-Werkzeug stabilisiert. Die Seed-Reihe `1001..1024` soll schnell pruefbar sein, ohne geteilte `.tres`-Resources zur Laufzeit zu mutieren.

Konsequenz: Der naechste Slice bleibt im bestehenden Body-Lab- und Renderer-Rahmen. Er ergaenzt Review-Navigation, Debug-Overlay-Steuerung und Headless-Assertions gegen Config-Mutation, aber keine Mutation, Population, Schadenslogik oder neuen Renderer-Klassen.

## ADR-006: Surface segments are blueprint topology, not damage state

Status: akzeptiert

Die Aussenhuelle erhaelt `BodySurfaceSegment`-Daten im `BodyBlueprint`, damit spaetere Kontakt-, Absorptions- und Schadenslogik lokale Beruehrungsareale adressieren kann. Diese Segmente sind in diesem Slice reine Topologie: Winkelbereich, Mittelpunkt, Normale, Modul-Tag und Links auf Koerperzonen.

ADR-002 bleibt gueltig. Die Bindung von Modulen an SurfaceSegments ist Datenmodellierung, keine Modul-Verhaltensklasse und kein Modul-Lifecycle.

Konsequenz: Es entstehen keine Segment-HP, keine lokale Integritaet, kein DamageSystem, keine Absorption und keine Kollisionssimulation. RuntimeState bleibt unveraendert minimal.
