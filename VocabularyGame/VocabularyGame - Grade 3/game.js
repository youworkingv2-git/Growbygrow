const vocabData = {
    MyFriends: [
        { word: 'America', emoji: '🇺🇸', ipa: '🇺🇸 /əˈmerɪkə/', meaning: 'nước Mỹ', flagImg: 'assets/flags/usa.svg' },
        { word: 'Australia', emoji: '🇦🇺', ipa: '🇺🇸 /ɒˈstreɪliə/', meaning: 'nước Úc', flagImg: 'assets/flags/australia.svg' },
        { word: 'Britain', emoji: '🇬🇧', ipa: '🇺🇸 /ˈbrɪtn/', meaning: 'nước Anh', flagImg: 'assets/flags/britain.svg' },
        { word: 'Japan', emoji: '🇯🇵', ipa: '🇺🇸 /dʒəˈpæn/', meaning: 'nước Nhật', flagImg: 'assets/flags/japan.svg' },
        { word: 'Malaysia', emoji: '🇲🇾', ipa: '🇺🇸 /məˈleɪziə/', meaning: 'Malaysia', flagImg: 'assets/flags/malaysia.svg' },
        { word: 'Singapore', emoji: '🇸🇬', ipa: '🇺🇸 /ˌsɪŋəˈpɔː/', meaning: 'Singapore', flagImg: 'assets/flags/singapore.svg' },
        { word: 'Thailand', emoji: '🇹🇭', ipa: '🇺🇸 /ˈtaɪlənd/', meaning: 'Thái Lan', flagImg: 'assets/flags/thailand.svg' },
        { word: 'Viet Nam', emoji: '🇻🇳', ipa: '🇺🇸 /ˌviːetˈnɑːm/', meaning: 'Việt Nam', flagImg: 'assets/flags/vietnam.svg' },
        { word: 'Country', emoji: '🌍', ipa: '🇺🇸 /ˈkʌntri/', meaning: 'quốc gia' },
        { word: 'Friendly', emoji: '😊', ipa: '🇺🇸 /ˈfrɛndli/', meaning: 'thân thiện' },
        { word: "What's your name?", emoji: '📛', ipa: '🇺🇸 /wɒts jɔːr neɪm/', meaning: 'Tên bạn là gì?' },
        { word: "My name's Tom", emoji: '👦', ipa: '🇺🇸 /maɪ neɪmz tɒm/', meaning: 'Tên mình là Tom' },
        { word: 'Goodbye', emoji: '👋', ipa: '🇺🇸 /ˌɡʊdˈbaɪ/', meaning: 'Tạm biệt' },
        { word: 'How old are you?', emoji: '🎂', ipa: '🇺🇸 /haʊ oʊld ɑːr juː/', meaning: 'Bạn bao nhiêu tuổi?' },
        { word: "I's eight", emoji: '8️⃣', ipa: '🇺🇸 /aɪz eɪt/', meaning: 'Mình 8 tuổi' },
        { word: "I'm eight", emoji: '8️⃣', ipa: '🇺🇸 /aɪm eɪt/', meaning: 'Mình 8 tuổi' },
        { word: 'What color is it', emoji: '🎨', ipa: '🇺🇸 /wɒt ˈkʌl.ər ɪz ɪt/', meaning: 'Nó có màu gì?' },
        { word: "It's yellow", emoji: '🟨', ipa: '🇺🇸 /ɪts ˈjel.oʊ/', meaning: 'Nó màu vàng' },
        { word: 'Open your book', emoji: '📖', ipa: '🇺🇸 /ˈoʊ.pən jɔːr bʊk/', meaning: 'Mở sách ra' },
        { word: 'Close your book', emoji: '📕', ipa: '🇺🇸 /kloʊz jɔːr bʊk/', meaning: 'Đóng sách lại' },
        { word: 'Hands down', emoji: '👇', ipa: '🇺🇸 /hændz daʊn/', meaning: 'Hạ tay xuống' },
        { word: 'Hands up', emoji: '🙋', ipa: '🇺🇸 /hændz ʌp/', meaning: 'Giơ tay lên' },
        { word: 'Sit down', emoji: '🪑', ipa: '🇺🇸 /sɪt daʊn/', meaning: 'Ngồi xuống' },
        { word: 'Stand up', emoji: '🧍', ipa: '🇺🇸 /stænd ʌp/', meaning: 'Đứng lên' },
        { word: 'Hello', emoji: '👋', ipa: '🇺🇸 /həˈloʊ/', meaning: 'Xin chào' }
    ],
    School: [
        { word: 'Monday', emoji: '2', ipa: '🇺🇸 /ˈmʌn.deɪ/', meaning: 'Thứ hai' },
        { word: 'Tuesday', emoji: '3', ipa: '🇺🇸 /ˈtjuːz.deɪ/', meaning: 'Thứ ba' },
        { word: 'Wednesday', emoji: '4', ipa: '🇺🇸 /ˈwenz.deɪ/', meaning: 'Thứ tư' },
        { word: 'Thursday', emoji: '5', ipa: '🇺🇸 /ˈθɝːz.deɪ/', meaning: 'Thứ năm' },
        { word: 'Friday', emoji: '6', ipa: '🇺🇸 /ˈfraɪ.deɪ/', meaning: 'Thứ sáu' },
        { word: 'Saturday', emoji: '7', ipa: '🇺🇸 /ˈsæt̬.ɚ.deɪ/', meaning: 'Thứ bảy' },
        { word: 'Sunday', emoji: 'Chủ nhật', ipa: '🇺🇸 /ˈsʌn.deɪ/', meaning: 'Chủ nhật' },
        { word: 'Morning', emoji: '🌅', ipa: '🇺🇸 /ˈmɔːr.nɪŋ/', meaning: 'Buổi sáng' },
        { word: 'Afternoon', emoji: '☀️', ipa: '🇺🇸 /ˌæf.tɚˈnuːn/', meaning: 'Buổi chiều' },
        { word: 'Evening', emoji: '🌆', ipa: '🇺🇸 /ˈiːv.nɪŋ/', meaning: 'Buổi tối' },
        { word: 'Night', emoji: '🌙', ipa: '🇺🇸 /naɪt/', meaning: 'Ban đêm' },
        { word: 'Math', emoji: '🧮', ipa: '🇺🇸 /mæθ/', meaning: 'Môn toán' },
        { word: 'English', emoji: '🇬🇧', ipa: '🇺🇸 /ˈɪŋ.ɡlɪʃ/', meaning: 'Môn tiếng Anh' },
        { word: 'P.E (physical education)', emoji: '🏃', ipa: '🇺🇸 /ˌfɪz.ɪ.kəl ed.jʊˈkeɪ.ʃən/', meaning: 'Môn thể dục' },
        { word: 'Music', emoji: '🎵', ipa: '🇺🇸 /ˈmjuː.zɪk/', meaning: 'Môn âm nhạc' },
        { word: 'Art', emoji: '🎨', ipa: '🇺🇸 /ɑːrt/', meaning: 'Môn mỹ thuật' },
        { word: 'eraser', emoji: '🧼', ipa: '🇺🇸 /ˈɪˈreɪsər/', meaning: 'cục tẩy' },
        { word: 'ruler', emoji: '📏', ipa: '🇺🇸 /ˈruː.lɚ/', meaning: 'thước kẻ' },
        { word: 'pencil', emoji: '✏️', ipa: '🇺🇸 /ˈpen.səl/', meaning: 'bút chì' },
        { word: 'notebook', emoji: '📓', ipa: '🇺🇸 /ˈnoʊt.bʊk/', meaning: 'vở ghi' },
        { word: 'pencil case', emoji: '👝', ipa: '🇺🇸 /ˈpen.səl keɪs/', meaning: 'hộp bút' },
        { word: 'Is this your eraser?', emoji: '🧼❓', ipa: '🇺🇸 /ɪz ðɪs jɔːr ɪˈreɪsər/', meaning: 'Đây có phải cục tẩy của bạn không?' },
        { word: 'yes, it is', emoji: '✅', ipa: '🇺🇸 /jes ɪt ɪz/', meaning: 'Vâng, đúng vậy' },
        { word: "No, it isn't", emoji: '❌', ipa: '🇺🇸 /noʊ ɪt ˈɪznt/', meaning: 'Không, không phải' },
        { word: 'are these your notebook?', emoji: '📓❓', ipa: '🇺🇸 /ɑːr ðiːz jɔːr ˈnoʊt.bʊk/', meaning: 'Đây có phải là những cuốn vở của bạn không?' },
        { word: 'yes they are', emoji: '✅', ipa: '🇺🇸 /jes ðeɪ ɑːr/', meaning: 'Vâng, đúng vậy' },
        { word: "No, they aren't", emoji: '❌', ipa: '🇺🇸 /noʊ ðeɪ ɑːrnt/', meaning: 'Không, không phải' },
        { word: 'Do you like math?', emoji: '❓', ipa: '🇺🇸 /duː juː laɪk mæθ/', meaning: 'Bạn có thích môn toán không?' },
        { word: 'Yes, I do', emoji: '🙋', ipa: '🇺🇸 /jes aɪ duː/', meaning: 'Có, mình thích' },
        { word: 'When do you have English?', emoji: '📅🇬🇧❓', ipa: '🇺🇸 /wen duː juː hæv ˈɪŋ.ɡlɪʃ/', meaning: 'Khi nào bạn có môn tiếng Anh?' },
        { word: 'I have English on Wednesdays and Fridays', emoji: '📅🇬🇧', ipa: '🇺🇸 /aɪ hæv ˈɪŋ.ɡlɪʃ ɑːn ˈwenz.deɪz ænd ˈfraɪ.deɪz/', meaning: 'Mình có môn tiếng Anh vào thứ Tư và thứ Sáu' },
        { word: "What's your favorite color?", emoji: '🎨❓', ipa: '🇺🇸 /wɒts jɔːr ˈfeɪ.vər.ɪt ˈkʌl.ər/', meaning: 'Màu sắc yêu thích của bạn là gì?' },
        { word: 'My favorite color is orange', emoji: '🍊', ipa: '🇺🇸 /maɪ ˈfeɪ.vər.ɪt ˈkʌl.ər ɪz ˈɒr.ɪndʒ/', meaning: 'Màu sắc yêu thích của mình là màu cam' },
        { word: 'I can make orange with yellow and red', emoji: '🟨➕🟥🟰🟧', ipa: '🇺🇸 /aɪ kæn meɪk ˈɒr.ɪndʒ wɪð ˈjel.oʊ ænd red/', meaning: 'Mình có thể tạo màu cam bằng màu vàng và màu đỏ' },
        { word: 'Green', emoji: '🟩', ipa: '🇺🇸 /ɡriːn/', meaning: 'Màu xanh lá' },
        { word: 'orange', emoji: '🟧', ipa: '🇺🇸 /ˈɒr.ɪndʒ/', meaning: 'Màu cam' },
        { word: 'pink', emoji: '💗', ipa: '🇺🇸 /pɪŋk/', meaning: 'Màu hồng' },
        { word: 'purple', emoji: '🟪', ipa: '🇺🇸 /ˈpɜː.pəl/', meaning: 'Màu tím' },
        { word: 'gray', emoji: '⚪', ipa: '🇺🇸 /ɡreɪ/', meaning: 'Màu xám' },
        { word: 'favorite', emoji: '❤️', ipa: '🇺🇸 /ˈfeɪ.vər.ɪt/', meaning: 'yêu thích' },
        { word: 'red', emoji: '🟥', ipa: '🇺🇸 /red/', meaning: 'Màu đỏ' },
        { word: 'yellow', emoji: '🟨', ipa: '🇺🇸 /ˈjel.oʊ/', meaning: 'Màu vàng' },
        { word: 'blue', emoji: '🟦', ipa: '🇺🇸 /bluː/', meaning: 'Màu xanh dương' },
        { word: 'black', emoji: '⬛', ipa: '🇺🇸 /blæk/', meaning: 'Màu đen' },
        { word: 'white', emoji: '⬜', ipa: '🇺🇸 /waɪt/', meaning: 'Màu trắng' }
    ],
    Family: [
        { word: 'Cake', emoji: '🎂', ipa: '🇺🇸 /keɪk/', meaning: 'Bánh kem' },
        { word: 'Gift', emoji: '🎁', ipa: '🇺🇸 /ɡɪft/', meaning: 'Quà tặng' },
        { word: 'Balloon', emoji: '🎈', ipa: '🇺🇸 /bəˈluːn/', meaning: 'Bóng bay' },
        { word: 'father', emoji: '👨', ipa: '🇺🇸 /ˈfɑː.ðɚ/', meaning: 'bố/cha' },
        { word: 'mother', emoji: '👩', ipa: '🇺🇸 /ˈmʌð.ɚ/', meaning: 'mẹ' },
        { word: 'brother', emoji: '👦', ipa: '🇺🇸 /ˈbrʌð.ɚ/', meaning: 'anh/em trai' },
        { word: 'sister', emoji: '👧', ipa: '🇺🇸 /ˈsɪs.tɚ/', meaning: 'chị/em gái' },
        { word: 'uncle', emoji: '👨‍💼', ipa: '🇺🇸 /ˈʌŋ.kəl/', meaning: 'chú/bác/cậu' },
        { word: 'aunt', emoji: '👩‍💼', ipa: '🇺🇸 /ænt/', meaning: 'cô/dì/bác gái' },
        { word: 'cousin', emoji: '🧑‍🤝‍🧑', ipa: '🇺🇸 /ˈkʌz.ən/', meaning: 'anh chị em họ' },
        { word: 'do your homework', emoji: '✍️', ipa: '🇺🇸 /duː jɔːr ˈhoʊm.wɝːk/', meaning: 'làm bài tập về nhà' },
        { word: 'clean your room', emoji: '🧹', ipa: '🇺🇸 /kliːn jɔːr ruːm/', meaning: 'dọn dẹp phòng' },
        { word: 'wake up', emoji: '⏰🌅', ipa: '🇺🇸 /weɪk ʌp/', meaning: 'thức dậy' },
        { word: 'go to bed', emoji: '🛌🌙', ipa: '🇺🇸 /goʊ tə bed/', meaning: 'đi ngủ' },
        { word: 'dog', emoji: '🐶', ipa: '🇺🇸 /dɔːɡ/', meaning: 'con chó' },
        { word: 'fish', emoji: '🐟', ipa: '🇺🇸 /fɪʃ/', meaning: 'con cá' },
        { word: 'cat', emoji: '🐱', ipa: '🇺🇸 /kæt/', meaning: 'con mèo' },
        { word: 'bird', emoji: '🐦', ipa: '🇺🇸 /bɝːd/', meaning: 'con chim' },
        { word: "i like my cat", emoji: '🐱❤️', ipa: '🇺🇸 /aɪ laɪk maɪ kæt/', meaning: 'mình thích con mèo của mình' },
        { word: "i love dogs", emoji: '🐶💖', ipa: '🇺🇸 /aɪ lʌv dɔːɡz/', meaning: 'mình yêu những chú chó' },
        { word: "i don't like fishs", emoji: '🐟❌', ipa: '🇺🇸 /aɪ doʊnt laɪk fɪʃɪz/', meaning: 'mình không thích cá' },
        { word: "Who's she?", emoji: '👩❓', ipa: '🇺🇸 /huːz ʃiː/', meaning: 'Cô ấy là ai?' },
        { word: "She's my aunt", emoji: '👩‍💼', ipa: '🇺🇸 /ʃiːz maɪ ænt/', meaning: 'Cô ấy là dì/cô của mình' },
        { word: "What's her name?", emoji: '📛👩❓', ipa: '🇺🇸 /wɒts hɜː neɪm/', meaning: 'Tên cô ấy là gì?' },
        { word: "Her name's May", emoji: '👩📛', ipa: '🇺🇸 /hɜː neɪmz meɪ/', meaning: 'Tên cô ấy là May' },
        { word: "This is my father", emoji: '👨👈', ipa: '🇺🇸 /ðɪs ɪz maɪ ˈfɑː.ðɚ/', meaning: 'Đây là bố của mình' },
        { word: "Hello, I'm Alfie", emoji: '🙋‍♂️💬', ipa: '🇺🇸 /həˈloʊ aɪm ˈæl.fi/', meaning: 'Xin chào, mình là Alfie' },
        { word: "Hello Alfie", emoji: '👋👦', ipa: '🇺🇸 /həˈloʊ ˈæl.fi/', meaning: 'Xin chào Alfie' }
    ],
    Home: [
        { word: 'living room', emoji: '🛋️', ipa: '🇺🇸 /ˈlɪv.ɪŋ ruːm/', meaning: 'phòng khách' },
        { word: 'bedroom', emoji: '🛏️', ipa: '🇺🇸 /ˈbed.ruːm/', meaning: 'phòng ngủ' },
        { word: 'kitchen', emoji: '🍳', ipa: '🇺🇸 /ˈkɪtʃ.ən/', meaning: 'nhà bếp' },
        { word: 'bathroom', emoji: '🛁', ipa: '🇺🇸 /ˈbæθ.ruːm/', meaning: 'phòng tắm' },
        { word: 'yard', emoji: '🏡', ipa: '🇺🇸 /jɑːrd/', meaning: 'sân vườn' },
        { word: 'cleaning', emoji: '🧹', ipa: '🇺🇸 /ˈkliː.nɪŋ/', meaning: 'dọn dẹp' },
        { word: 'playing', emoji: '🎮', ipa: '🇺🇸 /ˈpleɪ.ɪŋ/', meaning: 'đang chơi' },
        { word: 'eating', emoji: '🍽️', ipa: '🇺🇸 /ˈiː.tɪŋ/', meaning: 'đang ăn' },
        { word: 'sleeping', emoji: '😴', ipa: '🇺🇸 /ˈsliː.pɪŋ/', meaning: 'đang ngủ' },
        { word: 'cooking', emoji: '👩‍🍳', ipa: '🇺🇸 /ˈkʊk.ɪŋ/', meaning: 'đang nấu ăn' },
        { word: 'mirror', emoji: '🪞', ipa: '🇺🇸 /ˈmɪr.ɚ/', meaning: 'gương soi' },
        { word: 'picture', emoji: '🖼️', ipa: '🇺🇸 /ˈpɪk.tʃɚ/', meaning: 'bức tranh' },
        { word: 'sofa', emoji: '🛋️', ipa: '🇺🇸 /ˈsoʊ.fə/', meaning: 'ghế sofa' },
        { word: 'table', emoji: '🟫', ipa: '🇺🇸 /ˈteɪ.bəl/', meaning: 'cái bàn' },
        { word: 'box', emoji: '📦', ipa: '🇺🇸 /bɑːks/', meaning: 'cái hộp' },
        { word: 'house', emoji: '🏠', ipa: '🇺🇸 /haʊs/', meaning: 'ngôi nhà' },
        { word: 'bed', emoji: '🛏️', ipa: '🇺🇸 /bed/', meaning: 'cái giường' },
        { word: 'closet', emoji: '🚪', ipa: '🇺🇸 /ˈklɑː.zɪt/', meaning: 'tủ quần áo' },
        { word: 'chair', emoji: '🪑', ipa: '🇺🇸 /tʃer/', meaning: 'cái ghế' },
        { word: 'desk', emoji: '🟫', ipa: '🇺🇸 /desk/', meaning: 'bàn học' },
        { word: 'TV', emoji: '📺', ipa: '🇺🇸 /ˌtiːˈviː/', meaning: 'tivi' },
        { word: "Where's dad?", emoji: '👨❓', ipa: '🇺🇸 /werz dæd/', meaning: 'Bố ở đâu rồi?' },
        { word: "He's in the yard", emoji: '👨🏡', ipa: '🇺🇸 /hiːz ɪn ðə jɑːrd/', meaning: 'Bố đang ở ngoài sân' },
        { word: "What's he doing", emoji: '👨❓', ipa: '🇺🇸 /wɒts hiː ˈduː.ɪŋ/', meaning: 'Bố đang làm gì thế?' },
        { word: "He's Sleeping", emoji: '👨😴', ipa: '🇺🇸 /hiːz ˈsliː.pɪŋ/', meaning: 'Bố đang ngủ' },
        { word: 'Is the picture in the living room?', emoji: '🖼️🛋️❓', ipa: '🇺🇸 /ɪz ðə ˈpɪk.tʃɚ ɪn ðə ˈlɪv.ɪŋ ruːm/', meaning: 'Bức tranh có ở trong phòng khách không?' },
        { word: 'I live on La Thanh Street in Ha Noi', emoji: '🏠🇻🇳', ipa: '🇺🇸 /aɪ lɪv ɑːn la tʰaːŋ striːt ɪn haː noɪ/', meaning: 'Mình sống ở phố La Thành, Hà Nội' },
        { word: 'My Bedroom has a bed, a TV, and two chairs', emoji: '🛏️📺🪑', ipa: '🇺🇸 /maɪ ˈbed.ruːm hæz ə bed ə ˌtiːˈviː ænd tuː tʃerz/', meaning: 'Phòng ngủ của mình có một chiếc giường, một chiếc tivi và hai chiếc ghế' }
    ],
    SportHobbies: [
        { word: 'Badminton', emoji: '🏸', ipa: '🇺🇸 /ˈbæd.mɪn.tən/', meaning: 'môn cầu lông' },
        { word: 'Tennis', emoji: '🎾', ipa: '🇺🇸 /ˈten.ɪs/', meaning: 'môn quần vợt' },
        { word: 'Volleyball', emoji: '🏐', ipa: '🇺🇸 /ˈvɑː.li.bɔːl/', meaning: 'môn bóng chuyền' },
        { word: 'Basketball', emoji: '🏀', ipa: '🇺🇸 /ˈbæs.kət.bɑːl/', meaning: 'môn bóng rổ' },
        { word: 'Soccer', emoji: '⚽', ipa: '🇺🇸 /ˈsɑː.kɚ/', meaning: 'môn bóng đá' },
        { word: 'hitting', emoji: '🏏', ipa: '🇺🇸 /ˈhɪt.ɪŋ/', meaning: 'đang đánh (bóng)' },
        { word: 'kicking', emoji: '⚽', ipa: '🇺🇸 /ˈkɪk.ɪŋ/', meaning: 'đang đá (bóng)' },
        { word: 'catching', emoji: '🤲', ipa: '🇺🇸 /ˈkætʃ.ɪŋ/', meaning: 'đang bắt (bóng)' },
        { word: 'throwing', emoji: '🤾', ipa: '🇺🇸 /ˈθroʊ.ɪŋ/', meaning: 'đang ném (bóng)' },
        { word: 'watch TV', emoji: '📺', ipa: '🇺🇸 /wɑːtʃ ˌtiːˈviː/', meaning: 'xem tivi' },
        { word: 'go Skateboarding', emoji: '🛹', ipa: '🇺🇸 /ɡoʊ ˈskeɪt.bɔːr.dɪŋ/', meaning: 'đi trượt ván' },
        { word: 'go out', emoji: '🚪🏃', ipa: '🇺🇸 /ɡoʊ aʊt/', meaning: 'đi ra ngoài' },
        { word: 'go swimming', emoji: '🏊', ipa: '🇺🇸 /ɡoʊ ˈswɪm.ɪŋ/', meaning: 'đi bơi' },
        { word: 'hand', emoji: '✋', ipa: '🇺🇸 /hænd/', meaning: 'bàn tay' },
        { word: 'arm', emoji: '💪', ipa: '🇺🇸 /ɑːrm/', meaning: 'cánh tay' },
        { word: 'foot', emoji: '🦶', ipa: '🇺🇸 /fʊt/', meaning: 'bàn chân' },
        { word: 'leg', emoji: '🦵', ipa: '🇺🇸 /leɡ/', meaning: 'cái chân' },
        { word: 'head', emoji: '👤', ipa: '🇺🇸 /hed/', meaning: 'cái đầu' },
        { word: 'body', emoji: '🧍', ipa: '🇺🇸 /ˈbɑː.di/', meaning: 'cơ thể' },
        { word: 'Can you play soccer?', emoji: '⚽❓', ipa: '🇺🇸 /kæn juː pleɪ ˈsɑː.kɚ/', meaning: 'Bạn có biết chơi bóng đá không?' },
        { word: 'Yes, I can', emoji: '✅', ipa: '🇺🇸 /jes aɪ kæn/', meaning: 'Có, mình có thể' },
        { word: "No, I can't", emoji: '❌', ipa: '🇺🇸 /noʊ aɪ kænt/', meaning: 'Không, mình không thể' },
        { word: 'What are you good at?', emoji: '🌟❓', ipa: '🇺🇸 /wɒt ɑːr juː ɡʊd æt/', meaning: 'Bạn giỏi về môn gì/hoạt động gì?' },
        { word: "I'm good at kicking", emoji: '⚽🏃', ipa: '🇺🇸 /aɪm ɡʊd æt ˈkɪk.ɪŋ/', meaning: 'Mình giỏi đá bóng' },
        { word: 'May I watch TV?', emoji: '📺❓', ipa: '🇺🇸 /meɪ aɪ wɑːtʃ ˌtiːˈviː/', meaning: 'Con có thể xem tivi không?' },
        { word: 'Yes, I may', emoji: '✅', ipa: '🇺🇸 /jes aɪ meɪ/', meaning: 'Có, con có thể' },
        { word: 'No, you may not', emoji: '❌', ipa: '🇺🇸 /noʊ juː meɪ nɒt/', meaning: 'Không, con không được phép' },
        { word: 'I use my legs and feet in soccer', emoji: '🦵🦶⚽', ipa: '🇺🇸 /aɪ juːz maɪ leɡz ænd fiːt ɪn ˈsɑː.kɚ/', meaning: 'Mình sử dụng chân và bàn chân trong môn bóng đá' },
        { word: 'i can kick the ball in soccer', emoji: '⚽👟', ipa: '🇺🇸 /aɪ kæn kɪk ðə bɔːl ɪn ˈsɑː.kɚ/', meaning: 'Mình có thể đá bóng trong môn bóng đá' },
        { word: "I can't kick the ball in Basketball", emoji: '🏀❌', ipa: '🇺🇸 /aɪ kænt kɪk ðə bɔːl ɪn ˈbæs.kət.bɑːl/', meaning: 'Mình không được đá bóng trong môn bóng rổ' }
    ],
    Clothes: [
        { word: 'dress', emoji: '👗', ipa: '🇺🇸 /dres/', meaning: 'váy liền' },
        { word: 'shirt', emoji: '👕', ipa: '🇺🇸 /ʃɝːt/', meaning: 'áo sơ mi' },
        { word: 'shorts', emoji: '🩳', ipa: '🇺🇸 /ʃɔːrts/', meaning: 'quần đùi' },
        { word: 'socks', emoji: '🧦', ipa: '🇺🇸 /sɑːks/', meaning: 'đôi tất' },
        { word: 'pants', emoji: '👖', ipa: '🇺🇸 /pænts/', meaning: 'quần dài' },
        { word: 'skirt', emoji: '👗', ipa: '🇺🇸 /skɝːt/', meaning: 'chân váy' },
        { word: 'jacket', emoji: '🧥', ipa: '🇺🇸 /ˈdʒæk.ɪt/', meaning: 'áo khoác' },
        { word: 'jeans', emoji: '👖', ipa: '🇺🇸 /dʒiːnz/', meaning: 'quần jean' },
        { word: 'boots', emoji: '🥾', ipa: '🇺🇸 /buːts/', meaning: 'đôi ủng' },
        { word: 'T-shirt', emoji: '👕', ipa: '🇺🇸 /ˈtiː.ʃɝːt/', meaning: 'áo thun' }
    ],

    Fruits: [
        { word: 'Apple', emoji: '🍎', ipa: '🇺🇸 /ˈæp.əl/', meaning: 'Táo' },
        { word: 'Banana', emoji: '🍌', ipa: '🇺🇸 /bəˈnæn.ə/', meaning: 'Chuối' },
        { word: 'Orange', emoji: '🍊', ipa: '🇺🇸 /ˈɔːr.ɪndʒ/', meaning: 'Cam' },
        { word: 'Grapes', emoji: '🍇', ipa: '🇺🇸 /ɡreɪps/', meaning: 'Nho' },
        { word: 'Strawberry', emoji: '🍓', ipa: '🇺🇸 /ˈstrɔːˌber.i/', meaning: 'Dâu tây' },
        { word: 'Watermelon', emoji: '🍉', ipa: '🇺🇸 /ˈwɑː.t̬ɚˌmel.ən/', meaning: 'Dưa hấu' },
        { word: 'Pineapple', emoji: '🍍', ipa: '🇺🇸 /ˈpaɪn.æp.əl/', meaning: 'Dứa' },
        { word: 'Cherry', emoji: '🍒', ipa: '🇺🇸 /ˈtʃer.i/', meaning: 'Anh đào' },
        { word: 'Mango', emoji: '🥭', ipa: '🇺🇸 /ˈmæŋ.ɡoʊ/', meaning: 'Xoài' },
        { word: 'Pear', emoji: '🍐', ipa: '🇺🇸 /per/', meaning: 'Lê' },
        { word: 'Kiwi', emoji: '🥝', ipa: '🇺🇸 /ˈkiːwi/', meaning: 'Kiwi' },
        { word: 'Papaya', emoji: '🥭', ipa: '🇺🇸 /pæˈpaɪ.ə/', meaning: 'Đu đủ' },
        { word: 'Peach', emoji: '🍑', ipa: '🇺🇸 /piːtʃ/', meaning: 'Đào' },
        { word: 'Plum', emoji: '🍈', ipa: '🇺🇸 /plʌm/', meaning: 'Mận' },
        { word: 'Lemon', emoji: '🍋', ipa: '🇺🇸 /ˈlɛm.ən/', meaning: 'Chanh vàng' },
        { word: 'Lime', emoji: '🍈', ipa: '🇺🇸 /laɪm/', meaning: 'Chanh xanh' },
    ],
    Verbs: [
        { word: 'Run', emoji: '🏃', ipa: '🇺🇸 /rʌn/', meaning: 'Chạy' },
        { word: 'Jump', emoji: '🤾', ipa: '🇺🇸 /dʒʌmp/', meaning: 'Nhảy' },
        { word: 'Swim', emoji: '🏊', ipa: '🇺🇸 /swɪm/', meaning: 'Bơi' },
        { word: 'Fly', emoji: '🪂', ipa: '🇺🇸 /flaɪ/', meaning: 'Bay' },
        { word: 'Sing', emoji: '🎤', ipa: '🇺🇸 /sɪŋ/', meaning: 'Hát' },
        { word: 'Dance', emoji: '💃', ipa: '🇺🇸 /dæns/', meaning: 'Nhảy múa' },
        { word: 'Think', emoji: '🤔', ipa: '🇺🇸 /θɪŋk/', meaning: 'Suy nghĩ' },
        { word: 'Listen', emoji: '👂', ipa: '🇺🇸 /ˈlɪs.ən/', meaning: 'Lắng nghe' },
        { word: 'Watch', emoji: '📺', ipa: '🇺🇸 /wɒtʃ/', meaning: 'Xem' },
        { word: 'Cook', emoji: '👩‍🍳', ipa: '🇺🇸 /kʊk/', meaning: 'Nấu ăn' },
        { word: 'Drive', emoji: '🚗', ipa: '🇺🇸 /draɪv/', meaning: 'Lái xe' },
        { word: 'Buy', emoji: '🛒', ipa: '🇺🇸 /baɪ/', meaning: 'Mua' },
        { word: 'Sell', emoji: '💰', ipa: '🇺🇸 /sɛl/', meaning: 'Bán' },
        { word: 'Help', emoji: '🤝', ipa: '🇺🇸 /hɛlp/', meaning: 'Giúp đỡ' },
        { word: 'Play', emoji: '🎮', ipa: '🇺🇸 /pleɪ/', meaning: 'Chơi' },
        { word: 'Study', emoji: '📚', ipa: '🇺🇸 /ˈstʌdi/', meaning: 'Học' },
        { word: 'Travel', emoji: '✈️', ipa: '🇺🇸 /ˈtrævəl/', meaning: 'Du lịch' },
        { word: 'Build', emoji: '🔨', ipa: '🇺🇸 /bɪld/', meaning: 'Xây dựng' },
        { word: 'Clean', emoji: '🧹', ipa: '🇺🇸 /kliːn/', meaning: 'Lau dọn' },
        { word: 'Sleep', emoji: '😴', ipa: '🇺🇸 /sliːp/', meaning: 'Ngủ' },
        { word: 'Read', emoji: '📖', ipa: '🇺🇸 /riːd/', meaning: 'Đọc' },
        { word: 'Write', emoji: '✍️', ipa: '🇺🇸 /raɪt/', meaning: 'Viết' },
        { word: 'Draw', emoji: '🖍️', ipa: '🇺🇸 /drɔː/', meaning: 'Vẽ' },
        { word: 'Speak', emoji: '🗣️', ipa: '🇺🇸 /spiːk/', meaning: 'Nói' },
        { word: 'Climb', emoji: '🧗', ipa: '🇺🇸 /klaɪm/', meaning: 'Leo trèo' },
        { word: 'Throw', emoji: '🏈', ipa: '🇺🇸 /θroʊ/', meaning: 'Ném' },
        { word: 'Catch', emoji: '🤲', ipa: '🇺🇸 /kætʃ/', meaning: 'Bắt lấy' },
        { word: 'Kick', emoji: '🥾', ipa: '🇺🇸 /kɪk/', meaning: 'Đá' },
        { word: 'Hit', emoji: '👊', ipa: '🇺🇸 /hɪt/', meaning: 'Đánh' },
        { word: 'Push', emoji: '🤜', ipa: '🇺🇸 /pʊʃ/', meaning: 'Đẩy' },
        { word: 'Pull', emoji: '🤚', ipa: '🇺🇸 /pʊl/', meaning: 'Kéo' },
        { word: 'Open', emoji: '🚪', ipa: '🇺🇸 /ˈoʊ.pən/', meaning: 'Mở' },
        { word: 'Close', emoji: '🔒', ipa: '🇺🇸 /kloʊz/', meaning: 'Đóng' },
        { word: 'Turn', emoji: '🔄', ipa: '🇺🇸 /tɜːrn/', meaning: 'Xoay' },
        { word: 'Smile', emoji: '😊', ipa: '🇺🇸 /smaɪl/', meaning: 'Mỉm cười' },
        { word: 'Laugh', emoji: '😂', ipa: '🇺🇸 /læf/', meaning: 'Cười lớn' },
        { word: 'Cry', emoji: '😢', ipa: '🇺🇸 /kraɪ/', meaning: 'Khóc' },
        { word: 'Pray', emoji: '🙏', ipa: '🇺🇸 /preɪ/', meaning: 'Cầu nguyện' },
        { word: 'Meditate', emoji: '🧘', ipa: '🇺🇸 /ˈmɛdɪteɪt/', meaning: 'Thiền' },
        { word: 'Celebrate', emoji: '🥳', ipa: '🇺🇸 /ˈsɛləbreɪt/', meaning: 'Ăn mừng' },
        { word: 'Explore', emoji: '🧭', ipa: '🇺🇸 /ɪkˈsplɔːr/', meaning: 'Khám phá' },
        { word: 'Discover', emoji: '🔎', ipa: '🇺🇸 /dɪsˈkʌvər/', meaning: 'Phát hiện' },
        { word: 'Choose', emoji: '🤔', ipa: '🇺🇸 /tʃuːz/', meaning: 'Chọn' },
        { word: 'Decide', emoji: '✅', ipa: '🇺🇸 /dɪˈsaɪd/', meaning: 'Quyết định' },
        { word: 'Remember', emoji: '🧠', ipa: '🇺🇸 /rɪˈmɛm.bɚ/', meaning: 'Ghi nhớ' },
        { word: 'Forget', emoji: '❌', ipa: '🇺🇸 /fərˈɡɛt/', meaning: 'Quên' },
        { word: 'Grow', emoji: '🌱', ipa: '🇺🇸 /ɡroʊ/', meaning: 'Lớn lên' },
        { word: 'Shrink', emoji: '📏', ipa: '🇺🇸 /ʃrɪŋk/', meaning: 'Co lại' },
        { word: 'Paint', emoji: '🎨', ipa: '🇺🇸 /peɪnt/', meaning: 'Tô màu' },
        { word: 'Sew', emoji: '🧵', ipa: '🇺🇸 /soʊ/', meaning: 'May vá' },
        { word: 'Code', emoji: '💻', ipa: '🇺🇸 /koʊd/', meaning: 'Lập trình' },
        { word: 'Teach', emoji: '👩‍🏫', ipa: '🇺🇸 /tiːtʃ/', meaning: 'Dạy học' },
        { word: 'Bark', emoji: '🐶', ipa: '🇺🇸 /bɑːrk/', meaning: 'Sủa' },
        { word: 'Meow', emoji: '🐱', ipa: '🇺🇸 /miˈaʊ/', meaning: 'Kêu meo meo' },
    ],

    Colors: [
        { word: 'Red', emoji: '🟥', ipa: '🇺🇸 /red/', meaning: 'Màu đỏ' },
        { word: 'Blue', emoji: '🟦', ipa: '🇺🇸 /bluː/', meaning: 'Màu xanh dương' },
        { word: 'Green', emoji: '🟩', ipa: '🇺🇸 /ɡriːn/', meaning: 'Màu xanh lá' },
        { word: 'Yellow', emoji: '🟨', ipa: '🇺🇸 /ˈjel.oʊ/', meaning: 'Màu vàng' },
        { word: 'Purple', emoji: '🟪', ipa: '🇺🇸 /ˈpɝː.pəl/', meaning: 'Màu tím' },
        { word: 'Orange', emoji: '🟧', ipa: '🇺🇸 /ˈɔːr.ɪndʒ/', meaning: 'Màu cam' },
        { word: 'Pink', emoji: '💗', ipa: '🇺🇸 /pɪŋk/', meaning: 'Màu hồng' },
        { word: 'Black', emoji: '⬛', ipa: '🇺🇸 /blæk/', meaning: 'Màu đen' },
        { word: 'White', emoji: '⬜', ipa: '🇺🇸 /waɪt/', meaning: 'Màu trắng' },
        { word: 'Grey', emoji: '⚪', ipa: '🇺🇸 /ɡreɪ/', meaning: 'Màu xám' },
        { word: 'Brown', emoji: '🟫', ipa: '🇺🇸 /braʊn/', meaning: 'Màu nâu' },
        { word: 'Gold', emoji: '🟨', ipa: '🇺🇸 /ɡoʊld/', meaning: 'Màu vàng kim' },
        { word: 'Silver', emoji: '⚪', ipa: '🇺🇸 /ˈsɪl.vər/', meaning: 'Màu bạc' },

    ],
};

