# 5. Saving & Loading, FX Chains & Track Templates

## Internal Layout Saving

StripLink allows you to save and recall custom layouts and mappings directly within its interface. Right-click an empty background area to open the Section Menu. Use **Save** and **Load** to store and recall mapping configurations for individual plugins, making it easy to reuse your favorite setups on new tracks.

**Important Note:**

Universal Group assignments (A-F) are not saved within internal mappings. Grouping is strictly project-dependent and must be configured per project to avoid unintended parameter links across different sessions.

<aside>

![1.png](5%20Saving%20&%20Loading,%20FX%20Chains%20&%20Track%20Templates/1.png)

</aside>

---

## REAPER Native FX Chains & Track Templates

Because StripLink saves its entire state seamlessly, it is fully compatible with native REAPER saving features. You can save StripLink alongside your third-party plugins as a standard **REAPER FX Chain (`.RfxChain`)**. When loaded on a new track, everything remains perfectly mapped.

**Important for Default Chains:** As of REAPER v7.83+, you can also safely use the *"Save chain as default for new tracks"* feature. In these newer versions, REAPER correctly assigns unique FXIDs when generating the default chain. *(Note: Do not use this feature in older REAPER versions, as they copy the entire chunk with duplicated IDs, which will break StripLink's mapping logic).*
For the ultimate workflow, save your entire track setup as a **REAPER Track Template**. This is a great way to build hybrid consoles—for example, combining the interface of an SSL EQ, a classic 1176 compressor, and a Neve preamp in one unified StripLink layout. A Track Template preserves the plugins and StripLink mappings, as well as track routing, colors, and gain staging.

---

## Insert Mapped FX

To make your workflow truly modular, StripLink features an **Insert Mapped FX** option accessible via the background Section Menu. Even if you are working within a complex, predefined FX chain or Track Template, you can easily swap out or add a different plugin to just one specific section (for example, changing the compressor in your DYN block). By selecting this option, StripLink instantly inserts the chosen pre-mapped plugin into your REAPER FX chain and automatically links it to that specific section's controls, making experimenting with different analog models incredibly fast.

## Copying & Pasting Settings

For rapid duplication across your mix, StripLink lets you instantly copy your entire layout and mapping configuration from one track to another. **Right-Click** the background to open the Section Menu and select **Copy settings**. Then open another StripLink instance and select **Paste settings**. This instantly duplicates the visual layout and all parameter links.

*Note: For the parameter links to work correctly after pasting, the target track must have the exact same plugins loaded in its FX chain.*

<aside>

[20261025-2107-42.9513797.mp4](5%20Saving%20&%20Loading,%20FX%20Chains%20&%20Track%20Templates/20261025-2107-42.9513797.mp4)

</aside>
