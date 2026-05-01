# AGENTS.md

Arbeitsvertrag fuer Codex, Claude und GPT in diesem Repository.

## Startprotokoll

Vor jeder nicht-trivialen Codeaenderung:

1. `git status --short --branch` pruefen.
2. `AGENTS.md` und die betroffenen Doku-Dateien lesen.
3. Betroffene Schicht benennen.
4. Ziel, Annahmen, Risiken und Validierungspfad nennen.
5. Bei Architekturzweifel zuerst `docs/DECISIONS.md` oder Plan-Doku aktualisieren.

## Schichtregeln

Die gerichtete Pipeline fuer Slice 1 ist:

```text
core -> config -> genetics -> body -> runtime -> rendering -> ui/debug/scenes
```

Regeln:

- Daten sind Wahrheit; Nodes sind Projektion.
- Organismusvariation fliesst ueber `Genome -> BodyBlueprint -> RuntimeState -> Renderer`.
- Renderer lesen nur `BodyBlueprint`, `OrganismRuntimeState` und `RenderConfig`.
- UI, Debug und Szenen duerfen keine Simulationswahrheit erzeugen.
- Keine Manager-Gottklasse.
- Kleine Dateien mit einer klaren Verantwortlichkeit bevorzugen.
- Neue Gene, Zonen oder Modularten brauchen einen Eintrag in `docs/DECISIONS.md`, wenn sie die Architektur erweitern.

## Slice-1 Scope

Erlaubt:

- Genome v1
- deterministische Seed-Erzeugung
- BodyBlueprint v1
- Material- und Zonenplan im Blueprint
- minimale RuntimeState-Huelle
- ein CellRenderer mit interner Layer-Reihenfolge
- Body-Lab-UI und Blueprint-Debugansicht

Nicht erlaubt ohne neue Entscheidung:

- Populationen
- Kampf
- Fusion oder Symbiose
- Observer-Mode
- Mutation oder Vererbung
- lokale Schadenslogik
- echte Softbody- oder Fluidphysik
- separate Phenotype-Schicht
- Modul-Klassenhierarchie fuer Verhalten

## Validierung

Jeder Slice braucht einen konkreten Validierungspfad. Fuer Slice 1:

- gleicher Seed erzeugt denselben Blueprint
- 20 bis 30 Seeds erzeugen sichtbare Varianten
- Renderer liest keine Genome direkt
- UI schreibt nur Testinputs, keine Koerperregeln
- Pflichtbestandteile Core, Shell und Innenraum existieren immer

## Commit-Vorschlag

Nach jeder abgeschlossenen Aenderung muss die abschliessende Antwort einen Commit-Vorschlag enthalten:

- Commit-Name: kurzer imperativer Titel, passend fuer eine Git-Commit-Message.
- Commit-Beschreibung: konkret genug, um den Change spaeter ohne Diff grob einordnen zu koennen.
- Bei kleinen Aenderungen reichen 2 bis 5 Saetze oder Bulletpoints.
- Bei groesseren Slices darf die Beschreibung detaillierter sein und Scope, Architekturentscheidungen, wichtigste Dateien, Validierung und bewusst ausgelassene Themen nennen.

Das ist ein Vorschlag fuer den Menschen, kein automatischer Commit. Staging, Commit und Push erfolgen nur nach expliziter Anweisung.
