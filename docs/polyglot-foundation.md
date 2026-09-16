# polyglot foundation

loundrycode is intentionally not tied to one programming language.

there are two different questions:

1. what language is loundrycode itself written in?
2. what language should a generated project use?

those answers do not need to match.

## project side

`projectlanguage`, `toolchain`, `projectfile`, and `projectmanifest` describe generated work without assuming a single language.

a project can contain swift, rust, typescript, python, c++, or other supported languages at the same time.

## environment side

`environmentcapabilities` describes what an execution backend can actually provide: operating system, shells, languages, process execution, filesystem persistence, and network policy.

this lets the planner ask for capabilities instead of hard-coding assumptions such as "everything runs in swift" or "everything runs on github actions".

## product boundary

github actions builds and tests **loundrycode itself**.

user-generated projects go through `executionenvironment` implementations owned by loundrycode. those implementations can eventually be local, sandboxed, containerized, virtualized, remote, or otherwise specialized.

## foundation rule

> interfaces and contracts should survive language changes.

if a future component is better implemented in rust, go, python, c++, zig, swift, typescript, or another language, the surrounding architecture should not need to be redesigned just because that component changed languages.
