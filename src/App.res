open Belt

// todo:
// - symmetry with respect to root
// - pitch classes
// - enharmonics
// - named keys
// - shifts
// - all symmetries

let join = Js.Array2.joinWith(_, " ")

let any = (a, test) =>
  a->Array.reduce(false, (acc, element) => {
    acc ? true : test(element)
  })

module Collapsed = {
  @react.component
  let make = (~render) => {
    let (state, set) = React.useState(() => true)

    render(state, set)
  }
}

type triSwitch = One | Two | Three

module CollapsedTri = {
  @react.component
  let make = (~render) => {
    let (state, set) = React.useState(() => One)

    render(state, set)
  }
}

module SVG = {
  @module("./SVG.jsx") @react.component
  external make: (~data: array<(string, int)>) => React.element = "SVG"
}

module Config = {
  let bits = 12
}

let reactMap = (a, f) => a->Array.map(f)->React.array

let reactMapWithIndex = (a, f) => a->Array.mapWithIndex(f)->React.array

let str = React.string

let rec padLeft = (s, l, pad) => {
  s->Js.String2.length < l ? padLeft(pad ++ s, l, pad) : s
}

type bitArray = array<string>

module BitOps = {
  let stringToStringArray = x => x->Js.String2.castToArrayLike->Js.Array2.from

  let stringArrayToString = x => x->Array.reduce("", (acc, value) => acc ++ value)

  let stringArrayToIntArray = x => x->Array.map(x => x->Int.fromString->Option.getWithDefault(0))

  let stringToIntArray = x => x->stringToStringArray->stringArrayToIntArray

  let intArrayToString = x => x->Array.reduce("", (acc, value) => acc ++ value->Int.toString)

  let stringArrayToInt = x =>
    x
    ->Array.reverse
    ->Array.reduceWithIndex(0, (acc, value, i) => {
      value
      ->Int.fromString
      ->Option.mapWithDefault(acc, valueInt => {
        (valueInt->Int.toFloat *. 2. ** i->Int.toFloat)->Int.fromFloat + acc
      })
    })

  let stringToInt = x => x->stringToStringArray->stringArrayToInt
}

let getPermsForBitLength = numOfBits =>
  Array.range(0, (2. ** numOfBits->Int.toFloat -. 1.)->Float.toInt)->Array.map(x =>
    x->Js.Int.toStringWithRadix(~radix=2)->padLeft(numOfBits, "0")
  )

let count1s = bitArray =>
  bitArray->Array.reduce(0, (acc, value) => {
    value == "1" ? acc + 1 : acc
  })

let groupByGenus = x =>
  x->Array.reduce(Map.Int.empty, (acc, value) => {
    let genus = value->count1s
    acc->Map.Int.update(genus, a =>
      a->Option.mapWithDefault([value]->Some, b => Array.concat(b, [value])->Some)
    )
  })

let rec rotate = (x, shift) => {
  shift > 0 ? Array.concat(x->Js.Array2.sliceFrom(1), [x->Array.getExn(0)])->rotate(shift - 1) : x
}

let getRotations = x => {
  let unordered = Array.range(0, x->Array.length - 1)->Array.map(i => {
    x->rotate(i)
  })

  let _orderedShiftingRight = Array.concat(
    [unordered->Array.getExn(0)],
    unordered->Js.Array2.sliceFrom(1)->Array.reverse,
  )

  let orderedShiftingLeft = Array.concat(
    [unordered->Array.getExn(0)],
    unordered->Js.Array2.sliceFrom(1),
  )

  orderedShiftingLeft
}

let getGreatestRotation = x => {
  let rotations = getRotations(x)

  rotations->Array.reduce(rotations->Array.getExn(0), (acc, value) => {
    let valueDecRep = value->BitOps.stringArrayToInt
    let accDecRep = acc->BitOps.stringArrayToInt
    valueDecRep > accDecRep ? value : acc
  })
}

let startsWith1 = a => a->Array.getExn(0) == "1"

let removeZeroStarts = x => {
  x->Array.keep(startsWith1)
}

let removeDuplicates = x => {
  x
  ->Array.map(a => (a->BitOps.stringArrayToString, ""))
  ->Map.String.fromArray
  ->Map.String.keysToArray
  ->Array.map(a => a->BitOps.stringToStringArray)
}

