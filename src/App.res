open Belt

type key = int

type stepDisplay = Key | MinMaj | DimAug | Semitone | SemitoneSteps | HalfnoteSteps | Binary

type kind = Species | Mode | NonMode

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
  external make: (
    ~data: array<(string, int)>,
    ~currentKey: int,
    ~onKeyChange: int => unit,
  ) => React.element = "SVG"
}

module Symmetry = {
  @module("react-icons/go") @react.component
  external make: (~size: int=?, ~color: string=?, ~className: string=?) => React.element =
    "GoMirror"
}

module ChevronDown = {
  @module("react-icons/fa") @react.component
  external make: (~size: int=?, ~color: string=?, ~className: string=?) => React.element =
    "FaChevronDown"
}

module ChevronUp = {
  @module("react-icons/fa") @react.component
  external make: (~size: int=?, ~color: string=?, ~className: string=?) => React.element =
    "FaChevronUp"
}

module PlayIcon = {
  @module("react-icons/fa") @react.component
  external make: (~size: int=?, ~color: string=?, ~className: string=?) => React.element = "FaPlay"
}
module Switch = {
  @module("./Switch.jsx") @react.component
  external make: (~checked: bool, ~onCheckedChange: unit => unit) => React.element = "Switch"
}

module Collapsed = {
  @react.component
  let make = (~render) => {
    let (state, set) = React.useState(() => true)

    render(state, set)
  }
}

let getGridCols = x =>
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

module IntervalRefs = {
  //   let pitchKeys = [
  //   `C`,
  //   `C♯ D♭`,
  //   `D`,
  //   `D♯ E♭`,
  //   `E`,
  //   `F`,
  //   `F♯ G♭`,
  //   `G`,
  //   `G♯ A♭`,
  //   `A`,
  //   `A♯ B♭`,
  //   `B`,
  // ]

  let pitchKeys = [`C`, `C♯ `, `D`, `E♭`, `E`, `F`, `F♯ `, `G`, `A♭`, `A`, `B♭`, `B`]

