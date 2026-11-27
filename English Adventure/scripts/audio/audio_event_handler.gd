class_name AudioEventHandler
extends RefCounted
## Subscribes to EventBus gameplay, quest, reward, dialogue, and mini-game events
## and routes them cleanly to MusicManager, SoundEffectManager, and AudioPlaybackManager.

var _music: MusicManager
var _sfx: SoundEffectManager
var _playback: AudioPlaybackManager
var _connected: bool = false


func _init(music: MusicManager, sfx: SoundEffectManager, playback: AudioPlaybackManager) -> void:
	_music = music
	_sfx = sfx
	_playback = playback


func connect_events() -> void:
	if _connected:
		return
	_connected = true
	EventBus.quest_completed.connect(func(_qid: String, _rw: Dictionary) -> void:
		if _sfx != null:
			_sfx.play_sfx("quest_complete")
	)
	EventBus.quest_reward_claimed.connect(func(_qid: String, _rw: Dictionary) -> void:
		if _sfx != null:
			_sfx.play_sfx("reward_received")
	)
	EventBus.area_unlocked.connect(func(_aid: String) -> void:
		if _sfx != null:
			_sfx.play_sfx("area_unlocked")
	)
	EventBus.item_collected.connect(func(_iid: String, _qty: int) -> void:
		if _sfx != null:
			_sfx.play_sfx("reward_received")
	)
	EventBus.dialogue_ended.connect(func(_did: String) -> void:
		if _playback != null:
			_playback.stop_all_speech()
	)
	EventBus.pause_toggled.connect(func(is_paused: bool) -> void:
		if is_paused and _playback != null:
			_playback.pause_speech()
		elif not is_paused and _playback != null and _playback.is_paused():
			_playback.resume_speech()
	)
	EventBus.area_entered.connect(func(_area_id: String) -> void:
		if _music != null and not _music.is_playing():
			_music.play_track("bgm_welcome_village")
	)
