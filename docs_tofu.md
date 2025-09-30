# DigitalOcean

In this guide, we'll walk you through deploying the **Care** on **Digital Ocean** through **Tofu**.

---

## Prerequisites

- A DigitalOcean account ([Sign up here](https://www.digitalocean.com)).
- A fork of the Care backend and frontend repositories.
- A registered domain name (optional but recommended).
- Basic familiarity with DigitalOcean's App Platform and Spaces.

---


## Step 1: Install and Setup the Tofu in your System

### 1.1 Generate a Digital Ocean API Token

- First go to the **API** section in the [DigitalOcean account](https://cloud.digitalocean.com/account/api/tokens).
- Generate a Personal Access Token. This token is used by the provider for authentication to the digital ocean api for your account.
- Export the token to your system's shell:

```bash 
export DIGITALOCEAN_TOKEN="your-actual-token"
```

### 1.2 Create Spaces Access & Secret Keys

- Navigate to Spaces Object Storage in the DigitalOcean dashboard.
- Go to the Access Keys tab and create a key with Full Access.
- Export the access credentials:

```bash
export TF_VAR_spaces_access_key="your-access-key"
export TF_VAR_spaces_secret_key="your-secret-key"
```
These credentials are used by the provider and other resources to interact with Spaces buckets.

### 1.3 Install OpenTofu
Visit the [OpenTofu Installation Guide](https://opentofu.org/docs/intro/install/) and follow the instructions for your OS.

### 1.4 Create a Spaces Bucket for Remote State
Manually create a Spaces bucket named:
```perl
care-tofu-state
```

Then export your access credentials again (required by OpenTofu backend):
```bash
export AWS_ACCESS_KEY_ID="your-spaces-access-key"
export AWS_SECRET_ACCESS_KEY="your-spaces-secret-key"
```

---

## step 2: write the provider.tf
This file tell the opentofu to interact with the digital ocean cloud api. And also here we define the credentials for your account. So that open tofu can create resources in your account.

<img width="1385" height="535" alt="image" src="https://github.com/user-attachments/assets/4d692512-b327-4af4-a649-7412952463e5" />

## step 3: write the init.tf
This file defines where the tfstate file will get store for your infrastructure

<img width="964" height="364" alt="image" src="https://github.com/user-attachments/assets/068eab6b-2aaa-4bbe-9d96-c586bd241086" />

## step 4: create variable.tf and dev.tfvars files
We define all the variables in the variables.tf file and store the values of these variables in the environments/dev.tfvars file.

## step 5: next we will create the postgres database
- create the database.tf file
- write the terraform script in it like this:

  <img width="900" height="353" alt="image" src="https://github.com/user-attachments/assets/8ef82ff3-dd86-4bdd-9947-529749a1960b" />

- Then in variables.tf define the variables

  <img width="1054" height="740" alt="image" src="https://github.com/user-attachments/assets/9e178db6-8413-405c-8465-d77f031b936a" />

- then in dev.tfvars define the values of them

  <img width="716" height="177" alt="image" src="https://github.com/user-attachments/assets/a03c2959-e285-42c6-98b9-57da6c097a91" />

## step 6: now we will define the spaces(bucket)
- create the spaces.tf file
- write the terraform script in it:

<img width="901" height="258" alt="image" src="https://github.com/user-attachments/assets/11343954-de9c-4202-9f57-fb63cc092acc" />

- then in variables.tf define the variables related to it

  <img width="529" height="381" alt="image" src="https://github.com/user-attachments/assets/0abd74b2-444c-4b14-a74f-9616b17bd05f" />

- then in dev.tfvars file define the values of these variables

  <img width="570" height="132" alt="image" src="https://github.com/user-attachments/assets/8b7c6ad1-6f67-4acd-b995-ece703986f20" />


## step 7: Cloudfront
- create a cdn.tf file
- write the terraform script for it:

<img width="945" height="224" alt="image" src="https://github.com/user-attachments/assets/1ad8e444-af03-4748-85a9-4fbba50d6739" />

This is the cloudfront for caching the data, we will put this in front of the bucket.

## step 8: Backend app
- create the backend_app.tf
- so in this file we will define backend app, in backend app we have four components: redis, celery-worker, celery-beat, dajango app. so here we will define four services in it.







  