  let pitchKeysShort = [`C`, `C♯`, `D`, `D♯`, `E`, `F`, `F♯`, `G`, `G♯`, `A`, `A♯`, `B`]
  let semitones = [`0`, `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `11`]
  let mMPs = [`P1`, `m2`, `M2`, `m3`, `M3`, `P4`, `TT`, `P5`, `m6`, `M6`, `m7`, `M7`]
  // TODO: replace TT with d5/A4 when we have proper scaling
  let dimAugs = [`d2`, `A1`, `d3`, `A2`, `d4`, `A3`, `TT`, `d6`, `A5`, `d7`, `A6`, `d8`]
}

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

let bitToDisplaySymbol = (bit, index, currentKey, currentStepDisplay, bitString) => {
  let a = switch currentStepDisplay {
  | Key => IntervalRefs.pitchKeysShort->DataGeneration.rotate(currentKey)
  | DimAug => IntervalRefs.dimAugs
  | Semitone => IntervalRefs.semitones
  | MinMaj => IntervalRefs.mMPs
  | SemitoneSteps => IntervalRefs.semitones
  | HalfnoteSteps => IntervalRefs.semitones
  | Binary => bitString->BitOps.stringToStringArray
  }
  bit == "0" ? `•` : a->Array.get(index)->Option.getWithDefault("")
}

let scaleRepToMode = (s, rot) =>
  s
  ->BitOps.stringToIntArray
  ->DataGeneration.rotate(rot)
  ->stepsToBits
  ->BitOps.stringToIntArray
  ->BitOps.intArrayToString

module StepButton = {
  @react.component
  let make = (~selected, ~onClick, ~children) => {
    <div
      className={[
        selected ? " bg-[var(--card-select-bg)] font-bold " : " bg-white font-medium ",
        "col-span-1 p-1 rounded-xl px-2 text-center  cursor-default",
      ]->join}
      onClick={onClick}>
      {children}
    </div>
  }
}

module PageTitle = {
  @react.component
  let make = () => {
    <div className={"font-sans text-[var(--logo)] font-black text-4xl tracking-tighter"}>
      {"Topotonic"->str}
    </div>
  }
}

module Card = {
  @react.component
  let make = (~title, ~className="", ~children) => {
    <div
      className={[
        " rounded-xl p-2 pb-3 pt-1 mt-2 overflow-hidden bg-[var(--card)]",
        className,
      ]->join}>
      <div className="w-full text-center pb-2 font-bold text-lg "> {title->str} </div>
      <div className={""}> {children} </div>
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

// Must be uncurried.
// Will throw a "this is undefined" error otherwise.
type notePlayer = {
  playNote: (. int, int) => unit,
  setVolume: (. float) => unit,
  playNotesSequentially: (. array<(int, int)>, int) => unit,
}

@module("./NotePlayer.js") @new external makeNotePlayer: unit => notePlayer = "default"

@module("./Tone.js") external triggerAttackRelease: (. int, string, float) => unit = "default"

module Scale = {
  @react.component
  let make = (~bitString, ~currentStepDisplay, ~currentKey, ~kind: kind, ~selected as _: bool) => {
    let gridCols = switch currentStepDisplay {
    | SemitoneSteps => bitString->bitsToSemitoneSteps->Array.length
    | HalfnoteSteps => bitString->bitsToHalfnoteSteps->Array.length
    | _ => 12
    }->getGridCols

    let container = (i, content) =>
      <div
        key={i->Int.toString} className={["w-6 flex flex-row items-center justify-center "]->join}>
        {content->str}
      </div>

    <div className={["flex-none flex-row flex justify-center w-full gap-0.5"]->join}>
      {switch currentStepDisplay {
      | SemitoneSteps =>
        bitString
        ->bitsToSemitoneSteps
        ->Array.mapWithIndex((i, step) => {
          container(i, step->Int.toString)
        })
        ->React.array

      | HalfnoteSteps =>
        bitString
        ->bitsToHalfnoteSteps
        ->Array.mapWithIndex((i, step) => {
          container(i, step)
        })
        ->React.array

      | _ =>
        bitString
        ->BitOps.stringToStringArray
        ->Array.mapWithIndex((i, bit) => {
          container(i, bitToDisplaySymbol(bit, i, currentKey, currentStepDisplay, bitString))
        })
        ->React.array
      }}
    </div>
  }
}

module Species = {
  @react.component
  let make = (
    ~genusId,
    ~currentBits,
    ~currentStepDisplay,
    ~setCurrentBits,
    ~currentKey: key,
    ~speciesId: string,
    ~speciesDetails: DataGeneration.speciesDetails,
    ~showNonModes: bool,
  ) => {
    let scaleLength = switch currentStepDisplay {
    | SemitoneSteps => speciesId->bitsToSemitoneSteps->Array.length
    | HalfnoteSteps => speciesId->bitsToHalfnoteSteps->Array.length
    | _ => speciesId->BitOps.stringToStringArray->Array.length
    }

    let _scaleRange = Array.range(1, scaleLength)

    let speciesNameData = Data.namedSpecies->Array.keep(((s, _, _)) => {
      s->BitOps.stringToIntArray->stepsToBits == speciesId
    })

    let speciesNames =
      speciesNameData
      ->Array.map(((_sId, sNames, _)) => {
        sNames
        ->Array.map(((_tradition, name)) => {
          name
        })
        ->Array.keep(x => x != "")
        ->Js.Array2.joinWith(" • ")
      })
      ->Array.keep(x => x != "")
      ->Js.Array2.joinWith(" • ")

    let speciesModeNames =
      speciesNameData
      ->Array.map(((_, _, modes)) => {
        modes
        ->Array.map(((_, modeNames)) => modeNames->Array.map(((_, name)) => name))
        ->Array.concatMany
      })
      ->Array.concatMany
      ->Js.Array2.joinWith(" • ")

    let numModes =
      speciesDetails.modes
      ->Array.keep(((modeId, _)) => modeId->BitOps.stringToStringArray->DataGeneration.startsWith1)
      ->Array.length

    let numPitchClasses = speciesDetails.modes->Array.length

    let _uniqueNumModes = numModes != genusId

    let _modesDisplay =
      <span> {`(${numModes->Int.toString}:${numPitchClasses->Int.toString})`->str} </span>

    <Collapsed
      render={(speciesHidden, setSpeciesHidden) => {
        let anySelected = speciesDetails.modes->DataGeneration.any(((rotation, _)) => {
          currentBits->Option.mapWithDefault(false, c => c->BitOps.intArrayToString == rotation)
        })

        let _speciesIdModeSelected =
          currentBits->Option.mapWithDefault(false, c => c->BitOps.intArrayToString == speciesId)

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

        let speciesNamesComp =
          <div
            className={[
              " text-[var(--species-text)]  flex-1 text-ellipsis overflow-hidden  whitespace-nowrap ",
              anySelected ? "font-black" : "",
            ]->join}>
            {speciesNames->str}
          </div>

        <div
          className={[
            " rounded-xl mb-2 cursor-pointer font-bold",
            speciesHidden ? "bg-[var(--species-bg)] " : "bg-[var(--species-open-bg)] ",
          ]->join}>
          {speciesHidden
            ? <div className={[""]->join} onClick={onClickHeader}>
                {if speciesNames != "" {
                  <div
                    className={[
                      " flex flex-row justify-start tracking-tight  items-center pt-1 px-3",
                    ]->join}>
                    {speciesNamesComp}
                  </div>
                } else if speciesModeNames != "" {
                  <div className=" flex flex-row justify-start items-center  pt-1 px-3">
                    <div
                      className="text-[var(--species-text)]  flex-1 text-ellipsis overflow-hidden whitespace-nowrap">
                      {("Modes: " ++ speciesModeNames)->str}
                    </div>
                  </div>
                } else {
                  React.null
                }}
                <div
                  className="flex flex-row bg-[var(--species-scales)] rounded-xl py-1 font-medium">
                  <Scale
                    selected={false}
                    currentKey={currentKey}
                    bitString={speciesId}
                    kind={Species}
                    currentStepDisplay={currentStepDisplay}
                  />
                  // <div className=" flex-none flex flex-row items-center justify-center w-10 px-1">
                  //   {speciesDetails.isSymmetric ? <Symmetry /> : React.null}
                  // </div>
                </div>
              </div>
            : <div>
                <div
                  onClick={_ => {
                    setSpeciesHidden(_ => true)
                  }}
                  className=" flex flex-row justify-start items-center px-3 pt-1">
                  {speciesNamesComp}
                  <div className={"flex flex-row items-center justify-center gap-2"}>
                    <div className="flex-none">
                      {speciesDetails.isSymmetric ? <Symmetry /> : React.null}
                    </div>
                    <div className="flex-none text-sm tracking-wide "> {`#${scaleName}`->str} </div>
                  </div>
                </div>
                <div className="p-2 pt-0 bg-[var(--species-scales)] rounded-xl">
                  <div
                    className={[
                      "rounded-lg flex flex-col divide-y bg-white divide-[var(--species-open-bg)]",
                    ]->join}>
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
                        ->Array.keepMap(((s, _, modes)) => {
                          modes->Array.getBy(
                            ((mId, _)) => {
                              modeId == s->scaleRepToMode(mId)
                            },
                          )
                        })
                        ->Array.get(0)
                        ->Option.mapWithDefault([], ((_, modeNames)) =>
                          modeNames->Array.map(((_, name)) => name)
                        )
                        ->Js.Array2.joinWith(" • ")

                      {
                        modeKind == NonMode && !showNonModes
                          ? React.null
                          : <div
                              onClick={_ =>
                                setCurrentBits(_ => modeId->BitOps.stringToIntArray->Some)}
                              key={modeId}
                              className={[
                                "flex flex-col py-1 sm:justify-start justify-center ",
                                selected
                                  ? "text-[var(--accent)] bg-[var(--scale-highlight)] font-black"
                                  : modeKind == NonMode
                                  ? "text-neutral-400 font-medium "
                                  : "  font-medium",
                              ]->join}>
                              <Scale
                                selected={selected}
                                currentKey={currentKey}
                                currentStepDisplay={currentStepDisplay}
                                bitString={modeId}
                                kind={modeKind}
                              />
                              {modeNames == ""
                                ? React.null
                                : <div
                                    className={[
                                      "flex flex-row tracking-tight items-center text-xs px-3 py-0.5 flex-1",
                                      selected
                                        ? " text-[var(--species-text)] "
                                        : "   text-[var(--species-text)]",
                                    ]->join}>
                                    {modeNames->str}
                                  </div>}
                            </div>
                      }
                    })}
                  </div>
                </div>
              </div>}
        </div>
      }}
    />
  }
}
// module SelectKey = {
//   @react.component
//   let make = () => {
//     <Card title={"Key"} className="mt-4">
//       <div className={"grid grid-cols-4 gap-2 w-full "}>
//         {IntervalRefs.pitchKeys->reactMapWithIndex((i, v) => {
//           let selected = i == currentKey

