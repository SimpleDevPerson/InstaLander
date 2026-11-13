# Continuità della griglia Report

Strumento: imagegen integrato. Immagine 1: banner attuale; immagine 2: screenshot originale del Report.

```text
Use case: compositing
Asset: existing InstaLander GitHub banner.
Image 1 is the edit target. Image 2 is the real Report screen, reference for consistent card anatomy.
Repair ONLY the card grid in the LEFTMOST phone of image 1. There is an erroneous black empty horizontal band below the third row of cards (approximately y=714 to y=810 in the 1672x941 banner). Cards then reappear below the navbar. This is a discontinuity: FIX IT by continuing the grid with a FOURTH ROW OF COMPLETE POPULATED PROFILE CARDS starting immediately after the third row with exactly the same small gap as the previous rows (about 8px). The fourth row should begin at approximately y=724 and extend naturally to y=832; its bottom part is OCCLUDED by the floating navigation pill at y=765-821, while its top parts are clearly visible ABOVE the pill and its bottom edge reappears below the pill. The pill floats ON TOP of a continuous scrollable card grid, it does not divide the grid into disconnected pieces. Use demo_simone and demo_federica for the fourth row, with blue glowing D avatars, date text and normal card anatomy. Keep first three rows unchanged. Never insert a black gap, blank tiles, compressed tiles, or an extra separate row below the pill. The FOURTH ROW is ONE continuous pair of cards behind the overlay. If needed make the third row a few pixels taller to maintain uniform rhythm, but do not deform any card.
KEEP EVERYTHING ELSE EXACTLY: all three other phones, phone frames, flat dark top safe areas, counter glow and avatar glow, decorative waves, title InstaLander, slogan "Il tuo report, privato. Nessun rischio.", footer "Anteprima con dati dimostrativi". Preserve current image dimensions and phone positions. Change only the discontinuous lower card grid in leftmost phone.
```
