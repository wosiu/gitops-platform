#!/bin/bash
set -euo pipefail

# Check access to the cluster
if ! kubectl cluster-info &>/dev/null; then
    echo "No access to Kubernetes cluster"
    echo "Please check your AWS credentials and Kubeconfig context"
    echo "Go to README.md for more details"
    exit 1
fi

# Install ArgoCD in the cluster if not installed yet
if ! kubectl get namespace argocd &> /dev/null; then
    helm repo add argo https://argoproj.github.io/argo-helm
    helm install argocd argo/argo-cd -n argocd --create-namespace
fi

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Login to ArgoCD
argocd login --core --username admin --password "$ARGOCD_PASSWORD"

# Check if argocd is available
if ! argocd cluster list &>/dev/null; then
    echo "ArgoCD is not available"
    exit 1
fi

if ! argocd app get root-app &>/dev/null; then
    echo "ArgoCD root-app does not exist, creating..."
    GITOPS_REPO_URL="https://github.com/wosiu/gitops-platform"
    kubectl config set-context --current --namespace=argocd
    argocd repo add $GITOPS_REPO_URL --name gitops-platform

    argocd app create root-app \
        --repo $GITOPS_REPO_URL \
        --path root-app \
        --dest-server https://kubernetes.default.svc \
        --dest-namespace argocd \
        --sync-policy automated 
fi