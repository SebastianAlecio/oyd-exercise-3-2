# oyd-exercise-3-2 — Lambda Currency Converter

Módulo Terraform reutilizable que provisiona una función AWS Lambda (Node.js 22, arm64) detrás de un API Gateway HTTP API. Expone `GET /rates` y `POST /convert`.

## Estructura

```
app/                       # Handler de Lambda (function.zip se construye localmente; está en .gitignore)
infra/
  modules/compute_lambda/  # Módulo reutilizable: 9 recursos
  envs/dev/dev.tfvars      # Valores del entorno dev
  evidence/function.txt    # Capturado después de terraform apply
.github/workflows/         # Pipeline de PR: build del zip + terraform plan
```

## Despliegue

```bash
cd app/ && zip function.zip index.js && cd ..
cd infra/
terraform init
terraform apply -var-file=envs/dev/dev.tfvars
```

Una vez aplicado, obtén la URL de invocación con `terraform output -raw invoke_url`.

## Pruebas

```bash
INVOKE_URL=$(cd infra && terraform output -raw invoke_url)
curl ${INVOKE_URL}rates
curl -X POST ${INVOKE_URL}convert \
  -H 'Content-Type: application/json' \
  -d '{"from":"USD","to":"GTQ","amount":100}'
```

## Limpieza

```bash
cd infra/
terraform destroy -var-file=envs/dev/dev.tfvars
```

## CI

`.github/workflows/terraform-ci.yml` se ejecuta en cada PR hacia `main`:

1. **build** — instala Node 22, construye `app/function.zip` y lo sube como artifact.
2. **terraform** (necesita `build`) — descarga el zip y luego corre `fmt -check`, `init -backend=false`, `validate` y `plan -var-file=envs/dev/dev.tfvars`. La salida del plan se publica como comentario colapsable en el PR.

Las credenciales de AWS provienen exclusivamente de los secrets `AWS_ACCESS_KEY_ID` y `AWS_SECRET_ACCESS_KEY` del repositorio.

## Evidence

`infra/evidence/function.txt` (salida de `aws lambda get-function`):

```json
{
    "FunctionArn": "arn:aws:lambda:us-east-1:544341949288:function:currency-converter-dev",
    "State": "Active",
    "Arch": [
        "arm64"
    ]
}
```

### Respuestas de los endpoints

```text
$ curl https://e2qqw5y8yf.execute-api.us-east-1.amazonaws.com/rates
{"rates":{"USD":1,"EUR":0.92,"GBP":0.79,"JPY":149.5,"GTQ":7.78}}

$ curl -X POST https://e2qqw5y8yf.execute-api.us-east-1.amazonaws.com/convert \
    -H 'Content-Type: application/json' \
    -d '{"from":"USD","to":"GTQ","amount":100}'
{"from":"USD","to":"GTQ","amount":100,"result":778}
```

> La URL del API Gateway de arriba pertenecía al stack de dev usado para capturar esta evidencia. Los recursos ya fueron destruidos; volver a correr `terraform apply` generará una URL nueva.
