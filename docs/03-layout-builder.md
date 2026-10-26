# 3. Layout Builder (Module Version Only)

## Activation & Basics

The StripLink Module version features a powerful Layout Builder that lets you design your custom interface. Open the **Main Settings Menu** (hamburger icon) and select **Layout Builder** to activate editing mode. The interface operates on a Grid Snap system, allowing you to freely drag and arrange elements precisely where you want them on the canvas.

---

## Adding & Arranging Elements

Once in Builder mode, a floating toolbox window appears. You can add various controls directly to the grid by clicking the respective buttons: **Knobs**, **Switches**, **Tubes**, **Meters**, and an **Input Gain** module. Before adding a Meter, use the radio buttons in the toolbox to select the correct Target Section (Top or Bottom), so it appears in the desired logical area (e.g., DYN 1 vs. DYN 2).

<video controls>
  <source src="3%20Layout%20Builder%20(Module%20Version%20Only)/Recording_2026-10-25_183723-compressed.mp4" type="video/mp4">
</video>


### Available Control Types

<table style="width:100%; border:0; border-collapse:collapse;">
  <tr>
    <td style="width:70%; vertical-align:top; padding:0 15px 0 0;">

- **Knob:** A standard continuous rotary control for parameters like gain, frequency, or threshold.
- **Switch:** A simple two-state toggle (On/Off), ideal for bypasses, phase inversion, or routing options.
- **Selector (Multi-state):** A stepped rotary switch for parameters with fixed values (e.g., ratios, specific frequencies). It can auto-detect the available steps directly from the linked plugin, or you can manually define the number of steps.
- **Tube:** A specialized visual element designed for saturation, drive, or harmonic stages.
- **Meters:** Visual feedback units (like VU or Gain Reduction meters) that can be targeted to specific Top or Bottom sections.
- **Input Gain:** A dedicated utility module used for initial gain staging at the very start of your FX chain.
- **Auto-Gain:** A smart compensation toggle that can be placed on your layout to balance input and output levels (detailed fully in Chapter 6).
- **Text Label:** A non-functional text block used for labeling sections, controls, or adding custom notes to your layout.
- **Separator:** A visual dividing line (multi shape options) to help group controls and keep your interface neatly organized.

    </td>
    <td style="width:30%; vertical-align:top; text-align:center; padding:0;">
      <img src="3%20Layout%20Builder%20(Module%20Version%20Only)/control-types-composite-120.png" style="width:165px !important; max-width:165px !important; height:auto !important; display:block !important; float:none !important; margin:0 auto !important;">
    </td>
  </tr>
</table>


---

## System Dividers (Top/Bottom Split)

On the DYN and FX pages, you will notice a horizontal System Divider line. This divider visually and logically separates the Top processing section (e.g., DYN 1 or FX PRE) from the Bottom section (e.g., DYN 2 or FX POST). You can freely drag this divider up or down to adjust the workspace area dedicated to each half. Functional controls automatically respect this boundary, ensuring your routing logic remains strictly organized.

---

## Interface Height Adjustment

The toolbox offers two independent height settings to fit your layout:

- **Unscrollable Slot Height (Global):** Modifies the core `.jsfx` file to change the physical window size of the plugin across your entire REAPER project.
- **Panel Size (Instance):** Adjusts the scrollable workspace height exclusively for the currently selected StripLink instance, defining how far down you can place elements.

---

## Clear Layout

To start completely from scratch, click the **CLEAR LAYOUT** button in the toolbox. A safety prompt will appear to prevent accidental deletion. Confirming will remove all custom elements and tab colors, leaving a completely blank layout across all TABs.

### **Modular Layout Concepts**

The Layout Builder provides complete structural freedom to design your ideal channel strip. Rather than just swapping colors, you can construct entirely distinct functional blocks—from dense EQ and Dynamics sections to dedicated Preamp utilities and complex signal routing panels. Below are examples of different layout architectures demonstrating the wide variety of controls, visual grouping, and interface designs you can achieve.



<table style="width:100% !important; border:0 !important; border-collapse:collapse !important; background:transparent !important;">
  <tbody style="background:transparent !important;">
    <tr style="background:transparent !important;">
      <td style="width:50%; padding:5px; vertical-align:top; text-align:center; background:transparent !important; border:0 !important;">
        <img src="3%20Layout%20Builder%20(Module%20Version%20Only)/1.png" style="width:320px !important; min-width:320px !important; max-width:320px !important; height:auto !important; display:block !important; float:none !important; margin:0 auto !important; background:transparent !important;">
      </td>
      <td style="width:50%; padding:5px; vertical-align:top; text-align:center; background:transparent !important; border:0 !important;">
        <img src="3%20Layout%20Builder%20(Module%20Version%20Only)/2.png" style="width:320px !important; min-width:320px !important; max-width:320px !important; height:auto !important; display:block !important; float:none !important; margin:0 auto !important; background:transparent !important;">
      </td>
    </tr>
    <tr style="background:transparent !important;">
      <td style="width:50%; padding:5px; vertical-align:top; text-align:center; background:transparent !important; border:0 !important;">
        <img src="3%20Layout%20Builder%20(Module%20Version%20Only)/3.png" style="width:320px !important; min-width:320px !important; max-width:320px !important; height:auto !important; display:block !important; float:none !important; margin:0 auto !important; background:transparent !important;">
      </td>
      <td style="width:50%; padding:5px; vertical-align:top; text-align:center; background:transparent !important; border:0 !important;">
        <img src="3%20Layout%20Builder%20(Module%20Version%20Only)/4.png" style="width:320px !important; min-width:320px !important; max-width:320px !important; height:auto !important; display:block !important; float:none !important; margin:0 auto !important; background:transparent !important;">
      </td>
    </tr>
  </tbody>
</table>


