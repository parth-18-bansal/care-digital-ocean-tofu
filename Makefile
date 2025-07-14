.PHONY: init prep plan deploy destroy lint

init:
	@tofu init

plan: prep
	@tofu plan -var-file=environments/$(ENV).tfvars

deploy: prep
	@tofu apply -var-file=environments/$(ENV).tfvars -auto-approve
