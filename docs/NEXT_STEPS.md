# Next Steps

## Aktueller Arbeitsblock

Slice 1 Fundament ist angelegt. Der aktuelle Arbeitsblock ist `Body Layout Coherence + Surface Segments v1`: zusammenhaengendere Koerperplatzierung und Aussenflaechen-Topologie ohne Kampf- oder Schadenslogik.

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
6. Erst danach entscheiden, ob Antialiasing, Mutation Preview oder Kontaktlogik als naechster Slice tragfaehig ist.
