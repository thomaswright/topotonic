open Belt

/*
todo:
- symmetry with respect to root
- symmetries (n point, star n point)
- enharmonics / temperments
- just interval
- if has mode but not species
- all scales
- score based on correlations * best intervals

*/

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

module Logo = {
  @module("./Icons.jsx") @react.component
  external make: (~size: int) => React.element = "Logo"
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

// let namedData = Data.namedSpecies-> Array.

let pitchKeys = [
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

let pitchKeysShort = [`C`, `C♯`, `D`, `D♯`, `E`, `F`, `F♯`, `G`, `G♯`, `A`, `A♯`, `B`]
let semitones = [`0`, `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `11`]
let mMPs = [`P1`, `m2`, `M2`, `m3`, `M3`, `P4`, `TT`, `P5`, `m6`, `M6`, `m7`, `M7`]
// TODO: replace TT with d5/A4 when we have proper scaling
let dimAugs = [`d2`, `A1`, `d3`, `A2`, `d4`, `A3`, `TT`, `d6`, `A5`, `d7`, `A6`, `d8`]

let stepsToBits = x => {
  x->Array.reduce("", (acc, value) => {
    acc ++
    switch value {
    | 1 => "1"
    | 2 => "10"
    | 3 => "100"
    | 4 => "1000"
    | 5 => "10000"
    | 6 => "100000"
    | _ => ""
    }
  })
}

let bitsToSemitoneSteps = x => {
  x
  ->Js.String2.split("1")
  ->Array.map(a => {
    a->Js.String2.length + 1
  })
  ->Belt.Array.sliceToEnd(1)
}

let bitsToHalfnoteSteps = x => {
  x
  ->Js.String2.split("1")
  ->Array.map(a => {
    switch a->Js.String2.length + 1 {
    | 1 => "H"
    | 2 => "W"
    | l => mod(l, 2) == 0 ? (l / 2)->Int.toString ++ "W" : l->Int.toString ++ "H"
    }
  })
  ->Belt.Array.sliceToEnd(1)
}

type key = Pitch(int) | MinMaj | DimAug | Semitone | SemitoneSteps | HalfnoteSteps

type kind = Species | Mode | NonMode

// type bitDisplay = Bit | Index

let bitToDisplaySymbol = (bit, index, currentKey) => {
  switch currentKey {
  | None => bit
  | Some(x) => {
      let a = switch x {
      | Pitch(shift) => pitchKeysShort->rotate(shift)
      | DimAug => dimAugs
      | Semitone => semitones
      | MinMaj => mMPs
      | SemitoneSteps => semitones
      | HalfnoteSteps => semitones
      }
      bit == "0" ? `•` : a->Array.get(index)->Option.getWithDefault("")
    }
  }
}

module Scale = {
  @react.component
  let make = (~bitString, ~currentKey: option<key>, ~kind: kind, ~selected as _: bool) => {
    let container = (i, content) =>
      <td
        key={i->Int.toString}
        className={[
          "w-5 text-center align-middle",
          "border border-collapse border-y-inherit border-x-primary-300 ",
          switch kind {
          | Species => "font-bold "
          | Mode => ""
          | NonMode => ""
          },
        ]->join}>
        {content}
      </td>

    {
      switch currentKey {
      | Some(SemitoneSteps) =>
        bitString
        ->bitsToSemitoneSteps
        ->Array.mapWithIndex((i, step) => {
          container(i, step->Int.toString->str)
        })
        ->React.array

      | Some(HalfnoteSteps) =>
        bitString
        ->bitsToHalfnoteSteps
        ->Array.mapWithIndex((i, step) => {
          container(i, step->str)
        })
        ->React.array

      | _ =>
        bitString
        ->BitOps.stringToStringArray
        ->Array.mapWithIndex((i, bit) => {
          container(i, bitToDisplaySymbol(bit, i, currentKey)->str)
        })
        ->React.array
      }
    }
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
    ~genusId,
    ~currentBits,
    ~setCurrentBits,
    ~currentKey: option<key>,
    ~speciesId: string,
    ~speciesDetails: speciesDetails,
  ) => {
    // let (base, setBase) = React.useState(_ => None)

    let scaleLength = switch currentKey {
    | Some(SemitoneSteps) => speciesId->bitsToSemitoneSteps->Array.length
    | Some(HalfnoteSteps) => speciesId->bitsToHalfnoteSteps->Array.length
    | _ => speciesId->BitOps.stringToStringArray->Array.length
    }

    let _scaleRange = Array.range(1, scaleLength)

    let speciesNameData = Data.namedSpecies->Array.keep(((sId, _, _)) => {
      switch sId {
      | Bits(s) => s
      | Steps(s) => s->BitOps.stringToIntArray->stepsToBits
      }
      ->BitOps.stringToStringArray
      ->getRotations
      ->any(x => {
        x->BitOps.stringArrayToString == speciesId
      })
    })

    let speciesNames = speciesNameData->reactMap(((sId, sNames, _)) => {
      <div
        key={switch sId {
        | Bits(s) => s
        | Steps(s) => s
        }}>
        {sNames
        ->Array.map(((_tradition, name)) => {
          name
        })
        ->Js.Array2.joinWith(", ")
        ->str}
      </div>
    })

    let numModes =
      speciesDetails.modes
      ->Array.keep(((modeId, _)) => modeId->BitOps.stringToStringArray->startsWith1)
      ->Array.length

    let numPitchClasses = speciesDetails.modes->Array.length

    let uniqueNumModes = numModes != genusId
    // let uniqueNumPitchClasses = numPitchClasses != Config.bits

    let modesDisplay =
      <div> {`(${numModes->Int.toString}:${numPitchClasses->Int.toString})`->str} </div>

    <Collapsed
      render={(speciesHidden, setSpeciesHidden) => {
        let anySelected = speciesDetails.modes->any(((rotation, _)) => {
          currentBits->Option.mapWithDefault(false, c => c->BitOps.intArrayToString == rotation)
        })

        let _speciesIdModeSelected =
          currentBits->Option.mapWithDefault(false, c => c->BitOps.intArrayToString == speciesId)

        <tbody className={[]->join}>
          // {speciesHidden
          // ?
          <tr
            className={["border-y-2 border-y-primary-900 bg-primary-300"]->join}
            onClick={_ => {
              currentBits->Option.mapWithDefault(
                {
                  setSpeciesHidden(_ => false)
                  setCurrentBits(_ => speciesId->BitOps.stringToIntArray->Some)
                },
                _ => {
                  setSpeciesHidden(_ => !speciesHidden ? anySelected : !speciesHidden)
                  setCurrentBits(_ => anySelected ? None : speciesId->BitOps.stringToIntArray->Some)
                },
              )
            }}>
            <td className={"w-5 text-xs border-collapse border-r-2 border-r-primary-900 px-1"}>
              {speciesId->BitOps.stringToInt->Int.toString->str}
            </td>
            <Scale selected={false} currentKey={currentKey} bitString={speciesId} kind={Species} />
            <td className="font-bold border-collapse border-l-2 border-l-primary-900 px-1">
              {speciesNames}
              {uniqueNumModes ? modesDisplay : React.null}
            </td>
            <td className="w-6  border-collapse border-l-2 border-l-primary-900 ">
              {speciesDetails.isSymmetric ? "x"->str : ""->str}
            </td>
          </tr>
          {speciesHidden
            ? React.null
            : speciesDetails.modes->reactMapWithIndex((i, (modeId, _rotationDegrees)) => {
                let selected =
                  currentBits->Option.mapWithDefault(false, c =>
                    c->BitOps.intArrayToString == modeId
                  )

                let modeKind = modeId->BitOps.stringToStringArray->startsWith1 ? Mode : NonMode

                <tr
                  onClick={_ => setCurrentBits(_ => modeId->BitOps.stringToIntArray->Some)}
                  key={modeId}
                  className={[
                    "border-b border-b-primary-900",
                    selected ? "font-bold" : "",
                    switch modeKind {
                    | Mode => selected ? "text-accent-600 " : "text-primary-700"
                    | NonMode =>
                      selected
                        ? "bg-primary-200 text-accent-600"
                        : "bg-primary-200 text-primary-500"
                    | _ => ""
                    },
                  ]->join}>
                  <td
                    className={" text-xs text-center align-middle border-r-2 border-collapse border-r-primary-900"}>
                    {i->Int.toString->str}
                  </td>
                  <Scale
                    selected={selected} currentKey={currentKey} bitString={modeId} kind={modeKind}
                  />
                  <td className={"border-collapse border-l-2 border-l-primary-900 px-1"}>
                    {speciesNameData
                    ->Array.keepMap(((_, _, modes)) => {
                      modes->Array.getBy(
                        ((mId, _)) => {
                          let match = switch mId {
                          | Bits(s) => s
                          | Steps(stepString) => stepString->BitOps.stringToIntArray->stepsToBits
                          }

                          modeId == match
                        },
                      )
                    })
                    ->Array.get(0)
                    ->Option.mapWithDefault([], ((_, modeNames)) =>
                      modeNames->Array.map(((_, name)) => name)
                    )
                    ->Js.Array2.joinWith(", ")
                    ->str}
                  </td>
                  {speciesDetails.autoCorrelations
                  ->Array.get(i)
                  ->Option.mapWithDefault(React.null, x => {
                    <td
                      key={i->Int.toString ++ "auto-correlation"}
                      className={[
                        "text-center align-middle font-bold text-lime-600 border-collapse border-l-2 border-l-primary-900",
                      ]->join}>
                      {x->str}
                    </td>
                  })}
                </tr>
              })}
          {speciesHidden
            ? React.null
            : <tr className={""}>
                <td className={"h-3 border-x-transparent bg-inherit"} />
              </tr>}
        </tbody>
      }}
    />
  }
}

module PageTitle = {
  @react.component
  let make = () => {
    <div className={"font-sans absolute flex flex-row top-0 left-0 pl-3 pt-3"}>
      // <Logo />
      <div className={" text-[rgb(25,0,175)]  italic text-4xl font-bold"}> {"T"->str} </div>
      <div className={"mt-1.5 -ml-0.5"}>
        <div className={" text-[rgb(25,0,175)] font-bold text-xl"}> {"opotonic"->str} </div>
        <div className={"text-cyan-600 text-[10px] font-bold italic -mt-1"}>
          {"by T. Wright"->str}
        </div>
      </div>
    </div>
  }
}

module PageTitle2 = {
  @react.component
  let make = () => {
    <div className={"font-sans absolute flex flex-row top-5 left-5 "}>
      <Logo size={32} />
      <div className={" -ml-2"}>
        <div className={" text-[rgb(25,0,175)] font-bold text-xl"}> {"opotonic"->str} </div>
        // <div className={"text-cyan-600 text-[10px] font-bold italic -mt-1"}>
        //   {"by T. Wright"->str}
        // </div>
      </div>
    </div>
  }
}

@react.component
let make = () => {
  let (currentBits, setCurrentBits) = React.useState(_ => None)
  let (currentKey: option<key>, setCurrentKey) = React.useState(_ => Some(Pitch(0)))

  let graphKeys = {
    switch currentKey {
    | None => semitones
    | Some(Semitone) => semitones
    | Some(SemitoneSteps) => semitones
    | Some(HalfnoteSteps) => semitones
    | Some(DimAug) => dimAugs
    | Some(MinMaj) => mMPs
    | Some(Pitch(shift)) => pitchKeys->rotate(shift)
    }
  }

  let graphBits =
    currentBits->Option.mapWithDefault(Array.range(0, Config.bits - 1)->Array.map(_ => 0), b => b)

  <div className={"flex md:flex-row flex-col h-screen w-screen "}>
    <PageTitle2 />
    <div className="flex-1 h-full flex flex-col p-2 md:max-w-[320px]">
      <div className={"h-80 w-80  self-center "}>
        <SVG data={Array.zip(graphKeys, graphBits)} />
      </div>
      <div className={" flex-1 overflow-scroll p-1 border rounded max-h-24 md:max-h-min "}>
        {pitchKeys->reactMapWithIndex((i, v) => {
          let selected = switch currentKey {
          | Some(Pitch(c)) => c == i
          | _ => false
          }

          <Key key={v} selected={selected} onClick={_ => setCurrentKey(_ => Some(Pitch(i)))}>
            {v->str}
          </Key>
        })}
        <Key selected={currentKey->Option.isNone} onClick={_ => setCurrentKey(_ => None)}>
          {"Binary"->str}
        </Key>
        <Key
          selected={currentKey->Option.mapWithDefault(false, x => x == MinMaj)}
          onClick={_ => setCurrentKey(_ => Some(MinMaj))}>
          {"Min-Maj Intervals"->str}
        </Key>
        <Key
          selected={currentKey->Option.mapWithDefault(false, x => x == DimAug)}
          onClick={_ => setCurrentKey(_ => Some(DimAug))}>
          {"Dim-Aug Intervals"->str}
        </Key>
        <Key
          selected={currentKey->Option.mapWithDefault(false, x => x == Semitone)}
          onClick={_ => setCurrentKey(_ => Some(Semitone))}>
          {"Semitone Intervals"->str}
        </Key>
        <Key
          selected={currentKey->Option.mapWithDefault(false, x => x == SemitoneSteps)}
          onClick={_ => setCurrentKey(_ => Some(SemitoneSteps))}>
          {"Semitone Steps"->str}
        </Key>
        <Key
          selected={currentKey->Option.mapWithDefault(false, x => x == HalfnoteSteps)}
          onClick={_ => setCurrentKey(_ => Some(HalfnoteSteps))}>
          {"Halfnote Steps"->str}
        </Key>
      </div>
    </div>
    <div className="md:flex-1 h-full overflow-scroll xs:px-2">
      {result
      ->Map.Int.toArray
      ->reactMap(((genusId, species)) =>
        <Collapsed
          key={genusId->Int.toString}
          render={(genusCollapsedState, setGenusCollapsedState) => {
            <div className={"mb-1"}>
              <div
                onClick={_ => {
                  setGenusCollapsedState(s => !s)
                }}
                className="flex flex-row items-center px-4 ">
                <div className="min-w-[50px] text-2xl font-black">
                  {genusId->Int.toString->str}
                </div>
                <div className=" text-sm font-bold whitespace-nowrap">
                  {species->Map.String.toArray->Array.length->Int.toString->str}
                  {" species"->str}
                </div>
              </div>
              <table
                className={[
                  genusCollapsedState ? "hidden" : "",
                  "overflow-scroll border-4 border-primary-900 ",
                ]->join}>
                {genusCollapsedState
                  ? React.null
                  : species
                    ->Map.String.toArray
                    ->reactMap(((speciesId, speciesDetails)) =>
                      <Species
                        key={speciesId}
                        genusId={genusId}
                        currentBits={currentBits}
                        setCurrentBits={setCurrentBits}
                        currentKey={currentKey}
                        speciesId={speciesId}
                        speciesDetails={speciesDetails}
                      />
                    )}
              </table>
            </div>
          }}
        />
      )}
    </div>
  </div>
}

let default = make
