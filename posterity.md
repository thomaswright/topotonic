# Save for posterity

```res
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
```

```res
let makeKey = ((k, s)) =>
  <Key
    selected={currentKey->Option.mapWithDefault(false, x => x == k)}
    onClick={_ => setCurrentKey(_ => Some(k))}>
    {s->str}
  </Key>
```
