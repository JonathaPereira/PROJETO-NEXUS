extends AudioStreamPlayer
## Original short synthesized cues. No downloaded sound packs or network requests.
var enabled := false
var cues: Array[AudioStreamWAV] = []

func _ready() -> void:
	volume_db = -14.0
	for index in range(10):
		var cue := AudioStreamWAV.new()
		cue.format = AudioStreamWAV.FORMAT_16_BITS
		cue.mix_rate = 22050
		var samples := PackedByteArray()
		var count := 5512
		samples.resize(count * 2)
		var frequency := 180.0 + index * 65.0
		for i in range(count):
			var t := float(i) / cue.mix_rate
			var envelope := sin(PI * i / count) * exp(-t * 10)
			var wave := sin(TAU * frequency * t) + 0.25 * sin(TAU * frequency * 2 * t)
			if index == 7: wave = sin(TAU * 960 * t) * sin(TAU * 1370 * t)
			elif index == 8: wave = sin(TAU * (420 * t + 1100 * t * t)) + 0.3 * sin(TAU * 85 * t)
			elif index == 9: wave = sin(TAU * 100 * t) * exp(-t * 18)
			samples.encode_s16(i * 2, int(clampf(wave * envelope * 0.6, -1, 1) * 32767))
		cue.data = samples
		cues.append(cue)

func play_cue(index: int) -> void:
	if enabled and not cues.is_empty():
		stream = cues[index % cues.size()]
		play()
