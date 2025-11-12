
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.sa.v1alpha1 as sav1alpha1

_items = [
    metav1alpha1.E2ETest {
        metadata.name: ""
        spec = {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            manifests: [
                sav1alpha1.XBackstage {
                    metadata = {
                        name: "e2e-backstage"
                        uid: "e2e-test-123"
                    }
                    spec = {
                        parameters = {
                            id: "e2e-backstage-test"
                            region: "us-west-2"
                            deletionPolicy: "Delete"
                            providerConfigName: "default"
                            ingress = {
                                enabled: True
                                host: "backstage-solution-idp.upboundrocks.cloud"
                                clusterIssuer: "letsencrypt-prod"
                                className: "nginx"
                            }
                            replicas: 3
                            image = {
                                registry: "xpkg.upbound.io"
                                repository: "upbound/backstage"
                                tag: "v0.1.0"
                            }
                            config = {
                                app = {
                                    title: "e2e-backstage"
                                }
                                kubernetesIngestor = {
                                    mappings = {
                                        systemModel: "cluster-namespace"
                                    }
                                    components = {
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
                                    }
                                }
                            }
                            secretSync: [
                                {
                                    destRef = {
                                        name: "up-secret"
                                        namespace: "backstage"
                                    }
                                    sourceRef = {
                                        name: "e2e-backstage-test-robot-token"
                                        namespace: "crossplane-system"
                                    }
                                }
                            ]
                            infrastructure: {
                                ingressNginx: {}
                                certManager: {}
                                lbController: {}
                                externalDNS: {
                                    enabled: True
                                    route53ZoneId: "Z0115025YFQ7ZQF6BJ6N"
                                }
                                eks: {
                                    enabled: True
                                    clusterName: "configuration-gitops-backstage-cluster"
                                    accessConfig: {
                                        bootstrapClusterCreatorAdminPermissions: True
                                        authenticationMode: "API"
                                    }
                                    iam: {
                                        principalArn: "arn:aws:iam::609897127049:role/solutions-e2e-provider-aws"
                                    }
                                    version: "1.31"
                                    nodes: {
                                        count: 8
                                        instanceType: "t3.small"
                                    }
                                }
                            }
                        }
                    }
                }
            ]
            extraResources: [
                {
                    apiVersion: "aws.upbound.io/v1beta1"
                    kind: "ProviderConfig"
                    metadata.name: "default"
                    spec.credentials = {
                        source = "Upbound"
                        upbound = {
                            webIdentity = {
                                roleARN = "arn:aws:iam::609897127049:role/solutions-e2e-provider-aws"
                            }
                        }
                    }
                }
                {
                    apiVersion: "v1"
                    kind: "Secret"
                    metadata = {
                        name: "e2e-backstage-test-robot-token"
                        namespace: "crossplane-system"
                        labels = {
                            accessId: "e2e-test-access-id"
                        }
                    }
                    type: "Opaque"
                    stringData = {
                        token: "949395e5-6f4c-4d3c-9f7e-3f5f5f5f5f5f" # Dummy token
                    }
                }
            ]
            skipDelete: False
            timeoutSeconds: 4500
        }
    }
]
items = _items