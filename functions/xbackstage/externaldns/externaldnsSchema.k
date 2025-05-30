schema ExternalDNS:
    r"""
    ExternalDNS represents an Input for an ExternalDNS Deployment.

    Attributes
    ----------
    name : str, required
        The Name for the ExternalDNS Deployment.
    clusterName : str, required
        The Name of the AWS EKS Cluster.
    providerConfigName : str, required
        The Name of the provider config to reference
    id : str, required
        The id of this resources that other objects will use to refer to it.
    zoneId : str, required
        The zoneId of the Route53 zone
    region : str, required
        The AWS Region for the PodIdentity IAM Resources.
    ocds : any, required
        The kcl ocds
    deletionPolicy : str, required
        Specifies the behavior when the resource is deleted.
        Options: 'Delete' (default), 'Orphan'.
    """

    name: str
    providerConfigName: str
    id: str
    clusterName: str
    zoneId: str
    region: str
    ocds: any
    deletionPolicy: str
    dependsOn: str