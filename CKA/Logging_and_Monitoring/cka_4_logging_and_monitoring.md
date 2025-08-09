# 4. Logging & Monitoring (10%)

>##### 💡TIP💡: Focus on Kubernetes native commands and workflows (kubectl, Metrics Server) for the Certified Kubernetes Administrator (CKA) exam. Third-party tools (e.g. Prometheus, Grafana, Fluentd, and Elasticsearch) are not explicitly listed as required topics or tools in the official CKA exam syllabus.

- The CKA exam covers monitoring cluster components and application logs/troubleshooting as part of the "Logging & Monitoring" and "Troubleshooting" domains, but it does not mandate proficiency in particular third-party monitoring or logging tools like Prometheus, Grafana, Fluentd, or Elasticsearch

- The exam expects knowledge of collecting metrics and logs, understanding concepts, and troubleshooting issues—not necessarily hands-on with specific monitoring stacks.

---

[YouTube Video](TBD)

---

### 1. **Cluster Logging Concepts**

- **Understanding cluster logging:**
  - Kubernetes splits logs into *system logs* (for cluster components), *node logs*, and *pod/container logs*.
  - System components use `klog` (library), node logs are in `/var/log`, and pod logs are in `/var/log/containers`.
  - Kubernetes does not provide cluster-level centralized logging out of the box; typically, logs are stored locally and accessed via native commands.
- **Accessing logs:**
  - Use `kubectl logs <pod>` for container stdout/stderr.
  - `kubectl logs <pod> -c <container>` for multi-container pods.
  - `kubectl logs --previous <pod>` for crashed containers. If true, print the logs for the previous instance of the container in a pod if it exists.
  - Describe node or pod events: `kubectl describe node <node>`, `kubectl describe pod <pod>`.

#### 🪢 Hands-on Practice

```bash
# Create a pod named "test" with image "nginx"
kubectl run test --image nginx
```

```bash
# List pods and find the worker node running this container
kubectl get pods -o wide
```

```bash
# View logs for a pod
kubectl logs <pod-name>
```

```bash
# View logs for a container inside a pod
kubectl logs <pod-name> -c <container-name>
```

```bash
# View logs of a previously terminated container in a pod
# --previous # If true, print the logs for the previous instance of the container in a pod if it exists.
kubectl logs --previous <pod-name>
```

```bash
# find UID of the container
kubectl get pod test -o custom-columns='POD_NAME:.metadata.name,NAMESPACE:.metadata.namespace,POD_UID:.metadata.uid,CONTAINER_NAME:.spec.containers[0].name'

##### example output#####
# POD_NAME   NAMESPACE   POD_UID                                CONTAINER_NAME
# test       default     0d8aa448-f130-4c1e-bfea-f219bb9214ec   test
```

```bash
# login to the worker node using ssh. In our setup you can use "multipass shell" command
ssh <worker-node-name>
multipass shell <worker-node-name>
```

```bash
# On the worker node, find container and look for logs
export POD_UID='0d8aa448-f130-4c1e-bfea-f219bb9214ec'
export NAMESPACE='default'
export POD_NAME='test'
export CONTAINER_NAME='test'
sudo crictl ps |egrep "^CONTAINER|$POD_NAME"
sudo crictl logs `sudo crictl ps |grep -i $POD_NAME|awk '{print $1}'`
```

```bash
# Look for container logs
# logs are stored in /var/log/pods/ but you can find them in /var/log/containers/ too
sudo ls -l /var/log/containers/|grep $POD_UID
# example output would be in format "/var/log/pods/<NAMESPACE>>_<POD_NAME>_<POD_UID>/<CONTAINER_NAME>/0.log"
# e.g.
# /var/log/pods/default_test_0d8aa448-f130-4c1e-bfea-f219bb9214ec/test/0.log
```

```bash
# you can use cat or tail commands to view the contents of log file
# e.g.
sudo tail `sudo ls -l /var/log/containers/|grep $POD_UID|awk '{print $NF}'`
# OR you can construct it with variables like this
sudo tail /var/log/pods/${NAMESPACE}_${POD_NAME}_${POD_UID}/${CONTAINER_NAME}/0.log
```

### 2. **Monitoring Cluster Components**

- **Metrics Server:**
  - *Heapster* was deprecated; the *Metrics Server* is now the expected solution for basic resource monitoring.
  - Metrics Server aggregates resource usage metrics (CPU, memory) for nodes and pods, available via `kubectl top node` and `kubectl top pod`.
- **Built-in monitoring commands:**
  - `kubectl top node` — view node metrics.
  - `kubectl top pod` — view pod metrics.
  - `kubectl cluster-info` — shows cluster state information.