//           <StepButton key={v} selected={selected} onClick={_ => setCurrentKey(_ => i)}>
//             {v->str}
//           </StepButton>
//         })}
//       </div>
//     </Card>
//   }
// }

module StepDisplay = {
  @react.component
  let make = (~currentStepDisplay, ~setCurrentStepDisplay) => {
    <Card title={"Step Display"}>
      <StepButton
        selected={currentStepDisplay == Key} onClick={_ => setCurrentStepDisplay(_ => Key)}>
        {"Key"->str}
      </StepButton>
      <div className="grid grid-cols-3 gap-2 w-full pb-2 pt-2">
        <StepButton
          selected={currentStepDisplay == MinMaj} onClick={_ => setCurrentStepDisplay(_ => MinMaj)}>
          {"Min-Maj"->str}
        </StepButton>
        <StepButton
          selected={currentStepDisplay == DimAug} onClick={_ => setCurrentStepDisplay(_ => DimAug)}>
          {"Dim-Aug"->str}
        </StepButton>
        <StepButton
          selected={currentStepDisplay == Semitone}
          onClick={_ => setCurrentStepDisplay(_ => Semitone)}>
          {"Semitone"->str}
        </StepButton>
      </div>
      <div className="grid grid-cols-2 gap-2 w-full pb-2">
        <StepButton
          selected={currentStepDisplay == SemitoneSteps}
          onClick={_ => setCurrentStepDisplay(_ => SemitoneSteps)}>
          {"Semitone Steps"->str}
        </StepButton>
        <StepButton
          selected={currentStepDisplay == HalfnoteSteps}
          onClick={_ => setCurrentStepDisplay(_ => HalfnoteSteps)}>
          {"Halfnote Steps"->str}
        </StepButton>
      </div>
      <div className={" "}>
        <StepButton
          selected={currentStepDisplay == Binary} onClick={_ => setCurrentStepDisplay(_ => Binary)}>
          {"Binary"->str}
        </StepButton>
      </div>
    </Card>
  }
}

