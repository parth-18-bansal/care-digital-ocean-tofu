First go to the "API" section in the Digital Ocean Account. And generate a token. This token is used by the provider for authentication to the digital ocean api for your account. Then run this command in the shell.

export DIGITALOCEAN_TOKEN="your-actual-token"

Second go to the "spaces object storage" then to the "Access key" tab. Then create the access key and secret key with full access permision. These are used by the provider other components to make different api calls to the space bucket.Then run this in the shell.

export TF_VAR_spaces_access_key="your-access-key"
export TF_VAR_spaces_secret_key="your-secret-key"

Third, install OpenTofu, a tool for managing infrastructure as code. To do this, visit the official OpenTofu installation page and follow the instructions for your operating system: OpenTofu Installation Guide.

After installing OpenTofu, manually create a Space bucket with name care-tofu-state.

export AWS_ACCESS_KEY_ID="your-spaces-access-key"
export AWS_SECRET_ACCESS_KEY="your-spaces-secret-key"

Then run the make

