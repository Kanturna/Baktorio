# Next Steps

## Aktueller Arbeitsblock

Slice 1 Fundament ist angelegt. Der aktuelle Arbeitsblock ist `Visual Body Lab v1`: Review-Navigation, Debug-Overlay-Steuerung und Config-Mutation-Schutz fuer die Seed-Reihe `1001..1024`.

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
2. Seed-Reihe 1001 bis 1024 per Prev/Next visuell pruefen.
3. Debug Overlay per Checkbox ein- und ausschalten.
4. Random und manuelle Seed-Eingabe pruefen; ausserhalb der Review-Range muss `off-review` angezeigt werden.
5. Materiallesbarkeit bewerten: Shell, Fluid, Structural, Core, optionale Module.
6. Erst danach entscheiden, ob Mutation Preview als naechster Slice tragfaehig ist.
