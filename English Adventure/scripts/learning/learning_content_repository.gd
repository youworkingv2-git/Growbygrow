class_name LearningContentRepository
extends RefCounted
## Data-driven repository loading and indexing Curriculum, Alphabet, Phonics,
## Vocabulary, Phrases, Grammar, 4-Skill activities, Question Bank, and Spaced Repetition config.

var curriculum: Dictionary = {}
var a1_unlock_criteria: Dictionary = {}
var levels_ordered: Array[Dictionary] = []
var levels_by_id: Dictionary = {}
var worlds_by_id: Dictionary = {}
var topics_by_id: Dictionary = {}
var lessons_by_id: Dictionary = {}
var lessons_ordered: Array[Dictionary] = []

var spaced_repetition_config: Dictionary = {}

var alphabet_ordered: Array[Dictionary] = []
var alphabet_by_id: Dictionary = {}

var phonics_categories: Array[String] = []
var phonics_units_ordered: Array[Dictionary] = []
var phonics_by_id: Dictionary = {}
var phonics_activities: Array[Dictionary] = []

var vocab_ordered: Array[Dictionary] = []
var vocab_by_id: Dictionary = {}

var phrases_ordered: Array[Dictionary] = []
var phrases_by_id: Dictionary = {}

var grammar_ordered: Array[Dictionary] = []
var grammar_by_id: Dictionary = {}
var model_sentences: Array[Dictionary] = []

var listening_by_id: Dictionary = {}
var listening_ordered: Array[Dictionary] = []
var reading_by_id: Dictionary = {}
var reading_ordered: Array[Dictionary] = []
var writing_by_id: Dictionary = {}
var writing_ordered: Array[Dictionary] = []
var speaking_by_id: Dictionary = {}
var speaking_ordered: Array[Dictionary] = []

var question_bank_by_id: Dictionary = {}
var question_bank_ordered: Array[Dictionary] = []


func reload_all() -> void:
	_clear_all()
	_load_spaced_repetition_config()
	_load_curriculum("res://data/curriculum/learning_curriculum.json")
	_load_curriculum_optional("res://data/curriculum/a1_sample_curriculum.json")
	_load_alphabet("res://data/alphabet/alphabet_a_z.json")
	_load_phonics("res://data/phonics/phonics_units.json")

	_load_vocabulary("res://data/vocabulary/world_01_vocab.json")
	_load_vocabulary_optional("res://data/vocabulary/world_02_a1_vocab.json")
	_load_phrases("res://data/phrases/common_phrases.json")

	_load_grammar("res://data/grammar/world_01_grammar.json")
	_load_grammar_optional("res://data/grammar/world_02_a1_grammar.json")

	_load_skill_items("res://data/listening/world_01_listening.json", listening_by_id, listening_ordered)
	_load_skill_items_optional("res://data/listening/world_02_a1_listening.json", listening_by_id, listening_ordered)
	_load_skill_items("res://data/reading/world_01_reading.json", reading_by_id, reading_ordered)
	_load_skill_items_optional("res://data/reading/world_02_a1_reading.json", reading_by_id, reading_ordered)
	_load_skill_items("res://data/writing/world_01_writing.json", writing_by_id, writing_ordered)
	_load_skill_items_optional("res://data/writing/world_02_a1_writing.json", writing_by_id, writing_ordered)
	_load_skill_items("res://data/speaking/world_01_speaking.json", speaking_by_id, speaking_ordered)
	_load_skill_items_optional("res://data/speaking/world_02_a1_speaking.json", speaking_by_id, speaking_ordered)

	_load_question_bank("res://data/questions/question_bank.json")


func register_vocabulary_pack(path: String) -> void:
	_load_vocabulary(path)


func register_curriculum_pack(path: String) -> void:
	_load_curriculum(path)


func register_phrases_pack(path: String) -> void:
	_load_phrases(path)