// Merged Vietnamese meanings directly into vocabData entries

// Meanings are now part of vocabData; no additional processing needed

let currentDifficulty = 'easy';

const difficultySettings = {
    easy: {
        time: 90,
        lives: 3,
        optionsCount: 2
    },
    medium: {
        time: 60,
        lives: 3,
        optionsCount: 4
    },
    hard: {
        time: 40,
        lives: 3,
        optionsCount: 8
    }
};

let categoryLives = {
    Fruits: 0,
    Colors: 0,
    School: 0,
    Verbs: 0,
    MyFriends: 0,
    Family: 0,
    Home: 0,
    SportHobbies: 0,
    Clothes: 0
};

function setDifficulty(level) {
    currentDifficulty = level;

    document.querySelectorAll('.diff-btn').forEach(btn => btn.classList.remove('active'));
    const activeBtn = document.getElementById('diff-' + level);
    if (activeBtn) {
        activeBtn.classList.add('active');
    }

    let voiceWord = 'Easy';
    if (level === 'medium') voiceWord = 'Medium';
    if (level === 'hard') voiceWord = 'Hard';

    const msg = new SpeechSynthesisUtterance(voiceWord);
    msg.lang = 'en-US';
    msg.rate = 1.0;
    window.speechSynthesis.speak(msg);
}

