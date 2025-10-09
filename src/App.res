open Belt

type key = int

type stepDisplay = Key | MinMaj | DimAug | Semitone | SemitoneSteps | HalfnoteSteps | Binary

type kind = Species | Mode | NonMode

@module("./rotation.js") external rotationGroups: array<(int, array<int>)> = "rotationGroups"
@module("./rotation.js") external intToBoolArray: int => array<bool> = "intToBoolArray"
@module("./rotation.js")
external areInSameRotationClass: (int, int) => bool = "areInSameRotationClass"
@module("./rotation.js") external getMinRotation: int => int = "getMinRotation"
@module("./rotation.js") external getMaxRotation: int => int = "getMaxRotation"
@module("./rotation.js") external rotateRightByOnes: (int, int) => int = "rotateRightByOnes"
@module("./rotation.js") external getAllRotations: int => array<int> = "getAllRotations"

module Attribution = {
  @react.component
  let make = () => {
    <div className="text-xs p-6">
      <span className={"font-normal text-gray-600"}> {"By "->React.string} </span>
      <a className="font-bold text-blue-600" href={"https://github.com/thomaswright/topotonic"}>
        {"Thomas Wright"->React.string}
      </a>
    </div>
  }
}

module Logo = {
  @module("./Icons.jsx") @react.component
  external make: (~size: int) => React.element = "Logo"
}

