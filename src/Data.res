// Species

type tradition = Misc | ChinesePenta | Numbers | ModernGreek | Jewish

type encoding = Bits(string) | Steps(string)

type scaleName = (tradition, string)

type mode = (encoding, array<scaleName>)

type species = (encoding, array<scaleName>, array<mode>)

// let namedSpecies: array<species> = [(Steps("222222"), [(Misc, "whole tone")], [])]

let namedSpecies: array<species> = [
  (
    Bits("101010010100"),
    [(Misc, "Pentatonic")],
    [
      (Bits("101010010100"), [(Misc, "Major Pentatonic"), (ChinesePenta, `宮 Gong`)]),
      (
        Bits("101001010010"),
        [(Misc, "Egyptian"), (Misc, "Suspended"), (ChinesePenta, `商 Shang`)],
      ),
      (Bits("100101001010"), [(Misc, "Blues 5 Minor"), (ChinesePenta, `角 Jue`)]),
      (Bits("101001010100"), [(Misc, "Blues 5 Major"), (ChinesePenta, `徵 Zhi`)]),
      (Bits("100101010010"), [(Misc, "Minor Pentatonic"), (ChinesePenta, `羽 Yu`)]),
    ],
  ),
  (
    Steps("1221222"),
    [(Misc, "Diatonic")],
    [
      (Steps("1221222"), [(Numbers, "7"), (ModernGreek, "Locrian")]),
      (Steps("2212221"), [(Numbers, "1"), (ModernGreek, "Ionian"), (Misc, "Natural Major")]),
      (Steps("2122212"), [(Numbers, "2"), (ModernGreek, "Dorian")]),
      (Steps("1222122"), [(Numbers, "3"), (ModernGreek, "Phrygian")]),
      (Steps("2221221"), [(Numbers, "4"), (ModernGreek, "Lydian")]),
      (Steps("2212212"), [(Numbers, "5"), (ModernGreek, "Mixolydian"), (Jewish, "Adonai Malakh")]),
      (
        Steps("2122122"),
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
    Steps("1212222"),
    [],
    [(Steps("1212222"), [(Misc, "Altered"), (Misc, "Palamidian"), (Misc, "Super Locrian")])],
  ),
  (Steps("21414"), [(Misc, "Hirajoshi")], []),
  (Steps("14232"), [(Misc, "Insen")], []),
  (Steps("14142"), [(Misc, "Iwato")], []),
  (Steps("321132"), [(Misc, "Blues 6")], []),
  (Steps("222222"), [(Misc, "Whole Tone")], []),
  (Steps("222123"), [(Misc, "Acoustic")], []),
  (Steps("313131"), [(Misc, "Augmented")], []),
  (Steps("121215"), [(Misc, "Istrian")], []),
  (Steps("222312"), [(Misc, "Prometheus")], []),
  (Steps("132132"), [(Misc, "Tritone")], []),
  (Steps("2121132"), [(Misc, "Blues 7")], []),
  (Steps("1321212"), [], [(Steps("1321212"), [(Misc, "Romanian Major")])]),
  (Steps("2122221"), [(Misc, "Melodic"), (Misc, "Half Diminished")], []),
  (Steps("2212131"), [(Misc, "Harmonic Major")], []),
  (Steps("2121222"), [], [(Steps("2121222"), [(Jewish, "Yistabach")])]),
  (
    Steps("2122131"),
    [(Misc, "Harmonic Minor")],
    [
      (Steps("2122131"), [(Misc, "Harmonic Minor")]),
      (Steps("2131212"), [(Misc, "Ukranian Dorian"), (Jewish, "Mi Sheberach")]),
      (Steps("1312122"), [(Misc, "Phrygian Dominant"), (Jewish, "Ahavah Rabbah")]),
    ],
  ),
  (
    Steps("1312131"),
    [(Misc, "Double Harmonic")],
    [
      (Steps("1312131"), [(Misc, "Double Harmonic Major"), (Misc, "Gypsy Major")]),
      (Steps("3121311"), [(Misc, "")]),
      (Steps("1213113"), [(Misc, "Ultraphrygian")]),
      (
        Steps("2131131"),
        [
          (Misc, "Double Harmonic Minor"),
          (Misc, "Hungarian Minor"),
          (Misc, "Gypsy Minor"),
          (Misc, "Algerian"),
        ],
      ),
      (Steps("1311312"), [(Misc, "Oriental")]),
      (Steps("3113121"), [(Misc, "")]),
      (Steps("1131213"), [(Misc, "")]),
    ],
  ),
  (Steps("1322211"), [], [(Steps("1322211"), [(Misc, "Enigmatic")])]),
  (
    Steps("1222131"),
    [(Misc, "Neapolitan Minor")],
    [
      (Steps("1222131"), [(Misc, "Neapolitan Minor ")]),
      (Steps("2131122"), [(Misc, "Gypsy Minor")]),
      (Steps("1122213"), [(Misc, "Ultralocrian")]),
    ],
  ),
  (
    Steps("1222221"),
    [(Misc, "Neapolitan Major")],
    [
      (Steps("1222221"), [(Misc, "Neapolitan Major")]),
      (Steps("2222211"), [(Misc, "Leading Whole Tone")]),
      (Steps("2112222"), [(Misc, "Major Locrian")]),
    ],
  ),
  (Steps("1311231"), [(Misc, "Persian")], []),
  (Steps("21212121"), [(Misc, "Octatonic")], []),
  (Steps("22122111"), [(Misc, "Bebop Dominant")], []),
  (Steps("22121121"), [(Misc, "Bebop Major")], []),
  (Steps("212211111"), [(Misc, "Melodic Minor")], []),
  (Steps("111111111111"), [(Misc, "Chromatic")], []),
]
