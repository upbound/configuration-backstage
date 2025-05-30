schema LBController:
    r"""
    LBController represents the configuration input for deploying the AWS Load Balancer Controller.

    Attributes
    ----------
    name : str, required
        The name assigned to the Load Balancer Controller deployment.
    providerConfigName : str, required
        The name of the provider configuration to reference (e.g., IAM roles, credentials).
    id : str, required
        A unique identifier for this resource, used by other resources to reference it.
    clusterName : str, required
        The name of the AWS EKS cluster where the controller will be deployed.
    region : str, required
        The AWS region where the EKS cluster and IAM resources are located.
    vpcId : str, required
        The ID of the AWS VPC associated with the EKS cluster and load balancers.
    ocds : any, required
        Object used to determine readiness conditions, typically for orchestration and dependencies.
    deletionPolicy : str, required
        Defines the behavior when this resource is deleted.
        Valid options:
        - 'Delete' (default): The resource and associated infrastructure are removed.
        - 'Orphan': The resource is left intact but unmanaged.
    dependsOn : str, required
        Specifies a dependency on another resource. Ensures this Load Balancer Controller deployment
        occurs only after the specified resource has been successfully provisioned.
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