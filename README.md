# loundrycode

> throw in your messy ideas and loundrycode can turn that messy idea of yours to life! 🧺✨

loundrycode is a native-first ai app coder for ios. it is designed around one simple idea: **describe what you want, then let the system do the heavy lifting.**

instead of making you assemble a giant pile of tools yourself, loundrycode aims to bring planning, coding, project generation, execution, testing, and iteration into one place.

> ⚠️ **the loundy department has one request:** please do not make your idea *too* messy. loundy is self aware of what they do. 👀

![loundy mascot](docs/assets/loundy.svg)

## 🚧 project status

**very early development.**

this repository is currently the foundation for the project. the app architecture, ui, ai orchestration, execution environments, and model integrations will be built here over time.

nothing in this readme should be interpreted as a promise that every planned feature already exists. this document describes the direction and architecture we are building toward.

## 🧺 what is loundrycode?

loundrycode is intended to be an **ai-powered app development environment for ios** that hides as much unnecessary complexity as possible without hiding what the ai is actually doing.

at the surface, the experience should stay extremely simple:

1. describe an idea
2. loundrycode plans it
3. loundy and the ai agents build it
4. the environment runs the project
5. the project is compiled and tested
6. failures are diagnosed and fixed
7. the result comes back to you

underneath that clean interface is a much larger system containing model providers, agents, project systems, runtimes, compilers, environment adapters, execution services, and more.

## 🧠 the core idea

loundrycode is not meant to be just a chat box with a code generator stapled onto it.

its long-term architecture is closer to an **ai software workshop**:

```text
                    your idea
                       │
                       ▼
                 ┌───────────┐
                 │  loundy   │
                 │   core    │
                 └─────┬─────┘
                       │
                       ▼
                 ┌───────────┐
                 │  planner  │
                 └─────┬─────┘
                       │
                       ▼
              ┌─────────────────┐
              │ model + agents  │
              └────────┬────────┘
                       │
                       ▼
              ┌─────────────────┐
              │ ai's environment│
              └────────┬────────┘
                       │
                compile + test
                       │
                  ┌────┴────┐
                  │         │
                works     fails
                  │         │
                  │    diagnose/fix
                  │         │
                  └────┬────┘
                       ▼
                    result
```

![loundrycode architecture](docs/assets/architecture.svg)

## 🖥️ ai's environment

one of the biggest ideas in loundrycode is **ai's environment**.

when the ai needs to actually build something, it should have access to a real execution environment rather than a pretend terminal animation.

that means the environment can contain things such as:

- a filesystem
- a shell
- source files
- package managers
- runtimes
- compilers
- build tools
- processes
- test runners
- logs
- artifacts

for example, an agent could request a command like `npm install` through the environment abstraction without needing to hard-code whether the underlying machine uses windows, linux, or another supported system.

### environment targets

loundrycode is designed to eventually support environments ranging from windows to linux, with other environments possible through adapters.

conceptually, an environment can be described as:

```text
operating system
      +
shell
      +
filesystem
      +
runtimes
      +
compilers
      +
packages
      +
processes
      =
ai's environment
```

this abstraction is important because loundrycode should not depend on one giant computer sitting in a mysterious warehouse somewhere. ☁️🖥️

execution can eventually be routed to different backends such as local machines, hosted runners, github actions, user-provided servers, or other compatible compute providers.

## 🤖 ai orchestration

loundrycode itself is intended to act as the **orchestrator**.

rather than assuming one model can do everything, the system can coordinate specialized agents and model providers.

possible responsibilities include:

- understanding the user's request
- turning an idea into a project plan
- generating and editing files
- delegating subtasks
- selecting tools
- running commands
- compiling projects
- executing tests
- inspecting failures
- applying fixes
- retrying failed work
- presenting useful progress to the user

retries should always have sensible limits. a broken build should not summon an infinite army of agents at 3:00 am. 😭

## 👀 visible ai activity

loundrycode should make ai work **visible without exposing private chain-of-thought**.

there will be a visible thinking/processing experience that can communicate high-level activity such as:

- understanding the request
- planning the architecture
- generating a project
- installing dependencies
- compiling
- running tests
- diagnosing an error
- applying a fix
- trying again

this gives the user a useful window into progress while keeping private internal reasoning private.

## ✖️ the extra menu

loundrycode is planned to have a small, detailed x-style action button that opens additional tools and views.

one of the important entries is:

**ai's environment**

that view is intended to let you watch the actual execution environment doing its work: terminals, files, builds, processes, logs, and tests.

## 🧺 unorthodox

**unorthodox** is the more powerful version of the loundrycode experience.

it is intended to provide:

- stronger models
- stronger subagents
- more aggressive ai workflows
- some additional visual polish
- more compute capacity

unorthodox is not meant to turn the normal app into a locked box. the goal is for free users to be able to experience it too, with usage limits based on the compute cost.

### usage model

there are **no credits** in loundrycode.

instead, unorthodox usage is handled as a rolling availability system:

| plan | unorthodox slots |
| --- | ---: |
| free | ~10 |
| pro | ~20 |

