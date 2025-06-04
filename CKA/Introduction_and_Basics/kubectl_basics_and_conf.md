# kubectl Basics and Configuration

`kubectl` is the command-line tool for interacting with Kubernetes clusters. With `kubectl`, you can deploy applications, inspect and manage cluster resources, and view logs. Mastering `kubectl` is essential for day-to-day Kubernetes administration and for success in the CKA exam.

---

## 1. kubectl Syntax

The general syntax for `kubectl` commands is:

```
kubectl [command] [TYPE] [NAME] [flags]
```

- **command:** The operation to perform (e.g., `get`, `create`, `delete`, `apply`)
- **TYPE:** The resource type (e.g., `pod`, `service`, `deployment`). Singular, plural, or abbreviated forms are accepted (e.g., `pod`, `pods`, `po`).
- **NAME:** The name of the resource (optional; if omitted, the command applies to all resources of that type).
- **flags:** Optional arguments to modify command behavior (e.g., `-n` for namespace, `-o` for output format).

---

## 2. Common kubectl Commands

Here are some essential `kubectl` commands for cluster management:

### Cluster and Resource Inspection

```
# List all nodes in the cluster
kubectl get nodes

# List all pods in the current namespace
kubectl get pods

# List all resources in all namespaces
kubectl get all --all-namespaces

# Show detailed information about a pod
kubectl describe pod 

# Show labeled nodes
kubectl get nodes --show-labels
```

### Creating and Managing Resources

```
# Create a resource from a YAML file
kubectl apply -f resource.yaml

# Create a deployment with 2 replicas
kubectl create deployment my-nginx --image=nginx --replicas=2

# Delete a resource
kubectl delete pod 
```

### Debugging and Logs

```
# View logs for a pod
kubectl logs 

# Execute a command inside a running pod
kubectl exec -it  -- /bin/bash
```

### Copying Files

```
# Copy a file from your local machine to a pod
kubectl cp ./localfile.txt [[namespace/]pod:]file/path
```

---

## 3. kubectl Configuration

`kubectl` uses a configuration file (usually located at `~/.kube/config`) to determine which cluster to connect to and which credentials to use.

### Managing Contexts

- **View current configuration:**
  ```
  kubectl config view
  ```
- **List all available contexts:**
  ```
  kubectl config get-contexts
  ```
- **Switch to a different context:**
  ```
  kubectl config use-context 
  ```
- **Set a default namespace for a context:**
  ```
  kubectl config set-context --current --namespace=
  ```

### Configuration File Structure

The kubeconfig file contains:
- **clusters:** Information about Kubernetes clusters
- **users:** Authentication info
- **contexts:** A context ties a user to a cluster and a namespace

You can specify an alternate kubeconfig file with:
```
kubectl --kubeconfig /path/to/your/config get pods
```

---

## 4. Output Formatting

`kubectl` supports multiple output formats:

- **Wide:** More details (e.g., node name)
  ```
  kubectl get pods -o wide
  ```
- **YAML/JSON:** For scripting and automation
  ```
  kubectl get pod  -o yaml
  kubectl get pod  -o json
  ```
- **Custom Columns:** For tailored outputs
  ```
  kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase
  ```

---

## 5. Helpful Flags

- `-n` or `--namespace`: Specify the namespace
- `-o`: Output format (e.g., `-o yaml`, `-o json`, `-o wide`)
- `--dry-run=client`: Preview the result of a command without making changes
- `--help`: Show help for any command

---

## 6. Tips for the CKA Exam

- Practice using `kubectl` commands quickly and accurately.
- Use `kubectl explain ` to get documentation on any resource type.
- Familiarize yourself with YAML manifests and how to apply them.
- Use `kubectl create --dry-run=client -o yaml ...` to generate YAML templates for resources.

---

## Additional Resources

- [kubectl Quick Reference - Kubernetes Docs](https://kubernetes.io/docs/reference/kubectl/quick-reference/)
- [kubectl Cheat Sheet - Spacelift](https://spacelift.io/blog/kubernetes-cheat-sheet)
- [kubectl Commands - GeeksforGeeks](https://www.geeksforgeeks.org/kubernetes-kubectl-commands/)
- [kubectl Official Reference](https://kubernetes.io/docs/reference/kubectl/)

---

Mastering `kubectl` is the foundation for efficient Kubernetes administration and troubleshooting!