module SVG = {
  @module("./SVG.jsx") @react.component
  external make: (
    ~playing: option<int>,
    ~labels: array<string>,
    ~stepLabels: option<array<string>>,
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

module About = {
  @module("./about.jsx") @react.component
  external make: unit => React.element = "default"
}

// Must be uncurried.
// Will throw a "this is undefined" error otherwise.
type notePlayer = {
  playNote: (. int, int) => unit,
  setVolume: (. float) => unit,
  playNotesSequentially: (. array<(int, int)>, int) => unit,
}

@module("./NotePlayer.js") @new external makeNotePlayer: unit => notePlayer = "default"

@module("./Tone.js") external triggerAttackRelease: (. float, string, float) => unit = "default"
@val external parseInt: (string, int) => option<int> = "parseInt"

let join = Js.Array2.joinWith(_, " ")
let reactMap = (a, f) => a->Array.map(f)->React.array
let reactMapWithIndex = (a, f) => a->Array.mapWithIndex(f)->React.array

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
  let pitchKeys = [`C`, `C♯ `, `D`, `E♭`, `E`, `F`, `F♯ `, `G`, `A♭`, `A`, `B♭`, `B`]
  let pitchKeysShort = [`C`, `C♯`, `D`, `E♭`, `E`, `F`, `F♯`, `G`, `A♭`, `A`, `B♭`, `B`]
  let semitones = [`0`, `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `11`]
  let mMPs = [`P1`, `m2`, `M2`, `m3`, `M3`, `P4`, `TT`, `P5`, `m6`, `M6`, `m7`, `M7`]
  // TODO: replace TT with d5/A4 when we have proper scaling
  let dimAugs = [`d2`, `A1`, `d3`, `A2`, `d4`, `A3`, `TT`, `d6`, `A5`, `d7`, `A6`, `d8`]
}

let generateChromaticScale = (startFrequency, numNotes) => {
  let semitoneRatio = 2. ** (1. /. 12.)

  Array.range(0, numNotes)->Array.map(v => {
    startFrequency *. semitoneRatio ** v->Float.fromInt
  })
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

let rotateArray = (values, shift) => {
  let length = values->Array.length
  if length == 0 {
    values
  } else {
    let offset = {
      let raw = mod(shift, length)
      raw < 0 ? raw + length : raw
    }
    let tail = values->Js.Array2.slice(~start=offset, ~end_=length)
    let head = values->Js.Array2.slice(~start=0, ~end_=offset)
    Array.concat(tail, head)
  }
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
  | Key => IntervalRefs.pitchKeysShort->rotateArray(currentKey)
  | DimAug => IntervalRefs.dimAugs
  | Semitone => IntervalRefs.semitones
  | MinMaj => IntervalRefs.mMPs
  | SemitoneSteps => IntervalRefs.semitones
  | HalfnoteSteps => IntervalRefs.semitones
  | Binary => rotation->intToBoolArray->Array.map(v => v ? "1" : "0")
  }
  !bit ? `•` : a->Array.get(index)->Option.getWithDefault("")
}

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
      {"Topotonic"->React.string}
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
      <div className="w-full text-center pb-2 font-bold text-lg "> {title->React.string} </div>
      <div className={""}> {children} </div>
    </div>
  }
}

module Scale = {
  let container = (i, isPlaying, content) => {
    <div
      key={i->Int.toString}
      className={[
        "w-6 flex flex-row items-center justify-center ",
        isPlaying ? "text-[var(--accent)]" : "",
      ]->join}>
      {content->React.string}
    </div>
  }

  @react.component
  let make = (
    ~rotation,
    ~currentStepDisplay,
    ~currentKey,
    ~playing: option<int>,
    ~selected: bool,
  ) => {
    let isPlayingAt = (~selected, ~index) =>
      selected && playing->Option.mapWithDefault(false, playingIndex => playingIndex == index)

    let renderValues = (values, toString) =>
      values
      ->Array.mapWithIndex((i, value) =>
        container(i, isPlayingAt(~selected, ~index=i), toString(value))
      )
      ->React.array

    let stepElements = switch currentStepDisplay {
    | SemitoneSteps =>
      let semitoneSteps = rotation->rotationToSemitoneSteps
      renderValues(semitoneSteps, step => step->Int.toString)
    | HalfnoteSteps =>
      let halfnoteSteps = rotation->rotationToHalfnoteSteps
      renderValues(halfnoteSteps, step => step)
    | _ =>
      let bits = rotation->intToBoolArray
      let noteIndex = ref(0)
      bits
      ->Array.mapWithIndex((i, bit) => {
        let currentSeqIndex = noteIndex.contents
        if bit {
          noteIndex := currentSeqIndex + 1
        }
        let isPlaying = isPlayingAt(~selected=selected && bit, ~index=currentSeqIndex)
        container(
          i,
          isPlaying,
          bitToDisplaySymbol(bit, i, currentKey, currentStepDisplay, rotation),
        )
      })
      ->React.array
    }

    <div className={["flex-none flex-row flex justify-center w-full gap-0.5"]->join}>
      {stepElements}
    </div>
  }
}

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
  let joinNonEmptyNames = names =>
    names->Array.keep(name => name != "")->Js.Array2.joinWith(" • ")

  let findSpeciesNameData = speciesId =>
    Data.namedSpecies->Array.keep(((s, _, _)) => s->stepsToRotation->getMinRotation == speciesId)

  let resolveSpeciesNames = speciesNameData =>
    speciesNameData
    ->Array.map(((_, names, _)) => names->Array.map(((_, name)) => name)->joinNonEmptyNames)
    ->joinNonEmptyNames

  let resolveSpeciesModeNames = speciesNameData =>
    speciesNameData
    ->Array.map(((_, _, modes)) =>
      modes
      ->Array.map(((_, modeNames)) => modeNames->Array.map(((_, name)) => name))
      ->Array.concatMany
    )
    ->Array.concatMany
    ->joinNonEmptyNames

  let resolveModeNames = (speciesNameData, modeId) =>
    speciesNameData
    ->Array.keepMap(((s, _, modes)) =>
      modes->Array.getBy(((mId, _)) => modeId == s->stepsToRotation->rotateRightByOnes(mId + 1))
    )
    ->Array.get(0)
    ->Option.mapWithDefault([], ((_, modeNames)) => modeNames->Array.map(((_, name)) => name))
    ->joinNonEmptyNames

  let getScaleLength = (speciesId, currentStepDisplay) =>
    switch currentStepDisplay {
    | SemitoneSteps => speciesId->rotationToSemitoneSteps->Array.length
    | HalfnoteSteps => speciesId->rotationToHalfnoteSteps->Array.length
    | _ => 12
    }

  let toggleHiddenState = (hidden, anySelected) =>
    if hidden {
      false
    } else {
      anySelected
    }

  module ModeList = {
    @react.component
    let make = (
      ~modes,
      ~rotation,
      ~currentKey,
      ~currentStepDisplay,
      ~setRotation,
      ~speciesNameData,
      ~showNonModes,
      ~playing,
    ) => {
      modes->reactMapWithIndex((_i, modeId) => {
        let selected = rotation->Option.mapWithDefault(false, c => c == modeId)
        let isMode = modeId->intToBoolArray->Array.get(0)->Option.getWithDefault(false)
        let modeKind = isMode ? Mode : NonMode
        let modeNames = speciesNameData->resolveModeNames(modeId)

        {
          modeKind == NonMode && !showNonModes
            ? React.null
            : <div
                onClick={_ => setRotation(_ => modeId->Some)}
                key={modeId->Int.toString}
                className={[
                  "flex flex-col py-1 sm:justify-start justify-center ",
                  selected
                    ? "text-[var(--highlight)] bg-[var(--scale-highlight)] font-black"
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
                />
                {modeNames == ""
                  ? React.null
                  : <div
                      className={[
                        "flex flex-row tracking-tight items-center text-xs px-3 py-0.5 flex-1",
                        selected ? " text-[var(--species-text)] " : "   text-[var(--species-text)]",
                      ]->join}>
                      {modeNames->React.string}
                    </div>}
              </div>
        }
      })
    }
  }

  @react.component
  let make = (
    ~playing: option<int>,
    ~rotation: option<int>,
    ~currentStepDisplay,
    ~setRotation,
    ~currentKey: key,
    ~speciesId: int,
    ~modes: array<int>,
    ~showNonModes: bool,
    ~speciesHidden: bool,
    ~setSpeciesHidden: bool => unit,
  ) => {
    // precompute derived data for readability
    let _scaleRange = Array.range(1, speciesId->getScaleLength(currentStepDisplay))
    let speciesNameData = speciesId->findSpeciesNameData
    let speciesNames = speciesNameData->resolveSpeciesNames
    let speciesModeNames = speciesNameData->resolveSpeciesModeNames

    let currentRotation = rotation->Option.getWithDefault(0)
    let anySelected = areInSameRotationClass(currentRotation, speciesId)

    let speciesMax = speciesId->getMaxRotation
    let scaleName = speciesMax->Int.toString

    let onClickHeader = _ =>
      switch rotation {
      | None =>
        setSpeciesHidden(false)
        setRotation(_ => speciesMax->Some)
      | Some(_) =>
        let nextHidden = speciesHidden->toggleHiddenState(anySelected)
        setSpeciesHidden(nextHidden)
        setRotation(_ => anySelected ? None : speciesMax->Some)
      }

    let speciesNamesComp =
      <div
        className={[
          " text-[var(--species-text)]  flex-1 text-ellipsis overflow-hidden  whitespace-nowrap ",
          anySelected ? "font-black" : "",
        ]->join}>
        {speciesNames->React.string}
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
                {("Modes: " ++ speciesModeNames)->React.string}
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
            onClick={_ => setSpeciesHidden(true)}
            className=" flex flex-row justify-start items-center px-3 pt-1">
            {speciesNamesComp}
            <div className={"flex flex-row items-center justify-center gap-2"}>
              <div className="flex-none"> {false ? <Symmetry /> : React.null} </div>
              <div className="flex-none text-sm tracking-wide ">
                {`#${scaleName}`->React.string}
              </div>
            </div>
          </div>
          <div className="p-2 pt-0 bg-[var(--species-scales)] rounded-xl">
            <div
              className={[
                "rounded-lg flex flex-col divide-y bg-white divide-[var(--species-open-bg)]",
              ]->join}>
              <ModeList
                modes={modes}
                rotation={rotation}
                currentKey={currentKey}
                currentStepDisplay={currentStepDisplay}
                setRotation={setRotation}
                speciesNameData={speciesNameData}
                showNonModes={showNonModes}
                playing={playing}
              />
            </div>
          </div>
        </div>
      }}
    </div>
  }
}

