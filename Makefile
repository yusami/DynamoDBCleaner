.PHONY: help all run clean
.DEFAULT_GOAL := run

help: ## Show help text
	@echo "Description:"
	@echo "  Quick build tool"
	@echo ""
	@echo "Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

all: clean install run ## Install gems and run the script

install: ## Install gems
	echo "Installing gems..."
	bundle config set --local path 'vendor/bundle'
	bundle config set --local without 'development test'
	bundle install

run: ## Run the ruby script (default)
	ruby bulk_cleaner.rb

clean: ## Delete the existing gems
	rm -rf ./vendor

