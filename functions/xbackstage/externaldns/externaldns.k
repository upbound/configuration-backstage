import models.io.crossplane.helm.v1beta1 as helmv1beta1
import models.io.upbound.platform.aws.v1alpha1 as awsv1alpha1
import crossplane.v1alpha1 as crossplanev1alpha1

import utils
import json

externaldns = lambda config: ExternalDNS -> any {
    """
   Creates an ExternalDNS Deployment.
   """
    [
        if utils.ready(utils.get(config.ocds, config.dependsOn, {})) or utils.exists("{}-external-dns".format(config.name),config.ocds):
            helmv1beta1.Release {
                metadata: utils._metadata("{}-external-dns".format(config.name)) | {
                    annotations: {
                        "crossplane.io/external-name" = "external-dns"
                    }
                    labels: {
                        type: "{}-external-dns".format(config.name)
                    }
                }
                spec: {
                    deletionPolicy: config.deletionPolicy
                    providerConfigRef: {
                        name: config.id
                    }
                    forProvider: {
                        wait: True
                        namespace: "external-dns"
                        chart: {
                            name: "external-dns"
                            repository: "https://charts.bitnami.com/bitnami"
                            version: "8.8.2"
                        }
                        values: {
                            replicaCount: 2
                            provider: "aws"
                            policy: "sync"
                            source: "ingress"
                            registry: "txt"
                            txtOwnerId: "{}-{}".format(config.name, config.clusterName)
                            # domainFilters: [
                            #     # ToDo(haarchri): limit access to a specific zone from zoneId
                            # ]
                            aws: {
                                # we need 5: "Total changes for 0 exceeds max batch size of 4, total changes: 5; changes will not be performed"
                                batchChangeSize: 5
                                zoneType: "public"
                                # Zones are Global
                                region: "us-east-1"
                            }
                            rbac: {
                                create: True
                            }
                            serviceAccount: {
                                create: True
                                name: "external-dns"
                            }
                            metrics: {
                                enabled: False
                                serviceMonitor: {
                                    enabled: False
                                }
                            }
                            podDisruptionBudget: {
                                minAvailable: 1
                            }
                        }
                    }
                }
            }

        if utils.ready(utils.get(config.ocds, config.dependsOn, {})) or utils.exists("{}-external-dns-usage-xeks".format(config.name),config.ocds):
            crossplanev1alpha1.Usage {
            metadata: utils._metadata("{}-external-dns-usage-xeks".format(config.name))
                spec: {
                    replayDeletion: True
                    by: {
                        apiVersion: "helm.crossplane.io/v1beta1"
                        kind: "Release"
                        resourceSelector: {
                            matchLabels: {
                                type: "{}-external-dns".format(config.name)
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

        awsv1alpha1.XPodIdentity {
            metadata: utils._metadata(config.name + "-external-dns-pi")
            spec: {
                parameters: {
                    deletionPolicy: config.deletionPolicy
                    providerConfigName: config.providerConfigName
                    clusterName: config.clusterName
                    inlinePolicy: [
                        {
                            name: "external-dns"
                            policy: json.encode({
                                Version: "2012-10-17"
                                Statement: [
                                    {
                                        Effect: "Allow"
                                        Action: [
                                            "route53:ListResourceRecordSets"
                                            "route53:ListHostedZones"
                                        ]
                                        Resource: "*"
                                    }
                                    {
                                        Effect: "Allow"
                                        Action: "route53:ChangeResourceRecordSets"
                                        Resource: "arn:aws:route53:::hostedzone/{}".format(config.zoneId)
                                    }
                                ]
                            })
                        }
                    ]
                    region: config.region
                    serviceAccount: {
                        name: "external-dns"
                        namespace: "external-dns"
                    }
                }
            }
        }
    ]
}
