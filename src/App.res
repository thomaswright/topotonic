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

// let namedData = Data.namedSpecies-> Array.
module IntervalRefs = {
  let pitchKeys = [
    `C`,
    `C♯ D♭`,
    `D`,
    `D♯ E♭`,
    `E`,
    `F`,
    `F♯ G♭`,
    `G`,
    `G♯ A♭`,
    `A`,
    `A♯ B♭`,
    `B`,
  ]

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
// `•`

module StepButton = {
  @react.component
  let make = (~selected, ~onClick, ~children) => {
    <div
      className={[
        selected
          ? "text-blue-700 border-blue-700 bg-blue-50 font-bold hover:border-blue-700"
          : "border-black bg-white font-medium border-transparent hover:border-neutral-400 hover:bg-neutral-100",
        "col-span-1 p-1 rounded-xl px-2 text-center border cursor-default",
      ]->join}
      onClick={onClick}>
      {children}
    </div>
  }
}

module Scale = {
  @react.component
  let make = (~bitString, ~currentStepDisplay, ~currentKey, ~kind: kind, ~selected as _: bool) => {
    let gridCols = switch currentStepDisplay {
    | SemitoneSteps => bitString->bitsToSemitoneSteps->Array.length
    | HalfnoteSteps => bitString->bitsToHalfnoteSteps->Array.length
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
      {switch currentStepDisplay {
      | SemitoneSteps =>
        bitString
        ->bitsToSemitoneSteps
        ->Array.mapWithIndex((i, step) => {
          container(i, step->Int.toString->str)
        })
        ->React.array

      | HalfnoteSteps =>
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
          container(i, bitToDisplaySymbol(bit, i, currentKey, currentStepDisplay, bitString)->str)
        })
        ->React.array
      }}
    </div>
  }
}

// <div className="hidden sm:block  flex-none w-10">
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
    ~currentStepDisplay,
    ~setCurrentBits,
    ~currentKey: key,
    ~speciesId: string,
    ~speciesDetails: DataGeneration.speciesDetails,
    ~showNonModes: bool,
  ) => {
    // let (base, setBase) = React.useState(_ => None)

    let scaleLength = switch currentStepDisplay {
    | SemitoneSteps => speciesId->bitsToSemitoneSteps->Array.length
    | HalfnoteSteps => speciesId->bitsToHalfnoteSteps->Array.length
    | _ => speciesId->BitOps.stringToStringArray->Array.length
    }

    let _scaleRange = Array.range(1, scaleLength)

    let speciesNameData = Data.namedSpecies->Array.keep(((s, _, _)) => {
      s->BitOps.stringToIntArray->stepsToBits == speciesId

      // ->BitOps.stringToStringArray

      // ->DataGeneration.getRotations
      // ->DataGeneration.any(x => {
      //   x->BitOps.stringArrayToString == speciesId
      // })
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

    let speciesModeNames =
      speciesNameData
      ->Array.map(((_, _, modes)) => {
        modes
        ->Array.map(((_, modeNames)) => modeNames->Array.map(((_, name)) => name))
        ->Array.concatMany
      })
      ->Array.concatMany
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

        <div className={[" py-1 border border-neutral-300 rounded-xl mb-2"]->join}>
          {speciesHidden
            ? <div className={["font-bold"]->join} onClick={onClickHeader}>
                {speciesNames == ""
                  ? speciesModeNames != ""
                      ? <div
                          className="text-sm px-3 text-center text-ellipsis overflow-hidden whitespace-nowrap">
                          {("Modes: " ++ speciesModeNames)->str}
                        </div>
                      : React.null
                  : <div className="flex flex-row justify-center items-center pb-1">
                      <div
                        className="text-lg flex-none overflow-x-hidden text-ellipsis whitespace-nowrap px-1">
                        {speciesNames->str}
                      </div>
                    </div>}
                <div className="flex flex-row">
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
                <div className="border-b mx-6 pt-2 border-neutral-300" />
                <div className={["py-1 flex flex-col divide-y"]->join}>
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
                            // if s == "1123113" {
                            //   Js.log3(
                            //     "Persian",
                            //     modeId,
                            //     s
                            //     ->BitOps.stringToIntArray
                            //     ->stepsToBits
                            //     ->BitOps.stringToIntArray
                            //     ->DataGeneration.rotate(mId)
                            //     ->BitOps.intArrayToString,
                            //   )
                            // }
                            modeId ==
                              s
                              ->BitOps.stringToIntArray
                              ->DataGeneration.rotate(mId)
                              ->stepsToBits
                              ->BitOps.stringToIntArray
                              ->BitOps.intArrayToString
                          },
                        )
                      })
                      ->Array.get(0)
                      ->Option.mapWithDefault([], ((_, modeNames)) =>
                        modeNames->Array.map(((_, name)) => name)
                      )
                      ->Js.Array2.joinWith(", ")

                    {
                      modeKind == NonMode && !showNonModes
                        ? React.null
                        : <div
                            onClick={_ =>
                              setCurrentBits(_ => modeId->BitOps.stringToIntArray->Some)}
                            key={modeId}
                            className={[
                              "flex flex-col py-1 sm:justify-start justify-center ",
                              selected ? "font-bold" : "",
                              switch modeKind {
                              | Mode => selected ? "text-accent-600 " : "text-plain-700"
                              | NonMode =>
                                selected
                                  ? "bg-plain-50 text-accent-600"
                                  : "bg-plain-50 text-plain-300"
                              | _ => ""
                              },
                            ]->join}>
                            {modeNames == ""
                              ? React.null
                              : <div
                                  className={"flex flex-row items-center text-xs px-3 py-0.5 justify-center flex-1"}>
                                  {modeNames->str}
                                </div>}
                            <Scale
                              selected={selected}
                              currentKey={currentKey}
                              currentStepDisplay={currentStepDisplay}
                              bitString={modeId}
                              kind={modeKind}
                            />
                          </div>
                    }
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
    <div className={"font-sans  flex flex-row py-2 "}>
      <Logo size={32} />
      <div className={" -ml-2"}>
        <div className={" text-[rgb(25,0,175)] font-bold text-3xl"}> {"opotonic"->str} </div>
        // <div className={"text-cyan-600 text-[10px] font-bold italic -mt-1"}>
        //   {"by T. Wright"->str}
        // </div>
      </div>
    </div>
  }
}

