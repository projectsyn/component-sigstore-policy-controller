local com = import 'lib/commodore.libjsonnet';
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';

local inv = kap.inventory();
local params = inv.parameters.sigstore_policy_controller;

// NOTE(sg): SkipDryRunOnMissingResource isn't required, since the Helm chart
// renders the CRDs, so ArgoCD will know not to do dry-run on first apply.
local ClusterPolicy(name) =
  kube._Object('policy.sigstore.dev/v1beta1', 'ClusterImagePolicy', name);

local policies = com.generateResources(
  params.cluster_policies,
  ClusterPolicy,
);

{
  '00_namespace': kube.Namespace(params.namespace),
  [if std.length(policies) > 0 then '10_clusterpolicies']: policies,
}
