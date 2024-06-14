helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install quickstart ingress-nginx/ingress-nginx -n nginx-ingress --create-namespace --set controller.service.externalTrafficPolicy=Local

# Wait for the IP address of the nginx controller's external load balancer IP to be provisioned
# Use that IP address to setup all DNS entries from the gateway values YAML below