module StepDisplay = {
  @react.component
  let make = (~currentStepDisplay, ~setCurrentStepDisplay) => {
    <Card title={"Step Display"}>
      <StepButton
        selected={currentStepDisplay == Key} onClick={_ => setCurrentStepDisplay(_ => Key)}>
        {"Key"->React.string}
      </StepButton>
      <div className="grid grid-cols-3 gap-2 w-full pb-2 pt-2">
        <StepButton
          selected={currentStepDisplay == MinMaj} onClick={_ => setCurrentStepDisplay(_ => MinMaj)}>
          {"Min-Maj"->React.string}
        </StepButton>
        <StepButton
          selected={currentStepDisplay == DimAug} onClick={_ => setCurrentStepDisplay(_ => DimAug)}>
          {"Dim-Aug"->React.string}
        </StepButton>
        <StepButton
          selected={currentStepDisplay == Semitone}
          onClick={_ => setCurrentStepDisplay(_ => Semitone)}>
          {"Index"->React.string}
        </StepButton>
      </div>
      <div className="grid grid-cols-2 gap-2 w-full pb-2">
        <StepButton
          selected={currentStepDisplay == SemitoneSteps}
          onClick={_ => setCurrentStepDisplay(_ => SemitoneSteps)}>
          {"Semitones"->React.string}
        </StepButton>
        <StepButton
          selected={currentStepDisplay == HalfnoteSteps}
          onClick={_ => setCurrentStepDisplay(_ => HalfnoteSteps)}>
          {"Halfnotes"->React.string}
        </StepButton>
      </div>
      <div className={" "}>
        <StepButton
          selected={currentStepDisplay == Binary} onClick={_ => setCurrentStepDisplay(_ => Binary)}>
          {"Binary"->React.string}
        </StepButton>
      </div>
    </Card>
  }
}

