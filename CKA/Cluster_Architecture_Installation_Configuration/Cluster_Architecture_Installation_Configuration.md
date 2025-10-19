# Cluster Architecture, Installation & Configuration (25%)

_Knowing the theory is great, but hands-on muscle memory and real-world examples make the difference on exam day! So, here’s practical, human-focused guidance and code snippets for each area. I’ve sprinkled in pro tips, gotchas from live clusters, and command samples that will save you time in the CKA exam environment._

We will use [Killercoda live playground](https://killercoda.com/playgrounds/scenario/kubernetes) to run these scnarios.

#### [YouTube video link](TBD)
---

## 🛡️ Role-Based Access Control (RBAC)

**What is RBAC?**
RBAC is a way to control access to Kubernetes resources.
**RBAC** lets you gatekeep: Who can do what, where, with which Kubernetes objects?

**What is a Role?**
A Role is a Kubernetes resource that defines a set of permissions.
It is a Kubernetes resource that defines a set of rules.

**What is a RoleBinding?**
A RoleBinding is a Kubernetes resource that binds a Role to a set of Subjects.

**RoleBindings** and **ClusterRoleBindings** are **central to secure Kubernetes cluster administration**, they control "who" can access Kubernetes resources and "where"
those permissions apply. Understanding the differences, common use cases, and practical troubleshooting is vital for the CKA exam and real-world clusters.

## Key Differences

```
+---------------------+--------------------------+--------------------------------+
|      Concept        |    Role/RoleBinding      | ClusterRole/ClusterRoleBinding |
+---------------------+--------------------------+--------------------------------+
| Scope               | Namespace-specific       | Cluster-wide (all namespaces)  |
+---------------------+--------------------------+--------------------------------+
| Resource            | Pods, secrets, etc.      | Nodes or any resource          |
+---------------------+--------------------------+--------------------------------+
| Typical Uses        | Fine-grained control     | Admin, view, access cluster    |
|                     | (dev, prod teams)        | wide (infrastructure, etc.)    |
+---------------------+--------------------------+--------------------------------+
```

### Common Examples

**Namespace Role**  

Following command will imperatively create the `secret-reader` Role in the `dev` namespace, granting permissions to `get` and `list` secrets (remove `--dry-run=client  -o yaml` to actually create it).

Create a Role to permit reading secrets in the `dev` namespace.:

```bash
kubectl create role secret-reader \
  --namespace=dev \
  --verb=get,list \
  --resource=secrets \
  --dry-run=client  -o yaml
```

or use following YAML file and apply it

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader
  namespace: dev
rules:
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - get
  - list
```

Create a RoleBinding for a user (remove `--dry-run=client  -o yaml` to actually create it):

```bash
kubectl create rolebinding dev-secrets-read \
 --role=secret-reader --user=devuser --namespace=dev --dry-run=client -o yaml
```

or use following yaml and apply it.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-secrets-read
  namespace: dev
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: secret-reader
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: devuser
```

**Tip:** RoleBindings are namespace-scoped!

**Test the permission**  
Check if `devuser` can read secrets:

```bash
kubectl auth can-i get secrets --namespace=dev --as=devuser
```

**ServiceAccount Example**

Create a ServiceAccount (remove `--dry-run=client  -o yaml` to actually create it):

```bash
kubectl create sa -n dev cicd-bot --dry-run=client -o yaml
```

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cicd-bot
  namespace: dev
```

Bind the service account to the Role (remove `--dry-run=client  -o yaml` to actually create it):

```bash
kubectl create rolebinding bot-secrets-read \
 --role=secret-reader --serviceaccount=dev:cicd-bot --namespace=dev \
 --dry-run=client -o yaml

```

More: [Kubernetes RBAC Official Docs](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

## Practical Examples

### 1. RoleBinding (namespaced)

Bind a namespaced `Role` to a user/service account:

```bash
kubectl create rolebinding read-secrets-binding \
  --role=secret-reader \
  --user=devuser \
  --namespace=dev
```
_YAML equivalent:_

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-secrets-binding
  namespace: dev
subjects:
- kind: User
  name: devuser
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

### 2. ClusterRoleBinding (cluster-wide)

Bind a `ClusterRole` to a user across all namespaces:

```bash
kubectl create clusterrolebinding global-pod-reader \
  --clusterrole=pod-reader \
  --user=alice
```

_YAML equivalent:_

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: global-pod-reader
subjects:
- kind: User
  name: alice
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

## Common Mistakes & Exam Tips

- A **RoleBinding** can reference a `ClusterRole` to give cluster-level permissions within a single namespace. This is common:

  ```bash
  kubectl create rolebinding audit-admin \
    --clusterrole=admin \
    --user=auditteam \
    --namespace=dev
  ```

- **ClusterRoleBindings always work cluster-wide.** You cannot scope a ClusterRoleBinding to a specific namespace.
- Make sure to match the `kind` and `name` in the `roleRef`—typos here cause silent failures.
- Use `kubectl auth can-i <verb> <resource> --as <user> --namespace <ns>` to test permissions (e.g. `kubectl auth can-i list pods --as alice`).

## Challenge Practice

1. **Create a ClusterRole** that lets you list and get pods anywhere.
2. **Bind that ClusterRole** to a service account used by automation (e.g., `cicd-bot` in the namespace `staging`)—but only in that namespace.
3. Test with `kubectl auth can-i` using `--as=system:serviceaccount:staging:cicd-bot`.

## Mnemonic to Remember

- **RoleBinding = namespace**, **ClusterRoleBinding = cluster**
- To restrict **where** permissions apply, use RoleBinding. For broad permissions, use ClusterRoleBinding.

---

## 🚀 Create & Manage Clusters using kubeadm. I don't think it would be needed but still you should know how it is done.

**Init a new cluster**
[Documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
Initialize with Pod network CIDR and control plane endpoint:

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint=mylb.example.com:6443
```

**Set up kubectl config:**

```bash
export KUBECONFIG=/etc/kubernetes/admin.conf
mkdir -p \$HOME/.kube
cp /etc/kubernetes/admin.conf \$HOME/.kube/config
chown $(id -u):$(id -g) \$HOME/.kube/config
```

**Join worker node**

```bash
kubeadm join mylb.example.com:6443 --token abc123 --discovery-token-ca-cert-hash sha256:...
```

**Tip:**  
Your token expires—refresh with:

```bash
kubeadm token create
```

Get the ca-cert-hash:

```bash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | \
openssl rsa -pubin -outform der 2>/dev/null | \
openssl dgst -sha256
```

More: [kubeadm Official Guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

---

## 🔄 Cluster Lifecycle Management

**Draining for Maintenance**

```bash
kubectl drain node-1 --ignore-daemonsets --delete-local-data
kubectl cordon node-1
kubectl uncordon node-1
```

**Delete & Re-add Nodes (Assuming you have a node named `node-2`**

```bash
kubectl delete node node-2

# On node-2
kubeadm reset
```

**Certificates (I think this will not be needed during the exam, however adding a user and signing a CSR certificate signing request will be there):**
Extend kubeadm certificates (they expire in one year):

```bash
kubeadm certs renew all
```

More: [Administer Clusters](https://kubernetes.io/docs/tasks/administer-cluster/)

---

## 🏆 Implement Highly-Available Control Plane (I don't expect it to be part of the exam!, its good to know for real life self managed k8s)

**Add additional masters**  
On new control plane node:

```bash
kubeadm join mylb.example.com:6443 --token abc123 \
--discovery-token-ca-cert-hash sha256:... \
--control-plane --certificate-key <cert-key>
```

**Rotate leadership:**  
Shutdown kube-apiserver on one master, check cluster remains “Ready”.

**Real world tip:**  
Use keepalived for virtual IP in small home labs; cloud users use provider load balancers.

More: [Kubeadm HA Clusters](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)

---

## ⬆️ Version Upgrades

**Control Plane Upgrade**
[Documentation](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)


The upgrade workflow at high level is the following:

1) Upgrade a primary control plane node.
2) Upgrade additional control plane nodes.
3) Upgrade worker nodes.

Update the OS packages:

```bash
# Find the latest 1.34 version in the list.
# It should look like 1.34.x-*, where x is the latest patch.
sudo apt update
sudo apt-cache madison kubeadm
# replace x in 1.34.x-* with the latest patch version
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='1.34.x-*' && \
sudo apt-mark hold kubeadm
```

Plan and apply the newer version:

```bash
sudo kubeadm upgrade plan
# replace x with the patch version you picked for this upgrade
sudo kubeadm upgrade apply v1.34.x
```

Once the command finishes you should see:

> _[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.34.x". Enjoy!_
> 
> _[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so._


**Node Upgrade**
[Documentation](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/upgrading-linux-nodes/)

Call **"kubeadm upgrade"**
For worker nodes this upgrades the local kubelet configuration:

```bash
sudo kubeadm upgrade node
```

Drain the node (Prepare the node for maintenance by marking it unschedulable and evicting the workloads):

```bash
# replace <node-to-drain> with the name of your node you are draining
kubectl drain <node-to-drain> --ignore-daemonsets
```

Upgrade the kubelet and kubectl:

```bash
# replace x in 1.34.x-* with the latest patch version
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='1.34.x-*' kubectl='1.34.x-*' && \
sudo apt-mark hold kubelet kubectl
```

Restart the kubelet:

```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

Bring the node back online by marking it schedulable:

```bash
# replace <node-to-uncordon> with the name of your node
kubectl uncordon <node-to-uncordon>
```

**Tip:**  
Verify versions:

```bash
kubectl get nodes
```

More: [Upgrading kubeadm Clusters](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

---

## 🧩 etcd Backup & Restore

**Backup etcd**

```bash
ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
 --endpoints=https://127.0.0.1:2379 \
 --cert=/etc/kubernetes/pki/etcd/peer.crt \
 --key=/etc/kubernetes/pki/etcd/peer.key \
 --cacert=/etc/kubernetes/pki/etcd/ca.crt
```

**Restore etcd**
```bash
ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup.db --data-dir /var/lib/etcd-from-backup
```

**Tip:**  
Remount the etcd member data after restore, update static Pod manifest, and restart kubelet.

More: [etcd Official Docs](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)

---

## 🔌 Extension Interfaces: CNI, CSI, CRI

**CNI Example (for reference only, I don't expect it to be in the exam):**  
Check networking:

```bash
cat /etc/cni/net.d/*
kubectl get pods -n kube-system
```

Install Calico networking (for reference only, I don't expect it to be in the exam):

```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

**CSI Example(for reference only, I don't expect it to be in the exam):**  
List storage drivers:

```bash
kubectl get csidrivers
kubectl get volumeattachments

```

**CRI Check:**

```bash
systemctl status containerd
```

More:  
- [Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
- [Storage](https://kubernetes.io/docs/concepts/storage/)
- [Container Runtimes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)

---

## 🧬 Custom Resource Definitions (CRDs) & Operators (for reference only, I don't expect it to be in the exam):

**Define a simple CRD**

```bash
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: helloapps.demo.io
spec:
  group: demo.io
  names:
    plural: helloapps
    singular: helloapp
    kind: HelloApp
    shortNames:
      - ha
  scope: Namespaced
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                message:
                  type: string
            status:
              type: object
              properties:
                state:
                  type: string
```

**Apply it:**

```bash
kubectl apply -f crd.yaml
kubectl get crds |grep helloapps
```

**Install Operator (Helm)**

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prom-operator prometheus-community/kube-prometheus-stack
```

**Tip:**  
Look for new objects after install:

```bash
kubectl get servicemonitors,alertmanagers
```

See what all it configured in your cluster using:

```bash
helm get all prom-operator
```

More:  
- [CRD Docs](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/)
- [Operators](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)

---

## 🏅 Hands-On Exam Wisdom

- Alias `kubectl` to `k` to save time (`alias k=kubectl`)
- Use `kubectl explain <resource>`
- Backup etcd, read logs: `journalctl -u kubelet`
- Try `--dry-run=client -o yaml` for safe manifest editing
- Label nodes: `kubectl label node node-1 env=prod`
- Debug pods: `kubectl describe <resource>`
- Always check `kubectl get events`!

---

## 🏠 Homework (Do It Yourself)

- Set up a 3-node cluster, with two control plane nodes (hint: use VirtualBox or cloud VMs).
- Create custom RBAC so only a “devuser” can list pods in the “dev” namespace.
- Use Helm to install a dashboard or metrics-server component; delete and reinstall it.
- Simulate an etcd disaster: intentionally break a cluster, restore from snapshot.
- Write your own CRD (“helloapp”), deploy at least one operator, and create a custom resource instance.
- Upgrade kubeadm and kubelet on a node, noting every error and fix.
- Document every step in your own markdown for future reference—this is real-world professional documentation!

---

_If you struggled or got stuck, post your config and error. Every mistake made creates a powerful learning opportunity. When in doubt, check the official docs. Almost every exam task can be solved with commands or YAML found there. Good luck!_