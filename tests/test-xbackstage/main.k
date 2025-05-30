import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.platform.aws.v1alpha1 as platformawsv1alpha1
import models.io.upbound.aws.eks.v1beta2 as eksv1beta2

import resources
import conditions

_spec = metav1alpha1.CompositionTest {
    spec = {
        compositionPath: "apis/xbackstages/composition.yaml"
        xrPath: "examples/xbackstage/example.yaml"
        xrdPath: "apis/xbackstages/definition.yaml"
        timeoutSeconds: 60
        validate: False
    }
}

_test1 = metav1alpha1.CompositionTest {
    metadata.name: "create-xeks"
    **_spec
    spec.assertResources: [
        resources._xeks
        resources._xnetwork
    ]
}

_test2 = metav1alpha1.CompositionTest {
    metadata.name: "lb-create"
    **_spec
    spec.observedResources: [
         platformawsv1alpha1.XEKS{
            **resources._xeks
            status: {
                conditions: conditions._readyConditions
            }
        }
        platformawsv1alpha1.XNetwork{
            **resources._xnetwork
            status: {
                vpcId: "test123"
                conditions: conditions._readyConditions
            }
        }
    ]
    spec.extraResources: [
         eksv1beta2.Cluster{
            metadata: {
                name: "uptest"
                labels: {
                    "crossplane.io/composite": "solution-idp"
                }
            }
            spec: {
                forProvider: {
                    region: "test"
                }
            }
        }
    ]
    spec.assertResources: _test1.spec.assertResources + [
        resources._lbcontoller
    ]
}

_test3 = metav1alpha1.CompositionTest {
    metadata.name: "certmanager-create"
    **_spec
    spec.observedResources: _test2.spec.observedResources + [
        helmv1beta1.Release {
            **resources._lbcontoller
            status: {
                conditions: conditions._readyConditions
                atProvider: {
                    state: "deployed"
                }
            }
        }
    ]
    spec.extraResources: _test2.spec.extraResources
    spec.assertResources: _test2.spec.assertResources + [
        resources._certmanager
    ]
}

_test4: metav1alpha1.CompositionTest {
    metadata.name: "ingress-create"
    **_spec
    spec.observedResources: _test3.spec.observedResources + [
        helmv1beta1.Release {
            **resources._certmanager
            status: {
                conditions: conditions._readyConditions
                atProvider: {
                    state: "deployed"
                }
            }
        }
    ]
    spec.extraResources: _test3.spec.extraResources
    spec.assertResources: _test3.spec.assertResources + [
        resources._ingress
    ]
}

_test5: metav1alpha1.CompositionTest {
    metadata.name: "externaldns-create"
    **_spec
    spec.observedResources: _test4.spec.observedResources + [
        helmv1beta1.Release {
            **resources._ingress
            status: {
                conditions: conditions._readyConditions
                atProvider: {
                    state: "deployed"
                }
            }
        }
    ]
    spec.extraResources: _test4.spec.extraResources
    spec.assertResources: _test4.spec.assertResources + [
        resources._externaldns
    ]
}

_test6: metav1alpha1.CompositionTest {
    metadata.name: "externaldns-create"
    **_spec
    spec.observedResources: _test5.spec.observedResources + [
        helmv1beta1.Release {
            **resources._externaldns
            status: {
                conditions: conditions._readyConditions
                atProvider: {
                    state: "deployed"
                }
            }
        }
    ]
    spec.extraResources: _test5.spec.extraResources
    spec.assertResources: _test5.spec.assertResources + [
        resources._backstage
    ]
}

items = [_test1, _test2, _test3, _test4, _test5, _test6]
