# Next Steps

## Aktueller Arbeitsblock

Slice 1 Fundament ist angelegt. Der naechste Arbeitsblock ist visuelle Review und Tuning des Body Labs.

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

## Naechster Review-Punkt

Nach dem ersten lauffaehigen Body Lab:

- Screenshots von 20 bis 30 Seeds pruefen
- entscheiden, ob die Blueprint-Geometrie fuer spaetere lokale Schadenslogik reicht
- erst dann den naechsten Slice definieren

## Konkrete naechste Schritte

1. Body Lab im Godot-Editor oeffnen.
2. Seed-Reihe 1001 bis 1024 visuell pruefen.
3. Materiallesbarkeit bewerten: Shell, Fluid, Structural, Core, optionale Module.
4. Renderer-Tuning nur ueber `RenderConfig` vornehmen, solange keine neue Darstellungslogik noetig ist.
5. Danach ADR fuer den naechsten Slice schreiben.