let currentCategory = '';
let score = 0;
let lives = 3;
let currentWord = null;
let options = [];
let isAnimating = false;
let timeRemaining = 60;
let timerInterval = null;
let remainingWords = [];
let isWaitingForCorrection = false;
let isPaused = false;
let categoryScores = {
    Fruits: 0,
    Colors: 0,
    School: 0,
    Verbs: 0,
    MyFriends: 0,
    Family: 0,
    Home: 0,
    SportHobbies: 0,
    Clothes: 0
};

// DOM Elements
const screenHome = document.getElementById('screen-home');
const screenGame = document.getElementById('screen-game');
const screenGameOver = document.getElementById('screen-game-over');
const categoryTitle = document.getElementById('game-category-title');
const scoreDisplay = document.getElementById('score-display');
const timerDisplay = document.getElementById('timer-display');
const finalScoreDisplay = document.getElementById('final-score');
const livesContainer = document.getElementById('lives-container');
const wordDisplay = document.getElementById('word-display');
const optionsGrid = document.getElementById('options-grid');
const rewardOverlay = document.getElementById('reward-overlay');
const timerBar = document.getElementById('timer-bar');

function showScreen(screen) {
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
    screen.classList.add('active');
}

function startGame(category) {
    console.log('Starting game for category:', category);
    if (!vocabData.hasOwnProperty(category)) {
        console.error('Category data missing for', category);
        alert('Sorry, data for this category is unavailable.');
        return;
    }

    currentCategory = category;
    score = 0;
    isWaitingForCorrection = false;
    isPaused = false;
    const pauseBtn = document.getElementById('btn-pause');
    if (pauseBtn) pauseBtn.innerText = '⏸️';
    const pauseOverlay = document.getElementById('pause-overlay');
    if (pauseOverlay) pauseOverlay.classList.remove('show');

    remainingWords = [...vocabData[category]];
    const perWordSec = { easy: 10, medium: 8, hard: 5 }[currentDifficulty] || 8;
    const totalTime = remainingWords.length * perWordSec; // total seconds for the round
    timeRemaining = totalTime;

    // Lives are still taken from difficulty settings.
    const settings = difficultySettings[currentDifficulty];
    lives = settings.lives;

    categoryTitle.innerText = category;
    scoreDisplay.innerText = score;
    timerDisplay.innerText = timeRemaining;

    // Store totalTime for percentage calculation in the timer bar.
    window.__gameTotalTime = totalTime; // temporary global for the timer interval

    if (timerBar) {
        timerBar.style.width = '100%';
        timerBar.classList.remove('low-time');
    }

    initLivesDisplay();
    showScreen(screenGame);
    nextQuestion();

    clearInterval(timerInterval);
    timerInterval = setInterval(() => {
        timeRemaining--;
        timerDisplay.innerText = timeRemaining;
        if (timerBar) {
            const total = window.__gameTotalTime || settings.time;
            const percentage = Math.max(0, (timeRemaining / total) * 100);
            timerBar.style.width = percentage + '%';
            if (timeRemaining <= 15) {
                timerBar.classList.add('low-time');
            } else {
                timerBar.classList.remove('low-time');
            }
        }
        if (timeRemaining <= 0) {
            clearInterval(timerInterval);
            updateCategoryScore();
            // Show Game Over screen instead of returning home.
            gameOver(false);
        }
    }, 1000);
}


