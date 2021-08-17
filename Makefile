dep: ## Get all dependencies
		helm repo add apache-airflow https://airflow.apache.org
		helm repo update

create-ns: ##  Create namespace in k8s
		kubectl create namespace apache-airflow

add-volume: ## Add a Persistent Volume
		kubectl apply -f .helm/apache-airflow/persistentVolume.yaml -n apache-airflow

claim-volume: ## Claim a Persistent Volume
		kubectl apply -f .helm/apache-airflow/persistentVolumeClaim.yaml -n apache-airflow

prep: dep create-ns add-volume claim-volume ## Prep  and execute all pre-requisite

docker-login: ## Login into Docker Hub
		docker login

docker-build: ## Build The Docker Image
		docker build --pull --no-cache -f Dockerfile -t <repo-user-name>/airflow:0.0.1 .

docker-push: ## Push local image into Docker hub
		docker push gosapoorv/airflow:0.0.1

extend-image:docker-login docker-build docker-push  ## Extend/Customize the Base Image

install: ## Install Release in helm with debug enabled
		helm upgrade --install rl-apache-airflow apache-airflow/airflow -n apache-airflow -f .helm/apache-airflow/values.yaml

check-helm: ## Check Helm Release
		helm list -n apache-airflow

sleep: ## Sleep for 60 seconds for pods to get ready
		@sleep 60

port-forward: ## Port forward from local k8s cluster to access locally
		export POD_NAME=$$(kubectl get pods --namespace apache-airflow -l "component=webserver" -o jsonpath="{.items[0].metadata.name}"); \
		kubectl port-forward --namespace apache-airflow $$POD_NAME 8080:8080

deploy: install sleep port-forward ## Deploy the code in  local k8s cluster

upgrade: ## Upgrade the Release
		helm upgrade --install rl-apache-airflow apache-airflow/airflow -n apache-airflow -f .helm/apache-airflow/values.yaml

uninstall: ## Uninstall Release
		helm uninstall rl-apache-airflow -n apache-airflow
		kill $$(lsof -ti:8080)

browse: ## Open the Browser
		open -a "Google Chrome" http://localhost:8080

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
		@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help