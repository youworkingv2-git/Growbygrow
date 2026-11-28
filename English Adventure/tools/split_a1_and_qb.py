#!/usr/bin/env python3
"""Splits A1 curriculum and A1 dialogues into modular packs and expands Question Bank to 20 items."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    cur_p = ROOT / "data/curriculum/learning_curriculum.json"
    cur = json.loads(cur_p.read_text(encoding="utf-8"))
    w2_topics = []
    for w in cur["worlds"]:
        if w["id"] == "world_02":
            w2_topics = w.get("topics", [])
            w["topics"] = []
    cur_p.write_text(json.dumps(cur, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (ROOT / "data/curriculum/a1_sample_curriculum.json").write_text(
        json.dumps(
            {
                "worlds": [
                    {
                        "id": "world_02",
                        "level_id": "a1_basic",
                        "title_en": "Vocabulary Forest (A1 Foundation Sample)",
                        "title_vi": "Rừng Từ Vựng (Gói Nội Dung Mẫu A1)",
                        "status": "sample_playable",
                        "topics": w2_topics,
                    }
                ]
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    dlg_p = ROOT / "data/minigames/dialogue_adventures.json"
    dlg = json.loads(dlg_p.read_text(encoding="utf-8"))
    pre = [s for s in dlg["scenarios"] if s.get("cefr_level", "Pre-A1") == "Pre-A1"]
    a1 = [s for s in dlg["scenarios"] if s.get("cefr_level") == "A1"]
    dlg["scenarios"] = pre
    dlg_p.write_text(json.dumps(dlg, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (ROOT / "data/minigames/a1_dialogue_adventures.json").write_text(
        json.dumps({"world_id": "world_02", "cefr_level": "A1", "scenarios": a1}, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    qb_p = ROOT / "data/questions/question_bank.json"
    qb = json.loads(qb_p.read_text(encoding="utf-8"))
    for q in qb["questions"]:
        if q["id"] == "qb_08":
            q["correct_answer"] = "a"
    extra_qb = [
        {"id": "qb_11", "question_type": "multiple_choice", "difficulty_tier": 1, "cefr_level": "Pre-A1", "topic": "numbers", "knowledge_ids": ["word_eight"], "prompt_vi": "Số tám trong tiếng Anh viết là gì?", "options": [{"id": "a", "label_en": "eight", "is_correct": True}, {"id": "b", "label_en": "six", "is_correct": False}, {"id": "c", "label_en": "ten", "is_correct": False}], "correct_answer": "a", "explanation_vi": "Eight là số 8.", "image_path": "res://assets/learning/images/eight.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_12", "question_type": "listen_and_choose", "difficulty_tier": 1, "cefr_level": "Pre-A1", "topic": "weather", "knowledge_ids": ["word_rain"], "prompt_vi": "Nghe từ 'rain' và chọn hình đúng:", "transcript_en": "rain", "options": [{"id": "a", "label_en": "rain", "word_id": "word_rain", "is_correct": True}, {"id": "b", "label_en": "sun", "word_id": "word_sun", "is_correct": False}, {"id": "c", "label_en": "wind", "word_id": "word_wind", "is_correct": False}], "correct_answer": "a", "explanation_vi": "Rain là trời mưa.", "image_path": "res://assets/learning/images/rain.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_13", "question_type": "image_word_matching", "difficulty_tier": 2, "cefr_level": "Pre-A1", "topic": "toys", "knowledge_ids": ["word_robot"], "prompt_vi": "Hình người máy tương ứng với từ nào?", "options": [{"id": "a", "label_en": "robot", "is_correct": True}, {"id": "b", "label_en": "doll", "is_correct": False}, {"id": "c", "label_en": "kite", "is_correct": False}], "correct_answer": "a", "explanation_vi": "Robot là người máy.", "image_path": "res://assets/learning/images/robot.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_14", "question_type": "drag_and_drop", "difficulty_tier": 2, "cefr_level": "Pre-A1", "topic": "house", "knowledge_ids": ["word_door"], "prompt_vi": "Ghép các chữ cái thành từ 'Cánh cửa' (DOOR):", "tiles": ["R", "D", "O", "O"], "correct_answer": "DOOR", "explanation_vi": "DOOR gồm D-O-O-R.", "image_path": "res://assets/learning/images/door.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_15", "question_type": "fill_in_the_blank", "difficulty_tier": 3, "cefr_level": "A1", "topic": "family", "knowledge_ids": ["word_cousin", "gram_a1_07"], "prompt_vi": "Điền động từ đúng (have / has): 'My cousin ___ a green bike.'", "options": [{"id": "a", "label_en": "has", "is_correct": True}, {"id": "b", "label_en": "have", "is_correct": False}, {"id": "c", "label_en": "are", "is_correct": False}], "correct_answer": "a", "explanation_vi": "My cousin (1 người) dùng 'has'.", "image_path": "res://assets/learning/images/cousin.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_16", "question_type": "word_ordering", "difficulty_tier": 4, "cefr_level": "A1", "topic": "hobbies", "knowledge_ids": ["word_sing", "gram_a1_04"], "prompt_vi": "Sắp xếp thành câu hỏi khả năng:", "tokens": ["Can", "you", "sing", "a", "song?"], "correct_answer": "Can you sing a song?", "acceptable_answers": ["Can you sing a song?", "Can you sing a song"], "explanation_vi": "Câu hỏi bắt đầu bằng 'Can you...'.", "image_path": "res://assets/learning/images/sing.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_17", "question_type": "sentence_ordering", "difficulty_tier": 4, "cefr_level": "A1", "topic": "shopping", "knowledge_ids": ["word_buy", "word_money"], "prompt_vi": "Sắp xếp trình tự hội thoại mua đồ:", "tokens": ["How much is it?", "It is five coins.", "I would like to buy it."], "correct_answer": "How much is it? It is five coins. I would like to buy it.", "explanation_vi": "Hỏi giá -> Nghe giá -> Đồng ý mua.", "image_path": "res://assets/learning/images/buy.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_18", "question_type": "spelling", "difficulty_tier": 2, "cefr_level": "A1", "topic": "food", "knowledge_ids": ["word_salad"], "prompt_vi": "Chọn chữ cái còn thiếu cho 'Rau trộn' (SAL_D):", "options": [{"id": "a", "label_en": "A", "is_correct": True}, {"id": "b", "label_en": "E", "is_correct": False}, {"id": "c", "label_en": "O", "is_correct": False}], "correct_answer": "a", "explanation_vi": "SALAD viết là S-A-L-A-D.", "image_path": "res://assets/learning/images/salad.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_19", "question_type": "reading_comprehension", "difficulty_tier": 5, "cefr_level": "A1", "topic": "friends", "knowledge_ids": ["word_friend", "word_share"], "prompt_vi": "Đọc: 'Nam and Hoa are good friends. They share snacks and study together.' — Hai bạn làm gì?", "options": [{"id": "a", "label_vi": "Chia sẻ đồ ăn và học cùng nhau", "is_correct": True}, {"id": "b", "label_vi": "Đi bệnh viện", "is_correct": False}, {"id": "c", "label_vi": "Ngủ cả ngày", "is_correct": False}], "correct_answer": "a", "explanation_vi": "'Share snacks and study together' = chia sẻ đồ ăn và học cùng nhau.", "image_path": "res://assets/learning/images/share.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_20", "question_type": "speaking_practice", "difficulty_tier": 5, "cefr_level": "Pre-A1", "topic": "feelings", "knowledge_ids": ["word_happy", "gram_01"], "prompt_vi": "Luyện nói câu diễn đạt cảm xúc vui vẻ:", "target_text_en": "I am very happy today!", "correct_answer": "I am very happy today!", "explanation_vi": "Đọc tự nhiên, nhấn vào 'happy'.", "image_path": "res://assets/learning/images/happy.svg", "audio_path": "", "review_status": "approved"},
    ]
    qb["questions"] = qb["questions"][:10] + extra_qb
    qb_p.write_text(json.dumps(qb, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Split A1 curriculum ({len(w2_topics)} topics), A1 dialogues ({len(a1)} scenarios), QuestionBank ({len(qb['questions'])} items).")


if __name__ == "__main__":
    main()
