import { Synth, now } from "tone";

const synth = new Synth().toDestination();

//play a middle 'C' for the duration of an 8th note

let triggerAttackRelease = (note, duration, when) => {
  const _now = now();
  synth.triggerAttackRelease(note, duration, _now + when);
};

export default triggerAttackRelease;
