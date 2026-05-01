# Next Steps

## Aktueller Arbeitsblock

Slice 1 Fundament ist angelegt. Aktuell ist der Architekturvertrag fuer das Hull-and-Fluid-Koerpermodell fixiert (siehe ADR-007 bis ADR-010).

Naechster Code-Slice: `Hull-and-Fluid Topology v1`: `BodyInteriorFluid`-Resource, Rename `BodySurfaceSegment` zu `BodyHullCell`, Migration der Fluid-`BodyZone`s und Render-Spike fuer `AntialiasedLine2D` und `shaderV`. Die Addon-Integration wird im Spike geprueft, nicht als Migration versprochen.

## Verworfene Plaene

- `Tissue Topology v1` (Hex-Lattice mit etwa 96 Tissue-Cells im Innenraum) wurde zugunsten des Hull-and-Fluid-Modells verworfen. Siehe ADR-007 (supersedes).

Validierungsskript:

```text
godot_console.exe --headless --path . --script res://tools/validate_body_pipeline.gd
```

## Nicht anfangen

- Populationen
- Mutation
- Vererbung
- Kampf
- Fusion
- Observer-Mode
- lokale Schadenslogik
- echte Softbody- oder Fluidphysik
- Segment-HP oder lokale Schadenswerte

## Naechster Review-Punkt

Nach dem ersten lauffaehigen Body Lab:

- Screenshots von 20 bis 30 Seeds pruefen
- entscheiden, ob die Blueprint-Geometrie fuer spaetere lokale Schadenslogik reicht
- erst dann den naechsten Slice definieren

## Konkrete naechste Schritte

1. Body Lab im Godot-Editor oeffnen.
2. Seed-Reihe 1001 bis 1024 per Prev/Next visuell pruefen.
3. Debug Overlay per Checkbox einschalten und SurfaceSegments/Normalen pruefen.
4. Materiallesbarkeit bewerten: Shell, Fluid, Structural, Core, optionale Module.
5. Beobachten, ob Debug-Overlay-Vertexkosten spaeter bei Populationstests relevant werden.
6. Vor der naechsten Layout-Heuristik entscheiden, ob `BlueprintBuilder` nach `body/placement_helpers.gd` entlastet wird.
7. Erst danach entscheiden, ob Antialiasing, Mutation Preview oder Kontaktlogik als naechster Slice tragfaehig ist.
