# Setup Akeyless Gateway with Nginx Ingress and Cert Manager
This README outlines the steps taken in the setup process of the Akeyless Gateway with Nginx Ingress and Cert Manager, as described in the following files:

### 1. Setup Nginx Ingress (`1-setup-nginx.sh`)
- Adds the `ingress-nginx` repository to Helm.
- Updates the Helm repository to ensure it has the latest charts.
- Installs the `ingress-nginx` chart into the `akeyless` namespace, creating the namespace if it does not exist.
- Waits for the external load balancer IP address to be provisioned for the Nginx controller. This IP address is used to set up DNS entries for the gateway.

### 2. Setup Cert Manager (`2-setup-cert-manager.sh`)
- Adds the `jetstack` repository to Helm for accessing the Cert Manager charts.
- Updates the Helm repository.
- Installs the `cert-manager` chart into the `cert-manager` namespace, with CRDs installation enabled.
- Creates a `lets-encrypt-prod-issuer.yml` file that defines a Let's Encrypt issuer for acquiring certificates.
- Applies the issuer configuration in the `akeyless` namespace.

### 3. Setup Akeyless Gateway (`3-setup-gateway.sh`)
- Adds the `akeyless` repository to Helm for accessing the Akeyless API Gateway charts.
- Updates the Helm repository.
- Installs the `akeyless-api-gateway` chart with custom values from the `values.yaml` file into the `akeyless` namespace.

### 4. Configuration (`values.yaml`)
- Defines various configurations for the Akeyless API Gateway, including:
  - Metrics and telemetry settings.
  - Log forwarding configuration.
  - Horizontal Pod AutoScaler (HPA) settings.
  - Ingress settings for accessing the Akeyless API Gateway.
  - TLS configuration for securing communication.
  - User authentication and authorization settings.
  - Caching and proactive caching settings.
  - Custom agreement links for the login page.
  - Universal Identity settings for token rotation and child token creation.
  - Customer Fragment settings for Zero-Knowledge Encryption.

These steps collectively set up the Akeyless Gateway with Nginx Ingress and Cert Manager in a Kubernetes environment, ensuring secure and scalable access to the gateway.

**This will detail the current configuration in the `values_gateway.yaml` file that is used to install the Akeyless Gateway in a Azure AKS Cluster.**

The `values_gateway.yaml` file serves as a comprehensive configuration template for deploying the Akeyless API Gateway within a Kubernetes environment. It outlines a variety of settings that are crucial for the successful operation and management of the gateway, aligning with the setup steps described above. Key aspects covered in this file include:

- **General Configuration**: Specifies the deployment type (Deployment or DaemonSet), replica count, and container image details. This is not need for change until line 91 block "service:" where we change the type to ClusterIP ( default is LoadBalancer)
  - **Note**: ClusterIP is required for the Akeyless Gateway to be accessible from within the Kubernetes cluster. The Nginx controller will handle the LoadBalancer and expose the gateway to the internet.


