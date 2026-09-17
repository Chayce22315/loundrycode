# loundrycode contracts

this directory defines the boundaries that allow loundrycode to be implemented in multiple languages.

contracts describe **what** a component provides. they do not prescribe **how** it is implemented.

## initial contracts

```text
contracts/
├── project/
├── model/
├── environment/
├── build/
└── activity/
```

these contracts should remain small, explicit, versionable, and language-neutral.

swift structs, rust types, typescript interfaces, protobuf schemas, json schemas, and other representations are adapters to the contracts, not the architecture itself.

## dependency rule

```text
ui ────────────────┐
model adapter ─────┤
agent ─────────────┤
runner ────────────┤──> contract <── implementation
build service ────┘
```

no component should require another component to be written in the same language.
