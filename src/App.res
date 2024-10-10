open Belt

type key = int

type stepDisplay = Key | MinMaj | DimAug | Semitone | SemitoneSteps | HalfnoteSteps | Binary

type kind = Species | Mode | NonMode

// let result = DataGeneration.result

let join = Js.Array2.joinWith(_, " ")
let str = React.string
let reactMap = (a, f) => a->Array.map(f)->React.array
let reactMapWithIndex = (a, f) => a->Array.mapWithIndex(f)->React.array

// module BitOps = DataGeneration.BitOps

@module("./rotation.js") external rotationGroups: array<(int, array<int>)> = "rotationGroups"
@module("./rotation.js") external intToBoolArray: int => array<bool> = "intToBoolArray"
@module("./rotation.js")
external areInSameRotationClass: (int, int) => bool = "areInSameRotationClass"
@module("./rotation.js") external getMinRotation: int => int = "getMinRotation"
@module("./rotation.js") external getMaxRotation: int => int = "getMaxRotation"
@module("./rotation.js") external rotateRightByOnes: (int, int) => int = "rotateRightByOnes"
@module("./rotation.js") external getAllRotations: int => array<int> = "getAllRotations"

module Logo = {
  @module("./Icons.jsx") @react.component
  external make: (~size: int) => React.element = "Logo"
}