// type rotationDetails = {
//   shift: int,
//   rotation: array<string>,
//   startsWith1: bool,
// }

type speciesDetails = {
  modes: array<(string, array<int>)>,
  autoCorrelations: array<string>,
  isSymmetric: bool,
}

let isSameArray = (a: array<string>, b: array<string>) =>
  Array.zip(a, b)->Array.every(((a1, b1)) => a1 == b1)

let hasBilateralSymmetry = (x: array<string>) => {
  let l = x->Array.length

  mod(l, 2) == 0
    ? {
        let (a, b) = (
          x->Js.Array2.slice(~start=1, ~end_=l / 2),
          x->Js.Array2.sliceFrom(l / 2 + 1)->Array.reverse,
        )
        let (c, d) = (
          x->Js.Array2.slice(~start=0, ~end_=l / 2),
          x->Js.Array2.sliceFrom(l / 2)->Array.reverse,
        )
        // Js.log4(a, b, c, d)
        isSameArray(a, b) || isSameArray(c, d)
      }
    : {
        let (a, b) = (
          x->Js.Array2.slice(~start=1, ~end_=(l + 1) / 2),
          x->Js.Array2.sliceFrom((l + 1) / 2),
        )
        isSameArray(a, b->Array.reverse)
      }
}

let mapAppend = (m, k, v) => {
  m->Map.String.update(k, a => a->Option.mapWithDefault([v]->Some, b => Array.concat(b, [v])->Some))
}

let groupBySpecies = genusGrouping =>
  genusGrouping->Map.Int.map(genusPerms => {
    genusPerms
    ->Array.reduce(Map.String.empty, (acc, value) => {
      let greatestRotation = value->getGreatestRotation->BitOps.stringArrayToString
      acc->mapAppend(greatestRotation, value)
    })
    ->Map.String.keysToArray
    ->Array.map(speciesId => {
      let rotations = speciesId->BitOps.stringToStringArray->getRotations
      // ->Array.mapWithIndex(
      //   (index, rotation) => {
      //     shift: index,
      //     rotation,
      //     startsWith1: rotation->Array.getExn(0) == "1",
      //   },
      // )

      let modes =
        rotations
        ->Array.reduceWithIndex(
          Map.String.empty,
          (acc, value, index) => {
            acc->mapAppend(value->BitOps.stringArrayToString, index)
          },
        )
        ->Map.String.toArray
        ->Belt.SortArray.stableSortBy(((_, a), (_, b)) => a->Array.getExn(0) - b->Array.getExn(0))

      (speciesId, modes)
    })
    ->Map.String.fromArray
    ->Map.String.mapWithKey((speciesId, modes) => {
      // let _numOfAutoCorrelations = switch (modes->Array.get(0), modes->Array.get(1)) {
      // | (Some(a1), Some(a2)) =>
      //   Array.zip(a1, a2)->Array.keep(((a1, a2)) => a1 == "1" && a2 == "1")->Array.length
      // | (_, _) => 0
      // }

      let rotations = speciesId->BitOps.stringToStringArray->getRotations
      {
        modes,
        autoCorrelations: modes
        ->Array.get(0)
        ->Option.mapWithDefault(
          [],
          ((modeId, _)) =>
            rotations->Array.map(
              p => {
                p->BitOps.stringArrayToString == modeId
                  ? "_"
                  : Array.zip(p, modeId->BitOps.stringToStringArray)
                    ->Array.keep(((a1, a2)) => a1 == "1" && a2 == "1")
                    ->Array.length
                    ->Int.toString
              },
            ),
        ),
        isSymmetric: rotations->any(p => p->hasBilateralSymmetry),
      }
    })
  })

let result =
  Config.bits
  ->getPermsForBitLength
  ->Array.map(BitOps.stringToStringArray)
  ->groupByGenus
  ->groupBySpecies

let keys = [
  `C`,
  `C♯/D♭`,
  `D`,
  `D♯/E♭`,
  `E`,
  `F`,
  `F♯/G♭`,
  `G`,
  `G♯/A♭`,
  `A`,
  `A♯/B♭`,
  `B`,
]

let keysShort = [`C`, `C♯`, `D`, `D♯`, `E`, `F`, `F♯`, `G`, `G♯`, `A`, `A♯`, `B`]

