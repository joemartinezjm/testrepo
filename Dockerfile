# Ubuntu 24.04 LTS (Noble) with Google Cloud SDK, Azure CLI, AWS CLI, Terraform, Terragrunt, Pulumi, Kubectl, Python, Poetry
FROM ubuntu:noble-20250127


# Set environment variables (versions as of 2025-02-07, python  3.12.3 latest for container OS)
ENV CLOUD_SDK_VERSION=509.0.0
ENV AZURE_CLI_VERSION=2.68.0-1~noble
ENV AWS_CLI_VERSION=2.24.0
ENV TERRAFORM_VERSION=1.10.5
ENV TERRAGRUNT_VERSION=0.72.8
ENV PULUMI_VERSION=3.148.0
ENV KUBECTL_VERSION=1.32.1
ENV PYTHON_VERSION=3.12
ENV POETRY_VERSION=2.0.1

ARG TARGETARCH

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    unzip \
    gnupg \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    google-cloud-cli=${CLOUD_SDK_VERSION}-0 \
    google-cloud-cli-gke-gcloud-auth-plugin && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/microsoft.gpg && \
    echo "Types: deb\nURIs: https://packages.microsoft.com/repos/azure-cli/\nSuites: $(lsb_release -cs)\nComponents: main\nArchitectures: $(dpkg --print-architecture)\nSigned-by: /etc/apt/keyrings/microsoft.gpg" | tee /etc/apt/sources.list.d/azure-cli.sources && \
    apt-get update && \
    apt-get install -y --no-install-recommends azure-cli=${AZURE_CLI_VERSION} && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN if [ "${TARGETARCH}" = "amd64" ]; then \
        AWS_ARCH="x86_64"; \
    else \
        AWS_ARCH="aarch64"; \
    fi && \
    curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && \
    rm -rf awscliv2.zip aws

# Install Terraform
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip" -o terraform.zip && \
    unzip terraform.zip -d /usr/local/bin/ && \
    rm -f terraform.zip

# Install Terragrunt
RUN curl -L "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${TARGETARCH}" -o /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt

# Install Pulumi
RUN curl -fsSL "https://get.pulumi.com" | sh -s -- --version ${PULUMI_VERSION} && \
    mv /root/.pulumi/bin/* /usr/local/bin/ && \
    rm -rf /root/.pulumi

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install Python
RUN apt-get update && \
    apt-get install -y --no-install-recommends python${PYTHON_VERSION} python3-pip python3-venv python3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | POETRY_VERSION=${POETRY_VERSION} python3 - && \
    mv /root/.local/bin/poetry /usr/local/bin/

# Set working directory
WORKDIR /home/workspace

# Run container as root
USER root

# Default command
CMD ["bash"]
