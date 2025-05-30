import models.io.upbound.sa.v1alpha1 as sav1alpha1
import certmanager
import backstage
import ingressnginx
import externaldns
import lbcontroller
import xeks
import utils
import ctpSecretSync

oxr = sav1alpha1.XBackstage {**option("params").oxr}
# observed composed resources
_ocds = option("params").ocds
# desired composite resource
_dxr = option("params").dxr
# desired composed resources
dcds = option("params").dcds
# extra resources
_extra = option("params")?.extraResources

_items = []

if oxr.spec.parameters.infrastructure.eks.enabled:
    _items += xeks.xeks(xeks.XEKS {
        # shared
        id: oxr.spec.parameters.id
        providerConfigName: oxr.spec.parameters.providerConfigName
        region: oxr.spec.parameters.region
        deletionPolicy: oxr.spec.parameters.deletionPolicy
        # xeks
        accessConfig: oxr.spec.parameters.infrastructure.eks.accessConfig
        iam: oxr.spec.parameters.infrastructure.eks.iam
        nodes: oxr.spec.parameters.infrastructure.eks.nodes
        version: oxr.spec.parameters.infrastructure.eks.version
        uid: oxr.metadata.uid
        # xnetwork
        subnets: oxr.spec.parameters.infrastructure.network?.subnets
        vpcCidrBlock: oxr.spec.parameters.infrastructure.network?.vpcCidrBlock
    })

_items += [
    {
        apiVersion: "meta.krm.kcl.dev/v1alpha1"
        kind: "ExtraResources"
        requirements = {
            eks = {
                apiVersion: "eks.aws.upbound.io/v1beta2"
                kind: "Cluster"
                matchLabels: {
                    "crossplane.io/composite": oxr.metadata.name
                }
            },
        }
    }
]

if oxr.spec.parameters.infrastructure.eks.clusterName != "":
    _eksClusterName = oxr.spec.parameters.infrastructure.eks.clusterName

if _extra?.eks:
    _eksClusterName = _extra?.eks[0]?.Resource?.metadata?.name or ""

vpcId = _ocds["xnetwork"]?.Resource?.status?.vpcId

if oxr.spec.parameters.infrastructure.eks.enabled or (oxr.spec.parameters.infrastructure.eks.enabled == False and _eksClusterName != ""):

    if vpcId and _eksClusterName != Undefined:
        _items += lbcontroller.lbcontroller(lbcontroller.LBController {
            clusterName: _eksClusterName
            name: oxr.metadata.name
            vpcId: vpcId
            id: oxr.spec.parameters.id
            providerConfigName: oxr.spec.parameters.providerConfigName
            region: oxr.spec.parameters.region
            deletionPolicy: oxr.spec.parameters.deletionPolicy
            ocds: _ocds
            dependsOn: "xeks"
        })

    if oxr.spec.parameters.infrastructure.certManager.enabled:
        _items += certmanager.certManager(certmanager.CertManager {
            name: oxr.metadata.name
            id: oxr.spec.parameters.id
            deletionPolicy: oxr.spec.parameters.deletionPolicy
            ocds: _ocds
            dependsOn: "{}-lb-controller".format(oxr.metadata.name)
        })


    if oxr.spec.parameters.infrastructure.ingressNginx.enabled and _eksClusterName != Undefined:
        _items += ingressnginx.ingressnginx(ingressnginx.IngressNginx {
            name: oxr.metadata.name
            id: oxr.spec.parameters.id
            deletionPolicy: oxr.spec.parameters.deletionPolicy
            clusterName: _eksClusterName
            ocds: _ocds
            dependsOn: "{}-cert-manager".format(oxr.metadata.name)
        })


    if oxr.spec.parameters.infrastructure.externalDNS.enabled and _eksClusterName != Undefined:
        _items += externaldns.externaldns(externaldns.ExternalDNS {
            clusterName: _eksClusterName
            name: oxr.metadata.name
            id: oxr.spec.parameters.id
            providerConfigName: oxr.spec.parameters.providerConfigName
            region: oxr.spec.parameters.region
            zoneId: oxr.spec.parameters.infrastructure.externalDNS.route53ZoneId
            deletionPolicy: oxr.spec.parameters.deletionPolicy
            ocds: _ocds
            dependsOn: "{}-ingress".format(oxr.metadata.name)
        })

        _items += backstage.backstage(backstage.Backstage {
            name: oxr.metadata.name
            id: oxr.spec.parameters.id
            ingress: backstage.Ingress{
                className: oxr.spec.parameters.ingress.className
                clusterIssuer: oxr.spec.parameters.ingress.clusterIssuer
                enabled: oxr.spec.parameters.ingress.enabled
                host: oxr.spec.parameters.ingress.host
            }
            config: oxr.spec.parameters.config
            image: oxr.spec.parameters.image
            replicas: oxr.spec.parameters.replicas
            deletionPolicy: oxr.spec.parameters.deletionPolicy
            ocds: _ocds
            dependsOn: "{}-external-dns".format(oxr.metadata.name)
        })

    if oxr.spec.parameters.secretSync:
        _items += ctpSecretSync.syncedSecrets([ctpSecretSync.SecretSyncInput{
            sourceRef = {
                name = secret.sourceRef.name
                namespace = secret.sourceRef.namespace
            }
            destRef = {
                name = secret.destRef.name
                namespace = secret.destRef.namespace
            }
            providerConfigName = oxr.spec.parameters.id
        } for secret in oxr.spec.parameters.secretSync])


items = _items
