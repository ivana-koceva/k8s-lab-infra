#!/usr/bin/env bash
set -euo pipefail

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods
echo "Waiting for ArgoCD pods..."
kubectl wait pods -n argocd --all --for=condition=ready --timeout=300s

# Configure insecure mode (plain HTTP, Traefik handles routing)
kubectl patch configmap argocd-cmd-params-cm -n argocd \
  --type merge -p '{"data": {"server.insecure": "true"}}'
kubectl rollout restart deployment argocd-server -n argocd
kubectl rollout status deployment argocd-server -n argocd

# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 \
  https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

echo ""
echo "Initial admin password:"
argocd admin initial-password -n argocd
echo ""
echo "Next: run 02-bootstrap-gitops.sh"