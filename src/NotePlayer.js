const onRamp = 0.05;
const offRamp = 0.1;
const maxGain = 0.5;
const nearZeroGain = 0.0001;

class NotePlayer {
  constructor() {
    this.audioContext = new window.AudioContext();

    this.gainNode = this.audioContext.createGain();
    this.gainNode.connect(this.audioContext.destination);
    this.gainNode.gain.value = nearZeroGain;
  }

  playNote(frequency, duration) {
    const oscillator = this.audioContext.createOscillator();

    oscillator.frequency.setValueAtTime(
      frequency,
      this.audioContext.currentTime
    );
    oscillator.connect(this.gainNode);

    oscillator.start();
    oscillator.stop(this.audioContext.currentTime + duration / 1000);

    this.gainNode.gain.setValueAtTime(
      nearZeroGain,
      this.audioContext.currentTime
    );

    this.gainNode.gain.linearRampToValueAtTime(
      maxGain,
      this.audioContext.currentTime + onRamp
    );

    this.gainNode.gain.setValueAtTime(
      maxGain,
      this.audioContext.currentTime + onRamp + 0.001
    );

    this.gainNode.gain.linearRampToValueAtTime(
      nearZeroGain,
      this.audioContext.currentTime + duration / 1000
    );
  }
  setVolume(volume) {
    this.gainNode.gain.value = volume;
  }

  playNotesSequentially(noteArray, delay) {
    if (!this.isPlaying) {
      this.isPlaying = true;
      const self = this;

      function playNextNote(index) {
        if (index < noteArray.length) {
          const [frequency, duration] = noteArray[index];
          self.playNote(frequency, duration);
          setTimeout(() => {
            playNextNote(index + 1);
          }, duration + delay);
        } else {
          self.isPlaying = false;
        }
      }

      playNextNote(0);
    }
  }
}

export default NotePlayer;
