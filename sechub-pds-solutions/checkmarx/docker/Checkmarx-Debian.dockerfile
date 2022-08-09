# SPDX-License-Identifier: MIT

# The image argument needs to be placed on top
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

LABEL maintainer="SecHub FOSS Team"

# Build args
ARG PDS_VERSION="0.30.0"

ARG JAVA_VERSION="11"
ARG PDS_FOLDER="/pds"
ARG SCRIPT_FOLDER="/scripts"
ARG USER="zap"
ARG WORKSPACE="/workspace"

# Environment vars
ENV DOWNLOAD_FOLDER="/downloads"
ENV MOCK_FOLDER="${SCRIPT_FOLDER}/mocks"
ENV PDS_VERSION="${PDS_VERSION}"
ENV SHARED_VOLUMES="/shared_volumes"
ENV SHARED_VOLUME_UPLOAD_DIR="${SHARED_VOLUMES}/uploads"
ENV TOOL_FOLDER="/tools"

# non-root user
# using fixed group and user ids
# zap needs a home directory for the plugins
RUN groupadd --gid 2323 "$USER" \
     && useradd --uid 2323 --no-log-init --create-home --gid "$USER" "$USER"

# Create folders & change owner of folders
RUN mkdir --parents "$PDS_FOLDER" "${SCRIPT_FOLDER}" "$TOOL_FOLDER" "$WORKSPACE" "$DOWNLOAD_FOLDER" "MOCK_FOLDER" "$SHARED_VOLUME_UPLOAD_DIR" "/home/$USER/.ZAP/plugin"

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get upgrade --assume-yes && \
    apt-get install --assume-yes wget openjdk-${JAVA_VERSION}-jre && \
    apt-get clean

# Install the SecHub Product Delegation Server (PDS)
RUN cd "$PDS_FOLDER" && \
    # download checksum file
    wget --no-verbose "https://github.com/mercedes-benz/sechub/releases/download/v$PDS_VERSION-pds/sechub-pds-$PDS_VERSION.jar.sha256sum" && \
    # download pds
    wget --no-verbose "https://github.com/mercedes-benz/sechub/releases/download/v$PDS_VERSION-pds/sechub-pds-$PDS_VERSION.jar" && \
    # verify that the checksum and the checksum of the file are same
    sha256sum --check sechub-pds-$PDS_VERSION.jar.sha256sum

# Install SecHub OWASP ZAP wrapper
RUN cd "$TOOL_FOLDER" && \
    # download checksum file
    wget --no-verbose "https://github.com/mercedes-benz/sechub/releases/download/v$PDS_VERSION-pds/sechub-pds-wrapper-checkmarx-$PDS_VERSION.jar.sha256sum" && \
    # download wrapper jar
    wget --no-verbose "https://github.com/mercedes-benz/sechub/releases/download/v$PDS_VERSION-pds/sechub-pds-wrapper-checkmarx-$PDS_VERSION.jar" && \
    # verify that the checksum and the checksum of the file are same
    sha256sum --check sechub-pds-wrapper-checkmarx-$PDS_VERSION.jar.sha256sum && \
    ln -s sechub-pds-wrapper-checkmarx-$PDS_VERSION.jar wrapper-checkmarx.jar

# Copy mock folders
COPY mocks/ "$MOCK_FOLDER"

# Setup scripts
COPY checkmarx.sh ${SCRIPT_FOLDER}/checkmarx.sh
COPY checkmarx-mock.sh ${SCRIPT_FOLDER}/checkmarx-mock.sh

# Copy PDS configfile
COPY pds-config.json "$PDS_FOLDER/pds-config.json"

# Copy run script into container
COPY run.sh /run.sh

# Make scripts executable
RUN chmod +x ${SCRIPT_FOLDER}/checkmarx.sh ${SCRIPT_FOLDER}/checkmarx-mock.sh /run.sh

# Create the PDS workspace
WORKDIR "$WORKSPACE"

# Change owner of tool, workspace and pds folder as well as /run.sh
RUN chown --recursive "$USER:$USER" $TOOL_FOLDER ${SCRIPT_FOLDER} $WORKSPACE $PDS_FOLDER ${SHARED_VOLUMES} /run.sh

# Switch from root to non-root user
USER "$USER"

CMD ["/run.sh"]