module Card = {
  @react.component
  let make = (~title, ~className="", ~children) => {
    <div
      className={["border  border-neutral-300 rounded-xl mt-2 overflow-hidden ", className]->join}>
      <div className="px-6">
        <div className="w-full text-center py-2 font-bold border-b border-neutral-300 ">
          {title->str}
        </div>
      </div>
      <div className={"px-2 py-3"}> {children} </div>
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

  let (currentKey: int, setCurrentKey) = React.useState(_ => 0)
  let (currentStepDisplay: stepDisplay, setCurrentStepDisplay) = React.useState(_ => Key)

  let (showNonModes, setShowNonModes) = React.useState(_ => false)

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
        graphBits->BitOps.intArrayToString ==
          s
          ->BitOps.stringToIntArray
          ->DataGeneration.rotate(mId)
          ->stepsToBits
          ->BitOps.stringToIntArray
          ->BitOps.intArrayToString
      })
    })
    ->Array.get(0)
    ->Option.mapWithDefault([], ((_, modeNames)) => modeNames->Array.map(((_, name)) => name))
    ->Js.Array2.joinWith(", ")

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
    ->Js.Array2.joinWith(", ")

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

  <div className={"flex sm:flex-row flex-col h-screen w-screen "}>
    <div
      className="flex-1 flex flex-col w-screen sm:w-auto sm:max-w-[350px] p-2  overflow-y-scroll items-center">
      <div className="flex flex-row justify-between items-center w-full px-4">
        <PageTitle />
        {currentBits->Option.isNone
          ? React.null
          : <button
              className={"flex flex-row gap-2 py-1 px-5 rounded-full items-center
               justify-center font-bold text-white bg-accent-600   hover:bg-accent-700"}
              onClick={_ => {playNotes()}}>
              <PlayIcon size={14} />
              {"Play"->str}
            </button>}
      </div>
      <div className=" sm:max-h-min  max-w-[500px] w-full">
        <div className={"pt-2 w-full self-center"}>
          <SVG data={Array.zip(graphDisplay, graphBits)} />
        </div>
        {scaleNames == ""
          ? React.null
          : <div className="w-full text-lg text-center mt-4 font-bold text-accent-600">
              {`Scale: ${scaleNames}`->str}
            </div>}
        {modeNames == ""
          ? React.null
          : <div className="w-full text-lg text-center font-bold text-accent-600">
              {`Mode: ${modeNames}`->str}
            </div>}
        <Card title={"Key"} className="mt-4">
          <div className={"grid grid-cols-4 gap-2 w-full "}>
            {IntervalRefs.pitchKeys->reactMapWithIndex((i, v) => {
              let selected = i == currentKey

              <StepButton key={v} selected={selected} onClick={_ => setCurrentKey(_ => i)}>
                {v->str}
              </StepButton>
            })}
          </div>
        </Card>
        <Card title={"Step Display"}>
          <StepButton
            selected={currentStepDisplay == Key} onClick={_ => setCurrentStepDisplay(_ => Key)}>
            {"Key"->str}
          </StepButton>
          <div className="grid grid-cols-3 gap-2 w-full pb-2 pt-2">
            <StepButton
              selected={currentStepDisplay == MinMaj}
              onClick={_ => setCurrentStepDisplay(_ => MinMaj)}>
              {"Min-Maj Int."->str}
            </StepButton>
            <StepButton
              selected={currentStepDisplay == DimAug}
              onClick={_ => setCurrentStepDisplay(_ => DimAug)}>
              {"Dim-Aug Int."->str}
            </StepButton>
            <StepButton
              selected={currentStepDisplay == Semitone}
              onClick={_ => setCurrentStepDisplay(_ => Semitone)}>
              {"Semitone Int."->str}
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
              selected={currentStepDisplay == Binary}
              onClick={_ => setCurrentStepDisplay(_ => Binary)}>
              {"Binary"->str}
            </StepButton>
          </div>
        </Card>
      </div>
    </div>
    <div className="flex-1 sm:flex-1 h-full overflow-scroll xs:px-2">
      <div className="sm:max-w-[500px] pt-2">
        <Collapsed
          render={(collapsedState, setCollapsedState) => {
            <div>
              <div className={"my-2 flex flex-row justify-between items-center"}>
                <button
                  onClick={_ => setCollapsedState(s => !s)}
                  className={`px-3 py-1  font-bold border border-neutral-300 rounded-lg 
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
        <Card title={"Number of notes in scale"}>
          <div className="flex flex-row overflow-x-scroll gap-2">
            {Array.range(1, DataGeneration.Config.bits)->reactMap(num => {
              <StepButton
                selected={selectedGenus->Option.mapWithDefault(false, ((i, _)) => num == i)}
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
              </StepButton>
            })}
          </div>
        </Card>
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
