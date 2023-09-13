open Belt

let result = DataGeneration.result
let join = Js.Array2.joinWith(_, " ")
let str = React.string
let reactMap = (a, f) => a->Array.map(f)->React.array
let reactMapWithIndex = (a, f) => a->Array.mapWithIndex(f)->React.array

module BitOps = DataGeneration.BitOps

module Logo = {
  @module("./Icons.jsx") @react.component
  external make: (~size: int) => React.element = "Logo"
}

module SVG = {
  @module("./SVG.jsx") @react.component
  external make: (~data: array<(string, int)>) => React.element = "SVG"
}

module Symmetry = {
  @module("react-icons/bs") @react.component
  external make: (~size: int=?, ~color: string=?, ~className: string=?) => React.element =
    "BsSymmetryVertical"
}

module ChevronDown = {
  @module("react-icons/fa") @react.component
  external make: (~size: int=?, ~color: string=?, ~className: string=?) => React.element =
    "FaChevronDown"
}

module PlayIcon = {
  @module("react-icons/fa") @react.component
  external make: (~size: int=?, ~color: string=?, ~className: string=?) => React.element = "FaPlay"
}

module Collapsed = {
  @react.component
  let make = (~render) => {
    let (state, set) = React.useState(() => true)

    render(state, set)
  }
}

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
      | Pitch(shift) => pitchKeysShort->DataGeneration.rotate(shift)
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
// `•`

module Key = {
  @react.component
  let make = (~selected, ~onClick, ~children) => {
    <div
      className={[
        selected ? "bg-blue-300 border-blue-500" : "bg-plain-100 border-plain-400",
        "col-span-1 rounded p-1 px-2 border text-center",
      ]->join}
      onClick={onClick}>
      {children}
    </div>
  }
}

module Scale = {
  @react.component
  let make = (~bitString, ~currentKey: option<key>, ~kind: kind, ~selected as _: bool) => {
    let gridCols = switch currentKey {
    | Some(SemitoneSteps) => bitString->bitsToSemitoneSteps->Array.length
    | Some(HalfnoteSteps) => bitString->bitsToHalfnoteSteps->Array.length
    | _ => 12
    }->{
      x =>
        switch x {
        | 0 => "grid-cols-0"
        | 1 => "grid-cols-1"
        | 2 => "grid-cols-2"
        | 3 => "grid-cols-3"
        | 4 => "grid-cols-4"
        | 5 => "grid-cols-5"
        | 6 => "grid-cols-6"
        | 7 => "grid-cols-7"
        | 8 => "grid-cols-8"
        | 9 => "grid-cols-9"
        | 10 => "grid-cols-10"
        | 11 => "grid-cols-11"
        | 12 => "grid-cols-12"
        | _ => "grid-cols-12"
        }
    }
    let container = (i, content) =>
      <div
        key={i->Int.toString}
        className={[
          "col-span-1 flex flex-row items-center justify-center min-w-[2rem]",
          "",
          switch kind {
          | Species => " "
          | Mode => ""
          | NonMode => ""
          },
        ]->join}>
        {content}
      </div>

    <div className={["flex-1 grid", gridCols]->join}>
      {switch currentKey {
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
      }}
    </div>
  }
}

// <div className="hidden md:block  flex-none w-10">
//   {speciesDetails.autoCorrelations
//   ->Array.get(i)
//   ->Option.mapWithDefault(React.null, x => {
//     <div
//       key={i->Int.toString ++ "auto-correlation"}
//       className={[
//         "text-center align-middle font-bold text-plain-700 ",
//       ]->join}>
//       {x->str}
//     </div>
//   })}
// </div>