- **Ingress and Service Configuration**: Defines how the gateway is exposed outside the Kubernetes cluster, including ingress settings for enabling TLS, specifying hostname rules, and annotations for cert-manager integration.
The ingress block within the `values_gateway.yaml` file is crucial for configuring how the Akeyless API Gateway is exposed outside the Kubernetes cluster. This section primarily focuses on the annotations that enhance the functionality and security of the ingress resource. Here's a detailed explanation of each annotation used:

  - `cert-manager.io/issuer: letsencrypt-prod`: This annotation tells the cert-manager to use the Let's Encrypt production issuer for automatically managing and renewing TLS certificates. It ensures that the communication to the gateway is encrypted and secure.

  - `kubernetes.io/ingress.class: nginx`: Specifies that the ingress resource should be handled by the Nginx Ingress Controller. This is essential for routing external HTTP(S) traffic to the services within the cluster.

  - `nginx.ingress.kubernetes.io/ssl-redirect: "true"`: Forces the redirection of HTTP traffic to HTTPS, enhancing the security by ensuring that all communications are encrypted.

  - `nginx.ingress.kubernetes.io/proxy-connect-timeout: "3600"`, `nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"`, and `nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"`: These annotations configure the timeout settings for the proxy, ensuring that long-running operations (such as large data transfers) do not get prematurely terminated.

  - `nginx.ingress.kubernetes.io/proxy-buffer-size: "8k"` and `nginx.ingress.kubernetes.io/proxy-buffers-number: "4"`: Adjust the buffer size and the number of buffers that Nginx uses for proxying HTTP requests, optimizing performance for different payload sizes.

  - `nginx.ingress.kubernetes.io/client-body-buffer-size: 64k`, `nginx.ingress.kubernetes.io/client-header-buffer-size: 100k`, `nginx.ingress.kubernetes.io/http2-max-header-size: 96k`, and `nginx.ingress.kubernetes.io/large-client-header-buffers: 4 100k`: These annotations are configured to support large client headers and bodies, which is particularly useful for services that require sending large amounts of data in headers or bodies of the requests.

  - These annotations collectively ensure that the ingress resource is properly configured to handle traffic to the Akeyless API Gateway securely and efficiently, leveraging the Nginx Ingress Controller's features to provide robust access control, traffic routing, and encryption.

  - **Note**: These annotations will be used for the other Gateways ( The SRA Bastion and the ZTWA Bastion) as well.

  - The `rules` block within the `values_gateway.yaml` file plays a pivotal role in defining how the Akeyless API Gateway is exposed and accessed from outside the Kubernetes cluster. This block is a part of the ingress configuration and specifies the routing rules for incoming traffic to the gateway services. Each rule within this block is designed to route traffic to a specific service based on the hostname and optionally, the path.

  - Here is a breakdown of the `rules` block and its components:

  - **servicePort**: Specifies the port of the service within the Kubernetes cluster. This port is where the ingress routes the traffic it receives. The service port names like `web`, `hvp`, `legacy-api`, `api`, and `configure-app` correspond to different functionalities within the Akeyless Gateway, such as the web interface, High Volume Proxy, legacy API, new version API, and configuration app, respectively.

  - **hostname**: Defines the external hostname through which the service can be accessed. For instance, `ui-sandbox.akeyless.dev.app.app` for the web interface or `api-v2-sandbox.akeyless.dev.app` for the new version API. These hostnames are crucial for directing external traffic to the correct service within the Kubernetes cluster.

  - **path**: (Optional) Specifies the URL path that must be matched for the rule to apply. This is useful for more granular routing within a service or when hosting multiple services under the same hostname.

  - The `rules` block allows for the configuration of multiple hostnames and paths, directing traffic to different ports of the Akeyless Gateway based on the request's characteristics. This flexibility is key to setting up a robust and accessible API gateway that can handle various types of requests efficiently.

  - By carefully configuring the `rules` block, administrators can ensure that the Akeyless Gateway is securely and effectively exposed to the necessary external traffic, while also leveraging the capabilities of the Nginx Ingress Controller for advanced traffic routing and management.

  - Example configuration snippet from the `values_gateway.yaml` file:
    ```yaml
    rules:
    - servicePort: web
      hostname: "ui-sandbox.akeyless.dev.app"
      path: "/"
    - servicePort: hvp
      hostname: "hvp-sandbox.akeyless.dev.app"
      path: "/"
    - servicePort: legacy-api
      hostname: "api-sandbox.akeyless.dev.app"
      path: "/v1/"
    - servicePort: api
      hostname: "api-v2-sandbox.akeyless.dev.app"
      path: "/v2/"
    - servicePort: configure-app
      hostname: "conf-sandbox.akeyless.dev.app"
      path: "/configure/"
    ```



