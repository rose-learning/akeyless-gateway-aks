helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
# Add this above the last argument for GKE Auto Pilot
# --set global.leaderElection.namespace=cert-manager

# Be sure to change email to your email
cat << EOF >| lets-encrypt-prod-issuer.yml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  annotations: {}
  name: letsencrypt-prod
spec:
  acme:
    email: your.email@example-company.com
    preferredChain: ""
    privateKeySecretRef:
      name: letsencrypt-prod
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
      - http01:
          ingress:
            class: nginx
EOF

kubectl apply -f lets-encrypt-prod-issuer.yml -n akeyless
