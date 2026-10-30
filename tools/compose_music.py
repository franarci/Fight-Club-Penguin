import argparse
import array
import functools
import math
from pathlib import Path
import random
import struct
import wave

RATE = 32000
BPM = 174
BEAT = 60 / BPM
BARS = 32
LENGTH = round(BARS * 4 * BEAT * RATE)
TAU = math.tau


@functools.lru_cache(maxsize=None)
def tone(midi, beats, voice):
    duration = beats * BEAT
    count = round(duration * RATE)
    frequency = 440 * 2 ** ((midi - 69) / 12)
    samples = array.array('f')
    for i in range(count):
        t = i / RATE
        phase = TAU * frequency * t
        attack = min(1, t / 0.006)
        release = min(1, (duration - t) / 0.025)
        if voice == 'bell':
            value = (math.sin(phase) + 0.28 * math.sin(phase * 2) + 0.12 * math.sin(phase * 3)) * math.exp(-t * 11)
        elif voice == 'pulse':
            value = sum(math.sin(phase * h) / h for h in (1, 3, 5, 7) if frequency * h < RATE * 0.42) * 0.62
            value *= 0.5 + 0.5 * math.exp(-t * 10)
        elif voice == 'bass':
            value = math.sin(phase) * 0.8 + math.sin(phase * 2) * 0.14 + math.sin(phase * 3) * 0.07
        elif voice == 'reese':
            value = sum((math.sin(phase * h * 0.996) + math.sin(phase * h * 1.004)) / (h * 2) for h in (1, 2, 3, 4, 5, 6) if frequency * h < 6000)
            value = math.tanh(value * 1.7) * (0.7 + 0.3 * math.sin(TAU * 5.8 * t))
        elif voice == 'dark_pad':
            growl = sum((math.sin(phase * h * 0.997) + math.sin(phase * h * 1.003)) / (2 * h ** 1.35) for h in (1, 2, 3, 4, 5, 6))
            movement = 0.78 + 0.22 * math.sin(TAU * 0.38 * t)
            value = math.tanh(growl * 1.6) * movement
            attack = min(1, t / 0.3)
            release = min(1, (duration - t) / 0.4)
        elif voice == 'frost':
            value = (math.sin(phase) * 0.5 + math.sin(phase * 2.013) * 0.23 + math.sin(phase * 3.009) * 0.14 + math.sin(phase * 4.998) * 0.07) * math.exp(-t * 1.5)
            attack = min(1, t / 0.05)
            release = min(1, (duration - t) / 0.2)
        elif voice == 'pad':
            value = (math.sin(phase) + 0.2 * math.sin(phase * 2.003)) * 0.65
            attack = min(1, t / 0.08)
            release = min(1, (duration - t) / 0.12)
        else:
            raise ValueError(voice)
        samples.append(value * attack * release)
    return samples


@functools.lru_cache(maxsize=None)
def drum(kind):
    rng = random.Random(174 + sum(map(ord, kind)))
    duration = {'kick': 0.25, 'snare': 0.19, 'hat': 0.055, 'open': 0.17, 'crash': 0.6}[kind]
    count = round(duration * RATE)
    samples = array.array('f')
    phase = 0.0
    previous_noise = 0.0
    low_noise = 0.0
    for i in range(count):
        t = i / RATE
        noise = rng.uniform(-1, 1)
        high_noise = (noise - previous_noise) * 0.5
        low_noise += (noise - low_noise) * 0.2
        previous_noise = noise
        if kind == 'kick':
            phase += TAU * (48 + 150 * math.exp(-t * 42)) / RATE
            value = math.sin(phase) * math.exp(-t * 20) + high_noise * math.exp(-t * 350) * 0.3
        elif kind == 'snare':
            value = (noise * 0.65 + low_noise * 0.35) * math.exp(-t * 27) + math.sin(TAU * 183 * t) * math.exp(-t * 40) * 0.48
        else:
            decay = {'hat': 85, 'open': 24, 'crash': 7}[kind]
            metallic = math.sin(TAU * 4310 * t) * math.sin(TAU * 6170 * t)
            value = (high_noise * 0.8 + metallic * 0.2) * math.exp(-t * decay)
        envelope = min(1, t / 0.001) * min(1, (duration - t) / 0.006)
        samples.append(value * envelope)
    return samples


class Arrangement:
    def __init__(self):
        self.left = array.array('f', [0]) * LENGTH
        self.right = array.array('f', [0]) * LENGTH

    def add(self, sound, beat, gain, pan=0):
        start = round(beat * BEAT * RATE)
        left_gain = gain * math.sqrt((1 - pan) * 0.5)
        right_gain = gain * math.sqrt((1 + pan) * 0.5)
        for i, sample in enumerate(sound):
            index = (start + i) % LENGTH
            self.left[index] += sample * left_gain
            self.right[index] += sample * right_gain

    def note(self, midi, beat, beats, voice, gain, pan=0, echo=False):
        sound = tone(midi, beats, voice)
        self.add(sound, beat, gain, pan)
        if echo:
            self.add(sound, beat + 0.75, gain * 0.18, -pan)
            self.add(sound, beat + 1.5, gain * 0.065, pan)

    def save(self, path):
        peak = max(max(abs(v) for v in self.left), max(abs(v) for v in self.right))
        scale = 0.86 / peak
        pcm = array.array('h')
        square_sum = 0.0
        for left, right in zip(self.left, self.right):
            l = left * scale
            r = right * scale
            square_sum += l * l + r * r
            pcm.extend((round(l * 32767), round(r * 32767)))
        if struct.pack('=h', 1) != struct.pack('<h', 1):
            pcm.byteswap()
        with wave.open(str(path), 'wb') as output:
            output.setnchannels(2)
            output.setsampwidth(2)
            output.setframerate(RATE)
            output.writeframes(pcm.tobytes())
        rms = math.sqrt(square_sum / (LENGTH * 2))
        print(f'{path.name}: {LENGTH / RATE:.3f}s, peak {20 * math.log10(0.86):.1f} dBFS, RMS {20 * math.log10(rms):.1f} dBFS')


