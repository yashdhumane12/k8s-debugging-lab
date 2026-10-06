#!/bin/bash
# K8s Debugging Cheatsheet Script
NS=${1:-default}

echo "=== Pod Status ==="
kubectl get pods -n $NS -o wide

echo ""
echo "=== Events (last 20) ==="
kubectl get events -n $NS --sort-by='.lastTimestamp' | tail -20

echo ""
echo "=== CrashLoopBackOff pods ==="
kubectl get pods -n $NS | grep -E "CrashLoop|Error|OOMKilled|Pending"

echo ""
echo "To debug a specific pod:"
echo "  kubectl describe pod <pod-name> -n $NS"
echo "  kubectl logs <pod-name> -n $NS --previous"
echo "  kubectl exec -it <pod-name> -n $NS -- /bin/sh"
echo ""
echo "Check DNS from inside pod:"
echo "  kubectl run dns-test --rm -it --image=busybox -- nslookup kubernetes"
echo ""
echo "Check network policy:"
echo "  kubectl get networkpolicies -n $NS"
echo ""
echo "Check resource usage:"
echo "  kubectl top pods -n $NS"
