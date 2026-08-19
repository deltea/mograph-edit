extends MeshInstance3D


var spectrum: AudioEffectSpectrumAnalyzerInstance
var min_hz := 120.0
var max_hz := 11050 / 4.0
var freq_bands := 256
var frequency_repeats := 8
var bar_width := 0.65
var smoothed_energy: Array[float] = []


func _ready() -> void:
	var bus_idx := AudioServer.get_bus_index("Music")
	spectrum = AudioServer.get_bus_effect_instance(bus_idx, 0)

	mesh = ImmediateMesh.new()
	smoothed_energy.resize(freq_bands)
	smoothed_energy.fill(0.0)


func _process(_dt: float) -> void:
	(mesh as ImmediateMesh).clear_surfaces()
	(mesh as ImmediateMesh).surface_begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(freq_bands):
		# Tile the spectrum across the visualizer instead of mapping it only once.
		var phase0 := float(i) / freq_bands * frequency_repeats
		var phase1 := float(i + 1) / freq_bands * frequency_repeats
		var t0 := fmod(phase0, 1.0)
		var t1 := fmod(phase1, 1.0)
		if is_zero_approx(t1):
			t1 = 1.0
		var prev_hz := min_hz + pow(t0, 2.5) * (max_hz - min_hz)
		var hz := min_hz + pow(t1, 2.5) * (max_hz - min_hz)
		var t := t1

		# Get magnitude for the frequency range
		var mag := spectrum.get_magnitude_for_frequency_range(prev_hz, hz)
		var energy := clampf((mag.length() + mag.y) * 100.0, 0.0, 100.0)
		smoothed_energy[i] = lerpf(smoothed_energy[i], energy, 0.15)
		energy = smoothed_energy[i]

		var x := (i - freq_bands / 2.0) * bar_width
		var half_w := bar_width * 0.4
		var depth := 0.05
		var z0 := -depth * 0.5
		var z1 := depth * 0.5
		var y0 := 0.0
		var y1 := energy
		var x0 := x - half_w
		var x1 := x + half_w
		var color := Color(t, 0.5, 1.0 - t)

		var verts := [
			Vector3(x0, y0, z0), Vector3(x1, y0, z0), Vector3(x1, y1, z0),
			Vector3(x0, y0, z0), Vector3(x1, y1, z0), Vector3(x0, y1, z0),
			Vector3(x0, y0, z1), Vector3(x1, y1, z1), Vector3(x1, y0, z1),
			Vector3(x0, y0, z1), Vector3(x0, y1, z1), Vector3(x1, y1, z1),
			Vector3(x0, y0, z0), Vector3(x0, y0, z1), Vector3(x0, y1, z1),
			Vector3(x0, y0, z0), Vector3(x0, y1, z1), Vector3(x0, y1, z0),
			Vector3(x1, y0, z0), Vector3(x1, y1, z1), Vector3(x1, y0, z1),
			Vector3(x1, y0, z0), Vector3(x1, y1, z0), Vector3(x1, y1, z1),
			Vector3(x0, y1, z0), Vector3(x1, y1, z0), Vector3(x1, y1, z1),
			Vector3(x0, y1, z0), Vector3(x1, y1, z1), Vector3(x0, y1, z1),
			Vector3(x0, y0, z0), Vector3(x1, y0, z1), Vector3(x1, y0, z0),
			Vector3(x0, y0, z0), Vector3(x0, y0, z1), Vector3(x1, y0, z1)
		]

		for v: Vector3 in verts:
			(mesh as ImmediateMesh).surface_set_color(color)
			(mesh as ImmediateMesh).surface_add_vertex(v)

	(mesh as ImmediateMesh).surface_end()
