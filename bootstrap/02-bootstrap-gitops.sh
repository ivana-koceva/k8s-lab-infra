#!/usr/bin/env bash
set -euo pipefail

GITOPS_REPO="${1:-$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")/k8s-lab-gitops}"
ROOT_APP="$GITOPS_REPO/apps/apps.yaml"

[[ -f "$ROOT_APP" ]] || { echo "ERROR: $ROOT_APP not found. Pass the gitops repo path as an argument."; exit 1; }

# Add argocd.local to /etc/hosts if not already present
grep -q "argocd.local" /etc/hosts || \
  echo "192.168.56.10  argocd.local" | sudo tee -a /etc/hosts

# Apply the App of Apps
kubectl apply -f "$ROOT_APP"

# Wait for ArgoCD to sync the root app
echo "Waiting for apps to sync..."
kubectl wait application/apps \
  -n argocd \
  --for=jsonpath='{.status.sync.status}'=Synced \
  --timeout=120s

echo ""
echo "Bootstrap complete."
echo ""
echo "Initial admin password:"
argocd admin initial-password -n argocd | head -1
echo ""
echo "Next steps:"
echo "  1. Open http://argocd.local and log in with the password above"
echo "  2. Change your password: User Info → Update Password"
echo "  3. Delete the initial secret:"
echo "     kubectl delete secret argocd-initial-admin-secret -n argocd"
kubectl get applications -n argocd