func _clear_all() -> void:
	curriculum.clear()
	a1_unlock_criteria.clear()
	levels_ordered.clear()
	levels_by_id.clear()
	worlds_by_id.clear()
	topics_by_id.clear()
	lessons_by_id.clear()
	lessons_ordered.clear()
	spaced_repetition_config.clear()
	alphabet_ordered.clear()
	alphabet_by_id.clear()
	phonics_categories.clear()
	phonics_units_ordered.clear()
	phonics_by_id.clear()
	phonics_activities.clear()
	vocab_ordered.clear()
	vocab_by_id.clear()
	phrases_ordered.clear()
	phrases_by_id.clear()
	grammar_ordered.clear()
	grammar_by_id.clear()
	model_sentences.clear()
	listening_by_id.clear()
	listening_ordered.clear()
	reading_by_id.clear()
	reading_ordered.clear()
	writing_by_id.clear()
	writing_ordered.clear()
	speaking_by_id.clear()
	speaking_ordered.clear()
	question_bank_by_id.clear()
	question_bank_ordered.clear()


func _is_publishable(item: Dictionary) -> bool:
	var st := str(item.get("review_status", "approved")).to_lower()
	return st == "approved" or st == "published"


func _read_json(path: String, optional: bool = false) -> Dictionary:
	if not FileAccess.file_exists(path):
		if not optional:
			AppLogger.error("LearningContentRepository", "Missing JSON file: " + path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		AppLogger.error("LearningContentRepository", "Cannot open JSON file: " + path)
		return {}
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		AppLogger.error("LearningContentRepository", "Invalid JSON dictionary in: " + path)
		return {}
	return parsed as Dictionary


func _load_spaced_repetition_config() -> void:
	spaced_repetition_config = _read_json("res://data/curriculum/spaced_repetition_config.json")


func _load_curriculum(path: String) -> void:
	var doc := _read_json(path)
	if doc.is_empty():
		return
	_ingest_curriculum_doc(doc)


func _load_curriculum_optional(path: String) -> void:
	var doc := _read_json(path, true)
	if not doc.is_empty():
		_ingest_curriculum_doc(doc)


func _ingest_curriculum_doc(doc: Dictionary) -> void:
	if curriculum.is_empty():
		curriculum = doc
	var lp: Dictionary = doc.get("learning_path", {})
	if typeof(lp.get("a1_unlock_criteria", {})) == TYPE_DICTIONARY and not (lp.get("a1_unlock_criteria", {}) as Dictionary).is_empty():
		a1_unlock_criteria = lp.get("a1_unlock_criteria", {})
	for lv_var in lp.get("levels", []):
		if typeof(lv_var) == TYPE_DICTIONARY:
			var lv: Dictionary = lv_var
			var lid := str(lv.get("id", ""))
			if not lid.is_empty() and not levels_by_id.has(lid):
				levels_by_id[lid] = lv
				levels_ordered.append(lv)

	for w_var in doc.get("worlds", []):
		if typeof(w_var) != TYPE_DICTIONARY:
			continue
		var w: Dictionary = w_var
		var wid := str(w.get("id", ""))
		if not wid.is_empty():
			worlds_by_id[wid] = w
		for t_var in w.get("topics", []):
			if typeof(t_var) != TYPE_DICTIONARY:
				continue
			var t: Dictionary = t_var
			var tid := str(t.get("id", ""))
			t["world_id"] = wid
			if not tid.is_empty():
				topics_by_id[tid] = t
			for ls_var in t.get("lessons", []):
				if typeof(ls_var) != TYPE_DICTIONARY:
					continue
				var ls: Dictionary = ls_var
				var lsid := str(ls.get("id", ""))
				ls["topic_id"] = tid
				ls["world_id"] = wid
				if not lsid.is_empty() and not lessons_by_id.has(lsid):
					lessons_by_id[lsid] = ls
					lessons_ordered.append(ls)


func _load_alphabet(path: String) -> void:
	var doc := _read_json(path)
	for item_var in doc.get("letters", []):
		if typeof(item_var) == TYPE_DICTIONARY:
			var item: Dictionary = item_var
			if not _is_publishable(item):
				continue
			var lid := str(item.get("id", ""))
			if not lid.is_empty() and not alphabet_by_id.has(lid):
				alphabet_by_id[lid] = item
				alphabet_ordered.append(item)


func _load_phonics(path: String) -> void:
	var doc := _read_json(path)
	for cat_var in doc.get("categories", []):
		var cat_s := str(cat_var)
		if not phonics_categories.has(cat_s):
			phonics_categories.append(cat_s)
	for unit_var in doc.get("units", []):
		if typeof(unit_var) == TYPE_DICTIONARY:
			var u: Dictionary = unit_var
			if not _is_publishable(u):
				continue
			var uid := str(u.get("id", ""))
			if not uid.is_empty() and not phonics_by_id.has(uid):
				phonics_by_id[uid] = u
				phonics_units_ordered.append(u)
	for act_var in doc.get("phonics_activities", []):
		if typeof(act_var) == TYPE_DICTIONARY:
			var a: Dictionary = act_var
			if _is_publishable(a):
				phonics_activities.append(a)


func _load_vocabulary(path: String) -> void:
	var doc := _read_json(path)
	_ingest_vocab_doc(doc)


func _load_vocabulary_optional(path: String) -> void:
	var doc := _read_json(path, true)
	if not doc.is_empty():
		_ingest_vocab_doc(doc)


func _ingest_vocab_doc(doc: Dictionary) -> void:
	for v_var in doc.get("vocabulary", []):
		if typeof(v_var) == TYPE_DICTIONARY:
			var v: Dictionary = v_var
			if not _is_publishable(v):
				continue
			var vid := str(v.get("id", ""))
			if not vid.is_empty() and not vocab_by_id.has(vid):
				vocab_by_id[vid] = v
				vocab_ordered.append(v)


func _load_phrases(path: String) -> void:
	var doc := _read_json(path, true)
	for p_var in doc.get("phrases", []):
		if typeof(p_var) == TYPE_DICTIONARY:
			var p: Dictionary = p_var
			if not _is_publishable(p):
				continue
			var pid := str(p.get("id", ""))
			if not pid.is_empty() and not phrases_by_id.has(pid):
				phrases_by_id[pid] = p
				phrases_ordered.append(p)


func _load_grammar(path: String) -> void:
	var doc := _read_json(path)
	_ingest_grammar_doc(doc)


func _load_grammar_optional(path: String) -> void:
	var doc := _read_json(path, true)
	if not doc.is_empty():
		_ingest_grammar_doc(doc)


func _ingest_grammar_doc(doc: Dictionary) -> void:
	for g_var in doc.get("structures", []):
		if typeof(g_var) == TYPE_DICTIONARY:
			var g: Dictionary = g_var
			if not _is_publishable(g):
				continue
			var gid := str(g.get("id", ""))
			if not gid.is_empty() and not grammar_by_id.has(gid):
				grammar_by_id[gid] = g
				grammar_ordered.append(g)
	for s_var in doc.get("model_sentences", []):
		if typeof(s_var) == TYPE_DICTIONARY:
			model_sentences.append(s_var)


func _load_skill_items(path: String, map_target: Dictionary, arr_target: Array[Dictionary]) -> void:
	var doc := _read_json(path)
	_ingest_skill_doc(doc, map_target, arr_target)


func _load_skill_items_optional(path: String, map_target: Dictionary, arr_target: Array[Dictionary]) -> void:
	var doc := _read_json(path, true)
	if not doc.is_empty():
		_ingest_skill_doc(doc, map_target, arr_target)


func _ingest_skill_doc(doc: Dictionary, map_target: Dictionary, arr_target: Array[Dictionary]) -> void:
	for it_var in doc.get("items", []):
		if typeof(it_var) == TYPE_DICTIONARY:
			var it: Dictionary = it_var
			if not _is_publishable(it):
				continue
			var iid := str(it.get("id", ""))
			if not iid.is_empty() and not map_target.has(iid):
				map_target[iid] = it
				arr_target.append(it)


func _load_question_bank(path: String) -> void:
	var doc := _read_json(path, true)
	for q_var in doc.get("questions", []):
		if typeof(q_var) == TYPE_DICTIONARY:
			var q: Dictionary = q_var
			if not _is_publishable(q):
				continue
			var qid := str(q.get("id", ""))
			if not qid.is_empty() and not question_bank_by_id.has(qid):
				question_bank_by_id[qid] = q
				question_bank_ordered.append(q)
