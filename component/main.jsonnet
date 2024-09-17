// main template for rotating-bucket-backup
local com = import 'lib/commodore.libjsonnet';
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.rotating_bucket_backup;

local alertlabels = {
  syn: 'true',
  syn_component: 'rotating-bucket-backup',
};

local alerts = params.monitoring.alerts;
local prometheusRule =
  kube._Object('monitoring.coreos.com/v1', 'PrometheusRule', 'rotating-bucket-backup-alerts') {
    metadata+: {
      namespace: params.namespace,
    },
    spec+: {
      groups+: [
        {
          name: 'rotating-bucket-backup-alerts',
          rules:
            std.filterMap(
              function(field) alerts[field].enabled == true,
              function(field) alerts[field].rule {
                alert: field,
                labels+: alertlabels,
              },
              std.sort(std.objectFields(alerts)),
            ),
        },
      ],
    },
  };

// Define outputs below
{
  '00_namespace': kube.Namespace(params.namespace) {
    metadata+: com.makeMergeable(params.namespace_metadata),
  },
  '10_jobs': (import 'jobs.libsonnet'),
  [if params.monitoring.enabled then '20_prometheus_rule']: prometheusRule,
}