#### 🪢 Hands-on Practice

```bash
# Install Metrics Server (example for generic K8s cluster)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

**💡TIP💡** Since we are running deployment in local setup, we will have to patch the deployment to allow metrics server to run without certificate validation errors. **FOR TESTING ONLY, NOT RECOMMENDED FOR PRODUCTIONS**

```bash
kubectl -n kube-system patch deployment metrics-server --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--kubelet-insecure-tls"
  }
]'

# let's wait for metrics-server container to be in Ready state
kubectl wait --for=condition=Ready pod -l k8s-app=metrics-server --namespace=kube-system --timeout=120s
```

View "NODE" resource usage and check different options e.g. sort by memory or cpu.

```bash
kubectl top nodes
kubectl top pods
kubectl top node --sort-by memory
kubectl top node --sort-by cpu
```

View "POD" resource usage and check different options e.g. sort by memory or cpu.

```bash
kubectl top pods
kubectl top pods -A #show usage across all namespaces
kubectl top pods --sort-by memory
kubectl top pods -A --sort-by memory #show usage across all namespaces
kubectl top pods --sort-by cpu
kubectl top pods -A --sort-by cpu #show usage across all namespaces
```

***

### 3. **Application Logs and Troubleshooting**

- **Logging for debugging:**
  - To troubleshoot applications, use `kubectl logs` to view application logs, and `kubectl describe pod` to inspect events/reasons for failures.
  - For crash issues, check previous logs with `kubectl logs --previous <pod>`.
  - Streaming logs in real-time: `kubectl logs -f <pod>`.
- **General troubleshooting workflow:**
  - Get pod and node status:
`kubectl get pods -o wide`, `kubectl get nodes`.
  - Check detailed pod info and recent events:
`kubectl describe pod <pod>`.
  - Investigate common errors: CrashLoopBackOff, OOMKilled, failed scheduling.

#### 🪢 Hands-on Practice

```bash
# Check pod status and details
kubectl get pods -o wide
kubectl describe pod <pod-name>

# Stream logs for live debugging
kubectl logs -f <pod-name>
```

## Cluster Logging Concepts

- Kubernetes stores logs for containers, pods, nodes, and system components.
- Use `kubectl logs <pod>`, `kubectl logs <pod> -c <container>`, and `kubectl logs --previous <pod>` to access container logs. # --previous # If true, print the logs for the previous instance of the container in a pod if it exists.
- System logs are found under `/var/log` on nodes and use the klog library.

## Monitoring Cluster Components

- Use the Metrics Server for resource monitoring.
- Display resource usage for nodes and pods with `kubectl top node` and `kubectl top pod`.
- Additional cluster info: `kubectl cluster-info`, `kubectl get nodes`, `kubectl get pods`.

## Application Logs and Troubleshooting

- Diagnostics: `kubectl logs`, `kubectl describe pod`, and streaming logs with `kubectl logs -f`.
- Troubleshoot by checking events, status, and error messages.

---

#### References

> Kubernetes Metrics Server (cluster component monitoring):
The Metrics Server collects resource usage metrics like CPU and memory from nodes and pods essential for monitoring.
>
> ##### Official repo and docs
>
>- [metrics-server](https://github.com/kubernetes-sigs/metrics-server)
>- [debug-application-cluster/resource-metrics-pipeline](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/)
>
> #### Kubernetes Cluster Logging Concepts
>
> Kubernetes itself does not provide a full cluster-level logging solution, but the typical approach is to use DaemonSets running logging agents (like Fluentd) on each node to collect and forward logs to backends such as Elasticsearch. Application logs can be viewed via kubectl logs from pod stdout/stderr.
>
> ###### Official docs on logging architecture
>
> - [cluster-administration/logging](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
> - [debug-cluster/logging](https://kubernetes.io/docs/tasks/debug/debug-cluster/logging/)
>
> #### Troubleshooting Application Logs with kubectl
>
> Using kubectl logs, kubectl describe pod commands to troubleshoot application and pod runtime issues is fundamental.
>
> ###### Docs for kubectl logs troubleshooting
>
> - [debug-application/debug-running-pod](https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/)
>
> #### Monitoring Cluster Components
>
> Prometheus and other advanced monitoring tools are commonly used in real-world production environments, but Metrics Server is the baseline cluster metrics provider and it is used during the exam as well.
>
> #### Kubernetes metrics concepts and troubleshooting
>
> - [debug-application-cluster/resource-metrics-pipeline](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/)
> - [debug-cluster/monitoring](https://kubernetes.io/docs/tasks/debug/debug-cluster/monitoring/)

Happy learning! 🚀
