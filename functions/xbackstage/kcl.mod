[package]
name = "xbackstage"
version = "0.0.1"

[dependencies]
models = { path = "./model" }
strategic_merge_patch = "0.1.1"
crossplane = { oci = "oci://xpkg.upbound.io/upbound/kcl-modules_crossplane:1.19.0", tag = "1.19.1", package = "kcl-modules_crossplane", version = "1.19.1" }
