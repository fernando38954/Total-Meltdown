extends Node

@onready var SFXPlayer = $SFXPlayer
@onready var BGMPlayer = $BGMPlayer

var tween: Tween

func _ready():
	GlobalSignal.volume_level_changed.connect(update_volume_level)

func update_volume_level():
	var SFX_volume_level = GlobalResource.volume_level
	var BGM_volume_level = GlobalResource.volume_level * 0.5
	SFXPlayer.set_volume_db(linear_to_db(SFX_volume_level))
	BGMPlayer.set_volume_db(linear_to_db(BGM_volume_level))

#region Fade
func fade_volume(stream_player: AudioStreamPlayer, target_volume_level: float, duration: float):
	if tween and tween.is_running():
		tween.kill()
		tween.finished.emit()
	
	var target_db = linear_to_db(target_volume_level)
	target_db = clamp(target_db, -80, 24)
	tween = create_tween()
	tween.tween_property(stream_player, "volume_db", target_db, duration)

func fade_in_bgm(duration: float = .9):
	fade_volume(BGMPlayer, GlobalResource.volume_level * 0.5, duration)

func fade_out_bgm(duration: float = .9):
	fade_volume(BGMPlayer, 0, duration)
#endregion

#region SFX
func play_sfx(target_sfx: AudioStream):
	SFXPlayer.stream = target_sfx
	SFXPlayer.play()

func stop_sfx():
	SFXPlayer.stop()
#endregion

#region BGM
func play_bgm(target_bgm: AudioStream):
	BGMPlayer.stream = target_bgm
	BGMPlayer.play()
	fade_in_bgm()

func stop_bgm():
	fade_out_bgm()
	await tween.finished
	BGMPlayer.stop()
#endregion
