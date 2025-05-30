# Backstage Configuration

This repository contains an [Upbound](https://cloud.upbound.io) project designed to help users set up their first control plane. It includes a configuration for deploying Backstage, with optional integrations for managed services such as:

* [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks)
* AWS networking components
* AWS Load Balancer Controller
* External DNS Controller
* NGINX Ingress Controller
* Cert Manager
* EKS Pod Identity for service-level access control

## Overview

This project defines a custom API in an [Upbound Project](https://docs.upbound.io/learn/control-plane-project/), composed of the following core elements:

* **CompositeResourceDefinition (XRD):** Defines the schema for the custom API resource.
* **Composition(s):** Configures the control plane’s function pipeline.
* **Embedded Function(s):** Contains the logic and implementation of the Composition in a reusable unit.

Specifically, this configuration provides:

* A custom resource type defined in [XBackstage](/apis/xbackstages/definition.yaml)
* A Composition defined in [/apis/composition.yaml](/apis/xbackstages/composition.yaml)
* Embedded logic implemented in [main.k](/functions/xbackstage/main.k)

## Deployment

You can deploy this configuration by:

* Running `up project run`
* Installing it via the [Upbound Marketplace](https://marketplace.upbound.io/configurations/upbound/configuration-backstage)

Refer to the [examples directory](/examples/) for sample composite resources (XRs).

## Testing

To validate the configuration, you can:

* Render the composition:

  ```bash
  up composition render --xrd=apis/xbackstages/definition.yaml apis/xbackstages/composition.yaml examples/xbackstage/example.yaml
  ```
* Run unit tests:

  ```bash
  up test run tests/*
  ```
* Run end-to-end tests:

  ```bash
  up test run tests/* --e2e
  ```

## Next Steps

This configuration serves as a starting point. You can extend it by:

1. Creating additional API definitions in this repository.
2. Modifying the existing API definition to better suit your requirements.

For more guidance on building APIs for managed control planes in Upbound, refer to the [official documentation](https://docs.upbound.io/).