- **Security and Access Control**: Details around security contexts, service accounts, and permissions. It includes configurations for admin access, allowed access permissions, and restrictions on service access to specific IDs or admin accounts.


  - The `akeylessUserAuth` block within the `values_gateway.yaml` file is crucial for configuring authentication settings for the Akeyless API Gateway. This block allows administrators to set up the initial authentication method and credentials that will be used to secure access to the gateway. Here is a detailed explanation of the configurations available within the `akeylessUserAuth` block:

  - **adminAccessId**: This is a required field where you specify the access ID for the admin user. The access ID can be of different types, including access_key, password, certificate, or cloud identity (e.g., aws_iam, azure_ad, gcp_gce).

  - **adminAccessKey**, **adminPassword**, **adminBase64Certificate**, **adminBase64CertificateKey**, **adminUIDInitToken**: These fields allow you to provide the corresponding credentials based on the type of admin access ID you are using. Only the relevant fields need to be filled based on the chosen authentication method.

  - **Existing Secrets**: For each of the above credentials, there is an option to use a Kubernetes existing secret instead of directly inputting the values in the file. This is a more secure approach as it avoids exposing sensitive information. The keys for these secrets include:
    - `adminAccessIdExistingSecret`
    - `adminAccessKeyExistingSecret`
    - `adminPasswordExistingSecret`
    - `adminBase64CertificateExistingSecret`
    - `adminBase64CertificateKeyExistingSecret`
    - `adminUIDInitTokenExistingSecret`

  - **clusterName** and **initialClusterDisplayName**: These fields are used to specify a unique name for your cluster and a display name, respectively. This is useful for identification purposes when managing multiple clusters.
    - <span style="color:red">**Note**: The clusterName value can not be changed once it is set. Changing it will trigger a redeployment of the gateway with a new clusterName and a unique identity, which **REMOVES** all existing targets, secrets, and authentication methods associated with this Gateway.</span>

  - **configProtectionKeyName**: This optional field allows specifying a key used to encrypt the API Gateway configuration. If left empty, the account’s default key will be used. This key is determined during cluster setup and cannot be modified afterward.

  - **allowedAccessIDs** and **allowedAccessPermissions**: These configurations enable you to define granular access control to the gateway. You can specify allowed access IDs and their corresponding permissions. There is also an option to use an existing secret for allowed access permissions (`allowedAccessPermissionsExistingSecret`).
    - **Note**: The allowedAccessIDs are currently set as the Azure AD Saml Auth Method. This will typically be a **Human User Auth Method** and only for **Gateway Configuration ADMINS**. 


  - **restrictServiceToAccessIds**: This field allows restricting access to the gateway to specific access IDs, enhancing security by limiting who can interact with the gateway.

  - **restrictAccessToAdminAccount**: When set to true, this restricts access to the admin account, ensuring that only authorized users can make changes to the gateway configuration.

  - **useGwForOidc**: This boolean field specifies whether the gateway should be used as an OIDC callback target, enabling integration with OIDC providers for authentication.

  This block is essential for setting up secure and controlled access to the Akeyless API Gateway, ensuring that only authorized users can access and manage the gateway.

- **High Availability and Scaling**: Configures Horizontal Pod AutoScaler (HPA) settings to ensure the gateway scales based on CPU and memory utilization.

- **Customization Options**: Allows for the customization of login page agreement links, metrics exporter configuration for telemetry, log forwarding setup, and TLS configurations for various components of the gateway.

- **Universal Identity and Customer Fragment**: Settings related to token rotation intervals, child token creation, and Zero-Knowledge Encryption configurations.

This file is integral to the setup process outlined in the README, particularly in steps 3 and 4, where the Akeyless Gateway is installed and configured with custom values from the `values.yaml` file. It ensures that the gateway is deployed with the necessary configurations for secure, scalable, and efficient operation within a Kubernetes environment.


The `values_sra.yaml` file contains a comprehensive list of user-supplied values that are essential for configuring the Akeyless Secure Remote Access (SRA) setup. This file is crucial for customizing various aspects of the Akeyless Gateway, SSH Proxy, and Zero Trust Bastion services within a Kubernetes environment. Below is a walkthrough of the key configurations required for setting up the environment, aimed at assisting beginners through the process.



### Key Configurations in `values_sra.yaml`:

1. **USER-SUPPLIED VALUES**: This section lists all the configurations that can be customized by the user.

2. **RDPusernameSubClaim & SSHusernameSubClaim**: These fields are used to specify the claim names that contain the username for RDP and SSH access. If not required, they can be left as `null`.

3. **apiGatewayCert**: This section allows specifying the Kubernetes secret that contains the TLS certificates for the API Gateway. If you're not using custom certificates, leave `tlsCertsSecretName` as `null`.

4. **apiGatewayURL**: The URL of the Akeyless API Gateway. This is pre-configured to `https://rest.akeyless.io`.
    - <span style="color:green">**Note**: This is the 8080 Port that is configured for the Gateway Helm Values file:</span> *api-sandbox.akeyless.dev.app*

5. **clusterName**: A unique name for your cluster, such as `sra-sandbox`, to identify your deployment.

