# Body System

## Ziel fuer Slice 1

Ein einzelner Organismus wird aus einem `Genome` in einen `BodyBlueprint` uebersetzt und daraus visuell dargestellt.

Der BodyBlueprint beschreibt:

- Silhouette und Achse
- Koerpergroesse
- Zonen mit Materialtyp
- segmentierte Aussenflaeche als Kontakt-Topologie
- Pflichtmodule als Daten-Tags
- optionale Modul-Tags
- einfache abgeleitete Funktionswerte fuer Lesbarkeit

## Koerpermodell: Hull and Fluid

Der Koerper ist als drei klar getrennte Schichten plus Aussenmodule modelliert. Diese Skizze gilt als architektonischer Rahmen fuer Slice 1 und alle Folge-Slices innerhalb des Koerpermodells (siehe ADR-007).

```text
1. Aussenwand:    Huellzellen (diskrete Wandkacheln entlang der Silhouette)
2. Innenraum:     Cytoplasma-Fluid (ein zusammenhaengender Container)
3. Festkoerper:   Core, strukturelle Stuetzen, kuenftige Funktionsorganellen
                  schwimmen im Fluid
+. Aussenmodule:  Photosynthese-Patch, Intake-Oeffnung
                  bleiben an Huellzellen verankert
```

Die Schichten sind reine Datenmodellierung. Schadenslogik, Kontakt, Absorption, Kollision und Containment-Verlust sind in Slice 1 ausdruecklich nicht vorhanden (siehe ADR-003 und ADR-006/007).

Ein Ziel-Datenmodell `BodyInteriorFluid` ersetzt langfristig die heutigen mehreren Fluid-Tropfen-`BodyZone`s mit `Kind.FLUID` (siehe ADR-008). Bis zur Code-Migration im Folge-Slice bleibt die heutige Fluid-Tropfen-Darstellung im Code unveraendert.

## Materialien

`shell`  
Schutzhuelle und sichtbare Grenze. Wird als Kontur und aeussere Schicht dargestellt.

`fluid`  
Weicher Innenraum. Halbtransparent, organisch und verletzlich lesbar.

`structural`  
Innere Stuetze oder spezialisierte Struktur. Koerniger/kompakter als Fluid.

`core`  
Zentrale Identitaets- und Koordinationszone. Pflichtbestandteil.

`photosynthetic`  
Optionale exponierte Zone fuer Umweltenergie. In Slice 1 nur Daten- und Rendermerkmal.

`intake`  
Optionale Randzone fuer Aufnahme. In Slice 1 nur Daten- und Rendermerkmal.

## Pflichtmodule

- `core`
- `shell`
- `metabolism`

Diese Module sind in Slice 1 Daten-Tags im Blueprint. Sie enthalten keine Prozesslogik.

## Optionale Module

- `photosynthesis`
- `intake`

Nur eines davon muss im ersten Slice plausibel erzeugbar und sichtbar sein. Beide duerfen als Tags existieren, solange keine Simulationslogik entsteht.

## Huellzellen (HullCells)

Im aktuellen Code heisst diese Entitaet noch `BodySurfaceSegment`. Der Rename auf `BodyHullCell` ist mit ADR-009 beschlossen und wird im Folge-Slice umgesetzt. Bis dahin sind in dieser Doku "Huellzelle" und der Code-Name `BodySurfaceSegment` gleichbedeutend.

`BodySurfaceSegment` beschreibt einen kleinen Abschnitt der Aussenhuelle, also eine einzelne Huellzelle.

Enthalten:

- stabiler `segment_id`, z. B. `surface_00`
- `index` als Reihenfolge um den Koerper
- Winkelbereich in `[0, TAU)`
- lokaler Mittelpunkt
- normalisierte Aussen-Normale
- optionale Modulbindung als Daten-Tag
- `linked_zone_ids` als Soft-References auf BodyZones

Die Huellzellen sind noch kein Schadenmodell. Sie sind nur die Topologie, auf der spaeter Kontakt, Absorption und lokaler Schaden aufbauen koennen.

Huellzellen-Normalen werden als geometrische Aussen-Normalen der skalierten Ellipse berechnet, nicht als einfache angulare Richtung.

