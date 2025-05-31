schema XEKS:
    r"""
    XEKS represents the configuration input for provisioning an AWS EKS Cluster
    and its associated networking resources using Crossplane.

    Attributes
    ----------
    uid : str, required
        The unique identifier (UID) of the Crossplane Composite Resource (XR).
    providerConfigName : str, required
        The name of the Crossplane ProviderConfig used to provision AWS resources.
        Defaults to 'default'.
    id : str, required
        A unique identifier for this resource, referenced by other dependent resources.
    region : str, required
        The AWS region where the EKS cluster and its supporting infrastructure will be deployed.
    deletionPolicy : str, required
        Defines the behavior when this resource is deleted.
        Valid options:
        - 'Delete' (default): Resources are fully removed.
        - 'Orphan': Resources are left intact but unmanaged.
    subnets : any[], optional
        A list of subnet configurations for the cluster.
        Each subnet should define:
        - Availability zone
        - Type (public/private)
        - CIDR block
    vpcCidrBlock : str, optional
        The CIDR block for the Virtual Private Cloud (VPC) hosting the EKS cluster.
    accessConfig : any, optional
        Configuration for EKS access control:
        - `bootstrapClusterCreatorAdminPermissions` (bool): Whether to bootstrap admin permissions for the cluster creator. Default: True
        - `authenticationMode` (str): Mode for authentication.
        Options: 'CONFIG_MAP', 'API', 'API_AND_CONFIG_MAP'. Default: 'CONFIG_MAP'
    iam : any, optional
        IAM access configuration:
        - `principalArn` (str): ARN of the IAM user or role granted cluster admin access.
    nodes : any, required
        Configuration for the EKS node group:
        - `count` (int): Number of worker nodes (1–100)
        - `instanceType` (str): EC2 instance type for nodes. Default: 't3.small'
    version : any, optional
        Kubernetes version for the EKS cluster.
        Supported versions: "1.27" through "1.31". Default: "1.31"
    """

    uid: str
    providerConfigName: str
    id: str
    region: str
    deletionPolicy: str
    subnets?: any
    vpcCidrBlock?: str
    accessConfig: any
    iam: any
    nodes: any
    version: any