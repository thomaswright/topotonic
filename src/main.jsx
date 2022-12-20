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

root.render(
  <div>
    <div className="p-4">
      <Canvas />
    </div>
    <App />
  </div>
);
