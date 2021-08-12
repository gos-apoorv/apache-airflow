dep: ## Get all dependencies
		helm repo add apache-airflow https://airflow.apache.org
		helm repo update
		#helm dependency update .helm/apache-airflow

install-debug: ## Install Release in helm with debug enabled
		helm install rl-apache-airflow apache-airflow/airflow --namespace apache-airflow --debug
		#helm install rl-apache-airflow .helm/apache-airflow --namespace airflow --debug

upgrade: ## Upgrade the Release
		helm upgrade --install rl-apache-airflow apache-airflow/airflow -n apache-airflow -f .helm/apache-airflow/values.yaml

install: upgrade ## Install Release in helm

uninstall: ## Uninstall Release
		helm uninstall rl-apache-airflow -n apache-airflow
		kill $$(lsof -ti:8080)

check-helm: ## Check Helm Release
		helm list -n apache-airflow

port-forward: ## Port forward from local k8s cluster to access locally
		export POD_NAME=$$(kubectl get pods --namespace apache-airflow -l "component=webserver" -o jsonpath="{.items[0].metadata.name}"); \
		kubectl port-forward --namespace apache-airflow $$POD_NAME 8080:8080

browse: ## Open the Browser
		open -a "Google Chrome" http://localhost:8080

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
		@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help