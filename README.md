# k8s-lab-infra

Single-node Kubernetes lab environment provisioned from code using Vagrant and k3s, intended as the infrastructure foundation for a local GitOps platform.

## Structure
```
k8s-infra/
├── bootstrap/
│   ├── 01-install-argocd.sh   # Installs and configures ArgoCD
│   └── 02-bootstrap-gitops.sh # Applies App of Apps, sets up access
├── Vagrantfile       # VM definition and k3s provisioner
├── kubeconfig.yaml   # Generated on vagrant up (gitignored)
├── INSTALLATION.md
└── README.md
```

## Requirements
- VirtualBox
- Vagrant
- kubectl
- Helm

See [INSTALLATION.md](INSTALLATION.md) for setup instructions.

## Quickstart

Generate a dedicated SSH key for the VM (one-time):
```bash
ssh-keygen -t ed25519 -C "k8s-lab-vm" -f ~/.ssh/k8s_lab_key
```

Start the cluster:
```bash
vagrant up
export KUBECONFIG="$(pwd)/kubeconfig.yaml"
kubectl get nodes
```

To persist the kubeconfig across sessions, add the export to your `~/.bashrc` or `~/.zshrc`.

## Bootstrap ArgoCD
 
Run the scripts in order from the repo root:
 
```bash
chmod +x bootstrap/*.sh   # one-time, after cloning
 
./bootstrap/01-install-argocd.sh
./bootstrap/02-bootstrap-gitops.sh
```
 
`02-bootstrap-gitops.sh` assumes the gitops repo is cloned at `../k8s-lab-gitops`. Pass an explicit path if yours differs:
```bash
./bootstrap/02-bootstrap-gitops.sh /path/to/k8s-lab-gitops
```
 
After both scripts complete, ArgoCD is available at `http://argocd.local`.

## VM Management

| Command | Effect |
|---|---|
| `vagrant up` | Create VM and provision cluster |
| `vagrant halt` | Shut down VM, preserve state |
| `vagrant ssh` | Shell access inside the VM |
| `vagrant destroy && vagrant up` | Full clean rebuild |

Direct SSH: `ssh -i ~/.ssh/k8s_lab_key vagrant@192.168.56.10`

## Verify the Cluster

```bash
kubectl get nodes
kubectl get pods -A
kubectl cluster-info
```

All pods in `kube-system` should be `Running`. The API server should be reachable at `https://192.168.56.10:6443`.

