schema IngressNginx:
    r"""
    IngressNginx represents the configuration input for deploying an NGINX Ingress Controller.

    Attributes
    ----------
    name : str, required
        The name assigned to the IngressNginx deployment.
    id : str, required
        A unique identifier for this resource, used by other resources to reference it.
    clusterName : str, required
        The name of the AWS EKS cluster where this IngressNginx deployment will be associated.
        Used to determine the LoadBalancer service name.
    deletionPolicy : str, required
        Defines the behavior when this resource is deleted.
        Valid options:
        - 'Delete' (default): The resource and its configurations are removed.
        - 'Orphan': The resource remains but is no longer managed.
    ocds : any, required
        Object used to evaluate readiness conditions, commonly for orchestration or dependency logic.
    dependsOn : str, required
        Specifies a dependency on another resource. Ensures this IngressNginx deployment is created
        only after the referenced resource has been successfully provisioned.
    """

    name: str
    id: str
    deletionPolicy: str
    clusterName: str
    ocds: any
    dependsOn: str