6. **deployment.labels**: Custom labels for the deployment can be added here. If not needed, it can be left as an empty object `{}`.

7. **dockerRepositoryCreds**: Contains the Docker repository credentials encoded in base64. This is essential for pulling the Akeyless images from private repositories.

8. **httpProxySettings**: If your environment requires an HTTP proxy, configure `http_proxy`, `https_proxy`, and `no_proxy` settings here.

9. **privilegedAccess**: This section is critical for configuring access to Akeyless services. It includes `accessID`, `accessKey`, and a list of `allowedAccessIDs` for granular access control.

10. **sshConfig & ztbConfig**: These sections allow configuring the SSH Proxy and Zero Trust Bastion services, including settings for Horizontal Pod Autoscaler (HPA), ingress annotations, and TLS settings.

### Steps to Setup:

1. **Fill in Required Fields**: Start by filling in the required fields such as `clusterName`, `privilegedAccess.accessID`, and `privilegedAccess.accessKey` with your specific values.

2. **Configure TLS Certificates**: If you have custom TLS certificates, specify the secret name in `apiGatewayCert.tlsCertsSecretName`.

3. **Set Proxy Settings**: If behind a corporate proxy, ensure the `httpProxySettings` are correctly set.

4. **Review and Customize**: Go through each section and customize the values as per your requirements. Pay special attention to the `privilegedAccess` and `sshConfig` sections to ensure secure and restricted access.

5. **Apply the Configuration**: Once you have customized the `values_sra.yaml` file, use it to deploy the Akeyless services in your Kubernetes cluster by running the appropriate `helm install` or `helm upgrade` commands.

This walkthrough is designed to help beginners understand and configure the necessary settings in the `values_sra.yaml` file for setting up Akeyless Secure Remote Access in a Kubernetes environment.

The `values_ztwa.yaml` file is pivotal for configuring the Akeyless Zero Trust Web Access (ZTWA) within a Kubernetes environment. This file allows users to customize the deployment to meet their specific requirements for secure and scalable web access. Below is a detailed guide on the key configurations and the steps necessary for setting up the environment.

### Key Configurations in `values_ztwa.yaml`:

1. **USER-SUPPLIED VALUES**: This section encompasses all the configurations that users can customize according to their needs.

2. **HPA (Horizontal Pod Autoscaler)**: Configurations for scaling the dispatcher and web worker pods based on CPU and memory utilization.

3. **deployment.labels**: Custom labels for the deployment can be added here. If not needed, it can be left as an empty object `{}`.

4. **dispatcher**: Contains settings for the dispatcher component, including API Gateway URL, cluster name, and privileged access credentials.

5. **webWorker**: Configurations for the web worker component, including replica count and container specifications.

6. **privilegedAccess**: Critical for configuring access to Akeyless services. It includes `accessID`, `accessKey`, and a list of `allowedAccessIDs` for granular access control.

7. **httpProxySettings**: If your environment requires an HTTP proxy, configure `http_proxy`, `https_proxy`, and `no_proxy` settings here.

8. **ingress**: Settings for Kubernetes ingress, including annotations, hostname, and TLS configuration.

### Steps to Setup:

1. **Fill in Required Fields**: Begin by populating the required fields such as `clusterName`, `privilegedAccess.accessID`, and `privilegedAccess.accessKey` with your specific values.

2. **Configure HPA Settings**: If you wish to enable automatic scaling for dispatcher and web worker components, adjust the HPA settings accordingly.

3. **Set Proxy Settings**: If your environment is behind a corporate proxy, ensure the `httpProxySettings` are correctly set.

4. **Review and Customize**: Go through each section and customize the values as per your requirements. Pay special attention to the `privilegedAccess` and `dispatcher` sections to ensure secure and restricted access.

5. **Apply the Configuration**: Once you have customized the `values_ztwa.yaml` file, use it to deploy the Akeyless Zero Trust Web Access services in your Kubernetes cluster by running the appropriate `helm install` or `helm upgrade` commands.

This guide aims to assist users in understanding and configuring the necessary settings in the `values_ztwa.yaml` file for setting up Akeyless Zero Trust Web Access in a Kubernetes environment.


## Installation Instructions
- Setup Nginx Ingress Controller
- Setup Cert Manager for TLS
- Setup Akeyless Gateway into Kubernetes using helm
