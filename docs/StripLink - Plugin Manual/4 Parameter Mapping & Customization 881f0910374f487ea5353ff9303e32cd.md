# 4. Parameter Mapping & Customization

## Linking Parameters

Connecting StripLink controls to your plugins is straightforward. **Right-Click** any empty element to open the mapping menu, where you can manually navigate through the menu to select your target plugin and parameter. For a much faster workflow, tweak the desired parameter in the target plugin's GUI first, then right-click the StripLink element and select **“Link to last touched parameter.”** 

<aside>

[20261025-1845-21.8932848.mp4](4%20Parameter%20Mapping%20&%20Customization/20261025-1845-21.8932848.mp4)

</aside>

---

⚠️**Important Note:**

The "last touched" feature registers *any* parameter  movement in REAPER, including interacting with StripLink's own tabs or internal knobs. Always link the parameter *immediately* after tweaking the target plugin, without clicking anything else in between.

## Editing Elements (Rename & Invert)

Once a parameter is linked, **Right-Click** it to open the editing options. Select **Rename parameter** to give it a custom, easy-to-read name on your layout. You can also select **Invert status**, which reverses the control's behavior—useful for mapping bypass switches or reverse-acting knobs.

<aside>

[20261025-1853-56.2151793.mp4](4%20Parameter%20Mapping%20&%20Customization/20261025-1853-56.2151793.mp4)

</aside>

---

## Visual Customization (Colors & Types)

To visually organize your channel strip, hold `Ctrl` (or `Cmd`) and **Right-Click** to open the Appearance menu. Assign colors (Green, Blue, Red, Yellow, White, or Black) to controls. You can also change the physical knob type to match the analog gear you are controlling (e.g., SSL, Neve, or API styles, depending on your active theme).

<aside>

[visual_customization_aligned_1.mp4](4%20Parameter%20Mapping%20&%20Customization/visual_customization_aligned_1.mp4)

</aside>

<aside>

[visual_customization_aligned_2.mp4](4%20Parameter%20Mapping%20&%20Customization/visual_customization_aligned_2.mp4)

</aside>

---

## Response Curves

Different analog-modeled plugins react differently to knob turns. Hold `Alt` (or `Opt`) and **Right-Click** to adjust the parameter's response curve. Options such as *Linear (1:1)*, *Fast*, or *Slow* let you calibrate the mouse feel, compensate for logarithmic scales, and make smooth adjustments across the parameter's range.

---

## Universal Groups (A-F)

StripLink features a universal grouping system. **Right-Click** any linked element and assign it to a group from **A to F**. This links that parameter across the entire project. For example, assign the compressor threshold on all drum tracks to Group A; turning the threshold knob on the snare track will then adjust the thresholds across the entire drum kit simultaneously. 

**It also fully supports inverted group states:** if a grouped element has its "Invert status" enabled, it will move in the exact opposite direction relative to the rest of the group.

<aside>

[20261025-1946-17.5344152.mp4](4%20Parameter%20Mapping%20&%20Customization/20261025-1946-17.5344152.mp4)

</aside>