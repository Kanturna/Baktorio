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

## SurfaceSegments

`BodySurfaceSegment` beschreibt einen kleinen Abschnitt der Aussenhuelle.

Enthalten:

- stabiler `segment_id`, z. B. `surface_00`
- `index` als Reihenfolge um den Koerper
- Winkelbereich in `[0, TAU)`
- lokaler Mittelpunkt
- normalisierte Aussen-Normale
- optionale Modulbindung als Daten-Tag
- `linked_zone_ids` als Soft-References auf BodyZones

Die Segmente sind noch kein Schadenmodell. Sie sind nur die Topologie, auf der spaeter Kontakt, Absorption und lokaler Schaden aufbauen koennen.

Segment-Normalen werden als geometrische Aussen-Normalen der skalierten Ellipse berechnet, nicht als einfache angulare Richtung.

`BodyBlueprint.to_debug_text()` zeigt SurfaceSegment-Count und Segmente mit Modulbindung oder zusaetzlichen Zonenlinks, damit der Body Lab Inspector die Topologie pruefbar macht.

## Aufbau-Reihenfolge

`BlueprintBuilder` erzeugt zuerst Shell und Core, dann Fluid- und optionale Modulzonen. Structural-Zonen kommen danach, damit sie Core, Fluid und Aussenmodule als Stuetze verbinden koennen. Diese Reihenfolge ist Teil der Layout-Heuristik, nicht der Runtime-Simulation.

## Nicht in Slice 1

- lokaler Schaden
- Containment pro Fluidzone
- Shell-Segmente mit Integritaet
- SurfaceSegment-HP oder Segment-Schadenswerte
- Modul-Lifecycle
- Bewegung, Sensorik, Reproduktion, Fusion
