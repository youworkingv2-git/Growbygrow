#!/usr/bin/env python3
"""Expands 4-skill datasets (Pre-A1 & A1), builds reusable Question Bank, updates Curriculum & Quests."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def opt(oid: str, label_en: str = "", label_vi: str = "", word_id: str = "", is_correct: bool = False) -> dict:
    d: dict = {"id": oid, "is_correct": is_correct}
    if label_en:
        d["label_en"] = label_en
    if label_vi:
        d["label_vi"] = label_vi
    if word_id:
        d["word_id"] = word_id
    return d


def main() -> None:
    # -------------------------------------------------------------------------
    # 1. LISTENING: 12 -> 22 Pre-A1 + 6 A1
    # -------------------------------------------------------------------------
    l1_p = ROOT / "data/listening/world_01_listening.json"
    l1_doc = json.loads(l1_p.read_text(encoding="utf-8"))
    l1_items = l1_doc.get("items", [])[:12]
    for it in l1_items:
        it["review_status"] = "approved"
        it["cefr_level"] = "Pre-A1"

    l1_new = [
        {
            "id": "list_13", "activity_type": "listen_word_choose_image",
            "prompt_vi": "Nghe từ về hình dạng và chọn đúng hình:",
            "transcript_en": "star", "translation_vi": "Ngôi sao", "ipa": "/stɑːr/", "word_id": "word_star",
            "options": [opt("a", label_en="star", word_id="word_star", is_correct=True), opt("b", label_en="circle", word_id="word_circle"), opt("c", label_en="square", word_id="word_square")],
            "explanation_vi": "'Star' nghĩa là ngôi sao / hình ngôi sao.", "audio_status": "missing_asset", "audio_path": "", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "list_14", "activity_type": "listen_word_choose_image",
            "prompt_vi": "Nghe từ về bộ phận cơ thể và chọn hình đúng:",
            "transcript_en": "eye", "translation_vi": "Con mắt", "ipa": "/aɪ/", "word_id": "word_eye",
            "options": [opt("a", label_en="ear", word_id="word_ear"), opt("b", label_en="eye", word_id="word_eye", is_correct=True), opt("c", label_en="nose", word_id="word_nose")],
            "explanation_vi": "'Eye' (/aɪ/) là con mắt.", "audio_status": "missing_asset", "audio_path": "", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "list_15", "activity_type": "listen_word_choose_meaning",
            "prompt_vi": "Nghe từ và chọn nghĩa tiếng Việt đúng:",
            "transcript_en": "happy", "translation_vi": "Vui vẻ", "ipa": "/ˈhæp.i/", "word_id": "word_happy",
            "options": [opt("a", label_vi="Vui vẻ", is_correct=True), opt("b", label_vi="Buồn bã"), opt("c", label_vi="Đói bụng")],
            "explanation_vi": "'Happy' nghĩa là vui vẻ.", "audio_status": "missing_asset", "audio_path": "", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "list_16", "activity_type": "listen_word_choose_image",
            "prompt_vi": "Nghe từ về thời tiết và chọn hình đúng:",
            "transcript_en": "sun", "translation_vi": "Mặt trời", "ipa": "/sʌn/", "word_id": "word_sun",
            "options": [opt("a", label_en="rain", word_id="word_rain"), opt("b", label_en="sun", word_id="word_sun", is_correct=True), opt("c", label_en="cloud", word_id="word_cloud")],
            "explanation_vi": "'Sun' (/sʌn/) là mặt trời.", "audio_status": "missing_asset", "audio_path": "", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "list_17", "activity_type": "listen_word_choose_image",
            "prompt_vi": "Nghe từ về đồ chơi và chọn hình đúng:",
            "transcript_en": "kite", "translation_vi": "Cái diều", "ipa": "/kaɪt/", "word_id": "word_kite",
            "options": [opt("a", label_en="kite", word_id="word_kite", is_correct=True), opt("b", label_en="doll", word_id="word_doll"), opt("c", label_en="robot", word_id="word_robot")],
            "explanation_vi": "'Kite' là cái diều bay trong gió.", "audio_status": "missing_asset", "audio_path": "", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "list_18", "activity_type": "listen_sentence_choose_answer",
            "prompt_vi": "Nghe câu và chọn hình miêu tả đúng:",
            "transcript_en": "A black cat.", "translation_vi": "Một con mèo màu đen.", "ipa": "/ə blæk kæt/", "word_id": "word_black",
            "options": [opt("a", label_en="A black cat", word_id="word_black", is_correct=True), opt("b", label_en="A white rabbit", word_id="word_white"), opt("c", label_en="A brown bear", word_id="word_brown")],
            "explanation_vi": "'A black cat' là một con mèo màu đen.", "audio_status": "missing_asset", "audio_path": "", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "list_19", "activity_type": "listen_sentence_choose_answer",
            "prompt_vi": "Nghe câu và chọn đáp án đúng:",
            "transcript_en": "I ride my blue bike in the park.", "translation_vi": "Mình đi xe đạp xanh dương ở công viên.", "ipa": "/aɪ raɪd maɪ bluː baɪk ɪn ðə pɑːrk/", "word_id": "word_bike",
            "options": [opt("a", label_vi="Đi xe đạp xanh dương ở công viên", is_correct=True), opt("b", label_vi="Ngủ trên giường ở nhà"), opt("c", label_vi="Ăn bánh mì và trứng")],
            "explanation_vi": "'Ride my blue bike' = đi xe đạp màu xanh dương; 'in the park' = ở công viên.", "audio_status": "missing_asset", "audio_path": "", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "list_20", "activity_type": "listen_short_dialogue",
            "prompt_vi": "Nghe câu hỏi và chọn câu trả lời phù hợp:",
            "transcript_en": "What color is the lemon?", "translation_vi": "Quả chanh màu gì?", "ipa": "/wʌt ˈkʌl.ɚ ɪz ðə ˈlɛm.ən/", "word_id": "word_lemon",
            "options": [opt("a", label_en="It is yellow.", is_correct=True), opt("b", label_en="It is seven."), opt("c", label_en="My name is Leo.")],
            "explanation_vi": "Quả chanh vàng (lemon) có màu vàng -> 'It is yellow.'", "audio_status": "missing_asset", "audio_path": "", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "list_21", "activity_type": "listen_identify_detail",
            "prompt_vi": "Nghe câu hướng dẫn và chọn hành động đúng:",
            "transcript_en": "Please open the door and sit on the chair.", "translation_vi": "Làm ơn mở cửa và ngồi xuống ghế.", "ipa": "/pliːz ˈoʊ.pən ðə dɔːr ænd sɪt ɑːn ðə tʃɛr/", "word_id": "word_door",
            "options": [opt("a", label_vi="Mở cửa và ngồi xuống ghế", is_correct=True), opt("b", label_vi="Đóng cửa sổ và đi ngủ"), opt("c", label_vi="Rửa tay và uống sữa")],
            "explanation_vi": "'Open the door' = mở cửa, 'sit on the chair' = ngồi lên ghế.", "audio_status": "missing_asset", "audio_path": "", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "list_22", "activity_type": "listen_arrange_sentence",
            "prompt_vi": "Nghe câu mẫu rồi chạm các từ để ghép lại cho đúng:",
            "transcript_en": "I have ten red stars", "translation_vi": "Mình có mười ngôi sao đỏ.", "ipa": "/aɪ hæv tɛn rɛd stɑːrz/", "word_id": "word_ten",
            "tokens": ["I", "have", "ten", "red", "stars"],
            "explanation_vi": "Thứ tự đúng: I have ten red stars (Mình có mười ngôi sao đỏ).", "audio_status": "missing_asset", "audio_path": "", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
    ]
    l1_doc["items"] = l1_items + l1_new
    l1_p.write_text(json.dumps(l1_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    l2_items = [
        {
            "id": "list_a1_01", "activity_type": "listen_word_choose_image",
            "prompt_vi": "[A1] Nghe từ chỉ địa điểm và chọn hình đúng:",
            "transcript_en": "library", "translation_vi": "Thư viện", "ipa": "/ˈlaɪ.brɛr.i/", "word_id": "word_library",
            "options": [opt("a", label_en="library", word_id="word_library", is_correct=True), opt("b", label_en="hospital", word_id="word_hospital"), opt("c", label_en="market", word_id="word_market")],
            "explanation_vi": "'Library' là thư viện nơi đọc và mượn sách.", "audio_status": "missing_asset", "audio_path": "", "difficulty": 2, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "list_a1_02", "activity_type": "listen_short_dialogue",
            "prompt_vi": "[A1] Nghe câu hỏi trong cửa hàng và chọn lời đáp phù hợp:",
            "transcript_en": "How much is this science book? It is cheap!", "translation_vi": "Quyển sách khoa học này giá bao nhiêu? Rất rẻ!", "ipa": "/haʊ mʌtʃ ɪz ðɪs ˈsaɪ.əns bʊk/", "word_id": "word_price",
            "options": [opt("a", label_en="I would like to buy it, please.", is_correct=True), opt("b", label_en="I brush my teeth at six."), opt("c", label_en="The elephant is big.")],
            "explanation_vi": "Khi muốn mua món đồ vừa hỏi giá, nói: 'I would like to buy it, please.'", "audio_status": "missing_asset", "audio_path": "", "difficulty": 2, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "list_a1_03", "activity_type": "listen_identify_detail",
            "prompt_vi": "[A1] Nghe thói quen buổi sáng và cho biết bạn nhỏ ăn gì:",
            "transcript_en": "I brush my teeth at six thirty. Then I have bread and milk for breakfast.", "translation_vi": "Mình đánh răng lúc 6:30. Sau đó mình ăn bánh mì và uống sữa cho bữa sáng.", "ipa": "/aɪ brʌʃ maɪ tiːθ æt sɪks ˈθɜːr.t̬i/", "word_id": "word_breakfast",
            "options": [opt("a", label_vi="Bánh mì và sữa", is_correct=True), opt("b", label_vi="Mì gà và rau trộn"), opt("c", label_vi="Súp và cơm")],
            "explanation_vi": "Trong đoạn nghe có cụm 'have bread and milk for breakfast'.", "audio_status": "missing_asset", "audio_path": "", "difficulty": 2, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "list_a1_04", "activity_type": "listen_identify_detail",
            "prompt_vi": "[A1] Nghe chỉ đường và chọn địa điểm cuối cùng:",
            "transcript_en": "Go straight on Green Street and turn left at the park. The museum is next to the library.", "translation_vi": "Đi thẳng trên phố Green và rẽ trái ở công viên. Bảo tàng nằm cạnh thư viện.", "ipa": "/ɡoʊ streɪt ɑːn ɡriːn striːt/", "word_id": "word_museum",
            "options": [opt("a", label_vi="Bảo tàng (bên cạnh thư viện)", is_correct=True), opt("b", label_vi="Bệnh viện"), opt("c", label_vi="Chợ")],
            "explanation_vi": "Câu cuối cho biết 'The museum is next to the library.'", "audio_status": "missing_asset", "audio_path": "", "difficulty": 3, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "list_a1_05", "activity_type": "listen_sentence_choose_answer",
            "prompt_vi": "[A1] Nghe câu hỏi về sở thích và chọn câu trả lời đúng:",
            "transcript_en": "Can you swim or draw?", "translation_vi": "Bạn biết bơi hay vẽ tranh không?", "ipa": "/kæn juː swɪm ɔːr drɔː/", "word_id": "word_swim",
            "options": [opt("a", label_en="Yes, I can swim very well.", is_correct=True), opt("b", label_en="My uncle works at the market."), opt("c", label_en="There are five tables.")],
            "explanation_vi": "Câu hỏi bắt đầu bằng 'Can you...' trả lời bằng 'Yes, I can...' hoặc 'No, I can't...'.", "audio_status": "missing_asset", "audio_path": "", "difficulty": 2, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "list_a1_06", "activity_type": "listen_arrange_sentence",
            "prompt_vi": "[A1] Nghe và sắp xếp các từ thành câu hoàn chỉnh:",
            "transcript_en": "My cousin likes funny music", "translation_vi": "Anh họ mình thích nhạc vui nhộn.", "ipa": "/maɪ ˈkʌz.ən laɪks ˈfʌn.i ˈmjuː.zɪk/", "word_id": "word_cousin",
            "tokens": ["My", "cousin", "likes", "funny", "music"],
            "explanation_vi": "Thứ tự đúng: My cousin likes funny music.", "audio_status": "missing_asset", "audio_path": "", "difficulty": 3, "cefr_level": "A1", "review_status": "approved",
        },
    ]
    (ROOT / "data/listening/world_02_a1_listening.json").write_text(
        json.dumps({"world_id": "world_02", "cefr_level": "A1", "items": l2_items}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    # -------------------------------------------------------------------------
    # 2. READING: 12 -> 22 Pre-A1 + 6 A1
    # -------------------------------------------------------------------------
    r1_p = ROOT / "data/reading/world_01_reading.json"
    r1_doc = json.loads(r1_p.read_text(encoding="utf-8"))
    r1_items = r1_doc.get("items", [])[:12]
    for it in r1_items:
        it["review_status"] = "approved"
        it["cefr_level"] = "Pre-A1"

    r1_new = [
        {
            "id": "read_13", "activity_type": "read_word_choose_meaning",
            "prompt_vi": "Đọc từ sau và chọn nghĩa tiếng Việt đúng:",
            "text_en": "triangle", "translation_vi": "Hình tam giác", "word_id": "word_triangle",
            "options": [opt("a", label_vi="Hình tam giác", is_correct=True), opt("b", label_vi="Hình tròn"), opt("c", label_vi="Hình vuông")],
            "explanation_vi": "'Triangle' là hình tam giác (có 3 cạnh).", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "read_14", "activity_type": "read_word_choose_image",
            "prompt_vi": "Đọc từ và chọn hình tương ứng:",
            "text_en": "pencil", "translation_vi": "Bút chì", "word_id": "word_pencil",
            "options": [opt("a", label_en="ruler", word_id="word_ruler"), opt("b", label_en="pencil", word_id="word_pencil", is_correct=True), opt("c", label_en="desk", word_id="word_desk")],
            "explanation_vi": "'Pencil' là cây bút chì.", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "read_15", "activity_type": "match_word_image",
            "prompt_vi": "Từ nào khớp với bức tranh dưới đây?",
            "text_en": "frog", "word_id": "word_frog", "image_path": "res://assets/learning/images/frog.svg",
            "options": [opt("a", label_en="frog", is_correct=True), opt("b", label_en="lion"), opt("c", label_en="cow")],
            "explanation_vi": "Hình chú ếch xanh là 'frog'.", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "read_16", "activity_type": "fill_blank_sentence",
            "prompt_vi": "Chọn mạo từ đúng (a / an) điền vào chỗ trống:",
            "text_en": "I eat ___ orange every morning.", "word_id": "word_orange",
            "options": [opt("a", label_en="an", is_correct=True), opt("b", label_en="a"), opt("c", label_en="two")],
            "explanation_vi": "'Orange' bắt đầu bằng nguyên âm 'o' nên dùng 'an orange'.", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "read_17", "activity_type": "fill_blank_sentence",
            "prompt_vi": "Chọn giới từ vị trí đúng điền vào chỗ trống:",
            "text_en": "The red apple is ___ the table.", "word_id": "word_table",
            "options": [opt("a", label_en="on", is_correct=True), opt("b", label_en="happy"), opt("c", label_en="six")],
            "explanation_vi": "'On the table' = ở trên bàn.", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "read_18", "activity_type": "read_short_sentence",
            "prompt_vi": "Đọc câu và chọn nghĩa đúng:",
            "text_en": "My grandma wears a green coat.", "translation_vi": "Bà của mình mặc một chiếc áo khoác màu xanh lá.", "word_id": "word_coat",
            "options": [opt("a", label_vi="Bà của mình mặc áo khoác xanh lá.", is_correct=True), opt("b", label_vi="Ông của mình đội mũ màu đỏ."), opt("c", label_vi="Em bé đang ngủ trên giường.")],
            "explanation_vi": "'Grandma' = bà, 'wears' = mặc, 'green coat' = áo khoác xanh lá.", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "read_19", "activity_type": "read_short_passage",
            "prompt_vi": "Đọc đoạn ngắn và trả lời: Bạn nhỏ đi đâu?",
            "text_en": "Today is sunny. I go to the park with my dog. We fly a blue kite!",
            "translation_vi": "Hôm nay trời nắng. Mình đi công viên cùng chú chó. Chúng mình thả một chiếc diều xanh dương!",
            "word_id": "word_park",
            "options": [opt("a", label_vi="Đi công viên", is_correct=True), opt("b", label_vi="Đi đến trường"), opt("c", label_vi="Đi ra bãi biển")],
            "explanation_vi": "Câu thứ hai nói rõ: 'I go to the park with my dog.'", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "read_20", "activity_type": "read_short_passage",
            "prompt_vi": "Đọc đoạn ngắn và chọn đáp án đúng: Con thỏ màu gì?",
            "text_en": "I have two pets. My cat is black. My rabbit is white and has long ears.",
            "translation_vi": "Mình có hai thú cưng. Con mèo màu đen. Con thỏ màu trắng và có đôi tai dài.",
            "word_id": "word_rabbit",
            "options": [opt("a", label_vi="Màu trắng", is_correct=True), opt("b", label_vi="Màu đen"), opt("c", label_vi="Màu nâu")],
            "explanation_vi": "Câu cuối: 'My rabbit is white' -> chú thỏ màu trắng.", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "read_21", "activity_type": "read_short_passage",
            "prompt_vi": "Đọc đoạn ngắn và cho biết bạn nhỏ cảm thấy thế nào:",
            "text_en": "I am hungry! I eat bread, an egg, and drink sweet orange juice. Now I am happy!",
            "translation_vi": "Mình đói bụng rồi! Mình ăn bánh mì, một quả trứng và uống nước cam ngọt. Bây giờ mình thấy vui!",
            "word_id": "word_juice",
            "options": [opt("a", label_vi="Vui vẻ sau khi ăn uống", is_correct=True), opt("b", label_vi="Buồn ngủ và mệt mỏi"), opt("c", label_vi="Đang đi thả diều")],
            "explanation_vi": "Sau khi ăn bánh mì, trứng và uống nước cam: 'Now I am happy!'", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "read_22", "activity_type": "arrange_words_sentence",
            "prompt_vi": "Sắp xếp các từ để tạo thành câu đúng: 'Tôi thấy sáu ngôi sao.'",
            "tokens": ["I", "see", "six", "stars"],
            "word_id": "word_six",
            "explanation_vi": "Câu đúng là: 'I see six stars'.", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
    ]
    r1_doc["items"] = r1_items + r1_new
    r1_p.write_text(json.dumps(r1_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    r2_items = [
        {
            "id": "read_a1_01", "activity_type": "read_word_choose_meaning",
            "prompt_vi": "[A1] Đọc từ sau và chọn nghĩa tiếng Việt đúng:",
            "text_en": "homework", "translation_vi": "Bài tập về nhà", "word_id": "word_homework",
            "options": [opt("a", label_vi="Bài tập về nhà", is_correct=True), opt("b", label_vi="Bữa ăn sáng"), opt("c", label_vi="Cửa hàng")],
            "explanation_vi": "'Homework' là bài tập về nhà.", "difficulty": 2, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "read_a1_02", "activity_type": "fill_blank_sentence",
            "prompt_vi": "[A1] Chọn từ đúng ('is' hay 'are') cho câu sau:",
            "text_en": "There ___ many colorful books in our school library.", "word_id": "word_library",
            "options": [opt("a", label_en="are", is_correct=True), opt("b", label_en="is"), opt("c", label_en="am")],
            "explanation_vi": "'Many colorful books' là số nhiều nên dùng 'There are'.", "difficulty": 2, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "read_a1_03", "activity_type": "read_short_passage",
            "prompt_vi": "[A1] Đọc đoạn văn về bạn thân và trả lời: Hai bạn thường làm gì cùng nhau?",
            "text_en": "Minh is my best friend. He is kind and funny. We live on the same street and walk to school every morning. After school, we usually draw pictures and share fruit salad at home.",
            "translation_vi": "Minh là bạn thân nhất của mình. Bạn ấy tốt bụng và vui tính. Chúng mình sống trên cùng một con phố và đi bộ đến trường mỗi sáng. Sau giờ học, chúng mình thường vẽ tranh và chia sẻ salad trái cây ở nhà.",
            "word_id": "word_friend",
            "options": [opt("a", label_vi="Vẽ tranh và ăn salad trái cây cùng nhau", is_correct=True), opt("b", label_vi="Đi chợ và dọn bệnh viện"), opt("c", label_vi="Bơi ở bãi biển vào buổi sáng")],
            "explanation_vi": "Câu cuối đoạn văn viết: 'we usually draw pictures and share fruit salad at home.'", "difficulty": 3, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "read_a1_04", "activity_type": "read_short_passage",
            "prompt_vi": "[A1] Đọc đoạn văn về một ngày ở trường và chọn đáp án đúng: Bạn nhỏ thích môn nào nhất?",
            "text_en": "My school day starts at seven o'clock. First, I have science class. Science is my favorite subject because we do fun activities. At break time, I listen to music or read in the quiet library.",
            "translation_vi": "Ngày học của mình bắt đầu lúc 7 giờ. Đầu tiên là tiết Khoa học. Khoa học là môn yêu thích của mình vì chúng mình làm các hoạt động thú vị. Giờ ra chơi, mình nghe nhạc hoặc đọc sách ở thư viện yên tĩnh.",
            "word_id": "word_science",
            "options": [opt("a", label_vi="Môn Khoa học (Science)", is_correct=True), opt("b", label_vi="Môn Lịch sử"), opt("c", label_vi="Môn Bơi lội")],
            "explanation_vi": "Đoạn văn nói rõ: 'Science is my favorite subject'.", "difficulty": 3, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "read_a1_05", "activity_type": "read_short_passage",
            "prompt_vi": "[A1] Đọc đoạn văn và trả lời: Dì (aunt) của bạn nhỏ đi chợ mua gì?",
            "text_en": "On Sunday morning, my aunt goes to the market near our street. She wants to buy fresh chicken, noodles, and vegetables to cook hot soup for our parents and cousins. The prices at the market are very cheap!",
            "translation_vi": "Sáng Chủ nhật, dì của mình đi chợ gần phố nhà mình. Dì muốn mua thịt gà tươi, mì và rau để nấu súp nóng cho bố mẹ và các anh chị em họ. Giá cả ở chợ rất rẻ!",
            "word_id": "word_market",
            "options": [opt("a", label_vi="Thịt gà tươi, mì và rau", is_correct=True), opt("b", label_vi="Sách khoa học và bút chì"), opt("c", label_vi="Xe đạp và diều giấy")],
            "explanation_vi": "Câu thứ hai liệt kê: 'buy fresh chicken, noodles, and vegetables'.", "difficulty": 3, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "read_a1_06", "activity_type": "arrange_words_sentence",
            "prompt_vi": "[A1] Sắp xếp các từ để tạo thành câu hoàn chỉnh:",
            "tokens": ["There", "is", "a", "big", "museum"],
            "word_id": "word_museum",
            "explanation_vi": "Câu đúng là: 'There is a big museum' (Có một bảo tàng lớn).", "difficulty": 2, "cefr_level": "A1", "review_status": "approved",
        },
    ]
    (ROOT / "data/reading/world_02_a1_reading.json").write_text(
        json.dumps({"world_id": "world_02", "cefr_level": "A1", "items": r2_items}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    # -------------------------------------------------------------------------
    # 3. WRITING: 12 -> 22 Pre-A1 + 6 A1 (with acceptable_answers support)
    # -------------------------------------------------------------------------
    w1_p = ROOT / "data/writing/world_01_writing.json"
    w1_doc = json.loads(w1_p.read_text(encoding="utf-8"))
    w1_items = w1_doc.get("items", [])[:12]
    for it in w1_items:
        it["review_status"] = "approved"
        it["cefr_level"] = "Pre-A1"

    w1_new = [
        {
            "id": "write_13", "activity_type": "fill_missing_letter",
            "prompt_vi": "Chọn chữ cái còn thiếu cho từ 'Mặt trời' (SUN):",
            "pattern": "S _ N", "target_text": "SUN", "missing_letter": "U", "word_id": "word_sun",
            "letter_choices": ["U", "A", "I", "O"],
            "explanation_vi": "SUN (mặt trời) viết là S-U-N.", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "write_14", "activity_type": "fill_missing_letter",
            "prompt_vi": "Chọn chữ cái còn thiếu cho từ 'Ngôi sao' (STAR):",
            "pattern": "S T _ R", "target_text": "STAR", "missing_letter": "A", "word_id": "word_star",
            "letter_choices": ["A", "E", "O", "U"],
            "explanation_vi": "STAR (ngôi sao) viết là S-T-A-R.", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "write_15", "activity_type": "assemble_letters_word",
            "prompt_vi": "Ghép các chữ cái thành từ 'Con ếch' (FROG):",
            "target_text": "FROG", "word_id": "word_frog",
            "tiles": ["G", "F", "O", "R"],
            "explanation_vi": "FROG (con ếch) gồm F-R-O-G.", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "write_16", "activity_type": "assemble_letters_word",
            "prompt_vi": "Ghép các chữ cái thành từ 'Bánh mì' (BREAD):",
            "target_text": "BREAD", "word_id": "word_bread",
            "tiles": ["D", "B", "A", "R", "E"],
            "explanation_vi": "BREAD (bánh mì) gồm B-R-E-A-D.", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "write_17", "activity_type": "fill_word_in_sentence",
            "prompt_vi": "Điền từ chỉ màu sắc đúng vào câu: 'Bầu trời và quả bóng màu xanh dương.'",
            "sentence_template": "The ball is ___.", "target_word": "blue", "target_text": "The ball is blue.", "word_id": "word_blue",
            "word_choices": ["blue", "six", "desk"],
            "explanation_vi": "'Blue' nghĩa là màu xanh dương.", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "write_18", "activity_type": "fill_word_in_sentence",
            "prompt_vi": "Điền từ chỉ bộ phận cơ thể đúng: 'Mình có hai bàn tay.'",
            "sentence_template": "I have two ___.", "target_word": "hands", "target_text": "I have two hands.", "word_id": "word_hand",
            "word_choices": ["hands", "sun", "park"],
            "explanation_vi": "'Two hands' = hai bàn tay (nhớ thêm 's' khi có 2 trở lên).", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "write_19", "activity_type": "arrange_words_sentence",
            "prompt_vi": "Sắp xếp các từ thành câu: 'Tôi thích nho màu tím.'",
            "target_text": "I like purple grapes", "tokens": ["I", "like", "purple", "grapes"], "word_id": "word_grape",
            "acceptable_answers": ["I like purple grapes", "I like purple grapes."],
            "explanation_vi": "Cấu trúc: I like + tính từ màu sắc + danh từ -> I like purple grapes.", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "write_20", "activity_type": "arrange_words_sentence",
            "prompt_vi": "Sắp xếp các từ thành câu: 'Quyển sách ở trên cái bàn.'",
            "target_text": "The book is on the table", "tokens": ["The", "book", "is", "on", "the", "table"], "word_id": "word_table",
            "acceptable_answers": ["The book is on the table", "The book is on the table."],
            "explanation_vi": "Cấu trúc chỉ vị trí: The book is on the table.", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "write_21", "activity_type": "type_simple_sentence",
            "prompt_vi": "Viết câu ngắn nói mình thấy một chú thỏ trắng (hoặc một chú thỏ):",
            "target_text": "I see a white rabbit.",
            "acceptable_answers": ["I see a white rabbit", "I see a white rabbit.", "I see a rabbit", "I see a rabbit."],
            "word_id": "word_rabbit",
            "starter_chips": ["I see", "a white", "rabbit."],
            "explanation_vi": "Cả 'I see a white rabbit.' và 'I see a rabbit.' đều đúng ngữ pháp!", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
        {
            "id": "write_22", "activity_type": "type_simple_sentence",
            "prompt_vi": "Viết câu chào và nói mình rất vui hôm nay:",
            "target_text": "Hello! I am happy.",
            "acceptable_answers": ["Hello! I am happy.", "Hello I am happy", "Hello, I am happy.", "Hi! I am happy.", "I am happy.", "I'm happy."],
            "word_id": "word_happy",
            "starter_chips": ["Hello!", "I am", "I'm", "happy."],
            "explanation_vi": "Bé có thể viết 'Hello! I am happy.' hoặc 'I'm happy.' đều chính xác!", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved",
        },
    ]
    w1_doc["items"] = w1_items + w1_new
    w1_p.write_text(json.dumps(w1_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    w2_items = [
        {
            "id": "write_a1_01", "activity_type": "fill_missing_letter",
            "prompt_vi": "[A1] Điền chữ cái còn thiếu cho từ 'Thư viện' (LIBRARY):",
            "pattern": "L I B _ A R Y", "target_text": "LIBRARY", "missing_letter": "R", "word_id": "word_library",
            "letter_choices": ["R", "L", "N", "T"],
            "explanation_vi": "LIBRARY viết là L-I-B-R-A-R-Y.", "difficulty": 2, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "write_a1_02", "activity_type": "assemble_letters_word",
            "prompt_vi": "[A1] Ghép các chữ cái thành từ 'Âm nhạc' (MUSIC):",
            "target_text": "MUSIC", "word_id": "word_music",
            "tiles": ["C", "M", "S", "U", "I"],
            "explanation_vi": "MUSIC gồm M-U-S-I-C.", "difficulty": 2, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "write_a1_03", "activity_type": "fill_word_in_sentence",
            "prompt_vi": "[A1] Điền động từ đúng vào câu: 'Mình đánh răng mỗi sáng.'",
            "sentence_template": "I ___ my teeth every morning.", "target_word": "brush", "target_text": "I brush my teeth every morning.", "word_id": "word_brush",
            "word_choices": ["brush", "swim", "buy"],
            "explanation_vi": "'Brush my teeth' là cụm từ chuẩn nghĩa là đánh răng.", "difficulty": 2, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "write_a1_04", "activity_type": "arrange_words_sentence",
            "prompt_vi": "[A1] Sắp xếp từ thành câu lịch sự khi gọi đồ ăn:",
            "target_text": "I would like some chicken soup", "tokens": ["I", "would", "like", "some", "chicken", "soup"], "word_id": "word_soup",
            "acceptable_answers": ["I would like some chicken soup", "I would like some chicken soup."],
            "explanation_vi": "Mẫu câu lịch sự: 'I would like some + món ăn'.", "difficulty": 2, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "write_a1_05", "activity_type": "type_simple_sentence",
            "prompt_vi": "[A1] Viết câu nói về thói quen buổi tối của bạn (dùng 'usually' và 'study' hoặc 'homework'):",
            "target_text": "I usually do my homework.",
            "acceptable_answers": [
                "I usually do my homework.", "I usually do homework.", "I usually study English.",
                "I usually study in the evening.", "I usually read books."
            ],
            "word_id": "word_homework",
            "starter_chips": ["I usually", "do my homework.", "study English.", "read books."],
            "explanation_vi": "Mẫu câu Present Simple với trạng từ tần suất: 'I usually + động từ nguyên mẫu'.", "difficulty": 3, "cefr_level": "A1", "review_status": "approved",
        },
        {
            "id": "write_a1_06", "activity_type": "type_simple_sentence",
            "prompt_vi": "[A1] Viết 1–2 câu giới thiệu bạn thân hoặc gia đình của bạn:",
            "target_text": "My best friend is kind.",
            "acceptable_answers": [
                "My best friend is kind.", "My best friend is funny.", "My friend is very kind.",
                "My parents are kind.", "My cousin is funny."
            ],
            "word_id": "word_friend",
            "starter_chips": ["My best friend", "My parents", "is kind.", "is funny.", "are kind."],
            "explanation_vi": "Chấp nhận nhiều câu mô tả đúng cấu trúc chủ ngữ + is/are + tính từ!", "difficulty": 3, "cefr_level": "A1", "review_status": "approved",
        },
    ]
    (ROOT / "data/writing/world_02_a1_writing.json").write_text(
        json.dumps({"world_id": "world_02", "cefr_level": "A1", "items": w2_items}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    # -------------------------------------------------------------------------
    # 4. SPEAKING: 6 -> 12 Pre-A1 + 4 A1 (strict ai_scoring_status)
    # -------------------------------------------------------------------------
    s1_p = ROOT / "data/speaking/world_01_speaking.json"
    s1_doc = json.loads(s1_p.read_text(encoding="utf-8"))
    s1_items = s1_doc.get("items", [])[:6]
    for it in s1_items:
        it["review_status"] = "approved"
        it["cefr_level"] = "Pre-A1"

    s1_new = [
        {"id": "speak_07", "speaking_mode": "repeat_word", "prompt_vi": "Tập nói từ 'Star' (Ngôi sao):", "target_text_en": "Star", "meaning_vi": "Ngôi sao", "ipa": "/stɑːr/", "word_id": "word_star", "mouth_hint_vi": "Xì nhẹ âm /s/, nối sang /t/ và mở rộng khẩu hình /ɑːr/.", "audio_status": "missing_asset", "audio_path": "", "ai_scoring_status": "not_integrated_experimental", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved"},
        {"id": "speak_08", "speaking_mode": "repeat_word", "prompt_vi": "Tập nói từ 'Rabbit' (Con thỏ):", "target_text_en": "Rabbit", "meaning_vi": "Con thỏ", "ipa": "/ˈræb.ɪt/", "word_id": "word_rabbit", "mouth_hint_vi": "Nhấn trọng âm vào âm tiết đầu 'RAB-bit'.", "audio_status": "missing_asset", "audio_path": "", "ai_scoring_status": "not_integrated_experimental", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved"},
        {"id": "speak_09", "speaking_mode": "repeat_sentence", "prompt_vi": "Tập nói lời chào buổi sáng:", "target_text_en": "Good morning! Nice to meet you.", "meaning_vi": "Chào buổi sáng! Rất vui được gặp bạn.", "ipa": "/ɡʊd ˈmɔːr.nɪŋ naɪs tuː miːt juː/", "word_id": "word_hello", "mouth_hint_vi": "Nói với giọng tươi vui, rõ từng từ.", "audio_status": "missing_asset", "audio_path": "", "ai_scoring_status": "not_integrated_experimental", "difficulty": 1, "cefr_level": "Pre-A1", "review_status": "approved"},
        {"id": "speak_10", "speaking_mode": "repeat_sentence", "prompt_vi": "Tập nói màu sắc và đồ vật:", "target_text_en": "It is a yellow banana.", "meaning_vi": "Đó là một quả chuối màu vàng.", "ipa": "/ɪt ɪz ə ˈjɛl.oʊ bəˈnæn.ə/", "word_id": "word_banana", "mouth_hint_vi": "Đọc nối nhẹ 'It is' và nhấn ở 'yellow', 'banana'.", "audio_status": "missing_asset", "audio_path": "", "ai_scoring_status": "not_integrated_experimental", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved"},
        {"id": "speak_11", "speaking_mode": "repeat_sentence", "prompt_vi": "Tập đếm số và nói về đồ vật:", "target_text_en": "I have six blue pencils.", "meaning_vi": "Mình có sáu cây bút chì màu xanh dương.", "ipa": "/aɪ hæv sɪks bluː ˈpɛn.səlz/", "word_id": "word_pencil", "mouth_hint_vi": "Chú ý âm /s/ ở cuối 'six' và /z/ ở cuối 'pencils'.", "audio_status": "missing_asset", "audio_path": "", "ai_scoring_status": "not_integrated_experimental", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved"},
        {"id": "speak_12", "speaking_mode": "repeat_sentence", "prompt_vi": "Tập hỏi thăm lịch sự:", "target_text_en": "Thank you! See you later.", "meaning_vi": "Cảm ơn bạn! Hẹn gặp lại sau nhé.", "ipa": "/θæŋk juː siː juː ˈleɪ.t̬ɚ/", "word_id": "word_bye", "mouth_hint_vi": "Đặt nhẹ đầu lưỡi giữa hai răng cho âm /θ/ trong 'Thank'.", "audio_status": "missing_asset", "audio_path": "", "ai_scoring_status": "not_integrated_experimental", "difficulty": 2, "cefr_level": "Pre-A1", "review_status": "approved"},
    ]
    s1_doc["items"] = s1_items + s1_new
    s1_p.write_text(json.dumps(s1_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    s2_items = [
        {"id": "speak_a1_01", "speaking_mode": "repeat_sentence", "prompt_vi": "[A1] Tập giới thiệu bản thân và bạn thân:", "target_text_en": "I live near the park. My best friend is very kind.", "meaning_vi": "Mình sống gần công viên. Bạn thân của mình rất tốt bụng.", "ipa": "/aɪ lɪv nɪr ðə pɑːrk/", "word_id": "word_friend", "mouth_hint_vi": "Ngắt nhịp nhẹ ở dấu chấm giữa hai câu.", "audio_status": "missing_asset", "audio_path": "", "ai_scoring_status": "not_integrated_experimental", "difficulty": 2, "cefr_level": "A1", "review_status": "approved"},
        {"id": "speak_a1_02", "speaking_mode": "repeat_sentence", "prompt_vi": "[A1] Tập nói về thói quen buổi sáng:", "target_text_en": "I usually brush my teeth and have breakfast at seven.", "meaning_vi": "Mình thường đánh răng và ăn sáng lúc bảy giờ.", "ipa": "/aɪ ˈjuː.ʒu.ə.li brʌʃ maɪ tiːθ/", "word_id": "word_breakfast", "mouth_hint_vi": "Đọc mượt âm /ʒ/ trong 'usually' và /θ/ trong 'teeth'.", "audio_status": "missing_asset", "audio_path": "", "ai_scoring_status": "not_integrated_experimental", "difficulty": 3, "cefr_level": "A1", "review_status": "approved"},
        {"id": "speak_a1_03", "speaking_mode": "repeat_sentence", "prompt_vi": "[A1] Tập nói về sở thích của bạn:", "target_text_en": "I like to draw pictures and listen to music.", "meaning_vi": "Mình thích vẽ tranh và nghe nhạc.", "ipa": "/aɪ laɪk tuː drɔː ˈpɪk.tʃɚz/", "word_id": "word_draw", "mouth_hint_vi": "Nhấn giọng vào các từ khóa: draw, pictures, listen, music.", "audio_status": "missing_asset", "audio_path": "", "ai_scoring_status": "not_integrated_experimental", "difficulty": 2, "cefr_level": "A1", "review_status": "approved"},
        {"id": "speak_a1_04", "speaking_mode": "repeat_sentence", "prompt_vi": "[A1] Tập gọi đồ hoặc mua đồ lịch sự ở cửa hàng:", "target_text_en": "How much is this book? I would like to buy it.", "meaning_vi": "Quyển sách này giá bao nhiêu ạ? Mình muốn mua nó.", "ipa": "/haʊ mʌtʃ ɪz ðɪs bʊk/", "word_id": "word_buy", "mouth_hint_vi": "Lên giọng nhẹ ở cuối câu hỏi 'How much is this book?'.", "audio_status": "missing_asset", "audio_path": "", "ai_scoring_status": "not_integrated_experimental", "difficulty": 3, "cefr_level": "A1", "review_status": "approved"},
    ]
    (ROOT / "data/speaking/world_02_a1_speaking.json").write_text(
        json.dumps({"world_id": "world_02", "cefr_level": "A1", "items": s2_items}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    # -------------------------------------------------------------------------
    # 5. REUSABLE QUESTION BANK (data/questions/question_bank.json)
    # -------------------------------------------------------------------------
    qb_items = [
        {"id": "qb_01", "question_type": "multiple_choice", "difficulty_tier": 1, "cefr_level": "Pre-A1", "topic": "fruits", "knowledge_ids": ["word_apple"], "prompt_vi": "Từ 'apple' có nghĩa là gì?", "options": [opt("a", label_vi="Quả táo", is_correct=True), opt("b", label_vi="Quả chuối"), opt("c", label_vi="Quả cam")], "correct_answer": "a", "explanation_vi": "'Apple' là quả táo.", "image_path": "res://assets/learning/images/apple.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_02", "question_type": "listen_and_choose", "difficulty_tier": 1, "cefr_level": "Pre-A1", "topic": "animals", "knowledge_ids": ["word_lion"], "prompt_vi": "Nghe từ 'lion' và chọn đúng con vật:", "transcript_en": "lion", "options": [opt("a", label_en="lion", word_id="word_lion", is_correct=True), opt("b", label_en="frog", word_id="word_frog"), opt("c", label_en="bear", word_id="word_bear")], "correct_answer": "a", "explanation_vi": "'Lion' là con sư tử.", "image_path": "res://assets/learning/images/lion.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_03", "question_type": "image_word_matching", "difficulty_tier": 2, "cefr_level": "Pre-A1", "topic": "shapes", "knowledge_ids": ["word_circle"], "prompt_vi": "Nhìn hình tròn và chọn đúng từ tiếng Anh:", "options": [opt("a", label_en="circle", is_correct=True), opt("b", label_en="square"), opt("c", label_en="triangle")], "correct_answer": "a", "explanation_vi": "'Circle' là hình tròn.", "image_path": "res://assets/learning/images/circle.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_04", "question_type": "drag_and_drop", "difficulty_tier": 2, "cefr_level": "Pre-A1", "topic": "body_parts", "knowledge_ids": ["word_hand"], "prompt_vi": "Ghép các chữ cái thành từ 'Bàn tay' (HAND):", "tiles": ["N", "H", "D", "A"], "correct_answer": "HAND", "explanation_vi": "HAND gồm 4 chữ cái H-A-N-D.", "image_path": "res://assets/learning/images/hand.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_05", "question_type": "fill_in_the_blank", "difficulty_tier": 3, "cefr_level": "Pre-A1", "topic": "school", "knowledge_ids": ["word_pencil", "gram_20"], "prompt_vi": "Điền mạo từ đúng: 'I have ___ pencil.'", "options": [opt("a", label_en="a", is_correct=True), opt("b", label_en="an"), opt("c", label_en="are")], "correct_answer": "a", "explanation_vi": "'Pencil' bắt đầu bằng phụ âm /p/ nên dùng 'a pencil'.", "image_path": "res://assets/learning/images/pencil.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_06", "question_type": "word_ordering", "difficulty_tier": 4, "cefr_level": "Pre-A1", "topic": "weather", "knowledge_ids": ["word_sun", "gram_05"], "prompt_vi": "Sắp xếp thành câu hoàn chỉnh: 'Hôm nay trời nắng.'", "tokens": ["It", "is", "a", "sunny", "day"], "correct_answer": "It is a sunny day", "acceptable_answers": ["It is a sunny day", "It is a sunny day."], "explanation_vi": "Câu hoàn chỉnh: 'It is a sunny day.'", "image_path": "res://assets/learning/images/sun.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_07", "question_type": "sentence_ordering", "difficulty_tier": 4, "cefr_level": "A1", "topic": "daily_activities", "knowledge_ids": ["word_breakfast", "gram_a1_01"], "prompt_vi": "Sắp xếp thứ tự hợp lý cho buổi sáng:", "tokens": ["I wake up.", "I brush my teeth.", "I have breakfast."], "correct_answer": "I wake up. I brush my teeth. I have breakfast.", "explanation_vi": "Trình tự buổi sáng: thức dậy -> đánh răng -> ăn sáng.", "image_path": "res://assets/learning/images/breakfast.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_08", "question_type": "spelling", "difficulty_tier": 2, "cefr_level": "Pre-A1", "topic": "clothes", "knowledge_ids": ["word_shirt"], "prompt_vi": "Điền chữ cái còn thiếu cho 'Áo sơ mi' (SH_RT):", "options": [opt("a", label_en="I", is_correct=True), opt("b", label_en="E"), opt("c", label_en="A")], "correct_answer": "I", "explanation_vi": "SHIRT viết là S-H-I-R-T.", "image_path": "res://assets/learning/images/shirt.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_09", "question_type": "reading_comprehension", "difficulty_tier": 5, "cefr_level": "A1", "topic": "places", "knowledge_ids": ["word_library", "word_museum"], "prompt_vi": "Đọc đoạn ngắn: 'There is a library next to the museum on Green Street.' — Thư viện ở đâu?", "options": [opt("a", label_vi="Cạnh bảo tàng trên phố Green", is_correct=True), opt("b", label_vi="Trong công viên"), opt("c", label_vi="Ở ngoài bãi biển")], "correct_answer": "a", "explanation_vi": "'Next to the museum on Green Street' = cạnh bảo tàng trên phố Green.", "image_path": "res://assets/learning/images/library.svg", "audio_path": "", "review_status": "approved"},
        {"id": "qb_10", "question_type": "speaking_practice", "difficulty_tier": 5, "cefr_level": "A1", "topic": "shopping", "knowledge_ids": ["word_price", "gram_a1_03"], "prompt_vi": "Luyện nói câu hỏi giá tiền lịch sự:", "target_text_en": "Excuse me, how much is it?", "correct_answer": "Excuse me, how much is it?", "explanation_vi": "Dùng 'Excuse me, how much is it?' để hỏi giá tiền lịch sự.", "image_path": "res://assets/learning/images/price.svg", "audio_path": "", "review_status": "approved"},
    ]
    (ROOT / "data/questions").mkdir(parents=True, exist_ok=True)
    (ROOT / "data/questions/question_bank.json").write_text(
        json.dumps({"version": "1.0", "questions": qb_items}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    # -------------------------------------------------------------------------
    # 6. CURRICULUM EXPANSION (6-World Long-Term Structure + Expanded World 01 + A1 Sample World 02)
    # -------------------------------------------------------------------------
    cur_p = ROOT / "data/curriculum/learning_curriculum.json"
    cur_doc = json.loads(cur_p.read_text(encoding="utf-8"))
    cur_doc["learning_path"]["a1_unlock_criteria"] = {
        "min_pre_a1_lessons_completed": 6,
        "min_remembered_or_mastered_items": 15,
        "required_quest_ids": ["quest_03_mysterious_gate"],
        "min_overall_accuracy_pct": 60.0,
        "description_vi": "Mở khóa lộ trình A1 khi hoàn thành tối thiểu 6 bài Pre-A1, ghi nhớ/thành thạo ít nhất 15 kiến thức cốt lõi, vượt qua Cổng Bí Ẩn (Quest 03) và đạt độ chính xác tối thiểu 60%."
    }

    w1 = cur_doc["worlds"][0]
    w1["area_mapping"] = {
        "welcome_village": ["topic_01_alphabet", "topic_06_greetings_numbers"],
        "alphabet_meadow": ["topic_01_alphabet", "topic_02_basic_vocab"],
        "letter_cave": ["topic_03_basic_phonics"],
        "crystal_lake": ["topic_04_basic_words", "topic_07_world_around_us"],
        "shadow_gate": ["topic_05_simple_sentences"],
    }
    existing_topics = w1.get("topics", [])[:5]
    new_w1_topics = [
        {
            "id": "topic_06_greetings_numbers",
            "order_index": 6,
            "area_id": "welcome_village",
            "title_en": "Greetings, Shapes & Numbers 1-10",
            "title_vi": "Chủ đề 06: Chào hỏi, Hình dạng & Số đếm 1-10",
            "lessons": [
                {
                    "id": "lesson_06_01_shapes_numbers",
                    "quest_id": "",
                    "area_id": "crystal_lake",
                    "title_en": "Shapes, Numbers 6-10 & Polite Words",
                    "title_vi": "Bài 08: Hình dạng, Số 6-10 & Lời chào lịch sự",
                    "summary_vi": "Học số 6-10, 4 hình dạng cơ bản và câu chào hỏi lịch sự.",
                    "rewards": {"exp": 35, "gold": 15},
                    "activities": [
                        {"id": "act_08_1", "skill": "listening", "source_type": "listening", "source_id": "list_13"},
                        {"id": "act_08_2", "skill": "reading", "source_type": "reading", "source_id": "read_13"},
                        {"id": "act_08_3", "skill": "writing", "source_type": "writing", "source_id": "write_14"},
                        {"id": "act_08_4", "skill": "speaking", "source_type": "speaking", "source_id": "speak_09"},
                    ],
                }
            ],
        },
        {
            "id": "topic_07_world_around_us",
            "order_index": 7,
            "area_id": "crystal_lake",
            "title_en": "Body, Clothes, Weather & Daily Life",
            "title_vi": "Chủ đề 07: Cơ thể, Quần áo, Thời tiết & Hoạt động",
            "lessons": [
                {
                    "id": "lesson_07_01_body_weather",
                    "quest_id": "",
                    "area_id": "crystal_lake",
                    "title_en": "Body Parts, Weather & Feelings",
                    "title_vi": "Bài 09: Cơ thể, Thời tiết & Cảm xúc",
                    "summary_vi": "Nhận diện bộ phận cơ thể, thời tiết nắng/mưa và cảm xúc vui/buồn.",
                    "rewards": {"exp": 40, "gold": 20},
                    "activities": [
                        {"id": "act_09_1", "skill": "listening", "source_type": "listening", "source_id": "list_14"},
                        {"id": "act_09_2", "skill": "listening", "source_type": "listening", "source_id": "list_15"},
                        {"id": "act_09_3", "skill": "listening", "source_type": "listening", "source_id": "list_16"},
                        {"id": "act_09_4", "skill": "reading", "source_type": "reading", "source_id": "read_18"},
                        {"id": "act_09_5", "skill": "writing", "source_type": "writing", "source_id": "write_13"},
                        {"id": "act_09_6", "skill": "writing", "source_type": "writing", "source_id": "write_22"},
                    ],
                },
                {
                    "id": "lesson_07_02_toys_places_stories",
                    "quest_id": "",
                    "area_id": "crystal_lake",
                    "title_en": "Toys, Places & Short Stories",
                    "title_vi": "Bài 10: Đồ chơi, Địa điểm & Đọc hiểu ngắn",
                    "summary_vi": "Luyện tập diều, xe đạp, công viên và đọc đoạn văn 1-3 câu.",
                    "rewards": {"exp": 40, "gold": 20},
                    "activities": [
                        {"id": "act_10_1", "skill": "listening", "source_type": "listening", "source_id": "list_17"},
                        {"id": "act_10_2", "skill": "listening", "source_type": "listening", "source_id": "list_19"},
                        {"id": "act_10_3", "skill": "reading", "source_type": "reading", "source_id": "read_19"},
                        {"id": "act_10_4", "skill": "reading", "source_type": "reading", "source_id": "read_20"},
                        {"id": "act_10_5", "skill": "writing", "source_type": "writing", "source_id": "write_21"},
                        {"id": "act_10_6", "skill": "speaking", "source_type": "speaking", "source_id": "speak_11"},
                    ],
                },
            ],
        },
    ]
    w1["topics"] = existing_topics + new_w1_topics

    # Long-term 6-World structure (world_02 playable A1 sample, world_03..world_06 planned_extensible)
    world_02 = {
        "id": "world_02",
        "level_id": "a1_basic",
        "title_en": "Vocabulary Forest (A1 Foundation Sample)",
        "title_vi": "Rừng Từ Vựng (Gói Nội Dung Mẫu A1)",
        "status": "sample_playable",
        "topics": [
            {
                "id": "topic_a1_01_friends_school",
                "order_index": 1,
                "title_en": "Friends, Family & School Day",
                "title_vi": "[A1] Chủ đề 01: Bạn bè, Gia đình & Trường học",
                "lessons": [
                    {
                        "id": "lesson_a1_01_friends_school",
                        "quest_id": "",
                        "title_en": "My Best Friend & School Library",
                        "title_vi": "[A1] Bài 01: Bạn thân, Thư viện & Môn học",
                        "summary_vi": "Luyện từ vựng A1 về bạn bè, trường học, đọc đoạn văn 30-50 từ và viết câu.",
                        "rewards": {"exp": 50, "gold": 25},
                        "activities": [
                            {"id": "act_a1_1", "skill": "listening", "source_type": "listening", "source_id": "list_a1_01"},
                            {"id": "act_a1_2", "skill": "reading", "source_type": "reading", "source_id": "read_a1_03"},
                            {"id": "act_a1_3", "skill": "reading", "source_type": "reading", "source_id": "read_a1_04"},
                            {"id": "act_a1_4", "skill": "writing", "source_type": "writing", "source_id": "write_a1_01"},
                            {"id": "act_a1_5", "skill": "writing", "source_type": "writing", "source_id": "write_a1_06"},
                            {"id": "act_a1_6", "skill": "speaking", "source_type": "speaking", "source_id": "speak_a1_01"},
                        ],
                    }
                ],
            },
            {
                "id": "topic_a1_02_routine_shopping_places",
                "order_index": 2,
                "title_en": "Daily Routine, Hobbies, Food & Shopping",
                "title_vi": "[A1] Chủ đề 02: Thói quen, Sở thích, Đồ ăn & Mua sắm",
                "lessons": [
                    {
                        "id": "lesson_a1_02_routine_shop",
                        "quest_id": "",
                        "title_en": "Morning Routine, Hobbies & Market",
                        "title_vi": "[A1] Bài 02: Thói quen buổi sáng, Sở thích & Đi chợ",
                        "summary_vi": "Thực hành 'I usually...', 'I would like...', nghe chỉ đường và đọc hiểu A1.",
                        "rewards": {"exp": 55, "gold": 30},
                        "activities": [
                            {"id": "act_a1_7", "skill": "listening", "source_type": "listening", "source_id": "list_a1_02"},
                            {"id": "act_a1_8", "skill": "listening", "source_type": "listening", "source_id": "list_a1_03"},
                            {"id": "act_a1_9", "skill": "listening", "source_type": "listening", "source_id": "list_a1_04"},
                            {"id": "act_a1_10", "skill": "reading", "source_type": "reading", "source_id": "read_a1_05"},
                            {"id": "act_a1_11", "skill": "writing", "source_type": "writing", "source_id": "write_a1_04"},
                            {"id": "act_a1_12", "skill": "speaking", "source_type": "speaking", "source_id": "speak_a1_02"},
                        ],
                    }
                ],
            },
        ],
    }
    planned_worlds = [
        {"id": "world_03", "level_id": "a1_basic", "title_en": "Sentence Kingdom", "title_vi": "Vương Quốc Mẫu Câu", "status": "planned_extensible", "topics": []},
        {"id": "world_04", "level_id": "a1_plus", "title_en": "Listening Ocean", "title_vi": "Đại Dương Luyện Nghe", "status": "planned_extensible", "topics": []},
        {"id": "world_05", "level_id": "a1_plus", "title_en": "Speaking City", "title_vi": "Thành Phố Luyện Nói", "status": "planned_extensible", "topics": []},
        {"id": "world_06", "level_id": "a2_starter", "title_en": "Challenge Kingdom", "title_vi": "Vương Quốc Thử Thách", "status": "planned_extensible", "topics": []},
    ]
    cur_doc["worlds"] = [w1, world_02] + planned_worlds
    cur_p.write_text(json.dumps(cur_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    # -------------------------------------------------------------------------
    # 7. QUEST LEARNING HOOK ENRICHMENT (world_01_quests.json)
    # -------------------------------------------------------------------------
    q_p = ROOT / "data/quests/world_01_quests.json"
    q_doc = json.loads(q_p.read_text(encoding="utf-8"))
    quest_enrichment = {
        "quest_01_new_adventure": {
            "linked_topics": ["greetings", "numbers"],
            "linked_vocab_ids": ["word_hello", "word_yes", "word_one", "word_two"],
            "linked_phrase_ids": ["phr_01", "phr_06"],
            "linked_grammar_ids": ["gram_01", "gram_16"],
            "review_vocab_ids": ["word_hello"],
        },
        "quest_02_lost_letters": {
            "linked_topics": ["alphabet", "fruits", "toys", "animals"],
            "linked_vocab_ids": ["word_apple", "word_ball", "word_cat"],
            "linked_phrase_ids": ["phr_08", "phr_10"],
            "linked_grammar_ids": ["gram_03", "gram_20"],
            "review_vocab_ids": ["word_apple", "word_cat"],
        },
        "quest_03_mysterious_gate": {
            "linked_topics": ["phonics", "school", "food"],
            "linked_vocab_ids": ["word_ship", "word_book", "word_milk"],
            "linked_phrase_ids": ["phr_16", "phr_14"],
            "linked_grammar_ids": ["gram_06", "gram_07"],
            "review_vocab_ids": ["word_apple", "word_ball", "word_ship"],
        },
        "quest_04_crystal_guardian": {
            "linked_topics": ["colors", "shapes", "animals", "weather"],
            "linked_vocab_ids": ["word_red", "word_blue", "word_star", "word_frog", "word_sun"],
            "linked_phrase_ids": ["phr_11", "phr_33"],
            "linked_grammar_ids": ["gram_18", "gram_19"],
            "review_vocab_ids": ["word_red", "word_frog"],
        },
        "quest_05_shadow_gate": {
            "linked_topics": ["simple_sentences", "feelings", "places"],
            "linked_vocab_ids": ["word_happy", "word_park", "word_home"],
            "linked_phrase_ids": ["phr_04", "phr_36"],
            "linked_grammar_ids": ["gram_07", "gram_15", "gram_22"],
            "review_vocab_ids": ["word_apple", "word_cat", "word_happy", "word_star"],
        },
        "side_buddy_treasure": {
            "linked_topics": ["food", "fruits"],
            "linked_vocab_ids": ["word_banana", "word_cake", "word_grape"],
            "linked_phrase_ids": ["phr_09", "phr_15"],
            "linked_grammar_ids": ["gram_07"],
            "review_vocab_ids": ["word_banana"],
        },
        "side_lily_garden": {
            "linked_topics": ["colors", "alphabet"],
            "linked_vocab_ids": ["word_green", "word_yellow", "word_pink", "word_purple"],
            "linked_phrase_ids": ["phr_08"],
            "linked_grammar_ids": ["gram_18"],
            "review_vocab_ids": ["word_green", "word_yellow"],
        },
        "side_rocky_animals": {
            "linked_topics": ["animals"],
            "linked_vocab_ids": ["word_dog", "word_bird", "word_lion", "word_rabbit", "word_bear"],
            "linked_phrase_ids": ["phr_12", "phr_32"],
            "linked_grammar_ids": ["gram_17"],
            "review_vocab_ids": ["word_dog", "word_lion"],
        },
    }
    for q in q_doc.get("quests", []):
        qid = q.get("id", "")
        if qid in quest_enrichment:
            hook = q.setdefault("learning_hook", {})
            hook.update(quest_enrichment[qid])
    q_p.write_text(json.dumps(q_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(
        f"Listening: {len(l1_doc['items'])} Pre-A1 + {len(l2_items)} A1; "
        f"Reading: {len(r1_doc['items'])} Pre-A1 + {len(r2_items)} A1; "
        f"Writing: {len(w1_doc['items'])} Pre-A1 + {len(w2_items)} A1; "
        f"Speaking: {len(s1_doc['items'])} Pre-A1 + {len(s2_items)} A1; "
        f"QuestionBank: {len(qb_items)}; Curriculum worlds: {len(cur_doc['worlds'])}."
    )


if __name__ == "__main__":
    main()