// let intervals = [`C`, `C♯`, `D`, `D♯`, `E`, `F`, `F♯`, `G`, `G♯`, `A`, `A♯`, `B`]

let namedSpecies = [
  (
    "110101101010",
    ["Diatonic"],
    [
      ["Locrian", "7"],
      ["Ionian", "1"],
      ["Dorian", "2"],
      ["Phrygian", "3"],
      ["Lydian", "4"],
      ["Mixolydian", "5"],
      ["Aeolian", "6"],
    ],
  ),
  ("110110011010", ["Harmonic Major"], []),
  ("110101100110", ["Harmonic Minor"], []),
  ("", [""], []),
  ("", [""], []),
  ("", [""], []),
  ("", [""], []),
]

let spacedToBits = a => {
  a->Array.reduce("1", (acc, value) => {
    acc ++
    switch value {
    | 1 => "1"
    | 2 => "10"
    | 3 => "100"
    | 4 => "1000"
    | _ => ""
    }
  })
}

type kind = Species | Mode | NonMode

// type bitDisplay = Bit | Index

let bitToDisplaySymbol = (bit, index, currentKey, default) => {
  currentKey->Option.mapWithDefault(default, shift =>
    bit == "0" ? "-" : keysShort->rotate(shift)->Array.get(index)->Option.getWithDefault("")
  )
}

module Scale = {
  @react.component
  let make = (~onClick, ~bitString, ~currentKey, ~kind: kind, ~selected: bool) => {
    <div
      onClick={onClick}
      className={[
        " flex flex-row ",
        switch kind {
        | Species => "font-bold"
        | Mode => selected ? "bg-blue-300" : ""
        | NonMode => selected ? "text-neutral-400 bg-blue-300" : "text-neutral-400"
        },
      ]->join}>
      {bitString
      ->BitOps.stringToStringArray
      ->Array.mapWithIndex((i, bit) => {
        <div
          className={[
            currentKey->Option.isSome ? "w-5" : "w-5",
            "flex flex-row justify-center",
          ]->join}>
          {bitToDisplaySymbol(bit, i, currentKey, bit)->str}
        </div>
      })
      ->React.array}
    </div>
  }
}

module Key = {
  @react.component
  let make = (~selected, ~onClick, ~children) => {
    <div className={[selected ? "bg-blue-300" : "", "rounded p-1 pl-2"]->join} onClick={onClick}>
      {children}
    </div>
  }
}

module Species = {
  @react.component
  let make = (
    ~currentBits,
    ~setCurrentBits,
    ~currentKey,
    ~speciesId,
    ~speciesDetails: speciesDetails,
  ) => {
    let (base, setBase) = React.useState(_ => None)

    <Collapsed
      render={(speciesHidden, setSpeciesHidden) => {
        let anySelected = speciesDetails.modes->any(((rotation, _)) => {
          currentBits->Option.mapWithDefault(false, c => c->BitOps.intArrayToString == rotation)
        })

        <div
          className={[
            !speciesHidden ? "bg-blue-50 border-blue-200 mb-1" : "border-transparent",
            "border rounded-sm",
          ]->join}>
          <div className="flex flex-row items-center justify-start gap-3">
            <Scale
              selected={false}
              onClick={_ => {
                currentBits->Option.mapWithDefault(
                  {
                    setSpeciesHidden(_ => false)
                    setCurrentBits(_ => speciesId->BitOps.stringToIntArray->Some)
                  },
                  _ => {
                    setSpeciesHidden(_ => !speciesHidden ? anySelected : !speciesHidden)
                    setCurrentBits(_ =>
                      anySelected ? None : speciesId->BitOps.stringToIntArray->Some
                    )
                  },
                )
              }}
              currentKey={currentKey}
              bitString={speciesId}
              kind={Species}
            />
            <div className="w-6"> {speciesDetails.isSymmetric ? "x"->str : ""->str} </div>
            <div className="text-sm whitespace-nowrap">
              {speciesDetails.modes
              ->Array.keep(((modeId, _)) => modeId->BitOps.stringToStringArray->startsWith1)
              ->Array.length
              ->Int.toString
              ->str}
              {" modes"->str}
            </div>
            <div className="text-sm whitespace-nowrap">
              {speciesDetails.modes->Array.length->Int.toString->str}
              {" pitch classes"->str}
            </div>
          </div>
          <div
            className={[
              speciesHidden ? "hidden " : "",
              "pt-0.5 pb-2 border-t border-neutral-400",
            ]->join}>
            {speciesDetails.modes->reactMap(((modeId, rotationDegrees)) => {
              let selected =
                currentBits->Option.mapWithDefault(false, c => c->BitOps.intArrayToString == modeId)
              <div className="flex flex-row">
                <Scale
                  selected={selected}
                  onClick={_ => setCurrentBits(_ => modeId->BitOps.stringToIntArray->Some)}
                  currentKey={currentKey}
                  bitString={modeId}
                  kind={modeId->BitOps.stringToStringArray->startsWith1 ? Mode : NonMode}
                />
                {currentKey->Option.isSome
                  ? {
                      base->Option.mapWithDefault(
                        <button onClick={_ => setBase(_ => Some(modeId))}> {"Base"->str} </button>,
                        b =>
                          b == modeId
                            ? <button onClick={_ => setBase(_ => None)}> {"Remove"->str} </button>
                            : React.null,
                      )
                    }
                  : React.null}
                <div className="text-neutral-700 text-xs">
                  {`[${rotationDegrees
                    ->Array.map(degree =>
                      bitToDisplaySymbol("1", degree, currentKey, degree->Int.toString)
                    )
                    ->Js.Array2.joinWith(_, ", ")}]`->str}
                </div>
              </div>
            })}
            <div className="text-xs text-green-600 flex flex-row ">
              {speciesDetails.autoCorrelations->reactMap(x => {
                <div className={["w-5 flex flex-row items-center justify-center"]->join}>
                  {x->str}
                </div>
              })}
            </div>
          </div>
        </div>
      }}
    />
  }
}

