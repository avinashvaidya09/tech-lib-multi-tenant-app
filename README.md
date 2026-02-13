# Getting Started

Welcome to CAP project to demostrate multitenancy and SaaS extensibility.

It contains these folders and files, following CAPs recommended project layout:

File or Folder | Purpose
---------|----------
`app/` | Content for UI frontends goes here
`db/` | Your domain models and data go here
`srv/` | Your service models and code go here
`package.json` | Project metadata and configuration
`readme.md` | This getting started guide
`xs-security.json` | Application security descriptor

## Prerequisites:
- VSCode or BAS
- Node.js 20+ and npm
- Cloud Foundry CLI (`cf`) and MultiApps (`mbt`)


## What is Multitenancy?

Before jumping into the code, I would like to briefly touch the concept of multitenant and it's architecture.

Multitenancy involves two main perspectives

1. **Provider:** Provider is an global account owner who offers SaaS solutions to its consumers.
2. **Subscriber:** A subscriber of the application provider. It can be a customer, a department or organizational unit. Subscriber users consume the application.

Important point here is that - the provider owns the global account and consumers subaccounts must be in the same global account and region.

In multitenant architecture - 

1. A single instance of the application and server resources serve multiple customers/tenants

2. This optimizes the compute resource usage as all subscribers are pointing to the same instance of the application

3. Data in the database is kept separate based on tenant specific schema ensuring data privacy

The below diagram gives a simple representation of how multitenant applications are different from single tenant

![Single Tenant vs Multi Tenant](/assets/images/single_vs_multi_tenant.png)


## How you can achieve multi tenancy on SAP BTP Cloud Foundry Runtime

In this section, I will explain three perspectives 

1. What happens when a provider deploys application on the provider subaccount

2. What happens when a subscriber subscribes the application in the subscriber subaccount

3. What happens when customer open the application using subscriber specific URL

Let us go through the above points in detail

### When provider deploys application on the provider subaccount

The diagram below outlines the key components and steps involved when deploying a multitenant application on the SAP BTP Cloud Foundry runtime

![Provider Subaccount Perspective](/assets/images/provider_subaccount_perspective.png)

1. Provider packages and deploys the MTAR: Developer builds the CAP project (srv + UI) and deploy it to the provider Cloud Foundry space

2. CF deploy creates the runtime apps: The deployment pushes your CAP application (srv) and App Router as CF apps with routes

3. CF deploy provisions platform services: It also creates/binds the XSUAA instance (tenant mode shared) for authentication and a Service Manager instance to orchestrate tenant database provisioning

4. MTX sidecar is deployed alongside srv: The MTX sidecar microservice is pushed as a separate CF app to handle (subscription/onboarding/offboarding) tenant lifecycle operations

5. SaaS registry is configured to call MTX: The SaaS provisioning service instance is created with callback URLs (onSubscription/getDependencies) that point to the MTX sidecar endpoints

6. Technical tenant t0 is prepared for multitenancy metadata: MTX initializes a technical persistence area (often referred to as t0) to store tenant registry/runtime metadata (like your tenant records)

### When subscriber subscribes the application in the subscriber subaccount

The diagram below outlines the key components and steps involved when a subscriber subscribes to a multitenant application

![Subscriber Subaccount Perspective](/assets/images/subscriber_subaccount_perspective.png)

1. Subscriber initiates subscription: The subscriber subaccount subscribes to the provider’s SaaS application, which triggers the SaaS provisioning service (SaaS Registry)

2. SaaS Registry calls MTX callbacks: SaaS Registry calls the MTX sidecar’s getDependencies endpoint (if there are any dependencies to be installed), then triggers onSubscription to start tenant onboarding

3. MTX registers the tenant in t0: MTX writes/updates tenant registry metadata in the technical tenant t0 (for example, tenant entry and subscription context)

4. MTX requests tenant resources via Service Manager: MTX calls Service Manager to provision the tenant’s database artifacts — typically a dedicated HDI container/schema for that tenant plus a service binding

5. Deployment Service deploys the data model: MTX invokes the Deployment Service + Model Provider to deploy the CAP model into the newly created tenant schema/container

6. Tenant URL is returned to SaaS Registry: MTX generates/returns the subscriber tenant URL, and SaaS Registry stores it and completes the subscription so the tenant can access the app using that URL


**Note:** Map the subscriber hostname in the app router routes in provider sub account space before accesssing the subscriber specific application url

### What happens when customer opens subscriber specific application URL

The diagram below outlines the key components and steps involved when a user opens the subscriber specific application URL

![Multitenancy User Flow](/assets/images/multitenancy-request-flow.png)

1. User opens the subscriber URL: A subscriber user accesses the application using the subscriber-specific tenant URL, which maps to the provider’s App Router route

2. App Router derives tenant from the host: App Router inspects the incoming request host/subdomain and determines the tenant identifier associated with that subscriber

