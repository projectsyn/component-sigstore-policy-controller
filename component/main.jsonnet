local com = import 'lib/commodore.libjsonnet';
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';

local prometheus = import 'lib/prometheus.libsonnet';

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

local aggregated_rbac =
  kube.ClusterRole('syn:sigstore-policy-controller:cluster-reader') {
    metadata+: {
      labels+: {
        'rbac.authorization.k8s.io/aggregate-to-cluster-reader': 'true',
      },
    },
    rules: [
      {
        apiGroups: [ 'policy.sigstore.dev' ],
        resources: [ '*' ],
        verbs: [ 'get', 'list', 'watch' ],
      },
    ],
  };

local namespace =
  local ns = kube.Namespace(params.namespace) {
    metadata+: {
      labels+: {
        // Scrape metrics through cluster-monitoring stack on OCP4
        'openshift.io/cluster-monitoring': 'true',
      },
    },
  };
  if std.member(inv.applications, 'prometheus') then
    prometheus.RegisterNamespace(ns)
  else
    ns;

{
  '00_namespace': namespace,
  '02_aggregated_rbac': aggregated_rbac,
  [if std.length(policies) > 0 then '10_clusterpolicies']: policies,
}
