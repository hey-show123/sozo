import wave
import math
import struct
import os

def generate_tone(frequency, duration, volume=0.5, sample_rate=44100):
    n_samples = int(sample_rate * duration)
    data = []
    for i in range(n_samples):
        value = int(volume * 32767.0 * math.sin(2.0 * math.pi * frequency * i / sample_rate))
        data.append(value)
    return data

def generate_square_wave(frequency, duration, volume=0.5, sample_rate=44100):
    n_samples = int(sample_rate * duration)
    data = []
    period = sample_rate / frequency
    for i in range(n_samples):
        if (i % period) < (period / 2):
            value = int(volume * 32767.0)
        else:
            value = int(-volume * 32767.0)
        data.append(value)
    return data

def save_wav(filename, data, sample_rate=44100):
    with wave.open(filename, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        for value in data:
            f.writeframes(struct.pack('<h', value))

# Ensure directory exists
output_dir = 'sozo_app/assets/sounds'
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# 1. Correct Sound (Ding - High pitch sine wave followed by a fade out)
# Actually, an ascending major triad is nicer (C5 - E5 - G5)
sample_rate = 44100
correct_data = []
# C5
correct_data.extend(generate_tone(523.25, 0.1))
# E5
correct_data.extend(generate_tone(659.25, 0.1))
# G5 (longer)
# Add decay
freq = 783.99
duration = 0.4
for i in range(int(sample_rate * duration)):
    vol = 0.5 * (1.0 - i / (sample_rate * duration)) # Linear decay
    value = int(vol * 32767.0 * math.sin(2.0 * math.pi * freq * i / sample_rate))
    correct_data.append(value)

save_wav(f'{output_dir}/correct.wav', correct_data)
print(f'Generated {output_dir}/correct.wav')

# 2. Incorrect Sound (Softer - Low pitch descending sine wave)
incorrect_data = []
start_freq = 200.0
end_freq = 150.0
duration = 0.3
for i in range(int(sample_rate * duration)):
    # Linear decay in volume
    vol = 0.4 * (1.0 - i / (sample_rate * duration)) 
    
    # Linear slide in frequency
    t = i / (sample_rate * duration)
    current_freq = start_freq + (end_freq - start_freq) * t
    
    # Sine wave (much softer than square)
    # Note: For changing frequency, we should integrate phase, but for short duration/small change this approximation is okay-ish, 
    # but strictly correct is integrating phase. Let's do a simple approximation or standard sine at fixed low freq to be safe against artifacts.
    # Actually, let's just do a short low "bonk" at fixed frequency.
    # 2 tone descending is better.
    # Let's simple fixed low sine with quick decay.
    
    # "Bonk" sound
    freq = 150.0
    value = int(vol * 32767.0 * math.sin(2.0 * math.pi * freq * i / sample_rate))
    
    incorrect_data.append(value)

save_wav(f'{output_dir}/incorrect.wav', incorrect_data)
print(f'Generated {output_dir}/incorrect.wav')
