open Belt

let any = (a, test) =>
  a->Array.reduce(false, (acc, element) => {
    acc ? true : test(element)
  })

type triSwitch = One | Two | Three

module CollapsedTri = {
  @react.component
  let make = (~render) => {
    let (state, set) = React.useState(() => One)

    render(state, set)
  }
}

module Config = {
  let bits = 12
}

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

let getPermutationsGivenBitLength = numOfBits =>
  Array.range(0, (2. ** numOfBits->Int.toFloat -. 1.)->Float.toInt)->Array.map(x =>
    x->Js.Int.toStringWithRadix(~radix=2)->padLeft(numOfBits, "0")
  )

// Counts "1"s
let getBinaryHammingWeight = bitArray =>
  bitArray->Array.reduce(0, (acc, value) => {
    value == "1" ? acc + 1 : acc
  })

let groupByGenus = x =>
  x->Array.reduce(Map.Int.empty, (acc, value) => {
    let genus = value->getBinaryHammingWeight
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

// let result =
//   Config.bits
//   ->getPermutationsGivenBitLength
//   ->Array.map(BitOps.stringToStringArray)
//   ->groupByGenus
//   ->groupBySpecies

// let resultExport =
//   result
//   ->Map.Int.toArray
//   ->Array.map(((k, v)) => {
//     (k, v->Map.String.toArray)
//   })

type importData = array<(int, array<(string, speciesDetails)>)>

@module("./data.js") external data: importData = "default"

let result =
  data
  ->Array.map(((k, v)) => {
    (k, v->Map.String.fromArray)
  })
  ->Map.Int.fromArray
