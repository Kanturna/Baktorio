# Body System

## Ziel fuer Slice 1

Ein einzelner Organismus wird aus einem `Genome` in einen `BodyBlueprint` uebersetzt und daraus visuell dargestellt.

Der BodyBlueprint beschreibt:

- Silhouette und Achse
- Koerpergroesse
- Zonen mit Materialtyp
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

## Nicht in Slice 1

- lokaler Schaden
- Containment pro Fluidzone
- Shell-Segmente mit Integritaet
- Modul-Lifecycle
- Bewegung, Sensorik, Reproduktion, Fusion
