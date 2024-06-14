# Manifests Generator for Medusa Backups (K8ssandra Operator)


**Requirements:**

```
$ brew install jsonnet
$ brew install yq
```


**Generate manifests:**
```
$ jsonnet -m ./ k8ssandra.jsonnet
```

**Convert JSON to YAML**

```
$ cat manifest-backup-diff.json | yq -P > manifest-backup-diff.yaml
$ cat manifest-backup-full.json | yq -P > manifest-backup-full.yaml
$ cat manifest-backup-purge.json | yq -P > manifest-backup-purge.yaml
$ cat manifest-cassandra.json | yq -P > manifest-cassandra.yaml
```
