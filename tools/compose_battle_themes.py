import argparse
import array
import functools
import math
from pathlib import Path
import random

from compose_dark_marches import RATE, Score, drum


TAU = math.tau


@functools.lru_cache(maxsize=192)
def battle_tone(pitch, seconds, voice):
    frequency = 440.0 * 2 ** ((pitch - 69) / 12)
    rng = random.Random(pitch * 181)
    output = array.array('f')
    breath = 0.0
    for index in range(round(seconds * RATE)):
        time = index / RATE
        phase = TAU * frequency * time
        attack = min(1.0, time / 0.018)
        release = min(1.0, (seconds - time) / 0.035)
        if voice == 'fife':
            vibrato = 0.035 * math.sin(TAU * 5.2 * time) * min(1.0, time / 0.25)
            breath += (rng.uniform(-1.0, 1.0) - breath) * 0.16
            value = math.sin(phase + vibrato) + 0.21 * math.sin(phase * 2) + 0.09 * math.sin(phase * 3)
            value = round(value * 63) / 63.0 + breath * 0.035
        elif voice == 'bass':
            value = math.sin(phase) + 0.18 * math.sin(phase * 2) + 0.1 * math.sin(phase * 3)
            value *= 0.55 + 0.45 * math.exp(-time * 12)
        elif voice == 'pulse':
            value = sum(math.sin(phase * h) / h for h in (1, 3, 5) if frequency * h < RATE * 0.4) * 0.6
            value *= math.exp(-time * 3)
        elif voice == 'tension':
            value = math.sin(phase) + 0.12 * math.sin(phase * 2.002) + 0.1 * math.sin(phase * 3)
            value *= 0.8 + 0.2 * math.sin(TAU * 2.0 * time)
            attack = min(1.0, time / 0.2)
            release = min(1.0, (seconds - time) / 0.25)
        else:
            raise ValueError(voice)
        output.append(value * attack * release)
    return output


class BattleScore(Score):
    def __init__(self, bpm, bars, beats_per_bar=4):
        super().__init__(bpm, bars * beats_per_bar / 4)

    def play(self, pitch, beat, length, voice, gain, pan=0.0):
        sound = battle_tone(pitch, length * self.beat, voice)
        self.mix(sound, beat, gain, pan)
        if voice == 'fife':
            self.mix(sound, beat + 0.5, gain * 0.13, -pan)
            self.mix(sound, beat + 1.0, gain * 0.045, pan)


def assault(path):
    score = BattleScore(108, 16)
    roots = [40, 40, 41, 40, 36, 36, 39, 39]
    melody = [
        [(0, 76, 0.42), (0.75, 77, 0.2), (1.0, 71, 0.65), (2, 74, 0.35), (2.5, 76, 0.4), (3.25, 70, 0.35)],
        [(0, 71, 0.85), (1.5, 75, 0.35), (2.25, 76, 0.95)],
        [(0, 77, 0.65), (1, 76, 0.4), (1.75, 72, 0.65), (3, 71, 0.45)],
        [(0, 70, 0.9), (1.5, 71, 0.4), (2.25, 75, 0.35), (3, 74, 0.45)],
    ]
    for bar in range(16):
        base = bar * 4
        root = roots[bar % 8]
        for beat in (0, 2):
            score.mix(drum('bass'), base + beat, 0.5)
        for beat in (1, 3):
            score.roll(base + beat, 2, 0.26)
        for beat in (0.75, 2.75):
            score.roll(base + beat, 2, 0.07)
        if bar % 4 == 3:
            score.roll(base + 3.5, 4, 0.11)
        for beat in (0, 0.75, 1.5, 2, 2.75, 3.5):
            score.play(root, base + beat, 0.35, 'bass', 0.32)
        score.play(root + 7, base, 3.9, 'tension', 0.055, -0.3)
        if bar not in (8, 9):
            for beat, pitch, duration in melody[bar % 4]:
                score.play(pitch, base + beat, duration, 'fife', 0.19, -0.12)
        if bar >= 4:
            for beat in (0.5, 1.5, 2.5, 3.5):
                score.play(root + 19, base + beat, 0.18, 'pulse', 0.035, 0.35)
    score.save(path)


def rivalry(path):
    score = BattleScore(132, 24, 3)
    melody = [
        [(0, 74, 0.38), (0.5, 77, 0.35), (1, 75, 0.4), (1.75, 69, 0.7)],
        [(0, 68, 0.7), (1, 69, 0.4), (1.75, 74, 0.8)],
        [(0, 75, 0.7), (1, 74, 0.4), (1.75, 72, 0.7)],
        [(0, 69, 0.65), (1, 68, 0.4), (2, 73, 0.6)],
    ]
    roots = [38, 38, 39, 38, 34, 34, 37, 37]
    for bar in range(24):
        base = bar * 3
        root = roots[bar % 8]
        score.mix(drum('bass'), base, 0.52)
        score.mix(drum('bass'), base + 1.5, 0.36)
        score.roll(base + 1, 3, 0.16)
        score.roll(base + 2.5, 4, 0.12 if bar % 2 else 0.08)
        for step in range(6):
            score.play(root + (12 if step == 4 else 0), base + step * 0.5, 0.32, 'bass', 0.26)
        for beat, pitch, duration in melody[bar % 4]:
            score.play(pitch, base + beat, duration, 'fife', 0.17, -0.25 if bar % 2 == 0 else 0.25)
        if bar >= 8:
            score.play(root + 18, base, 2.9, 'tension', 0.04, 0.2)
        if bar >= 16:
            for step in (0.75, 2.25):
                score.play(root + 12, base + step, 0.2, 'pulse', 0.05, -0.2)
    score.save(path)


def countdown(path):
    score = BattleScore(116, 16)
    melody = [
        [(0, 74, 0.7), (1.5, 75, 0.35), (2.25, 74, 0.9)],
        [(0, 73, 0.75), (1.5, 69, 1.4)],
        [(0.5, 77, 0.7), (1.75, 75, 0.6), (3, 74, 0.5)],
        [(0, 68, 0.7), (1.5, 69, 0.5), (2.5, 73, 0.8)],
    ]
    for bar in range(16):
        base = bar * 4
        root = 38 if bar % 4 < 2 else 39
        tension_pitch = 56 if bar % 4 == 3 else 57
        score.play(tension_pitch, base, 3.95, 'tension', 0.06, -0.25)
        for step in range(8):
            if bar % 4 == 3 and step >= 6:
                continue
            score.play(root, base + step * 0.5, 0.26, 'bass', 0.28)
            score.play(62 + (1 if step % 4 == 2 else 0), base + step * 0.5, 0.16, 'pulse', 0.055, 0.2)
        for beat in (0, 1.5, 2.5):
            score.mix(drum('bass'), base + beat, 0.43)
        for beat in (1, 3):
            score.roll(base + beat, 2, 0.19)
        if bar % 4 == 3:
            score.roll(base + 3, 8, 0.105)
        if bar % 8 not in (4, 5):
            for beat, pitch, duration in melody[bar % 4]:
                score.play(pitch, base + beat, duration, 'fife', 0.17, -0.1)
    score.save(path)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, default=Path(__file__).resolve().parents[1] / 'assets/audio/music/previews')
    output = parser.parse_args().output
    assault(output / '04_orden_de_asalto.wav')
    rivalry(output / '05_rivales_en_el_hielo.wav')
    countdown(output / '06_cuenta_atras_de_guerra.wav')