function updateCategoryScore() {
    categoryScores[currentCategory] = Math.max(categoryScores[currentCategory] || 0, score);
    const catScoreDisplay = document.getElementById('score-' + currentCategory);
    if (catScoreDisplay) {
        catScoreDisplay.innerText = categoryScores[currentCategory];
    }

    const finalLives = Math.max(0, lives);
    categoryLives[currentCategory] = finalLives;
    const catLivesDisplay = document.getElementById('lives-' + currentCategory);
    if (catLivesDisplay) {
        let heartsHTML = '';
        for (let i = 0; i < finalLives; i++) {
            heartsHTML += '❤️';
        }
        if (finalLives === 0) {
            heartsHTML = '💔';
        }
        catLivesDisplay.innerText = heartsHTML;
    }
}

function initLivesDisplay() {
    livesContainer.innerHTML = '';
    const maxLives = difficultySettings[currentDifficulty].lives;
    for (let i = 0; i < maxLives; i++) {
        const heart = document.createElement('span');
        heart.className = 'heart';
        heart.innerText = '❤️';
        livesContainer.appendChild(heart);
    }
}

function updateLivesDisplay() {
    const hearts = livesContainer.querySelectorAll('.heart');
    hearts.forEach((heart, index) => {
        if (index >= lives) {
            heart.classList.add('lost');
        } else {
            heart.classList.remove('lost');
        }
    });
}

