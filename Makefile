.PHONY: init prep plan deploy destroy lint

all: init plan deploy

init:
	@tofu init

plan: prep
	@tofu plan -var-file=environments/$(ENV).tfvars

deploy: prep
	@tofu apply -var-file=environments/$(ENV).tfvars -auto-approve

destroy: prep
	@tofu destroy -var-file=environments/$(ENV).tfvars

lint:
	@tofu fmt -write=true -recursive
