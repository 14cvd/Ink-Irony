#!/usr/bin/env python3
"""Synthesises Ink & Irony's sound effects into Ink/Resources/Sounds/*.wav.

Own sounds, no licence questions. Standard library only. Re-run to regenerate:
    python3 tools/make_sounds.py
"""
import math
import os
import random
import struct
import wave

RATE = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "Ink", "Resources", "Sounds")
random.seed(7)  # same files on every run


def tone(freq, dur, amp=0.5, decay=8.0, harmonics=(1.0, 0.35, 0.12)):
    n = int(RATE * dur)
    out = []
    for i in range(n):
        t = i / RATE
        env = math.exp(-decay * t) * min(1.0, t * 400)  # 2.5 ms attack, no click
        s = sum(h * math.sin(2 * math.pi * freq * (k + 1) * t) for k, h in enumerate(harmonics))
        out.append(amp * env * s / sum(harmonics))
    return out


def noise(dur, amp=0.5, decay=20.0, smooth=0.0, wobble=0.0):
    """Filtered noise. `smooth` 0..0.99 is a one-pole low-pass, `wobble` Hz adds a scribble rhythm."""
    n = int(RATE * dur)
    out, prev = [], 0.0
    for i in range(n):
        t = i / RATE
        x = random.uniform(-1, 1)
        prev = smooth * prev + (1 - smooth) * x
        env = math.exp(-decay * t) * min(1.0, t * 800)
        if wobble:
            env *= 0.55 + 0.45 * abs(math.sin(math.pi * wobble * t))
        out.append(amp * env * prev)
    return out


def sweep(f0, f1, dur, amp=0.5, decay=6.0):
    n = int(RATE * dur)
    out, phase = [], 0.0
    for i in range(n):
        t = i / RATE
        f = f0 + (f1 - f0) * (i / n)
        phase += 2 * math.pi * f / RATE
        out.append(amp * math.exp(-decay * t) * min(1.0, t * 400) * math.sin(phase))
    return out


def mix(*tracks, offsets=None):
    offsets = offsets or [0.0] * len(tracks)
    length = max(int(o * RATE) + len(t) for t, o in zip(tracks, offsets))
    out = [0.0] * length
    for track, offset in zip(tracks, offsets):
        start = int(offset * RATE)
        for i, s in enumerate(track):
            out[start + i] += s
    return out


def save(name, samples, gain=0.9):
    peak = max(1e-9, max(abs(s) for s in samples))
    scale = gain / peak
    # 8 ms fade out so nothing ends in a click
    fade = int(RATE * 0.008)
    data = bytearray()
    for i, s in enumerate(samples):
        if i > len(samples) - fade:
            s *= (len(samples) - i) / fade
        data += struct.pack("<h", int(max(-1, min(1, s * scale)) * 32767))
    path = os.path.join(OUT, name + ".wav")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(bytes(data))
    print(f"{name}.wav  {len(samples) / RATE * 1000:.0f} ms")


def main():
    os.makedirs(OUT, exist_ok=True)
    # Key press: a short pen tick on paper.
    save("pen_scratch", noise(0.06, decay=70, smooth=0.55), gain=0.45)
    # Correct letter: pen tick plus a bright two-note pluck.
    save("sfx_correct", mix(noise(0.03, decay=90, smooth=0.5), tone(880, 0.16, decay=22), tone(1318.5, 0.22, decay=16),
                            offsets=[0, 0.005, 0.07]), gain=0.6)
    # Wrong letter: a red-pen scribble over a low thud.
    save("sfx_wrong", mix(noise(0.26, decay=7, smooth=0.75, wobble=22), tone(140, 0.2, decay=18, harmonics=(1.0, 0.2))),
         gain=0.65)
    # Word solved: a rising four-note chime.
    save("checkmark", mix(*[tone(f, 0.5, decay=6) for f in (523.25, 659.25, 783.99, 1046.5)],
                          offsets=[0, 0.08, 0.16, 0.24]), gain=0.7)
    # Word lost: a pencil snaps, then a falling tone.
    save("pencil_snap", mix(noise(0.02, decay=200, smooth=0.1), sweep(320, 110, 0.35, decay=5), offsets=[0, 0.015]), gain=0.7)
    # Paper tear: crackling noise that slowly darkens.
    tear = [s * (1.6 if random.random() < 0.04 else 1.0) for s in noise(0.45, decay=4, smooth=0.6, wobble=40)]
    save("paper_tear", tear, gain=0.55)
    # Rubber stamp: a low thump with a paper slap.
    save("stamp", mix(tone(85, 0.22, decay=16, harmonics=(1.0, 0.3)), noise(0.05, decay=60, smooth=0.3)), gain=0.8)


if __name__ == "__main__":
    main()
