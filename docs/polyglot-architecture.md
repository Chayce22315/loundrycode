# polyglot architecture

loundrycode is polyglot by design.

there is no single implementation language for the product itself. each subsystem may use the language and runtime that best fit its job.

## rule

loundrycode components communicate through stable, language-neutral contracts. implementation language is an internal detail of the component.

```text
                    loundrycode
                         │
             language-neutral contracts
                         │
       ┌─────────────────┼─────────────────┐
       │                 │                 │
     swift              rust              python
       │                 │                 │
       ui            orchestration       agents
       │                 │                 │
       └──────────────┬──┴─────────────────┘
                      │
                more components
          go / c++ / c# / typescript / ...
```

## component boundaries

### application shells

platform-facing interfaces can use native technologies. an ios application can use swift/swiftui, a web application can use typescript, and a windows application can use c#, c++, rust, or another appropriate stack.

### core orchestration

the orchestration engine is independent of the ui and model vendor. rust, go, c++, or another systems language may implement it when that provides the required runtime characteristics.

### agents and model adapters

agent logic can use python, rust, typescript, or another language. model providers are exposed through a common provider contract so the orchestrator does not depend on a specific sdk.

### execution environments

an execution environment can be implemented with native platform tooling or a dedicated runner. windows, linux, and macos environments do not need to share an implementation language.

### generated projects

generated projects are also polyglot. the generated language is selected from project requirements, target platform, available toolchains, and build constraints, not from the language used to implement loundrycode.

## communication

components should prefer explicit contracts such as:

- project and manifest schemas
- model request/response streams
- activity events
- environment commands and results
- build plans and diagnostics
- capability descriptions

transport may vary by deployment. in-process calls, subprocess protocols, local sockets, http, grpc, or another appropriate transport are implementation choices.

## github actions boundary

github actions is the construction and release system for loundrycode itself. it is not an employee inside loundrycode and is not the runtime worker for user projects.

user projects execute through loundrycode's environment abstraction, which can later be backed by local sandboxes, containers, virtual machines, or remote workers.

## design consequence

the repository may contain multiple independently buildable components. a component should only depend on another component's published contract, not on its implementation language.
