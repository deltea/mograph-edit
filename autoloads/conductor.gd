extends AudioStreamPlayer


signal beat(pos: int)
signal half_beat(pos: int)
signal quarter_beat(pos: int)


@export var bpm: int = 126
@export var measures: int = 4
@export var start_beat_offset: int = 0


var BEAT: float = 60.0 / bpm
var HALF_BEAT: float = BEAT / 2.0
var QUARTER_BEAT: float = BEAT / 4.0
var TWO_BEAT: float = BEAT * 2.0
var MEASURE: float = BEAT * 4.0


var curr_pos: float = 0.0
var curr_pos_beats: int = 0
var sec_per_beat: float = BEAT
var last_beat: int = -4
# this tracks
var beat_offset: int = start_beat_offset

var beat_patterns: Array[BeatPattern] = []


func _ready() -> void:
	pitch_scale = Engine.time_scale

	for node in get_tree().get_nodes_in_group("beat_pattern"):
		if node is BeatPattern:
			beat_patterns.append(node)


func _process(_dt: float) -> void:
	if not playing:
		return

	curr_pos = get_playback_position() + AudioServer.get_time_since_last_mix()
	curr_pos -= AudioServer.get_output_latency()
	# adding one so that the first beat is 1 instead of 0
	curr_pos_beats = int(floor(curr_pos / sec_per_beat)) - beat_offset + 1

	if last_beat < curr_pos_beats:
		beat.emit(curr_pos_beats)
		last_beat = curr_pos_beats


func play_from_beat(pos_beat: int) -> void:
	play()
	beat_offset = start_beat_offset + pos_beat
	seek(beat_offset * sec_per_beat)
	beat_offset += beat_offset % 4


func wait(duration: float) -> void:
	await get_tree().create_timer(duration, true, false, true).timeout
