local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.sigstore_policy_controller;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('sigstore-policy-controller', params.namespace) {
  spec+: {
    ignoreDifferences: [
      {
        group: 'admissionregistration.k8s.io',
        kind: 'MutatingWebhookConfiguration',
        jqPathExpressions: [
          '.webhooks[]?.namespaceSelector.matchExpressions',
        ],
      },
      {
        group: 'admissionregistration.k8s.io',
        kind: 'ValidatingWebhookConfiguration',
        jqPathExpressions: [
          '.webhooks[]?.namespaceSelector.matchExpressions',
        ],
      },
    ],
  },
};

{
  'sigstore-policy-controller': app,
}