let deriveStepLabels = currentStepDisplay =>
  switch currentStepDisplay {
  | Binary => None
  | HalfnoteSteps => None
  | SemitoneSteps => None
  | Semitone => IntervalRefs.semitones->Some
  | DimAug => IntervalRefs.dimAugs->Some
  | MinMaj => IntervalRefs.mMPs->Some
  | Key => None
  }

let collectModeNames = rotation =>
  switch rotation {
  | None => ""
  | Some(rotationValue) =>
    Data.namedSpecies
    ->Array.keepMap(((s, _, modes)) =>
      modes->Array.getBy(((mId, _)) =>
        rotationValue == s->stepsToRotation->rotateRightByOnes(mId + 1)
      )
    )
    ->Array.get(0)
    ->Option.mapWithDefault([], ((_, modeNames)) => modeNames->Array.map(((_, name)) => name))
    ->Js.Array2.joinWith(" • ")
  }

let collectScaleNames = rotation =>
  switch rotation {
  | None => ""
  | Some(rotationValue) =>
    let targetMin = rotationValue->getMinRotation
    Data.namedSpecies
    ->Array.keepMap(((sId, sNames, _modes)) => {
      let isMatch = sId->stepsToRotation->getMinRotation == targetMin
      isMatch ? sNames->Array.map(((_tradition, name)) => name)->Some : None
    })
    ->Array.concatMany
    ->Js.Array2.joinWith(" • ")
  }

let filterSpeciesByNoteCount = selectedNoteNum =>
  rotationGroups->Array.keep(((speciesId, _scales)) =>
    speciesId->intToBoolArray->Array.keep(x => x)->Array.length == selectedNoteNum
  )

let computeRotationOffset = rotation =>
  rotation
  ->Option.flatMap(r => r->getMaxRotation->getAllRotations->Array.getIndexBy(v => v == r))
  ->Option.getWithDefault(0)

