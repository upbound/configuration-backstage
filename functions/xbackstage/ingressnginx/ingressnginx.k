import models.io.crossplane.helm.v1beta1 as helmv1beta1
import crossplane.v1alpha1 as crossplanev1alpha1
import utils

ingressnginx = lambda iconfig: IngressNginx -> any {
    """
   Creates an IngressNginx Deployment.
   """
    [
        if utils.ready(utils.get(iconfig.ocds, iconfig.dependsOn, {})) or utils.exists("{}-ingress".format(iconfig.name),iconfig.ocds):
            helmv1beta1.Release {
                metadata: utils._metadata("{}-ingress".format(iconfig.name)) | {
                    annotations: {
                        "crossplane.io/external-name" = "ingress-nginx"
                    }
                    labels: {
                        type: "{}-ingress".format(iconfig.name)
                    }
                }
                spec: {
                    deletionPolicy: iconfig.deletionPolicy
                    providerConfigRef: {
                        name: iconfig.id
                    }
                    forProvider: {
                        wait: True
                        namespace: "ingress-nginx"
                        chart: {
                            version: "4.12.2"
                            repository: "https://kubernetes.github.io/ingress-nginx"
                            name: "ingress-nginx"
                        }
                        values: {
                            controller: {
                                config: {
                                    hsts: "false"
                                }
                                service: {
                                    type: "LoadBalancer"
                                    annotations: {
                                        "service.beta.kubernetes.io/aws-load-balancer-name": iconfig.clusterName
                                        "service.beta.kubernetes.io/aws-load-balancer-type": "external"
                                        "service.beta.kubernetes.io/aws-load-balancer-scheme": "internet-facing"
                                        "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "ip"
                                    }
                                    loadBalancerClass: "service.k8s.aws/nlb"
                                    targetPorts: {
                                        https: "https"
                                    }
                                }
                                extraArgs: {
                                    "enable-ssl-passthrough": True
                                }
                            }
                        }
                    }
                }
            }

        if utils.ready(utils.get(iconfig.ocds, iconfig.dependsOn, {})) or utils.exists("{}-ingress-usage-xeks".format(iconfig.name),iconfig.ocds):
            crossplanev1alpha1.Usage {
                metadata: utils._metadata("{}-ingress-usage-xeks".format(iconfig.name))
                spec: {
                    replayDeletion: True
                    by: {
                        apiVersion: "helm.crossplane.io/v1beta1"
                        kind: "Release"
                        resourceSelector: {
                            matchLabels: {
                                type: "{}-ingress".format(iconfig.name)
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
    ]
}