function playAudio() {
    if (!currentWord || isPaused) return;
    const utterance = new SpeechSynthesisUtterance(currentWord.word);
    utterance.lang = 'en-US';
    utterance.rate = 0.8; // Slower for kids
    utterance.pitch = 1.2;
    window.speechSynthesis.speak(utterance);
}

function nextQuestion() {
    isAnimating = false;
    const words = vocabData[currentCategory];

    if (remainingWords.length === 0) {
        gameOver(true);
        return;
    }

    const randomIndex = Math.floor(Math.random() * remainingWords.length);
    currentWord = remainingWords[randomIndex];
    remainingWords.splice(randomIndex, 1);

    // Pick wrong options based on difficulty settings
    const wrongOptionsCount = difficultySettings[currentDifficulty].optionsCount - 1;
    const wrongOptions = words.filter(w => w.word !== currentWord.word);
    wrongOptions.sort(() => 0.5 - Math.random());

    options = [currentWord, ...wrongOptions.slice(0, wrongOptionsCount)];
    options.sort(() => 0.5 - Math.random()); // Shuffle

    // Clear previous options
    optionsGrid.innerHTML = '';
    // Adjust grid columns based on difficulty
    const colsClass = {
        2: 'cols-2',
        4: 'cols-4',
        8: 'cols-8'
    }[difficultySettings[currentDifficulty].optionsCount];
    optionsGrid.className = `options-grid ${colsClass}`;

    // Render UI
    wordDisplay.innerText = currentWord.word;
    // Adapt font-size dynamically for longer sentences or words to look beautiful and prevent overflow
    if (currentWord.word.length > 12) {
        wordDisplay.style.fontSize = '2.2rem';
    } else {
        wordDisplay.style.fontSize = ''; // reset to stylesheet default (3.2rem)
    }
    // Update IPA display
    const ipaBadge = document.getElementById('ipa-display');
    if (ipaBadge) { ipaBadge.innerText = currentWord.ipa; }
    // Render options with emoji and meaning
    options.forEach((opt, index) => {
        const btn = document.createElement('div');
        btn.className = 'option-card';
        // Show emoji, optional flag image, and Vietnamese meaning
        btn.innerHTML = `<div class="emoji-display">${opt.emoji}</div>${opt.flagImg ? `<img src="${opt.flagImg}" class="flag-img">` : ''}<div class="meaning-text">${opt.meaning || ''}</div>`;
        btn.onclick = () => checkAnswer(opt, btn);
        optionsGrid.appendChild(btn);
    });

    // Auto play audio
    playAudio();
}

