import argparse
import array
import functools
import math
from pathlib import Path
import random
import sys
import wave


RATE = 32000
TAU = math.tau


@functools.lru_cache(maxsize=128)
def tone(pitch, seconds, voice):
    frequency = 440.0 * 2 ** ((pitch - 69) / 12)
    rng = random.Random(pitch * 71)
    output = array.array('f')
    breath = 0.0
    for index in range(round(seconds * RATE)):
        time = index / RATE
        phase = TAU * frequency * time
        attack = min(1.0, time / 0.16)
        release = min(1.0, (seconds - time) / 0.22)
        if voice == 'flute':
            vibrato = 0.014 * math.sin(TAU * 4.2 * time) * min(1.0, time / 0.5)
            breath += (rng.uniform(-1.0, 1.0) - breath) * 0.08
            value = math.sin(phase + vibrato) + 0.09 * math.sin(phase * 2) + 0.04 * math.sin(phase * 3)
            value = round(value * 63.0) / 63.0 * 0.8 + breath * 0.04
        elif voice == 'drone':
            value = math.sin(phase) * 0.85 + math.sin(phase * 2) * 0.1 + math.sin(phase * 3) * 0.05
            attack = min(1.0, time / 0.7)
            release = min(1.0, (seconds - time) / 0.8)
        elif voice == 'low_horn':
            value = math.sin(phase) + 0.13 * math.sin(phase * 3) + 0.04 * math.sin(phase * 5)
            value = round(value * 31) / 31.0
            attack = min(1.0, time / 0.3)
            release = min(1.0, (seconds - time) / 0.4)
        else:
            raise ValueError(voice)
        output.append(value * attack * release)
    return output


@functools.lru_cache(maxsize=16)
def drum(kind, variation=0):
    rng = random.Random(341 + variation)
    duration = 0.36 if kind == 'bass' else 0.2
    output = array.array('f')
    noise = 0.0
    filtered = 0.0
    phase = 0.0
    for index in range(round(duration * RATE)):
        time = index / RATE
        if index % 6 == 0:
            noise = rng.choice((-1.0, 1.0))
        filtered += (noise - filtered) * 0.12
        if kind == 'bass':
            phase += TAU * (40 + 45 * math.exp(-time * 24)) / RATE
            value = math.sin(phase) * math.exp(-time * 12)
        else:
            value = (filtered * 0.65 + noise * 0.17 + math.sin(TAU * 190 * time) * 0.18) * math.exp(-time * 28)
        envelope = min(1.0, time / 0.002) * min(1.0, (duration - time) / 0.015)
        output.append(value * envelope)
    return output


class Score:
    def __init__(self, bpm, bars):
        self.beat = 60.0 / bpm
        self.frames = round(bars * 4 * self.beat * RATE)
        self.left = array.array('f', [0.0]) * self.frames
        self.right = array.array('f', [0.0]) * self.frames

    def mix(self, sound, beat, gain, pan=0.0):
        start = round(beat * self.beat * RATE)
        left = gain * math.sqrt((1 - pan) * 0.5)
        right = gain * math.sqrt((1 + pan) * 0.5)
        for offset, value in enumerate(sound):
            index = (start + offset) % self.frames
            self.left[index] += value * left
            self.right[index] += value * right

    def play(self, pitch, beat, length, voice, gain, pan=0.0):
        sound = tone(pitch, length * self.beat, voice)
        self.mix(sound, beat, gain, pan)
        if voice == 'flute':
            self.mix(sound, beat + 0.75, gain * 0.15, -pan)
            self.mix(sound, beat + 1.5, gain * 0.05, pan)

    def roll(self, beat, count, gain):
        for index in range(count):
            accent = 0.8 if index % 2 else 1.0
            self.mix(drum('snare', index % 4), beat + index * 0.125, gain * accent, -0.1)

    def save(self, path):
        peak = max(max(map(abs, self.left)), max(map(abs, self.right)))
        scale = 0.78 / peak
        pcm = array.array('h')
        for left, right in zip(self.left, self.right):
            pcm.extend((round(left * scale * 32767), round(right * scale * 32767)))
        if sys.byteorder != 'little':
            pcm.byteswap()
        path.parent.mkdir(parents=True, exist_ok=True)
        with wave.open(str(path), 'wb') as output:
            output.setnchannels(2)
            output.setsampwidth(2)
            output.setframerate(RATE)
            output.writeframes(pcm.tobytes())
        print(f'{path.name}: {self.frames / RATE:.2f}s', flush=True)


