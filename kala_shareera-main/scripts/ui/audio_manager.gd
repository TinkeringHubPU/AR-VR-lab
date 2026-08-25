extends Node

# Audio players
var music_player: AudioStreamPlayer
var sfx_click: AudioStreamPlayer
var sfx_hover: AudioStreamPlayer

# State
var music_enabled: bool = true
var sfx_enabled: bool = true

func _ready():
	# Create music player (ambient background)
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	music_player.volume_db = -10.0  # Subtle background level
	add_child(music_player)
	
	# Create SFX player for click/select sounds
	sfx_click = AudioStreamPlayer.new()
	sfx_click.bus = "Master"
	sfx_click.volume_db = -5.0
	add_child(sfx_click)
	
	# Create SFX player for hover sounds
	sfx_hover = AudioStreamPlayer.new()
	sfx_hover.bus = "Master"
	sfx_hover.volume_db = -12.0
	add_child(sfx_hover)
	
	# Generate procedural audio tones (no external files needed!)
	_generate_click_sound()
	_generate_hover_sound()
	_generate_ambient_music()

func play_click():
	if sfx_enabled and sfx_click.stream:
		sfx_click.play()

func play_hover():
	if sfx_enabled and sfx_hover.stream:
		sfx_hover.play()

func start_ambient_music():
	if music_enabled and music_player.stream and not music_player.playing:
		music_player.play()

func stop_ambient_music():
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -40.0, 1.0)
		tween.tween_callback(func():
			music_player.stop()
			music_player.volume_db = -10.0
		)

# === PROCEDURAL AUDIO GENERATION ===
# These create simple tones so we don't need external audio files

func _generate_click_sound():
	# A short, crisp "click" — rising tone burst
	var sample_rate = 22050
	var duration = 0.08  # 80ms click
	var samples = int(sample_rate * duration)
	
	var audio = AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false
	
	var data = PackedByteArray()
	data.resize(samples * 2)  # 16-bit = 2 bytes per sample
	
	for i in range(samples):
		var t = float(i) / sample_rate
		var progress = float(i) / samples
		
		# Rising frequency chirp (800 → 1600 Hz)
		var freq = 800.0 + 800.0 * progress
		var wave = sin(TAU * freq * t)
		
		# Quick attack, fast decay envelope
		var envelope = (1.0 - progress) * (1.0 - progress)
		
		var sample_val = int(wave * envelope * 16000)
		sample_val = clampi(sample_val, -32768, 32767)
		
		data.encode_s16(i * 2, sample_val)
	
	audio.data = data
	sfx_click.stream = audio

func _generate_hover_sound():
	# A soft, gentle "boop" — single soft tone
	var sample_rate = 22050
	var duration = 0.05  # 50ms
	var samples = int(sample_rate * duration)
	
	var audio = AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false
	
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / sample_rate
		var progress = float(i) / samples
		
		# Soft tone at 600 Hz
		var wave = sin(TAU * 600.0 * t)
		
		# Gentle envelope
		var attack = min(progress * 10.0, 1.0)
		var decay = 1.0 - progress
		var envelope = attack * decay * decay
		
		var sample_val = int(wave * envelope * 8000)
		sample_val = clampi(sample_val, -32768, 32767)
		
		data.encode_s16(i * 2, sample_val)
	
	audio.data = data
	sfx_hover.stream = audio

func _generate_ambient_music():
	# A calming, meditative drone — layered sine waves with slow modulation
	# Creates a tanpura-like ambient pad
	var sample_rate = 22050
	var duration = 16.0  # 16-second loop
	var samples = int(sample_rate * duration)
	
	var audio = AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_begin = 0
	audio.loop_end = samples
	
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / sample_rate
		
		# Base drone note (Sa - C3 ~ 130.81 Hz)
		var sa = sin(TAU * 130.81 * t) * 0.25
		
		# Perfect fifth (Pa - G3 ~ 196.0 Hz)
		var pa = sin(TAU * 196.0 * t) * 0.15
		
		# Octave (Sa' - C4 ~ 261.63 Hz)
		var sa_high = sin(TAU * 261.63 * t) * 0.1
		
		# Subtle Ma (F3 ~ 174.61 Hz) that fades in and out
		var ma_envelope = sin(TAU * t / 8.0) * 0.5 + 0.5  # Slow 8-second cycle
		var ma = sin(TAU * 174.61 * t) * 0.08 * ma_envelope
		
		# Very subtle shimmer/high harmonic
		var shimmer = sin(TAU * 523.25 * t) * 0.03 * (sin(TAU * t / 4.0) * 0.5 + 0.5)
		
		# Mix all together
		var mixed = sa + pa + sa_high + ma + shimmer
		
		# Gentle overall volume modulation (breathing effect)
		var breath = 0.8 + 0.2 * sin(TAU * t / 12.0)
		mixed *= breath
		
		var sample_val = int(mixed * 12000)
		sample_val = clampi(sample_val, -32768, 32767)
		
		data.encode_s16(i * 2, sample_val)
	
	audio.data = data
	music_player.stream = audio
