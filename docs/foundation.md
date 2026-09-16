# foundation architecture

this directory layer is intentionally boring in the best possible way.

`loundrycore` owns orchestration and state. it does not know how a particular terminal, model vendor, or ui works.

`loundryenvironment` owns the boundary where generated work actually executes. the first implementation includes an in-memory environment for tests and a local process environment for native development.

`loundrymodels` contains the portable project and environment data model.

## execution flow

```text
idea
  -> loundry project
  -> loundry orchestrator
  -> model provider
  -> generated files + commands
  -> execution environment
  -> build/test output
  -> repair loop
  -> completed project
```

## important boundary

github actions is not an execution worker for user-generated projects.

github actions builds, tests, and eventually packages **loundrycode itself**. user-generated projects run through loundrycode's own `executionenvironment` abstraction.

that separation lets the product eventually swap in local sandboxes, remote workers, virtual machines, containers, or other backends without rewriting the orchestrator.

## activity stream

`activityevent` is the public-facing event stream for the ui. it is intentionally made of useful status summaries rather than hidden chain-of-thought. the ui can use it for loundy's animation, the live activity panel, logs, and the "ai's environment" screen.