Nachbarschaft links/rechts entlang des Rings ist trivial aus `index` ableitbar; explizite `neighbor_cell_ids` werden im Folge-Slice ergaenzt (fuer den spaeteren Bruchbereich-Algorithmus).

`BodyBlueprint.to_debug_text()` zeigt Huellzellen-Count und Huellzellen mit Modulbindung oder zusaetzlichen Zonenlinks, damit der Body Lab Inspector die Topologie pruefbar macht.

## Innenraum-Fluid

Zielmodell ab ADR-008: ein einzelner `BodyInteriorFluid`-Container repraesentiert das Cytoplasma als zusammenhaengende Innen-Kammer.

Geplante Datenfelder (Code-Migration im Folge-Slice):

- `material_id` als Material-Tag (fluid)
- `volume_factor` als Skalar relativ zur Koerperellipse
- `pigment_offset` zur Variation gegenueber `pigment_hue`
- weitere reine Datenwerte (z. B. Viskositaets-Hinweis fuer den Renderer)

Dieser Container traegt keine Schaden-, Druck- oder Stroemungssimulation. Spaeterer Containment-Verlust wird im RuntimeState abgebildet, sobald ein Schaden-Slice nach ADR-003 freigegeben wird.

Bis zur Code-Migration koexistiert das Zielmodell konzeptuell mit den heutigen mehreren Fluid-Tropfen-`BodyZone`s. Die Tropfen sind ab jetzt als deprecated zu lesen (siehe ADR-008).

## Innere Festkoerper

Festkoerper schwimmen im Fluid und stellen die strukturelle und funktionelle Innenausstattung des Organismus.

Aktuelle Festkoerper-Kategorien als `BodyZone`s:

- Core: zentrale Identitaets- und Koordinationszone, Pflichtbestandteil.
- Structural: innere Stuetzen, die Core und Aussenmodule verbinden.

Spaetere, noch nicht implementierte Funktionsorganellen koennen als zusaetzliche `BodyZone`-Kinds oder `module_tag`-Auspraegungen modelliert werden, ohne ADR-002 zu verletzen (Module bleiben Daten-Tags).

Festkoerper sind im Slice 1 ohne Schaden, ohne Lebenszustand und ohne eigene Sim-Logik. Sie sind reine Position und Materialdaten im Blueprint.

## Aufbau-Reihenfolge

`BlueprintBuilder` erzeugt zuerst Shell und Core, dann Fluid- und optionale Modulzonen. Structural-Zonen kommen danach, damit sie Core, Fluid und Aussenmodule als Stuetze verbinden koennen. Anschliessend werden Huellzellen erzeugt.

Nach Migration auf das Hull-and-Fluid-Modell wird die Reihenfolge entsprechend ergaenzt: Shell, Core, Innenraum-Fluid (statt mehrerer Fluid-Tropfen), Festkoerper, Aussenmodule, Huellzellen. Die genaue Code-Reihenfolge wird im Folge-Slice spezifiziert.

Diese Reihenfolge ist Teil der Layout-Heuristik, nicht der Runtime-Simulation.

## Render-Strategie (forward-looking)

Bevorzugte Bausteine fuer den naechsten Code-Slice (siehe ADR-010):

- `AntialiasedLine2D` und `AntialiasedPolygon2D` (Plugin enabled in `project.godot`) fuer glatte Huellzellen-Konturen und Huellringe.
- `shaderV` als Asset-Bibliothek im Repo (nicht als Plugin enabled) wird in einem Render-Spike als Kandidat fuer Fluid-Innenraum-Visualisierung evaluiert.
- `DebugMenu` (Plugin enabled) bleibt fuer Performance-Diagnose verfuegbar.

Eine ausfuehrliche Effekt-Auswahl gehoert in den spaeteren Render-Plan, nicht in dieses Koerpermodell-Dokument.

## Nicht in Slice 1

- lokaler Schaden
- Containment pro Fluidzone
- Shell-Segmente mit Integritaet
- SurfaceSegment- bzw. Huellzellen-HP oder Segment-Schadenswerte
- Modul-Lifecycle
- Bewegung, Sensorik, Reproduktion, Fusion

Huelltreffer, Huellbruch, Fluid-Leck, Containment-Verlust und kritischer Zustand sind Schadenslogik und liegen ausserhalb von Slice 1 (siehe ADR-003).
