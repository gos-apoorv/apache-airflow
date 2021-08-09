dep: ## Get all dependencies
		helm dependency update .helm/apache-airflow

install: ## Install Release in helm
		helm install rl-apache-airflow .helm/apache-airflow

uninstall: ## Uninstall Release
		helm uninstall rl-apache-airflow
		kill $$(lsof -ti:8080)

check-helm: ## Check Helm Release
		helm list

port-forward: ## Port forward from local k8s cluster to access locally
		export POD_NAME=$$(kubectl get pods --namespace default -l "component=web,app=airflow" -o jsonpath="{.items[0].metadata.name}"); \
		kubectl port-forward --namespace default $$POD_NAME 8080:8080

browse: ## Open the Browser
		open -a "Google Chrome" http://localhost:8080

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
		@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help