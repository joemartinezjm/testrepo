# Ubuntu 24.04 LTS (Noble) with Azure CLI, Terraform, Terragrunt, Kubectl, Python
FROM ubuntu:24.04


# Set environment variables (versions as of 2025-02-07, python  3.12.3 latest for container OS)
ENV AZURE_CLI_VERSION=2.68.0-1~noble
ENV TERRAFORM_VERSION=1.10.5
ENV TERRAGRUNT_VERSION=0.72.8
ENV KUBECTL_VERSION=1.32.1
ENV PYTHON_VERSION=3.12

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    unzip \
    gnupg \
    apt-transport-https \
    ca-certificates \
    git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ noble main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends azure-cli=${AZURE_CLI_VERSION} && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip && \
    unzip terraform.zip -d /usr/local/bin/ && \
    rm -f terraform.zip

# Install Terragrunt
RUN curl -L "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" -o /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install Python
RUN apt-get update && \
    apt-get install -y --no-install-recommends python${PYTHON_VERSION} python3-pip python3-venv python3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /home/workspace

# Run container as root
USER root

# Default command
CMD ["bash"]
