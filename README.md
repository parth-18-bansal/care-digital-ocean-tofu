## 1. Generate a Digital Ocean API Token
1. First go to the **API** section in the [DigitalOcean account](https://cloud.digitalocean.com/account/api/tokens).
2. Generate a Personal Access Token. This token is used by the provider for authentication to the digital ocean api for your account.
3. Export the token to your shell:

```bash 
export DIGITALOCEAN_TOKEN="your-actual-token"
```

## 2. Create Spaces Access & Secret Keys
1. Navigate to Spaces Object Storage in the DigitalOcean dashboard.
2. Go to the Access Keys tab and create a key with Full Access.
3. Export the access credentials:

```bash
export TF_VAR_spaces_access_key="your-access-key"
export TF_VAR_spaces_secret_key="your-secret-key"
```
These credentials are used by the provider and other resources to interact with Spaces buckets.

## 3. Install OpenTofu
Visit the [OpenTofu Installation Guide](https://opentofu.org/docs/intro/install/) and follow the instructions for your OS.

## 4. Create a Spaces Bucket for Remote State
Manually create a Spaces bucket named:
```perl
care-tofu-state
```

Then export your access credentials again (required by OpenTofu backend):
```bash
export AWS_ACCESS_KEY_ID="your-spaces-access-key"
export AWS_SECRET_ACCESS_KEY="your-spaces-secret-key"
```

## 5. Run the Project
Finally, run:
```bash
make
```
This will initialize and apply your infrastructure using OpenTofu.

