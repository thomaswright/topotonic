import React from "react";

const RadialText = ({
  x,
  y,
  radius,
  deg,
  text,
  selected,
  currentKey,
  onClick,
  fill,
}) => {
  let angle = deg - 90 - currentKey * 30;
  return (
    <g
      onClick={onClick}
      className=" cursor-pointer"
      style={{
        transition: "transform 1s ease-in-out",
        transform: `
          translate(${x}px, ${y}px)
          rotate(${angle}deg)
          translate(${radius + 2}px, ${0}px)
          rotate(${-angle}deg)
          `,
      }}
    >
      <text
        dominantBaseline={"middle"}
        textAnchor={"middle"}
        fontSize={5}
        fill={fill}
        className={selected ? "font-black" : "font-medium"}
      >
        {text}
      </text>
    </g>
  );
};

const RadialLine = ({
  x,
  y,
  start,
  end,
  deg,
  color = "black",
  strokeWidth = 1,
  radius = 0,
}) => {
  return (
    <g transform={`translate(${x} ${y}) rotate(${deg - 90})`}>
      <rect
        rx={radius}
        ry={radius}
        x={start}
        y={-strokeWidth / 2}
        width={end - start}
        height={strokeWidth}
        fill={color}
        // strokeWidth={strokeWidth}
      />
    </g>
  );
};

function cycleArray(arr, m) {
  const n = arr.length;
  const shift = ((m % n) + n) % n;
  return arr.slice(-shift).concat(arr.slice(0, -shift));
}

export const SVG = ({
  playing,
  labels,
  stepLabels,
  selected,
  currentKey = 0,
  onKeyChange,
  rotationOffset,
}) => {
  let order = labels.length;
  let boxSize = 100;
  let orderDegree = 360 / order;
  let translate = 10;

  let center = {
    x: boxSize / 2,
    y: boxSize / 2 - translate,
  };

  let radius = boxSize / 4.5;
  let cycledData = cycleArray(labels, currentKey);
  let numNotes = selected.slice(0).filter((x) => x).length;
  let shift = selected.slice(0, rotationOffset).filter((x) => x).length;

  return (
    <svg viewBox="0 0 100 80" xmlns="http://www.w3.org/2000/svg">
      <circle
        cx={center.x}
        cy={center.y}
        strokeWidth={0.5}
        r={radius}
        fill="none"
        stroke={"currentColor"}
      />

      <g
        style={{
          transition: "transform 1s ease-in-out",
          transform: `
          translate(${center.x}px, ${center.y}px)
          rotate(-${rotationOffset * 30}deg)
          translate(-${center.x}px, -${center.y}px)

          `,
        }}
      >
        {selected.map((s, i) => {
          return (
            <React.Fragment key={i + "lines"}>
              <RadialLine
                x={center.x}
                y={center.y}
                start={radius - 1}
                end={radius + 1}
                deg={i * orderDegree}
                strokeWidth={2}
                radius={1}
                color={"currentColor"}
              />
              {s ? (
                <RadialLine
                  x={center.x}
                  y={center.y}
                  start={-1}
                  end={radius * 1.1}
                  deg={i * orderDegree}
                  strokeWidth={2}
                  radius={1}
                  color={"var(--accent)"}
                />
              ) : null}
            </React.Fragment>
          );
        })}
        {selected.map((s, i) => {
          let numInSeq = selected.slice(0, i).filter((x) => x).length;

          let isPlaying = (playing + shift) % numNotes == numInSeq;
          return s && isPlaying ? (
            <RadialLine
              key={i + "playing"}
              x={center.x}
              y={center.y}
              start={-1}
              end={radius * 1.1}
              deg={i * orderDegree}
              strokeWidth={2}
              radius={1}
              color={"var(--red)"}
            />
          ) : null;
        })}
      </g>

      {cycledData.map((label, i) => {
        let newIndex = (i + rotationOffset + (12 - currentKey)) % order;
        let numInSeq = selected.slice(0, newIndex).filter((x) => x).length;
        let isPlaying = (playing + shift) % numNotes == numInSeq;
        let s = selected[newIndex];

        return (
          <React.Fragment key={label + "notes"}>
            <RadialText
              currentKey={currentKey}
              selected={s}
              fill={
                s
                  ? isPlaying
                    ? "var(--red)"
                    : "var(--accent)"
                  : "currentColor"
              }
              x={center.x}
              y={center.y}
              radius={radius * 1.2}
              deg={i * orderDegree}
              text={label}
              onClick={(_) => onKeyChange(i)}
            />
          </React.Fragment>
        );
      })}

      {stepLabels &&
        stepLabels.map((label, i) => {
          let newIndex = (i + rotationOffset) % order;
          let numInSeq = selected.slice(0, newIndex).filter((x) => x).length;
          let isPlaying = (playing + shift) % numNotes == numInSeq;
          let s = selected[newIndex];

          return (
            <React.Fragment key={label + "notes"}>
              <RadialText
                currentKey={0}
                selected={s}
                fill={
                  s
                    ? isPlaying
                      ? "var(--red)"
                      : "var(--accent)"
                    : "currentColor"
                }
                x={center.x}
                y={center.y}
                radius={radius * 1.55}
                deg={i * orderDegree}
                text={label}
                onClick={(_) => {}}
              />
            </React.Fragment>
          );
        })}
    </svg>
  );
};
