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

kubectl apply -f argocd_gitops_repo.yaml
kubectl apply -f root_app.yaml
