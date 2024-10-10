import { Synth, now, Sampler } from "tone";

const sampler = new Sampler({
  urls: {
    A0: "A0.mp3",
    A1: "A1.mp3",
    A2: "A2.mp3",
    A3: "A3.mp3",
    A4: "A4.mp3",
    A5: "A5.mp3",
  },
  baseUrl: "https://tonejs.github.io/audio/salamander/",
}).toDestination();

let triggerAttackRelease = (note, duration, when) => {
  const _now = now();
  sampler.triggerAttackRelease(note, duration, _now + when);
};

export default triggerAttackRelease;
