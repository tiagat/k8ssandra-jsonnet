{

  datacenter(dc):: {
    metadata: {
      name: dc,
    },
    size: 3,
    config: {
      cassandraYaml: {
        concurrent_compactors: 6,
        num_tokens: 16,
      },
    },
    resources: {
      limits: {
        cpu: '2',
        memory: '8Gi',
      },
      requests: {
        cpu: '1',
        memory: '4Gi',
      },
    },
    tolerations: [
      {
        effect: 'NoSchedule',
        key: 'k8ssandra',
        value: 'k8ssandra',
      },
    ],
    racks: [
      { name: 'default' },
    ],
    storageConfig: {
      cassandraDataVolumeClaimSpec: {
        accessModes: ['ReadWriteOnce'],
        resources: {
          requests: {
            storage: '300Gi',
          },
        },
      },
    },
  },

  cluster(ns, cluster):: {
    apiVersion: 'k8ssandra.io/v1alpha1',
    kind: 'K8ssandraCluster',
    metadata: {
      name: 'k8ssandra-' + cluster,
      namespace: ns,
    },
    spec: {
      cassandra: {
        serverVersion: '4.0.11',
        telemetry: {
          prometheus: {
            enabled: true,
          },
        },
        datacenters: [],
      },
    },
  },
}
