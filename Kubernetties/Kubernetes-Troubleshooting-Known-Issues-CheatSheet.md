# Kubernetes Troubleshooting Known Issues Cheat Sheet

Fast reference for diagnosing and fixing common Kubernetes problems.

## 1) First 60-Second Triage

```bash
kubectl config current-context
kubectl get nodes
kubectl get pods -A
kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -n 40
```

Use this first to confirm cluster access, node health, and latest errors.

## 2) Pods Stuck in `Pending`

### Common causes
- No schedulable nodes
- CPU/memory requests too high
- Node taints without matching tolerations
- PVC not bound
- Namespace resource quota exceeded

### Diagnose
```bash
kubectl get pod POD -n NS -o wide
kubectl describe pod POD -n NS
kubectl get nodes
kubectl describe node NODE
kubectl get quota -n NS
kubectl get pvc -n NS
```

### Typical fixes
```bash
# Reduce requests/limits in deployment and re-apply
kubectl edit deploy APP -n NS

# Add toleration / nodeSelector as needed
kubectl edit deploy APP -n NS

# Scale cluster/nodepool (platform-specific)
# then re-check scheduling
kubectl get pods -n NS -o wide
```

## 3) Pods in `CrashLoopBackOff`

### Common causes
- App start command fails
- Missing env var / bad config
- Secret/ConfigMap not found
- Dependency (DB/API) unavailable

### Diagnose
```bash
kubectl logs POD -n NS --previous
kubectl logs POD -n NS -c CONTAINER --previous
kubectl describe pod POD -n NS
kubectl get configmap,secret -n NS
kubectl exec -it POD -n NS -- /bin/sh
```

### Typical fixes
```bash
kubectl rollout restart deploy APP -n NS
kubectl set env deploy/APP KEY=VALUE -n NS
kubectl create configmap APP-CONFIG --from-file=app.env -n NS --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic APP-SECRET --from-literal=password='VALUE' -n NS --dry-run=client -o yaml | kubectl apply -f -
```

## 4) Image Pull Errors (`ImagePullBackOff`, `ErrImagePull`)

### Common causes
- Wrong image/tag
- Private registry auth missing
- Registry/network outage

### Diagnose
```bash
kubectl describe pod POD -n NS
kubectl get pod POD -n NS -o jsonpath='{.spec.containers[*].image}'
```

### Typical fixes
```bash
# Fix image
kubectl set image deploy/APP CONTAINER=repo/image:tag -n NS

# Create/update image pull secret
kubectl create secret docker-registry regcred \
  --docker-server=REGISTRY \
  --docker-username=USER \
  --docker-password=PASS \
  -n NS

kubectl patch serviceaccount default -n NS -p '{"imagePullSecrets":[{"name":"regcred"}]}'
```

## 5) Service Not Reachable

### Common causes
- Service selector does not match pod labels
- Wrong targetPort
- Pod not Ready
- NetworkPolicy blocking traffic

### Diagnose
```bash
kubectl get svc -n NS
kubectl describe svc SVC -n NS
kubectl get endpoints SVC -n NS
kubectl get pods -n NS --show-labels
kubectl get networkpolicy -n NS
```

### Typical fixes
```bash
kubectl edit svc SVC -n NS
kubectl edit deploy APP -n NS
kubectl rollout restart deploy APP -n NS
```

## 6) Ingress Problems (404 / 502 / TLS)

### Common causes
- Host/path mismatch
- Ingress class mismatch
- Backend service/port mismatch
- TLS secret missing/invalid

### Diagnose
```bash
kubectl get ingress -A
kubectl describe ingress ING -n NS
kubectl get svc -n NS
kubectl get secret TLS_SECRET -n NS
kubectl logs -n ingress-nginx deploy/ingress-nginx-controller
```

### Typical fixes
```bash
kubectl edit ingress ING -n NS
kubectl create secret tls TLS_SECRET --cert=tls.crt --key=tls.key -n NS --dry-run=client -o yaml | kubectl apply -f -
```

## 7) DNS Issues Inside Cluster

### Symptoms
- Pods cannot resolve service names
- Intermittent name resolution failures

