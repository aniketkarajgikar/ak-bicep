# ak-bicep

Bicep project that deploys a **resource group** and a **storage account** across `dev`, `test` and `prod`.

## Structure

```
.github/workflows/
  deploy-infra.yml          # PR: lint + what-if | main: dev -> test -> prod
  _deploy-environment.yml   # reusable per-environment deploy job
infra/
  main.bicep                # subscription-scope entry point
  bicepconfig.json          # linter rules
  modules/
    resource-group/main.bicep
    storage-account/main.bicep
  parameters/
    dev.bicepparam
    test.bicepparam
    prod.bicepparam
```

## Naming

- Resource group: `rg-<workload>-<env>-<region>`
- Storage account: `st<workload><env><region><unique>` (max 24 chars)

## Security defaults (storage)

TLS 1.2, HTTPS only, no public blob access, shared-key access disabled (Entra ID auth only),
firewall default-deny, infrastructure encryption, blob/container soft delete.

## Local usage

```powershell
az bicep lint --file infra/main.bicep
az deployment sub what-if --location eastus2 --template-file infra/main.bicep --parameters infra/parameters/dev.bicepparam
az deployment sub create  --location eastus2 --template-file infra/main.bicep --parameters infra/parameters/dev.bicepparam
```

## GitHub setup (one-time)

1. Create an Entra app registration / managed identity per environment with **federated credentials** for
   the GitHub repo (subject: `repo:<org>/<repo>:environment:<env>` and `...:environment:<env>-readonly`, plus `pull_request` if desired).
2. Grant it **Contributor** (+ **User Access Administrator** only if you add role assignments) at the subscription scope
   (Reader for the `-readonly` identity; what-if needs Reader on the subscription).
3. Create GitHub Environments `dev`, `test`, `prod`, `dev-readonly`, `test-readonly`, `prod-readonly`.
   Add required reviewers on `test`/`prod`.
4. In each Environment, add secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.
5. Enable branch protection on `main` requiring the `Lint & Build` check.

## Extending

Add new modules under `infra/modules/<name>/main.bicep`, reference them from `main.bicep`.
When sharing across teams, publish modules to an Azure Container Registry / Bicep registry.
