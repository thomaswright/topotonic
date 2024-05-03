import React from "react";

const About = () => {
  return (
    <div id="about">
      <p>
        Topotonic lists all the scales, all the scale modes, and all the
        (additional) pitch classes possible for a 12 tone system along with
        their constellation diagram, in any key or step representation.
      </p>
      <p>
        These are first organized by the number of notes in each scale, then by
        the scale itself, then by the pitch classes (non-modal pitch classes are
        shaded).
      </p>
      <p>
        The scale number is the decimal representation of the binary
        representation of the scale (highest with regards to rotation). For
        example, the pentatonic scale in binary is 101010010100, which is 2708
        in decimal.
      </p>
      <p>
        A symmetry icon means the scale has bilateral symmetry for at least one
        pitch class (though not necessarily a mode).
      </p>
      <p>
        Scales are reduced with regards to symmetry. For example, the first
        scale of 4 notes (#2340) has D4 dihedral symmetry and so is reduced to
        just 1 mode and 3 pitch classes.
      </p>
      <p>
        You can choose both key and step display. We are currently disregarding
        temperment and consider, for instance, G♯ the same as A♭.
      </p>
    </div>
  );
};

export default About;

{
  /* <li>
  In the same column as the symmetry indicator is the listing of the
  number of correlations between each pitch class. For example, in the
  Pentatonic scale we can see if a mode is rotated 2 half-notes there
  will be 3 correlations, for 3 half-notes 2 correlations, etc. This is
  somewhat an indicator of how self-harmonic a scale is. You'll see that
  the most popular scales (like the Pentatonic and the Diatonic) have
  high correlations across rotations, especially for simple (aka high
  harmonic) pitch ratios like 5ths (7 half-notes) and 3rds (5
  half-notes).
</li> */
}
