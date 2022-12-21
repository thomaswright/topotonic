// Species

type tradition = Misc | ChinesePenta | RomanNums | ModernNums | ModernGreek

type encoding = Bits(string) | Steps(string)

type scaleName = (tradition, string)

type mode = (encoding, array<scaleName>)

type species = (encoding, array<scaleName>, array<mode>)

let namedSpecies: array<species> = [
  (
    Bits("101010010100"),
    [(Misc, "pentatonic")],
    [
      (Bits("101010010100"), [(Misc, "major pentatonic"), (ChinesePenta, `宮 gong`)]),
      (
        Bits("101001010010"),
        [(Misc, "egyptian"), (Misc, "suspended"), (ChinesePenta, `商 shang`)],
      ),
      (Bits("100101001010"), [(Misc, "blues minor"), (ChinesePenta, `角 jue`)]),
      (Bits("101001010100"), [(Misc, "blue major"), (ChinesePenta, `徵 zhi`)]),
      (Bits("100101010010"), [(Misc, "minor pentatonic"), (ChinesePenta, `羽 yu`)]),
    ],
  ),
  (
    Bits("110101101010"),
    [(Misc, "Diatonic")],
    [
      (Bits("110101101010"), [(ModernGreek, "Locrian"), (ModernNums, "7"), (RomanNums, "VII")]),
      (
        Bits("101011010101"),
        [(ModernGreek, "Ionian"), (ModernNums, "1"), (RomanNums, "I"), (Misc, "Major")],
      ),
      (Bits("101101010110"), [(ModernGreek, "Dorian"), (ModernNums, "2"), (RomanNums, "II")]),
      (Bits("110101011010"), [(ModernGreek, "Phrygian"), (ModernNums, "3"), (RomanNums, "III")]),
      (Bits("101010110101"), [(ModernGreek, "Lydian"), (ModernNums, "4"), (RomanNums, "IV")]),
      (Bits("101011010110"), [(ModernGreek, "Mixolydian"), (ModernNums, "5"), (RomanNums, "V")]),
      (
        Bits("101101011010"),
        [(ModernGreek, "Aeolian"), (ModernNums, "6"), (RomanNums, "VI"), (Misc, "Minor")],
      ),
    ],
  ),
  (Bits("110110011010"), [(Misc, "Harmonic Major")], []),
  (Bits("110101100110"), [(Misc, "Harmonic Minor")], []),
  (Steps("21414"), [(Misc, "hirajoshi")], []),
  (Steps("14232"), [(Misc, "insen")], []),
  (Steps("14142"), [(Misc, "iwato")], []),
  (Steps("321132"), [(Misc, "blues 6")], []),
  (Steps("222222"), [(Misc, "whole tone")], []),
  (Steps("222123"), [(Misc, "acoustic")], []),
  (Steps("313131"), [(Misc, "augmented")], []),
  (Steps("121215"), [(Misc, "istrian")], []),
  (Steps("222312"), [(Misc, "prometheus")], []),
  (Steps("132132"), [(Misc, "tritone")], []),
  (Steps("2121132"), [(Misc, "blues 7")], []),
  (Steps("2212221"), [(Misc, "diatonic ")], []),
  (Steps("2122221"), [(Misc, "melodic"), (Misc, "half diminished")], []),
  (Steps("2212131"), [(Misc, "harmonic major")], []),
  (Steps("2122131"), [(Misc, "harmonic minor")], []),
  (Steps("2212122"), [(Misc, "adonai malakh")], []),
  (Steps("2131131"), [(Misc, "algerian")], []),
  (Steps("1212222"), [(Misc, "altered")], []),
  (
    Steps("1312131"),
    [(Misc, "double harmonic"), (Misc, "flamenco"), (Misc, "hungarian gypsy")],
    [],
  ),
  (Steps("1322211"), [(Misc, "enigmatic")], []),
  (Steps("2131122"), [(Misc, "gypsy ")], []),
  (Steps("1222221"), [(Misc, "neapolitan major")], []),
  (Steps("1222131"), [(Misc, "neapolitan minor")], []),
  (Steps("1311231"), [(Misc, "persian")], []),
  (Steps("1312122"), [(Misc, "phrygian dominant, ukranian dorian")], []),
  (Steps("21212121"), [(Misc, "octatonic")], []),
  (Steps("22122111"), [(Misc, "bebop dominant")], []),
  (Steps("22121121"), [(Misc, "bebop major")], []),
  (Steps("212211111"), [(Misc, "melodic minor")], []),
  (Steps("111111111111"), [(Misc, "chromatic")], []),
]
