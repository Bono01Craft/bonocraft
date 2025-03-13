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
USER root
# Controlla se `apt` o `apk` è disponibile
RUN if command -v apt-get > /dev/null; then \
      apt-get update && apt-get install -y \
      rcon \
      && apt-get clean && rm -rf /var/lib/apt/lists/*; \
    elif command -v apk > /dev/null; then \
      apk update && apk add --no-cache \
      rcon; \
    else \
      echo "Gestore di pacchetti non riconosciuto"; \
      exit 1; \
    fi

USER minecraft
#ENV UID=1026
#ENV GID=100
ENV TYPE=FABRIC
ENV SERVER_NAME=BonoCraft
#ENV JVM_XX_OPTS=-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15
#ENV MAX_MEMORY=6G
ENV EULA=TRUE
ENV VERSION=1.20.1
ADD mods /data/mods/
ADD https://cdn.modrinth.com/data/MdwFAVRL/versions/EVozVxCq/Cobblemon-fabric-1.5.2%2B1.20.1.jar /data/mods/Cobblemon-fabric-1.5.2%2B1.20.1.jar
#
#RUN wget https://modrinth.com/modpack/cobblemon-fabric?version=1.20.1
#RUN wget https://modrinth.com/mod/modern-industrialization

ENTRYPOINT ["/start"]