function checkAnswer(selectedOpt, btnElement) {
    if (isAnimating || isPaused) return;

    if (isWaitingForCorrection) {
        if (selectedOpt.word === currentWord.word) {
            isAnimating = true;
            btnElement.classList.remove('correct-glow');
            btnElement.classList.add('correct');

            rewardOverlay.classList.add('show');

            setTimeout(() => {
                rewardOverlay.classList.remove('show');
                isWaitingForCorrection = false;
                if (lives < 0) {
                    gameOver(false);
                } else {
                    nextQuestion();
                }
            }, 1500);
        }
        return;
    }

    isAnimating = true;

    if (selectedOpt.word === currentWord.word) {
        // Correct
        score += 10;
        scoreDisplay.innerText = score;
        btnElement.classList.add('correct');

        // Show reward animation
        rewardOverlay.classList.add('show');

        setTimeout(() => {
            rewardOverlay.classList.remove('show');
            nextQuestion();
        }, 1500);
    } else {
        // Wrong
        lives--;
        updateLivesDisplay();
        if (lives <= 0) {
            clearInterval(timerInterval);
            gameOver(false);
            return;
        }
        btnElement.classList.add('wrong');
        btnElement.classList.add('shake');

        // Show the correct emoji next to the target word immediately
        // Render UI
        wordDisplay.innerText = currentWord.word;
        // Update IPA display
        const ipaBadge = document.getElementById('ipa-display');
        if (ipaBadge) {
            ipaBadge.innerText = currentWord.ipa;
        }

        // Highlight correct answer card with glowing pulse
        const allCards = optionsGrid.querySelectorAll('.option-card');
        allCards.forEach(card => {
            if (card.innerText === currentWord.emoji) {
                card.classList.add('correct-glow');
            }
        });

        isWaitingForCorrection = true;
        isAnimating = false; // Allow click on correct answer to proceed
    }
}

