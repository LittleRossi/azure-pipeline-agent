FROM ubuntu:22.04
ENV TZ=Europe/Berlin
ENV AGENT_ALLOW_RUNASROOT="true"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y



RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    gnupg \
    software-properties-common \
    python3-pip \
    tzdata \
    wget \
    zip \
    unzip
    
RUN DEBIAN_FRONTEND=noninteractive mkdir -p /etc/apt/keyrings && \
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
 wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" && \
 dpkg -i packages-microsoft-prod.deb && \
 echo \
   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/nul

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y -qq --no-install-recommends \
  docker-ce docker-ce-cli containerd.io docker-compose-plugin powershell


RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN pwsh -c "Install-Module -Name Az -Force" && pwsh -c "Install-Module -Name SqlServer -Force"

RUN echo "openssl_conf = default_conf\n\n\
[default_conf]\n\
ssl_conf = ssl_sect\n\n\
[ssl_sect]\nsystem_default = system_default_sect\n\n\
[system_default_sect]\n\
CipherString = ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256\n\
$(cat /etc/ssl/openssl.cnf)" > /etc/ssl/openssl.cnf

RUN sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf
RUN sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/g' /usr/lib/ssl/openssl.cnf

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

WORKDIR /azp

COPY ./start.sh .
COPY ./cache-images.s? .
RUN test -f ./cache-images.sh && chmod 755 ./cache-images.sh || echo 'no cached images are used'
RUN chmod 755 ./start.sh


ENTRYPOINT [ "./start.sh" ]