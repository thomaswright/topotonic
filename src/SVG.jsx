import React from "react";

const RadialText = ({ x, y, radius, deg, text }) => {
  return (
    <g transform={`translate(${x} ${y}) `}>
      <g transform={`rotate(${deg - 90}) translate(${radius} ${0}) `}>
        <g transform={`rotate(${-(deg - 90)})  `}>
          <text dominantBaseline="middle" textAnchor="middle" fontSize={5}>
            {text}
          </text>
        </g>
      </g>
    </g>
  );
};

const RadialLine = ({ x, y, start, end, deg, color = "black" }) => {
  return (
    <g transform={`translate(${x} ${y}) rotate(${deg - 90})`}>
      <line x1={start} x2={end} y1={0} y2={0} stroke={color} />
    </g>
  );
};

const range = (start, end) => {
  const recurse = (array, s, e) => {
    return s <= e ? recurse([...array, s], s + 1, e) : array;
  };
  return recurse([], start, end);
};

export const SVG = ({ bits }) => {
  let order = 12;
  let boxSize = 100;
  let orderDegree = 360 / 12;

  let center = {
    x: boxSize / 2,
    y: boxSize / 2,
  };
  let radius = boxSize / 4;

  return (
    <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <circle
        cx={center.x}
        cy={center.y}
        r={radius}
        fill="none"
        stroke="black"
      />
      {range(0, order - 1).map((i) => {
        return (
          <g>
            <RadialLine
              x={center.x}
              y={center.y}
              start={radius * 0.9}
              end={radius * 1.1}
              deg={i * orderDegree}
            />
            <RadialText
              x={center.x}
              y={center.y}
              radius={radius * 1.3}
              deg={i * orderDegree}
              text={i}
            />
          </g>
        );
      })}
      {bits.map((x, i) => {
        return x === 1 ? (
          <RadialLine
            x={center.x}
            y={center.y}
            start={0}
            end={radius}
            deg={i * orderDegree}
            color={"red"}
          />
        ) : null;
      })}
    </svg>
  );
};
