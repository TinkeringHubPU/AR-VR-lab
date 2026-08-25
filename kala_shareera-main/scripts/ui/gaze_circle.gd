## GazeCircle – A custom Control that draws a "feeling circle" progress ring.
## Attach this as a child of the GazeReticle CanvasLayer.
## Call set_progress(0.0..1.0) every frame to drive the fill arc.
extends Control

## Outer radius of the progress ring in pixels.
@export var ring_radius: float = 38.0
## Width of the arc stroke in pixels.
@export var ring_width: float = 6.0
## Radius of the small centre dot.
@export var dot_radius: float = 5.0
## Number of segments used to draw the arc (higher = smoother).
@export var arc_segments: int = 64

## 0.0 = empty, 1.0 = full ring.
var progress: float = 0.0

## Idle dot color (no gaze target).
const COLOR_IDLE   := Color(1.0, 1.0, 1.0, 0.55)
## Fill color while dwelling.
const COLOR_FILL   := Color(0.95, 0.75, 0.2, 0.95)   # warm gold
## Background ring track color.
const COLOR_TRACK  := Color(1.0, 1.0, 1.0, 0.18)

func set_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5

	# ── Background track ring ────────────────────────────────────────────────
	draw_arc(center, ring_radius, 0.0, TAU, arc_segments, COLOR_TRACK, ring_width, true)

	# ── Progress fill arc (starts at 12 o'clock = -PI/2, goes clockwise) ────
	if progress > 0.0:
		var end_angle := -PI * 0.5 + progress * TAU
		draw_arc(center, ring_radius, -PI * 0.5, end_angle, arc_segments, COLOR_FILL, ring_width, true)

	# ── Centre dot ───────────────────────────────────────────────────────────
	var dot_color := COLOR_FILL if progress > 0.0 else COLOR_IDLE
	draw_circle(center, dot_radius, dot_color)
