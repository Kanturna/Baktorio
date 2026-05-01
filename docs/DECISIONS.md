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

Hinweis: Die hier beschriebene Entitaet wird in ADR-009 zu `BodyHullCell` umbenannt. Das Prinzip (Topologie, kein Schadenstand) bleibt unveraendert.

## ADR-007: Hull-and-Fluid body model (supersedes Tissue Topology v1)

Status: akzeptiert

Der Koerper besteht aus drei Schichten:

1. Huellzellen (diskrete Wandkacheln entlang der Silhouette).
2. Cytoplasma-Fluid (ein zusammenhaengender Container).
3. Innere Festkoerper (Core, strukturelle Stuetzen, kuenftige Funktionsorganellen), die im Fluid schwimmen.

Aussenmodule (Photosynthese-Patch, Intake-Oeffnung) bleiben an Huellzellen verankert.

Supersedes: Der vorherige "Tissue Topology v1"-Plan (Hex-Lattice mit etwa 96 Tissue-Cells im Innenraum) wird durch dieses Modell ersetzt, nicht nur pausiert. Damit ist klargestellt: kein Zurueckpendeln zwischen zwei Koerpermodellen.

Konsequenz: Spaeterer Schaden referenziert Huellzellen-Integritaet und Fluid-Containment, keine Tissue-HP. ADR-003 bleibt unveraendert.

## ADR-008: BodyZone.Kind.FLUID semantic shift

Status: akzeptiert

Die heutigen mehreren Fluid-Tropfen-`BodyZone`s mit `Kind.FLUID` werden konzeptuell zu einem einzigen `BodyInteriorFluid`-Container vereinheitlicht. Die migrationsbedingte Code-Aenderung erfolgt erst im Folge-Slice; ADR-008 fixiert die Zielrichtung jetzt.

Entscheidung: `BodyZone.Kind.FLUID` wird als Uebergangsmodell deprecated. Zielmodell ist `BodyInteriorFluid` als ein zusammenhaengender Container. Strukturelle und Core-Zonen bleiben als Festkoerper-`BodyZone`s erhalten.

Konsequenz: Ob das tatsaechliche Removal des Enum-Werts und die Datenmigration im selben Code-Slice oder in einem separaten Cleanup-Slice erfolgen, wird zum Zeitpunkt des Code-Plans entschieden. ADR-008 bindet nur das Zielmodell, nicht den Removal-Zeitpunkt.

## ADR-009: Rename `BodySurfaceSegment` zu `BodyHullCell`

Status: akzeptiert

Der Klassenname `BodySurfaceSegment` wird im Folge-Slice auf `BodyHullCell` umbenannt, um die konzeptuelle Sprache der Hull-and-Fluid-Architektur zu treffen. "HullCell" trifft "Einheit mit spaeterer Integritaet" besser als "Segment".

Betroffener Refactor (fuer den Folge-Slice dokumentiert):

- `body/body_surface_segment.gd` zu `body/body_hull_cell.gd`
- `BodyBlueprint.surface_segments` zu `hull_cells`
- `BodyLabConfig.surface_segment_count` zu `hull_cell_count`
- Validator-Funktionen, Debug-Renderer, `to_debug_text`-Sektion

Konsequenz: ADR-006 bleibt gueltig (Topologie ist kein Schadenstand), bezieht sich aber ab jetzt auf `BodyHullCell`.

## ADR-010: Use installed addons for organic rendering (preferred direction)

Status: akzeptiert

Fuer die Hull-and-Fluid-Visualisierung im Folge-Slice sind die im Repo vorhandenen Addons die bevorzugten Kandidaten, statt erneut Custom-`_draw()`-Animation auf CPU zu erweitern:

- `AntialiasedLine2D` und `AntialiasedPolygon2D` (Plugin enabled in `project.godot`) als bevorzugter Baustein fuer glatte HullCell-Konturen und Huellringe.
- `shaderV` ist als Asset-Bibliothek im Repo, nicht als Plugin enabled. Wird im Folge-Slice in einem Render-Spike evaluiert (Eignung von Noise- und Distortion-Shadern fuer Fluid-Innenraum). Aktivierung als Plugin und konkrete Shader-Auswahl gehoeren in den Render-Spike, nicht in diesen Doku-Vertrag.
- `DebugMenu` (Plugin enabled) bleibt fuer spaetere Performance-Diagnose verfuegbar (FPS, Frametime, Memory).

Konsequenz fuer Renderer-Architektur im Folge-Slice:

- `CellRenderer` bleibt Orchestrator (ADR-004). Addon-basierte Child-Nodes oder Shader-Materialien sind bevorzugte Kandidaten fuer HullCell-Konturen und Fluid-Darstellung; die konkrete Bauweise wird im Code-Plan festgelegt.
- ADR-004 bleibt unangetastet: weiterhin eine Renderer-Klasse, die Child-Nodes komponiert. Keine `ShellRenderer`/`FluidRenderer`-Hierarchie.
- Das Performance-Argument fuer Shader-basierte Animation (Entlastung der 96-Vertex-Sin-Berechnung) ist Motivation fuer den Spike, keine Implementierungspflicht.

Forward-looking: Wenn der Spike erfolgreich ist, koennen Photosynthese-Patches und Intake-Oeffnungen spaeter eigene Shader-Effekte bekommen. Auch das wird im jeweiligen Slice entschieden.
