schema IngressNginx:
    r"""
    IngressNginx represents an Input for an IngressNginx Deployment.

    Attributes
    ----------
    name : str, required
        The Name for the IngressNginx Deployment.
    id : str, required
        The id of this resources that other objects will use to refer to it.
    clusterName : str, required
        The Name of the AWS EKS Cluster to use for LoadBalancer Service Name.
    deletionPolicy : str, required
        Specifies the behavior when the resource is deleted.
        Options: 'Delete' (default), 'Orphan'.
    """

    name: str
    id: str
    deletionPolicy: str
    clusterName: str
    ocds: any
    dependsOn: str