# Docker image file that describes an Ubuntu16.04 image with UCS PowerTool Core Suite and PowerShell installed from Microsoft APT Repo

FROM ubuntu:xenial-20180417

LABEL maintainer="Cisco UCS PowerTool Team <ucs-powertool@cisco.com>"
LABEL readme.md="https://github.com/sumanthbr/ciscoucspowertoolcore/blob/master/README.md"
LABEL description="This Dockerfile will install the VmWareTools and UCS PowerTool Core Suite for the Ubuntu 16.04 version of PowerShell."

# Install dependencies and clean up
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    apt-utils \
    ca-certificates \
    curl \
    wget \ 
    gnupg \
    apt-transport-https \
    locales\
    && rm -rf /var/lib/apt/lists/*

# Setup the locale
ENV LANG en_US.UTF-8
ENV LC_ALL $LANG
RUN locale-gen $LANG && update-locale

# Import the public repository GPG keys for Microsoft
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

# Register the Microsoft Ubuntu 16.04 repository
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/microsoft.list

# Install powershell from Microsoft Repo
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    powershell

# Install Unzip package
RUN apt-get install -y \
    unzip

# Copy UCS PowerTool Suite binaries from local system
RUN mkdir -p ~/.local/share/powershell/Modules
RUN mkdir -p ~/.config/powershell/

#ADD https://communities.cisco.com/servlet/JiveServlet/download/74217-2-149644/ucspowertoolcore.zip /tmp
#RUN unzip /tmp/ucspowertoolcore.zip -d ~/.local/share/powershell/Modules/
#RUN mv ~/.local/share/powershell/Modules/Start-UcsPowerTool.ps1 ~/.config/powershell/Microsoft.PowerShell_profile.ps1 -f

# Install VMware and PowerTool modules from PSGallery
SHELL [ "pwsh", "-command" ]
RUN Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
RUN Install-Module VMware.PowerCLI,PowerNSX,PowervRA
RUN Install-Module Cisco.UCS.Core
# On by default to suppress nagging. Set to $false if you don't want to help us make PowerCLI better.
# TODO: Investigate why we can't set this to either true or false.
RUN Set-PowerCLIConfiguration -ParticipateInCeip $true -Confirm:$false
# Use PowerShell as the default shell
# Use array to avoid Docker prepending /bin/sh -c
ENTRYPOINT [ "pwsh" ]