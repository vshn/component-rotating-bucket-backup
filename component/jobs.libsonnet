// main template for rotating-bucket-backup
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.rotating_bucket_backup;

// one for each day in a month
local bucketsPerTarget = 31;

local scriptCM = kube.ConfigMap('rotating-bucket-backup') {
  data: {
    'backup.sh': (importstr 'scripts/backup.sh'),
  },
};

local jobs = std.flattenArrays(std.mapWithIndex(function(jobI, job)
  [
    local bucketName = 'backup-%s-%d' % [ job, i ];
    local jobParams = params.jobs[job];
    assert jobParams.target_bucket_tmpl.type == 'appcat' : 'Currently only buckets with type `appcat` are supported';
    kube._Object('appcat.vshn.io/v1', 'ObjectBucket', bucketName) {
      spec+: {
        parameters: {
          bucketName: bucketName,
          region: jobParams.target_bucket_tmpl.parameters.region,
        },
        writeConnectionSecretToRef: {
          name: bucketName + '-bucket-secret',
        },
      },
    }
    for i in std.range(1, bucketsPerTarget)
  ] + [
    local jobParams = params.jobs[job];
    kube.Secret('%s-source' % job) {
      stringData+: {
        SOURCE_URL: jobParams.source_bucket.url,
        SOURCE_ACCESSKEY: jobParams.source_bucket.accesskey,
        SOURCE_SECRETKEY: jobParams.source_bucket.secretkey,
        SOURCE_BUCKET: jobParams.source_bucket.name,
      },
    },
    kube.CronJob(job) {
      metadata: {
        name: job,
      },
      spec: {
        jobTemplate: {
          spec: {
            backoffLimit: 4,
            template: {
              spec: {
                containers: [
                  {
                    args: [
                      '-c',
                      '/script/backup.sh',
                    ],
                    command: [
                      '/bin/bash',
                    ],
                    envFrom: [
                      {
                        secretRef: {
                          name: '%s-source' % job,
                        },
                      },
                    ] + [
                      {
                        secretRef: {
                          name: 'backup-%s-%d-bucket-secret' % [ job, i ],
                        },
                        prefix: 'BUCKET_%d_' % [ i ],
                      }
                      for i in std.range(1, bucketsPerTarget)
                    ],
                    image: '%(registry)s/%(repository)s:%(tag)s' % params.images.mc,
                    name: 'backup',
                    resources: {},
                    volumeMounts: [
                      {
                        mountPath: '/script',
                        name: 'script',
                      },
                    ],
                  },
                ],
                restartPolicy: 'Never',
                terminationGracePeriodSeconds: 30,
                volumes: [
                  {
                    configMap: {
                      defaultMode: 511,
                      name: scriptCM.metadata.name,
                    },
                    name: 'script',
                  },
                ],
              },
            },
          },
        },
        schedule: '%d %d * * *' % [ (((jobI + 1) * 7) % 60), params.schedule.hour ],
        successfulJobsHistoryLimit: 3,
        failedJobsHistoryLimit: 3,
        suspend: false,
      },
    },
  ], std.objectFields(params.jobs)));


jobs + [ scriptCM ]