def procession(path):
    score = Score(52, 6)
    phrases = [
        [(0.5, 62, 2.5)],
        [(0, 61, 1.4), (2.25, 58, 1.3)],
        [(0.5, 63, 2.7)],
        [(0, 62, 2.2), (3, 57, 0.7)],
        [(0.5, 58, 1.6), (2.5, 56, 1.0)],
        [(0, 57, 2.8)],
    ]
    for bar, phrase in enumerate(phrases):
        base = bar * 4
        score.play(26, base, 3.98, 'drone', 0.25)
        score.play(38 if bar % 3 else 39, base + 0.25, 3.5, 'low_horn', 0.05)
        score.mix(drum('bass'), base, 0.38)
        for beat in (1, 3):
            score.roll(base + beat, 2, 0.15)
        if bar % 2:
            score.roll(base + 3.5, 4, 0.065)
        for beat, pitch, duration in phrase:
            score.play(pitch, base + beat, duration, 'flute', 0.13, -0.15)
    score.save(path)


def battalion(path):
    score = Score(60, 8)
    phrases = [
        [(0.5, 62, 1.0), (2, 63, 0.7), (3, 57, 0.65)],
        [(0, 62, 2.4)],
        [(0.5, 65, 1.1), (2.5, 63, 1.0)],
        [(0, 62, 1.7), (2.5, 58, 1.0)],
        [(0.5, 57, 1.2), (2.5, 56, 0.8)],
        [(0, 58, 2.4)],
        [(0.5, 63, 1.0), (2, 62, 1.0)],
        [(0, 61, 1.5), (2.5, 57, 0.8)],
    ]
    for bar, phrase in enumerate(phrases):
        base = bar * 4
        score.play(26, base, 3.98, 'drone', 0.2)
        for beat in (0, 2):
            score.mix(drum('bass'), base + beat, 0.42)
        for beat in (1, 3):
            score.mix(drum('snare', bar % 4), base + beat, 0.26)
        score.roll(base + 0.5, 3, 0.055)
        score.roll(base + 2.5, 3, 0.07)
        if bar % 2:
            score.roll(base + 3.5, 4, 0.095)
        for beat, pitch, duration in phrase:
            score.play(pitch, base + beat, duration, 'flute', 0.14, -0.12)
        if bar in (3, 7):
            score.play(44, base, 3.5, 'low_horn', 0.055, 0.2)
    score.save(path)


def siege(path):
    score = Score(48, 6)
    phrases = [(0, 62, 2.5), (1, 61, 2.2), (0.5, 56, 2.8), (0, 58, 2.5), (1, 63, 2.5), (0.5, 61, 2.6)]
    for bar, (beat, pitch, duration) in enumerate(phrases):
        base = bar * 4
        score.play(26, base, 3.98, 'drone', 0.25, -0.12)
        score.play(44 if bar % 2 else 39, base + 0.25, 3.5, 'drone', 0.045, 0.2)
        score.mix(drum('bass'), base, 0.3)
        score.roll(base + 2.75, 6, 0.09)
        score.play(pitch, base + beat, duration, 'flute', 0.12, -0.3)
        if bar in (2, 5):
            score.play(38, base + 0.5, 3, 'low_horn', 0.085, 0.25)
    score.save(path)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, default=Path(__file__).resolve().parents[1] / 'assets/audio/music/previews')
    destination = parser.parse_args().output
    procession(destination / '01_procesion_del_hielo.wav')
    battalion(destination / '02_batallon_polar.wav')
    siege(destination / '03_asedio_en_la_niebla.wav')
