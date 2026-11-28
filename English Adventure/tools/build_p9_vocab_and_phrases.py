#!/usr/bin/env python3
"""Builds/updates Alphabet review metadata, 115 Pre-A1 words, 32 A1 sample words, and 48 common phrases."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ACTIVITIES = [
    "listening_word_image",
    "reading_word_meaning",
    "writing_missing_letter",
    "speaking_repeat_word",
    "review_flashcard",
]
LICENSE = "Project Original Vector (CC0-1.0)"


def make_word(
    word: str,
    ipa_us: str,
    ipa_uk: str,
    meaning_vi: str,
    pos: str,
    topic: str,
    topics: list[str],
    world_id: str,
    cefr: str,
    difficulty: int,
    ex_en: str,
    ex_vi: str,
    syllables: list[str],
    phonemes: list[str],
    related: list[str] | None = None,
    antonyms: list[str] | None = None,
    synonyms: list[str] | None = None,
) -> dict:
    return {
        "id": f"word_{word}",
        "word": word,
        "ipa_us": ipa_us,
        "ipa_uk": ipa_uk,
        "meaning_vi": meaning_vi,
        "part_of_speech": pos,
        "audio_us_path": "",
        "audio_uk_path": "",
        "audio_status": "missing_asset",
        "image_path": f"res://assets/learning/images/{word}.svg",
        "example_sentence": ex_en,
        "example_translation": ex_vi,
        "topic": topic,
        "topics": topics,
        "category": topic,
        "world_id": world_id,
        "cefr_level": cefr,
        "difficulty": difficulty,
        "related_words": related or [],
        "antonyms": antonyms or [],
        "synonyms": synonyms or [],
        "usable_activities": list(DEFAULT_ACTIVITIES),
        "accent": "en-US",
        "syllables": syllables,
        "phonemes": phonemes,
        "audio_slow_us_path": "",
        "audio_slow_uk_path": "",
        "example_audio_us_path": "",
        "example_audio_uk_path": "",
        "review_status": "approved",
        "asset_license": LICENSE,
    }


def main() -> None:
    # 1. Update alphabet_a_z.json metadata cleanly
    alpha_p = ROOT / "data/alphabet/alphabet_a_z.json"
    alpha_doc = json.loads(alpha_p.read_text(encoding="utf-8"))
    for lt in alpha_doc.get("letters", []):
        lt["review_status"] = "approved"
        lt["cefr_level"] = "Pre-A1"
    alpha_p.write_text(json.dumps(alpha_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 2. Enrich existing 38 Pre-A1 words + add 77 new Pre-A1 words = 115
    v1_p = ROOT / "data/vocabulary/world_01_vocab.json"
    v1_doc = json.loads(v1_p.read_text(encoding="utf-8"))
    existing = v1_doc.get("vocabulary", [])[:38]

    topic_enrichment = {
        "word_apple": ["fruits", "food"],
        "word_banana": ["fruits", "food"],
        "word_orange": ["fruits", "food", "colors"],
        "word_milk": ["food", "drinks"],
        "word_water": ["food", "drinks"],
        "word_cake": ["food"],
        "word_jam": ["food"],
        "word_book": ["school", "classroom_objects"],
        "word_pen": ["school", "classroom_objects"],
        "word_bag": ["school", "classroom_objects"],
        "word_ball": ["toys", "objects"],
        "word_chair": ["house", "rooms_furniture", "classroom_objects"],
        "word_box": ["house", "objects"],
        "word_hat": ["clothes", "objects"],
        "word_zoo": ["places", "animals"],
        "word_queen": ["family"],
    }
    antonym_enrichment = {
        "word_mom": ["word_dad"],
        "word_dad": ["word_mom"],
        "word_sister": ["word_brother"],
        "word_brother": ["word_sister"],
        "word_black": ["word_white"],
        "word_white": ["word_black"],
        "word_happy": ["word_sad"],
        "word_sad": ["word_happy"],
    }
    for w in existing:
        wid = w["id"]
        t = w.get("topic", "objects")
        w["topics"] = topic_enrichment.get(wid, [t])
        w["review_status"] = "approved"
        w["asset_license"] = LICENSE
        if wid in antonym_enrichment:
            w["antonyms"] = antonym_enrichment[wid]
        else:
            w.setdefault("antonyms", [])
        w.setdefault("synonyms", [])

    new_pre_a1 = [
        # Greetings (5)
        make_word("hello", "/həˈloʊ/", "/həˈləʊ/", "Xin chào", "interjection", "greetings", ["greetings"], "world_01", "Pre-A1", 1, "Hello! Nice to meet you.", "Xin chào! Rất vui được gặp bạn.", ["hel", "lo"], ["h", "ə", "l", "oʊ"], ["word_bye"], [], ["hi"]),
        make_word("bye", "/baɪ/", "/baɪ/", "Tạm biệt", "interjection", "greetings", ["greetings"], "world_01", "Pre-A1", 1, "Bye! See you soon.", "Tạm biệt! Hẹn gặp lại nhé.", ["bye"], ["b", "aɪ"], ["word_hello"], ["word_hello"], ["goodbye"]),
        make_word("please", "/pliːz/", "/pliːz/", "Làm ơn / Vui lòng", "adverb", "greetings", ["greetings"], "world_01", "Pre-A1", 1, "Please help me.", "Làm ơn giúp mình với.", ["please"], ["p", "l", "iː", "z"], ["word_sorry"]),
        make_word("sorry", "/ˈsɑːr.i/", "/ˈsɒr.i/", "Xin lỗi", "adjective", "greetings", ["greetings", "feelings"], "world_01", "Pre-A1", 1, "I am sorry.", "Mình xin lỗi.", ["sor", "ry"], ["s", "ɑː", "r", "i"], ["word_please"]),
        make_word("yes", "/jɛs/", "/jɛs/", "Vâng / Có", "adverb", "greetings", ["greetings"], "world_01", "Pre-A1", 1, "Yes, it is a cat.", "Đúng rồi, đó là một con mèo.", ["yes"], ["j", "ɛ", "s"], ["word_hello"]),

        # Numbers 6-10 (5)
        make_word("six", "/sɪks/", "/sɪks/", "Số sáu (6)", "number", "numbers", ["numbers"], "world_01", "Pre-A1", 1, "I have six pencils.", "Mình có sáu cây bút chì.", ["six"], ["s", "ɪ", "k", "s"], ["word_five", "word_seven"]),
        make_word("seven", "/ˈsɛv.ən/", "/ˈsɛv.ən/", "Số bảy (7)", "number", "numbers", ["numbers"], "world_01", "Pre-A1", 1, "There are seven stars.", "Có bảy ngôi sao.", ["sev", "en"], ["s", "ɛ", "v", "ə", "n"], ["word_six", "word_eight"]),
        make_word("eight", "/eɪt/", "/eɪt/", "Số tám (8)", "number", "numbers", ["numbers"], "world_01", "Pre-A1", 2, "I see eight birds.", "Mình thấy tám con chim.", ["eight"], ["eɪ", "t"], ["word_seven", "word_nine"]),
        make_word("nine", "/naɪn/", "/naɪn/", "Số chín (9)", "number", "numbers", ["numbers"], "world_01", "Pre-A1", 1, "She has nine books.", "Cô ấy có chín quyển sách.", ["nine"], ["n", "aɪ", "n"], ["word_eight", "word_ten"]),
        make_word("ten", "/tɛn/", "/tɛn/", "Số mười (10)", "number", "numbers", ["numbers"], "world_01", "Pre-A1", 1, "I am ten years old.", "Mình mười tuổi.", ["ten"], ["t", "ɛ", "n"], ["word_nine"]),

        # Colors (4)
        make_word("black", "/blæk/", "/blæk/", "Màu đen", "adjective", "colors", ["colors"], "world_01", "Pre-A1", 1, "It is a black cat.", "Đó là một con mèo đen.", ["black"], ["b", "l", "æ", "k"], ["word_white"], ["word_white"]),
        make_word("white", "/waɪt/", "/waɪt/", "Màu trắng", "adjective", "colors", ["colors"], "world_01", "Pre-A1", 1, "The rabbit is white.", "Chú thỏ có màu trắng.", ["white"], ["w", "aɪ", "t"], ["word_black"], ["word_black"]),
        make_word("purple", "/ˈpɜːr.pəl/", "/ˈpɜː.pəl/", "Màu tím", "adjective", "colors", ["colors"], "world_01", "Pre-A1", 2, "I like purple grapes.", "Mình thích nho màu tím.", ["pur", "ple"], ["p", "ɜːr", "p", "ə", "l"], ["word_pink", "word_grape"]),
        make_word("brown", "/braʊn/", "/braʊn/", "Màu nâu", "adjective", "colors", ["colors"], "world_01", "Pre-A1", 2, "The bear is brown.", "Con gấu có màu nâu.", ["brown"], ["b", "r", "aʊ", "n"], ["word_bear"]),

        # Shapes (4)
        make_word("circle", "/ˈsɜːr.kəl/", "/ˈsɜː.kəl/", "Hình tròn", "noun", "shapes", ["shapes"], "world_01", "Pre-A1", 2, "Draw a blue circle.", "Hãy vẽ một hình tròn màu xanh dương.", ["cir", "cle"], ["s", "ɜːr", "k", "ə", "l"], ["word_square", "word_star"]),
        make_word("square", "/skwɛr/", "/skweə/", "Hình vuông", "noun", "shapes", ["shapes"], "world_01", "Pre-A1", 2, "The box is a square.", "Chiếc hộp có hình vuông.", ["square"], ["s", "k", "w", "ɛ", "r"], ["word_circle", "word_triangle"]),
        make_word("triangle", "/ˈtraɪ.æŋ.ɡəl/", "/ˈtraɪ.æŋ.ɡəl/", "Hình tam giác", "noun", "shapes", ["shapes"], "world_01", "Pre-A1", 2, "I see a green triangle.", "Mình thấy một hình tam giác màu xanh lá.", ["tri", "an", "gle"], ["t", "r", "aɪ", "æ", "ŋ", "ɡ", "ə", "l"], ["word_square"]),
        make_word("star", "/stɑːr/", "/stɑː/", "Ngôi sao / Hình ngôi sao", "noun", "shapes", ["shapes", "weather"], "world_01", "Pre-A1", 1, "Look at the yellow star.", "Hãy nhìn ngôi sao màu vàng kia.", ["star"], ["s", "t", "ɑːr"], ["word_circle", "word_sun"]),

        # Family (3)
        make_word("baby", "/ˈbeɪ.bi/", "/ˈbeɪ.bi/", "Em bé", "noun", "family", ["family"], "world_01", "Pre-A1", 1, "The baby is sleeping.", "Em bé đang ngủ.", ["ba", "by"], ["b", "eɪ", "b", "i"], ["word_mom", "word_dad"]),
        make_word("grandma", "/ˈɡræn.mɑː/", "/ˈɡræn.mɑː/", "Bà", "noun", "family", ["family"], "world_01", "Pre-A1", 2, "My grandma is very kind.", "Bà của mình rất hiền.", ["grand", "ma"], ["ɡ", "r", "æ", "n", "m", "ɑː"], ["word_grandpa", "word_mom"]),
        make_word("grandpa", "/ˈɡræn.pɑː/", "/ˈɡræn.pɑː/", "Ông", "noun", "family", ["family"], "world_01", "Pre-A1", 2, "My grandpa likes tea.", "Ông của mình thích uống trà.", ["grand", "pa"], ["ɡ", "r", "æ", "n", "p", "ɑː"], ["word_grandma", "word_dad"]),

        # Body Parts (7)
        make_word("head", "/hɛd/", "/hɛd/", "Cái đầu", "noun", "body_parts", ["body_parts"], "world_01", "Pre-A1", 1, "Touch your head.", "Hãy chạm vào đầu của bạn.", ["head"], ["h", "ɛ", "d"], ["word_eye", "word_ear"]),
        make_word("eye", "/aɪ/", "/aɪ/", "Con mắt", "noun", "body_parts", ["body_parts"], "world_01", "Pre-A1", 1, "I have two eyes.", "Mình có hai con mắt.", ["eye"], ["aɪ"], ["word_ear", "word_nose"]),
        make_word("ear", "/ɪr/", "/ɪə/", "Cái tai", "noun", "body_parts", ["body_parts"], "world_01", "Pre-A1", 1, "The rabbit has long ears.", "Chú thỏ có đôi tai dài.", ["ear"], ["ɪ", "r"], ["word_eye", "word_rabbit"]),
        make_word("nose", "/noʊz/", "/nəʊz/", "Cái mũi", "noun", "body_parts", ["body_parts"], "world_01", "Pre-A1", 1, "This is my nose.", "Đây là cái mũi của mình.", ["nose"], ["n", "oʊ", "z"], ["word_mouth", "word_eye"]),
        make_word("mouth", "/maʊθ/", "/maʊθ/", "Cái miệng", "noun", "body_parts", ["body_parts"], "world_01", "Pre-A1", 2, "Open your mouth.", "Hãy mở miệng ra.", ["mouth"], ["m", "aʊ", "θ"], ["word_nose"]),
        make_word("hand", "/hænd/", "/hænd/", "Bàn tay", "noun", "body_parts", ["body_parts"], "world_01", "Pre-A1", 1, "Wash your hands.", "Hãy rửa tay của bạn.", ["hand"], ["h", "æ", "n", "d"], ["word_foot"]),
        make_word("foot", "/fʊt/", "/fʊt/", "Bàn chân", "noun", "body_parts", ["body_parts"], "world_01", "Pre-A1", 1, "I kick the ball with my foot.", "Mình đá bóng bằng chân.", ["foot"], ["f", "ʊ", "t"], ["word_hand", "word_ball"]),

        # Animals (5)
        make_word("lion", "/ˈlaɪ.ən/", "/ˈlaɪ.ən/", "Con sư tử", "noun", "animals", ["animals"], "world_01", "Pre-A1", 1, "The lion lives in the zoo.", "Con sư tử sống trong sở thú.", ["li", "on"], ["l", "aɪ", "ə", "n"], ["word_bear", "word_zoo"]),
        make_word("rabbit", "/ˈræb.ɪt/", "/ˈræb.ɪt/", "Con thỏ", "noun", "animals", ["animals"], "world_01", "Pre-A1", 1, "The white rabbit can jump.", "Chú thỏ trắng có thể nhảy.", ["rab", "bit"], ["r", "æ", "b", "ɪ", "t"], ["word_cat", "word_ear"]),
        make_word("bear", "/bɛr/", "/beə/", "Con gấu", "noun", "animals", ["animals"], "world_01", "Pre-A1", 1, "I see a big brown bear.", "Mình thấy một con gấu nâu to.", ["bear"], ["b", "ɛ", "r"], ["word_lion", "word_brown"]),
        make_word("frog", "/frɑːɡ/", "/frɒɡ/", "Con ếch", "noun", "animals", ["animals"], "world_01", "Pre-A1", 1, "The green frog is by the lake.", "Con ếch xanh ở bên hồ.", ["frog"], ["f", "r", "ɑː", "ɡ"], ["word_duck", "word_green"]),
        make_word("cow", "/kaʊ/", "/kaʊ/", "Con bò", "noun", "animals", ["animals"], "world_01", "Pre-A1", 1, "The cow gives us milk.", "Con bò cho chúng ta sữa.", ["cow"], ["k", "aʊ"], ["word_milk"]),

        # Fruits (4)
        make_word("grape", "/ɡreɪp/", "/ɡreɪp/", "Quả nho", "noun", "fruits", ["fruits", "food"], "world_01", "Pre-A1", 1, "I eat purple grapes.", "Mình ăn nho màu tím.", ["grape"], ["ɡ", "r", "eɪ", "p"], ["word_apple", "word_purple"]),
        make_word("mango", "/ˈmæŋ.ɡoʊ/", "/ˈmæŋ.ɡəʊ/", "Quả xoài", "noun", "fruits", ["fruits", "food"], "world_01", "Pre-A1", 2, "This mango is sweet.", "Quả xoài này rất ngọt.", ["man", "go"], ["m", "æ", "ŋ", "ɡ", "oʊ"], ["word_banana"]),
        make_word("pear", "/pɛr/", "/peə/", "Quả lê", "noun", "fruits", ["fruits", "food"], "world_01", "Pre-A1", 1, "I have one green pear.", "Mình có một quả lê xanh.", ["pear"], ["p", "ɛ", "r"], ["word_apple"]),
        make_word("lemon", "/ˈlɛm.ən/", "/ˈlɛm.ən/", "Quả chanh vàng", "noun", "fruits", ["fruits", "food"], "world_01", "Pre-A1", 2, "The lemon is yellow.", "Quả chanh có màu vàng.", ["lem", "on"], ["l", "ɛ", "m", "ə", "n"], ["word_yellow"]),

        # Food & Drinks (4)
        make_word("bread", "/brɛd/", "/brɛd/", "Bánh mì", "noun", "food", ["food"], "world_01", "Pre-A1", 1, "I eat bread for breakfast.", "Mình ăn bánh mì vào bữa sáng.", ["bread"], ["b", "r", "ɛ", "d"], ["word_egg", "word_jam"]),
        make_word("egg", "/ɛɡ/", "/ɛɡ/", "Quả trứng", "noun", "food", ["food"], "world_01", "Pre-A1", 1, "I want an egg, please.", "Làm ơn cho mình một quả trứng.", ["egg"], ["ɛ", "ɡ"], ["word_bread"]),
        make_word("rice", "/raɪs/", "/raɪs/", "Cơm / Gạo", "noun", "food", ["food"], "world_01", "Pre-A1", 1, "I eat rice with my family.", "Mình ăn cơm cùng gia đình.", ["rice"], ["r", "aɪ", "s"], ["word_water"]),
        make_word("juice", "/dʒuːs/", "/dʒuːs/", "Nước ép trái cây", "noun", "food", ["food", "drinks"], "world_01", "Pre-A1", 2, "I like orange juice.", "Mình thích nước ép cam.", ["juice"], ["dʒ", "uː", "s"], ["word_milk", "word_orange"]),

        # School & Classroom (5)
        make_word("pencil", "/ˈpɛn.səl/", "/ˈpɛn.səl/", "Bút chì", "noun", "school", ["school", "classroom_objects"], "world_01", "Pre-A1", 1, "I write with a pencil.", "Mình viết bằng bút chì.", ["pen", "cil"], ["p", "ɛ", "n", "s", "ə", "l"], ["word_pen", "word_ruler"]),
        make_word("ruler", "/ˈruː.lɚ/", "/ˈruː.lə/", "Thước kẻ", "noun", "school", ["school", "classroom_objects"], "world_01", "Pre-A1", 2, "This is my yellow ruler.", "Đây là cây thước màu vàng của mình.", ["ru", "ler"], ["r", "uː", "l", "ɚ"], ["word_pencil", "word_book"]),
        make_word("desk", "/dɛsk/", "/dɛsk/", "Bàn học", "noun", "school", ["school", "classroom_objects"], "world_01", "Pre-A1", 1, "My bag is on the desk.", "Cặp sách của mình ở trên bàn học.", ["desk"], ["d", "ɛ", "s", "k"], ["word_chair", "word_book"]),
        make_word("teacher", "/ˈtiː.tʃɚ/", "/ˈtiː.tʃə/", "Giáo viên", "noun", "school", ["school"], "world_01", "Pre-A1", 2, "My teacher is in the classroom.", "Cô giáo của mình đang ở trong lớp.", ["teach", "er"], ["t", "iː", "tʃ", "ɚ"], ["word_school"]),
        make_word("school", "/skuːl/", "/skuːl/", "Trường học", "noun", "school", ["school", "places"], "world_01", "Pre-A1", 1, "I go to school every day.", "Mình đi học mỗi ngày.", ["school"], ["s", "k", "uː", "l"], ["word_teacher", "word_book"]),

        # Toys (4)
        make_word("doll", "/dɑːl/", "/dɒl/", "Búp bê", "noun", "toys", ["toys"], "world_01", "Pre-A1", 1, "She has a pink doll.", "Bạn ấy có một con búp bê màu hồng.", ["doll"], ["d", "ɑː", "l"], ["word_ball", "word_pink"]),
        make_word("kite", "/kaɪt/", "/kaɪt/", "Cái diều", "noun", "toys", ["toys"], "world_01", "Pre-A1", 1, "Let us fly a kite!", "Cùng đi thả diều nào!", ["kite"], ["k", "aɪ", "t"], ["word_wind", "word_park"]),
        make_word("robot", "/ˈroʊ.bɑːt/", "/ˈrəʊ.bɒt/", "Người máy", "noun", "toys", ["toys"], "world_01", "Pre-A1", 2, "My robot can walk.", "Người máy của mình có thể đi bộ.", ["ro", "bot"], ["r", "oʊ", "b", "ɑː", "t"], ["word_ball"]),
        make_word("bike", "/baɪk/", "/baɪk/", "Xe đạp", "noun", "toys", ["toys"], "world_01", "Pre-A1", 1, "I ride my blue bike.", "Mình đi chiếc xe đạp màu xanh dương.", ["bike"], ["b", "aɪ", "k"], ["word_park"]),

        # Clothes (4)
        make_word("shirt", "/ʃɜːrt/", "/ʃɜːt/", "Áo sơ mi / Áo phông", "noun", "clothes", ["clothes"], "world_01", "Pre-A1", 2, "I wear a blue shirt.", "Mình mặc một chiếc áo màu xanh dương.", ["shirt"], ["ʃ", "ɜːr", "t"], ["word_hat", "word_shoes"]),
        make_word("shoes", "/ʃuːz/", "/ʃuːz/", "Đôi giày", "noun", "clothes", ["clothes"], "world_01", "Pre-A1", 2, "My shoes are red.", "Đôi giày của mình màu đỏ.", ["shoes"], ["ʃ", "uː", "z"], ["word_shirt", "word_foot"]),
        make_word("coat", "/koʊt/", "/kəʊt/", "Áo khoác", "noun", "clothes", ["clothes"], "world_01", "Pre-A1", 2, "Put on your green coat.", "Hãy mặc áo khoác xanh lá vào.", ["coat"], ["k", "oʊ", "t"], ["word_hat", "word_wind"]),
        make_word("dress", "/drɛs/", "/drɛs/", "Cái váy", "noun", "clothes", ["clothes"], "world_01", "Pre-A1", 2, "She wears a pink dress.", "Bạn ấy mặc một chiếc váy màu hồng.", ["dress"], ["d", "r", "ɛ", "s"], ["word_pink"]),

        # House & Rooms (5)
        make_word("house", "/haʊs/", "/haʊs/", "Ngôi nhà", "noun", "house", ["house", "places"], "world_01", "Pre-A1", 1, "This is my house.", "Đây là ngôi nhà của mình.", ["house"], ["h", "aʊ", "s"], ["word_home", "word_door"]),
        make_word("door", "/dɔːr/", "/dɔː/", "Cánh cửa", "noun", "house", ["house", "rooms_furniture"], "world_01", "Pre-A1", 1, "Open the door, please.", "Làm ơn mở cửa ra.", ["door"], ["d", "ɔːr"], ["word_window", "word_house"]),
        make_word("bed", "/bɛd/", "/bɛd/", "Cái giường", "noun", "house", ["house", "rooms_furniture"], "world_01", "Pre-A1", 1, "I sleep in my bed.", "Mình ngủ trên giường của mình.", ["bed"], ["b", "ɛ", "d"], ["word_sleep"]),
        make_word("table", "/ˈteɪ.bəl/", "/ˈteɪ.bəl/", "Cái bàn", "noun", "house", ["house", "rooms_furniture"], "world_01", "Pre-A1", 1, "The apple is on the table.", "Quả táo ở trên cái bàn.", ["ta", "ble"], ["t", "eɪ", "b", "ə", "l"], ["word_chair", "word_desk"]),
        make_word("window", "/ˈwɪn.doʊ/", "/ˈwɪn.dəʊ/", "Cửa sổ", "noun", "house", ["house", "rooms_furniture"], "world_01", "Pre-A1", 2, "Look out the window.", "Hãy nhìn ra ngoài cửa sổ.", ["win", "dow"], ["w", "ɪ", "n", "d", "oʊ"], ["word_door"]),

        # Daily Activities (6)
        make_word("eat", "/iːt/", "/iːt/", "Ăn", "verb", "daily_activities", ["daily_activities"], "world_01", "Pre-A1", 1, "I eat an apple every day.", "Mình ăn một quả táo mỗi ngày.", ["eat"], ["iː", "t"], ["word_drink", "word_apple"]),
        make_word("drink", "/drɪŋk/", "/drɪŋk/", "Uống", "verb", "daily_activities", ["daily_activities"], "world_01", "Pre-A1", 1, "Drink some water.", "Hãy uống một chút nước.", ["drink"], ["d", "r", "ɪ", "ŋ", "k"], ["word_eat", "word_water"]),
        make_word("read", "/riːd/", "/riːd/", "Đọc", "verb", "daily_activities", ["daily_activities", "school"], "world_01", "Pre-A1", 1, "I read a book at school.", "Mình đọc sách ở trường.", ["read"], ["r", "iː", "d"], ["word_book"]),
        make_word("play", "/pleɪ/", "/pleɪ/", "Chơi", "verb", "daily_activities", ["daily_activities", "toys"], "world_01", "Pre-A1", 1, "We play in the park.", "Chúng mình chơi ở công viên.", ["play"], ["p", "l", "eɪ"], ["word_ball", "word_park"]),
        make_word("sleep", "/sliːp/", "/sliːp/", "Ngủ", "verb", "daily_activities", ["daily_activities"], "world_01", "Pre-A1", 1, "I sleep at nine o'clock.", "Mình đi ngủ lúc chín giờ.", ["sleep"], ["s", "l", "iː", "p"], ["word_bed", "word_tired"]),
        make_word("run", "/rʌn/", "/rʌn/", "Chạy", "verb", "daily_activities", ["daily_activities"], "world_01", "Pre-A1", 1, "The dog can run fast.", "Chú chó có thể chạy nhanh.", ["run"], ["r", "ʌ", "n"], ["word_dog", "word_play"]),

        # Weather (4)
        make_word("sun", "/sʌn/", "/sʌn/", "Mặt trời", "noun", "weather", ["weather"], "world_01", "Pre-A1", 1, "The sun is bright today.", "Hôm nay mặt trời thật sáng.", ["sun"], ["s", "ʌ", "n"], ["word_cloud", "word_star"]),
        make_word("rain", "/reɪn/", "/reɪn/", "Mưa", "noun", "weather", ["weather"], "world_01", "Pre-A1", 1, "I see rain outside.", "Mình thấy trời đang mưa bên ngoài.", ["rain"], ["r", "eɪ", "n"], ["word_cloud", "word_wind"]),
        make_word("wind", "/wɪnd/", "/wɪnd/", "Gió", "noun", "weather", ["weather"], "world_01", "Pre-A1", 1, "The wind blows the kite.", "Gió thổi chiếc diều bay lên.", ["wind"], ["w", "ɪ", "n", "d"], ["word_kite", "word_rain"]),
        make_word("cloud", "/klaʊd/", "/klaʊd/", "Đám mây", "noun", "weather", ["weather"], "world_01", "Pre-A1", 2, "There is a white cloud.", "Có một đám mây trắng.", ["cloud"], ["k", "l", "aʊ", "d"], ["word_sun", "word_white"]),

        # Feelings (4)
        make_word("happy", "/ˈhæp.i/", "/ˈhæp.i/", "Vui vẻ", "adjective", "feelings", ["feelings"], "world_01", "Pre-A1", 1, "I am happy today!", "Hôm nay mình rất vui!", ["hap", "py"], ["h", "æ", "p", "i"], ["word_sad"], ["word_sad"], ["glad"]),
        make_word("sad", "/sæd/", "/sæd/", "Buồn", "adjective", "feelings", ["feelings"], "world_01", "Pre-A1", 1, "Do not be sad.", "Đừng buồn nhé.", ["sad"], ["s", "æ", "d"], ["word_happy"], ["word_happy"]),
        make_word("tired", "/ˈtaɪ.ɚd/", "/ˈtaɪəd/", "Mệt mỏi", "adjective", "feelings", ["feelings"], "world_01", "Pre-A1", 2, "I am tired after playing.", "Mình thấy mệt sau khi chơi.", ["tired"], ["t", "aɪ", "ɚ", "d"], ["word_sleep"]),
        make_word("hungry", "/ˈhʌŋ.ɡri/", "/ˈhʌŋ.ɡri/", "Đói bụng", "adjective", "feelings", ["feelings"], "world_01", "Pre-A1", 2, "I am hungry. Let us eat!", "Mình đói bụng rồi. Cùng ăn thôi!", ["hun", "gry"], ["h", "ʌ", "ŋ", "ɡ", "r", "i"], ["word_eat", "word_bread"]),

        # Places (4)
        make_word("park", "/pɑːrk/", "/pɑːk/", "Công viên", "noun", "places", ["places"], "world_01", "Pre-A1", 1, "Let us go to the park.", "Chúng ta hãy đi công viên.", ["park"], ["p", "ɑːr", "k"], ["word_play", "word_kite"]),
        make_word("home", "/hoʊm/", "/həʊm/", "Nhà / Tổ ấm", "noun", "places", ["places", "house"], "world_01", "Pre-A1", 1, "I go home after school.", "Mình về nhà sau giờ học.", ["home"], ["h", "oʊ", "m"], ["word_house"]),
        make_word("shop", "/ʃɑːp/", "/ʃɒp/", "Cửa hàng", "noun", "places", ["places"], "world_01", "Pre-A1", 2, "Mom buys fruit at the shop.", "Mẹ mua trái cây ở cửa hàng.", ["shop"], ["ʃ", "ɑː", "p"], ["word_apple"]),
        make_word("beach", "/biːtʃ/", "/biːtʃ/", "Bãi biển", "noun", "places", ["places"], "world_01", "Pre-A1", 2, "We swim at the beach.", "Chúng mình bơi ở bãi biển.", ["beach"], ["b", "iː", "tʃ"], ["word_sun", "word_water"]),
    ]

    v1_doc["vocabulary"] = existing + new_pre_a1
    v1_p.write_text(json.dumps(v1_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 3. Create world_02_a1_vocab.json (32 A1 sample words across 8 topics)
    a1_words = [
        # Friends (4)
        make_word("friend", "/frɛnd/", "/frɛnd/", "Người bạn", "noun", "friends", ["friends"], "world_02", "A1", 2, "Lan is my best friend.", "Lan là người bạn thân nhất của mình.", ["friend"], ["f", "r", "ɛ", "n", "d"], ["word_kind", "word_share"]),
        make_word("kind", "/kaɪnd/", "/kaɪnd/", "Tốt bụng", "adjective", "friends", ["friends"], "world_02", "A1", 2, "Buddy is very kind to everyone.", "Buddy rất tốt bụng với mọi người.", ["kind"], ["k", "aɪ", "n", "d"], ["word_friend"]),
        make_word("funny", "/ˈfʌn.i/", "/ˈfʌn.i/", "Vui tính / Hài hước", "adjective", "friends", ["friends"], "world_02", "A1", 2, "My friend tells funny stories.", "Bạn của mình kể những câu chuyện vui tính.", ["fun", "ny"], ["f", "ʌ", "n", "i"], ["word_happy", "word_friend"]),
        make_word("share", "/ʃɛr/", "/ʃeə/", "Chia sẻ", "verb", "friends", ["friends"], "world_02", "A1", 2, "We share our snacks at school.", "Chúng mình chia sẻ đồ ăn vặt ở trường.", ["share"], ["ʃ", "ɛ", "r"], ["word_friend"]),
        # School (4)
        make_word("library", "/ˈlaɪ.brɛr.i/", "/ˈlaɪ.brə.ri/", "Thư viện", "noun", "school", ["school", "places"], "world_02", "A1", 3, "I read quiet books in the library.", "Mình đọc sách yên tĩnh trong thư viện.", ["li", "brar", "y"], ["l", "aɪ", "b", "r", "ɛ", "r", "i"], ["word_book", "word_school"]),
        make_word("homework", "/ˈhoʊm.wɜːrk/", "/ˈhəʊm.wɜːk/", "Bài tập về nhà", "noun", "school", ["school", "daily_activities"], "world_02", "A1", 3, "I do my homework after dinner.", "Mình làm bài tập về nhà sau bữa tối.", ["home", "work"], ["h", "oʊ", "m", "w", "ɜːr", "k"], ["word_study", "word_school"]),
        make_word("science", "/ˈsaɪ.əns/", "/ˈsaɪ.əns/", "Môn Khoa học", "noun", "school", ["school"], "world_02", "A1", 3, "Science is my favorite subject.", "Khoa học là môn học yêu thích của mình.", ["sci", "ence"], ["s", "aɪ", "ə", "n", "s"], ["word_music", "word_school"]),
        make_word("music", "/ˈmjuː.zɪk/", "/ˈmjuː.zɪk/", "Âm nhạc", "noun", "school", ["school", "hobbies"], "world_02", "A1", 2, "I listen to music every evening.", "Mình nghe nhạc mỗi buổi tối.", ["mu", "sic"], ["m", "j", "uː", "z", "ɪ", "k"], ["word_sing", "word_dance"]),
        # Daily Activities (4)
        make_word("breakfast", "/ˈbrɛk.fəst/", "/ˈbrɛk.fəst/", "Bữa sáng", "noun", "daily_activities", ["daily_activities", "food"], "world_02", "A1", 2, "I have bread and milk for breakfast.", "Mình ăn bánh mì và uống sữa vào bữa sáng.", ["break", "fast"], ["b", "r", "ɛ", "k", "f", "ə", "s", "t"], ["word_bread", "word_milk"]),
        make_word("brush", "/brʌʃ/", "/brʌʃ/", "Đánh (răng) / Chải", "verb", "daily_activities", ["daily_activities"], "world_02", "A1", 2, "I brush my teeth every morning.", "Mình đánh răng mỗi buổi sáng.", ["brush"], ["b", "r", "ʌ", "ʃ"], ["word_clean"]),
        make_word("study", "/ˈstʌd.i/", "/ˈstʌd.i/", "Học tập", "verb", "daily_activities", ["daily_activities", "school"], "world_02", "A1", 2, "I study English for twenty minutes.", "Mình học tiếng Anh hai mươi phút.", ["stud", "y"], ["s", "t", "ʌ", "d", "i"], ["word_homework", "word_read"]),
        make_word("clean", "/kliːn/", "/kliːn/", "Dọn dẹp / Sạch sẽ", "verb", "daily_activities", ["daily_activities"], "world_02", "A1", 2, "I clean my room on Sunday.", "Mình dọn phòng vào Chủ nhật.", ["clean"], ["k", "l", "iː", "n"], ["word_brush"]),
        # Hobbies (4)
        make_word("draw", "/drɔː/", "/drɔː/", "Vẽ tranh", "verb", "hobbies", ["hobbies", "daily_activities"], "world_02", "A1", 2, "I like to draw colorful animals.", "Mình thích vẽ các con vật nhiều màu sắc.", ["draw"], ["d", "r", "ɔː"], ["word_pencil", "word_sing"]),
        make_word("swim", "/swɪm/", "/swɪm/", "Bơi lội", "verb", "hobbies", ["hobbies"], "world_02", "A1", 2, "I usually swim in the summer.", "Mình thường bơi vào mùa hè.", ["swim"], ["s", "w", "ɪ", "m"], ["word_beach", "word_water"]),
        make_word("sing", "/sɪŋ/", "/sɪŋ/", "Hát", "verb", "hobbies", ["hobbies"], "world_02", "A1", 2, "Can you sing an English song?", "Bạn có thể hát một bài tiếng Anh không?", ["sing"], ["s", "ɪ", "ŋ"], ["word_music", "word_dance"]),
        make_word("dance", "/dæns/", "/dɑːns/", "Nhảy múa", "verb", "hobbies", ["hobbies"], "world_02", "A1", 2, "We sing and dance at the party.", "Chúng mình hát và nhảy múa ở bữa tiệc.", ["dance"], ["d", "æ", "n", "s"], ["word_sing", "word_music"]),
        # Food (4)
        make_word("chicken", "/ˈtʃɪk.ɪn/", "/ˈtʃɪk.ɪn/", "Thịt gà", "noun", "food", ["food"], "world_02", "A1", 2, "I would like some chicken and rice.", "Mình muốn một ít thịt gà và cơm.", ["chick", "en"], ["tʃ", "ɪ", "k", "ɪ", "n"], ["word_rice", "word_soup"]),
        make_word("noodles", "/ˈnuː.dəlz/", "/ˈnuː.dəlz/", "Mì / Bún", "noun", "food", ["food"], "world_02", "A1", 2, "My brother likes hot noodles.", "Anh trai mình thích mì nóng.", ["noo", "dles"], ["n", "uː", "d", "ə", "l", "z"], ["word_soup", "word_rice"]),
        make_word("soup", "/suːp/", "/suːp/", "Súp / Canh", "noun", "food", ["food"], "world_02", "A1", 2, "This vegetable soup is delicious.", "Món súp rau này rất ngon.", ["soup"], ["s", "uː", "p"], ["word_noodles", "word_salad"]),
        make_word("salad", "/ˈsæl.əd/", "/ˈsæl.əd/", "Món rau trộn", "noun", "food", ["food"], "world_02", "A1", 2, "Do you like fresh fruit salad?", "Bạn có thích salad trái cây tươi không?", ["sal", "ad"], ["s", "æ", "l", "ə", "d"], ["word_soup"]),
        # Places (4)
        make_word("market", "/ˈmɑːr.kɪt/", "/ˈmɑː.kɪt/", "Chợ", "noun", "places", ["places", "shopping"], "world_02", "A1", 2, "Mom buys vegetables at the market.", "Mẹ mua rau ở chợ.", ["mar", "ket"], ["m", "ɑːr", "k", "ɪ", "t"], ["word_shop", "word_buy"]),
        make_word("hospital", "/ˈhɑːs.pɪ.təl/", "/ˈhɒs.pɪ.təl/", "Bệnh viện", "noun", "places", ["places"], "world_02", "A1", 3, "Doctors help people at the hospital.", "Bác sĩ giúp đỡ mọi người ở bệnh viện.", ["hos", "pi", "tal"], ["h", "ɑː", "s", "p", "ɪ", "t", "ə", "l"], ["word_street"]),
        make_word("museum", "/mjuːˈziː.əm/", "/mjuːˈziː.əm/", "Bảo tàng", "noun", "places", ["places"], "world_02", "A1", 3, "There is a big museum in town.", "Có một bảo tàng lớn ở trong thị trấn.", ["mu", "se", "um"], ["m", "j", "uː", "z", "iː", "ə", "m"], ["word_library"]),
        make_word("street", "/striːt/", "/striːt/", "Con đường / Phố", "noun", "places", ["places"], "world_02", "A1", 2, "My school is on Green Street.", "Trường của mình nằm trên phố Green.", ["street"], ["s", "t", "r", "iː", "t"], ["word_park", "word_market"]),
        # Shopping (4)
        make_word("price", "/praɪs/", "/praɪs/", "Giá tiền", "noun", "shopping", ["shopping"], "world_02", "A1", 2, "What is the price of this book?", "Giá của quyển sách này là bao nhiêu?", ["price"], ["p", "r", "aɪ", "s"], ["word_money", "word_cheap"]),
        make_word("money", "/ˈmʌn.i/", "/ˈmʌn.i/", "Tiền", "noun", "shopping", ["shopping"], "world_02", "A1", 2, "I save my money in a box.", "Mình tiết kiệm tiền trong một chiếc hộp.", ["mon", "ey"], ["m", "ʌ", "n", "i"], ["word_price", "word_buy"]),
        make_word("buy", "/baɪ/", "/baɪ/", "Mua", "verb", "shopping", ["shopping"], "world_02", "A1", 2, "I want to buy a new pencil.", "Mình muốn mua một cây bút chì mới.", ["buy"], ["b", "aɪ"], ["word_shop", "word_market"]),
        make_word("cheap", "/tʃiːp/", "/tʃiːp/", "Rẻ", "adjective", "shopping", ["shopping"], "world_02", "A1", 2, "These stickers are very cheap.", "Những hình dán này rất rẻ.", ["cheap"], ["tʃ", "iː", "p"], ["word_price"]),
        # Family (4)
        make_word("cousin", "/ˈkʌz.ən/", "/ˈkʌz.ən/", "Anh / Chị / Em họ", "noun", "family", ["family"], "world_02", "A1", 2, "My cousin plays football with me.", "Anh họ mình chơi bóng đá cùng mình.", ["cou", "sin"], ["k", "ʌ", "z", "ə", "n"], ["word_aunt", "word_uncle"]),
        make_word("uncle", "/ˈʌŋ.kəl/", "/ˈʌŋ.kəl/", "Chú / Bác / Cậu", "noun", "family", ["family"], "world_02", "A1", 2, "My uncle lives near the park.", "Chú của mình sống gần công viên.", ["un", "cle"], ["ʌ", "ŋ", "k", "ə", "l"], ["word_aunt", "word_cousin"]),
        make_word("aunt", "/ænt/", "/ɑːnt/", "Cô / Dì / Bác gái", "noun", "family", ["family"], "world_02", "A1", 2, "My aunt bakes yummy cakes.", "Dì của mình nướng bánh rất ngon.", ["aunt"], ["æ", "n", "t"], ["word_uncle", "word_cousin"]),
        make_word("parents", "/ˈpɛr.ənts/", "/ˈpeə.rənts/", "Bố mẹ / Cha mẹ", "noun", "family", ["family"], "world_02", "A1", 2, "My parents love me very much.", "Bố mẹ yêu thương mình rất nhiều.", ["par", "ents"], ["p", "ɛ", "r", "ə", "n", "t", "s"], ["word_mom", "word_dad"]),
    ]

    v2_p = ROOT / "data/vocabulary/world_02_a1_vocab.json"
    v2_p.write_text(json.dumps({"world_id": "world_02", "cefr_level": "A1", "vocabulary": a1_words}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # 4. Create data/phrases/common_phrases.json (36 Pre-A1 + 12 A1 = 48 phrases)
    phrases_raw = [
        # Pre-A1 (36)
        ("phr_01", "good morning", "chào buổi sáng", "/ɡʊd ˈmɔːr.nɪŋ/", "/ɡʊd ˈmɔː.nɪŋ/", "Pre-A1", "greetings", "world_01", ["word_hello"], "Good morning, Professor Owl!", "Chào buổi sáng, Giáo sư Cú!"),
        ("phr_02", "good afternoon", "chào buổi chiều", "/ɡʊd ˌæf.tɚˈnuːn/", "/ɡʊd ˌɑːf.təˈnuːn/", "Pre-A1", "greetings", "world_01", ["word_hello"], "Good afternoon, friends!", "Chào buổi chiều các bạn!"),
        ("phr_03", "good night", "chúc ngủ ngon", "/ɡʊd naɪt/", "/ɡʊd naɪt/", "Pre-A1", "greetings", "world_01", ["word_sleep", "word_bed"], "Good night, Mom and Dad.", "Chúc bố mẹ ngủ ngon."),
        ("phr_04", "thank you", "cảm ơn bạn", "/θæŋk juː/", "/θæŋk juː/", "Pre-A1", "greetings", "world_01", ["word_please"], "Thank you for helping me!", "Cảm ơn bạn đã giúp mình!"),
        ("phr_05", "you are welcome", "không có gì", "/juː ɑːr ˈwɛl.kəm/", "/juː ɑː ˈwɛl.kəm/", "Pre-A1", "greetings", "world_01", ["word_yes"], "You are welcome, Buddy!", "Không có gì đâu, Buddy!"),
        ("phr_06", "nice to meet you", "rất vui được gặp bạn", "/naɪs tuː miːt juː/", "/naɪs tuː miːt juː/", "Pre-A1", "greetings", "world_01", ["word_hello"], "Hello! Nice to meet you.", "Xin chào! Rất vui được gặp bạn."),
        ("phr_07", "see you later", "hẹn gặp lại sau", "/siː juː ˈleɪ.t̬ɚ/", "/siː juː ˈleɪ.tə/", "Pre-A1", "greetings", "world_01", ["word_bye"], "Bye! See you later.", "Tạm biệt! Hẹn gặp lại sau nhé."),
        ("phr_08", "a red apple", "một quả táo đỏ", "/ə rɛd ˈæp.əl/", "/ə rɛd ˈæp.əl/", "Pre-A1", "fruits", "world_01", ["word_red", "word_apple"], "I have a red apple.", "Mình có một quả táo đỏ."),
        ("phr_09", "a yellow banana", "một quả chuối vàng", "/ə ˈjɛl.oʊ bəˈnæn.ə/", "/ə ˈjɛl.əʊ bəˈnɑː.nə/", "Pre-A1", "fruits", "world_01", ["word_yellow", "word_banana"], "Look at a yellow banana.", "Hãy nhìn một quả chuối vàng."),
        ("phr_10", "a blue ball", "một quả bóng xanh dương", "/ə bluː bɔːl/", "/ə bluː bɔːl/", "Pre-A1", "toys", "world_01", ["word_blue", "word_ball"], "This is a blue ball.", "Đây là một quả bóng màu xanh dương."),
        ("phr_11", "two green frogs", "hai con ếch xanh lá", "/tuː ɡriːn frɑːɡz/", "/tuː ɡriːn frɒɡz/", "Pre-A1", "animals", "world_01", ["word_two", "word_green", "word_frog"], "I see two green frogs.", "Mình thấy hai con ếch màu xanh lá."),
        ("phr_12", "three cute cats", "ba chú mèo dễ thương", "/θriː kjuːt kæts/", "/θriː kjuːt kæts/", "Pre-A1", "animals", "world_01", ["word_three", "word_cat"], "There are three cute cats.", "Có ba chú mèo dễ thương."),
        ("phr_13", "drink water", "uống nước", "/drɪŋk ˈwɔː.t̬ɚ/", "/drɪŋk ˈwɔː.tə/", "Pre-A1", "daily_activities", "world_01", ["word_drink", "word_water"], "Remember to drink water.", "Hãy nhớ uống nước nhé."),
        ("phr_14", "drink milk", "uống sữa", "/drɪŋk mɪlk/", "/drɪŋk mɪlk/", "Pre-A1", "daily_activities", "world_01", ["word_drink", "word_milk"], "I drink milk in the morning.", "Mình uống sữa vào buổi sáng."),
        ("phr_15", "eat bread", "ăn bánh mì", "/iːt brɛd/", "/iːt brɛd/", "Pre-A1", "food", "world_01", ["word_eat", "word_bread"], "I eat bread and an egg.", "Mình ăn bánh mì và một quả trứng."),
        ("phr_16", "read a book", "đọc một quyển sách", "/riːd ə bʊk/", "/riːd ə bʊk/", "Pre-A1", "school", "world_01", ["word_read", "word_book"], "Let us read a book together.", "Cùng đọc một quyển sách nhé."),
        ("phr_17", "go to school", "đi học / đến trường", "/ɡoʊ tuː skuːl/", "/ɡəʊ tuː skuːl/", "Pre-A1", "school", "world_01", ["word_school"], "I go to school with my sister.", "Mình đi học cùng chị gái."),
        ("phr_18", "go home", "về nhà", "/ɡoʊ hoʊm/", "/ɡəʊ həʊm/", "Pre-A1", "places", "world_01", ["word_home"], "Time to go home!", "Đến giờ về nhà rồi!"),
        ("phr_19", "open your book", "mở sách ra", "/ˈoʊ.pən jʊr bʊk/", "/ˈəʊ.pən jɔː bʊk/", "Pre-A1", "school", "world_01", ["word_book"], "Please open your book.", "Làm ơn mở sách của bạn ra."),
        ("phr_20", "close the door", "đóng cửa lại", "/kloʊz ðə dɔːr/", "/kləʊz ðə dɔː/", "Pre-A1", "house", "world_01", ["word_door"], "Please close the door.", "Làm ơn đóng cửa lại."),
        ("phr_21", "sit down", "ngồi xuống", "/sɪt daʊn/", "/sɪt daʊn/", "Pre-A1", "school", "world_01", ["word_chair"], "Sit down on the chair.", "Hãy ngồi xuống ghế."),
        ("phr_22", "stand up", "đứng lên", "/stænd ʌp/", "/stænd ʌp/", "Pre-A1", "school", "world_01", ["word_teacher"], "Stand up and say hello.", "Hãy đứng lên và nói xin chào."),
        ("phr_23", "listen carefully", "lắng nghe cẩn thận", "/ˈlɪs.ən ˈkɛr.fəl.i/", "/ˈlɪs.ən ˈkeə.fəl.i/", "Pre-A1", "school", "world_01", ["word_ear"], "Listen carefully to the sound.", "Hãy lắng nghe âm thanh thật kỹ."),
        ("phr_24", "wash your hands", "rửa tay", "/wɑːʃ jʊr hændz/", "/wɒʃ jɔː hændz/", "Pre-A1", "body_parts", "world_01", ["word_hand", "word_water"], "Wash your hands before eating.", "Hãy rửa tay trước khi ăn."),
        ("phr_25", "in the bag", "ở trong cặp sách", "/ɪn ðə bæɡ/", "/ɪn ðə bæɡ/", "Pre-A1", "school", "world_01", ["word_bag", "word_pen"], "My pen is in the bag.", "Cây bút của mình ở trong cặp."),
        ("phr_26", "on the table", "ở trên bàn", "/ɑːn ðə ˈteɪ.bəl/", "/ɒn ðə ˈteɪ.bəl/", "Pre-A1", "house", "world_01", ["word_table", "word_apple"], "The cake is on the table.", "Chiếc bánh ở trên bàn."),
        ("phr_27", "under the chair", "ở dưới ghế", "/ˈʌn.dɚ ðə tʃɛr/", "/ˈʌn.də ðə tʃeə/", "Pre-A1", "house", "world_01", ["word_chair", "word_cat"], "The cat is under the chair.", "Con mèo ở dưới cái ghế."),
        ("phr_28", "fly a kite", "thả diều", "/flaɪ ə kaɪt/", "/flaɪ ə kaɪt/", "Pre-A1", "toys", "world_01", ["word_kite", "word_wind"], "We fly a kite in the park.", "Chúng mình thả diều ở công viên."),
        ("phr_29", "ride a bike", "đi xe đạp", "/raɪd ə baɪk/", "/raɪd ə baɪk/", "Pre-A1", "toys", "world_01", ["word_bike"], "I can ride a bike.", "Mình biết đi xe đạp."),
        ("phr_30", "play with a ball", "chơi với quả bóng", "/pleɪ wɪð ə bɔːl/", "/pleɪ wɪð ə bɔːl/", "Pre-A1", "toys", "world_01", ["word_play", "word_ball"], "The dog plays with a ball.", "Chú chó chơi với quả bóng."),
        ("phr_31", "at the park", "tại công viên", "/æt ðə pɑːrk/", "/æt ðə pɑːk/", "Pre-A1", "places", "world_01", ["word_park"], "I run at the park.", "Mình chạy bộ ở công viên."),
        ("phr_32", "at the zoo", "tại sở thú", "/æt ðə zuː/", "/æt ðə zuː/", "Pre-A1", "places", "world_01", ["word_zoo", "word_lion"], "I see a lion at the zoo.", "Mình thấy một con sư tử ở sở thú."),
        ("phr_33", "a sunny day", "một ngày nắng đẹp", "/ə ˈsʌn.i deɪ/", "/ə ˈsʌn.i deɪ/", "Pre-A1", "weather", "world_01", ["word_sun"], "It is a sunny day today.", "Hôm nay là một ngày nắng đẹp."),
        ("phr_34", "a rainy day", "một ngày mưa", "/ə ˈreɪ.ni deɪ/", "/ə ˈreɪ.ni deɪ/", "Pre-A1", "weather", "world_01", ["word_rain"], "Take a coat on a rainy day.", "Hãy mang áo khoác vào ngày mưa."),
        ("phr_35", "my big family", "gia đình lớn của mình", "/maɪ bɪɡ ˈfæm.əl.i/", "/maɪ bɪɡ ˈfæm.əl.i/", "Pre-A1", "family", "world_01", ["word_mom", "word_dad"], "I love my big family.", "Mình yêu gia đình lớn của mình."),
        ("phr_36", "very happy", "rất vui vẻ", "/ˈvɛr.i ˈhæp.i/", "/ˈvɛr.i ˈhæp.i/", "Pre-A1", "feelings", "world_01", ["word_happy"], "I am very happy!", "Mình rất vui!"),

        # A1 Sample Phrases (12)
        ("phr_37", "do homework", "làm bài tập về nhà", "/duː ˈhoʊm.wɜːrk/", "/duː ˈhəʊm.wɜːk/", "A1", "school", "world_02", ["word_homework"], "I do homework at seven o'clock.", "Mình làm bài tập về nhà lúc bảy giờ."),
        ("phr_38", "brush my teeth", "đánh răng", "/brʌʃ maɪ tiːθ/", "/brʌʃ maɪ tiːθ/", "A1", "daily_activities", "world_02", ["word_brush"], "I brush my teeth every morning.", "Mình đánh răng mỗi buổi sáng."),
        ("phr_39", "have breakfast", "ăn bữa sáng", "/hæv ˈbrɛk.fəst/", "/hæv ˈbrɛk.fəst/", "A1", "daily_activities", "world_02", ["word_breakfast"], "I have breakfast at home.", "Mình ăn sáng ở nhà."),
        ("phr_40", "in the library", "trong thư viện", "/ɪn ðə ˈlaɪ.brɛr.i/", "/ɪn ðə ˈlaɪ.brə.ri/", "A1", "school", "world_02", ["word_library"], "We read quietly in the library.", "Chúng mình đọc sách yên lặng trong thư viện."),
        ("phr_41", "best friend", "bạn thân nhất", "/bɛst frɛnd/", "/bɛst frɛnd/", "A1", "friends", "world_02", ["word_friend"], "My best friend is very funny.", "Bạn thân nhất của mình rất vui tính."),
        ("phr_42", "share toys", "chia sẻ đồ chơi", "/ʃɛr tɔɪz/", "/ʃeə tɔɪz/", "A1", "friends", "world_02", ["word_share"], "Good friends share toys together.", "Bạn tốt cùng nhau chia sẻ đồ chơi."),
        ("phr_43", "draw a picture", "vẽ một bức tranh", "/drɔː ə ˈpɪk.tʃɚ/", "/drɔː ə ˈpɪk.tʃə/", "A1", "hobbies", "world_02", ["word_draw"], "I like to draw a picture of a bird.", "Mình thích vẽ một bức tranh con chim."),
        ("phr_44", "listen to music", "nghe nhạc", "/ˈlɪs.ən tuː ˈmjuː.zɪk/", "/ˈlɪs.ən tuː ˈmjuː.zɪk/", "A1", "hobbies", "world_02", ["word_music"], "She likes to listen to music.", "Bạn ấy thích nghe nhạc."),
        ("phr_45", "how much is it", "cái này giá bao nhiêu", "/haʊ mʌtʃ ɪz ɪt/", "/haʊ mʌtʃ ɪz ɪt/", "A1", "shopping", "world_02", ["word_price"], "Excuse me, how much is it?", "Xin lỗi, cái này giá bao nhiêu ạ?"),
        ("phr_46", "at the market", "ở chợ", "/æt ðə ˈmɑːr.kɪt/", "/æt ðə ˈmɑː.kɪt/", "A1", "places", "world_02", ["word_market"], "We buy fresh fruit at the market.", "Chúng mình mua trái cây tươi ở chợ."),
        ("phr_47", "turn left", "rẽ trái", "/tɜːrn lɛft/", "/tɜːn lɛft/", "A1", "places", "world_02", ["word_street"], "Turn left at the park.", "Hãy rẽ trái ở chỗ công viên."),
        ("phr_48", "go straight", "đi thẳng", "/ɡoʊ streɪt/", "/ɡəʊ streɪt/", "A1", "places", "world_02", ["word_street"], "Go straight to the museum.", "Hãy đi thẳng đến bảo tàng."),
    ]
    phrases = [
        {
            "id": p[0],
            "phrase_en": p[1],
            "meaning_vi": p[2],
            "ipa_us": p[3],
            "ipa_uk": p[4],
            "cefr_level": p[5],
            "topic": p[6],
            "world_id": p[7],
            "linked_vocab_ids": p[8],
            "example_sentence": p[9],
            "example_translation": p[10],
            "audio_us_path": "",
            "audio_uk_path": "",
            "audio_status": "missing_asset",
            "review_status": "approved",
        }
        for p in phrases_raw
    ]
    (ROOT / "data/phrases").mkdir(parents=True, exist_ok=True)
    (ROOT / "data/phrases/common_phrases.json").write_text(
        json.dumps({"phrases": phrases}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    print(
        f"Updated alphabet (26), world_01_vocab ({len(v1_doc['vocabulary'])}), "
        f"world_02_a1_vocab ({len(a1_words)}), common_phrases ({len(phrases)})."
    )


if __name__ == "__main__":
    main()
