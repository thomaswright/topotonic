Js.log("Hello")

open Belt

module Config = {
  let bits = 12
}

let reactMap = (a, f) => a->Array.map(f)->React.array
let str = React.string

let rec padLeft = (s, l, pad) => {
  s->Js.String2.length < l ? padLeft(pad ++ s, l, pad) : s
}

let bitStrings =
  Array.range(0, (2. ** Config.bits->Int.toFloat -. 1.)->Float.toInt)->Array.map(x =>
    x->Js.Int.toStringWithRadix(~radix=2)->padLeft(Config.bits, "0")
  )

let stringToArray = x => x->Js.String2.castToArrayLike->Js.Array2.from

let arrayToString = x => x->Array.reduce("", (acc, value) => acc ++ value)

let bitArrays = bitStrings->Array.map(stringToArray)

let count1s = bitArray =>
  bitArray->Array.reduce(0, (acc, value) => {
    value == "1" ? acc + 1 : acc
  })

let groupedByCount = bitArrays->Array.reduce(Map.Int.empty, (acc, value) => {
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

let generatePermutations = x => {
  let unordered = Array.range(0, x->Array.length - 1)->Array.map(i => {
    x->cycleArray(i)
  })

  let orderedShiftingRight = Array.concat(
    [unordered->Array.getExn(0)],
    unordered->Js.Array2.sliceFrom(1)->Array.reverse,
  )

  orderedShiftingRight
}

let generateGreatest = x => {
  let permutations = generatePermutations(x)

  permutations->Array.reduce(permutations->Array.getExn(0), (acc, value) => {
    let valueDecRep = value->bitArrayToDec
    let accDecRep = acc->bitArrayToDec
    valueDecRep > accDecRep ? value : acc
  })
}

let groupedBySpecies = groupedByCount->Map.Int.map(x => {
  x->Array.reduce(Map.String.empty, (acc, value) => {
    let key = value->generateGreatest->arrayToString
    acc->Map.String.update(
      key,
      x => x->Option.mapWithDefault([value]->Some, a => Array.concat(a, [value])->Some),
    )
  })
})

module Collapsed = {
  @react.component
  let make = (~render) => {
    let (state, set) = React.useState(() => true)

    render(state, set)
  }
}

@react.component
let make = () => {
  <div className="font-mono">
    {groupedBySpecies
    ->Map.Int.toArray
    ->reactMap(((k, v)) =>
      <Collapsed
        render={(numCollapsedState, setNumCollapsedState) => {
          <div>
            <div onClick={_ => setNumCollapsedState(x => !x)} className="flex flex-row w-20 ">
              <div className="flex-1 text-red-500"> {k->Int.toString->str} </div>
              <div className="flex-1 text-blue-500">
                {v->Map.String.toArray->Array.length->Int.toString->str}
              </div>
            </div>
            <div className={numCollapsedState ? "hidden" : ""}>
              {v
              ->Map.String.toArray
              ->Array.reverse
              ->reactMap(((k2, _)) =>
                <Collapsed
                  render={(speciesCollapsedState, setSpeciesCollapsedState) => {
                    <div>
                      <div onClick={_ => setSpeciesCollapsedState(x => !x)} className="font-bold">
                        {k2->str}
                      </div>
                      <div className={speciesCollapsedState ? "hidden" : ""}>
                        {k2
                        ->stringToArray
                        ->generatePermutations
                        ->reactMap(
                          x => {
                            <div> {x->arrayToString->str} </div>
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
    {"Hello"->str}
  </div>
}

let default = make
