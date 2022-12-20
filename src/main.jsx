import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App.bs";
import "./index.css";

let drawRadius = ({ context, x, y, start, end, deg }) => {
  context.save();

  context.translate(x, y);
  context.rotate((deg * Math.PI) / 180);
  context.beginPath();
  context.moveTo(start, 0);
  context.lineTo(end, 0);
  context.strokeStyle = "red";
  context.stroke();

  context.restore();
};

let drawRadiusText = ({ context, x, y, radius, deg, text }) => {
  context.save();

  context.translate(x, y);
  context.rotate((deg * Math.PI) / 180);
  context.font = "12px";
  context.translate(radius, 0);
  context.rotate(-(deg * Math.PI) / 180);
  context.fillText(text, 0, 0);

  context.restore();
};

const Canvas = (props) => {
  const canvasRef = React.useRef(null);

  React.useEffect(() => {
    const canvas = canvasRef.current;
    const { width, height } = canvas.getBoundingClientRect();
    let ratio = window.devicePixelRatio;

    let size = Math.min(width, height);

    let radius = size * 0.3;
    let center = {
      x: size * 0.5,
      y: size * 0.5,
    };

    const context = canvas.getContext("2d");
    canvas.width = width * ratio;
    canvas.height = height * ratio;
    context.scale(ratio, ratio);

    context.beginPath();
    context.arc(center.x, center.y, radius, 0, Math.PI * 2, true); // Outer circle
    context.stroke();

    drawRadius({
      context,
      x: center.x,
      y: center.y,
      deg: 40,
      start: radius * 0.95,
      end: radius * 1.05,
    });

    drawRadiusText({
      context,
      x: center.x,
      y: center.y,
      deg: 40,
      radius: radius * 1.1,
      text: "Hello",
    });
  }, []);

  return <canvas width="100" height="100" ref={canvasRef} {...props} />;
};

const root = ReactDOM.createRoot(document.getElementById("root"));

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

const SVG = () => {
  let order = 12;
  let boxSize = 100;
  let orderDegree = 360 / 12;

  let center = {
    x: boxSize / 2,
    y: boxSize / 2,
  };
  let radius = boxSize / 4;

  let mock = [1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0];

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
      {mock.map((x, i) => {
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

root.render(
  <div>
    <div className=" h-80 w-80">
      {/* <Canvas /> */}
      <SVG />
    </div>
    <App />
  </div>
);
