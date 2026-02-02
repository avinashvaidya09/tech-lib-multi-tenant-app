# Getting Started

Welcome to CAP project to demostrate multitenancy design.

It contains these folders and files, following our recommended project layout:

File or Folder | Purpose
---------|----------
`app/` | Content for UI frontends goes here
`db/` | Your domain models and data go here
`srv/` | Your service models and code go here
`package.json` | Project metadata and configuration
`readme.md` | This getting started guide
`xs-security.json` | Application security descriptor

## Prerequisites:
- Node.js 20+ and npm
- Cloud Foundry CLI (`cf`) and MultiApps (`mbt`)
- UI5 CLI (`npm i -g @ui5/cli`) optional for local UI builds

## Project Set up 

- Clone the repo

- You can enhance the entity model, for example, a [db/schema.cds](db/schema.cds).

- Install dependencies
```bash
npm install
```

## Local build and deploy

- Run the below command

```bash
cds watch
```

- CAP backend (OData at `http://localhost:4004/service/tech_lib_multi_tenant_app/`):

- API samples

```bash
1. http://localhost:4004/service/tech_lib_multi_tenant_app/Books?$expand=bookAuthors

2. http://localhost:4004/service/tech_lib_multi_tenant_app/Books(ID='5ebc5455-f2d6-472e-af6f-3b68e544b6ee',IsActiveEntity=true)?$expand=bookAuthors($expand=author)
```

## Deploy single tenant app on BTP

- Log in to target your org/space:

```bash
cf login
```

- Build MTAR:

```bash
mbt build
```

- Deploy to Cloud Foundry:

```bash
cf deploy mta_archives/tech-lib-multi-tenant-app_*.mtar
```

- After deployment, open the approuter route from `cf apps`. If authentication is enabled, ensure your user has the required XSUAA role (e.g., `LibraryUser`).


## Learn More

Learn more at https://cap.cloud.sap/docs/get-started/.
