import models.io.upbound.platform.aws.v1alpha1 as awsv1alpha1
import utils

xeks = lambda config: XEKS -> any {
    """
   Creates an AWS EKS Cluster with Network.
   """
    [
        awsv1alpha1.XNetwork {
            metadata: utils._metadata("xnetwork")
            spec: {
                parameters: {
                    deletionPolicy: config.deletionPolicy
                    id: config.id
                    providerConfigName: config.providerConfigName
                    region: config.region
                    subnets: config.subnets
                    vpcCidrBlock: config.vpcCidrBlock
                }
            }
        }

        awsv1alpha1.XEKS {
            metadata: utils._metadata("xeks")
            spec: {
                parameters: {
                    accessConfig: config.accessConfig
                    deletionPolicy: config.deletionPolicy
                    iam: config.iam
                    id: config.id
                    nodes: config.nodes
                    providerConfigName: config.providerConfigName
                    region: config.region
                    version: config.version
                }
                writeConnectionSecretToRef: {
                    name: config.uid
                    namespace: "crossplane-system"
                }
            }
        }
    ]
}
