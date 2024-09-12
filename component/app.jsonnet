local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.rotating_bucket_backup;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('rotating-bucket-backup', params.namespace);

{
  'rotating-bucket-backup': app,
}
