import React from "react";
import tailwindColors from "tailwindcss/colors";
import { useAutoAnimate } from "@formkit/auto-animate/react";
const accentColor = "red";
const plainColor = "slate";

function getTextAnchors8(deg) {
  // returns [dominantBaseline, textAnchor]
  // positioned with deg = 0 at the top
  // going clockwise

  if (deg > 337 || deg <= 22) {
    return ["text-bottom", "middle"];
  } else if (deg > 22 && deg <= 67) {
    return ["text-bottom", "start"];
  } else if (deg > 67 && deg <= 112) {
    return ["middle", "start"];
  } else if (deg > 112 && deg <= 157) {
    return ["hanging", "start"];
  } else if (deg > 157 && deg <= 202) {
    return ["hanging", "middle"];
  } else if (deg > 202 && deg <= 247) {
    return ["hanging", "end"];
  } else if (deg > 247 && deg <= 292) {
    return ["middle", "end"];
  } else if (deg > 292 && deg <= 337) {
    return ["text-bottom", "end"];
  } else {
    return ["middle", "middle"];
  }
}

function getTextAnchors12(deg) {
  // returns [dominantBaseline, textAnchor]
  // positioned with deg = 0 at the top
  // going clockwise

  if (deg > 345 || deg <= 15) {
    return ["text-bottom", "middle"];
  } else if (deg > 15 && deg <= 45) {
    return ["text-bottom", "start"];
  } else if (deg > 45 && deg <= 75) {
    return ["middle", "start"];
  } else if (deg > 75 && deg <= 105) {
    return ["middle", "start"];
  } else if (deg > 105 && deg <= 135) {
    return ["middle", "start"];
  } else if (deg > 135 && deg <= 165) {
    return ["hanging", "start"];
  } else if (deg > 165 && deg <= 195) {
    return ["hanging", "middle"];
  } else if (deg > 195 && deg <= 225) {
    return ["hanging", "end"];
  } else if (deg > 225 && deg <= 255) {
    return ["middle", "end"];
  } else if (deg > 255 && deg <= 285) {
    return ["middle", "end"];
  } else if (deg > 285 && deg <= 315) {
    return ["middle", "end"];
  } else if (deg > 315 && deg <= 345) {
    return ["text-bottom", "end"];
  } else {
    return ["middle", "middle"];
  }
}

const RadialText = ({
  x,
  y,
  radius,
  deg,
  text,
  selected,
  currentKey,
  onClick,
}) => {
  // let [dominantBaseline, textAnchor] = getTextAnchors12(deg - currentKey * 30);
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
        fill={selected ? "var(--accent)" : "currentColor"}
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

const range = (start, end) => {
  const recurse = (array, s, e) => {
    return s <= e ? recurse([...array, s], s + 1, e) : array;
  };
  return recurse([], start, end);
};

function cycleArray(arr, m) {
  const n = arr.length;
  const shift = ((m % n) + n) % n;
  return arr.slice(-shift).concat(arr.slice(0, -shift));
}

export const SVG = ({
  playing,
  labels,
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

  let radius = boxSize / 3.5;
  let cycledData = cycleArray(labels, currentKey);
  let numNotes = selected.slice(0).filter((x) => x).length;
  let shift = selected.slice(0, rotationOffset).filter((x) => x).length;

  return (
    <svg viewBox="0 0 100 80" xmlns="http://www.w3.org/2000/svg">
      <circle
        cx={center.x}
        cy={center.y}
        strokeWidth={0.5}
        strokeOpacity={0.2}
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
          let numInSeq = selected.slice(0, i).filter((x) => x).length;

          let isPlaying = (playing + shift) % numNotes == numInSeq;
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
                  start={0}
                  end={radius * 1.1}
                  deg={i * orderDegree}
                  strokeWidth={2}
                  radius={1}
                  color={isPlaying ? "var(--red)" : "var(--accent)"}
                />
              ) : null}
            </React.Fragment>
          );
        })}
      </g>

      {cycledData.map((label, i) => {
        return (
          <React.Fragment key={label + "notes"}>
            <RadialText
              currentKey={currentKey}
              selected={
                selected[(i + rotationOffset + (12 - currentKey)) % order]
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

      {/* <circle
        cx={center.x}
        cy={center.y}
        strokeWidth={0.5}
        r={radius * 0.1}
        stroke="none"
        fill={"var(--accent)"}
      /> */}
    </svg>
  );
};
