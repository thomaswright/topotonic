# Topotonic

## About

Topotonic lists all the scales, all the scale modes, and all the (additional) pitch classes possible for a 12 tone system along with their constellation diagram, in any key or interval.

These are first organized by the number of notes in each scale, then by the scale itself, then by the pitch classes.

For example, in a 5 note scales there are 66 ways to arrange these notes (on a 12 note system). The most famous of these is the Pentatonic scale. If you click on "5 66 species" then on the top scale, labeled "Pentatonic", you'll see all the pitch classes. The modes are with a white background while the additional non-modal pitch classes are shaded. For popular scales and modes, we have listed their names.

Additional features:

- The number to the left of the scale is the decimal number of the binary representation of the scale (the highest with regards to rotation). For example, the pentatonic scale in binary is 101010010100, which is 2708 in decimal.
- If a symmetry icon is located to the right of the scale, this means the scale has bilateral symmetry for at least one pitch class (though not necessarily a mode).
- Along with the possible names for a scale will be listed the symmetric compression of the scale. For example, the first scale of 4 notes (#2340) has D4 dihedral symmetry and so is reduced to just 1 mode and 3 pitch classes.
- In the same column as the symmetry indicator is the listing of the number of correlations between each pitch class. For example, in the Pentatonic scale we can see if a mode is rotated 2 half-notes there will be 3 correlations, for 3 half-notes 2 correlations, etc. This is somewhat an indicator of how self-harmonic a scale is. You'll see that the most popular scales (like the Pentatonic and the Diatonic) have high correlations across rotations, especially for simple (aka high harmonic) pitch ratios like 5ths (7 half-notes) and 3rds (5 half-notes).
- You can choose both key and interval note representations. We are currently disregarding temperment and consider, for instance, g sharp the same as a flat.

## Dev

### Build

```
npm run build
```

### Watch

```
npm run watch
```