CHORDS = [(45, (69, 72, 76)), (41, (65, 69, 72)), (48, (67, 72, 76)), (43, (67, 71, 74))]
MELODY = [
    [(0, 76, .5), (.75, 79, .25), (1.5, 81, .5), (2.5, 79, .25), (3, 76, .5)],
    [(0, 72, .5), (1, 76, .25), (1.75, 79, .25), (2.5, 76, .5), (3.5, 72, .25)],
    [(0, 76, .5), (.75, 79, .25), (1.5, 84, .5), (2.5, 83, .25), (3, 79, .5)],
    [(0, 74, .5), (1, 79, .25), (1.75, 83, .25), (2.5, 81, .25), (3, 79, .25), (3.5, 76, .25)],
]


def compose(combat, output):
    song = Arrangement()
    for bar in range(BARS):
        base = bar * 4
        section = bar // 8
        root, chord = CHORDS[(bar // 2) % 4]
        sparse = section == 2 and bar % 8 < 4
        kicks = [0, 1.75, 2.5] if bar % 2 == 0 else [0, .75, 2.5, 3.5]
        if combat:
            kicks += [2.75] if bar % 4 == 3 else []
        for beat in kicks:
            song.add(drum('kick'), base + beat, .62 if combat else .48)
        for beat in (1, 3):
            song.add(drum('snare'), base + beat, .48 if combat else .32, .03)
        if bar % 2:
            song.add(drum('snare'), base + 2.75, .11 if combat else .065, -.1)
        for step in range(16):
            if step % 2 and not combat and (step + bar) % 3:
                continue
            gain = (.1 if step % 2 == 0 else .045) * (1.15 if combat else .8)
            song.add(drum('hat'), base + step * .25, gain, -.27 if step % 2 else .27)
        song.add(drum('open'), base + 2.5, .065 if combat else .045, .35)
        if combat and bar % 8 == 0:
            song.add(drum('crash'), base, .13, -.15)
        if bar % 8 == 7:
            for step, gain in [(3.25, .11), (3.5, .16), (3.75, .23)]:
                song.add(drum('snare'), base + step, gain, -.18)
        bass_pattern = [(0, 0, .65), (.75, 0, .35), (1.5, 12, .3), (2.25, 0, .65), (3, 7, .3), (3.5, 0, .35)]
        for beat, interval, duration in bass_pattern:
            song.note(root - 12 + interval, base + beat, duration, 'bass', .3 if combat else .24)
            if combat and not sparse:
                song.note(root + interval, base + beat, duration, 'reese', .19)
        if bar % 2 == 0:
            song.note(root - 12, base, 7.9, 'dark_pad', .15 if combat else .12, -.2, True)
            song.note(root - 5, base + .5, 7.4, 'dark_pad', .055 if combat else .04, .25, True)
            song.note(root + 15, base, 7.8, 'pad', .038 if combat else .026, .5, True)
        if bar % 4 == 0:
            song.note(root + 36, base + 2.5, 3.4, 'frost', .07 if combat else .055, -.55, True)
            song.note(root + 31, base + 6, 2.6, 'frost', .045, .5, True)
        if combat:
            for pitch in chord:
                song.note(pitch - 12, base, 3.9, 'pad', .033, -.45 if pitch % 2 else .45)
            if not sparse:
                for step in range(8):
                    pitch = chord[(step + bar) % 3] + (12 if section == 3 else 0)
                    song.note(pitch, base + step * .5, .19, 'pulse', .04, -.3 if step % 2 else .3, True)
        else:
            for step, pitch in enumerate(chord):
                song.note(pitch, base + step * .25, .6, 'bell', .065, -.3 + step * .3, True)
            for beat in (1.5, 3.5):
                song.note(chord[(bar + 1) % 3], base + beat, .25, 'bell', .035, .3, True)
        if not sparse or bar % 2 == 0:
            for beat, pitch, duration in MELODY[bar % 4]:
                octave = 12 if section == 3 and bar % 4 >= 2 else 0
                song.note(pitch + octave, base + beat, duration, 'pulse' if combat else 'bell', .08 if combat else .115, -.12, True)
                if not combat and section in (1, 3):
                    song.note(pitch - 12, base + beat, duration * .8, 'pulse', .035, .18)
    song.save(output)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, default=Path(__file__).resolve().parents[1] / 'assets/audio/music')
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    compose(False, args.output / 'menu_icebreaker.wav')
    compose(True, args.output / 'combat_icebreaker.wav')
