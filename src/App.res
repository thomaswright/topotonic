open Belt

let join = Js.Array2.joinWith(_, " ")

module Collapsed = {
  @react.component
  let make = (~render) => {
    let (state, set) = React.useState(() => true)

    render(state, set)
  }
}

module SVG = {
  @module("./SVG.jsx") @react.component
  external make: (~bits: array<int>) => React.element = "SVG"
}

module Config = {
  let bits = 12
}

let reactMap = (a, f) => a->Array.map(f)->React.array
let str = React.string

let rec padLeft = (s, l, pad) => {
  s->Js.String2.length < l ? padLeft(pad ++ s, l, pad) : s
}

let stringToArray = x => x->Js.String2.castToArrayLike->Js.Array2.from

let arrayToString = x => x->Array.reduce("", (acc, value) => acc ++ value)

let stringArrayToIntArray = x => x->Array.map(x => x->Int.fromString->Option.getWithDefault(0))

let stringToIntArray = x => x->stringToArray->stringArrayToIntArray

let getBitStrings = numOfBits =>
  Array.range(0, (2. ** numOfBits->Int.toFloat -. 1.)->Float.toInt)->Array.map(x =>
    x->Js.Int.toStringWithRadix(~radix=2)->padLeft(numOfBits, "0")
  )

let count1s = bitArray =>
  bitArray->Array.reduce(0, (acc, value) => {
    value == "1" ? acc + 1 : acc
  })

let groupByCount = bitArrays =>
  bitArrays->Array.reduce(Map.Int.empty, (acc, value) => {
    let count = value->count1s
    acc->Map.Int.update(count, x =>
      x->Option.mapWithDefault([value]->Some, a => Array.concat(a, [value])->Some)
    )
  })

let rec cycleArray = (x, shift) => {
  shift > 0
    ? Array.concat(x->Js.Array2.sliceFrom(1), [x->Array.getExn(0)])->cycleArray(shift - 1)
    : x
}

type bitArray = array<string>

let bitArrayToDec = x =>
  x
  ->Array.reverse
  ->Array.reduceWithIndex(0, (acc, value, i) => {
    value
    ->Int.fromString
    ->Option.mapWithDefault(acc, valueInt => {
      (valueInt->Int.toFloat *. 2. ** i->Int.toFloat)->Int.fromFloat + acc
    })
  })

let getPermutations = x => {
  let unordered = Array.range(0, x->Array.length - 1)->Array.map(i => {
    x->cycleArray(i)
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

let generateGreatest = x => {
  let permutations = getPermutations(x)

  permutations->Array.reduce(permutations->Array.getExn(0), (acc, value) => {
    let valueDecRep = value->bitArrayToDec
    let accDecRep = acc->bitArrayToDec
    valueDecRep > accDecRep ? value : acc
  })
}

let removeZeroStarts = permutations => {
  permutations->Array.keep(x => x->Array.getExn(0) == "1")
}

let removeDuplicates = permutations => {
  permutations
  ->Array.map(x => (x->arrayToString, ""))
  ->Map.String.fromArray
  ->Map.String.keysToArray
  ->Array.map(x => x->stringToArray)
}

let groupBySpecies = groupedByCount =>
  groupedByCount->Map.Int.map(x => {
    x
    ->Array.reduce(Map.String.empty, (acc, value) => {
      let key = value->generateGreatest->arrayToString
      acc->Map.String.update(
        key,
        x => x->Option.mapWithDefault([value]->Some, a => Array.concat(a, [value])->Some),
      )
    })
    ->Map.String.keysToArray
    ->Array.map(a => (
      a,
      a->stringToArray->getPermutations->removeZeroStarts->removeDuplicates->Array.reverse,
    ))
    ->Map.String.fromArray
  })

let result = Config.bits->getBitStrings->Array.map(stringToArray)->groupByCount->groupBySpecies

@react.component
let make = () => {
  let (currentBits, setCurrentBits) = React.useState(_ => [])
  <div className={"flex flex-row h-screen w-screen"}>
    <div className={"h-80 w-80"}>
      <SVG bits={currentBits} />
    </div>
    <div className="font-mono h-full overflow-scroll px-4">
      {result
      ->Map.Int.toArray
      ->reactMap(((k, v)) =>
        <Collapsed
          render={(numCollapsedState, setNumCollapsedState) => {
            <div className={"mb-1"}>
              <div onClick={_ => setNumCollapsedState(x => !x)} className="flex flex-row w-20 ">
                <div className="flex-1 text-red-500"> {k->Int.toString->str} </div>
                <div className="flex-1 text-blue-500">
                  {v->Map.String.toArray->Array.length->Int.toString->str}
                </div>
              </div>
              <div
                className={[
                  numCollapsedState ? "hidden" : "",
                  "max-h-52 overflow-scroll pr-4",
                ]->join}>
                {v
                ->Map.String.toArray
                ->Array.reverse
                ->reactMap(((k2, v2)) =>
                  <Collapsed
                    render={(speciesCollapsedState, setSpeciesCollapsedState) => {
                      <div className="">
                        <div className="flex flex-row justify-start gap-3">
                          <div
                            onClick={_ => {
                              setSpeciesCollapsedState(x => !x)
                              setCurrentBits(_ => k2->stringToIntArray)
                            }}
                            className="font-bold">
                            {k2->str}
                          </div>
                          <div className=" text-green-500">
                            {v2->Array.length->Int.toString->str}
                          </div>
                        </div>
                        <div className={[speciesCollapsedState ? "hidden " : "", "mb-2"]->join}>
                          {v2->reactMap(
                            x => {
                              <div onClick={_ => setCurrentBits(_ => x->stringArrayToIntArray)}>
                                {x->arrayToString->str}
                              </div>
                            },
                          )}
                        </div>
                      </div>
                    }}
                  />
                )}
              </div>
            </div>
          }}
        />
      )}
      // {bitStrings->reactMap(x =>
      //   <div>
      //     {x->str}
      //     // {count1s(stringToArray(x))->Int.toString->str}
      //   </div>
      // )}
      // {"Hello"->str}
    </div>
  </div>
}

let default = make
