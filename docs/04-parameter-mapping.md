# 4. Parameter Mapping & Customization

## Linking Parameters

Connecting StripLink controls to your plugins is straightforward. **Right-Click** any empty element to open the mapping menu, where you can manually navigate through the menu to select your target plugin and parameter. For a much faster workflow, tweak the desired parameter in the target plugin's GUI first, then right-click the StripLink element and select **“Link to last touched parameter.”** 

<aside>
  <video controls style="width: 500px !important; max-width: 100% !important;">
    <source src="4%20Parameter%20Mapping%20&%20Customization/20261025-1845-21.8932848.mp4" type="video/mp4">
  </video>
</aside>

---

⚠️**Important Note:**

The "last touched" feature registers *any* parameter movement in REAPER, including interacting with StripLink's own tabs or internal knobs. Always link the parameter *immediately* after tweaking the target plugin, without clicking anything else in between.

## Editing Elements (Rename & Invert)

Once a parameter is linked, **Right-Click** it to open the editing options. Select **Rename parameter** to give it a custom, easy-to-read name on your layout. You can also select **Invert status**, which reverses the control's behavior—useful for mapping bypass switches or reverse-acting knobs.

---
## The OVR (Overview) Tab

The **OVR** tab is a unique, dynamic section of the StripLink interface. Unlike the other dedicated tabs (which focus on specific processor categories like EQ or Dynamics), the OVR tab acts as a customizable master dashboard.

**How it works:**
It does not have fixed, pre-assigned controls. Instead, it can display *any* element or parameter that has been successfully mapped across the other tabs. 

By linking your most frequently used controls from various plugins (e.g., a specific EQ band, a compressor threshold, and a saturation drive), they will automatically populate in the OVR tab. This allows you to build a unified, single-page control center containing only the most crucial parameters for your workflow, eliminating the need to constantly switch between different sections.

**Visual Feedback & GR Ring Overlay:**
Additionally, you have the ability to overlay a Gain Reduction (GR) ring meter directly onto a parameter knob in the OVR tab. If a control is linked to the DYN (Dynamics) section, this overlay provides instant, real-time visual feedback of your compression activity right on the knob itself—allowing you to monitor gain reduction without ever needing to leave your master dashboard.

---
## Visual Customization (Element Colors & Types)

To visually organize your channel strip, hold `Ctrl` (or `Cmd`) and **Right-Click** to open the Appearance menu. Assign colors (Green, Blue, Red, Yellow, White, or Black) to controls. You can also change the physical knob type to match the analog gear you are controlling (e.g., SSL, Neve, or API styles, depending on your active theme).

<video controls>
  <source src="4%20Parameter%20Mapping%20&%20Customization/visual_customization_aligned_1.mp4" type="video/mp4">
</video>

<video controls>
  <source src="4%20Parameter%20Mapping%20&%20Customization/visual_customization_aligned_2.mp4" type="video/mp4">
</video>

---

## Response Curves

Different analog-modeled plugins react differently to knob turns. Hold `Alt` (or `Opt`) and **Right-Click** to adjust the parameter's response curve. Options such as *Linear (1:1)*, *Fast*, or *Slow* let you calibrate the mouse feel, compensate for logarithmic scales, and make smooth adjustments across the parameter's range.

---

## Universal Groups (A-F)

StripLink features a universal grouping system. **Right-Click** any linked element and assign it to a group from **A to F**. This links that parameter across the entire project. For example, assign the compressor threshold on all drum tracks to Group A; turning the threshold knob on the snare track will then adjust the thresholds across the entire drum kit simultaneously. 

**It also fully supports inverted group states:** if a grouped element has its "Invert status" enabled, it will move in the exact opposite direction relative to the rest of the group.

<video controls style="width: 500px !important; max-width: 100% !important;">
  <source src="4%20Parameter%20Mapping%20&%20Customization/20261025-1946-17.5344152.mp4" type="video/mp4">
</video>
