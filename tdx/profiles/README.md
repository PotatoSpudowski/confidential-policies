# GKE C3 / COS TDX reference profile

`gke-c3-cos.json` is an opt-in node-level PoC profile captured from a C3 Intel
TDX Confidential GKE node running COS_CONTAINERD / GKE 1.35.6-gke.1250000 on
October 2, 2026, with the owner reference refreshed on October 7 after the
development node was recreated on October 5. Authenticated cloud inventory
confirmed the replacement C3/TDX instance, and a fresh quote matched the original
firmware, TDX module, RTMRs and security-version values. Only the exact owner
reference changed. The live broker must still verify signatures, freshness and
policy before release. It pins firmware/boot measurements, owner, attributes and the
TDX module. A different node image or boot configuration must be revalidated;
this is not a wildcard for all Google Cloud nodes.

Set Reticle’s policy-provider base URL to
`https://policies.prem.io/gke-c3-cos/` to select `gke-c3-cos/policies.json`.
`UrlPolicies` always fetches `policies.json` relative to that base URL; its
absolute policy/data paths still resolve to the shared files on the same host.
Reticle's bundle loader supports the `data` list; the existing TDX policy merges
`reference_values.tdx` over its inline baseline. The default bundle and policy
are unchanged, so Azure and other existing consumers retain their behavior.

The captured MRSEAM is exactly Intel's published **TDX Module 1.5.34** hash,
with minor SVN 0x0f and major SVN 0x01. The existing inline baseline uses the
2.0-series major SVN 0x03. A component-wise comparison with that baseline would
reject this 1.5-series platform even though hardware/collateral verification
passes. This profile uses `[15,1,10,...]` and pins the corresponding module hash;
it does not lower a global minimum or accept an arbitrary module.

Sources:
- [Intel 1.5.34 release and MRSEAM](https://github.com/intel/confidential-computing.tdx.tdx-module/releases/tag/TDX_MODULE_1.5.34)
- [Intel quoting library: TEE_TCB_SVN layout](https://download.01.org/intel-sgx/sgx-dcap/1.18/linux/docs/Intel_TDX_DCAP_Quoting_Library_API.pdf)

Reticle must authenticate signatures, fresh report data and collateral/TCB status
before evaluating this policy. OPA only evaluates the verified body; accepting
a JSON fixture alone is not attestation. The tests zero the report data and
contain no raw quote, nonce, credentials or project/account identifiers.

This node-level profile assumes trusted node/Kubernetes administrators. It does
not identify the router container or protect it from those administrators. The
ZDR PRD's public router-image verification remains Phase 2. The GKE integration
uses bound delivery separately; this file alone is not a KBS.

Run the tests with OPA 1.x:

```sh
opa check .
opa test tdx/policy.rego tdx/profiles/gke-c3-cos.json tests -v
```
