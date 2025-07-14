#!/bin/bash
echo "env_vars = {" > env.auto.tfvars
while IFS='=' read -r key value; do
  [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
  echo "  $key = \"$value\"" >> env.auto.tfvars
done < .env
echo "}" >> env.auto.tfvars
