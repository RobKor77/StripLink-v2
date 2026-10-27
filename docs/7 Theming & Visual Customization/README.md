# 7 Theming & Visual Customization

StripLink allows you to completely overhaul its visual appearance by creating custom themes. Whether you want a photorealistic analog console look or a sleek modern flat design, the theming engine gives you full control over backgrounds, knobs, and meters.

## Theme Folder Structure

All StripLink themes are stored within your REAPER resource directory under the `SL_Themes` folder. The architecture is strictly organized by plugin version, then by theme name, and finally by the graphical assets.

Here is how the hierarchy looks on your system:

![Folder Structure](Folder%20Structure.png ':size=700')

**How it works:**
1. **Plugin Folders:** Inside the main `SL_Themes` directory, there is a dedicated folder for each StripLink plugin variant (e.g., `StripLink Module v2`).
2. **Theme Folders:** Inside the plugin folder, each subfolder represents a unique, selectable theme (e.g., `Analog Console`, `Flat`, `SSL`). The name of this folder is exactly what will appear in your StripLink Main Settings menu!
3. **Asset Folders:** Inside each specific theme folder, the visual elements must be strictly categorized into three exact subfolders: `Backgrounds`, `Knobs`, and `Meters`.

> **`Pro Tip for Creating Themes:`** The easiest way to create a new theme is to duplicate an existing theme folder and simply modify or replace the image files inside. If you want to retain a specific contextual menu structure for the knob graphics, you must keep the original theme's folder name and add a prefix or suffix to it (for example, `Custom_Analog Console`). This ensures StripLink automatically applies the exact same menu structure and logic to your new theme.
> 
### Asset Dimensions & Requirements

To ensure all graphical elements are displayed correctly within the plugin, the original aspect ratios of the images must be strictly maintained. 

- **Knobs:** The required resolution is **54x54 pixels** per frame, and the image must be a vertical sprite sheet containing exactly **51 frames**.
