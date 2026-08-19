# BonoCraft

Welcome to BonoCraft, a custom Minecraft server featuring the Cobblemon and Modern Industrialization mods!

## Overview

BonoCraft combines the fun of Cobblemon with the technical complexity of Modern Industrialization to deliver a unique Minecraft experience. Explore, craft, and automate in a world filled with endless possibilities.

The repository builds dedicated server images for Fabric 1.20.1 and NeoForge 1.21.1. The
NeoForge image is the production pack described below.

## Features

- **Cobblemon Mod**: Integrate Pokémon into the Minecraft world for exciting new adventures and challenges.
  
- **Modern Industrialization Mod**: Dive into advanced machinery and automated systems to enhance your gameplay with industrial capabilities.

## Getting Started

### Prerequisites

- Minecraft Java Edition
- Minecraft Forge (compatible version)

### Installation

1. **Clone the Repository**

   Clone this repository to your local machine:
   ```bash
   git clone https://github.com/Bono01Craft/bonocraft.git
   ```
   
1. Install Minecraft with modrinth app
Download and install the recommended version of Minecraft Forge for mod compatibility.

2. Download the Mods

Ensure you have the latest versions of the Cobblemon and Modern Industrialization mods.

3. Add Mods to Minecraft

Place all the downloaded mod .jar files into your Minecraft mods directory.

4. Launch Minecraft

Start Minecraft with the Forge profile.

### Server Setup

The server images are built by the Dockerfiles in this repository. For NeoForge 1.21.1:

```bash
docker build -f Dockerfile.neoforge -t bonocraft-neoforge:dev .
docker run -it --rm -p 25565:25565 -e MEMORY=6G bonocraft-neoforge:dev
```

The production world, server properties, permissions, and mod configuration live on the
server volume and are not stored in this repository.

### Performance Operations

Spark and Chunky are included in the NeoForge pack. Run these commands against the production
world as an operator; do not use a throwaway world for the baseline or pregeneration.

#### Spark baseline

With representative players online, run:

```text
/spark profiler --timeout 300
```

Record the generated Spark profile URL, average MSPT/TPS, and the five hottest code paths in
issue [#15](https://github.com/Bono01Craft/bonocraft/issues/15). This baseline must be captured
under normal player activity before using it to prioritize performance work.

#### Chunky pregeneration

Choose one radius for the production world and use the same value for the corresponding border.
The issue recommendation is 5000-10000 blocks in the Overworld; the final value is an
operator decision based on storage, generation time, and expected exploration.

Replace `<radius>` below with that decision, then run each dimension separately:

```text
/chunky world world
/chunky radius <radius>
/chunky start

/chunky world world_nether
/chunky radius <radius>
/chunky start

/chunky world world_the_end
/chunky radius <radius>
/chunky start
```

Wait for each job to finish before starting the next one. Afterward, enforce the same limit
with a centered world border in each dimension where a border is required by the server policy.
For a radius of `<radius>`, the matching diameter is `2 * <radius>`:

```text
/worldborder center 0 0
/worldborder set <diameter>
```

Apply the border in the intended dimension before moving to the next one; the border is
dimension-local.
Record the chosen radius, border diameter, completion date, and any skipped dimension in
issue [#16](https://github.com/Bono01Craft/bonocraft/issues/16).

### Install Server Files

Use the files provided in the server directory of this repository to set up your server environment.

### Configure the Server

Adjust the server.properties and other configuration files as necessary to customize your server settings.

### Start the Server

Run the server with the launch script provided for your operating system.

### Contributing
We welcome contributions! Please fork the repository and submit a pull request with your changes.

### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

The MIT license covers **this repository's own files** (Dockerfiles, CI workflows, documentation).
It does **not** cover the third-party mod `.jar` files shipped in `mods/`, `mods_neoforge/` and
`mods_homestead/`: each mod is subject to its own license, and redistribution permission varies per
mod. If you fork or redistribute the resulting Docker images, verify the terms of each mod you ship.

### Contact
For questions or support, please open an issue on GitHub or contact the maintainers directly.

### Happy crafting!

Feel free to adjust the text to fit the specific details of your project, such as any additional setup instructions or unique features.

