local backupScheduler(ns, cluster, dc, type, schedule) = {
  apiVersion: 'medusa.k8ssandra.io/v1alpha1',
  kind: 'MedusaBackupSchedule',
  metadata: {
    name: 'backup-' + cluster + '-' + dc + '-' + type,
    namespace: ns,
  },
  spec: {
    backupSpec: {
      backupType: type,
      cassandraDatacenter: dc,
    },
    cronSchedule: schedule,
    disabled: false,
  },

};

local purgeTaskTemplete(ns, cluster, dc) = |||
  apiVersion: medusa.k8ssandra.io/v1alpha1
  kind: MedusaTask
  metadata:
    name: purge-backups-%(cluster)s-%(dc)s-timestamp
    namespace: %(ns)s
  spec:
    cassandraDatacenter: %(dc)s
    operation: purge
||| % { ns: ns, cluster: cluster, dc: dc };
local purgeTaskYaml(ns, cluster, dc) = std.strReplace(purgeTaskTemplete(ns, cluster, dc), '\n', '\\n');

local purgeCronJob(ns, cluster, dc, schedule) = {
  apiVersion: 'batch/v1beta1',
  kind: 'CronJob',
  metadata: {
    name: ns + '-' + cluster + '-' + dc + '-purge-backups',
    namespace: 'operators',
  },
  spec: {
    schedule: schedule,
    suspend: false,
    successfulJobsHistoryLimit: 3,
    failedJobsHistoryLimit: 1,
    jobTemplate: {
      spec: {
        template: {
          metadata: {
            name: $.metadata.name,
          },
          spec: {
            serviceAccountName: 'k8ssandra-operator',
            restartPolicy: 'OnFailure',
            containers: [
              {
                name: 'medusa-cronjob',
                image: 'bitnami/kubectl:1.29.3',
                imagePullPolicy: 'IfNotPresent',
                command: [
                  'bin/bash',
                  '-c',
                  'printf "' + purgeTaskYaml(ns, cluster, dc) + '" | sed \"s/timestamp/$(date +%Y%m%d%H%M%S)/g\" | kubectl apply -f -'
                ],
              },
            ],
          },
        },
      },
    },
  },

};

{
  backup:: {
    full(ns, cluster, dc, schedule):: backupScheduler(ns, cluster, dc, 'full', schedule),
    diff(ns, cluster, dc, schedule):: backupScheduler(ns, cluster, dc, 'differential', schedule),
    purge(ns, cluster, dc, schedule):: purgeCronJob(ns, cluster, dc, schedule),
  }
}
