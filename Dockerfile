#ARG arch
FROM ghcr.io/itzg/minecraft-server:2025.3.0-java17-graalvm
#
# hook into docker BuildKit --platform support
# see https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
#
#RUN apt update && apt install -y rcon

#ENV UID=1026
#ENV GID=100
ENV TYPE=FABRIC
ENV SERVER_NAME=BonoCraft
# I flag G1 di Aikar, gestiti dall'immagine invece che a mano.
ENV USE_AIKAR_FLAGS=true
# Default dell'immagine itzg = 1G, insufficiente. Sovrascrivibile a runtime con -e MEMORY=...
ENV MEMORY=6G
ENV EULA=TRUE
ENV VERSION=1.20.1
COPY mods /data/mods/
ADD https://cdn.modrinth.com/data/MdwFAVRL/versions/EVozVxCq/Cobblemon-fabric-1.5.2%2B1.20.1.jar /data/mods/Cobblemon-fabric-1.5.2%2B1.20.1.jar
#
#RUN wget https://modrinth.com/modpack/cobblemon-fabric?version=1.20.1
#RUN wget https://modrinth.com/mod/modern-industrialization

ENTRYPOINT ["/start"]
