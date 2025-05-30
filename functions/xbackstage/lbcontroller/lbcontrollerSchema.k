schema LBController:
    r"""
     LBController an Input for an AWS Loadbalancer Controller Deployment.

    Attributes
    ----------
    name : str, required
        The Name for the ExternalDNS Deployment.
    providerConfigName : str, required
        The Name of the provider config to reference
    id : str, required
        The id of this resources that other objects will use to refer to it.
    clusterName : str, required
        The Name of the AWS EKS Cluster.
    region : str, required
        The AWS Region for the PodIdentity IAM Resources.
    ocds : any, required
        The kcl ocds
    deletionPolicy : str, required
        Specifies the behavior when the resource is deleted.
        Options: 'Delete' (default), 'Orphan'.
    vpcId : str, required
        The AWS vpcId
    """

    name: str
    providerConfigName: str
    id: str
    clusterName: str
    region: str
    ocds: any
    deletionPolicy: str
    vpcId: str
    dependsOn: str