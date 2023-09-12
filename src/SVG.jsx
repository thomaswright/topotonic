import React from "react";
import tailwindColors from "tailwindcss/colors";

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

const RadialText = ({ x, y, radius, deg, text, selected }) => {
  let [dominantBaseline, textAnchor] = getTextAnchors12(deg);
  return (
    <g transform={`translate(${x} ${y}) `}>
      <g transform={`rotate(${deg - 90}) translate(${radius} ${0}) `}>
        <g transform={`rotate(${-(deg - 90)})  `}>
          <text
            dominantBaseline={dominantBaseline}
            textAnchor={textAnchor}
            fontSize={5}
            fill={
              selected
                ? tailwindColors[accentColor][600]
                : tailwindColors[plainColor][800]
            }
            className={"font-bold"}
          >
            {text}
          </text>
        </g>
      </g>
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
}) => {
  return (
    <g transform={`translate(${x} ${y}) rotate(${deg - 90})`}>
      <line
        x1={start}
        x2={end}
        y1={0}
        y2={0}
        stroke={color}
        strokeWidth={strokeWidth}
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

export const SVG = ({ data }) => {
  // console.log({ data });
  let order = data.length;
  let boxSize = 100;
  let orderDegree = 360 / order;

  let center = {
    x: boxSize / 2,
    y: boxSize / 2,
  };

  let radius = boxSize / 3.5;

  return (
    <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <circle
        cx={center.x}
        cy={center.y}
        strokeWidth={1}
        r={radius}
        fill="none"
        stroke={tailwindColors[plainColor][800]}
      />
      {data.map(([label, bit], i) => {
        const selected = bit === 1;
        return (
          <g key={i}>
            <RadialLine
              x={center.x}
              y={center.y}
              start={radius * 0.9}
              end={radius * 1.1}
              deg={i * orderDegree}
              strokeWidth={1}
              color={tailwindColors[plainColor][800]}
            />
            <RadialText
              selected={selected}
              x={center.x}
              y={center.y}
              radius={radius * 1.2}
              deg={i * orderDegree}
              text={label}
            />
            {selected ? (
              <RadialLine
                x={center.x}
                y={center.y}
                start={0}
                end={radius * 1.1}
                deg={i * orderDegree}
                strokeWidth={1}
                color={tailwindColors[accentColor][600]}
              />
            ) : null}
          </g>
        );
      })}
    </svg>
  );
};
