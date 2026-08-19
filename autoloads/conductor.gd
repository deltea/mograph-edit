extends AudioStreamPlayer


signal beat(pos: int)
signal measure(pos_measure: int)


@export var bpm: int = 124
@export var measures: int = 4
@export var song_start_offset: int = 0


var curr_pos: float = 0.0
var curr_pos_beats: int = 1
var curr_measure: int = 1
var sec_per_beat: float = 60.0 / bpm
var last_beat: int = 0


func _process(_dt: float) -> void:
	if not playing:
		return

	curr_pos = get_playback_position() + AudioServer.get_time_since_last_mix() - (song_start_offset * sec_per_beat)
	curr_pos -= AudioServer.get_output_latency()
	curr_pos_beats = int(floor(curr_pos / sec_per_beat))

	if last_beat < curr_pos_beats:
		if curr_measure > measures:
			curr_measure = 1

		beat.emit(curr_pos_beats)
		measure.emit(curr_measure)

		last_beat = curr_pos_beats
		curr_measure += 1


func play_from_beat(beat: int) -> void:
	play()
	seek((beat + song_start_offset) * sec_per_beat)
	curr_measure = beat % measures + 1

