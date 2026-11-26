class_name MiniGameFeedback
extends RefCounted
## Mandatory Learning Feedback Generator:
## Never displays just an "X". Always displays full correct answer, Vietnamese meaning,
## simple explanation, example sentence if available, and audio replay path/transcript.


static func build_item_feedback(
	is_correct: bool,
	correct_display: String,
	meaning_vi: String,
	explanation_vi: String,
	example_en: String,
	audio_path: String,
	transcript_en: String,
	attempts: int,
	hint_used: bool
) -> Dictionary:
	var core: Dictionary = LearningEngine.assessment_engine.build_feedback(
		is_correct,
		correct_display,
		explanation_vi,
		attempts,
		hint_used,
		audio_path
	)

	if is_correct:
		var detail := correct_display
		if not meaning_vi.is_empty():
			detail += " — " + meaning_vi
		core["full_answer_line"] = detail
		if not example_en.is_empty():
			core["example_line"] = "Ví dụ: " + example_en
		core["transcript_en"] = transcript_en
		return core

	# Wrong answer: constructive guidance + full answer + meaning + replay cue
	var msg := "Chưa đúng rồi! Đáp án đúng là: %s" % correct_display
	if not meaning_vi.is_empty():
		msg += " – %s." % meaning_vi
	core["headline_vi"] = msg
	core["full_answer_line"] = correct_display + (" — " + meaning_vi if not meaning_vi.is_empty() else "")
	core["example_line"] = ("Ví dụ: " + example_en) if not example_en.is_empty() else ""
	core["transcript_en"] = transcript_en
	return core
