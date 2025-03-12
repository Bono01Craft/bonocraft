FROM ghcr.io/itzg/minecraft-server:2025.3.0-java17-graalvm
ENV UID=1026
ENV GID=100
ENV TYPE=NEOFORGE
ENV SERVER_NAME=BonoCraft
ENV JVM_XX_OPTS=-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=
#ENV MAX_MEMORY=6G
ENV EULA=TRUE
#RUN wget https://modrinth.com/modpack/cobblemon-fabric?version=1.20.1
#RUN wget https://modrinth.com/mod/modern-industrialization