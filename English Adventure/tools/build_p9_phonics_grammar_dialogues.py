#!/usr/bin/env python3
"""Expands Phonics (24 units + activities), Grammar/Sentence Patterns (22 Pre-A1 + 10 A1), and Dialogues (14 scenarios)."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    # 1. Expand Phonics Units (15 -> 24) + structured phonics_activities
    ph_p = ROOT / "data/phonics/phonics_units.json"
    ph_doc = json.loads(ph_p.read_text(encoding="utf-8"))
    existing_units = ph_doc.get("units", [])[:15]
    for u in existing_units:
        u["review_status"] = "approved"

    new_units = [
        {
            "id": "ph_long_o",
            "category": "long_vowels",
            "grapheme": "o_e",
            "phoneme_ipa": "/oʊ/",
            "title_vi": "Nguyên âm dài O (/oʊ/)",
            "explanation_vi": "Khi có e câm ở cuối như trong home, nose, chữ o đọc dài là /oʊ/.",
            "examples": [
                {"word_id": "word_home", "word": "home", "segments": ["h", "oʊ", "m"]},
                {"word_id": "word_nose", "word": "nose", "segments": ["n", "oʊ", "z"]},
            ],
            "audio_status": "missing_asset",
            "audio_path": "",
            "cefr_level": "Pre-A1",
            "review_status": "approved",
        },
        {
            "id": "ph_cons_c",
            "category": "consonants",
            "grapheme": "c",
            "phoneme_ipa": "/k/",
            "title_vi": "Phụ âm C cứng (/k/)",
            "explanation_vi": "Âm /k/ bật hơi nhẹ như trong cat, cake, cow, coat.",
            "examples": [
                {"word_id": "word_cat", "word": "cat", "segments": ["k", "æ", "t"]},
                {"word_id": "word_cow", "word": "cow", "segments": ["k", "aʊ"]},
            ],
            "audio_status": "missing_asset",
            "audio_path": "",
            "cefr_level": "Pre-A1",
            "review_status": "approved",
        },
        {
            "id": "ph_cons_d",
            "category": "consonants",
            "grapheme": "d",
            "phoneme_ipa": "/d/",
            "title_vi": "Phụ âm D (/d/)",
            "explanation_vi": "Đầu lưỡi chạm nướu trên bật âm /d/ như trong dog, dad, duck, desk.",
            "examples": [
                {"word_id": "word_dog", "word": "dog", "segments": ["d", "ɑː", "ɡ"]},
                {"word_id": "word_desk", "word": "desk", "segments": ["d", "ɛ", "s", "k"]},
            ],
            "audio_status": "missing_asset",
            "audio_path": "",
            "cefr_level": "Pre-A1",
            "review_status": "approved",
        },
        {
            "id": "ph_cons_m",
            "category": "consonants",
            "grapheme": "m",
            "phoneme_ipa": "/m/",
            "title_vi": "Phụ âm mũi M (/m/)",
            "explanation_vi": "Khép hai môi và rung âm mũi /m/ như trong mom, milk, mango.",
            "examples": [
                {"word_id": "word_mom", "word": "mom", "segments": ["m", "ɑː", "m"]},
                {"word_id": "word_milk", "word": "milk", "segments": ["m", "ɪ", "l", "k"]},
            ],
            "audio_status": "missing_asset",
            "audio_path": "",
            "cefr_level": "Pre-A1",
            "review_status": "approved",
        },
        {
            "id": "ph_cons_s",
            "category": "consonants",
            "grapheme": "s",
            "phoneme_ipa": "/s/",
            "title_vi": "Phụ âm xì S (/s/)",
            "explanation_vi": "Đẩy luồng hơi nhẹ qua răng như tiếng gió /s/ trong sun, six, sad.",
            "examples": [
                {"word_id": "word_sun", "word": "sun", "segments": ["s", "ʌ", "n"]},
                {"word_id": "word_six", "word": "six", "segments": ["s", "ɪ", "k", "s"]},
            ],
            "audio_status": "missing_asset",
            "audio_path": "",
            "cefr_level": "Pre-A1",
            "review_status": "approved",
        },
        {
            "id": "ph_cons_t",
            "category": "consonants",
            "grapheme": "t",
            "phoneme_ipa": "/t/",
            "title_vi": "Phụ âm T (/t/)",
            "explanation_vi": "Bật hơi nhẹ âm /t/ ở đầu hoặc cuối từ như ten, table, cat.",
            "examples": [
                {"word_id": "word_ten", "word": "ten", "segments": ["t", "ɛ", "n"]},
                {"word_id": "word_table", "word": "table", "segments": ["t", "eɪ", "b", "ə", "l"]},
            ],
            "audio_status": "missing_asset",
            "audio_path": "",
            "cefr_level": "Pre-A1",
            "review_status": "approved",
        },
        {
            "id": "ph_digraph_wh",
            "category": "consonant_digraphs",
            "grapheme": "wh",
            "phoneme_ipa": "/w/",
            "title_vi": "Tổ hợp WH (/w/)",
            "explanation_vi": "Tổ hợp 'wh' thường đọc là /w/ trong white, what, where.",
            "examples": [
                {"word_id": "word_white", "word": "white", "segments": ["w", "aɪ", "t"]},
            ],
            "audio_status": "missing_asset",
            "audio_path": "",
            "cefr_level": "Pre-A1",
            "review_status": "approved",
        },
        {
            "id": "ph_team_ai",
            "category": "vowel_teams",
            "grapheme": "ai",
            "phoneme_ipa": "/eɪ/",
            "title_vi": "Cặp nguyên âm AI (/eɪ/)",
            "explanation_vi": "Cặp chữ 'ai' tạo âm /eɪ/ như trong rain (mưa).",
            "examples": [
                {"word_id": "word_rain", "word": "rain", "segments": ["r", "eɪ", "n"]},
            ],
            "audio_status": "missing_asset",
            "audio_path": "",
            "cefr_level": "Pre-A1",
            "review_status": "approved",
        },
        {
            "id": "ph_pattern_an",
            "category": "common_sound_patterns",
            "grapheme": "-an",
            "phoneme_ipa": "/æn/",
            "title_vi": "Vần -AN (/æn/)",
            "explanation_vi": "Ghép phụ âm đầu với vần -an để đọc nhanh từ van, man, fan.",
            "examples": [
                {"word_id": "word_van", "word": "van", "segments": ["v", "æn"]},
            ],
            "audio_status": "missing_asset",
            "audio_path": "",
            "cefr_level": "Pre-A1",
            "review_status": "approved",
        },
    ]

    ph_doc["units"] = existing_units + new_units
    ph_doc["phonics_activities"] = [
        {"id": "pha_01", "type": "beginning_sound", "prompt_vi": "Nhìn hình quả táo (apple) và chọn âm đầu đúng:", "word_id": "word_apple", "target_sound": "/æ/", "options": ["/æ/", "/b/", "/k/"], "correct_answer": "/æ/", "review_status": "approved"},
        {"id": "pha_02", "type": "beginning_sound", "prompt_vi": "Nhìn hình mặt trời (sun) và chọn chữ cái đầu đúng:", "word_id": "word_sun", "target_sound": "/s/", "options": ["S", "B", "M"], "correct_answer": "S", "review_status": "approved"},
        {"id": "pha_03", "type": "ending_sound", "prompt_vi": "Từ 'cat' kết thúc bằng âm nào?", "word_id": "word_cat", "target_sound": "/t/", "options": ["/t/", "/k/", "/æ/"], "correct_answer": "/t/", "review_status": "approved"},
        {"id": "pha_04", "type": "blending", "prompt_vi": "Ghép 3 âm /b/ - /æ/ - /ɡ/ thành từ tiếng Anh nào?", "word_id": "word_bag", "target_sound": "bag", "options": ["bag", "bed", "box"], "correct_answer": "bag", "review_status": "approved"},
        {"id": "pha_05", "type": "minimal_pair", "prompt_vi": "Phân biệt cặp âm gần nhau: Từ nào có âm đầu /p/ (không phải /b/)?", "word_id": "word_pen", "target_sound": "/p/", "options": ["pen", "bag", "ball"], "correct_answer": "pen", "review_status": "approved"},
        {"id": "pha_06", "type": "digraph_match", "prompt_vi": "Từ 'ship' (con tàu) bắt đầu bằng tổ hợp chữ cái nào?", "word_id": "word_ship", "target_sound": "sh", "options": ["sh", "ch", "th"], "correct_answer": "sh", "review_status": "approved"},
    ]
    ph_p.write_text(json.dumps(ph_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 2. Expand world_01_grammar.json (15 -> 22 Pre-A1 structures, 12 -> 26 model sentences)
    g1_p = ROOT / "data/grammar/world_01_grammar.json"
    g1_doc = json.loads(g1_p.read_text(encoding="utf-8"))
    existing_struct = g1_doc.get("structures", [])[:15]
    for s in existing_struct:
        s["review_status"] = "approved"

    new_pre_a1_struct = [
        {
            "id": "gram_16",
            "world_id": "world_01",
            "structure": "My name is ...",
            "explanation_vi": "Dùng để giới thiệu tên của mình.",
            "example_sentences": [
                {"en": "My name is Leo.", "vi": "Tên mình là Leo.", "audio_status": "missing_asset", "audio_path": ""},
                {"en": "My name is Buddy.", "vi": "Tên mình là Buddy.", "audio_status": "missing_asset", "audio_path": ""},
            ],
            "difficulty": 1,
            "cefr_level": "Pre-A1",
            "common_mistakes_vi": ["Không thiếu 'is': nói 'My name is Leo', không nói 'My name Leo'."],
            "substitution_slots": [{"slot": "...", "options": ["Leo", "Mia", "Buddy"]}],
            "practice_activities": ["sentence_builder", "speaking_hero"],
            "review_status": "approved",
        },
        {
            "id": "gram_17",
            "world_id": "world_01",
            "structure": "I see ...",
            "explanation_vi": "Dùng để nói về những gì mình nhìn thấy xung quanh.",
            "example_sentences": [
                {"en": "I see a red bird.", "vi": "Mình thấy một con chim màu đỏ.", "audio_status": "missing_asset", "audio_path": ""},
                {"en": "I see two green frogs.", "vi": "Mình thấy hai con ếch xanh.", "audio_status": "missing_asset", "audio_path": ""},
            ],
            "difficulty": 1,
            "cefr_level": "Pre-A1",
            "common_mistakes_vi": ["Nhớ thêm 'a/an' trước danh từ số ít (I see a cat)."],
            "substitution_slots": [{"slot": "...", "options": ["a cat", "a star", "the sun"]}],
            "practice_activities": ["sentence_builder", "listen_and_find"],
            "review_status": "approved",
        },
        {
            "id": "gram_18",
            "world_id": "world_01",
            "structure": "What color is it?",
            "explanation_vi": "Dùng để hỏi màu sắc của một đồ vật hoặc con vật.",
            "example_sentences": [
                {"en": "What color is it? It is blue.", "vi": "Nó màu gì? Nó màu xanh dương.", "audio_status": "missing_asset", "audio_path": ""},
                {"en": "What color is the sun? It is yellow.", "vi": "Mặt trời màu gì? Nó màu vàng.", "audio_status": "missing_asset", "audio_path": ""},
            ],
            "difficulty": 1,
            "cefr_level": "Pre-A1",
            "common_mistakes_vi": ["Trả lời bằng 'It is + màu sắc' (It is red)."],
            "substitution_slots": [{"slot": "...", "options": ["red", "blue", "yellow", "green"]}],
            "practice_activities": ["dialogue_adventure", "sentence_builder"],
            "review_status": "approved",
        },
        {
            "id": "gram_19",
            "world_id": "world_01",
            "structure": "How many ...?",
            "explanation_vi": "Dùng để hỏi số lượng (bao nhiêu...) với danh từ đếm được số nhiều.",
            "example_sentences": [
                {"en": "How many apples? Three apples.", "vi": "Có bao nhiêu quả táo? Ba quả táo.", "audio_status": "missing_asset", "audio_path": ""},
                {"en": "How many stars do you see? Five stars.", "vi": "Bạn thấy bao nhiêu ngôi sao? Năm ngôi sao.", "audio_status": "missing_asset", "audio_path": ""},
            ],
            "difficulty": 2,
            "cefr_level": "Pre-A1",
            "common_mistakes_vi": ["Danh từ sau 'How many' thêm 's' ở cuối: How many books?"],
            "substitution_slots": [{"slot": "...", "options": ["apples", "books", "stars"]}],
            "practice_activities": ["dialogue_adventure", "sentence_builder"],
            "review_status": "approved",
        },
        {
            "id": "gram_20",
            "world_id": "world_01",
            "structure": "A / An + noun",
            "explanation_vi": "Dùng 'an' trước từ bắt đầu bằng nguyên âm (a, e, i, o, u), dùng 'a' trước phụ âm.",
            "example_sentences": [
                {"en": "an apple, an egg, an orange", "vi": "một quả táo, một quả trứng, một quả cam", "audio_status": "missing_asset", "audio_path": ""},
                {"en": "a book, a cat, a banana", "vi": "một quyển sách, một con mèo, một quả chuối", "audio_status": "missing_asset", "audio_path": ""},
            ],
            "difficulty": 1,
            "cefr_level": "Pre-A1",
            "common_mistakes_vi": ["Không dùng 'a apple' — phải nói 'an apple' để dễ nối âm."],
            "substitution_slots": [{"slot": "...", "options": ["a ball", "an apple", "an egg", "a pen"]}],
            "practice_activities": ["reading", "writing"],
            "review_status": "approved",
        },
        {
            "id": "gram_21",
            "world_id": "world_01",
            "structure": "Singular & Plural (-s)",
            "explanation_vi": "Từ 2 vật trở lên thường thêm 's' vào cuối danh từ (1 book -> 2 books).",
            "example_sentences": [
                {"en": "one cat -> two cats", "vi": "một con mèo -> hai con mèo", "audio_status": "missing_asset", "audio_path": ""},
                {"en": "one star -> six stars", "vi": "một ngôi sao -> sáu ngôi sao", "audio_status": "missing_asset", "audio_path": ""},
            ],
            "difficulty": 2,
            "cefr_level": "Pre-A1",
            "common_mistakes_vi": ["Đừng quên chữ 's' khi có số từ 2 trở lên: 'three cats', không nói 'three cat'."],
            "substitution_slots": [{"slot": "...", "options": ["two cats", "three books", "four apples"]}],
            "practice_activities": ["writing", "sentence_builder"],
            "review_status": "approved",
        },
        {
            "id": "gram_22",
            "world_id": "world_01",
            "structure": "in / on / under",
            "explanation_vi": "Giới từ chỉ vị trí cơ bản: in (bên trong), on (ở trên), under (ở dưới).",
            "example_sentences": [
                {"en": "The pen is in the bag.", "vi": "Cây bút ở trong cặp sách.", "audio_status": "missing_asset", "audio_path": ""},
                {"en": "The apple is on the table.", "vi": "Quả táo ở trên bàn.", "audio_status": "missing_asset", "audio_path": ""},
            ],
            "difficulty": 2,
            "cefr_level": "Pre-A1",
            "common_mistakes_vi": ["Phân biệt 'in' (bên trong hộp/cặp) và 'on' (nằm trên bề mặt)."],
            "substitution_slots": [{"slot": "...", "options": ["in the bag", "on the table", "under the chair"]}],
            "practice_activities": ["reading", "sentence_builder"],
            "review_status": "approved",
        },
    ]

    existing_models = g1_doc.get("model_sentences", [])[:12]
    new_models = [
        {"id": "sent_13", "en": "My name is Leo.", "vi": "Tên mình là Leo.", "grammar_id": "gram_16", "audio_status": "missing_asset"},
        {"id": "sent_14", "en": "I see a white rabbit.", "vi": "Mình thấy một con thỏ trắng.", "grammar_id": "gram_17", "audio_status": "missing_asset"},
        {"id": "sent_15", "en": "What color is it? It is green.", "vi": "Nó màu gì? Nó màu xanh lá.", "grammar_id": "gram_18", "audio_status": "missing_asset"},
        {"id": "sent_16", "en": "How many stars? Seven stars.", "vi": "Có bao nhiêu ngôi sao? Bảy ngôi sao.", "grammar_id": "gram_19", "audio_status": "missing_asset"},
        {"id": "sent_17", "en": "I have an orange and a pear.", "vi": "Mình có một quả cam và một quả lê.", "grammar_id": "gram_20", "audio_status": "missing_asset"},
        {"id": "sent_18", "en": "Three cats play in the park.", "vi": "Ba con mèo chơi ở công viên.", "grammar_id": "gram_21", "audio_status": "missing_asset"},
        {"id": "sent_19", "en": "The book is on the desk.", "vi": "Quyển sách ở trên bàn học.", "grammar_id": "gram_22", "audio_status": "missing_asset"},
        {"id": "sent_20", "en": "Good morning! Nice to meet you.", "vi": "Chào buổi sáng! Rất vui được gặp bạn.", "grammar_id": "gram_01", "audio_status": "missing_asset"},
        {"id": "sent_21", "en": "I can ride a bike.", "vi": "Mình biết đi xe đạp.", "grammar_id": "gram_08", "audio_status": "missing_asset"},
        {"id": "sent_22", "en": "I want some water, please.", "vi": "Làm ơn cho mình một ít nước.", "grammar_id": "gram_09", "audio_status": "missing_asset"},
        {"id": "sent_23", "en": "This is my grandma.", "vi": "Đây là bà của mình.", "grammar_id": "gram_03", "audio_status": "missing_asset"},
        {"id": "sent_24", "en": "Touch your head and nose.", "vi": "Hãy chạm vào đầu và mũi của bạn.", "grammar_id": "gram_10", "audio_status": "missing_asset"},
        {"id": "sent_25", "en": "It is a sunny day.", "vi": "Hôm nay là một ngày nắng đẹp.", "grammar_id": "gram_05", "audio_status": "missing_asset"},
        {"id": "sent_26", "en": "The frog is under the chair.", "vi": "Con ếch ở dưới cái ghế.", "grammar_id": "gram_22", "audio_status": "missing_asset"},
    ]
    g1_doc["structures"] = existing_struct + new_pre_a1_struct
    g1_doc["model_sentences"] = existing_models + new_models
    g1_p.write_text(json.dumps(g1_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 3. Create world_02_a1_grammar.json (10 A1 structures + 12 A1 model sentences)
    g2_doc = {
        "world_id": "world_02",
        "cefr_level": "A1",
        "structures": [
            {
                "id": "gram_a1_01",
                "world_id": "world_02",
                "structure": "I usually ...",
                "explanation_vi": "Thì hiện tại đơn (Present Simple) nói về thói quen hằng ngày với 'usually' (thường xuyên).",
                "example_sentences": [
                    {"en": "I usually have breakfast at seven.", "vi": "Mình thường ăn sáng lúc bảy giờ.", "audio_status": "missing_asset", "audio_path": ""},
                    {"en": "I usually study English after school.", "vi": "Mình thường học tiếng Anh sau giờ học.", "audio_status": "missing_asset", "audio_path": ""},
                ],
                "difficulty": 2,
                "cefr_level": "A1",
                "common_mistakes_vi": ["Đặt 'usually' trước động từ thường: 'I usually walk' (không nói 'I walk usually')."],
                "substitution_slots": [{"slot": "...", "options": ["read books", "brush my teeth", "swim on Sunday"]}],
                "practice_activities": ["sentence_builder", "writing"],
                "review_status": "approved",
            },
            {
                "id": "gram_a1_02",
                "world_id": "world_02",
                "structure": "I go to ... at ...",
                "explanation_vi": "Dùng 'go to + địa điểm' kết hợp 'at + giờ' để kể lịch trình hằng ngày.",
                "example_sentences": [
                    {"en": "I go to school at seven o'clock.", "vi": "Mình đi học lúc bảy giờ.", "audio_status": "missing_asset", "audio_path": ""},
                    {"en": "I go to the library at three o'clock.", "vi": "Mình đến thư viện lúc ba giờ.", "audio_status": "missing_asset", "audio_path": ""},
                ],
                "difficulty": 2,
                "cefr_level": "A1",
                "common_mistakes_vi": ["Dùng 'at' trước giờ cụ thể, nhưng nói 'go home' không cần 'to'."],
                "substitution_slots": [{"slot": "...", "options": ["school at seven", "the park at four", "bed at nine"]}],
                "practice_activities": ["sentence_builder"],
                "review_status": "approved",
            },
            {
                "id": "gram_a1_03",
                "world_id": "world_02",
                "structure": "I would like ...",
                "explanation_vi": "Cách nói lịch sự khi muốn gọi món ăn hoặc xin mua đồ vật.",
                "example_sentences": [
                    {"en": "I would like some chicken soup, please.", "vi": "Làm ơn cho mình một ít súp gà.", "audio_status": "missing_asset", "audio_path": ""},
                    {"en": "I would like a glass of orange juice.", "vi": "Mình muốn một ly nước cam.", "audio_status": "missing_asset", "audio_path": ""},
                ],
                "difficulty": 2,
                "cefr_level": "A1",
                "common_mistakes_vi": ["Lịch sự hơn 'I want' khi ở cửa hàng hay nhà hàng."],
                "substitution_slots": [{"slot": "...", "options": ["some noodles", "fruit salad", "a blue pencil"]}],
                "practice_activities": ["dialogue_adventure", "sentence_builder"],
                "review_status": "approved",
            },
            {
                "id": "gram_a1_04",
                "world_id": "world_02",
                "structure": "Can you ...?",
                "explanation_vi": "Dùng để hỏi khả năng hoặc nhờ ai đó làm giúp việc gì một cách thân thiện.",
                "example_sentences": [
                    {"en": "Can you swim? Yes, I can.", "vi": "Bạn biết bơi không? Có, mình biết.", "audio_status": "missing_asset", "audio_path": ""},
                    {"en": "Can you help me draw a star?", "vi": "Bạn giúp mình vẽ ngôi sao được không?", "audio_status": "missing_asset", "audio_path": ""},
                ],
                "difficulty": 2,
                "cefr_level": "A1",
                "common_mistakes_vi": ["Sau 'Can you' dùng động từ nguyên mẫu (Can you sing?, không thêm 'to')."],
                "substitution_slots": [{"slot": "...", "options": ["sing", "swim", "dance", "draw"]}],
                "practice_activities": ["dialogue_adventure", "speaking_hero"],
                "review_status": "approved",
            },
            {
                "id": "gram_a1_05",
                "world_id": "world_02",
                "structure": "There is ... / There are ...",
                "explanation_vi": "'There is' dùng với 1 vật; 'There are' dùng với từ 2 vật trở lên.",
                "example_sentences": [
                    {"en": "There is a museum on this street.", "vi": "Có một bảo tàng trên con phố này.", "audio_status": "missing_asset", "audio_path": ""},
                    {"en": "There are many books in the library.", "vi": "Có nhiều sách ở trong thư viện.", "audio_status": "missing_asset", "audio_path": ""},
                ],
                "difficulty": 2,
                "cefr_level": "A1",
                "common_mistakes_vi": ["Số nhiều phải dùng 'There are', không dùng 'There is many books'."],
                "substitution_slots": [{"slot": "...", "options": ["a big park", "two markets", "five birds"]}],
                "practice_activities": ["reading", "writing"],
                "review_status": "approved",
            },
            {
                "id": "gram_a1_06",
                "world_id": "world_02",
                "structure": "What are you doing?",
                "explanation_vi": "Thì hiện tại tiếp diễn (Present Continuous) hỏi/nói việc đang diễn ra ngay lúc này.",
                "example_sentences": [
                    {"en": "What are you doing? I am reading.", "vi": "Bạn đang làm gì thế? Mình đang đọc sách.", "audio_status": "missing_asset", "audio_path": ""},
                    {"en": "She is drawing a funny cat.", "vi": "Bạn ấy đang vẽ một chú mèo ngộ nghĩnh.", "audio_status": "missing_asset", "audio_path": ""},
                ],
                "difficulty": 3,
                "cefr_level": "A1",
                "common_mistakes_vi": ["Nhớ đi kèm động từ to be + V-ing: 'I am reading', không nói 'I reading'."],
                "substitution_slots": [{"slot": "...", "options": ["reading a book", "drawing a bird", "cleaning my desk"]}],
                "practice_activities": ["dialogue_adventure", "sentence_builder"],
                "review_status": "approved",
            },
            {
                "id": "gram_a1_07",
                "world_id": "world_02",
                "structure": "Have / Has",
                "explanation_vi": "I/You/We/They dùng 'have'; He/She/It hoặc 1 người dùng 'has'.",
                "example_sentences": [
                    {"en": "I have a kind friend.", "vi": "Mình có một người bạn tốt bụng.", "audio_status": "missing_asset", "audio_path": ""},
                    {"en": "My cousin has a new bike.", "vi": "Anh họ mình có một chiếc xe đạp mới.", "audio_status": "missing_asset", "audio_path": ""},
                ],
                "difficulty": 2,
                "cefr_level": "A1",
                "common_mistakes_vi": ["Với He/She (1 người) nhớ đổi 'have' thành 'has'."],
                "substitution_slots": [{"slot": "...", "options": ["a new book", "two cousins", "a green kite"]}],
                "practice_activities": ["reading", "writing"],
                "review_status": "approved",
            },
            {
                "id": "gram_a1_08",
                "world_id": "world_02",
                "structure": "my / your / his / her",
                "explanation_vi": "Tính từ sở hữu đứng trước danh từ để chỉ đồ của ai (của tôi/bạn/anh ấy/cô ấy).",
                "example_sentences": [
                    {"en": "This is my homework.", "vi": "Đây là bài tập về nhà của mình.", "audio_status": "missing_asset", "audio_path": ""},
                    {"en": "Her aunt works at the hospital.", "vi": "Dì của cô ấy làm việc ở bệnh viện.", "audio_status": "missing_asset", "audio_path": ""},
                ],
                "difficulty": 2,
                "cefr_level": "A1",
                "common_mistakes_vi": ["Dùng 'his' cho bạn nam và 'her' cho bạn nữ."],
                "substitution_slots": [{"slot": "...", "options": ["my friend", "his uncle", "her bag"]}],
                "practice_activities": ["reading", "sentence_builder"],
                "review_status": "approved",
            },
            {
                "id": "gram_a1_09",
                "world_id": "world_02",
                "structure": "Where do you live?",
                "explanation_vi": "Hỏi và trả lời nơi ở hoặc thông tin cơ bản về bản thân.",
                "example_sentences": [
                    {"en": "Where do you live? I live near the park.", "vi": "Bạn sống ở đâu? Mình sống gần công viên.", "audio_status": "missing_asset", "audio_path": ""},
                    {"en": "I live on Green Street.", "vi": "Mình sống ở phố Green.", "audio_status": "missing_asset", "audio_path": ""},
                ],
                "difficulty": 2,
                "cefr_level": "A1",
                "common_mistakes_vi": ["Dùng 'on + tên đường', 'near + địa điểm' (near the school)."],
                "substitution_slots": [{"slot": "...", "options": ["near the school", "on Green Street", "in a small house"]}],
                "practice_activities": ["dialogue_adventure", "speaking_hero"],
                "review_status": "approved",
            },
            {
                "id": "gram_a1_10",
                "world_id": "world_02",
                "structure": "Some / Any",
                "explanation_vi": "Dùng 'some' trong câu khẳng định hoặc lời mời; dùng 'any' trong câu hỏi hoặc phủ định.",
                "example_sentences": [
                    {"en": "I have some salad and noodles.", "vi": "Mình có một ít salad và mì.", "audio_status": "missing_asset", "audio_path": ""},
                    {"en": "Do you have any fresh juice?", "vi": "Bạn có chút nước ép tươi nào không?", "audio_status": "missing_asset", "audio_path": ""},
                ],
                "difficulty": 3,
                "cefr_level": "A1",
                "common_mistakes_vi": ["Câu hỏi thông thường dùng 'any': 'Do you have any money?'."],
                "substitution_slots": [{"slot": "...", "options": ["some soup", "some fruit", "any apples"]}],
                "practice_activities": ["reading", "writing"],
                "review_status": "approved",
            },
        ],
        "model_sentences": [
            {"id": "sent_a1_01", "en": "I usually brush my teeth at six.", "vi": "Mình thường đánh răng lúc sáu giờ.", "grammar_id": "gram_a1_01", "audio_status": "missing_asset"},
            {"id": "sent_a1_02", "en": "I go to school at seven o'clock.", "vi": "Mình đi học lúc bảy giờ.", "grammar_id": "gram_a1_02", "audio_status": "missing_asset"},
            {"id": "sent_a1_03", "en": "I would like some chicken soup.", "vi": "Mình muốn một ít súp gà.", "grammar_id": "gram_a1_03", "audio_status": "missing_asset"},
            {"id": "sent_a1_04", "en": "Can you sing and dance?", "vi": "Bạn có biết hát và nhảy không?", "grammar_id": "gram_a1_04", "audio_status": "missing_asset"},
            {"id": "sent_a1_05", "en": "There is a museum on Green Street.", "vi": "Có một bảo tàng trên phố Green.", "grammar_id": "gram_a1_05", "audio_status": "missing_asset"},
            {"id": "sent_a1_06", "en": "There are ten books in the library.", "vi": "Có mười quyển sách trong thư viện.", "grammar_id": "gram_a1_05", "audio_status": "missing_asset"},
            {"id": "sent_a1_07", "en": "What are you doing? I am drawing.", "vi": "Bạn đang làm gì thế? Mình đang vẽ tranh.", "grammar_id": "gram_a1_06", "audio_status": "missing_asset"},
            {"id": "sent_a1_08", "en": "My cousin has a funny robot.", "vi": "Anh họ mình có một con người máy ngộ nghĩnh.", "grammar_id": "gram_a1_07", "audio_status": "missing_asset"},
            {"id": "sent_a1_09", "en": "Her parents are very kind.", "vi": "Bố mẹ của bạn ấy rất tốt bụng.", "grammar_id": "gram_a1_08", "audio_status": "missing_asset"},
            {"id": "sent_a1_10", "en": "Where do you live? I live near the park.", "vi": "Bạn sống ở đâu? Mình sống gần công viên.", "grammar_id": "gram_a1_09", "audio_status": "missing_asset"},
            {"id": "sent_a1_11", "en": "We share some fruit salad at school.", "vi": "Chúng mình chia sẻ ít salad trái cây ở trường.", "grammar_id": "gram_a1_10", "audio_status": "missing_asset"},
            {"id": "sent_a1_12", "en": "How much is this science book?", "vi": "Quyển sách khoa học này giá bao nhiêu?", "grammar_id": "gram_a1_03", "audio_status": "missing_asset"},
        ],
    }
    (ROOT / "data/grammar/world_02_a1_grammar.json").write_text(
        json.dumps(g2_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    # 4. Expand dialogue_adventures.json (8 -> 14 scenarios: 10 Pre-A1 + 4 A1)
    dlg_p = ROOT / "data/minigames/dialogue_adventures.json"
    dlg_doc = json.loads(dlg_p.read_text(encoding="utf-8"))
    existing_sc = dlg_doc.get("scenarios", [])[:8]
    for s in existing_sc:
        s["cefr_level"] = "Pre-A1"
        s["review_status"] = "approved"

    new_sc = [
        {
            "id": "dlg_adv_09_colors_numbers",
            "topic": "Colors & Numbers",
            "title_vi": "Đếm sao & Chọn màu sắc",
            "title_en": "Counting Stars & Colors",
            "npc_id": "lily",
            "npc_name_vi": "Lily",
            "cefr_level": "Pre-A1",
            "review_status": "approved",
            "linked_grammar_id": "gram_18",
            "linked_vocab_ids": ["word_star", "word_yellow", "word_seven"],
            "turns": [
                {
                    "npc_line_en": "Look at the sky! How many stars do you see?",
                    "npc_line_vi": "Nhìn bầu trời kìa! Bạn thấy bao nhiêu ngôi sao?",
                    "options": [
                        {"text_en": "I see seven yellow stars!", "text_vi": "Mình thấy bảy ngôi sao màu vàng!", "is_correct": True, "feedback_vi": "Tuyệt vời! Con đã kết hợp đúng số đếm và màu sắc."},
                        {"text_en": "I eat an apple.", "text_vi": "Mình ăn một quả táo.", "is_correct": False, "feedback_vi": "Câu này nói về ăn táo, chưa trả lời câu hỏi 'How many stars?'."},
                        {"text_en": "Good night!", "text_vi": "Chúc ngủ ngon!", "is_correct": False, "feedback_vi": "Câu này dùng khi chúc ngủ ngon nhé."},
                    ],
                },
                {
                    "npc_line_en": "What color is your favorite star?",
                    "npc_line_vi": "Ngôi sao yêu thích của bạn màu gì?",
                    "options": [
                        {"text_en": "It is yellow and bright.", "text_vi": "Nó màu vàng và sáng lấp lánh.", "is_correct": True, "feedback_vi": "Chính xác! 'It is + màu sắc' rất tự nhiên."},
                        {"text_en": "My name is Lily.", "text_vi": "Tên mình là Lily.", "is_correct": False, "feedback_vi": "Đây là câu giới thiệu tên, chưa trả lời về màu sắc."},
                        {"text_en": "It is a desk.", "text_vi": "Nó là cái bàn.", "is_correct": False, "feedback_vi": "Câu hỏi 'What color' cần trả lời bằng tên màu sắc."},
                    ],
                },
            ],
        },
        {
            "id": "dlg_adv_10_can_i_have",
            "topic": "Polite Requests",
            "title_vi": "Xin phép & Nhờ giúp đỡ lịch sự",
            "title_en": "Can I Have Some Water?",
            "npc_id": "rocky",
            "npc_name_vi": "Rocky",
            "cefr_level": "Pre-A1",
            "review_status": "approved",
            "linked_grammar_id": "gram_09",
            "linked_vocab_ids": ["word_water", "word_please", "word_apple"],
            "turns": [
                {
                    "npc_line_en": "You look tired after walking! What do you want?",
                    "npc_line_vi": "Sau khi đi bộ trông bạn hơi mệt đấy! Bạn muốn gì nào?",
                    "options": [
                        {"text_en": "Can I have some water, please?", "text_vi": "Làm ơn cho mình xin ít nước được không?", "is_correct": True, "feedback_vi": "Rất lịch sự và tự nhiên với 'please'!"},
                        {"text_en": "Where is the lion?", "text_vi": "Con sư tử ở đâu?", "is_correct": False, "feedback_vi": "Câu này hỏi vị trí sư tử, chưa trả lời về thứ bạn muốn."},
                        {"text_en": "It is a square.", "text_vi": "Nó là hình vuông.", "is_correct": False, "feedback_vi": "Câu này nói về hình dạng rồi."},
                    ],
                },
                {
                    "npc_line_en": "Here you are! Have a fresh red apple too.",
                    "npc_line_vi": "Của bạn đây! Ăn thêm một quả táo đỏ tươi nữa nhé.",
                    "options": [
                        {"text_en": "Thank you very much!", "text_vi": "Cảm ơn bạn rất nhiều!", "is_correct": True, "feedback_vi": "Tuyệt lắm! Luôn nói 'Thank you' khi nhận đồ nhé."},
                        {"text_en": "I am sorry.", "text_vi": "Mình xin lỗi.", "is_correct": False, "feedback_vi": "Khi nhận quà từ bạn, mình nói 'Thank you', không phải 'I am sorry'."},
                        {"text_en": "Close the door.", "text_vi": "Đóng cửa lại.", "is_correct": False, "feedback_vi": "Câu này không phù hợp khi cảm ơn bạn."},
                    ],
                },
            ],
        },
        # 4 A1 Sample Dialogues
        {
            "id": "dlg_adv_11_a1_new_friend",
            "topic": "Friends",
            "title_vi": "[A1] Làm quen bạn mới ở trường",
            "title_en": "Meeting a New Friend",
            "npc_id": "lily",
            "npc_name_vi": "Lily",
            "cefr_level": "A1",
            "review_status": "approved",
            "linked_grammar_id": "gram_a1_09",
            "linked_vocab_ids": ["word_friend", "word_kind", "word_street"],
            "turns": [
                {
                    "npc_line_en": "Hi! I am Lily. Where do you live?",
                    "npc_line_vi": "Chào bạn! Mình là Lily. Bạn sống ở đâu?",
                    "options": [
                        {"text_en": "I live near the park on Green Street.", "text_vi": "Mình sống gần công viên trên phố Green.", "is_correct": True, "feedback_vi": "Chính xác! Trả lời đầy đủ nơi ở."},
                        {"text_en": "I have two eyes.", "text_vi": "Mình có hai mắt.", "is_correct": False, "feedback_vi": "Câu này nói về bộ phận cơ thể, chưa trả lời 'Where do you live?'."},
                        {"text_en": "It is Tuesday.", "text_vi": "Hôm nay là thứ Ba.", "is_correct": False, "feedback_vi": "Câu này nói về thứ trong tuần."},
                    ],
                },
                {
                    "npc_line_en": "Oh, that is close! Would you like to be friends and share books?",
                    "npc_line_vi": "Ồ, gần đấy! Chúng mình làm bạn và chia sẻ sách cùng nhau nhé?",
                    "options": [
                        {"text_en": "Yes! You are very kind. Let us go to the library.", "text_vi": "Có chứ! Bạn thật tốt bụng. Cùng đến thư viện nào.", "is_correct": True, "feedback_vi": "Tuyệt vời! Phản hồi rất thân thiện và tự nhiên."},
                        {"text_en": "The price is cheap.", "text_vi": "Giá rất rẻ.", "is_correct": False, "feedback_vi": "Câu này dùng khi mua sắm."},
                        {"text_en": "I brush my teeth.", "text_vi": "Mình đánh răng.", "is_correct": False, "feedback_vi": "Câu này không khớp ngữ cảnh kết bạn."},
                    ],
                },
            ],
        },
        {
            "id": "dlg_adv_12_a1_hobbies",
            "topic": "Hobbies",
            "title_vi": "[A1] Trò chuyện về sở thích",
            "title_en": "Talking About Hobbies",
            "npc_id": "professor_owl",
            "npc_name_vi": "Giáo sư Cú",
            "cefr_level": "A1",
            "review_status": "approved",
            "linked_grammar_id": "gram_a1_04",
            "linked_vocab_ids": ["word_draw", "word_music", "word_swim"],
            "turns": [
                {
                    "npc_line_en": "What do you usually do on Sunday? Can you draw or swim?",
                    "npc_line_vi": "Chủ nhật bạn thường làm gì? Bạn biết vẽ hay bơi không?",
                    "options": [
                        {"text_en": "I usually draw pictures and listen to music.", "text_vi": "Mình thường vẽ tranh và nghe nhạc.", "is_correct": True, "feedback_vi": "Rất hay! Dùng đúng trạng từ 'usually'."},
                        {"text_en": "I go to the hospital.", "text_vi": "Mình đến bệnh viện.", "is_correct": False, "feedback_vi": "Đây không phải câu trả lời về sở thích cuối tuần."},
                        {"text_en": "There is a rice.", "text_vi": "Có một cơm.", "is_correct": False, "feedback_vi": "Câu sai ngữ pháp và không liên quan chủ đề sở thích."},
                    ],
                },
                {
                    "npc_line_en": "Wonderful! What are you drawing right now?",
                    "npc_line_vi": "Tuyệt quá! Ngay bây giờ bạn đang vẽ gì thế?",
                    "options": [
                        {"text_en": "I am drawing a cute frog by the lake.", "text_vi": "Mình đang vẽ một chú ếch dễ thương bên hồ.", "is_correct": True, "feedback_vi": "Chuẩn thì hiện tại tiếp diễn 'I am drawing'!"},
                        {"text_en": "My uncle is a teacher.", "text_vi": "Chú mình là giáo viên.", "is_correct": False, "feedback_vi": "Câu hỏi hỏi 'đang vẽ gì' (What are you drawing?)."},
                        {"text_en": "Two plus three.", "text_vi": "Hai cộng ba.", "is_correct": False, "feedback_vi": "Không liên quan câu hỏi."},
                    ],
                },
            ],
        },
        {
            "id": "dlg_adv_13_a1_shop",
            "topic": "Shopping",
            "title_vi": "[A1] Mua đồ dùng học tập ở cửa hàng",
            "title_en": "At the Shop",
            "npc_id": "crystal_guardian",
            "npc_name_vi": "Người Bảo Vệ Pha Lê",
            "cefr_level": "A1",
            "review_status": "approved",
            "linked_grammar_id": "gram_a1_03",
            "linked_vocab_ids": ["word_buy", "word_price", "word_cheap"],
            "turns": [
                {
                    "npc_line_en": "Welcome to the Adventure Shop! What would you like to buy?",
                    "npc_line_vi": "Chào mừng đến Cửa hàng Phiêu lưu! Bạn muốn mua gì nào?",
                    "options": [
                        {"text_en": "I would like to buy a science book, please.", "text_vi": "Làm ơn cho mình mua một quyển sách khoa học ạ.", "is_correct": True, "feedback_vi": "Lịch sự và chuẩn mẫu 'I would like to buy...'!"},
                        {"text_en": "I sleep in my bed.", "text_vi": "Mình ngủ trên giường.", "is_correct": False, "feedback_vi": "Câu này nói về việc đi ngủ."},
                        {"text_en": "The wind is strong.", "text_vi": "Gió mạnh quá.", "is_correct": False, "feedback_vi": "Câu này nói về thời tiết."},
                    ],
                },
                {
                    "npc_line_en": "Here is the science book. It is only five gold coins — very cheap!",
                    "npc_line_vi": "Sách khoa học đây. Chỉ năm đồng vàng thôi — rất rẻ đấy!",
                    "options": [
                        {"text_en": "That is a good price! Here is the money. Thank you!", "text_vi": "Giá tốt quá! Tiền đây ạ. Cảm ơn bạn!", "is_correct": True, "feedback_vi": "Giao tiếp mua sắm tự nhiên và lễ phép!"},
                        {"text_en": "Touch your nose.", "text_vi": "Chạm vào mũi của bạn.", "is_correct": False, "feedback_vi": "Không phù hợp tình huống thanh toán."},
                        {"text_en": "I am hungry.", "text_vi": "Mình đói bụng.", "is_correct": False, "feedback_vi": "Không liên quan đến việc trả tiền mua sách."},
                    ],
                },
            ],
        },
        {
            "id": "dlg_adv_14_a1_school_day",
            "topic": "School",
            "title_vi": "[A1] Một ngày ở trường & Thức ăn",
            "title_en": "At the School & Lunch",
            "npc_id": "professor_owl",
            "npc_name_vi": "Giáo sư Cú",
            "cefr_level": "A1",
            "review_status": "approved",
            "linked_grammar_id": "gram_a1_10",
            "linked_vocab_ids": ["word_library", "word_homework", "word_soup"],
            "turns": [
                {
                    "npc_line_en": "Do you have any homework today?",
                    "npc_line_vi": "Hôm nay bạn có bài tập về nhà nào không?",
                    "options": [
                        {"text_en": "Yes, I have some science homework in my bag.", "text_vi": "Có ạ, mình có một ít bài tập khoa học trong cặp.", "is_correct": True, "feedback_vi": "Dùng đúng 'some' trong câu khẳng định!"},
                        {"text_en": "I am a triangle.", "text_vi": "Mình là hình tam giác.", "is_correct": False, "feedback_vi": "Câu trả lời không hợp lý."},
                        {"text_en": "She is swimming.", "text_vi": "Bạn ấy đang bơi.", "is_correct": False, "feedback_vi": "Chưa trả lời câu hỏi 'Do you have any homework?'."},
                    ],
                },
                {
                    "npc_line_en": "Great! After finishing homework, what would you like for lunch?",
                    "npc_line_vi": "Tuyệt! Sau khi làm xong bài tập, bạn muốn ăn gì cho bữa trưa?",
                    "options": [
                        {"text_en": "I would like some chicken noodles and salad.", "text_vi": "Mình muốn một ít mì gà và rau trộn.", "is_correct": True, "feedback_vi": "Chính xác! Kết hợp tốt từ vựng đồ ăn A1."},
                        {"text_en": "Turn left at the museum.", "text_vi": "Rẽ trái ở bảo tàng.", "is_correct": False, "feedback_vi": "Câu này dùng để chỉ đường."},
                        {"text_en": "My shoes are white.", "text_vi": "Giày mình màu trắng.", "is_correct": False, "feedback_vi": "Không phải món ăn trưa nhé."},
                    ],
                },
            ],
        },
    ]
    dlg_doc["scenarios"] = existing_sc + new_sc
    dlg_p.write_text(json.dumps(dlg_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(
        f"Updated phonics ({len(ph_doc['units'])} units, {len(ph_doc['phonics_activities'])} activities), "
        f"world_01_grammar ({len(g1_doc['structures'])} structs, {len(g1_doc['model_sentences'])} models), "
        f"world_02_a1_grammar ({len(g2_doc['structures'])} structs, {len(g2_doc['model_sentences'])} models), "
        f"dialogue_adventures ({len(dlg_doc['scenarios'])} scenarios)."
    )


if __name__ == "__main__":
    main()
