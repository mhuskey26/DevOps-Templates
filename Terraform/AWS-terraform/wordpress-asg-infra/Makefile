# Makefile for WordPress ASG Terraform Deployment

.PHONY: help init plan apply destroy validate fmt clean lint

help:
	@echo "WordPress ASG Terraform Makefile"
	@echo "================================"
	@echo ""
	@echo "Available targets:"
	@echo "  init       - Initialize Terraform (downloads providers)"
	@echo "  validate   - Validate Terraform configuration"
	@echo "  fmt        - Format Terraform code"
	@echo "  plan       - Create and display execution plan"
	@echo "  apply      - Apply configuration changes"
	@echo "  destroy    - Destroy all resources (DESTRUCTIVE)"
	@echo "  clean      - Clean Terraform temporary files"
	@echo "  lint       - Run terraform validation and format check"
	@echo "  output     - Display Terraform outputs"
	@echo "  state      - Show Terraform state"
	@echo "  cost       - Estimate infrastructure costs (requires terraform-cost-estimation)"
	@echo ""

init:
	terraform init

validate:
	terraform validate

fmt:
	terraform fmt -recursive .

plan:
	terraform plan -out=tfplan

apply: plan
	terraform apply tfplan
	rm tfplan

destroy:
	@echo "WARNING: This will destroy all resources!"
	@echo "Press Ctrl+C to cancel, or wait 5 seconds to confirm..."
	@sleep 5
	terraform destroy

clean:
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f tfplan
	rm -f *.tfstate*

lint: validate fmt
	@echo "Lint check complete!"

output:
	terraform output

state:
	terraform show

cost:
	@if command -v terraform-cost-estimation &> /dev/null; then \
		terraform plan -json | terraform-cost-estimation; \
	else \
		echo "terraform-cost-estimation not installed. Install with: npm install -g terraform-cost-estimation"; \
	fi

# Advanced targets for CI/CD
.PHONY: ci-init ci-plan ci-apply ci-destroy

ci-init:
	terraform init -backend=true -input=false

ci-plan:
	terraform plan -out=tfplan -input=false

ci-apply:
	terraform apply -input=false tfplan

ci-destroy:
	terraform destroy -auto-approve -input=false