slots refresh over time, with the intended maximum refresh window being around several hours rather than a huge multi-day reset.

when free usage is temporarily exhausted, the app should simply explain that unorthodox is unavailable until usage refreshes. it should not turn the interface into a credit vending machine.

## 💳 pro

pro is intended primarily to provide **more expensive compute capacity** for people who need it.

loundrycode should not constantly interrupt the user with giant upgrade banners, promo codes, or sales popups.

pro should be discoverable, but quiet.

## 📱 ios-first

loundrycode is being designed around an ios-first experience.

that means the interface should be designed for touch, small screens, and fast interactions instead of taking a desktop application and shrinking it until every button becomes a microscopic pancake.

long-term, the project can coordinate remote execution when ios itself cannot perform a particular build or runtime task locally.

## 🏗️ planned architecture

an early conceptual repository layout looks like this:

```text
loundrycode/
├── app/
│   ├── ui/
│   ├── onboarding/
│   └── loundy/
├── core/
│   ├── ai/
│   ├── agents/
│   ├── projects/
│   ├── environments/
│   └── workflows/
├── environments/
│   ├── linux/
│   ├── windows/
│   └── other/
├── runtimes/
│   ├── python/
│   ├── javascript/
│   ├── rust/
│   └── ...
├── backend/
│   ├── model-providers/
│   ├── execution/
│   └── orchestration/
├── docs/
│   └── assets/
└── .github/
    └── workflows/
```

this is a direction, not a claim that all of these folders already exist.

## 🧩 model providers

loundrycode should avoid being permanently tied to one ai provider.

an eventual provider layer can make it possible to connect different models and services through a common interface while allowing the orchestrator to choose what is appropriate for a task.

that architecture also makes it easier to support:

- different model families
- hosted models
- compatible apis
- specialized coding models
- future providers
- user-provided endpoints where appropriate

## 🛠️ execution backends

because loundrycode is not being built around owning a giant data center, compute should be treated as an interchangeable backend.

possible execution backends include:

- local execution
- github actions
- hosted runners
- remote machines
- user-provided servers
- gpu-backed services
- other compatible execution providers

this lets the app grow without forcing the project to own every compiler, gpu, and server on earth.

## 🎨 loundy

loundy is the little mascot living at the center of the experience.

for the early onboarding experience, loundy can be animated without requiring complicated animation software. a sequence of carefully designed monospace/ascii frames can create a spinning or changing head animation.

possible states include:

- idle
- thinking
- processing
- compiling
- success
- error

loundy should feel calm and competent, with just enough personality to make the system feel alive.

## 🧪 development philosophy

loundrycode is being built around a few principles:

### simple outside, huge inside

the user interface should feel small and understandable even if the backend is enormous.

### real tools, not fake theater

when the ai says it is building or testing something, the goal is for real execution to happen somewhere appropriate.

### no credit treadmill

usage limits may exist where compute has a real cost, but the product should not revolve around artificial little coins.

### model-agnostic architecture

models and providers should be replaceable pieces rather than the entire identity of the application.

### visible progress

users should be able to understand what the system is currently doing without being shown private chain-of-thought.

### fail, learn, retry

build errors are part of software development. loundrycode should be designed to diagnose failures and try useful fixes instead of immediately giving up.

## 🚀 development roadmap

### phase 0: foundation

- [x] repository created
- [x] project direction documented
- [x] gitignore added
- [ ] ios application shell
- [ ] initial loundy onboarding

### phase 1: first working builder

- [ ] project creation
- [ ] basic ai provider interface
- [ ] agent/tool system
- [ ] filesystem operations
- [ ] terminal environment
- [ ] linux execution environment
- [ ] build/test loop
- [ ] retry handling

### phase 2: ai's environment

- [ ] real environment viewer
- [ ] live terminal output
- [ ] process visibility
- [ ] build logs
- [ ] test results
- [ ] generated artifacts

### phase 3: bigger workshop

- [ ] additional operating system adapters
- [ ] more runtimes
- [ ] more compilers
- [ ] remote execution backends
- [ ] richer subagent orchestration
- [ ] provider expansion

### phase 4: unorthodox

- [ ] stronger model routing
- [ ] stronger subagents
- [ ] expanded compute capacity
- [ ] rolling usage system
- [ ] additional visual polish

## 🔐 privacy and credentials

loundrycode should treat credentials and provider keys as sensitive configuration.

secrets, local environment files, generated build artifacts, caches, and machine-specific configuration should not be committed to the repository.

providers and execution backends should be designed so that credentials can remain on the appropriate side of the connection instead of becoming part of the source tree.

## 📦 contributing

this project is currently in a very early stage, so the architecture may change substantially as implementation begins.

when contributing, prefer small, understandable changes and keep the public interface simple. if a feature makes the system dramatically more complicated, it should have a good reason to exist.

## 📄 license

loundrycode is released under the license included in this repository.

## 🧺 the short version

**loundrycode takes messy ideas and tries to turn them into working software.**

simple interface. huge machinery underneath. real environments. ai agents. compilation. testing. retries. and a tiny spinning head named loundy watching the whole thing happen.

welcome to the laundry. 🧺🤖✨
