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

## What is Multi tenancy?


## Adding Multitenancy and testing on local

- Enable multitenancy

```bash
cds add multitenancy
```

- The above command makes below changes in the project:
	- [package.json](package.json):
		- Adds `@sap/cds-mtxs` and enables multitenancy via `cds.requires` (for production and a local profile like `with-mtx-sidecar`).
        - Adds `multitenancy:true` for production
		- Significance: CAP runs each request in a tenant context; mocked users help emulate tenants locally without XSUAA.
	- [mta.yaml](mta.yaml):
		- Adds an MTX sidecar module (provides `mtx-api`) and wires approuter and SaaS provisioning callbacks.
		- Sets approuter destinations to reach the MTX; 
        - Sets tenant host pattern in the app router module so that requests run in the tenant context
            ```bash
            TENANT_HOST_PATTERN: "^(.*)-${default-uri}"
            ```
        - Changes `xsuaa` tenant mode from `dedicated` to `shared`
        - Adds `service-manager` for tenant isolation.
        - Adds `saas-registry` service used for onboarding/subscription on BTP.
		- Significance: Required for SaaS onboarding and per-tenant data provisioning in Cloud Foundry.
	- [xs-security.json](xs-security.json):
		- Added `mtcallback` scope
		- Significance: Governs authorization and multi-tenant mode in production.
    - [xs-app.json](/app/router/xs-app.json): Below route is added
        ```bash
            {
                "source": "^/-/cds/.*",
                "destination": "mtx-api",
                "authenticationType": "none"
            }
        ```
    - Creates a mtx/sidecar project with [package.json](/mtx/sidecar/package.json)

- Test locally with two tenants

    1) Add mock users mapped to tenants (local only)

	- In [package.json](package.json) under `cds.requires.auth.[development].users` add, for example:

	```json
	{
		"bob": { "tenant": "t1", "scopes": ["libraryuser", "libraryadminuser"] },
		"john": { "tenant": "t2", "scopes": ["libraryuser"] }
	}
	```

	2) Start MTX sidecar (default: port 4005)

	```bash
	cds watch mtx/sidecar
	```

	3) Start CAP backend with MTX (default: port 4004)

	```bash
	cds watch --with-mtx
	```

	4) Subscribe tenants (use Basic auth expected by the sidecar)

	```bash
	cds subscribe t1 --to http://localhost:4005 -u yves:
	cds subscribe t2 --to http://localhost:4005 -u yves:
	```

    This will create 2 database tenants as you will see in logs of `cds watch mtx/sidecar` terminal

    ```bash
    /> successfully deployed to db-t1.sqlite...
    ...
    ...
    /> successfully deployed to db-t2.sqlite 
    ...
    ```

	5) (If needed) Upgrade tenants to create tables

	```bash
	# Use either of the following depending on your cds version
	cds upgrade t1
	cds upgrade t2
	```

	6) Open localhost in incognito mode - `http://localhost:4004` and login with `bob`

        - Delete a book `Design Patterns`

        - Open another browser and login with `john`

        - You will still see the book - `Design Patterns`

        - This is because bob and john are using data from different tenants

**If you have reached till this point, you have successfully enabled multitenancy in your CAP project and tested it locally.**

## Deploying the Multi-Tenant Application on SAP BTP

Follow these steps to deploy the multi-tenant application on SAP Business Technology Platform (BTP):

### Prerequisites
1. Ensure you have the following tools installed:
   - [Cloud Foundry CLI](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html)
   - [MultiApps CF CLI Plugin](https://github.com/cloudfoundry-incubator/multiapps-cli-plugin)
   - Node.js (compatible version as per the project requirements)
   - MBT (Multi-Target Application Build Tool)
2. Log in to your SAP BTP provider subaccount and ensure you have the necessary permissions to deploy applications.
3. Open terminal and set up your Cloud Foundry space and organization 

### Steps to deploy application in provider account

1. **Build the MTA Archive**
   Run the following command to build the Multi-Target Application (MTA) archive:
   ```bash
   mbt build
   ```
   This will generate an `.mtar` file in the `mta_archives` directory.

2. **Deploy the MTA Archive**
   Use the Cloud Foundry CLI to deploy the generated `.mtar` file:
   ```bash
   cf deploy mta_archives/tech-lib-multi-tenant-app_1.0.0.mtar
   ```

3. **Verify the Deployment**
   After the deployment is complete, verify that the application is running:
   ```bash
   cf apps
   ```
   Check the status of the deployed application and ensure it is in the `STARTED` state.

4. **Subscribe to the multi tenant application**
   - Once the application is successfully published to the `saas-registry`, you will be able to see the application in the `Service Marketplace` section as shown in the below screenshot
   ![Saas Registry](/assets/images/service-marketplace.png)
   - To subscribe to the SaaS application, go to - `Instances and Subscriptions` - `Create`.
   - In the drop down, you will see application `Technical Library`. Select `default` plan. Click `Create`.
   - Once the application is successfully subscribed you will see the application in `Subscriptions` as shown in below screenshot
   ![App Subscription](/assets/images/app-subscription.png)
   - Go to `Security` - `Role Collections` - Create a new role collection `<name of your choice>` - Assign roles - `LibraryAdminUser`
   - Assign this role collection to your user in the subscriber tenant.

5. **Go to Provider sub account**
	- Open the dev space. Go to `Routes`
	- Here, you have to add a new route of the subscriber subaccount - `Create Route`
	- Select the `Domain`.
	- Select the `Host Name` (This will be the `subscriber subdomain` + `saas app name`)
	- Map this newly created route with the app router application.

	- You can do the above steps by `cf` command as well as shown below
	```bash
	cf map-route ‹app› ‹paasDomain› --hostname ‹subscriberSubdomain›-‹saasAppName› 

	example:
	cf map-route tlar cfapps.<region>.hana.ondemand.com --hostname subscriber1-btp-america-sandbox-ggbtlvwv-demo-tlar
	```

6. **Test the Application**
   - Access the application URL provided.
   - Verify that the application works as expected for the subscriber tenant.
   - If you see in the provider subaccount, you will see a new schema / HDI container gets created for each subscriber.

### Troubleshooting
- If the deployment fails, check the logs using:
  ```bash
  cf logs <app-name> --recent
  ```
- Ensure all required services are bound to the application and properly configured in the `xs-security.json`.


## References

1. https://cap.cloud.sap/docs/get-started/
2. https://cap.cloud.sap/docs/guides/multitenancy/#enable-multitenancy
