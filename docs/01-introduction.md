# 1. Introduction and Concept

## What is StripLink v2

StripLink v2 is an advanced workflow utility that transforms REAPER's mixer (MCP) into a dynamic, fully-featured console via the Embedded UI feature. It is powered by a backend Lua script — `StripLink Connector_v2.lua` — and a set of JSFX plugins that work together to enable real-time communication between the mixer strips and the control layer. While it primarily acts as a macro control utility to manage your favorite third-party plugins (EQs, Compressors, Saturators) from a unified interface, StripLink also actively processes your audio to handle **Input Gain** staging at the start of your FX chain and **Auto Gain** compensation at the very end.

![](1%20Introduction%20and%20Concept/MCP%201.png)

![](1%20Introduction%20and%20Concept/MCP%202.png)

<aside>


⚡
**Performance & CPU Usage**

StripLink is highly optimized and exceptionally lightweight. A single instance consumes well under **0.1% of CPU resources**. You can confidently place StripLink on every single track in your heaviest projects without worrying about system bloat, lag, or performance degradation.

</aside>

## Versions

StripLink v2 comes in two distinct flavors:

- **Static versions** — pre-configured for specific use cases:
    - **StripLink Standard Channel:** designed for standard audio channels.
    - **StripLink BUS:** optimized for bus/group routing with a wider layout.
    - **StripLink UC-1:** tailored for the SSL UC-1 control surface workflow.
- **Modular version** — a new, freely adaptable variant that allows you to generate your own custom layout from scratch. You can build your ideal channel strip by freely positioning defined structural elements (such as knobs, switches, tubes, meters, text, separators, etc…), each featuring their own customizable properties (like size, type, position, attachment options, etc…). This ensures you are never locked into a predefined layout and can perfectly match your exact workflow needs.

![SL versions](1%20Introduction%20and%20Concept/SL%20versions.png ':size=900')

## System Requirements & Prerequisites

Before using StripLink v2, ensure your setup meets the following requirements:

- **REAPER Version:** v7.0 or newer is strictly required for advanced routing and multi-FX chain saving. However, **v7.83 or newer is highly recommended**, as it supports hiding UI tooltips, and newer versions correctly support the "Chain as default for new tracks" feature with unique FXID assignment.
- **ReaImGui:** Required for rendering the graphical user interface. Please ensure you have the latest version installed via ReaPack.
- **SWS/S&M Extension:** Required for background memory management and layout saving/loading.
- **OS Compatibility:** Fully compatible with Windows. macOS and Linux (Intel and Apple Silicon) are supported but have undergone limited testing. Please ensure your host REAPER installation and SWS extensions match your OS architecture.