module Species = {
  @react.component
  let make = (
    ~genusId,
    ~currentBits,
    ~setCurrentBits,
    ~currentKey: option<key>,
    ~speciesId: string,
    ~speciesDetails: DataGeneration.speciesDetails,
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
      ->DataGeneration.getRotations
      ->DataGeneration.any(x => {
        x->BitOps.stringArrayToString == speciesId
      })
    })

    let speciesNames =
      speciesNameData
      ->Array.map(((_sId, sNames, _)) => {
        sNames
        ->Array.map(((_tradition, name)) => {
          name
        })
        ->Array.keep(x => x != "")
        ->Js.Array2.joinWith(", ")
      })
      ->Array.keep(x => x != "")
      ->Js.Array2.joinWith(", ")

    let numModes =
      speciesDetails.modes
      ->Array.keep(((modeId, _)) => modeId->BitOps.stringToStringArray->DataGeneration.startsWith1)
      ->Array.length

    let numPitchClasses = speciesDetails.modes->Array.length

    let _uniqueNumModes = numModes != genusId
    // let uniqueNumPitchClasses = numPitchClasses != Config.bits

    let _modesDisplay =
      <span> {`(${numModes->Int.toString}:${numPitchClasses->Int.toString})`->str} </span>

    <Collapsed
      render={(speciesHidden, setSpeciesHidden) => {
        let anySelected = speciesDetails.modes->DataGeneration.any(((rotation, _)) => {
          currentBits->Option.mapWithDefault(false, c => c->BitOps.intArrayToString == rotation)
        })

        let _speciesIdModeSelected =
          currentBits->Option.mapWithDefault(false, c => c->BitOps.intArrayToString == speciesId)

        // TODO:
        // {uniqueNumModes ? modesDisplay : React.null}

        let scaleName = speciesId->BitOps.stringToInt->Int.toString

        let onClickHeader = _ => {
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
        }

        <div className={[" py-2 "]->join}>
          {speciesHidden
            ? <div className={["font-bold"]->join} onClick={onClickHeader}>
                {speciesNames == ""
                  ? React.null
                  : <div className="flex flex-row justify-center items-center pb-1">
                      <div
                        className="text-lg flex-none overflow-x-hidden text-ellipsis whitespace-nowrap px-1">
                        {speciesNames->str}
                      </div>
                    </div>}
                <div className="flex flex-row">
                  <Scale
                    selected={false} currentKey={currentKey} bitString={speciesId} kind={Species}
                  />
                  <div className=" flex-none flex flex-row items-center justify-center w-10 px-1">
                    {speciesDetails.isSymmetric ? <Symmetry /> : React.null}
                  </div>
                </div>
              </div>
            : <div>
                <div
                  className=""
                  onClick={_ => {
                    setSpeciesHidden(_ => true)
                  }}>
                  <div
                    className={"text-lg flex-none font-bold flex flex-row items-center justify-center"}>
                    {speciesNames->str}
                  </div>
                  <div className={"flex flex-row items-center justify-center gap-2"}>
                    <div className="flex-none">
                      {speciesDetails.isSymmetric ? <Symmetry /> : React.null}
                    </div>
                    <div className="flex-none text-sm font-medium tracking-wide ">
                      {`SCALE ${scaleName}`->str}
                    </div>
                  </div>
                </div>
                <div className={["mt-1 mb-4 border-y border-plain-500"]->join}>
                  {speciesDetails.modes->reactMapWithIndex((_i, (modeId, _rotationDegrees)) => {
                    let selected =
                      currentBits->Option.mapWithDefault(false, c =>
                        c->BitOps.intArrayToString == modeId
                      )

                    let modeKind =
                      modeId->BitOps.stringToStringArray->DataGeneration.startsWith1
                        ? Mode
                        : NonMode

                    let modeNames =
                      speciesNameData
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

                    <div
                      onClick={_ => setCurrentBits(_ => modeId->BitOps.stringToIntArray->Some)}
                      key={modeId}
                      className={[
                        "flex flex-col py-px md:justify-start justify-center",
                        selected ? "font-bold" : "",
                        switch modeKind {
                        | Mode => selected ? "text-accent-600 " : "text-plain-700"
                        | NonMode =>
                          selected ? "bg-plain-50 text-accent-600" : "bg-plain-50 text-plain-300"
                        | _ => ""
                        },
                      ]->join}>
                      {modeNames == ""
                        ? React.null
                        : <div
                            className={"flex flex-row items-center text-xs pt-0.5 pl-0.5 justify-start flex-1 overflow-x-hidden text-ellipsis whitespace-nowrap px-1"}>
                            {modeNames->str}
                          </div>}
                      <Scale
                        selected={selected}
                        currentKey={currentKey}
                        bitString={modeId}
                        kind={modeKind}
                      />
                    </div>
                  })}
                </div>
              </div>}
        </div>
      }}
    />
  }
}

