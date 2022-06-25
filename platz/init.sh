#!/bin/bash

set -eu

NAMESPACE="platz"
VALUES_FILE="/tmp/values.yaml"
HELM_VERSION="3.9.0"

echo "===== 🛠 Installing k3s ====="

curl -fL https://get.k3s.io | sh -

echo "===== 🛠 Install Helm ====="

(cd /usr/local/bin && \
 curl -fL "https://get.helm.sh/helm-v$${HELM_VERSION}-linux-amd64.tar.gz" -o - | \
 tar xvzf - --strip-components=1 linux-amd64/helm)

echo "===== ⏳ Waiting for k3s to boot ====="

until (kubectl get deploy -n kube-system traefik | grep '1/1')
do
    sleep 1
done

echo "===== 🏷 Creating namespace ====="

kubectl create ns "$${NAMESPACE}"

echo "===== 🤐 Creating OIDC secret ====="

kubectl create secret generic -n "$${NAMESPACE}" "${oidc_secret_name}" \
    --from-literal=serverUrl="${oidc_server_url}" \
    --from-literal=clientId="${oidc_client_id}" \
    --from-literal=clientSecret="${oidc_client_secret}"

echo "===== 🧾 Creating values.yaml ====="

cat <<EOF >$${VALUES_FILE}
ownUrlOverride: https://${domain_name}

images:
  dummy: {}
  %{ if backend_version_override != null ~}
  backend:
    tag: ${backend_version_override}
  %{ endif ~}
  %{ if frontend_version_override != null ~}
  frontend:
    tag: ${frontend_version_override}
  %{ endif ~}

auth:
  adminEmails:
    %{ for admin_email in admin_emails ~}
    - ${admin_email}
    %{ endfor ~}

api:
  enabledVersions:
    - v2
  resources: null

chartDiscovery:
  resources: null

resourceSync:
  resources: null

statusUpdates:
  resources: null

k8sAgents:
  - name: default
    resources: null
    serviceAccount:
      name: ""
      annotations: {}

frontend:
  resources: null

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: traefik

postgresql:
  enabled: false
  databaseUrlOverride: "postgresql://${db_username}:${db_password}@${db_endpoint}/${db_name}"
EOF

echo "===== 🏗 Installing ====="

helm repo add platzio https://platzio.github.io/helm-charts
helm repo update

helm --debug \
    --kubeconfig=/etc/rancher/k3s/k3s.yaml \
    install \
    --version "${chart_version}" \
    platzio \
    platzio/platzio \
    -n "$${NAMESPACE}" \
    -f "$${VALUES_FILE}"
