# Rushware logo

## Current Minecraft server icon

- `server-icon.png`: exactly 64 x 64, RGBA PNG, transparent background, centered photographic cupcake cutout.
- Installed in `server-package/server-icon.png` and `runtime/server-icon.png`.
- Cutout source: `rushware-cupcake-photo-cutout-v1.png`, extracted with built-in image_gen from the user's photo.
- Final size export: Windows System.Drawing, preserve aspect ratio, fit the visible subject within 60 x 60 pixels on a transparent 64 x 64 canvas.
- The cupcake and the chocolate square touching its front are preserved as the subject; surrounding cupcakes, tabletop and scattered crumbs are removed.
- Package generation includes the icon automatically. Restart a running server to load its new server-list icon.

### Final cutout prompt

Use case: background-extraction / precise-object-edit. Edit ONLY the most recent user-attached photo (the photograph of a real central chocolate muffin/cupcake with chocolate chunks and a large diagonal chocolate square touching its front). Ignore the previous generated cupcake illustrations. Carefully cut out the SINGLE CENTRAL cupcake from this photo together with the prominent diagonal chocolate square leaning directly against its front, preserving the original photographic appearance, chocolate chunks, paper wrapper, lighting, colors, proportions, and exact silhouette. Remove the entire tabletop, scattered crumbs outside the subject, all surrounding cupcakes and background. Do not redraw or stylize the subject. Do not add sugar, frosting, text, shadows or other elements. Produce a genuinely transparent RGBA PNG with the cutout centered in a square canvas, full subject uncropped, with a clean transparent margin of approximately 5 percent around it. The final intended use is a 64x64 Minecraft server icon, so keep the subject large and centered. If the tool can directly produce an exact 64x64 PNG do so; otherwise preserve the clean cutout for a deterministic final resize. Absolutely no colored background and no checkerboard painted into the image.

## Earlier generated logo

- Asset: `rushware-chocolate-cupcake-v1.png`
- Theme: chocolate cupcake with white sugar sprinkled on top.
- Generated with the built-in image_gen tool on 2026-10-06.
- Actual output: 1254 x 1254 pixels, RGBA PNG with transparency.
- Requested the highest supported native square resolution. The built-in tool exposes no numeric size parameter; the delivered size is the tool's actual output, not an artificially enlarged image.
- This is the master logo asset; it has not been installed as the Minecraft server icon.

## Final generation prompt

Use case: logo-brand. Create one final, premium square server logo for the Rushware Minecraft PGM server. Subject: a single delicious CHOCOLATE CUPCAKE, with its dark chocolate top visibly sprinkled and dusted with WHITE SUGAR. Sugar must read as white sugar crystals and a light dusting, not a big white frosting cap. Style: polished illustrated game-server icon, confident clean contours, a strong instantly recognizable silhouette, restrained dimensional shading, rich cocoa cake and chocolate topping, a neatly pleated chocolate-brown paper cup. A small elegant chocolate frosting peak is fine. Composition: one centered cupcake filling approximately 80 percent of the square, full silhouette visible, comfortably padded, crisp details and enough simplicity to read clearly at 64x64. Genuinely transparent background. No text, letters, monogram, slogan, face, weapons, other objects, watermark, mockup, or scenery. Produce the highest native square resolution and best detail supported by this image-generation tool; prefer 2880x2880 if supported, otherwise the largest available native square output. This is the finished standalone logo asset, not a design sheet.
