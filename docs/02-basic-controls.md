# 2. Basic Controls & Navigation

## Tab Navigation

StripLink uses four main pages to organize your workflow: **OVR** (Overview), **EQ**, **DYN** (Dynamics), and **FX** (Effects).

- **Global Switching (Default):** Clicking any tab will instantly switch the view across all StripLink instances in your entire project, keeping your mixer perfectly synced.
- **Local Switching:** Hold `Ctrl` (or `Cmd` on Mac) and click a tab to change the view for that specific track only, without affecting the rest of your mixer.

<video controls width="50%">
  <source src="2%20Basic%20Controls%20&%20Navigation/922226ec-b219-4771-8355-ec080e012fea.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

---

## Tab Color Markers

To enhance visual organization, you can assign custom color markers to any tab. This is especially useful for acting as quick workflow reminders, visually grouping specific instruments, or indicating your intended signal chain order (e.g., color-coding to remind yourself whether the EQ is placed before or after the Compressor). Simply **Right-Click** on any tab header (EQ, DYN, or FX) to open the color menu and select a marker (Red, Green, Blue, Yellow, or None). 

<video controls width="50%">
  <source src="2%20Basic%20Controls%20&%20Navigation/20261025-1410-07.4574374.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

---

## Mouse Controls

All knobs, switches, and selectors in StripLink share a unified control logic, packed with workflow shortcuts:   
• **Adjust Values:** Left-Click + Drag up/down (or use the Mouse Wheel) for smooth parameter adjustments.   
• **Fine Control:** Hold `Ctrl` (or `Cmd` on Mac) while dragging for ultra-precise, surgical tweaks.   
• **Instant Reset:** **Double-Click** any assigned knob or switch to instantly reset the parameter to its saved default value.   
• **Main Menu:** **Right-Click** any element to open the core parameter linking and routing menu.   
• **Appearance Menu:** Hold `Ctrl` (or `Cmd`) + **Right-Click** to instantly open the Knob Style and Color menu. 
• **Response Curve Menu:** Hold `Alt` (or `Opt`) + **Right-Click** to instantly open the parameter response curve settings (Linear, Fast, Slow). 

<video controls width="50%">
  <source src="2%20Basic%20Controls%20&%20Navigation/20261025-1435-43.0342112.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

---

## Context Menus

### 1. Global & Instance Settings (Main Menu)

The Main Settings Menu (hamburger icon) provides full control over StripLink's behavior.

- **Icon Location:** By default, the icon is located in the top right corner, just below the VU meter. However, if you choose the *Hide Top Meters* style, the icon automatically moves to the **bottom right corner** of the interface.
- **Instance Settings:** These apply only to the current plugin. Here you can rename the instance, toggle the *Layout Builder*, choose the VU meter tap point (Pre In, Pre Out, Chain Out), calibrate its reference (e.g., -18 dBFS), and set the Auto Gain speed.
- **Global Settings:** These apply to the entire project. They include changing the Theme, VU Meter Style (Classic, Slim, Hidden), GR Meter Range, Peak LED Threshold, global Font Size, Tooltip visibility, and Mouse Control sensitivity.

<video controls width="50%">
  <source src="2%20Basic%20Controls%20&%20Navigation/20261025-1702-06.8030474.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

### 2. Main Parameter Menu (Right-Click)

A standard **Right-Click** on any element opens its core functional menu. From here, you can link the knob to a plugin parameter (or the last touched parameter), manually rename it, invert its behavior (useful for bypass switches or reverse parameters), and assign it to a global Saturation/Control Group (A-F).

<aside>

![image1.png](2%20Basic%20Controls%20&%20Navigation/image1.png)

</aside>

### 3. Appearance Menu (Ctrl/Cmd + Right-Click)

Holding `Ctrl` (or `Cmd`) while right-clicking instantly opens the Appearance menu. Here you can fully customize the look of the element. You can change its LED color (Green, Blue, Red, Yellow, White, Black) and its physical style (Type 1 to Type 4) to match the gear you are controlling (e.g., SSL, API, or Neve style knobs).

<aside>

![image1.png](2%20Basic%20Controls%20&%20Navigation/image1%201.png)

</aside>

### 4. Response Curve Menu (Alt/Opt + Right-Click)

Different analog-modeled plugins react differently to knob turns. Holding `Alt` (or `Opt`) while right-clicking lets you adjust the parameter's response curve. Choose *Linear (1:1)*, *Fast*, or *Slow* profiles to make physical mouse movement feel natural across the entire range, especially for logarithmic parameters.

<aside>

![image1.png](2%20Basic%20Controls%20&%20Navigation/image1%202.png)

</aside>

### 5. Section & Mapping Menu (Background Right-Click)

Right-clicking on any empty background area opens the Section Menu, which acts as your central hub for mapping management. Because sections like Dynamics (DYN) and Effects (FX) are split into top and bottom halves, this menu applies specifically to the half you clicked on. From here, you can Copy and Paste entire section settings, Save your custom layouts (Single FX, FX Chains, or Hybrids), Load existing mappings, quickly Insert mapped FX directly onto your track, or completely Clear the section's links.

<aside>

![image1-82.png](2%20Basic%20Controls%20&%20Navigation/image1-82.png)

</aside>