function gameOver(isWin = false) {
    clearInterval(timerInterval);
    isPaused = false;
    const pauseBtn = document.getElementById('btn-pause');
    if (pauseBtn) pauseBtn.innerText = '⏸️';
    const pauseOverlay = document.getElementById('pause-overlay');
    if (pauseOverlay) pauseOverlay.classList.remove('show');
    updateCategoryScore();
    finalScoreDisplay.innerText = score;

    const gameOverTitle = document.getElementById('game-over-title');
    const finalScoreLabel = document.getElementById('final-score-label');

    if (isWin) {
        if (gameOverTitle) {
            gameOverTitle.innerText = "You Win! 🏆";
            gameOverTitle.style.color = "#FFD166";
        }
        if (finalScoreLabel) {
            finalScoreLabel.innerText = "Congratulations! Score";
        }

        const msg = new SpeechSynthesisUtterance("Congratulations! You won!");
        msg.lang = 'en-US';
        msg.rate = 1.0;
        window.speechSynthesis.speak(msg);
    } else {
        if (gameOverTitle) {
            gameOverTitle.innerText = "Game Over!";
            gameOverTitle.style.color = "white";
        }
        if (finalScoreLabel) {
            finalScoreLabel.innerText = "Your Score";
        }

        const msg = new SpeechSynthesisUtterance("Game Over");
        msg.lang = 'en-US';
        msg.rate = 1.0;
        window.speechSynthesis.speak(msg);
    }

    showScreen(screenGameOver);
}

