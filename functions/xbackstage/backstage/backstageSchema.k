schema Backstage:
    r"""
    Backstage represents an Input for an Backstage Deployment.

    Attributes
    ----------
    name : str, required
        The Name for the Backstage Deployment.
    id : str, required
        The id of this resources that other objects will use to refer to it.
    config : any, default is Undefined, optional
        Free-form configuration object for Backstage (e.g. app-config.yaml), allowing arbitrary nested fields.
    image : any, default is Undefined, required
        image
    replicas : int, default is Undefined, required
        Number of Backstage pod replicas to run for high availability.
    ingress : Ingress, required
        Configuration for enabling and managing Ingress access to the Backstage service.
    deletionPolicy : str, required
        Specifies the behavior when the resource is deleted.
        Options: 'Delete' (default), 'Orphan'.
    ocds : any, required
        ocds to determine ready conditions for dependsOn resource
    dependsOn : str, required
        Specifies a dependency on another resource. This ensures that the Backstage
        deployment is created only after the specified resource has been successfully provisioned.
    """

    name: str
    id: str
    config?: any
    image: any
    replicas: int
    ingress: Ingress
    deletionPolicy: str
    ocds: any
    dependsOn: str

schema Ingress:
    r"""
    Backstage represents an Input for an Backstage Deployment.

    Attributes
    ----------
    enabled : bool, required
        Specifies if the Ingress is enabled
    clusterIssuer : str, optional
        Specifies the CertManager Cluster Issuer to use for SSL for Ingress
    host : str, required
        Specifies the Host for Ingress
    className : str, optional
        Specifies the ClassName for Ingress
    """
    enabled: bool
    clusterIssuer?: str
    className?: str
    host: str