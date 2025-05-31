schema ExternalDNS:
    r"""
    ExternalDNS represents the configuration input for deploying an ExternalDNS service.

    Attributes
    ----------
    name : str, required
        The name assigned to the ExternalDNS deployment.
    clusterName : str, required
        The name of the AWS EKS cluster associated with this deployment.
    providerConfigName : str, required
        The name of the provider configuration to use (e.g., credentials, settings for AWS).
    id : str, required
        A unique identifier for this resource, used by other resources to reference it.
    zoneId : str, required
        The Route53 hosted zone ID where DNS records will be managed.
    region : str, required
        The AWS region in which the EKS cluster and Pod Identity IAM resources are located.
    ocds : any, required
        An object used to determine readiness conditions, typically used in dependency resolution.
    deletionPolicy : str, required
        Defines the behavior when this resource is deleted.
        Valid options:
        - 'Delete' (default): The resource and related configurations are removed.
        - 'Orphan': The resource remains but is no longer managed.
    dependsOn : str, required
        Specifies a dependency on another resource. Ensures that this ExternalDNS deployment
        is created only after the referenced resource has been successfully provisioned.
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