import React, { useMemo } from "react";

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
  const angle = deg - 90 - currentKey * 30;
  return (
    <g
      onClick={onClick}
      className="cursor-pointer"
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
  if (n === 0) {
    return arr.slice();
  }
  const shift = ((m % n) + n) % n;
  return arr.slice(-shift).concat(arr.slice(0, -shift));
}

const normalizeIndex = (index, length) => {
  if (length === 0) {
    return 0;
  }
  const mod = index % length;
  return mod < 0 ? mod + length : mod;
};

const buildSelectedPrefix = (values) => {
  const prefix = new Array(values.length + 1);
  prefix[0] = 0;
  for (let i = 0; i < values.length; i += 1) {
    prefix[i + 1] = prefix[i] + (values[i] ? 1 : 0);
  }
  return prefix;
};

const countSelectedBefore = (prefix, index) => {
  const length = prefix.length - 1;
  if (length === 0) {
    return 0;
  }
  if (index < 0) {
    return prefix[Math.max(length + index, 0)];
  }
  return prefix[Math.min(index, length)];
};

export const SVG = ({
  playing,
  labels,
  stepLabels,
  selected,
  currentKey = 0,
  onKeyChange,
  rotationOffset,
}) => {
  const labelCount = labels.length;
  const boxSize = 100;
  const orderDegree = labelCount === 0 ? 0 : 360 / labelCount;
  const translate = 10;
  const center = {
    x: boxSize / 2,
    y: boxSize / 2 - translate,
  };

  const radius = boxSize / 4.5;
  const cycledLabels = useMemo(
    () => cycleArray(labels, currentKey),
    [labels, currentKey],
  );
  const selectedPrefix = useMemo(
    () => buildSelectedPrefix(selected),
    [selected],
  );
  const numNotes = selectedPrefix[selectedPrefix.length - 1] || 0;
  const shift = countSelectedBefore(selectedPrefix, rotationOffset);
  const playingIndex = numNotes > 0 ? (playing + shift) % numNotes : -1;
  const currentKeyOffset = normalizeIndex(labelCount - currentKey, labelCount);
  const lineMeta = useMemo(
    () =>
      selected.map((isSelected, index) => {
        const deg = index * orderDegree;
        const sequenceIndex = countSelectedBefore(selectedPrefix, index);
        const isPlayingLine =
          numNotes > 0 && isSelected && playingIndex === sequenceIndex;
        return {
          index,
          deg,
          isSelected,
          isPlaying: isPlayingLine,
        };
      }),
    [selected, orderDegree, selectedPrefix, numNotes, playingIndex],
  );

  const baseLines = lineMeta.map(({ index, deg }) => (
    <RadialLine
      key={`line-base-${index}`}
      x={center.x}
      y={center.y}
      start={radius - 1}
      end={radius + 1}
      deg={deg}
      strokeWidth={2}
      radius={1}
      color={"currentColor"}
    />
  ));

  const selectedLines = lineMeta
    .filter(({ isSelected }) => isSelected)
    .map(({ index, deg }) => (
      <RadialLine
        key={`line-selected-${index}`}
        x={center.x}
        y={center.y}
        start={-1}
        end={radius * 1.1}
        deg={deg}
        strokeWidth={2}
        radius={1}
        color={"var(--highlight)"}
      />
    ));

  const playingLines = lineMeta
    .filter(({ isPlaying }) => isPlaying)
    .map(({ index, deg }) => (
      <RadialLine
        key={`line-playing-${index}`}
        x={center.x}
        y={center.y}
        start={-1}
        end={radius * 1.1}
        deg={deg}
        strokeWidth={2}
        radius={1}
        color={"var(--accent)"}
      />
    ));

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
          rotate(-${rotationOffset * orderDegree}deg)
          translate(-${center.x}px, -${center.y}px)

          `,
        }}
      >
        {baseLines}
        {selectedLines}
        {playingLines}
      </g>

      {cycledLabels.map((label, i) => {
        const newIndex = normalizeIndex(
          i + rotationOffset + currentKeyOffset,
          labelCount,
        );
        const numInSeq = countSelectedBefore(selectedPrefix, newIndex);
        const isPlaying = numNotes > 0 && playingIndex === numInSeq;
        const isSelected = selected[newIndex];

        return (
          <React.Fragment key={`${label}-note-${i}`}>
            <RadialText
              currentKey={currentKey}
              selected={isSelected}
              fill={
                isSelected
                  ? isPlaying
                    ? "var(--accent)"
                    : "var(--highlight)"
                  : "currentColor"
              }
              x={center.x}
              y={center.y}
              radius={radius * 1.2}
              deg={i * orderDegree}
              text={label}
              onClick={() => onKeyChange(i)}
            />
          </React.Fragment>
        );
      })}

      {stepLabels &&
        stepLabels.map((label, i) => {
          const newIndex = normalizeIndex(i + rotationOffset, labelCount);
          const numInSeq = countSelectedBefore(selectedPrefix, newIndex);
          const isPlaying = numNotes > 0 && playingIndex === numInSeq;
          const isSelected = selected[newIndex];

          return (
            <React.Fragment key={`${label}-step-${i}`}>
              <RadialText
                currentKey={0}
                selected={isSelected}
                fill={
                  isSelected
                    ? isPlaying
                      ? "var(--accent)"
                      : "var(--highlight)"
                    : "currentColor"
                }
                x={center.x}
                y={center.y}
                radius={radius * 1.55}
                deg={i * orderDegree}
                text={label}
                onClick={() => {}}
              />
            </React.Fragment>
          );
        })}
    </svg>
  );
};
