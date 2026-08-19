
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

admin

WbLn9twJjd0eRj4T2bax4g6urtdMpGGAltgFs862