3. App Router initiates authentication with XSUAA: Because the route is protected, App Router redirects the browser to XSUAA (tenant mode shared) to start the OAuth authorization-code flow

4. XSUAA delegates login to the subscriber’s IdP: XSUAA uses the IdP trust configured in the subscriber subaccount (for example, Okta/IAS) to authenticate the user, then returns an authorization code to App Router’s callback

5. App Router exchanges code for JWT: App Router calls XSUAA’s token endpoint to exchange the authorization code for a JWT access token, then forwards requests to the CAP backend with that token

6. CAP resolves tenant from JWT and queries tenant DB: The CAP application reads the tenant context from the JWT, resolves the tenant-specific DB connection/binding (via the MTX layer and Service Manager), and runs the DB query against that tenant’s schema/container

### Now as we know what is multitenancy and the key components, let us understand 

1. How to make your application multi tenant
2. Test it on local
3. Deploy on BTP and test

## Adding Multitenancy and testing on local

- Enable multitenancy

```bash
cds add multitenancy
```

- The main component to enable multitenancy is MTX microservice. MTX stands for - Multitenancy, Toggle (features) and Extensibility

- The above command makes below changes in the project:
	- [package.json](package.json):
		- Adds `@sap/cds-mtxs` and enables multitenancy via `cds.requires` (for production and a local profile like `with-mtx-sidecar`)
        - Adds `multitenancy:true` for production
		- Significance: CAP runs each request in a tenant context; mocked users help emulate tenants locally without XSUAA
	- [mta.yaml](mta.yaml):
		- Adds an MTX sidecar module (provides `mtx-api`) and wires approuter and SaaS provisioning callbacks
		- Sets approuter destinations to reach the MTX; 
        - Sets tenant host pattern in the app router module so that requests run in the tenant context
            ```bash
            TENANT_HOST_PATTERN: "^(.*)-${default-uri}"
            ```
        - Changes `xsuaa` tenant mode from `dedicated` to `shared`
        - Adds `service-manager` for tenant isolation
        - Adds `saas-registry` service used for onboarding/subscription on BTP
		- Significance: Required for SaaS onboarding and per-tenant data provisioning in Cloud Foundry
	- [xs-security.json](xs-security.json):
		- Added `mtcallback` scope
		- Significance: Governs authorization and multi-tenant mode in production
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

## Project Set up 

- Clone the repo.

- You can enhance the entity model, for example, a [db/schema.cds](db/schema.cds)

- Install dependencies
```bash
npm install
```

## Local build and deploy

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
6) Open localhost in incognito mode - `http://localhost:4004`
    - login with `bob`
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
2. Log in to your SAP BTP provider subaccount and ensure you have the necessary permissions to deploy applications
3. Open terminal and set up your Cloud Foundry space and organization 

### Steps to deploy application in provider account

1. **Build the MTA Archive**
   Run the following command to build the Multi-Target Application (MTA) archive:
   ```bash
   mbt build
   ```
   This will generate an `.mtar` file in the `mta_archives` directory

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
   Check the status of the deployed application and ensure it is in the `STARTED` state

4. **Subscribe to the multi tenant application**
   - Once the application is successfully published to the `saas-registry`, you will be able to see the application in the `Service Marketplace` section as shown in the below screenshot

   ![Saas Registry](/assets/images/service-marketplace.png)

   - To subscribe to the SaaS application, go to - `Instances and Subscriptions` - `Create`.
   - In the drop down, you will see application `Technical Library`. Select `default` plan. Click `Create`.
   - Once the application is successfully subscribed you will see the application in `Subscriptions` as shown in below screenshot

   ![App Subscription](/assets/images/app-subscription.png)

   - Go to `Security` - `Role Collections` - Create a new role collection `<name of your choice>` - Assign roles - `LibraryAdminUser`
   - Assign this role collection to your user in the subscriber tenant

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
	cf map-route tlar cfapps.<region>.hana.ondemand.com --hostname subscriber1-btp-usa-sandbox-123456789-demo-tlar
	```

6. **Test the Application**
   - Access the application using tenant specific URL. If all is well, you should see application list page as shown below

   ![Application](/assets/images/app_landing_page.png)

   - Verify that the application works as expected for the subscriber tenant
   - Make changes by editing any record and see if the changes are persisted in the tenant specific schema.
   - Go to provider subaccount, you will see a new schema / HDI container gets created for each subscriber.

7. **Subscribe to the application from another tenant by repeating the steps 4 and 5**

### Troubleshooting
- If the deployment fails, check the logs using:
  ```bash
  cf logs <app-name> --recent
  ```
- Ensure all required services are bound to the application and properly configured in the `xs-security.json`.


## References

1. https://cap.cloud.sap/docs/get-started/
2. https://cap.cloud.sap/docs/guides/multitenancy/#enable-multitenancy
3. https://help.sap.com/docs/btp/sap-business-technology-platform/developing-multitenant-applications-in-cloud-foundry-environment 