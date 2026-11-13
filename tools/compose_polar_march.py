import argparse
import array
import functools
import math
from pathlib import Path
import random
import sys
import wave


RATE = 32000
BPM = 80
BEAT = 60.0 / BPM
BARS = 16
FRAMES = round(BARS * 4 * BEAT * RATE)
TAU = math.tau


@functools.lru_cache(maxsize=None)
def note(pitch, beats, voice):
    frequency = 440.0 * 2 ** ((pitch - 69) / 12)
    duration = beats * BEAT
    samples = array.array('f')
    for index in range(round(duration * RATE)):
        time = index / RATE
        phase = TAU * frequency * time
        attack = min(1.0, time / 0.012)
        release = min(1.0, (duration - time) / 0.06)
        if voice == 'bass':
            value = sum((-1) ** ((h - 1) // 2) * math.sin(phase * h) / h ** 2 for h in (1, 3, 5, 7))
            value *= 0.7 + 0.3 * math.exp(-time * 8)
        elif voice == 'brass':
            value = sum(math.sin(phase * h) / h for h in (1, 3, 5, 7) if frequency * h < RATE * 0.4) * 0.65
            value *= 0.55 + 0.45 * math.exp(-time * 5)
        elif voice == 'drone':
            value = sum(math.sin(phase * h) / h ** 1.8 for h in (1, 2, 3, 4))
            value *= 0.75 + 0.1 * math.sin(TAU * 0.25 * time)
            attack = min(1.0, time / 0.5)
            release = min(1.0, (duration - time) / 0.5)
        elif voice == 'ice':
            value = math.sin(phase) + 0.2 * math.sin(phase * 3)
            value *= math.exp(-time * 2.3)
            attack = min(1.0, time / 0.02)
        else:
            raise ValueError(voice)
        samples.append(round(value * 63.0) / 63.0 * attack * release)
    return samples


@functools.lru_cache(maxsize=None)
def percussion(kind):
    rng = random.Random(802 + sum(map(ord, kind)))
    duration = 0.24 if kind == 'kick' else 0.16
    samples = array.array('f')
    phase = 0.0
    noise = 0.0
    for index in range(round(duration * RATE)):
        time = index / RATE
        if index % 8 == 0:
            noise = rng.choice((-1.0, 1.0))
        if kind == 'kick':
            phase += TAU * (45 + 90 * math.exp(-time * 35)) / RATE
            value = math.sin(phase) * math.exp(-time * 18)
        elif kind == 'snare':
            value = (noise * 0.65 + math.sin(TAU * 165 * time) * 0.35) * math.exp(-time * 34)
        else:
            value = noise * math.exp(-time * 90)
        envelope = min(1.0, time / 0.002) * min(1.0, (duration - time) / 0.012)
        samples.append(value * envelope)
    return samples


class Arrangement:
    def __init__(self):
        self.left = array.array('f', [0.0]) * FRAMES
        self.right = array.array('f', [0.0]) * FRAMES

    def add(self, samples, beat, gain, pan=0.0):
        start = round(beat * BEAT * RATE)
        left_gain = gain * math.sqrt((1.0 - pan) * 0.5)
        right_gain = gain * math.sqrt((1.0 + pan) * 0.5)
        for offset, value in enumerate(samples):
            index = (start + offset) % FRAMES
            self.left[index] += value * left_gain
            self.right[index] += value * right_gain

    def play(self, pitch, beat, beats, voice, gain, pan=0.0, echo=False):
        samples = note(pitch, beats, voice)
        self.add(samples, beat, gain, pan)
        if echo:
            self.add(samples, beat + 1.0, gain * 0.16, -pan)
            self.add(samples, beat + 2.0, gain * 0.06, pan)

    def save(self, path):
        peak = max(max(map(abs, self.left)), max(map(abs, self.right)))
        scale = 0.8 / peak
        pcm = array.array('h')
        square_sum = 0.0
        for left, right in zip(self.left, self.right):
            for value in (left, right):
                value *= scale
                square_sum += value * value
                pcm.append(round(value * 32767))
        if sys.byteorder != 'little':
            pcm.byteswap()
        path.parent.mkdir(parents=True, exist_ok=True)
        with wave.open(str(path), 'wb') as output:
            output.setnchannels(2)
            output.setsampwidth(2)
            output.setframerate(RATE)
            output.writeframes(pcm.tobytes())
        rms = math.sqrt(square_sum / (FRAMES * 2))
        print(f'{path}: {FRAMES / RATE:.1f}s, {BPM} BPM, peak -1.94 dBFS, RMS {20 * math.log10(rms):.1f} dBFS')


MELODY = [
    [(0.0, 62, 0.7), (1.5, 57, 0.45), (2.5, 63, 0.8)],
    [(0.0, 62, 1.3), (2.0, 58, 0.65), (3.0, 57, 0.65)],
    [(0.5, 53, 1.0), (2.0, 60, 0.6), (3.0, 58, 0.45)],
    [(0.0, 57, 1.5), (2.5, 55, 0.35), (3.25, 51, 0.35)],
    [(0.0, 58, 1.1), (1.75, 65, 0.55), (3.0, 62, 0.65)],
    [(0.5, 63, 0.8), (2.0, 60, 1.2)],
    [(0.0, 62, 0.7), (1.5, 69, 0.45), (2.5, 65, 0.8)],
    [(0.0, 63, 1.3), (2.0, 57, 0.65), (3.0, 60, 0.4)],
]


def compose(output):
    song = Arrangement()
    roots = [38, 38, 39, 38, 34, 36, 38, 33]
    for bar in range(BARS):
        base = bar * 4
        root = roots[bar % 8]
        sparse = bar in (8, 9)
        for beat in (0, 2):
            song.add(percussion('kick'), base + beat, 0.65)
        for beat in (1, 3):
            song.add(percussion('snare'), base + beat, 0.22 if sparse else 0.33, 0.08)
        for beat in (0.5, 1.5, 2.5, 3.5):
            song.add(percussion('stick'), base + beat, 0.035, -0.2)
        if bar % 4 == 3:
            for beat, gain in [(2.75, 0.07), (3.5, 0.1), (3.75, 0.14)]:
                song.add(percussion('snare'), base + beat, gain, -0.12)
        for beat in (0, 2):
            song.play(root, base + beat, 1.55, 'bass', 0.32)
            song.play(root + 12, base + beat, 0.65, 'brass', 0.045, -0.1)
        song.play(root - 12, base, 3.95, 'drone', 0.12, -0.18)
        song.play(root + 7, base, 3.95, 'drone', 0.04, 0.18)
        if not sparse:
            for beat, pitch, length in MELODY[bar % 8]:
                song.play(pitch, base + beat, length, 'brass', 0.17, -0.05, True)
        if bar % 4 == 0:
            song.play(root + 36, base + 2.5, 2.5, 'ice', 0.035, 0.5, True)
        if bar >= 12:
            song.play(root + 15, base + 1.0, 2.6, 'drone', 0.03, 0.35)
    song.save(output)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, default=Path(__file__).resolve().parents[1] / 'assets/audio/music/previews/home_polar_march.wav')
    compose(parser.parse_args().output)