module PageTitle = {
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

module About = {
  @module("./about.jsx") @react.component
  external make: unit => React.element = "default"
}

let generateChromaticScale = (startFrequency, numNotes) => {
  let semitoneRatio = 2. ** (1. /. 12.)

  Array.range(0, numNotes)->Array.map(v => {
    (startFrequency->Float.fromInt *. semitoneRatio ** v->Float.fromInt)->Int.fromFloat
  })
}

// Important that these be uncurried.
// Will throw a "this is undefined" error otherwise.
type notePlayer = {
  playNote: (. int, int) => unit,
  setVolume: (. float) => unit,
  playNotesSequentially: (. array<(int, int)>, int) => unit,
}

@module("./NotePlayer.js") @new external makeNotePlayer: unit => notePlayer = "default"

// let notePlayer = makeNotePlayer()

// notePlayer.setVolume(. 0.3)

@module("./Tone.js") external triggerAttackRelease: (. int, string, float) => unit = "default"

@react.component
let make = () => {
  let (currentBits, setCurrentBits) = React.useState(_ => None)
  let (selectedGenus, setSelectedGenus) = React.useState(_ => None)

  let (currentKey: option<key>, setCurrentKey) = React.useState(_ => Some(Pitch(0)))

  let graphKeys = {
    switch currentKey {
    | None => semitones
    | Some(Semitone) => semitones
    | Some(SemitoneSteps) => semitones
    | Some(HalfnoteSteps) => semitones
    | Some(DimAug) => dimAugs
    | Some(MinMaj) => mMPs
    | Some(Pitch(shift)) => pitchKeys->DataGeneration.rotate(shift)
    }
  }

  let graphBits =
    currentBits->Option.mapWithDefault(
      Array.range(0, DataGeneration.Config.bits - 1)->Array.map(_ => 0),
      b => b,
    )

  let modeNames =
    Data.namedSpecies
    ->Array.keepMap(((_, _, modes)) => {
      modes->Array.getBy(((mId, _)) => {
        let match = switch mId {
        | Bits(s) => s
        | Steps(stepString) => stepString->BitOps.stringToIntArray->stepsToBits
        }

        graphBits->BitOps.intArrayToString == match
      })
    })
    ->Array.get(0)
    ->Option.mapWithDefault([], ((_, modeNames)) => modeNames->Array.map(((_, name)) => name))
    ->Js.Array2.joinWith(", ")

  let scaleNames =
    Data.namedSpecies
    ->Array.keepMap(((sId, sNames, _modes)) => {
      let match = switch sId {
      | Bits(s) => s
      | Steps(stepString) => stepString->BitOps.stringToIntArray->stepsToBits
      }
      let isMatch =
        graphBits
        ->DataGeneration.getRotations
        ->DataGeneration.any(x => {
          x->BitOps.intArrayToString == match
        })

      isMatch ? sNames->Array.map(((_tradition, name)) => name)->Some : None
    })
    ->Array.concatMany
    ->Js.Array2.joinWith(", ")

  <div className={"flex md:flex-row flex-col h-screen w-screen "}>
    <PageTitle />
    <div
      className="flex-1 flex flex-col w-screen md:w-auto md:max-w-[500px] p-2  overflow-y-scroll items-center">
      <div className=" md:max-h-min  max-w-[500px] w-full">
        <div className={"pt-2 w-full self-center"}>
          <SVG data={Array.zip(graphKeys, graphBits)} />
        </div>
        {currentBits->Option.isNone
          ? React.null
          : <div className="relative">
              <button
                className={"absolute -top-4 right-4 flex flex-row gap-2 py-1 px-4 border border-plain-400 bg-plain-200 rounded-full items-center justify-center font-bold text-xl"}
                onClick={_ => {
                  let cBaseFreq = 110
                  let cChromScale = generateChromaticScale(cBaseFreq, 12)
                  let newBase = switch currentKey {
                  | Some(Pitch(i)) => cChromScale->Array.get(i)->Option.getWithDefault(cBaseFreq)
                  | _ => cBaseFreq
                  }
                  let newChromScale = generateChromaticScale(cBaseFreq + newBase, 12)

                  let seq =
                    newChromScale
                    ->Array.keepWithIndex((_v, i) => {
                      graphBits->Array.get(i)->Option.mapWithDefault(false, bit => bit == 1)
                    })
                    ->(
                      x =>
                        x
                        ->Array.get(0)
                        ->Option.mapWithDefault(x, head => Array.concat(x, [head * 2]))
                    )

                  seq->Array.forEachWithIndex((i, v) => {
                    triggerAttackRelease(. v, "8n", i->Int.toFloat *. 0.5)
                  })
                }}>
                <PlayIcon size={16} />
                {"Play"->str}
              </button>
            </div>}
        {scaleNames == ""
          ? React.null
          : <div className="w-full text-lg text-center pt-2 font-bold text-accent-600">
              {`Scale: ${scaleNames}`->str}
            </div>}
        {modeNames == ""
          ? React.null
          : <div className="w-full text-lg text-center pb-2 font-bold text-accent-600">
              {`Mode: ${modeNames}`->str}
            </div>}
        <div className="w-full text-center pb-2 pt-3 font-medium"> {"Keys"->str} </div>
        <div className={"grid grid-cols-4 gap-2 w-full"}>
          {pitchKeys->reactMapWithIndex((i, v) => {
            let selected = switch currentKey {
            | Some(Pitch(c)) => c == i
            | _ => false
            }

            <Key key={v} selected={selected} onClick={_ => setCurrentKey(_ => Some(Pitch(i)))}>
              {v->str}
            </Key>
          })}
        </div>
        <div className="w-full text-center pb-2 pt-3 font-medium"> {"Intervals"->str} </div>
        <div className="grid grid-cols-3 gap-2 w-full">
          <Key
            selected={currentKey->Option.mapWithDefault(false, x => x == MinMaj)}
            onClick={_ => setCurrentKey(_ => Some(MinMaj))}>
            {"Min-Maj"->str}
          </Key>
          <Key
            selected={currentKey->Option.mapWithDefault(false, x => x == DimAug)}
            onClick={_ => setCurrentKey(_ => Some(DimAug))}>
            {"Dim-Aug"->str}
          </Key>
          <Key
            selected={currentKey->Option.mapWithDefault(false, x => x == Semitone)}
            onClick={_ => setCurrentKey(_ => Some(Semitone))}>
            {"Semitone"->str}
          </Key>
        </div>
        <div className="w-full text-center pb-2 pt-3 font-medium"> {"Steps"->str} </div>
        <div className="grid grid-cols-2 gap-2 w-full">
          <Key
            selected={currentKey->Option.mapWithDefault(false, x => x == SemitoneSteps)}
            onClick={_ => setCurrentKey(_ => Some(SemitoneSteps))}>
            {"Semitone"->str}
          </Key>
          <Key
            selected={currentKey->Option.mapWithDefault(false, x => x == HalfnoteSteps)}
            onClick={_ => setCurrentKey(_ => Some(HalfnoteSteps))}>
            {"Halfnote"->str}
          </Key>
        </div>
        <div className="w-full text-center pb-2 pt-3 font-medium"> {"Other"->str} </div>
        <div className={" "}>
          <Key selected={currentKey->Option.isNone} onClick={_ => setCurrentKey(_ => None)}>
            {"Binary"->str}
          </Key>
        </div>
      </div>
    </div>
    <div className="flex-1 md:flex-1 h-full overflow-scroll xs:px-2">
      <Collapsed
        render={(collapsedState, setCollapsedState) => {
          <div>
            <button
              onClick={_ => setCollapsedState(s => !s)}
              className={`px-3 py-1 m-2 ml-3 font-bold bg-plain-200 rounded 
              flex flex-row justify-center items-center gap-1`}>
              {"About Topotonic"->str}
              <ChevronDown />
            </button>
            <div className={[collapsedState ? "hidden" : ""]->join}>
              <About />
            </div>
          </div>
        }}
      />
      <div className=" py-3 text-lg font-medium flex flex-row items-center ">
        {"Select the number of notes"->str}
      </div>
      <div className="flex flex-row overflow-x-scroll gap-2">
        {Array.range(1, DataGeneration.Config.bits)->reactMap(num => {
          <div
            className={[
              "p-1 px-2 border rounded",
              selectedGenus->Option.mapWithDefault(false, ((i, _)) => num == i)
                ? "bg-primary-300 border-primary-500"
                : "bg-plain-00 border-plain-400",
            ]->join}
            onClick={_ =>
              setSelectedGenus(_ =>
                result
                ->Map.Int.keysToArray
                ->Array.get(num)
                ->Option.flatMap(
                  genusId =>
                    result->Map.Int.get(genusId)->Option.map(species => (genusId, species)),
                )
              )}>
            {num->Int.toString->str}
          </div>
        })}
      </div>
      <div className="md:max-w-[500px]">
        {selectedGenus->Option.mapWithDefault(React.null, ((genusId, species)) => {
          <div className={"mb-1"}>
            <div className="flex flex-row items-center py-4 font-medium text-lg ">
              {`There are ${species
                ->Map.String.toArray
                ->Array.length
                ->Int.toString} possible scales of ${genusId->Int.toString} notes`->str}
            </div>
            <div className={[""]->join}>
              {species
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
            </div>
          </div>
        })}
      </div>
    </div>
  </div>
}

let default = make
