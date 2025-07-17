local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.sigstore_policy_controller;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('sigstore-policy-controller', params.namespace) {
  metadata+: {
    // NOTE(sg): we need to add the post-delete argocd finalizers here since
    // the application-controller injects them when it sees any post-delete
    // Helm hooks.
    finalizers+: [
      'post-delete-finalizer.argocd.argoproj.io',
      'post-delete-finalizer.argocd.argoproj.io/cleanup',
    ],
  },
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

local appPath =
  local project = std.get(std.get(app, 'spec', {}), 'project', 'syn');
  if project == 'syn' then 'apps' else 'apps-%s' % project;

{
  ['%s/sigstore-policy-controller' % appPath]: app,
}