let rotationToSelectedNotes = rotation =>
  rotation->Option.mapWithDefault(Array.make(12, false), (value: int) =>
    value->getMaxRotation->intToBoolArray
  )

module Persistence = {
  let prefix = "topotonic."
  let rotationKey = "rotation"
  let noteCountKey = "selectedNoteNum"
  let keyKey = "currentKey"
  let stepDisplayKey = "stepDisplay"
  let showNonModesKey = "showNonModes"
  let speciesOpenKey = "speciesOpen"

  let makeKey = suffix => prefix ++ suffix

  let getStorage = () =>
    try {
      Dom.Storage2.localStorage->Some
    } catch {
    | _ => None
    }

  let getItem = suffix =>
    switch getStorage() {
    | None => None
    | Some(storage) => storage->Dom.Storage2.getItem(makeKey(suffix))
    }

  let setItem = (suffix, value) =>
    switch getStorage() {
    | None => ()
    | Some(storage) => storage->Dom.Storage2.setItem(makeKey(suffix), value)
    }

  let removeItem = suffix =>
    switch getStorage() {
    | None => ()
    | Some(storage) => storage->Dom.Storage2.removeItem(makeKey(suffix))
    }

  let stepDisplayToString = display =>
    switch display {
    | Key => "key"
    | MinMaj => "minMaj"
    | DimAug => "dimAug"
    | Semitone => "semitone"
    | SemitoneSteps => "semitoneSteps"
    | HalfnoteSteps => "halfnoteSteps"
    | Binary => "binary"
    }

  let stepDisplayFromString = value =>
    switch value {
    | "key" => Some(Key)
    | "minMaj" => Some(MinMaj)
    | "dimAug" => Some(DimAug)
    | "semitone" => Some(Semitone)
    | "semitoneSteps" => Some(SemitoneSteps)
    | "halfnoteSteps" => Some(HalfnoteSteps)
    | "binary" => Some(Binary)
    | _ => None
    }

  let loadRotation = () => getItem(rotationKey)->Option.flatMap(Int.fromString)

  let saveRotation = rotation =>
    switch rotation {
    | None => removeItem(rotationKey)
    | Some(value) => setItem(rotationKey, value->Int.toString)
    }

  let loadSelectedNoteNum = (~default) =>
    getItem(noteCountKey)
    ->Option.flatMap(value =>
      switch Int.fromString(value) {
      | Some(parsed) if parsed >= 1 && parsed <= 12 => Some(parsed)
      | _ => None
      }
    )
    ->Option.getWithDefault(default)

  let saveSelectedNoteNum = value => setItem(noteCountKey, value->Int.toString)

  let loadCurrentKey = (~default) =>
    getItem(keyKey)
    ->Option.flatMap(value =>
      switch Int.fromString(value) {
      | Some(parsed) if parsed >= 0 && parsed <= 11 => Some(parsed)
      | _ => None
      }
    )
    ->Option.getWithDefault(default)

  let saveCurrentKey = value => setItem(keyKey, value->Int.toString)

  let loadStepDisplay = (~default) =>
    getItem(stepDisplayKey)->Option.flatMap(stepDisplayFromString)->Option.getWithDefault(default)

  let saveStepDisplay = value => setItem(stepDisplayKey, stepDisplayToString(value))

  let loadShowNonModes = (~default) =>
    getItem(showNonModesKey)
    ->Option.flatMap(value =>
      switch value {
      | "true" => Some(true)
      | "false" => Some(false)
      | _ => None
      }
    )
    ->Option.getWithDefault(default)

  let saveShowNonModes = value => setItem(showNonModesKey, value ? "true" : "false")

  let decodeSpeciesOpen = value => {
    let trimmed = value->Js.String2.trim
    if trimmed == "" {
      Belt.Set.Int.empty
    } else {
      trimmed
      ->Js.String2.split(",")
      ->Array.reduce(Belt.Set.Int.empty, (acc, part) =>
        switch part->Js.String2.trim->Int.fromString {
        | Some(id) => Belt.Set.Int.add(acc, id)
        | None => acc
        }
      )
    }
  }

