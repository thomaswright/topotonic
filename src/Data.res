// Species

type tradition = Misc | ChinesePenta | Numbers | ModernGreek | Jewish | MiddleEast

// type encoding = Bits(string) | (string)

type scaleName = (tradition, string)

type mode = (string, array<scaleName>)

type species = (string, array<scaleName>, array<mode>)

// let namedSpecies: array<species> = [(("222222"), [(Misc, "whole tone")], [])]

let namedSpecies: array<species> = [
  (
    "22323",
    [(Misc, "Pentatonic")],
    [
      ("22323", [(Misc, "Major Pentatonic"), (ChinesePenta, `宮 Gong`), (MiddleEast, "Ajam")]),
      ("23232", [(Misc, "Egyptian"), (Misc, "Suspended Pentatonic"), (ChinesePenta, `商 Shang`)]),
      ("32322", [(Misc, "Blues 5 Minor"), (ChinesePenta, `角 Jue`)]),
      (
        "23223",
        [(Misc, "Ritsusen"), (Misc, "Yo"), (Misc, "Blues 5 Major"), (ChinesePenta, `徵 Zhi`)],
      ),
      ("23223", [(Misc, "Minor Pentatonic"), (ChinesePenta, `羽 Yu`)]),
    ],
  ),
  (
    "1221222",
    [(Misc, "Diatonic")],
    [
      ("1221222", [(Numbers, "7"), (ModernGreek, "Locrian")]),
      ("2212221", [(Numbers, "1"), (ModernGreek, "Ionian"), (Misc, "Natural Major")]),
      ("2122212", [(Numbers, "2"), (ModernGreek, "Dorian")]),
      ("1222122", [(Numbers, "3"), (ModernGreek, "Phrygian")]),
      ("2221221", [(Numbers, "4"), (ModernGreek, "Lydian")]),
      ("2212212", [(Numbers, "5"), (ModernGreek, "Mixolydian"), (Jewish, "Adonai Malakh")]),
      (
        "2122122",
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
    [],
    [("1212222", [(Misc, "Altered"), (Misc, "Palamidian"), (Misc, "Super Locrian")])],
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
  ("1321212", [], [("1321212", [(Misc, "Romanian Major")])]),
  ("2122221", [(Misc, "Melodic"), (Misc, "Half Diminished")], []),
  ("2212131", [(Misc, "Harmonic Major")], []),
  ("2121222", [], [("2121222", [(Jewish, "Yistabach")])]),
  (
    "2122131",
    [(Misc, "Harmonic Minor")],
    [
      ("2122131", [(Misc, "Harmonic Minor")]),
      ("2131212", [(Misc, "Ukranian Dorian"), (Jewish, "Mi Sheberach")]),
      ("1312122", [(Misc, "Phrygian Dominant"), (Jewish, "Ahavah Rabbah"), (MiddleEast, "Hijaz")]),
    ],
  ),
  (
    "1312131",
    [(Misc, "Double Harmonic")],
    [
      ("1312131", [(Misc, "Double Harmonic Major"), (Misc, "Gypsy Major")]),
      ("3121311", [(Misc, "")]),
      ("1213113", [(Misc, "Ultraphrygian")]),
      (
        "2131131",
        [
          (Misc, "Double Harmonic Minor"),
          (Misc, "Hungarian Minor"),
          (Misc, "Gypsy Minor"),
          (Misc, "Algerian"),
          (MiddleEast, "Nawa Athar"),
        ],
      ),
      ("1311312", [(Misc, "Oriental")]),
      ("3113121", [(Misc, "")]),
      ("1131213", [(Misc, "")]),
    ],
  ),
  ("1322211", [], [("1322211", [(Misc, "Enigmatic")])]),
  (
    "1222131",
    [(Misc, "Neapolitan Minor")],
    [
      ("1222131", [(Misc, "Neapolitan Minor ")]),
      ("2131122", [(Misc, "Gypsy Minor")]),
      ("1122213", [(Misc, "Ultralocrian")]),
    ],
  ),
  (
    "1222221",
    [(Misc, "Neapolitan Major")],
    [
      ("1222221", [(Misc, "Neapolitan Major")]),
      ("2222211", [(Misc, "Leading Whole Tone")]),
      ("2112222", [(Misc, "Major Locrian")]),
    ],
  ),
  ("1311231", [(Misc, "Persian")], []),
  ("21212121", [(Misc, "Octatonic")], []),
  ("22122111", [(Misc, "Bebop Dominant")], []),
  ("22121121", [(Misc, "Bebop Major")], []),
  ("212211111", [(Misc, "Melodic Minor"), (MiddleEast, "Nahawand")], []),
  ("111111111111", [(Misc, "Chromatic")], []),
]
