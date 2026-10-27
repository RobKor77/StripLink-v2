# 6. StripLink Aggregator, Metering & Auto-Gain

### The Aggregator Plugin & Meter Routing

To enable visual feedback and level matching, StripLink relies on a dedicated companion plugin called the **StripLink Aggregator**. You do not need to set it up manually. Whenever you link a meter to a plugin on your layout, StripLink automatically inserts the Aggregator at the end of your FX chain and transparently configures the multi-channel routing—for example, routing reference signals to channels 13/14. As mentioned in the Main Settings menu, you can globally set your primary VU Meter tap point to monitor *PRE In*, *PRE Out*, or *Chain Out*.<br>
Additionally, this same menu allows you to conserve system resources by choosing whether Gain Reduction (GR) meters are displayed across all tracks simultaneously, or restricted to only the currently selected tracks.

### Gain Reduction (GR) & Detection Modes

For dynamics sections (DYN 1 and DYN 2), the Aggregator analyzes the signal to calculate gain reduction. By default, the system uses a smart *Auto Detect* algorithm. For the best visual accuracy with specialized tools, open the Aggregator plugin window and manually set the *Detection Mode* for Meter 1 or Meter 2. Available modes are *Compressor*, *Gate/Expander*, and *Upward Expander*.

### Combined Channel Strips (Comp + Gate)

StripLink includes a calculation engine for channel-strip plugins that contain both a compressor and a gate. If the plugin reports native compressor gain reduction to the DAW, you can link DYN 1 to the compressor and DYN 2 to the gate. The Aggregator detects that both meters share the same plugin instance and isolates the gate’s gain reduction, providing two distinct GR meters.

<video controls>
  <source src="6%20StripLink%20Aggregator,%20Metering%20&%20Auto-Gain/20261025-2203-39.5161320.mp4" type="video/mp4">
</video>

<video controls>
  <source src="6%20StripLink%20Aggregator,%20Metering%20&%20Auto-Gain/20261025-2242-50.9028585.mp4" type="video/mp4">
</video>

> **`Important Note on Containers & Routing:`** Gain Reduction (GR) metering and the Aggregator's auto-routing will **only function if your plugins are placed inside a REAPER Container**. Because StripLink uses complex multi-channel routing (up to 14 channels) to pass meter and reference signals, the Container acts as an isolated sandbox—preventing this internal routing from bleeding into or breaking your track's main signal flow. Additionally, StripLink intentionally leaves channels 3/4 completely untouched, ensuring your standard sidechain compression workflows remain perfectly intact. 

Adaptive Auto-Gain System

The Aggregator houses an advanced LUFS-based Auto-Gain compensator that utilizes **Fletcher-Munson (ISO 226) weighting filters** to match perceived human loudness rather than just mathematical peak or RMS values. It continuously compares the reference signal (Ref In) with your final output (Raw Out) and smoothly adjusts the volume to match perfectly. Technically, this compensation measures the difference starting from the *output* of the first linked FX (which StripLink routes to channels 13/14) down to the *end* of the chain (the Aggregator input). The **Auto-Gain toggle** and its companion **Lock button** are permanent system elements located at the bottom of your StripLink interface, so they are always ready to use without needing to be manually added. 

• **Adaptation Speed:** You can calibrate the learning speed in the Main Settings menu. Slower speeds are ideal for highly percussive elements (like drums) to prevent erratic gain pumping, while faster speeds work better for sustained, dynamic material.
• **Locking the Gain:** While the LUFS learning process is smooth, you generally want perfect stability during the final mix phase. Clicking the **Lock** button freezes the Auto-Gain at its current compensation value, ensuring a 100% static, reliable gain stage. 

**Pro Tip for Input Stages:** Because the reference signal is tapped at the *output* of the first linked plugin, any input gain changes made *inside* that first plugin will not be auto-compensated. To compensate for the input stage of your first primary plugin, insert a "dummy" plugin (e.g., a basic volume utility) at the very beginning of your FX chain and link a meter to it. This forces the Aggregator to start its measurement before your primary processing begins.

### VU Meter Configuration & Calibration

StripLink provides extensive global and instance-based options to customize your main VU meters, all accessible via the Main Settings menu:

- **Tap Points:** Choose where the VU meter listens in your signal chain: *PRE In* (raw track input), *PRE Out* (after the PRE section), or *Chain Out* (final output after all processing).
- **Calibration (dBFS):** Calibrate the analog 0 VU reference point to match your digital workflow, such as -18 dBFS, -12 dBFS, or a custom value.
- **Peak LED Threshold:** Set a digital threshold, such as -1 dBFS or -3 dBFS, for the red Peak LED to warn of potential digital clipping.
- **Visual Styles:** Choose *Classic Analog VU*, the compact *Slim Horizontal VU*, or *Hide Top Meters* to suit your screen space.
