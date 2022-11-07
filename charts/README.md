
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/charon)](https://artifacthub.io/packages/search?repo=charon)

# Charon Chart

The curated list of Obol helm charts. Every chart is located in a separate folder and has the configuration parameters located in `values.yaml` file.

## TL;DR

```bash
$ helm repo add obol https://obolnetwork.github.io/helm-charts
$ helm install my-release obol/charon
```

## Before you begin

### Prerequisites

- Kubernetes 1.18+
- Helm 3
- PV provisioner support in the underlying infrastructure for some charts

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

* Install a chart: `helm install my-release obol/charon`
* Upgrade your application: `helm upgrade`
* Uninstall a chart: `helm uninstall my-release`
