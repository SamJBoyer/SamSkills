

## name: explore-distill
description: Map a prototype's modules and seam shape. Writes distill/DISTILL-inventory.md. Use when starting a distill, inventorying a prototype, strip for parts, or harvest from prototype. Accurately describe the seam shape, modules, etc. 


## Terms

- TARGET_REPO: the codebase this skill is being invoked in. 
- FUNCTIONAL_MODULE: A cluster of behavior with a recognizable responsibility and a boundary you can point at (package, assembly, types, API, data model, process). 
- SEAM_SHAPE: How the boundry layer that seperates a FUNCTIONAL_MODULE for other pieces of the code base. Imagine each FUNCTIONAL_MODULE as a service and the SEAM_SHAPE is the api layer. 
- SEAM: A named boundry between 1 or more FUNCTIONAL_MODULES. 

# Explore Distill

Take a TARGET_REPO and write a report seperating each FUNCTIONAL_MODULE in the codebase by a SEAM_SHAPE. 

## Constraints

- Don't run the testing suite or make changes to the code base. You're job is only to explore the current implementation implementation to identify the FUNCTIONAL_MODULES, SEAM_SHAPES, and  
- Don't 

## Inventory



For each unit record:

- Path / identity
- Responsibility (one sentence)
- Inbound deps (who uses it)
- Outbound deps (what it uses)
- Coupling: imports, inheritance, shared mutable state, globals/singletons, events, config, I/O, host lifecycle
- SEAM_SHAPE: Construction of the boundry, what information crosses it, how seperateable the boundry is. 
- Proof it works: tests, fixtures, golden files, or none

### Coupling to hunt

Hidden coupling is what later cuts have to see:

- Static/global state, singletons, service locators
- Inheritance from host base classes
- Shared mutable models passed everywhere
- Config keys, file paths, resource IDs, magic strings
- Event buses and implicit message shapes
- Database schemas or stores owned by the host
- Framework lifecycle hooks (engine ticks, HTTP middleware, job runners)
- Cyclic imports between modules


## Deliverable

Create `distill/` if needed. Write `distill/DISTILL-inventory.md`.

```markdown
# Distill Inventory: <prototype>

## Constraints
- **Technical constraints**:
- **Named units** (only if the user named any):

## Units
For each unit:
- **Identity / path**:
- **Responsibility**:
- **Inbound / outbound**:
- **Coupling notes**:
- **Seam shape**:
- **Proof it works**:

