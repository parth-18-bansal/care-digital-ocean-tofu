import json, os
from dotenv import dotenv_values

envs = dotenv_values(".env")
env_list = []

for k, v in envs.items():
    env_list.append({
        "key": k,
        "value": v,
        "type": "GENERAL"
    })

print(json.dumps({"env": json.dumps(env_list)}))
