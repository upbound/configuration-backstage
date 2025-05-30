schema XEKS:
    r"""
    XEKS represents the input specification for provisioning an AWS EKS Cluster
    along with its associated networking resources using Crossplane.

    Attributes
    ----------
    uid : str, required
        The uid of the XR
    providerConfigName : str, required
        The name of the Crossplane ProviderConfig used to provision AWS resources. Defaults to 'default'.
    id : str, required
        A unique identifier for this resource, referenced by other dependent objects.
    region : str, required
        AWS region where the EKS cluster and associated resources should be created.
    deletionPolicy : str, required
        Specifies the behavior when the resource is deleted.
        Options: 'Delete' (default), 'Orphan'.
    subnets : any[], optional
        Network subnets configuration for the cluster. Each subnet should define availability zone,
        type (public/private), and CIDR block.
    vpcCidrBlock : str, optional
        The CIDR block for the VPC in which the EKS cluster will be deployed.
    accessConfig : any, optional
        Configuration for EKS access control.
        - bootstrapClusterCreatorAdminPermissions: bool
            Whether to bootstrap admin permissions for the cluster creator. Default: True.
        - authenticationMode: str
            Authentication mode for the cluster. Options: 'CONFIG_MAP', 'API', 'API_AND_CONFIG_MAP'. Default: 'CONFIG_MAP'.
    iam : any, optional
        IAM configuration for accessing the cluster.
        - principalArn: str
            The ARN of the IAM principal (user/role) granted ClusterAdmin access.
    nodes : any, required
        Configuration for the EKS worker nodes.
        - count: int
            Number of nodes in the Node Group (1–100).
        - instanceType: str
            EC2 instance type used for worker nodes. Default: 't3.small'.
    version : any, optional
        Kubernetes version for the EKS cluster.
        Supported versions: "1.27" to "1.31". Default: "1.31".
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