### Diagnose
```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl logs -n kube-system deploy/coredns
kubectl run -it dns-test --image=busybox:1.36 --restart=Never -- nslookup kubernetes.default
```

### Typical fixes
```bash
kubectl rollout restart deploy/coredns -n kube-system
kubectl get configmap coredns -n kube-system -o yaml
```

## 8) PVC/PV Binding and Mount Failures

### Common causes
- StorageClass mismatch
- No available PV
- Access mode mismatch
- CSI driver issues

### Diagnose
```bash
kubectl get pvc,pv -A
kubectl describe pvc PVC -n NS
kubectl get storageclass
kubectl get pods -n kube-system | grep -i csi
```

### Typical fixes
```bash
kubectl edit pvc PVC -n NS
kubectl edit storageclass SC_NAME
kubectl delete pod POD -n NS
```

## 9) Nodes `NotReady` or Unstable

### Common causes
- Kubelet down
- Disk pressure / memory pressure
- CNI plugin failure
- Runtime/containerd issues

### Diagnose
```bash
kubectl get nodes
kubectl describe node NODE
kubectl get pods -n kube-system -o wide
```

### Node-level checks (on node)
```bash
sudo systemctl status kubelet
sudo journalctl -u kubelet -n 200 --no-pager
sudo systemctl status containerd
df -h
free -h
```

### Typical fixes
```bash
# Restart kubelet/container runtime on node
sudo systemctl restart containerd
sudo systemctl restart kubelet

# Safely drain for maintenance
kubectl cordon NODE
kubectl drain NODE --ignore-daemonsets --delete-emptydir-data
kubectl uncordon NODE
```

## 10) `kubectl` Forbidden / RBAC Denied

### Diagnose
```bash
kubectl auth can-i get pods -n NS
kubectl auth can-i create deploy -n NS
kubectl get role,rolebinding -n NS
kubectl get clusterrole,clusterrolebinding
```

### Typical fixes
```bash
# Apply proper Role/RoleBinding or ClusterRoleBinding manifest
kubectl apply -f rbac.yaml
```

## 11) Rollout Stuck / Bad Deploy

### Diagnose
```bash
kubectl rollout status deploy/APP -n NS
kubectl rollout history deploy/APP -n NS
kubectl describe deploy APP -n NS
kubectl get rs -n NS
```

### Typical fixes
```bash
kubectl rollout undo deploy/APP -n NS
kubectl set image deploy/APP CONTAINER=repo/image:known-good -n NS
kubectl rollout restart deploy/APP -n NS
```

## 12) `OOMKilled` and Resource Pressure

### Diagnose
```bash
kubectl get pod POD -n NS -o jsonpath='{.status.containerStatuses[*].lastState.terminated.reason}'
kubectl top pod -n NS
kubectl top node
kubectl describe pod POD -n NS
```

### Typical fixes
```bash
kubectl edit deploy APP -n NS
# Increase memory limits/requests carefully and re-apply
kubectl apply -f deploy.yaml
```

## 13) Timeouts / API Slowness

### Diagnose
```bash
kubectl get --raw='/readyz?verbose'
kubectl get --raw='/livez?verbose'
kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -n 80
```

### Typical fixes
- Reduce API churn (excessive controllers/jobs).
- Check etcd/control-plane metrics.
- Scale control plane (managed cluster setting).

## 14) High-Value One-Liners

```bash
# All non-running pods
kubectl get pods -A --field-selector=status.phase!=Running

# Restart all deployments in namespace
kubectl rollout restart deploy -n NS

# Latest warnings
kubectl get events -A --field-selector type=Warning --sort-by=.metadata.creationTimestamp | tail -n 50

# Pods with node placement
kubectl get pods -A -o wide
```

## 15) Safe Troubleshooting Workflow

1. Confirm context/namespace before any change.
2. Read `describe` and events first.
3. Pull logs (`--previous` for crashes).
4. Validate service endpoints, selectors, and readiness.
5. Check storage and DNS if app dependencies fail.
6. Apply minimal fix.
7. Watch rollout and verify.
8. Roll back if impact increases.

```bash
kubectl config current-context
kubectl get pods -n NS
kubectl describe pod POD -n NS
kubectl logs POD -n NS --previous
kubectl rollout status deploy/APP -n NS
```
