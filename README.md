# Estrion DevSecOps Test

This repository implements the requested workflow:

**Python → Docker → GitHub Actions → Trivy → GHCR → Helm → Kubernetes → Argo CD**

## Files

- `app.py` — supplied Python application; intentionally unchanged
- `requirements.txt` — supplied dependency
- `Dockerfile` — container image
- `.github/workflows/ci.yml` — build, security scan and GHCR push
- `helm/estrion-app/` — Kubernetes resources as a Helm chart
- `argocd/application.yaml` — Argo CD GitOps definition

## 1. GitHub

Create a **public** GitHub repository. Replace `YOUR_GITHUB_USERNAME` and `YOUR_REPOSITORY` in:

- `helm/estrion-app/values.yaml`
- `argocd/application.yaml`

Then push the project to the `main` branch.

## 2. Test Docker locally

```bash
docker build -t estrion-python-app:local .
docker run --rm -p 8080:8080 estrion-python-app:local
```

Open `http://localhost:8080`.

Expected response:

`DevSecOps Pipeline erfolgreich! Aktuelles Environment: Local`

Health check:

`http://localhost:8080/health`

## 3. GitHub Actions

Every push to `main` builds the image, scans it with Trivy for CRITICAL vulnerabilities, and pushes `latest` to GHCR.

After the first successful run, make the GHCR package public if you want the local Kubernetes cluster to pull it without an image-pull secret. Do not commit passwords or personal access tokens.

## 4. Local Kubernetes

Install Docker, kubectl, Helm and minikube in the Chromebook Linux environment. Then:

```bash
minikube start --driver=docker
kubectl get nodes
```

## 5. Argo CD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd
```

Wait until the Argo CD pods are running.

## 6. Deploy through Argo CD

Update `argocd/application.yaml` with your real GitHub repository URL, then:

```bash
kubectl apply -f argocd/application.yaml
kubectl get applications -n argocd
```

## 7. Argo CD UI

Get the initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Forward the UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open `https://localhost:8080` and log in as `admin` using the printed password.

The application should become **Healthy** and **Synced**.

## 8. Test the app

```bash
kubectl get all -n estrion-app
minikube service estrion-app -n estrion-app
```

The response should contain:

`DevSecOps Pipeline erfolgreich! Aktuelles Environment: ArgoCD-Test-Environment`

That proves the Kubernetes ConfigMap value reached the Python application.

## Troubleshooting

```bash
kubectl get all -n estrion-app
kubectl get configmap -n estrion-app
kubectl logs -n estrion-app deployment/estrion-app
kubectl describe pods -n estrion-app
kubectl get application estrion-app -n argocd
```

## Evidence

Submit:

1. Public GitHub repository URL.
2. This README with reproducible steps.
3. 2–3 screenshots or a short video showing Argo CD **Healthy/Synced** and the application displaying `ArgoCD-Test-Environment`.
