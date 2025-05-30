schema CertManager:
    r"""
    CertManager represents an Input for an CertManager Deployment.

    Attributes
    ----------
    name : str, required
        The Name for the Cert Manager Deployment.
    id : str, required
        The id of this resources that other objects will use to refer to it.
    deletionPolicy : str, required
        Specifies the behavior when the resource is deleted.
        Options: 'Delete' (default), 'Orphan'.
    """

    name: str
    id: str
    deletionPolicy: str
    ocds: any
    dependsOn: str