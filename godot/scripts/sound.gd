extends AudioStreamPlayer
## Original layered transients: filtered air, resonant body and short material tails.
var enabled := false
var cues: Array[AudioStreamWAV] = []

func _ready() -> void:
	volume_db = -11.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 80421
	for index in range(10):
		var cue := AudioStreamWAV.new()
		cue.format = AudioStreamWAV.FORMAT_16_BITS
		cue.mix_rate = 44100
		var duration := .54 if index in [0,3,4,5] else .39
		var count := int(cue.mix_rate*duration)
		var samples := PackedByteArray()
		samples.resize(count*2)
		var low := 0.0
		var air := 0.0
		for i in range(count):
			var t := float(i)/cue.mix_rate
			var noise := rng.randf_range(-1,1)
			low = lerpf(low,noise,.055)
			air = lerpf(air,noise,.38)
			var high := air-low
			var attack := 1-exp(-t*450)
			var body := sin(TAU*(78*t+34*(1-exp(-t*16))))*exp(-t*24)
			var whoosh := high*exp(-t*12)*attack
			var tail := low*exp(-t*8)*.4
			var wave := body*.35+whoosh*.65+tail
			match index:
				0: wave=body*.55+high*exp(-t*9)*attack*.65+low*exp(-t*6)*.3
				1: wave=body*.75+low*exp(-t*16)*2+whoosh*.25
				2: wave=body*.35+whoosh*.7+sin(TAU*1300*t)*exp(-t*38)*.16
				3: wave=high*exp(-t*7)*attack*.5+(sin(TAU*440*t)+sin(TAU*659.25*t)*.3)*exp(-t*11)*.14
				4: wave=low*exp(-t*6)*1.4+body*.35+whoosh*.25
				5: wave=high*exp(-t*9)*.2+(sin(TAU*523.25*t)+sin(TAU*783.99*t)*.3)*exp(-t*8)*.14
				6,7: wave=whoosh*.3+(sin(TAU*740*t)+sin(TAU*1174*t)*.4+sin(TAU*1941*t)*.2)*exp(-t*18)*.25+body*.15
				8: wave=body*.65+whoosh*.6+sin(TAU*(1800*t-700*t*t))*exp(-t*30)*.2
				9: wave=low*exp(-t*22)+sin(TAU*92*t)*exp(-t*26)*.4
			var edge := smoothstep(duration,duration-.04,t)
			samples.encode_s16(i*2,int(clampf(tanh(wave*1.2)*edge,-1,1)*27000))
		cue.data = samples
		cues.append(cue)

func play_cue(index: int) -> void:
	if enabled and not cues.is_empty():
		stream = cues[posmod(index,cues.size())]
		play()