  let encodeSpeciesOpen = openSet =>
    openSet->Belt.Set.Int.toArray->Array.joinWith(",", id => id->Int.toString)

  let loadSpeciesOpenSet = () =>
    getItem(speciesOpenKey)
    ->Option.map(decodeSpeciesOpen)
    ->Option.getWithDefault(Belt.Set.Int.empty)

  let saveSpeciesOpenSet = openSet => {
    let encoded = encodeSpeciesOpen(openSet)
    if encoded == "" {
      removeItem(speciesOpenKey)
    } else {
      setItem(speciesOpenKey, encoded)
    }
  }
}

@react.component
let make = () => {
  let (rotation: option<int>, setRotation) = React.useState(_ => Persistence.loadRotation())
  let (playing, setPlaying) = React.useState(_ => None)
  let (selectedNoteNum: int, setSelectedNoteNum) = React.useState(_ =>
    Persistence.loadSelectedNoteNum(~default=7)
  )
  let (currentKey: int, setCurrentKey) = React.useState(_ => Persistence.loadCurrentKey(~default=0))
  let (currentStepDisplay: stepDisplay, setCurrentStepDisplay) = React.useState(_ =>
    Persistence.loadStepDisplay(~default=Key)
  )
  let (showNonModes, setShowNonModes) = React.useState(_ =>
    Persistence.loadShowNonModes(~default=false)
  )
  let (openSpecies, setOpenSpecies) = React.useState(_ => Persistence.loadSpeciesOpenSet())

  React.useEffect1(() => {
    Persistence.saveRotation(rotation)
    None
  }, [rotation])

  React.useEffect1(() => {
    Persistence.saveSelectedNoteNum(selectedNoteNum)
    None
  }, [selectedNoteNum])

  React.useEffect1(() => {
    Persistence.saveCurrentKey(currentKey)
    None
  }, [currentKey])

  React.useEffect1(() => {
    Persistence.saveStepDisplay(currentStepDisplay)
    None
  }, [currentStepDisplay])

  React.useEffect1(() => {
    Persistence.saveShowNonModes(showNonModes)
    None
  }, [showNonModes])

  React.useEffect1(() => {
    Persistence.saveSpeciesOpenSet(openSpecies)
    None
  }, [openSpecies])

  let stepLabels = deriveStepLabels(currentStepDisplay)

  let modeNames = collectModeNames(rotation)
  let scaleNames = collectScaleNames(rotation)
  let selectedNotes = rotationToSelectedNotes(rotation)
  let species = filterSpeciesByNoteCount(selectedNoteNum)
  let rotationOffset = computeRotationOffset(rotation)
  let pitchLabels = IntervalRefs.pitchKeys->rotateArray(currentKey)
  let noteCounts = Array.range(1, 12)

  let isSpeciesHidden = speciesId => !Belt.Set.Int.has(openSpecies, speciesId)

  let updateSpeciesHidden = (speciesId, nextHidden) =>
    setOpenSpecies(prevSet =>
      nextHidden ? Belt.Set.Int.remove(prevSet, speciesId) : Belt.Set.Int.add(prevSet, speciesId)
    )

  let playNotes = rotationValue => {
    switch rotationValue {
    | None => ()
    | Some(rotationInt) =>
      let cBaseFreq = 261.626
      let cChromScale = generateChromaticScale(cBaseFreq, 12)
      let newBase = cChromScale->Array.get(currentKey)->Option.getWithDefault(cBaseFreq)

      let newChromScale = generateChromaticScale(newBase, 12)
      let rotationMask = rotationInt->intToBoolArray

      let seq =
        newChromScale->Array.keepWithIndex((_, i) =>
          rotationMask->Array.get(i)->Option.getWithDefault(false)
        )

      let seqWithOctave =
        seq->Array.get(0)->Option.mapWithDefault(seq, head => Array.concat(seq, [head *. 2.]))

      seqWithOctave->Array.forEachWithIndex((i, v) => {
        triggerAttackRelease(. v, "4n", i->Int.toFloat *. 0.5)
        Js.Global.setTimeout(() => {
          setPlaying(_ => Some(i))
        }, i * 500)->ignore
      })

      Js.Global.setTimeout(() => {
        setPlaying(_ => None)
      }, seqWithOctave->Array.length * 500)->ignore
    }
  }

  let playCurrentNotes = () => playNotes(rotation)
  let toggleNonModes = () => setShowNonModes(v => !v)
  let selectNoteCount = num => setSelectedNoteNum(_ => num)

  <div className={"flex  flex-col sm:grid grid-cols-main sm:flex-row h-screen w-screen max-w-3xl"}>
    <div
      className="flex-1 flex flex-col w-screen sm:w-auto sm:max-w-[350px] p-2  overflow-y-scroll items-center">
      <div className="flex flex-row justify-between items-center w-full pl-3 pr-1">
        <PageTitle />
        {rotation->Option.isNone
          ? React.null
          : <button
              className={"flex flex-row gap-2 py-1 px-5 rounded-full items-center
               justify-center font-bold text-white bg-[var(--highlight)]"}
              onClick={_ => playCurrentNotes()}>
              <PlayIcon size={14} />
              {"Play"->React.string}
            </button>}
      </div>
      <div className=" sm:max-h-min  max-w-[500px] w-full">
        <div className={"pt-2 w-full self-center text-[var(--dim)]"}>
          <SVG
            playing={playing}
            rotationOffset={rotationOffset}
            stepLabels={stepLabels}
            labels={pitchLabels}
            selected={selectedNotes}
            currentKey={currentKey}
            onKeyChange={newKey => setCurrentKey(_ => newKey)}
          />
        </div>
        {scaleNames == ""
          ? React.null
          : <div
              className="w-full tracking-tight text-center font-black  text-[var(--species-text)]">
              {`Scale: ${scaleNames}`->React.string}
            </div>}
        {modeNames == ""
          ? React.null
          : <div
              className="w-full tracking-tight text-center font-black text-[var(--species-text)]">
              {`Mode: ${modeNames}`->React.string}
            </div>}
        <StepDisplay setCurrentStepDisplay currentStepDisplay />
        <Card title={"Number of notes"}>
          <div className="grid grid-cols-6 overflow-x-scroll gap-2">
            {noteCounts->reactMap(num => {
              <StepButton selected={selectedNoteNum == num} onClick={_ => selectNoteCount(num)}>
                {num->Int.toString->React.string}
              </StepButton>
            })}
          </div>
        </Card>
        <div className="my-2 flex flex-row justify-between items-center">
          <About />
          <div className="flex flex-row gap-2">
            <div className="text-sm"> {"Show Non-Modes"->React.string} </div>
            <Switch checked={showNonModes} onCheckedChange={toggleNonModes} />
          </div>
        </div>
      </div>
      <div className={"flex-1"} />
      <Attribution />
    </div>
    <div className="flex-1 sm:flex-1  h-full overflow-scroll xs:px-2">
      <div className="sm:max-w-[500px] pt-2">
        <div className={"mb-1"}>
          <div className="flex flex-row items-center py-2 font-medium justify-center ">
            {`${selectedNoteNum->Int.toString} notes: ${species
              ->Array.length
              ->Int.toString} possible scales`->React.string}
          </div>
          <div className={[""]->join}>
            {species
            ->Array.reverse
            ->reactMap(((speciesId, modes)) =>
              <Species
                playing
                showNonModes={showNonModes}
                key={speciesId->Int.toString}
                rotation={rotation}
                setRotation={setRotation}
                currentKey={currentKey}
                currentStepDisplay={currentStepDisplay}
                speciesId={speciesId}
                modes={modes}
                speciesHidden={isSpeciesHidden(speciesId)}
                setSpeciesHidden={hidden => updateSpeciesHidden(speciesId, hidden)}
              />
            )}
          </div>
        </div>
      </div>
    </div>
  </div>
}

let default = make