module SVG = {
  @module("./SVG.jsx") @react.component
  external make: (
    ~playing: option<int>,
    ~labels: array<string>,
    ~selected: array<bool>,
    ~currentKey: int,
    ~onKeyChange: int => unit,
    ~rotationOffset: int,
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

  let pitchKeysShort = [`C`, `C♯`, `D`, `E♭`, `E`, `F`, `F♯`, `G`, `A♭`, `A`, `B♭`, `B`]
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

let rotationToSemitoneSteps = x => {
  x
  ->intToBoolArray
  ->Array.joinWith("", v => v ? "1" : "0")
  ->Js.String2.split("1")
  ->Array.map(a => {
    a->Js.String2.length + 1
  })
  ->Belt.Array.sliceToEnd(1)
}

let rotationToHalfnoteSteps = x => {
  x
  ->intToBoolArray
  ->Array.joinWith("", v => v ? "1" : "0")
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

let bitToDisplaySymbol = (bit, index, currentKey, currentStepDisplay, rotation) => {
  let a = switch currentStepDisplay {
  | Key => IntervalRefs.pitchKeysShort->DataGeneration.rotate(currentKey)
  | DimAug => IntervalRefs.dimAugs
  | Semitone => IntervalRefs.semitones
  | MinMaj => IntervalRefs.mMPs
  | SemitoneSteps => IntervalRefs.semitones
  | HalfnoteSteps => IntervalRefs.semitones
  | Binary => rotation->intToBoolArray->Array.map(v => v ? "1" : "0")
  }
  !bit ? `•` : a->Array.get(index)->Option.getWithDefault("")
}

// let scaleRepToMode = (s, rot) =>
//   s
//   ->BitOps.stringToIntArray
//   ->DataGeneration.rotate(rot)
//   ->stepsToBits
//   ->BitOps.stringToIntArray
//   ->BitOps.intArrayToString

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
  let make = (
    ~rotation,
    ~currentStepDisplay,
    ~currentKey,
    ~kind: kind,
    ~playing: option<int>,
    ~selected: bool,
  ) => {
    let gridCols = switch currentStepDisplay {
    | SemitoneSteps => rotation->rotationToSemitoneSteps->Array.length
    | HalfnoteSteps => rotation->rotationToHalfnoteSteps->Array.length
    | _ => 12
    }->getGridCols

    let container = (i, isPlaying, content) => {
      <div
        key={i->Int.toString}
        className={[
          "w-6 flex flex-row items-center justify-center ",
          isPlaying ? "text-[var(--red)]" : "",
        ]->join}>
        {content->str}
      </div>
    }

    <div className={["flex-none flex-row flex justify-center w-full gap-0.5"]->join}>
      {switch currentStepDisplay {
      | SemitoneSteps =>
        rotation
        ->rotationToSemitoneSteps
        ->Array.mapWithIndex((i, step) => {
          let isPlaying =
            selected &&
            playing->Option.mapWithDefault(false, playing => {
              playing == i
            })
          container(i, isPlaying, step->Int.toString)
        })
        ->React.array

      | HalfnoteSteps =>
        rotation
        ->rotationToHalfnoteSteps
        ->Array.mapWithIndex((i, step) => {
          let isPlaying =
            selected &&
            playing->Option.mapWithDefault(false, playing => {
              playing == i
            })

          container(i, isPlaying, step)
        })
        ->React.array

      | _ =>
        rotation
        ->intToBoolArray
        ->Array.mapWithIndex((i, bit) => {
          let isPlaying =
            selected &&
            bit &&
            playing->Option.mapWithDefault(false, playing => {
              let numInSeq =
                rotation
                ->intToBoolArray
                ->Js.Array2.slice(~start=0, ~end_=i)
                ->Array.keep(x => x)
                ->Array.length

              playing == numInSeq
            })

          container(
            i,
            isPlaying,
            bitToDisplaySymbol(bit, i, currentKey, currentStepDisplay, rotation),
          )
        })
        ->React.array
      }}
    </div>
  }
}

@val external parseInt: (string, int) => option<int> = "parseInt"

// Todo: replace this mess
let stepsToRotation = steps => {
  steps
  ->Js.String2.split("")
  ->Array.reduce([], (a, step) => {
    Array.concat(
      a,
      Array.concat(
        [1],
        step
        ->Int.fromString
        ->Option.mapWithDefault([], step => {
          if step > 1 {
            Array.make(step - 1, 0)
          } else {
            []
          }
        }),
      ),
    )
  })
  ->Array.joinWith("", x => x->Int.toString)
  ->parseInt(2)
  ->Option.getWithDefault(0)
}

module Species = {
  @react.component
  let make = (
    ~genusId,
    ~playing: option<int>,
    ~rotation: option<int>,
    ~currentStepDisplay,
    ~setRotation,
    ~currentKey: key,
    ~speciesId: int,
    // ~speciesDetails: DataGeneration.speciesDetails,
    ~modes: array<int>,
    ~showNonModes: bool,
  ) => {
    let scaleLength = switch currentStepDisplay {
    | SemitoneSteps => speciesId->rotationToSemitoneSteps->Array.length
    | HalfnoteSteps => speciesId->rotationToHalfnoteSteps->Array.length
    | _ => 12
    }

    let _scaleRange = Array.range(1, scaleLength)

    let speciesNameData = Data.namedSpecies->Array.keep(((s, _, _)) => {
      s->stepsToRotation->getMinRotation == speciesId
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

    // let numModes =
    //   speciesDetails.modes
    //   ->Array.keep(((modeId, _)) => modeId->BitOps.stringToStringArray->DataGeneration.startsWith1)
    //   ->Array.length

    // let numPitchClasses = speciesDetails.modes->Array.length

    // let _uniqueNumModes = numModes != genusId

    // let _modesDisplay =
    //   <span> {`(${numModes->Int.toString}:${numPitchClasses->Int.toString})`->str} </span>

    <Collapsed
      render={(speciesHidden, setSpeciesHidden) => {
        let anySelected = areInSameRotationClass(rotation->Option.getWithDefault(0), speciesId)

        // speciesDetails.modes->DataGeneration.any(((rotation, _)) => {
        //   currentBits->Option.mapWithDefault(false, c => c->BitOps.intArrayToString == rotation)
        // })

        // let _speciesIdModeSelected =
        //   currentBits->Option.mapWithDefault(false, c => c->BitOps.intArrayToString == speciesId)

        let scaleName = speciesId->getMaxRotation->Int.toString
        let speciesMax = speciesId->getMaxRotation

        let onClickHeader = _ => {
          rotation->Option.mapWithDefault(
            {
              setSpeciesHidden(_ => false)
              setRotation(_ => speciesMax->Some)
            },
            _ => {
              setSpeciesHidden(_ => !speciesHidden ? anySelected : !speciesHidden)
              setRotation(_ => anySelected ? None : speciesMax->Some)
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
          {if speciesHidden {
            <div className={[""]->join} onClick={onClickHeader}>
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
              <div className="flex flex-row bg-[var(--species-scales)] rounded-xl py-1 font-medium">
                <Scale
                  playing
                  selected={false}
                  currentKey={currentKey}
                  rotation={speciesMax}
                  kind={Species}
                  currentStepDisplay={currentStepDisplay}
                />
                // <div className=" flex-none flex flex-row items-center justify-center w-10 px-1">
                //   {speciesDetails.isSymmetric ? <Symmetry /> : React.null}
                // </div>
              </div>
            </div>
          } else {
            <div>
              <div
                onClick={_ => {
                  setSpeciesHidden(_ => true)
                }}
                className=" flex flex-row justify-start items-center px-3 pt-1">
                {speciesNamesComp}
                <div className={"flex flex-row items-center justify-center gap-2"}>
                  <div className="flex-none"> {false ? <Symmetry /> : React.null} </div>
                  <div className="flex-none text-sm tracking-wide "> {`#${scaleName}`->str} </div>
                </div>
              </div>
              <div className="p-2 pt-0 bg-[var(--species-scales)] rounded-xl">
                <div
                  className={[
                    "rounded-lg flex flex-col divide-y bg-white divide-[var(--species-open-bg)]",
                  ]->join}>
                  {modes->reactMapWithIndex((_i, modeId) => {
                    let selected = rotation->Option.mapWithDefault(false, c => c == modeId)

                    let modeKind = modeId->intToBoolArray->Array.getUnsafe(0) ? Mode : NonMode

                    let modeNames =
                      speciesNameData
                      ->Array.keepMap(((s, _, modes)) => {
                        modes->Array.getBy(
                          ((mId, _)) => {
                            modeId == s->stepsToRotation->rotateRightByOnes(mId + 1)
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
                            onClick={_ => setRotation(_ => modeId->Some)}
                            key={modeId->Int.toString}
                            className={[
                              "flex flex-col py-1 sm:justify-start justify-center ",
                              selected
                                ? "text-[var(--accent)] bg-[var(--scale-highlight)] font-black"
                                : modeKind == NonMode
                                ? "text-neutral-400 font-medium "
                                : "  font-medium",
                            ]->join}>
                            <Scale
                              playing
                              selected={selected}
                              currentKey={currentKey}
                              currentStepDisplay={currentStepDisplay}
                              rotation={modeId}
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
            </div>
          }}
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
  // let (currentBits, setCurrentBits) = React.useState(_ => None)
  let (rotation: option<int>, setRotation) = React.useState(_ => None)
  let (playing, setPlaying) = React.useState(_ => None)
  let (selectedNoteNum: int, setSelectedNoteNum) = React.useState(_ => 7)
  let (currentKey: int, setCurrentKey) = React.useState(_ => 0)
  let (currentStepDisplay: stepDisplay, setCurrentStepDisplay) = React.useState(_ => Key)
  let (showNonModes, setShowNonModes) = React.useState(_ => false)
  // let selectedGenus =
  //   selectedNoteNum->Option.flatMap(selectedNoteNum =>
  //     result
  //     ->Map.Int.keysToArray
  //     ->Array.get(selectedNoteNum)
  //     ->Option.flatMap(genusId =>
  //       result->Map.Int.get(genusId)->Option.map(species => (genusId, species))
  //     )
  //   )

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
    rotation->Option.mapWithDefault(Array.make(12, false), (b: int) =>
      b->getMaxRotation->intToBoolArray
    )

  let modeNames =
    Data.namedSpecies
    ->Array.keepMap(((s, _, modes)) => {
      modes->Array.getBy(((mId, _)) => {
        rotation->Option.getWithDefault(0) == s->stepsToRotation->rotateRightByOnes(mId + 1)
      })
    })
    ->Array.get(0)
    ->Option.mapWithDefault([], ((_, modeNames)) => modeNames->Array.map(((_, name)) => name))
    ->Js.Array2.joinWith(" • ")

  let scaleNames =
    Data.namedSpecies
    ->Array.keepMap(((sId, sNames, _modes)) => {
      let isMatch =
        sId->stepsToRotation->getMinRotation == rotation->Option.getWithDefault(0)->getMinRotation
      // graphBits
      // ->DataGeneration.getRotations
      // ->DataGeneration.any(x => {
      //   x->BitOps.intArrayToString == sId->BitOps.stringToIntArray->stepsToBits
      // })

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
        rotation
        ->Option.mapWithDefault(Array.make(12, false), (b: int) => b->intToBoolArray)
        ->Array.getUnsafe(i)
      })
      ->(x => x->Array.get(0)->Option.mapWithDefault(x, head => Array.concat(x, [head * 2])))

    seq->Array.forEachWithIndex((i, v) => {
      triggerAttackRelease(. v, "4n", i->Int.toFloat *. 0.5)
      Js.Global.setTimeout(() => {
        setPlaying(_ => Some(i))
      }, i * 500)->ignore
    })
    Js.Global.setTimeout(() => {
      setPlaying(_ => None)
    }, seq->Array.length * 500)->ignore
  }

  let species = rotationGroups->Array.keep(((speciesId, scales)) => {
    speciesId->intToBoolArray->Array.keep(x => x)->Array.length == selectedNoteNum
  })

  let rotationOffset =
    rotation
    ->Option.flatMap(r => {
      r->getMaxRotation->getAllRotations->Array.getIndexBy(v => v == r)
    })
    ->Option.getWithDefault(0)

  <div className={"flex  flex-col sm:grid grid-cols-main sm:flex-row h-screen w-screen max-w-3xl"}>
    <div
      className="flex-1 flex flex-col w-screen sm:w-auto sm:max-w-[350px] p-2  overflow-y-scroll items-center">
      <div className="flex flex-row justify-between items-center w-full pl-3 pr-1">
        <PageTitle />
        {rotation->Option.isNone
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
        <div className={"pt-2 w-full self-center text-[var(--dim)]"}>
          <SVG
            playing={playing}
            rotationOffset={rotationOffset}
            labels={graphDisplay}
            selected={rotation->Option.mapWithDefault(Array.make(12, false), (b: int) =>
              b->getMaxRotation->intToBoolArray
            )}
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
                selected={selectedNoteNum == num} onClick={_ => setSelectedNoteNum(_ => num)}>
                {num->Int.toString->str}
              </StepButton>
            })}
          </div>
        </Card>
        <div className="my-2 flex flex-row justify-between items-center">
          <About />
          <div className="flex flex-row gap-2">
            <div className="text-sm"> {"Show Non-Modes"->str} </div>
            <Switch checked={showNonModes} onCheckedChange={() => setShowNonModes(v => !v)} />
          </div>
        </div>
      </div>
    </div>
    <div className="flex-1 sm:flex-1  h-full overflow-scroll xs:px-2">
      <div className="sm:max-w-[500px] pt-2">
        <div className={"mb-1"}>
          <div className="flex flex-row items-center py-2 font-medium justify-center ">
            {`${selectedNoteNum->Int.toString} notes: ${species
              ->Array.length
              ->Int.toString} possible scales`->str}
          </div>
          <div className={[""]->join}>
            {species
            ->Array.reverse
            ->reactMap(((speciesId, modes)) =>
              <Species
                playing
                showNonModes={showNonModes}
                key={speciesId->Int.toString}
                genusId={selectedNoteNum}
                rotation={rotation}
                setRotation={setRotation}
                currentKey={currentKey}
                currentStepDisplay={currentStepDisplay}
                speciesId={speciesId}
                modes={modes}
              // speciesDetails={speciesDetails}
              />
            )}
          </div>
        </div>
      </div>
    </div>
  </div>
}

let default = make
