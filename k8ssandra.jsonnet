local k8ssandra = import 'templates/k8ssandra.libsonnet';
local medusa = import 'templates/medusa.libsonnet';

local cassandraNamespace = 'k8ssandra';
local cassandraName = 'warehouse';
local cassandraDatacenter = 'main';

local kubernetesCluster = "dev.example.com";
local kubernetesRegion = "eu-west-1";

{
  "manifest-backup-full.json": medusa.backup.full(cassandraNamespace, cassandraName, cassandraDatacenter, '0 0 * * *'),
  "manifest-backup-diff.json": medusa.backup.diff(cassandraNamespace, cassandraName, cassandraDatacenter, '0 * * * *'),
  "manifest-backup-purge.json": medusa.backup.purge(cassandraNamespace, cassandraName, cassandraDatacenter, '0 0 * * *'),
  "manifest-cassandra.json": k8ssandra.cluster(cassandraNamespace, cassandraName) {
    spec+: {
      medusa: {
        storageProperties: {
          storageProvider: 's3',
          storageSecretRef: {
            name: 'cassandra-backup-access-secret',
          },
          bucketName: 'cassandra-backup-' + kubernetesCluster,
          region: kubernetesRegion,
          prefix: cassandraNamespace + '-' + cassandraName + '-' + cassandraDatacenter,
          maxBackupCount: 0,
          maxBackupAge: 14,
        },
      },
    },
  }
}
