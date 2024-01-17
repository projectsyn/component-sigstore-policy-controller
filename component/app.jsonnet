local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.sigstore_policy_controller;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('sigstore-policy-controller', params.namespace);

{
  'sigstore-policy-controller': app,
}
