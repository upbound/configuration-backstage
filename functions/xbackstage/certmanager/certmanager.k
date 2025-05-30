import models.io.crossplane.helm.v1beta1 as helmv1beta1
import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2
import crossplane.v1alpha1 as crossplanev1alpha1

import utils

certManager = lambda config: CertManager -> any {
    """
   Creates an Cert Manager Deployment.
   """
    [
        if utils.ready(utils.get(config.ocds, config.dependsOn, {})) or utils.exists("{}-cert-manager".format(config.name),config.ocds):
            helmv1beta1.Release {
                metadata: utils._metadata("{}-cert-manager".format(config.name)) | {
                    annotations: {
                        "crossplane.io/external-name" = "cert-manager"
                    }
                    labels: {
                        type: "{}-cert-manager".format(config.name)
                    }
                }
                spec: {
                    deletionPolicy: config.deletionPolicy
                    providerConfigRef: {
                        name: config.id
                    }
                    forProvider: {
                        wait: True
                        namespace: "cert-manager"
                        chart: {
                            version: "v1.17.2"
                            repository: "https://charts.jetstack.io"
                            name: "cert-manager"
                        }
                        values: {
                            installCRDs: True
                            global: {
                                leaderElection: {
                                    namespace: "cert-manager"
                                }
                            }
                        }
                    }
                }
            }

        if utils.ready(utils.get(config.ocds, config.dependsOn, {})) or utils.exists("{}-cert-manager-usage-xeks".format(config.name),config.ocds):
            crossplanev1alpha1.Usage {
                metadata: utils._metadata("{}-cert-manager-usage-xeks".format(config.name))
                spec: {
                    replayDeletion: True
                    by: {
                        apiVersion: "helm.crossplane.io/v1beta1"
                        kind: "Release"
                        resourceSelector: {
                            matchLabels: {
                            type: "{}-cert-manager".format(config.name)
                            }
                        }
                    }
                    of: {
                        apiVersion: "aws.platform.upbound.io/v1alpha1"
                        kind: "XEKS"
                        resourceSelector: {
                            matchControllerRef: True
                        }
                    }
                }
            }

        if utils.ready(utils.get(config.ocds, config.dependsOn, {})) or utils.exists("{}-clusterissuer".format(config.name),config.ocds):
            kubernetesv1alpha2.Object {
                metadata: utils._metadata("{}-clusterissuer".format(config.name))
                spec: {
                    deletionPolicy: config.deletionPolicy
                    providerConfigRef: {
                        name: config.id
                    }
                    forProvider: {
                        manifest: {
                            apiVersion: "cert-manager.io/v1"
                            kind: "ClusterIssuer"
                            metadata: {
                                name: "letsencrypt-prod"
                            }
                            spec: {
                                acme: {
                                    server: "https://acme-v02.api.letsencrypt.org/directory"
                                    privateKeySecretRef: {
                                        name: "letsencrypt-prod"
                                    }
                                    solvers: [{
                                        http01: {
                                            ingress: {
                                                ingressClassName: "nginx"
                                            }
                                        }
                                    }]
                                }
                            }
                        }
                    }
                }
            }
    ]
}
