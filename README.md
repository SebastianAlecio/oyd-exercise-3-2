# oyd-exercise-3-2 — Lambda Currency Converter

Reusable Terraform module that provisions an AWS Lambda function (Node.js 22, arm64) behind an API Gateway HTTP API. Exposes `GET /rates` and `POST /convert`.

## Layout

```
app/                       # Lambda handler (function.zip is built locally; gitignored)
infra/
  modules/compute_lambda/  # reusable module: 9 resources
  envs/dev/dev.tfvars      # dev environment values
  evidence/function.txt    # captured after terraform apply
.github/workflows/         # PR pipeline: build zip + terraform plan
```

## Deploy

```bash
cd app/ && zip function.zip index.js && cd ..
cd infra/
terraform init
terraform apply -var-file=envs/dev/dev.tfvars
```

Once applied, retrieve the invoke URL with `terraform output -raw invoke_url`.

## Test

```bash
INVOKE_URL=$(cd infra && terraform output -raw invoke_url)
curl ${INVOKE_URL}rates
curl -X POST ${INVOKE_URL}convert \
  -H 'Content-Type: application/json' \
  -d '{"from":"USD","to":"GTQ","amount":100}'
```

## Tear down

```bash
cd infra/
terraform destroy -var-file=envs/dev/dev.tfvars
```

## CI

`.github/workflows/terraform-ci.yml` runs on every PR to `main`:

1. **build** — installs Node 22, builds `app/function.zip`, uploads it as an artifact.
2. **terraform** (needs `build`) — downloads the zip, then runs `fmt -check`, `init -backend=false`, `validate`, and `plan -var-file=envs/dev/dev.tfvars`. The plan output is posted back to the PR as a collapsible comment.

AWS credentials come exclusively from the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` repository secrets.

## Evidence

`infra/evidence/function.txt` (output of `aws lambda get-function`):

```json
{
    "FunctionArn": "arn:aws:lambda:us-east-1:544341949288:function:currency-converter-dev",
    "State": "Active",
    "Arch": [
        "arm64"
    ]
}
```

### Endpoint responses

```text
$ curl https://e2qqw5y8yf.execute-api.us-east-1.amazonaws.com/rates
{"rates":{"USD":1,"EUR":0.92,"GBP":0.79,"JPY":149.5,"GTQ":7.78}}

$ curl -X POST https://e2qqw5y8yf.execute-api.us-east-1.amazonaws.com/convert \
    -H 'Content-Type: application/json' \
    -d '{"from":"USD","to":"GTQ","amount":100}'
{"from":"USD","to":"GTQ","amount":100,"result":778}
```

> The API Gateway URL above belonged to the dev stack used to capture this evidence. Resources have been destroyed; re-running `terraform apply` will produce a fresh URL.
