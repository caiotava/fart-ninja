extends ProgressBar

@export var keep_increase = 1.0
@export var const_descrease = 0.25
@export var release_increase = 0.1
@export var full_release_increase = 0.5
#@export var limit = 10
#var value_hist = []
var keep_last_pressed
var full_release = false
signal do_fart
var full_release_sound_position;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if event is InputEventKey and event.is_action_pressed("keep") and not full_release:
		# Increase the progress bar value
		value += keep_increase
		# add the timestamp of the last pressed key
		keep_last_pressed = Time.get_ticks_msec()
		## Clamp the value to not exceed the maximum
		#value = min(value, value_hist[0])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# wait for first key press
	if not keep_last_pressed:
		return
	# if full release then wait will 100%
	if full_release:
		value += full_release_increase
		do_fart.emit()
		if value == 100:
			full_release = false
	# if last pressed key is more than 200 ms ago
	elif keep_last_pressed and Time.get_ticks_msec() - keep_last_pressed > 200:
		value += release_increase
		do_fart.emit()
		if $Decrease.playing:
			$Decrease.stop()
		if not $FullReleaseIncrease.playing:
			$FullReleaseIncrease.play()
			if full_release_sound_position:
				$FullReleaseIncrease.seek(full_release_sound_position)
		#if not $Fart.playing:
			#$Fart.play()
		#value_hist = [value]
	else:
		if $FullReleaseIncrease.playing:
			full_release_sound_position = $FullReleaseIncrease.get_playback_position()
			$FullReleaseIncrease.stop()
		if $Fart.playing:
			$Fart.stop()
		if not $Decrease.playing:
			$Decrease.play()
		#if not $Decrease1.playing and not $Decrease2.playing:
			#[$Decrease1, $Decrease2][randi_range(0, 1)].play()
		# reduce the progress bar value by 0.1 every frame
		value -= const_descrease
		#value_hist.append(value)
		#value_hist = value_hist.slice(max(value_hist.size()-limit, 0), value_hist.size())

	if value == 0:
		full_release = true
		$FullReleasePop.play()
		$FullReleaseIncrease.play()
		