@react.component
let make = () => {
  let (currentBits, setCurrentBits) = React.useState(_ => None)
  let (currentKey: option<int>, setCurrentKey) = React.useState(_ => None)

  let graphKeys =
    currentKey->Option.mapWithDefault(keys->Array.mapWithIndex((i, _) => i->Int.toString), shift =>
      keys->rotate(shift)
    )
  let graphBits = currentBits->Option.mapWithDefault(keys->Array.map(_ => 0), b => b)

  <div className={"flex flex-row h-screen w-screen font-mono"}>
    <div className=" h-full flex flex-col p-4">
      <div className={"h-80 w-80"}>
        <SVG data={Array.zip(graphKeys, graphBits)} />
      </div>
      <div className={"flex-1 overflow-scroll p-1 border rounded"}>
        <Key selected={currentKey->Option.isNone} onClick={_ => setCurrentKey(_ => None)}>
          {"None"->str}
        </Key>
        {keys->reactMapWithIndex((i, v) => {
          let selected = currentKey->Option.mapWithDefault(false, c => c == i)

          <Key selected={selected} onClick={_ => setCurrentKey(_ => Some(i))}> {v->str} </Key>
        })}
      </div>
    </div>
    <div className="flex-1 h-full overflow-scroll pr-4">
      {result
      ->Map.Int.toArray
      ->reactMap(((genusId, species)) =>
        <CollapsedTri
          render={(genusCollapsedState, setGenusCollapsedState) => {
            <div className={"mb-1"}>
              <div
                onClick={_ => {
                  setGenusCollapsedState(s =>
                    switch s {
                    | One => Two
                    | Two => Three
                    | Three => One
                    }
                  )
                }}
                className="flex flex-row items-center px-4 ">
                <div className="flex-1 text-lg"> {genusId->Int.toString->str} </div>
                <div className="flex-1 text-sm whitespace-nowrap">
                  {species->Map.String.toArray->Array.length->Int.toString->str}
                  {" species"->str}
                </div>
              </div>
              <div
                className={[
                  switch genusCollapsedState {
                  | One => "hidden"
                  | Two => "max-h-64"
                  | Three => ""
                  },
                  "overflow-scroll p-2 pb-6 border",
                ]->join}>
                {species
                ->Map.String.toArray
                ->Array.reverse
                ->reactMap(((speciesId, speciesDetails)) =>
                  <Species
                    currentBits={currentBits}
                    setCurrentBits={setCurrentBits}
                    currentKey={currentKey}
                    speciesId={speciesId}
                    speciesDetails={speciesDetails}
                  />
                )}
              </div>
            </div>
          }}
        />
      )}
    </div>
  </div>
}

let default = make
