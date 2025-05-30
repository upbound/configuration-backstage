import models.io.upbound.platform.aws.v1alpha1 as platformawsv1alpha1
import models.io.crossplane.helm.v1beta1 as helmv1beta1

_xeks = platformawsv1alpha1.XEKS {
    metadata: {
        annotations: {
            "crossplane.io/composition-resource-name": "xeks"
        }
    }
    spec: {
        parameters: {
            accessConfig: {
                authenticationMode: "API"
                bootstrapClusterCreatorAdminPermissions: True
            }
            deletionPolicy: "Delete"
            iam: {
                principalArn: "arn:aws:iam::609897127049:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_d703c73ed340fde7"
            }
            id: "solution-idp-non-prod-frontend"
            nodes: {
                count: 1
                instanceType: "m4.2xlarge"
            }
            providerConfigName: "default"
            region: "us-west-2"
            version: "1.27"
        }
        writeConnectionSecretToRef: {
            name: "test123"
            namespace: "crossplane-system"
        }
    }
}

_xnetwork = platformawsv1alpha1.XNetwork {
    metadata.annotations: {
        "crossplane.io/composition-resource-name": "xnetwork"
    }
    spec: {
        parameters: {
            deletionPolicy: "Delete"
            id: "solution-idp-non-prod-frontend"
            providerConfigName: "default"
            region: "us-west-2"
            vpcCidrBlock: "192.168.0.0/16"
            subnets: [
                {
                    availabilityZone: "us-west-2a"
                    cidrBlock: "192.168.0.0/18"
                    type: "public"
                }
                {
                    availabilityZone: "us-west-2b"
                    cidrBlock: "192.168.64.0/18"
                    type: "public"
                }
                {
                    availabilityZone: "us-west-2a"
                    cidrBlock: "192.168.128.0/18"
                    type: "private"
                }
                {
                    availabilityZone: "us-west-2b"
                    cidrBlock: "192.168.192.0/18"
                    type: "private"
                }
            ]
        }
    }
}

_ingress = helmv1beta1.Release {
    metadata.annotations: {
        "crossplane.io/composition-resource-name" = "solution-idp-ingress"
        "crossplane.io/external-name" = "ingress-nginx"
    }
    spec: {
        deletionPolicy: "Delete"
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
                            "service.beta.kubernetes.io/aws-load-balancer-name": "uptest"
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
        providerConfigRef: {
            name: "solution-idp-non-prod-frontend"
        }
    }
}

_backstage = helmv1beta1.Release {
    metadata.annotations: {
         "crossplane.io/composition-resource-name" = "solution-idp-backstage"
        "crossplane.io/external-name" = "backstage"
    }
    spec: {
        deletionPolicy: "Delete"
        providerConfigRef: {
            name: "solution-idp-non-prod-frontend"
        }
        forProvider: {
            wait: True
            namespace: "backstage"
            chart: {
                name: "backstage"
                repository: "https://backstage.github.io/charts"
                version: "2.5.2"
            }
            values: {
                ingress: {
                    host: "backstage-solution-idp.upboundrocks.cloud"
                    enabled: True
                    annotations:  {
                        "cert-manager.io/cluster-issuer": "letsencrypt-prod"
                    }
                    className: "nginx"
                    tls: {
                        enabled: True
                        secretName: "backstage-tls"
                    }
                }
                backstage: {
                    image: {
                        repository: "haarchri/solution-idp_backstage"
                        registry: "docker.io"
                        tag: "v0.1.0"
                    }
                    appConfig: {
                        app: {
                            baseUrl: "https://backstage-solution-idp.upboundrocks.cloud"
                            title: "solution-idp"
                        }
                        backend: {
                            baseUrl: "https://backstage-solution-idp.upboundrocks.cloud"
                            cors: {
                                origin: [
                                    "http://localhost:7007"
                                    "https://backstage-solution-idp.upboundrocks.cloud"
                                ]
                                methods: [
                                    "GET"
                                    "HEAD"
                                    "PATCH"
                                    "POST"
                                    "PUT"
                                    "DELETE"
                                ]
                                credentials: True
                            }
                            reading: {
                                allow: [
                                    {
                                        host: 'gist.githubusercontent.com'
                                    }
                                    {
                                        host: 'raw.githubusercontent.com'
                                    }
                                    {
                                        host: 'github.com'
                                    }
                                    {
                                        host: '*.github.com'
                                    }
                                ]
                            }
                        }
                        kubernetesIngestor: {
                            mappings: {
                                systemModel: "cluster-namespace"
                            }
                            components: {
                                enabled: True
                                taskRunner: {
                                    frequency: 10
                                    timeout: 600
                                }
                                excludedNamespaces: [
                                    "kube-public"
                                    "kube-system"
                                    "crossplane-system"
                                ]
                                customWorkloadTypes: [
                                    {
                                        group: "aws.platform.upbound.io"
                                        apiVersion: "v1alpha1"
                                        plural: "xeks"
                                    }
                                    {
                                        group: "aws.platform.upbound.io"
                                        apiVersion: "v1alpha1"
                                        plural: "xnetworks"
                                    }
                                    {
                                        group: "aws.platform.upbound.io"
                                        apiVersion: "v1alpha1"
                                        plural: "xpodidentities"
                                    }
                                    {
                                        group: "pkg.crossplane.io"
                                        apiVersion: "v1"
                                        plural: "providers"
                                    }
                                ]
                                disableDefaultWorkloadTypes: True
                                onlyIngestAnnotatedResources: False
                            }
                            crossplane: {
                                claims: {
                                    ingestAllClaims: True
                                }
                                xrds: {
                                    publishPhase: {
                                        allowRepoSelection: False
                                    }
                                    enabled: True
                                    taskRunner: {
                                        frequency: 10
                                        timeout: 600
                                    }
                                    ingestAllXRDs: True
                                    convertDefaultValuesToPlaceholders: True
                                }
                            }
                        }
                    }
                }
                postgresql: {
                    enabled: True
                    auth: {
                        username: "bn_backstage"
                        secretKeys: {
                            adminPasswordKey: "postgres-password"
                            userPasswordKey: "password"
                        }
                    }
                }
            }
        }
    }
}


_lbcontoller = helmv1beta1.Release {
    metadata.annotations: {
        "crossplane.io/composition-resource-name" = "solution-idp-lb-controller"
        "crossplane.io/external-name" = "aws-load-balancer-controller"
    }
    spec: {
        deletionPolicy: "Delete"
        providerConfigRef: {
            name: "solution-idp-non-prod-frontend"
        }
        forProvider: {
            wait: True
            namespace: "kube-system"
            chart: {
                name: "aws-load-balancer-controller"
                repository: "https://aws.github.io/eks-charts"
            }
            values: {
                vpcId: "test123"
                serviceAccount: {
                    name: "aws-load-balancer-controller"
                }
                clusterName: "uptest"
            }
        }
    }
}

_certmanager = helmv1beta1.Release {
    metadata.annotations: {
        "crossplane.io/composition-resource-name" = "solution-idp-cert-manager"
        "crossplane.io/external-name" = "cert-manager"
    }
    spec: {
        deletionPolicy: "Delete"
        providerConfigRef: {
            name: "solution-idp-non-prod-frontend"
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

_externaldns = helmv1beta1.Release {
    metadata.annotations: {
        "crossplane.io/composition-resource-name" = "solution-idp-external-dns"
        "crossplane.io/external-name" = "external-dns"
    }
    spec: {
        deletionPolicy: "Delete"
        providerConfigRef: {
            name: "solution-idp-non-prod-frontend"
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
                txtOwnerId: "solution-idp-uptest"
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