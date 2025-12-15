# 5. Storage (10%)

#### [YouTube video link](https://www.youtube.com/watch?v=vfGzKQDKPWc)

Welcome back, Kubernetes learners! This session explores one of the most real world used CKA domains: **Storage**. Kubernetes storage for the CKA comes down to three core building blocks you must be fast and fluent with in the exam: StorageClasses for dynamic provisioning, PersistentVolumes (PV) plus PersistentVolumeClaims (PVC), and how these connect into Pods via volumes and volumeMounts. This section gives you short explanations plus hands on labs you can run on any cluster, with homework at the end to lock in the skills.

We will use this [playground](https://killercoda.com/playgrounds/scenario/kubernetes) throughout this session.

## Learning objectives

By the end of this section you should be able to:

- Create and inspect StorageClasses and explain how dynamic provisioning works in Kubernetes.
- Configure PVs and PVCs with the correct access modes and reclaim policies.
- Mount a PVC into a Pod or Deployment and verify data persists across Pod restarts.

Use the official docs alongside your terminal while you practice:

- StorageClasses: https://kubernetes.io/docs/concepts/storage/storage-classes/
- Dynamic provisioning: https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/
- PersistentVolumes and PVCs: https://kubernetes.io/docs/concepts/storage/persistent-volumes/

***

## 1. StorageClasses and dynamic provisioning

StorageClasses describe “profiles” of storage in your cluster and are the foundation of dynamic provisioning.  A cluster admin defines one or more StorageClass objects, and user PVCs that reference those classes can trigger on demand volume creation through a provisioner such as a CSI driver.

Here is a minimal StorageClass manifest in Markdown you can adapt:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard-retain
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Retain
parameters: {}
```

Key fields to understand for the exam:

- `provisioner`: The plugin that actually creates storage volumes, such as a CSI driver or the `kubernetes.io/no-provisioner` example often used for local PVs.
- `reclaimPolicy`: What happens to the underlying volume when the PVC is deleted, usually `Delete` or `Retain`.
- `volumeBindingMode`: `Immediate` or `WaitForFirstConsumer`, which controls when binding and provisioning happen relative to Pod scheduling.

Hands on exercise (StorageClass):

1. Create the StorageClass above and then list it:

```bash
kubectl apply -f storageclass-standard-retain.yaml
kubectl get storageclass
kubectl describe storageclass standard-retain
```

2. Identify which StorageClass is marked as default in your cluster by looking for `(default)` in `kubectl get sc`.

3. Change the `reclaimPolicy` to `Delete` and re apply, then confirm the change with `kubectl describe sc`.

While practicing, keep the official StorageClass doc open: https://kubernetes.io/docs/concepts/storage/storage-classes/

***

## 2. PersistentVolumes, access modes and reclaim policies

PersistentVolumes are cluster scoped resources that represent actual pieces of storage with a defined capacity, access modes, volume mode and reclaim policy.  They decouple the underlying storage implementation from how workloads request and use that storage.

Typical exam friendly fields you should be comfortable editing under pressure:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-hostpath-1
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard-retain
  hostPath:
    path: /mnt/data/pv1
```

Important concepts:

- Access modes:
    - `ReadWriteOnce` (RWO) volume can be mounted as read write by a single node.
    - `ReadOnlyMany` (ROX) volume can be mounted read only by many nodes.
    - `ReadWriteMany` (RWX) volume can be mounted read write by many nodes.
- Reclaim policies:
    - `Retain`: PV is not automatically cleaned up after PVC deletion, manual admin cleanup is required.
    - `Delete`: PV and underlying storage are deleted when the PVC is deleted, depending on the provisioner.

Hands on exercise (PV basics):

1. Create the HostPath PV above in a local lab cluster and check its phase:

```bash
kubectl apply -f pv-hostpath-1.yaml
kubectl get pv
kubectl describe pv pv-hostpath-1
```

2. Note the `Status` field, which should show `Available` until a PVC is bound.
3. Change `accessModes` to `ReadOnlyMany`, apply again, and see how the PV’s spec updates.

For details on PV phases, reclaim policies and access modes refer to: https://kubernetes.io/docs/concepts/storage/persistent-volumes/

***

## 3. PersistentVolumeClaims and volume binding

PersistentVolumeClaims are how users and applications request storage in terms of size, access mode, and StorageClass.  Once a matching PV is found (or dynamically provisioned via a StorageClass), the control plane binds the PVC to that PV and keeps the relationship until the claim is released.

A PVC that explicitly targets the StorageClass created earlier looks like this:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-standard-1gi
spec:
  storageClassName: standard-retain
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

A few CKA relevant behaviors:

- If `storageClassName` is omitted, the cluster may automatically use the default StorageClass, depending on the admission controller configuration.
- A PVC can target a specific PV by setting `spec.volumeName`, which bypasses normal matching.
- Claims remain unbound if no suitable PV exists, and they bind automatically once an appropriate PV is created.

Hands on exercise (binding PV and PVC):

1. Create the PVC above and then inspect binding:

```bash
kubectl apply -f pvc-standard-1gi.yaml
kubectl get pvc
kubectl describe pvc pvc-standard-1gi
kubectl get pv
```

2. Confirm the PVC is `Bound` and that the `pv-hostpath-1` resource has changed from `Available` to `Bound`.

3. Delete the PVC and then inspect the PV status and behavior based on the `persistentVolumeReclaimPolicy` you configured.

While you run this, keep the PV and PVC docs open: https://kubernetes.io/docs/concepts/storage/persistent-volumes/

***

## 4. Using PVCs in Pods and Deployments

Once a PVC is bound you use it from Pods by defining a volume that references the claim, then mounting that volume into containers with `volumeMounts`.  This is exactly what the CKA exam expects you to do quickly under time pressure, often combining it with Deployments.

Example Pod that mounts the PVC at `/data`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pv-test
spec:
  containers:
    - name: busybox
      image: busybox:1.36
      command: ["sh", "-c", "echo 'Hello from PV' >> /data/out.txt && sleep 3600"]
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: pvc-standard-1gi
```

Attach a shell and verify the data:

```bash
kubectl apply -f pod-busybox-pv-test.yaml
kubectl exec -it busybox-pv-test -- sh -c "cat /data/out.txt"
```

Now verify persistence across Pod deletion:

1. Delete the Pod, keep the PVC:

```bash
kubectl delete pod busybox-pv-test
```

2. Recreate the Pod with the same PVC and check `out.txt` again. The content should still be present because the data is on the PV, not tied to the Pod lifecycle.

Reference: “Using PersistentVolumeClaims as volumes” section in the PV doc: https://kubernetes.io/docs/concepts/storage/persistent-volumes/\#claims-as-volumes

***

## 5. Typical CKA scenarios and gotchas

Here are patterns that frequently appear in CKA style tasks, along with behaviors you should be ready to troubleshoot quickly.

### Common exam style tasks

- Create a PVC of a specific size and StorageClass, then update a Pod or Deployment manifest to mount it at a given path.
- Change the `reclaimPolicy` of an existing PV from `Delete` to `Retain` to preserve data after a PVC is removed.
- Inspect why a PVC is stuck in `Pending` state by comparing requested size, access modes, and StorageClass against existing PV definitions.


### Typical mistakes to avoid

- PVC stuck in `Pending` because the StorageClass name is wrong or does not exist, or no PV matches the requested size or access mode.
- Accidentally using the default StorageClass leading to dynamic provisioning on the wrong backend, especially if the exam task expects a static PV binding.
- Forgetting to update both `volumes` and `volumeMounts` when wiring PVCs into a Pod spec, which results in containers failing to start.

Spend a few minutes reading the troubleshooting portions of the PV and dynamic provisioning docs so you can recognize these patterns quickly:

- PV troubleshooting and phases: https://kubernetes.io/docs/concepts/storage/persistent-volumes/\#phase
- Dynamic provisioning behavior: https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/

***

## 6. Hands on mini lab: app with persistent storage

In this mini lab we wire everything together: StorageClass, PVC, and a simple application that keeps its data across Pod restarts.

1. StorageClass and PVC:
```yaml
# storageclass-fast-delete.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-delete
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
---
# pv-fast-local.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-fast-local
spec:
  capacity:
    storage: 2Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: fast-delete
  hostPath:
    path: /mnt/fast
---
# pvc-fast-local.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-fast-local
spec:
  storageClassName: fast-delete
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

2. Simple Deployment that writes into the volume:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-persistent
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-persistent
  template:
    metadata:
      labels:
        app: nginx-persistent
    spec:
      containers:
        - name: nginx
          image: nginx:1.27
          volumeMounts:
            - name: web-data
              mountPath: /usr/share/nginx/html
          ports:
            - containerPort: 80
      volumes:
        - name: web-data
          persistentVolumeClaim:
            claimName: pvc-fast-local
```

3. Deploy and verify persistence:
```bash
kubectl apply -f storageclass-fast-delete.yaml
kubectl apply -f pv-fast-local.yaml
kubectl apply -f pvc-fast-local.yaml
kubectl apply -f nginx-persistent.yaml

# Find Pod name
kubectl get pods -l app=nginx-persistent

# Exec into the Pod and write an index file
POD=$(kubectl get pod -l app=nginx-persistent -o jsonpath='{.items[0].metadata.name}')
echo $POD
kubectl exec -it "$POD" -- sh -c 'echo "CKA Storage Lab $HOSTNAME" > /usr/share/nginx/html/index.html'
kubectl exec -it "$POD" -- sh -c 'curl localhost'

# Restart Pod by deleting it (Deployment recreates it)
kubectl delete pod "$POD"

# After new Pod is running
NEW_POD=$(kubectl get pod -l app=nginx-persistent -o jsonpath='{.items[0].metadata.name}')
echo $NEW_POD
kubectl exec -it "$NEW_POD" -- sh -c 'echo "CKA Storage Lab $HOSTNAME" >> /usr/share/nginx/html/index.html'
kubectl exec -it "$NEW_POD" -- sh -c 'curl localhost'
```

If the output still shows `CKA Storage Lab` and name of 2 PODs (old pod and new pod in 2nd line), you have successfully persisted application data using a PVC backed by a PV that matches the StorageClass.


## 7. emptyDir memory configuration example
For a Pod that defines an `emptyDir volume`, the volume is created when the Pod is assigned to a node. As the name says, the `emptyDir` volume is initially empty. All containers in the Pod can read and write the same files in the `emptyDir` volume, though that volume can be mounted at the same or different paths in each container. When a Pod is removed from a node for any reason, the data in the `emptyDir` is deleted permanently.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: registry.k8s.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir:
      sizeLimit: 500Mi
      medium: Memory
```

## 8. configMap example
A [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) provides a way to inject configuration data into pods. The data stored in a `ConfigMap` can be referenced in a volume of type configMap and then consumed by containerized applications running in a pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
spec:
  containers:
    - name: test
      image: busybox:1.28
      command: ['sh', '-c', 'echo "The app is running!" && tail -f /dev/null']
      volumeMounts:
        - name: config-vol
          mountPath: /etc/config
  volumes:
    - name: config-vol
      configMap:
        name: log-config
        items:
          - key: log_level
            path: log_level.conf
```

## 9. hostPath example
A `hostPath` volume mounts a file or directory from the host node's filesystem into your Pod. This is not something that most Pods will need, but it offers a powerful escape hatch for some applications. 

!!! Warning:!!!
Using the `hostPath` volume type presents many security risks. If you can avoid using a `hostPath` volume, you should. For example, define a local `PersistentVolume`, and use that instead.

```yaml
# This manifest mounts /data/foo on the host as /foo inside the
# single container that runs within the hostpath-example-linux Pod.
#
# The mount into the container is read-only.
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-example-linux
spec:
  os: { name: linux }
  nodeSelector:
    kubernetes.io/os: linux
  containers:
  - name: example-container
    image: registry.k8s.io/test-webserver
    volumeMounts:
    - mountPath: /foo
      name: example-volume
      readOnly: true
  volumes:
  - name: example-volume
    # mount /data/foo, but only if that directory already exists
    hostPath:
      path: /data/foo # directory location on host
      type: Directory # this field is optional
```
## 10. secret example

A [secret](https://kubernetes.io/docs/concepts/configuration/secret/) volume is used to pass sensitive information, such as passwords, to Pods. You can store secrets in the Kubernetes API and mount them as files for use by pods without coupling to Kubernetes directly. `secret` volumes are backed by tmpfs (a RAM-backed filesystem) so they are never written to non-volatile storage.

```yaml

apiVersion: v1
kind: Pod
metadata:
  name: secret-dotfiles-pod
spec:
  volumes:
    - name: secret-volume
      secret:
        secretName: dotfile-secret
  containers:
    - name: dotfile-test-container
      image: registry.k8s.io/busybox
      command:
        - ls
        - "-l"
        - "/etc/secret-volume"
      volumeMounts:
        - name: secret-volume
          readOnly: true
          mountPath: "/etc/secret-volume"
```

***

## Homework for learners

I encourage you to treat this like exam style drills. Ask them to time themselves and avoid copy paste as much as possible.

Homework ideas:

1. **Static vs dynamic provisioning**
    - Create a StorageClass that uses `volumeBindingMode: Immediate` and another that uses `WaitForFirstConsumer`.
    - Create PVCs for both classes and schedule Pods that reference them on a multi node cluster, then compare when the PV is bound in each case.
2. **Reclaim policies in practice**
    - Create a PV with `Retain` reclaim policy and a PVC that binds to it.
    - Write data to the volume from a Pod, then delete the PVC and inspect the PV status and underlying data directory on the node.
    - Manually clean up the PV and underlying path, then reuse it for a new PVC.
3. **Access modes and scheduling**
    - Simulate a scenario where a PV is created with `ReadWriteOnce` but you try to mount it from two Pods on different nodes.
    - Observe how scheduling behaves and note what changes you would need to support multi node read write patterns (for example, using a backend that supports `ReadWriteMany`).
4. **Exam style YAML editing drill**
    - Start with a basic Deployment manifest from your repo that does not use storage yet (for example one of your earlier workload examples).
    - Within 5 minutes, modify it to:
        - Create a PVC of 2Gi using the default StorageClass.
        - Mount the PVC at `/data` in the container.
        - Validate persistence by writing a file and recycling the Pod.

For each homework task, you should keep the relevant official doc page open, but type all YAML and commands by hand to build muscle memory:

- StorageClasses: https://kubernetes.io/docs/concepts/storage/storage-classes/
- Dynamic provisioning: https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/
- PersistentVolumes and PVCs: https://kubernetes.io/docs/concepts/storage/persistent-volumes/
