# 🔧 Kubernetes Debugging Lab

5 intentionally broken K8s scenarios. Apply them, diagnose the issue, then fix it.

## Scenarios

| Scenario | Bug | Symptom |
|----------|-----|---------|
| `bad-probes` | Wrong probe path `/healthz` | CrashLoopBackOff |
| `wrong-limits` | Memory limit 4Mi (too low) | OOMKilled |
| `broken-dns` | Service name mismatch | DNS resolution fails |
| `failed-mounts` | Missing ConfigMap | CreateContainerConfigError |
| `network-issues` | NetworkPolicy blocks all ingress | Connection timeout |

## How to use

```bash
# Apply one broken scenario
kubectl apply -f manifests/bad-probes/

# Watch what happens
kubectl get pods -w

# Diagnose
kubectl describe pod <pod-name>
kubectl logs <pod-name> --previous

# Use the debug script
bash scripts/debug.sh

# Fix it (edit the YAML, remove the BUG, apply fix)
kubectl apply -f manifests/bad-probes/

# Clean up
kubectl delete -f manifests/bad-probes/
```

## Debugging commands

```bash
# See all events (great for pending/error pods)
kubectl get events --sort-by='.lastTimestamp'

# Get detailed pod info (look at Events section)
kubectl describe pod <name>

# Logs from crashed container
kubectl logs <name> --previous

# Run a debug pod in the cluster
kubectl run debug --rm -it --image=busybox -- /bin/sh

# Check DNS resolution from inside cluster
kubectl run dns-test --rm -it --image=busybox -- nslookup my-service

# Check if NetworkPolicy is blocking
kubectl get networkpolicies

# Resource usage
kubectl top pods
kubectl top nodes
```

## Fix guide

### bad-probes
```yaml
# Change /healthz to /
livenessProbe:
  httpGet:
    path: /   # FIX
```

### wrong-limits
```yaml
resources:
  limits:
    memory: "128Mi"   # FIX: was 4Mi
```

### broken-dns
```yaml
# Change env value from "database" to "db"
env:
  - name: DB_HOST
    value: "db"   # FIX
```

### failed-mounts
```bash
# Create the missing ConfigMap first
kubectl create configmap app-config --from-literal=key=value
```

### network-issues
```yaml
# Add ingress rule to NetworkPolicy
ingress:
  - from:
    - podSelector: {}
    ports:
    - port: 80
```
