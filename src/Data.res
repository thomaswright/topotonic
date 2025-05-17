type tradition = Misc | ChinesePenta | Numbers | ModernGreek | Jewish | MiddleEast

type scaleName = (tradition, string)

type mode = (int, array<scaleName>)

type species = (string, array<scaleName>, array<mode>)

let namedSpecies: array<species> = [
  ("255", [], [(0, [(Misc, "Suspended second")]), (2, [(Misc, "Suspended fourth")])]),
  (
    "435",
    [(Misc, "Major triad")],
    [
      (0, [(Misc, "Major triad, root position")]),
      (1, [(Misc, "Major triad, 1st inversion")]),
      (2, [(Misc, "Major triad, 2nd inversion")]),
    ],
  ),
  (
    "4323",
    [(Misc, "Major sixth"), (Misc, "Minor seventh")],
    [
      (0, [(Misc, "Major sixth, root position")]),
      (1, [(Misc, "Major sixth, 1st inversion")]),
      (2, [(Misc, "Major sixth, 2nd inversion")]),
      (3, [(Misc, "Minor seventh")]),
    ],
  ),
  (
    "4332",
    [(Misc, "Dominant seventh")],
    [
      (0, [(Misc, "Dominant seventh, root position")]),
      (1, [(Misc, "Dominant seventh, 1st inversion")]),
      (2, [(Misc, "Dominant seventh, 2nd inversion")]),
      (3, [(Misc, "Dominant seventh, 3rd inversion")]),
    ],
  ),
  (
    "4341",
    [(Misc, "Major seventh")],
    [
      (0, [(Misc, "Major seventh, root position")]),
      (1, [(Misc, "Major seventh, 1st inversion")]),
      (2, [(Misc, "Major seventh, 2nd inversion")]),
      (3, [(Misc, "Major seventh, 3rd inversion")]),
    ],
  ),
  ("444", [(Misc, "Augmented triad")], []),
  (
    "4422",
    [(Misc, "Augmented seventh")],
    [
      (0, [(Misc, "Augmented seventh, root position")]),
      (1, [(Misc, "Augmented seventh, 1st inversion")]),
      (2, [(Misc, "Augmented seventh, 2nd inversion")]),
      (3, [(Misc, "Augmented seventh, 3rd inversion")]),
    ],
  ),
  (
    "345",
    [(Misc, "Minor triad")],
    [
      (0, [(Misc, "Minor triad, root position")]),
      (1, [(Misc, "Minor triad, 1st inversion")]),
      (2, [(Misc, "Minor triad, 2nd inversion")]),
    ],
  ),
  (
    "3423",
    [(Misc, "Minor sixth"), (Misc, "Half-diminished seventh")],
    [
      (0, [(Misc, "Minor sixth, root position")]),
      (1, [(Misc, "Minor sixth, 1st inversion")]),
      (2, [(Misc, "Minor sixth, 2nd inversion")]),
      (3, [(Misc, "Half-diminished seventh")]),
    ],
  ),
  (
    "3441",
    [(Misc, "Minor-major seventh")],
    [
      (0, [(Misc, "Minor-major seventh, root position")]),
      (1, [(Misc, "Minor-major seventh, 1st inversion")]),
      (2, [(Misc, "Minor-major seventh, 2nd inversion")]),
      (3, [(Misc, "Minor-major seventh, 3rd inversion")]),
    ],
  ),
  (
    "336",
    [(Misc, "Diminished triad")],
    [
      (0, [(Misc, "Diminished triad, root position")]),
      (1, [(Misc, "Diminished triad, 1st inversion")]),
      (2, [(Misc, "Diminished triad, 2nd inversion")]),
    ],
  ),
  ("3333", [(Misc, "Diminished seventh")], []),
  ("22332", [(Misc, "Dominant ninth")], [(0, [(Misc, "Dominant ninth, root position")])]),
  ("221232", [(Misc, "Dominant eleventh")], [(0, [(Misc, "Dominant eleventh, root position")])]),
  (
    "22323",
    [(Misc, "Pentatonic")],
    [
      (0, [(Misc, "Major Pentatonic"), (ChinesePenta, `宮 Gong`), (MiddleEast, "Ajam")]),
      (
        1,
        [
          (Misc, "Egyptian"),
          (Misc, "Suspended Pentatonic"),
          (Misc, "Jazz sus"),
          (ChinesePenta, `商 Shang`),
        ],
      ),
      (2, [(Misc, "Blues 5 Minor"), (ChinesePenta, `角 Jue`)]),
      (3, [(Misc, "Ritsusen"), (Misc, "Yo"), (Misc, "Blues 5 Major"), (ChinesePenta, `徵 Zhi`)]),
      (4, [(Misc, "Minor Pentatonic"), (ChinesePenta, `羽 Yu`)]),
    ],
  ),
  (
    "1221222",
    [(Misc, "Diatonic")],
    [
      (0, [(Numbers, "7"), (ModernGreek, "Locrian")]),
      (1, [(Numbers, "1"), (ModernGreek, "Ionian"), (Misc, "Natural Major")]),
      (2, [(Numbers, "2"), (ModernGreek, "Dorian")]),
      (3, [(Numbers, "3"), (ModernGreek, "Phrygian")]),
      (4, [(Numbers, "4"), (ModernGreek, "Lydian")]),
      (
        5,
        [
          (Numbers, "5"),
          (ModernGreek, "Mixolydian"),
          (Misc, "Dominant thirteenth"),
          (Jewish, "Adonai Malakh"),
        ],
      ),
      (
        6,
        [
          (Numbers, "6"),
          (ModernGreek, "Aeolian"),
          (Misc, "Natural Minor"),
          (Jewish, "Magein Avot"),
        ],
      ),
    ],
  ),
  (
    "1212222",
    [(Misc, "Jazz Minor"), (Misc, "Ascending Melodic Minor")],
    [
      (
        0,
        [
          (Misc, "Altered"),
          (Misc, "Altered Dominant"),
          (Misc, "Super Locrian"),
          (Misc, "Jazz Minor VII"),
        ],
      ),
      (1, [(Misc, "Jazz Minor I")]),
      (2, [(Misc, "Dorian ♭2"), (Misc, "Phrygian ♮6"), (Misc, "Jazz Minor II")]),
      (3, [(Misc, "Lydian Augmented"), (Misc, "Jazz Minor III")]),
      (
        4,
        [
          (Misc, "Acoustic"),
          (Misc, "Lydian Dominant"),
          (Misc, "Mixolydian ♯4"),
          (Misc, "Overtone"),
          (Misc, "Jazz Minor IV"),
        ],
      ),
      (
        5,
        [
          (Misc, "Aeolian Dominant"),
          (Misc, "Mixolydian ♭6"),
          (Misc, "Descending Melodic Major"),
          (Misc, "Hindu"),
          (Misc, "Jazz Minor V"),
        ],
      ),
      (
        6,
        [
          (Misc, "Half-diminished"),
          (Misc, "Locrian ♮2"),
          (Misc, "Aeolian ♭5"),
          (Misc, "Jazz Minor VI"),
        ],
      ),
    ],
  ),
  ("14142", [], [(0, [(Misc, "Iwato")]), (3, [(Misc, "Hirajoshi")])]),
  ("14232", [], [(0, [(Misc, "Insen")])]),
  ("113232", [], [(4, [(Misc, "Blues 6")])]),
  ("222222", [(Misc, "Whole Tone")], []),
  ("131313", [], [(1, [(Misc, "Augmented")])]),
  ("121215", [], [(0, [(Misc, "Istrian")])]),
  ("122223", [], [(2, [(Misc, "Prometheus")])]),
  ("132132", [(Misc, "Tritone")], []),
  ("1132212", [], [(4, [(Misc, "Blues 7")])]),
  ("1212132", [], [(5, [(Misc, "Romanian Major")])]),
  ("1213122", [(Misc, "Harmonic Major")], [(5, [(Misc, "Harmonic Major I")])]),
  ("2121222", [], [(0, [(Jewish, "Yistabach")])]),
  (
    "1212213",
    [(Misc, "Harmonic Minor")],
    [
      (1, [(Misc, "Harmonic Minor I")]),
      (4, [(Misc, "Ukranian Dorian"), (Jewish, "Mi Sheberach")]),
      (5, [(Misc, "Phrygian Dominant"), (Jewish, "Ahavah Rabbah"), (MiddleEast, "Hijaz")]),
    ],
  ),
  (
    "1131213",
    [(Misc, "Double Harmonic")],
    [
      (
        1,
        [
          (Misc, "Double Harmonic Major"),
          (Misc, "Gypsy Major"),
          (Misc, "Byzantine"),
          (Misc, "Arabic (Hijaz Kar)"),
          (Misc, "Bhairav Raga"),
          (Misc, "Mayamalavagowla"),
        ],
      ),
      (2, [(Misc, "")]),
      (3, [(Misc, "Ultraphrygian")]),
      (
        4,
        [
          (Misc, "Double Harmonic Minor"),
          (Misc, "Hungarian Minor"),
          (Misc, "Gypsy Minor"),
          (Misc, "Algerian (First Octave)"),
          (MiddleEast, "Nawa Athar"),
        ],
      ),
      (5, [(Misc, "Oriental")]),
      (6, [(Misc, "")]),
      (0, [(Misc, "")]),
    ],
  ),
  ("1212123", [], [(6, [(Misc, "Hungarian Major")])]),
  ("1113222", [], [(2, [(Misc, "Enigmatic")])]),
  (
    "1122213",
    [],
    [
      (1, [(Misc, "Neapolitan Minor")]),
      (4, [(Misc, "Gypsy Minor")]),
      (0, [(Misc, "Ultralocrian")]),
    ],
  ),
  (
    "1122222",
    [],
    [
      (1, [(Misc, "Neapolitan Major")]),
      (2, [(Misc, "Leading Whole Tone")]),
      (6, [(Misc, "Major Locrian")]),
    ],
  ),
  ("1123113", [], [(5, [(Misc, "Persian")])]),
  ("12121212", [(Misc, "Octatonic")], []),
  ("11122122", [], [(3, [(Misc, "Bebop Dominant")])]),
  ("11212212", [], [(2, [(Misc, "Bebop Harmonic Minor")]), (4, [(Misc, "Bebop Major")])]),
  ("11212122", [], [(4, [(Misc, "Bebop Melodic Minor")])]),
  ("11221122", [], [(2, [(Misc, "Seventh flat 5 diminished")])]),
  ("111112122", [(Misc, "Melodic Minor"), (MiddleEast, "Nahawand")], []),
  ("111211122", [], [(3, [(Misc, "Blues 9")])]),
  ("111111111111", [(Misc, "Chromatic")], []),
]

// Possible Additions:
// - Messiaen Modes
