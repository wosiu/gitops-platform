## Tools required for bootstrapping and local development
- [helm](https://helm.sh/docs/intro/install/#from-homebrew-macos)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#install-with-homebrew-on-macos)
- [argocd](https://kostis-argo-cd.readthedocs.io/en/refresh-docs/getting_started/install_cli/#install-on-macos-darwin)

TODO Once I know platform of the machine responsible for bootstrapping, implement script (or ansible playbook or...) to install all the tools above.

## Bootstrap ArgoCD

### Prerequisite - cluster connection

Ensure you have access to the desired AWS account from your terminal.
<details>
<summary>Setup example</summary>

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```
or whatever more advanced way you use to set AWS creds.
</details><br>

Check the current context (`kubectl config get-contexts`) and if it points to the desired cluster.  

<details>
<summary>Click here if the desired context is not available.</summary>

Run:
```bash
aws eks update-kubeconfig --region us-west-2 --alias mwos-interview --name <cluster_name>
```
where `<cluster_name>` was the output from terraform (you can also check in AWS Console)
</details><br>


Switch to the desired context if not already.
<details>
<summary>Example</summary>

`kubectl config use-context mwos-interview
`
</details><br>


### The bootstrap
Run:
```
./scripts/bootstrap_argocd.sh
```