function goHome() {
    clearInterval(timerInterval);
    isPaused = false;
    const pauseBtn = document.getElementById('btn-pause');
    if (pauseBtn) pauseBtn.innerText = '⏸️';
    const pauseOverlay = document.getElementById('pause-overlay');
    if (pauseOverlay) pauseOverlay.classList.remove('show');
    updateCategoryScore();
    showScreen(screenHome);
}

function restartGame() {
    startGame(currentCategory);
}

function togglePause() {
    if (!currentCategory || remainingWords.length === 0) return;

    isPaused = !isPaused;
    const pauseBtn = document.getElementById('btn-pause');
    const pauseOverlay = document.getElementById('pause-overlay');

    if (isPaused) {
        // Pause the game
        clearInterval(timerInterval);
        if (pauseBtn) pauseBtn.innerText = '▶️';
        if (pauseOverlay) pauseOverlay.classList.add('show');

        // Interrupt any speech output
        window.speechSynthesis.cancel();
    } else {
        // Resume the game
        if (pauseBtn) pauseBtn.innerText = '⏸️';
        if (pauseOverlay) pauseOverlay.classList.remove('show');

        // Re-read current word on resume
        playAudio();

        // Restart the timer interval
        clearInterval(timerInterval);
        const settings = difficultySettings[currentDifficulty];
        timerInterval = setInterval(() => {
            timeRemaining--;
            timerDisplay.innerText = timeRemaining;
            if (timerBar) {
                const total = window.__gameTotalTime || settings.time;
                const percentage = Math.max(0, (timeRemaining / total) * 100);
                timerBar.style.width = percentage + '%';
                if (timeRemaining <= 15) {
                    timerBar.classList.add('low-time');
                } else {
                    timerBar.classList.remove('low-time');
                }
            }
            if (timeRemaining <= 0) {
                clearInterval(timerInterval);
                updateCategoryScore();
                gameOver(false);
            }
        }, 1000);
    }
}
