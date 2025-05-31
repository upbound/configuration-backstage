import models.io.crossplane.helm.v1beta1 as helmv1beta1
import crossplane.v1alpha1 as crossplanev1alpha1

import utils
import crypto
import strategic_merge_patch as s

backstage = lambda config: Backstage -> any {
    """
   Creates an Backstage Deployment.
   """
    [
        if utils.ready(utils.get(config.ocds, config.dependsOn, {})) or utils.exists("{}-backstage".format(config.name),config.ocds):
            helmv1beta1.Release {
                metadata: utils._metadata( "{}-backstage".format(config.name)) | {
                    annotations: {
                        "crossplane.io/external-name" = "backstage"
                    }
                    labels: {
                        type: "{}-backstage".format(config.name)
                    }
                }
                spec: {
                    deletionPolicy: config.deletionPolicy
                    providerConfigRef: {
                        name: config.id
                    }
                    forProvider: {
                        wait: True
                        namespace: "backstage"
                        chart: {
                            name: "backstage"
                            repository: "https://backstage.github.io/charts"
                            version: "2.5.2"
                        }
                        values: ValuesSchema {
                            if config.ingress.enabled:
                                ingress: ValuesSchemaIngress {
                                    host: config.ingress.host
                                    enabled: config.ingress.enabled
                                    annotations: ValuesSchemaIngressAnnotations {
                                        if config.ingress.clusterIssuer != "":
                                            "cert-manager.io/cluster-issuer": config.ingress.clusterIssuer
                                    }
                                    className: config.ingress.className
                                    tls: ValuesSchemaIngressTls {
                                        enabled: True
                                        secretName: "backstage-tls"
                                    }
                                }
                            backstage: ValuesSchemaBackstage {
                                image: {
                                    repository: config.image.repository
                                    registry: config.image.registry
                                    tag: config.image.tag
                                }
                                extraEnvVars:[
                                    {
                                        name: "UP_ROBOT_TOKEN"
                                        valueFrom: {
                                            secretKeyRef: {
                                                key: "token"
                                                name: "up-secret"
                                            }
                                        }
                                    }
                                ]
                                appConfig: s.merge({
                                    app: {
                                        baseUrl: "https://{}".format(config.ingress.host)
                                        title: "upbound solution-idp"
                                    }
                                    backend: {
                                        baseUrl: "https://{}".format(config.ingress.host)
                                        cors: {
                                            origin: [
                                                "http://localhost:7007"
                                                "https://{}".format(config.ingress.host)
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
                                                {host: 'gist.githubusercontent.com'}
                                                {host: 'raw.githubusercontent.com'}
                                                {host: 'github.com'}
                                                {host: '*.github.com'}
                                            ]
                                        }
                                    }
                                    auth: {
                                        environment: "development"
                                        providers: {
                                            guest: {
                                                userEntityRef: "user:default/john-smith"
                                                ownershipEntityRefs: [
                                                    "group:default/smith-family"
                                                ]
                                                dangerouslyAllowOutsideDevelopment: True
                                            }
                                        }
                                    }
                                    techdocs: {
                                        builder: 'local'
                                        generator: {
                                            runIn: 'docker'
                                        }
                                        publisher: {
                                            type: 'local'
                                        }
                                    }
                                    database: {
                                        client: "pg"
                                        connection: {
                                            host: "\\${POSTGRES_HOST}"
                                            port: "\\${POSTGRES_PORT}"
                                            user: "\\${POSTGRES_USER}"
                                            password: "\\${POSTGRES_PASSWORD}"
                                        }
                                    }
                                    permission: {
                                        enabled: False
                                    }
                                    catalog: {
                                        import: {
                                            entityFilename: "catalog-info.yaml"
                                            pullRequestBranchName: "backstage-integration"
                                        }
                                        rules: [
                                            {allow: ["Component", "System", "API", "Resource", "Location"]}
                                        ]
                                        locations: [
                                            {
                                                type: "url"
                                                target: "https://gist.githubusercontent.com/haarchri/aaa03c8d30db4b03aa601d59b1a9c066/raw/65044e49acd78e0368955a2ddaff52e53f6a24e4/catalog-info.yaml"
                                            }
                                        ]
                                        useUrlReadersSearch: True
                                    }
                                    kubernetes: {
                                        frontend: {
                                            podDelete: {
                                                enabled: True
                                            }
                                        }
                                        skipMetricsLookup: True
                                        serviceLocatorMethod: {
                                            type: "multiTenant"
                                        }
                                        objectTypes: [
                                            "configmaps"
                                            "deployments"
                                            "pods"
                                            "services"
                                        ]
                                    }
                                    crossplane: {
                                        enablePermissions: False
                                    }
                                    kubernetesIngestor: {
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
                                            customWorkloadTypes: []
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
                                }, config.config)
                            }
                            postgresql: ValuesSchemaPostgresql {
                                enabled: True
                                auth: ValuesSchemaPostgresqlAuth {
                                    username: "bn_backstage"
                                    password: crypto.sha256(config.name)
                                    secretKeys: ValuesSchemaPostgresqlAuthSecretKeys {
                                        adminPasswordKey: "postgres-password"
                                        userPasswordKey: "password"
                                    }
                                }
                            }
                        }
                    }
                }
            }

        if utils.ready(utils.get(config.ocds, config.dependsOn, {})) or utils.exists("{}-backstage-usage-xeks".format(config.name),config.ocds):
            crossplanev1alpha1.Usage {
                metadata: utils._metadata("{}-backstage-usage-xeks".format(config.name))
                spec: {
                    replayDeletion: True
                    by: {
                        apiVersion: "helm.crossplane.io/v1beta1"
                        kind: "Release"
                        resourceSelector: {
                            matchLabels: {
                                type: "{}-backstage".format(config.name)
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

        if utils.ready(utils.get(config.ocds, config.dependsOn, {})) or utils.exists("{}-backstage-usage-lb".format(config.name),config.ocds):
            crossplanev1alpha1.Usage {
                metadata: utils._metadata("{}-backstage-usage-lb".format(config.name))
                spec: {
                    replayDeletion: True
                    by: {
                        apiVersion: "helm.crossplane.io/v1beta1"
                        kind: "Release"
                        resourceSelector: {
                            matchLabels: {
                                type: "{}-backstage".format(config.name)
                            }
                        }
                    }
                    of: {
                        apiVersion: "helm.crossplane.io/v1beta1"
                        kind: "Release"
                        resourceSelector: {
                            matchLabels: {
                                type: "{}-lb-controller".format(config.name)
                            }
                        }
                    }
                }
            }
    ]
}
