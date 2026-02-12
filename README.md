![Obol Logo](https://obol.tech/obolnetwork.png)

<h1 align="center">Obol Helm Charts</h1>

[![Release Charts](https://github.com/ObolNetwork/helm-charts/actions/workflows/release.yml/badge.svg?branch=main)](https://github.com/ObolNetwork/helm-charts/actions/workflows/release.yml)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/charon)](https://artifacthub.io/packages/search?org=obol)

This repo contains Helm Charts for deploying Obol Distributed Validator [middleware clients](https://github.com/ObolNetwork/charon) on Kubernetes using [Helm](https://helm.sh/).  

## List of charts

- [`charon`](charts/charon) - A chart for running a single charon container.
- [`charon-cluster`](charts/charon-cluster) - A chart for running a number of charon instances.
- [`charon-relay`](charts/charon-relay) - A chart for running a charon [relay](https://docs.obol.org/learn/charon/charon-cli-reference#host-a-relay).
- [`dv-pod`](charts/dv-pod) - A chart for running a Charon client + a Validator client, with automatic DKG completion as a feature. 
- [`obol-app`](charts/obol-app) - A chart for running arbitrary docker images in the [Obol Stack](https://obol.org/stack).
- [`aztec-node`](charts/aztec-node) - Aztec network node deployment (Full Node, Sequencer, or Prover)
- [`openclaw`](charts/openclaw) - OpenClaw gateway deployment (agent runtime)

## Before you begin

### Prerequisites

- Kubernetes 1.18+
- Helm 3

### Setup a Kubernetes Cluster

For setting up Kubernetes on cloud platforms or bare-metal servers refer to the
Kubernetes [getting started guide](http://kubernetes.io/docs/getting-started-guides/).

### Install Helm

Helm is a tool for managing Kubernetes charts. Charts are packages of pre-configured Kubernetes resources.

To install Helm, refer to the [Helm install guide](https://github.com/helm/helm#install) and ensure that the `helm`
binary is in the `PATH` of your shell.

### Using Helm

Once you have installed the Helm client, you can deploy a charts located in this repository into a Kubernetes cluster.

Please refer to the [Quick Start guide](https://helm.sh/docs/intro/quickstart/) if you wish to get running in just a few
commands, otherwise the [Using Helm Guide](https://helm.sh/docs/intro/using_helm/) provides detailed instructions on how
to use the Helm client to manage packages on your Kubernetes cluster.

Useful Helm Client Commands:

* Install a chart: `helm install <release-name> obol/<chart-name>`
* Upgrade your application: `helm upgrade`
* Uninstall a chart: `helm uninstall <release-name>`

## Development

### Prerequisites

- [`pre-commit`](https://pre-commit.com/) - Used to setup pre-commit git hooks
- [`docker`](https://www.docker.com/) - Used by many Makefile targets

### Pre-commit hooks

This repository used [`pre-commit`](https://pre-commit.com/) to manage and run certain git hooks. Hook definitions can be found within the [`.pre-commit-config.yaml`](.pre-commit-config.yaml) file.

Run the following to add the hooks to your local repository:

```sh
make init
```

### Useful commands

The `README` for every chart is auto generated using [helm-docs](https://github.com/norwoodj/helm-docs). This is defined as a pre-commit hook. If you want to run it manually, you can run:

```sh
make docs
```

The [CT (Chart Testing)](https://github.com/helm/chart-testing) tool is used to lint and validate charts. You can run this via:

```sh
make lint
```
