// Species

type tradition = Misc | ChinesePenta | Numbers | ModernGreek | Jewish | MiddleEast

// type encoding = Bits(string) | (string)

type scaleName = (tradition, string)

type mode = (int, array<scaleName>)

type species = (string, array<scaleName>, array<mode>)

// let namedSpecies: array<species> = [(("222222"), [(Misc, "whole tone")], [])]

let namedSpecies: array<species> = [
  (
    "22323",
    [(Misc, "Pentatonic")],
    [
      (0, [(Misc, "Major Pentatonic"), (ChinesePenta, `宮 Gong`), (MiddleEast, "Ajam")]),
      (1, [(Misc, "Egyptian"), (Misc, "Suspended Pentatonic"), (ChinesePenta, `商 Shang`)]),
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
      (5, [(Numbers, "5"), (ModernGreek, "Mixolydian"), (Jewish, "Adonai Malakh")]),
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
    [(Misc, "Melodic"), (Misc, "Half Diminished")],
    [(0, [(Misc, "Altered"), (Misc, "Palamidian"), (Misc, "Super Locrian")])],
  ),
  ("21414", [(Misc, "Hirajoshi")], []),
  ("14232", [(Misc, "Insen")], []),
  ("14142", [(Misc, "Iwato")], []),
  ("321132", [(Misc, "Blues 6")], []),
  ("222222", [(Misc, "Whole Tone")], []),
  ("222123", [(Misc, "Acoustic")], []),
  ("313131", [(Misc, "Augmented")], []),
  ("121215", [(Misc, "Istrian")], []),
  ("222312", [(Misc, "Prometheus")], []),
  ("132132", [(Misc, "Tritone")], []),
  ("2121132", [(Misc, "Blues 7")], []),
  ("1212132", [], [(5, [(Misc, "Romanian Major")])]),
  ("2212131", [(Misc, "Harmonic Major")], []),
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
      (1, [(Misc, "Double Harmonic Major"), (Misc, "Gypsy Major")]),
      (2, [(Misc, "")]),
      (3, [(Misc, "Ultraphrygian")]),
      (
        4,
        [
          (Misc, "Double Harmonic Minor"),
          (Misc, "Hungarian Minor"),
          (Misc, "Gypsy Minor"),
          (Misc, "Algerian"),
          (MiddleEast, "Nawa Athar"),
        ],
      ),
      (5, [(Misc, "Oriental")]),
      (6, [(Misc, "")]),
      (0, [(Misc, "")]),
    ],
  ),
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
  ("11122122", [(Misc, "Bebop Dominant")], []),
  ("11212212", [(Misc, "Bebop Major")], []),
  ("111112122", [(Misc, "Melodic Minor"), (MiddleEast, "Nahawand")], []),
  ("111111111111", [(Misc, "Chromatic")], []),
]