@react.component
let make = () => {
  let (currentBits, setCurrentBits) = React.useState(_ => None)
  let (selectedNoteNum: option<int>, setSelectedNoteNum) = React.useState(_ => Some(7))
  let (currentKey: int, setCurrentKey) = React.useState(_ => 0)
  let (currentStepDisplay: stepDisplay, setCurrentStepDisplay) = React.useState(_ => Key)
  let (showNonModes, setShowNonModes) = React.useState(_ => false)

  let selectedGenus =
    selectedNoteNum->Option.flatMap(selectedNoteNum =>
      result
      ->Map.Int.keysToArray
      ->Array.get(selectedNoteNum)
      ->Option.flatMap(genusId =>
        result->Map.Int.get(genusId)->Option.map(species => (genusId, species))
      )
    )

  let graphDisplay = {
    switch currentStepDisplay {
    | Binary => IntervalRefs.semitones
    | Semitone => IntervalRefs.semitones
    | SemitoneSteps => IntervalRefs.semitones
    | HalfnoteSteps => IntervalRefs.semitones
    | DimAug => IntervalRefs.dimAugs
    | MinMaj => IntervalRefs.mMPs
    | Key => IntervalRefs.pitchKeys->DataGeneration.rotate(currentKey)
    }
  }

  let graphBits =
    currentBits->Option.mapWithDefault(
      Array.range(0, DataGeneration.Config.bits - 1)->Array.map(_ => 0),
      b => b,
    )

  let modeNames =
    Data.namedSpecies
    ->Array.keepMap(((s, _, modes)) => {
      modes->Array.getBy(((mId, _)) => {
        graphBits->BitOps.intArrayToString == s->scaleRepToMode(mId)
      })
    })
    ->Array.get(0)
    ->Option.mapWithDefault([], ((_, modeNames)) => modeNames->Array.map(((_, name)) => name))
    ->Js.Array2.joinWith(" • ")

  let scaleNames =
    Data.namedSpecies
    ->Array.keepMap(((sId, sNames, _modes)) => {
      let isMatch =
        graphBits
        ->DataGeneration.getRotations
        ->DataGeneration.any(x => {
          x->BitOps.intArrayToString == sId->BitOps.stringToIntArray->stepsToBits
        })

      isMatch ? sNames->Array.map(((_tradition, name)) => name)->Some : None
    })
    ->Array.concatMany
    ->Js.Array2.joinWith(" • ")

  let playNotes = () => {
    let cBaseFreq = 110
    let cChromScale = generateChromaticScale(cBaseFreq, 12)
    let newBase = cChromScale->Array.get(currentKey)->Option.getWithDefault(cBaseFreq)

    let newChromScale = generateChromaticScale(cBaseFreq + newBase, 12)

    let seq =
      newChromScale
      ->Array.keepWithIndex((_v, i) => {
        graphBits->Array.get(i)->Option.mapWithDefault(false, bit => bit == 1)
      })
      ->(x => x->Array.get(0)->Option.mapWithDefault(x, head => Array.concat(x, [head * 2])))

    seq->Array.forEachWithIndex((i, v) => {
      triggerAttackRelease(. v, "8n", i->Int.toFloat *. 0.5)
    })
  }

  <div className={"flex  flex-col sm:grid grid-cols-main sm:flex-row h-screen w-screen max-w-3xl"}>
    <div
      className="flex-1 flex flex-col w-screen sm:w-auto sm:max-w-[350px] p-2  overflow-y-scroll items-center">
      <div className="flex flex-row justify-between items-center w-full px-4">
        <PageTitle />
        {currentBits->Option.isNone
          ? React.null
          : <button
              className={"flex flex-row gap-2 py-1 px-5 rounded-full items-center
               justify-center font-bold text-white bg-[var(--accent)]"}
              onClick={_ => {playNotes()}}>
              <PlayIcon size={14} />
              {"Play"->str}
            </button>}
      </div>
      <div className=" sm:max-h-min  max-w-[500px] w-full">
        <div className={"pt-2 w-full self-center"}>
          <SVG
            data={Array.zip(graphDisplay, graphBits)}
            currentKey={currentKey}
            onKeyChange={newKey => setCurrentKey(_ => newKey)}
          />
        </div>
        {scaleNames == ""
          ? React.null
          : <div
              className="w-full tracking-tight text-center font-black  text-[var(--species-text)]">
              {`Scale: ${scaleNames}`->str}
            </div>}
        {modeNames == ""
          ? React.null
          : <div
              className="w-full tracking-tight text-center font-black text-[var(--species-text)]">
              {`Mode: ${modeNames}`->str}
            </div>}
        <StepDisplay setCurrentStepDisplay currentStepDisplay />
        <Card title={"Number of notes"}>
          <div className="grid grid-cols-6 overflow-x-scroll gap-2">
            {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]->reactMap(num => {
              <StepButton
                selected={selectedNoteNum->Option.mapWithDefault(false, i => num == i)}
                onClick={_ => setSelectedNoteNum(_ => Some(num))}>
                {num->Int.toString->str}
              </StepButton>
            })}
          </div>
        </Card>
      </div>
    </div>
    <div className="flex-1 sm:flex-1  h-full overflow-scroll xs:px-2">
      <div className="sm:max-w-[500px] pt-2">
        <Collapsed
          render={(collapsedState, setCollapsedState) => {
            <div>
              <div className={"my-2 flex flex-row justify-between items-center"}>
                <button
                  onClick={_ => setCollapsedState(s => !s)}
                  className={`px-3 py-1 font-bold rounded-lg  bg-[var(--card)]
              flex flex-row justify-center items-center gap-1`}>
                  {"About Topotonic"->str}
                  {collapsedState ? <ChevronDown /> : <ChevronUp />}
                </button>
                <div className="flex flex-row gap-2">
                  <div className="text-sm"> {"Show Non-Modes"->str} </div>
                  <Switch checked={showNonModes} onCheckedChange={() => setShowNonModes(v => !v)} />
                </div>
              </div>
              <div className={[collapsedState ? "hidden" : ""]->join}>
                <About />
              </div>
            </div>
          }}
        />
        {selectedGenus->Option.mapWithDefault(React.null, ((genusId, species)) => {
          <div className={"mb-1"}>
            <div className="flex flex-row items-center py-2 font-medium justify-center ">
              {`${genusId->Int.toString} notes: ${species
                ->Map.String.toArray
                ->Array.length
                ->Int.toString} possible scales`->str}
            </div>
            <div className={[""]->join}>
              {species
              ->Map.String.toArray
              ->reactMap(((speciesId, speciesDetails)) =>
                <Species
                  showNonModes={showNonModes}
                  key={speciesId}
                  genusId={genusId}
                  currentBits={currentBits}
                  setCurrentBits={setCurrentBits}
                  currentKey={currentKey}
                  currentStepDisplay={currentStepDisplay}
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
