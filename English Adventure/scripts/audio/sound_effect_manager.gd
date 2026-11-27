class_name SoundEffectManager
extends Node
## Manages UI & Gameplay Sound Effects using a small polyphonic AudioStreamPlayer pool
## with anti-spam cooldowns so rapid button clicks never distort or overlap badly.

const POOL_SIZE := 6
const DEFAULT_COOLDOWN_MS := 45

var _assets: AudioAssetManager = null
var _pool: Array[AudioStreamPlayer] = []
var _cursor: int = 0
var _last_played_ms: Dictionary = {}
var _event_map: Dictionary = {
	"ui_click": "ui_click",
	"ui_open": "ui_open",
	"ui_close": "ui_close",
	"correct": "sfx_correct",
	"wrong": "sfx_wrong",
	"minigame_click": "ui_click",
	"minigame_correct": "sfx_correct",
	"minigame_wrong": "sfx_wrong",
	"minigame_reward": "sfx_reward_received",
	"quest_complete": "sfx_quest_complete",
	"reward_received": "sfx_reward_received",
	"area_unlocked": "sfx_area_unlocked",
	"mic_start": "sfx_mic_start",
	"mic_stop": "sfx_mic_stop"
}


func setup(assets: AudioAssetManager) -> void:
	_assets = assets
	if _pool.is_empty():
		for i in range(POOL_SIZE):
			var p := AudioStreamPlayer.new()
			p.bus = AudioSettingsManager.BUS_SFX
			p.process_mode = Node.PROCESS_MODE_ALWAYS
			add_child(p)
			_pool.append(p)


func register_stream(event_key: String, stream: AudioStream) -> void:
	if stream == null:
		return
	var p := _next_player()
	if p != null:
		p.stream = stream
		p.play()


func play_sfx(event_key: String) -> bool:
	if SettingsManager.sfx_volume <= 0.001 or SettingsManager.master_volume <= 0.001:
		return false
	if _assets == null:
		return false
	var now_ms := Time.get_ticks_msec()
	var prev_ms := int(_last_played_ms.get(event_key, -999))
	if now_ms - prev_ms < DEFAULT_COOLDOWN_MS:
		return false
	var asset_id := str(_event_map.get(event_key, event_key))
	var stream := _assets.load_stream_by_id(asset_id, true)
	if stream == null:
		return false
	var p := _next_player()
	if p == null:
		return false
	p.stream = stream
	p.play()
	_last_played_ms[event_key] = now_ms
	return true


func _next_player() -> AudioStreamPlayer:
	if _pool.is_empty():
		return null
	var p := _pool[_cursor]
	_cursor = (_cursor + 1) % _pool.size()
	return p
