helm repo add akeyless https://akeylesslabs.github.io/helm-charts
helm repo update
# See values.yaml file below
helm install agw akeyless/akeyless-api-gateway -f values.yaml -n akeyless
