/**
 * Phonics Quest — curriculum
 * Hệ thống: âm → cách viết → quy tắc → ngoại lệ → stress
 * Mỗi màn: Rule Core → Variation Zone → Boss Exception
 */
const W = (word, ipa, meaning) => ({ word, ipa, meaning });

const APP_META = {
  name: "Phonics Quest",
  tagline: "Học tiếng Anh từ âm → chữ → quy tắc → ngoại lệ → trọng âm",
  version: "3.0"
};

const IPA_CUE = {
  "/æ/": "a as in cat",
  "/e/": "e as in bed",
  "/ɪ/": "i as in sit",
  "/ɒ/": "o as in hot",
  "/ʌ/": "u as in cup",
  "/eɪ/": "ay as in cake",
  "/iː/": "ee as in see",
  "/aɪ/": "eye as in like",
  "/oʊ/": "oh as in home",
  "/əʊ/": "oh as in home",
  "/juː/": "you as in use",
  "/uː/": "oo as in blue",
  "/ʃ/": "sh as in ship",
  "/tʃ/": "ch as in chair",
  "/θ/": "th as in think",
  "/ð/": "th as in this",
  "/f/": "f as in phone",
  "/w/": "w as in what",
  "/k/": "k as in duck",
  "/ŋ/": "ng as in sing",
  "/ɔɪ/": "oy as in boy",
  "/aʊ/": "ow as in now",
  "/ɑː/": "ah as in car",
  "/ɜː/": "er as in her",
  "/ɔː/": "or as in fork",
  "/ə/": "uh as in about",
  "/ɪə/": "ear as in hear",
  "/eə/": "air as in bear",
  "/ʊ/": "u as in book"
};

function graphemeSpeak(g) {
  const key = String(g || "").toLowerCase();
  if (key.includes("_e")) return `${key[0].toUpperCase()} magic E`;
  if (key === "igh") return "I G H, silent G H";
  if (key.length === 2) return `${key[0].toUpperCase()} ${key[1].toUpperCase()} combined`;
  if (key.length === 3) return `${key.split("").join(" ").toUpperCase()} combined`;
  return key.split("").join(" ").toUpperCase();
}

function splitByGrapheme(word, grapheme) {
  const w = String(word || "").toLowerCase();
  const g = String(grapheme || "").toLowerCase();
  if (!w) return { prefix: "", suffix: "" };
  if (/^[aeiou]_e$/.test(g) && w.endsWith("e")) {
    const i = w.indexOf(g[0]);
    if (i >= 0) return { prefix: w.slice(0, i), suffix: w.slice(i + 1, -1) };
  }
  const i = w.indexOf(g.replace("_", ""));
  if (i >= 0) return { prefix: w.slice(0, i), suffix: w.slice(i + g.replace("_", "").length) };
  return { prefix: w.slice(0, 1), suffix: w.slice(-1) };
}

function ipaCue(ipa) {
  if (IPA_CUE[ipa]) return IPA_CUE[ipa];
  const found = Object.keys(IPA_CUE).find((k) => String(ipa).includes(k.slice(1, -1)));
  return found ? IPA_CUE[found] : "sound";
}

const WORLDS = [
  {
    id: "w1",
    number: 1,
    emoji: "🌱",
    color: "#38bdf8",
    title: "Letter → Sound",
    titleVi: "Chữ thành âm",
    blurb: "Nền móng: mỗi chữ cái gắn với một âm nền.",
    stages: [
      {
        id: "w1-vowels",
        title: "5 nguyên âm",
        subtitle: "a e i o u",
        spelling: "AEIOU",
        targetIpa: "/æ e ɪ ɒ ʌ/",
        speakWord: "apple",
        core: {
          rule: "Tiếng Anh có 5 chữ nguyên âm: A E I O U. Mỗi chữ có tên chữ (letter name) và âm nền (sound). Người mới học bắt đầu từ âm ngắn.",
          guide: "Đừng đọc a như 'ây' ngay. Ở World 2 bạn sẽ học âm ngắn. Ở đây chỉ nhớ 5 chữ và âm nền.",
          examples: [
            W("a", "æ", "chữ A — âm nền cat"),
            W("e", "e", "chữ E — âm nền bed"),
            W("i", "ɪ", "chữ I — âm nền sit"),
            W("o", "ɒ", "chữ O — âm nền hot (UK)"),
            W("u", "ʌ", "chữ U — âm nền cup")
          ]
        },
        variation: {
          intro: "Cùng một chữ, tên chữ khác âm nền. Đây là chiều 'nhìn chữ → đoán âm'.",
          branches: [
            { label: "Tên chữ (letter name)", ipa: "/eɪ iː aɪ oʊ juː/", examples: [W("A", "eɪ", "ây"), W("E", "iː", "i dài"), W("I", "aɪ", "ai"), W("O", "oʊ", "ô"), W("U", "juː", "yu")] },
            { label: "Âm nền ngắn", ipa: "/æ e ɪ ɒ ʌ/", examples: [W("cat", "kæt", "mèo"), W("bed", "bed", "giường"), W("sit", "sɪt", "ngồi"), W("hot", "hɒt", "nóng"), W("cup", "kʌp", "cốc")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "Y và W đôi khi làm nguyên âm. Đây là 'chữ giả nguyên âm'.",
          items: [
            { word: "my", expectedIpa: "/mɪ/", actualIpa: "/maɪ/", meaning: "của tôi", note: "Y đứng cuối từ thường đọc /aɪ/ hoặc /i/." },
            { word: "happy", expectedIpa: "/ˈhæpaɪ/", actualIpa: "/ˈhæpi/", meaning: "vui", note: "Y cuối từ nhiều âm tiết thường /i/." },
            { word: "gym", expectedIpa: "/ɡaɪm/", actualIpa: "/dʒɪm/", meaning: "phòng gym", note: "Y giữa từ thường /ɪ/." }
          ]
        }
      },
      {
        id: "w1-c1",
        title: "Phụ âm dễ 1",
        subtitle: "b d f h m n",
        spelling: "b d f h m n",
        targetIpa: "/b d f h m n/",
        speakWord: "bed",
        core: {
          rule: "Phụ âm đơn: một chữ → một âm nền. B /b/, D /d/, F /f/, H /h/, M /m/, N /n/.",
          guide: "Đọc phụ âm tiếng Anh có hơi, không thêm 'ờ' quá nặng. /b/ là bờ có hơi, không phải 'bờ-ờ'.",
          examples: [
            W("bed", "bed", "giường"),
            W("dog", "dɒɡ", "chó"),
            W("fan", "fæn", "quạt"),
            W("hat", "hæt", "mũ"),
            W("man", "mæn", "đàn ông"),
            W("net", "net", "lưới")
          ]
        },
        variation: {
          intro: "Cùng phụ âm, đứng đầu hoặc cuối từ — âm giữ nguyên.",
          branches: [
            { label: "Đầu từ", ipa: "onset", examples: [W("big", "bɪɡ", "to"), W("fish", "fɪʃ", "cá"), W("hot", "hɒt", "nóng")] },
            { label: "Cuối từ", ipa: "coda", examples: [W("web", "web", "mạng"), W("red", "red", "đỏ"), W("sun", "sʌn", "mặt trời")] }
          ]
        },
        boss: null
      },
      {
        id: "w1-c2",
        title: "Phụ âm dễ 2",
        subtitle: "l p r t v z",
        spelling: "l p r t v z",
        targetIpa: "/l p r t v z/",
        speakWord: "pen",
        core: {
          rule: "L /l/, P /p/, R /r/, T /t/, V /v/, Z /z/. R tiếng Anh không phải 'rờ' nặng tiếng Việt.",
          guide: "P và T có hơi bật (aspiration) ở đầu từ: pen, top.",
          examples: [
            W("leg", "leɡ", "chân"),
            W("pen", "pen", "bút"),
            W("red", "red", "đỏ"),
            W("top", "tɒp", "đỉnh"),
            W("van", "væn", "xe van"),
            W("zoo", "zuː", "sở thú")
          ]
        },
        variation: {
          intro: "S và Z dễ nhầm: S nền là /s/, Z luôn /z/. S đôi khi cũng đọc /z/ — sẽ gặp ở Boss.",
          branches: [
            { label: "P / T bật hơi", ipa: "/p t/", examples: [W("pen", "pen", "bút"), W("top", "tɒp", "đỉnh")] },
            { label: "V khác F", ipa: "/v/", examples: [W("van", "væn", "xe van"), W("five", "faɪv", "năm")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "Chữ S không luôn /s/.",
          items: [
            { word: "is", expectedIpa: "/ɪs/", actualIpa: "/ɪz/", meaning: "thì/là", note: "S cuối sau nguyên âm hữu thanh → /z/." },
            { word: "has", expectedIpa: "/hæs/", actualIpa: "/hæz/", meaning: "có", note: "has đọc /z/." }
          ]
        }
      },
      {
        id: "w1-c3",
        title: "Phụ âm còn lại",
        subtitle: "j k w y + qu",
        spelling: "j k w y",
        targetIpa: "/dʒ k w j/",
        speakWord: "jam",
        core: {
          rule: "J = /dʒ/ (jam). K = /k/. W = /w/. Y đầu từ = /j/ (yes). QU = /kw/.",
          guide: "Y đầu từ là phụ âm /j/ (yes). Y cuối từ là nguyên âm — World 3.",
          examples: [
            W("jam", "dʒæm", "mứt"),
            W("kite", "kaɪt", "diều"),
            W("web", "web", "mạng"),
            W("yes", "jes", "vâng"),
            W("queen", "kwiːn", "nữ hoàng")
          ]
        },
        variation: {
          intro: "Cùng chữ Y: đầu từ /j/, cuối từ nguyên âm.",
          branches: [
            { label: "Y đầu từ", ipa: "/j/", examples: [W("yes", "jes", "vâng"), W("yellow", "ˈjeləʊ", "vàng")] },
            { label: "Y cuối từ", ipa: "/aɪ/ hoặc /i/", examples: [W("my", "maɪ", "của tôi"), W("happy", "ˈhæpi", "vui")] }
          ]
        },
        boss: null
      },
      {
        id: "w1-cg",
        title: "C và G hai mặt",
        subtitle: "Hard / Soft",
        spelling: "c / g",
        targetIpa: "/k s ɡ dʒ/",
        speakWord: "cat",
        core: {
          rule: "C trước a/o/u → /k/ (cat). C trước e/i/y → /s/ (city). G trước a/o/u → /ɡ/ (go). G trước e/i/y thường /dʒ/ (gem).",
          guide: "Ghi nhớ: a o u = cứng. e i y = mềm (thường).",
          examples: [
            W("cat", "kæt", "mèo"),
            W("cup", "kʌp", "cốc"),
            W("city", "ˈsɪti", "thành phố"),
            W("go", "ɡəʊ", "đi"),
            W("gem", "dʒem", "đá quý")
          ]
        },
        variation: {
          intro: "Chiều 2: nghe âm → tìm chữ. /k/ có thể là C hoặc K. /s/ có thể là S hoặc C mềm.",
          branches: [
            { label: "/k/ viết C hoặc K", ipa: "/k/", examples: [W("cat", "kæt", "mèo"), W("kit", "kɪt", "bộ đồ")] },
            { label: "/s/ viết S hoặc C", ipa: "/s/", examples: [W("sun", "sʌn", "mặt trời"), W("cent", "sent", "xu")] }
          ]
        },
        boss: {
          kind: "multi-sound",
          intro: "G không luôn mềm trước e/i/y.",
          spelling: "g",
          sounds: [
            { ipa: "/ɡ/", example: "go", meaning: "đi" },
            { ipa: "/dʒ/", example: "gem", meaning: "đá quý" },
            { ipa: "/ɡ/", example: "get", meaning: "lấy — ngoại lệ cứng" }
          ],
          items: [
            { word: "get", expectedIpa: "/dʒet/", actualIpa: "/ɡet/", meaning: "lấy", note: "get, give, girl giữ /ɡ/." },
            { word: "give", expectedIpa: "/dʒɪv/", actualIpa: "/ɡɪv/", meaning: "cho", note: "Ngoại lệ cứng." }
          ]
        }
      }
    ]
  },
  {
    id: "w2",
    number: 2,
    emoji: "🟢",
    color: "#4ade80",
    title: "Short Vowels",
    titleVi: "Nguyên âm ngắn",
    blurb: "Xương sống: a e i o u trong âm tiết khép.",
    stages: [
      {
        id: "w2-a",
        title: "a → /æ/",
        subtitle: "cat, map, bag",
        spelling: "a",
        targetIpa: "/æ/",
        speakWord: "cat",
        core: {
          rule: "Chữ A trong âm tiết khép (sau A có phụ âm, không có e câm) đọc /æ/. Miệng mở rộng, không đọc /a/ tiếng Việt.",
          guide: "Luyện: cat /kæt/, man /mæn/, bag /bæɡ/. Miệng mở hơn /e/, âm ngắn.",
          examples: [W("cat", "kæt", "mèo"), W("map", "mæp", "bản đồ"), W("bag", "bæɡ", "túi"), W("hat", "hæt", "mũ"), W("sad", "sæd", "buồn")]
        },
        variation: {
          intro: "Cùng /æ/ trong từ dài khi A được nhấn.",
          branches: [
            { label: "Một âm tiết khép", ipa: "/æ/", examples: [W("man", "mæn", "đàn ông"), W("hand", "hænd", "tay")] },
            { label: "Âm tiết nhấn", ipa: "/æ/", examples: [W("apple", "ˈæpl", "táo"), W("happy", "ˈhæpi", "vui")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "Sau W, A thường không còn /æ/.",
          items: [
            { word: "want", expectedIpa: "/wænt/", actualIpa: "/wɒnt/", meaning: "muốn", note: "wa- thường /ɒ/ hoặc /ɔː/." },
            { word: "wash", expectedIpa: "/wæʃ/", actualIpa: "/wɒʃ/", meaning: "rửa", note: "Giống want." },
            { word: "was", expectedIpa: "/wæs/", actualIpa: "/wɒz/", meaning: "đã", note: "Từ chức năng, nguyên âm yếu/lạ." }
          ]
        }
      },
      {
        id: "w2-e",
        title: "e → /e/",
        subtitle: "bed, pen, red",
        spelling: "e",
        targetIpa: "/e/",
        speakWord: "bed",
        core: {
          rule: "Chữ E trong âm tiết khép đọc /e/ (giống e tiếng Việt nhưng ngắn, không thành 'ê').",
          guide: "bed, pen, red, ten. Không kéo thành /iː/.",
          examples: [W("bed", "bed", "giường"), W("pen", "pen", "bút"), W("red", "red", "đỏ"), W("ten", "ten", "mười"), W("leg", "leɡ", "chân")]
        },
        variation: {
          intro: "EA đôi khi cũng đọc /e/ — World 5 sẽ đào sâu. Ở đây chỉ nhận diện E đơn.",
          branches: [
            { label: "E khép", ipa: "/e/", examples: [W("desk", "desk", "bàn"), W("help", "help", "giúp")] },
            { label: "Teaser EA = /e/", ipa: "/e/", examples: [W("head", "hed", "đầu"), W("bread", "bred", "bánh mì")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "The không đọc /ðe/.",
          items: [
            { word: "the", expectedIpa: "/ðe/", actualIpa: "/ðə/ hoặc /ðiː/", meaning: "cái/the", note: "Trước phụ âm /ðə/, trước nguyên âm /ðiː/." },
            { word: "pretty", expectedIpa: "/ˈpreti/", actualIpa: "/ˈprɪti/", meaning: "xinh", note: "E đọc /ɪ/." }
          ]
        }
      },
      {
        id: "w2-i",
        title: "i → /ɪ/",
        subtitle: "sit, big, fish",
        spelling: "i",
        targetIpa: "/ɪ/",
        speakWord: "sit",
        core: {
          rule: "Chữ I trong âm tiết khép đọc /ɪ/ — ngắn, gần i nhưng chùng hơn, không phải /iː/.",
          guide: "sit ≠ seat. /ɪ/ ngắn; /iː/ dài.",
          examples: [W("sit", "sɪt", "ngồi"), W("big", "bɪɡ", "to"), W("fish", "fɪʃ", "cá"), W("milk", "mɪlk", "sữa"), W("ship", "ʃɪp", "tàu")]
        },
        variation: {
          intro: "Y giữa từ cũng thường /ɪ/ (gym, myth).",
          branches: [
            { label: "I khép", ipa: "/ɪ/", examples: [W("win", "wɪn", "thắng"), W("six", "sɪks", "sáu")] },
            { label: "Y = /ɪ/", ipa: "/ɪ/", examples: [W("gym", "dʒɪm", "phòng tập"), W("symbol", "ˈsɪmbl", "ký hiệu")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "Một số từ i_e đáng lẽ /aɪ/ nhưng ngắn.",
          items: [
            { word: "give", expectedIpa: "/ɡaɪv/", actualIpa: "/ɡɪv/", meaning: "cho", note: "live (động từ) /lɪv/, give /ɡɪv/." },
            { word: "live", expectedIpa: "/laɪv/", actualIpa: "/lɪv/", meaning: "sống (động từ)", note: "live (tính từ) mới /laɪv/." }
          ]
        }
      },
      {
        id: "w2-o",
        title: "o → /ɒ/ · /ɑː/",
        subtitle: "hot, dog, box",
        spelling: "o",
        targetIpa: "/ɒ/",
        speakWord: "hot",
        core: {
          rule: "Chữ O trong âm tiết khép: Anh-Anh /ɒ/ (hot), Anh-Mỹ thường /ɑː/. Đổi giọng ở mục Tôi.",
          guide: "Môi hơi tròn với /ɒ/. Không đọc thành 'o' ngang tiếng Việt kéo dài.",
          examples: [W("hot", "hɒt", "nóng"), W("dog", "dɒɡ", "chó"), W("box", "bɒks", "hộp"), W("top", "tɒp", "đỉnh"), W("not", "nɒt", "không")]
        },
        variation: {
          intro: "A sau W cũng hay về cùng vùng /ɒ/ (want).",
          branches: [
            { label: "O khép", ipa: "/ɒ/", examples: [W("lot", "lɒt", "nhiều"), W("rock", "rɒk", "đá")] },
            { label: "WA → /ɒ/", ipa: "/ɒ/", examples: [W("want", "wɒnt", "muốn"), W("wash", "wɒʃ", "rửa")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "one và once không đi theo O ngắn.",
          items: [
            { word: "one", expectedIpa: "/ɒn/ hoặc /oʊn/", actualIpa: "/wʌn/", meaning: "một", note: "Bắt đầu bằng /w/." },
            { word: "once", expectedIpa: "/ɒns/", actualIpa: "/wʌns/", meaning: "một lần", note: "Cùng họ với one." }
          ]
        }
      },
      {
        id: "w2-u",
        title: "u → /ʌ/",
        subtitle: "cup, sun, bus",
        spelling: "u",
        targetIpa: "/ʌ/",
        speakWord: "cup",
        core: {
          rule: "Chữ U trong âm tiết khép thường /ʌ/ — âm giữa, miệng hơi mở, không tròn như /u/.",
          guide: "cup, sun, bus, luck. Không đọc 'u' tiếng Việt.",
          examples: [W("cup", "kʌp", "cốc"), W("sun", "sʌn", "mặt trời"), W("bus", "bʌs", "xe buýt"), W("luck", "lʌk", "may"), W("jump", "dʒʌmp", "nhảy")]
        },
        variation: {
          intro: "O trong một số từ cũng đọc /ʌ/ (son, mother) — ngoại lệ hay gặp.",
          branches: [
            { label: "U khép", ipa: "/ʌ/", examples: [W("fun", "fʌn", "vui"), W("hut", "hʌt", "lều")] },
            { label: "O = /ʌ/", ipa: "/ʌ/", examples: [W("son", "sʌn", "con trai"), W("mother", "ˈmʌðə", "mẹ")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "put / push không /ʌ/.",
          items: [
            { word: "put", expectedIpa: "/pʌt/", actualIpa: "/pʊt/", meaning: "đặt", note: "put, push, pull, full → /ʊ/." },
            { word: "busy", expectedIpa: "/ˈbʌsi/", actualIpa: "/ˈbɪzi/", meaning: "bận", note: "U đọc /ɪ/." }
          ]
        }
      },
      {
        id: "w2-mix",
        title: "Trộn 5 âm ngắn",
        subtitle: "Nghe âm → chọn chữ",
        spelling: "a e i o u",
        targetIpa: "/æ e ɪ ɒ ʌ/",
        speakWord: "cat",
        isSoundMap: true,
        map: {
          ipa: "/æ e ɪ ɒ ʌ/",
          spellings: [
            { grapheme: "a", ipa: "/æ/", examples: ["cat", "map"] },
            { grapheme: "e", ipa: "/e/", examples: ["bed", "pen"] },
            { grapheme: "i", ipa: "/ɪ/", examples: ["sit", "big"] },
            { grapheme: "o", ipa: "/ɒ/", examples: ["hot", "box"] },
            { grapheme: "u", ipa: "/ʌ/", examples: ["cup", "sun"] }
          ]
        },
        core: {
          rule: "Chiều 2: nghe âm ngắn → tìm chữ. Đây là kỹ năng viết chính tả phonics.",
          guide: "Nghe /æ/ → viết a. Nghe /ɪ/ → viết i.",
          examples: [W("cat", "kæt", "mèo"), W("bed", "bed", "giường"), W("sit", "sɪt", "ngồi"), W("hot", "hɒt", "nóng"), W("cup", "kʌp", "cốc")]
        },
        variation: {
          intro: "Chọn từ có đúng âm được hỏi.",
          branches: [
            { label: "Từ nào có /æ/?", ipa: "/æ/", examples: [W("cat", "kæt", "mèo"), W("bag", "bæɡ", "túi")] },
            { label: "Từ nào có /ɪ/?", ipa: "/ɪ/", examples: [W("sit", "sɪt", "ngồi"), W("fish", "fɪʃ", "cá")] }
          ]
        },
        boss: null
      }
    ]
  },
  {
    id: "w3",
    number: 3,
    emoji: "🌞",
    color: "#fbbf24",
    title: "Long Vowels",
    titleVi: "Nguyên âm dài",
    blurb: "Magic E và các cách viết cùng một âm dài.",
    stages: [
      {
        id: "w3-ei",
        title: "/eɪ/ a_e · ai · ay",
        subtitle: "cake, rain, play",
        spelling: "a_e / ai / ay",
        targetIpa: "/eɪ/",
        speakWord: "cake",
        isSoundMap: true,
        map: {
          ipa: "/eɪ/",
          spellings: [
            { grapheme: "a_e", ipa: "/eɪ/", examples: ["cake", "name"] },
            { grapheme: "ai", ipa: "/eɪ/", examples: ["rain", "wait"] },
            { grapheme: "ay", ipa: "/eɪ/", examples: ["play", "day"] }
          ]
        },
        core: {
          rule: "Âm /eɪ/ có 3 cách viết xương sống: a_e (Magic E), ai (giữa từ), ay (cuối từ).",
          guide: "cake /keɪk/, rain /reɪn/, play /pleɪ/. E cuối câm: làm A đọc dài.",
          examples: [W("cake", "keɪk", "bánh"), W("name", "neɪm", "tên"), W("rain", "reɪn", "mưa"), W("play", "pleɪ", "chơi"), W("day", "deɪ", "ngày")]
        },
        variation: {
          intro: "Cùng âm /eɪ/, vị trí viết khác nhau — đây là chiều nghe âm → tìm cách viết.",
          branches: [
            { label: "a_e giữa", ipa: "/eɪ/", examples: [W("game", "ɡeɪm", "trò chơi"), W("late", "leɪt", "muộn")] },
            { label: "ai giữa · ay cuối", ipa: "/eɪ/", examples: [W("wait", "weɪt", "đợi"), W("stay", "steɪ", "ở lại")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "said trông như /eɪ/ nhưng không phải.",
          items: [
            { word: "said", expectedIpa: "/seɪd/", actualIpa: "/sed/", meaning: "đã nói", note: "ai trong said = /e/." },
            { word: "have", expectedIpa: "/heɪv/", actualIpa: "/hæv/", meaning: "có", note: "a_e nhưng ngắn /æ/." }
          ]
        }
      },
      {
        id: "w3-ii",
        title: "/iː/ e_e · ee · ea",
        subtitle: "these, see, eat",
        spelling: "e_e / ee / ea",
        targetIpa: "/iː/",
        speakWord: "see",
        isSoundMap: true,
        map: {
          ipa: "/iː/",
          spellings: [
            { grapheme: "e_e", ipa: "/iː/", examples: ["these", "theme"] },
            { grapheme: "ee", ipa: "/iː/", examples: ["see", "tree"] },
            { grapheme: "ea", ipa: "/iː/", examples: ["eat", "read"] }
          ]
        },
        core: {
          rule: "Âm /iː/ xương sống: ee (an toàn), ea (thường /iː/), e_e (Magic E).",
          guide: "see, tree, eat, these. Âm dài, môi dẹt.",
          examples: [W("see", "siː", "nhìn"), W("tree", "triː", "cây"), W("green", "ɡriːn", "xanh"), W("eat", "iːt", "ăn"), W("these", "ðiːz", "những cái này")]
        },
        variation: {
          intro: "EA còn nhiều âm khác — World 5 sẽ có trùm EA. Ở đây chỉ xương sống /iː/.",
          branches: [
            { label: "EE luôn gần /iː/", ipa: "/iː/", examples: [W("sleep", "sliːp", "ngủ"), W("feet", "fiːt", "bàn chân")] },
            { label: "EA = /iː/", ipa: "/iː/", examples: [W("clean", "kliːn", "sạch"), W("tea", "tiː", "trà")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "people viết eo nhưng đọc /iː/.",
          items: [
            { word: "people", expectedIpa: "/ˈpeɒpl/", actualIpa: "/ˈpiːpl/", meaning: "người", note: "eo → /iː/." },
            { word: "been", expectedIpa: "/biːn/", actualIpa: "/bɪn/ hoặc /biːn/", meaning: "đã", note: "Mỹ thường /bɪn/." }
          ]
        }
      },
      {
        id: "w3-ai",
        title: "/aɪ/ i_e · igh · y",
        subtitle: "like, light, my",
        spelling: "i_e / igh / y",
        targetIpa: "/aɪ/",
        speakWord: "like",
        isSoundMap: true,
        map: {
          ipa: "/aɪ/",
          spellings: [
            { grapheme: "i_e", ipa: "/aɪ/", examples: ["like", "time"] },
            { grapheme: "igh", ipa: "/aɪ/", examples: ["light", "night"] },
            { grapheme: "y", ipa: "/aɪ/", examples: ["my", "sky"] }
          ]
        },
        core: {
          rule: "/aɪ/ xương sống: i_e, igh, y cuối từ một âm tiết.",
          guide: "like, night, my. IGH: gh câm.",
          examples: [W("like", "laɪk", "thích"), W("time", "taɪm", "thời gian"), W("light", "laɪt", "ánh sáng"), W("night", "naɪt", "đêm"), W("my", "maɪ", "của tôi")]
        },
        variation: {
          intro: "ie đôi khi /aɪ/ (pie, die).",
          branches: [
            { label: "i_e / igh", ipa: "/aɪ/", examples: [W("five", "faɪv", "năm"), W("high", "haɪ", "cao")] },
            { label: "y / ie", ipa: "/aɪ/", examples: [W("sky", "skaɪ", "bầu trời"), W("pie", "paɪ", "bánh pie")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "give không /aɪ/.",
          items: [
            { word: "give", expectedIpa: "/ɡaɪv/", actualIpa: "/ɡɪv/", meaning: "cho", note: "Ngoại lệ Magic E." },
            { word: "live", expectedIpa: "/laɪv/", actualIpa: "/lɪv/", meaning: "sống (động từ)", note: "Tính từ live /laɪv/." }
          ]
        }
      },
      {
        id: "w3-ou",
        title: "/oʊ/ o_e · oa · ow",
        subtitle: "home, boat, snow",
        spelling: "o_e / oa / ow",
        targetIpa: "/oʊ/",
        speakWord: "home",
        isSoundMap: true,
        map: {
          ipa: "/oʊ/",
          spellings: [
            { grapheme: "o_e", ipa: "/oʊ/", examples: ["home", "note"] },
            { grapheme: "oa", ipa: "/oʊ/", examples: ["boat", "road"] },
            { grapheme: "ow", ipa: "/oʊ/", examples: ["snow", "grow"] }
          ]
        },
        core: {
          rule: "/oʊ/ (Mỹ) /əʊ/ (Anh): o_e, oa, ow cuối từ (snow). OW còn đọc /aʊ/ — World 7.",
          guide: "home, boat, snow. Môi tròn, trượt.",
          examples: [W("home", "həʊm", "nhà"), W("note", "nəʊt", "ghi chú"), W("boat", "bəʊt", "thuyền"), W("snow", "snəʊ", "tuyết"), W("grow", "ɡrəʊ", "lớn lên")]
        },
        variation: {
          intro: "OW hai mặt: /oʊ/ snow vs /aʊ/ now.",
          branches: [
            { label: "ow = /oʊ/", ipa: "/oʊ/", examples: [W("show", "ʃəʊ", "chỉ"), W("yellow", "ˈjeləʊ", "vàng")] },
            { label: "ow = /aʊ/", ipa: "/aʊ/", examples: [W("now", "naʊ", "bây giờ"), W("cow", "kaʊ", "bò")] }
          ]
        },
        boss: {
          kind: "multi-sound",
          intro: "OW phát ra 2 âm chính.",
          spelling: "ow",
          sounds: [
            { ipa: "/oʊ/", example: "snow", meaning: "tuyết" },
            { ipa: "/aʊ/", example: "now", meaning: "bây giờ" }
          ]
        }
      },
      {
        id: "w3-uu",
        title: "/juː/ · /uː/",
        subtitle: "u_e, ue, ew",
        spelling: "u_e / ue / ew",
        targetIpa: "/juː/",
        speakWord: "use",
        isSoundMap: true,
        map: {
          ipa: "/juː/ hoặc /uː/",
          spellings: [
            { grapheme: "u_e", ipa: "/juː/", examples: ["use", "cube"] },
            { grapheme: "ue", ipa: "/uː/", examples: ["blue", "true"] },
            { grapheme: "ew", ipa: "/juː/", examples: ["new", "few"] }
          ]
        },
        core: {
          rule: "u_e / ue / ew: /juː/ (use, new) hoặc /uː/ (blue, flute) tùy phụ âm trước.",
          guide: "Sau r, l, j thường /uː/ (blue, true). Nhiều từ khác /juː/ (use, music).",
          examples: [W("use", "juːz", "dùng"), W("cube", "kjuːb", "khối"), W("blue", "bluː", "xanh dương"), W("new", "njuː", "mới"), W("true", "truː", "đúng")]
        },
        variation: {
          intro: "oo cũng hay /uː/ (food) — World 5.",
          branches: [
            { label: "/juː/", ipa: "/juː/", examples: [W("music", "ˈmjuːzɪk", "nhạc"), W("few", "fjuː", "ít")] },
            { label: "/uː/", ipa: "/uː/", examples: [W("blue", "bluː", "xanh"), W("flute", "fluːt", "sáo")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "to / do / who không theo u_e.",
          items: [
            { word: "to", expectedIpa: "/təʊ/", actualIpa: "/tuː/ hoặc /tə/", meaning: "đến", note: "Từ chức năng, thường yếu /tə/." },
            { word: "who", expectedIpa: "/wəʊ/", actualIpa: "/huː/", meaning: "ai", note: "wh = /h/." }
          ]
        }
      }
    ]
  },
  {
    id: "w4",
    number: 4,
    emoji: "🟡",
    color: "#fb923c",
    title: "Consonant Digraphs",
    titleVi: "Âm ghép phụ âm",
    blurb: "Hai chữ → một âm. Boss: chữ đó phát ra bao nhiêu âm?",
    stages: [
      {
        id: "w4-sh",
        title: "sh → /ʃ/",
        subtitle: "ship, fish, shop",
        spelling: "sh",
        targetIpa: "/ʃ/",
        speakWord: "ship",
        core: {
          rule: "SH luôn gần như /ʃ/ — âm gió, môi xòe, không phải 'sờ' + 'hờ'.",
          guide: "ship, shop, fish, wash.",
          examples: [W("ship", "ʃɪp", "tàu"), W("shop", "ʃɒp", "cửa hàng"), W("fish", "fɪʃ", "cá"), W("wash", "wɒʃ", "rửa"), W("she", "ʃiː", "cô ấy")]
        },
        variation: {
          intro: "/ʃ/ còn viết ti, ci, si trong từ dài (nation) — nhận diện sau.",
          branches: [
            { label: "sh đầu", ipa: "/ʃ/", examples: [W("shoe", "ʃuː", "giày"), W("shut", "ʃʌt", "đóng")] },
            { label: "sh cuối", ipa: "/ʃ/", examples: [W("wish", "wɪʃ", "ước"), W("crash", "kræʃ", "va")] }
          ]
        },
        boss: null
      },
      {
        id: "w4-ch",
        title: "ch — nhiều mặt",
        subtitle: "chair · school · chef",
        spelling: "ch",
        targetIpa: "/tʃ/",
        speakWord: "chair",
        core: {
          rule: "Xương sống: CH → /tʃ/ (chair, much, chip).",
          guide: "Âm tắc-xát: t + sh dính nhau.",
          examples: [W("chair", "tʃeə", "ghế"), W("chip", "tʃɪp", "khoai chip"), W("much", "mʌtʃ", "nhiều"), W("lunch", "lʌntʃ", "bữa trưa"), W("child", "tʃaɪld", "trẻ")]
        },
        variation: {
          intro: "CH còn /k/ (gốc Hy Lạp) và /ʃ/ (gốc Pháp).",
          branches: [
            { label: "/tʃ/ xương sống", ipa: "/tʃ/", examples: [W("cheese", "tʃiːz", "phô mai"), W("catch", "kætʃ", "bắt")] },
            { label: "/k/ school", ipa: "/k/", examples: [W("school", "skuːl", "trường"), W("chorus", "ˈkɔːrəs", "điệp khúc")] },
            { label: "/ʃ/ chef", ipa: "/ʃ/", examples: [W("chef", "ʃef", "đầu bếp"), W("machine", "məˈʃiːn", "máy")] }
          ]
        },
        boss: {
          kind: "multi-sound",
          intro: "CH có thể phát ra bao nhiêu âm chính? Ba.",
          spelling: "ch",
          sounds: [
            { ipa: "/tʃ/", example: "chair", meaning: "ghế" },
            { ipa: "/k/", example: "school", meaning: "trường" },
            { ipa: "/ʃ/", example: "chef", meaning: "đầu bếp" }
          ]
        }
      },
      {
        id: "w4-th",
        title: "th → /θ/ và /ð/",
        subtitle: "think · this",
        spelling: "th",
        targetIpa: "/θ/",
        speakWord: "think",
        core: {
          rule: "TH có 2 âm: /θ/ vô thanh (think, three) và /ð/ hữu thanh (this, the). Lưỡi chạm răng.",
          guide: "Không đọc thành 'thờ' hay 'zờ'. Thổi hơi /θ/, rung /ð/.",
          examples: [W("think", "θɪŋk", "nghĩ"), W("three", "θriː", "ba"), W("this", "ðɪs", "cái này"), W("that", "ðæt", "cái đó"), W("the", "ðə", "the")]
        },
        variation: {
          intro: "Từ chức năng thường /ð/ (the, this, that, they). Từ nội dung đầu từ thường /θ/ (think, thank).",
          branches: [
            { label: "/θ/ think", ipa: "/θ/", examples: [W("thank", "θæŋk", "cảm ơn"), W("bath", "bɑːθ", "tắm")] },
            { label: "/ð/ this", ipa: "/ð/", examples: [W("they", "ðeɪ", "họ"), W("mother", "ˈmʌðə", "mẹ")] }
          ]
        },
        boss: {
          kind: "multi-sound",
          intro: "TH hai âm — chọn đúng mặt.",
          spelling: "th",
          sounds: [
            { ipa: "/θ/", example: "think", meaning: "nghĩ" },
            { ipa: "/ð/", example: "this", meaning: "cái này" }
          ]
        }
      },
      {
        id: "w4-phwh",
        title: "ph · wh · ck · ng",
        subtitle: "phone, what, duck, sing",
        spelling: "ph / wh / ck / ng",
        targetIpa: "/f w k ŋ/",
        speakWord: "phone",
        core: {
          rule: "PH = /f/ (phone). WH thường /w/ (what), trừ who /h/. CK = /k/ cuối từ sau nguyên âm ngắn. NG = /ŋ/ (sing).",
          guide: "ck không đứng đầu từ. ng không phải n + g tách.",
          examples: [W("phone", "fəʊn", "điện thoại"), W("photo", "ˈfəʊtəʊ", "ảnh"), W("what", "wɒt", "gì"), W("duck", "dʌk", "vịt"), W("sing", "sɪŋ", "hát")]
        },
        variation: {
          intro: "/f/ viết f hoặc ph. /k/ viết c, k, ck.",
          branches: [
            { label: "/f/ = f hoặc ph", ipa: "/f/", examples: [W("fan", "fæn", "quạt"), W("phone", "fəʊn", "điện thoại")] },
            { label: "/k/ = ck sau âm ngắn", ipa: "/k/", examples: [W("duck", "dʌk", "vịt"), W("back", "bæk", "sau")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "who / whose: WH = /h/.",
          items: [
            { word: "who", expectedIpa: "/wuː/", actualIpa: "/huː/", meaning: "ai", note: "wh = /h/." },
            { word: "what", expectedIpa: "/wæt/", actualIpa: "/wɒt/", meaning: "gì", note: "a sau w → /ɒ/." }
          ]
        }
      }
    ]
  },
  {
    id: "w5",
    number: 5,
    emoji: "🟣",
    color: "#a78bfa",
    title: "Vowel Teams",
    titleVi: "Nhóm nguyên âm",
    blurb: "Hai nguyên âm đi cùng nhau — mỗi team có xương sống và nhiều nhánh.",
    stages: [
      {
        id: "w5-ee",
        title: "EE → /iː/",
        subtitle: "see, tree, green",
        spelling: "ee",
        targetIpa: "/iː/",
        speakWord: "see",
        core: {
          rule: "EE gần như luôn /iː/. Đây là team 'an toàn' nhất.",
          guide: "see, tree, green, sleep, feet.",
          examples: [W("see", "siː", "nhìn"), W("tree", "triː", "cây"), W("green", "ɡriːn", "xanh"), W("sleep", "sliːp", "ngủ"), W("feet", "fiːt", "bàn chân")]
        },
        variation: {
          intro: "Cùng /iː/ còn ea, e_e, e. EE là cách viết ổn định nhất.",
          branches: [
            { label: "ee giữa/cuối", ipa: "/iː/", examples: [W("keep", "kiːp", "giữ"), W("free", "friː", "tự do")] },
            { label: "so sánh ea", ipa: "/iː/", examples: [W("eat", "iːt", "ăn"), W("sea", "siː", "biển")] }
          ]
        },
        boss: null
      },
      {
        id: "w5-ea",
        title: "EA — trùm 4 âm",
        subtitle: "eat · head · great · learn",
        spelling: "ea",
        targetIpa: "/iː/",
        speakWord: "eat",
        isSoundMap: true,
        map: {
          ipa: "EA",
          spellings: [
            { grapheme: "/iː/", ipa: "eat", examples: ["eat", "read", "clean"] },
            { grapheme: "/e/", ipa: "head", examples: ["bread", "head", "ready"] },
            { grapheme: "/eɪ/", ipa: "great", examples: ["break", "great", "steak"] },
            { grapheme: "/ɜː/", ipa: "learn", examples: ["learn", "heard"] }
          ]
        },
        core: {
          rule: "Xương sống EA → /iː/ (eat, read, clean). Đây là nhánh đông từ nhất.",
          guide: "Khi không chắc, thử /iː/ trước — rồi kiểm tra ngoại lệ.",
          examples: [W("eat", "iːt", "ăn"), W("read", "riːd", "đọc (hiện tại)"), W("clean", "kliːn", "sạch"), W("tea", "tiː", "trà"), W("meat", "miːt", "thịt")]
        },
        variation: {
          intro: "Ba nhánh biến đổi của EA.",
          branches: [
            { label: "/e/ bread", ipa: "/e/", examples: [W("bread", "bred", "bánh mì"), W("head", "hed", "đầu"), W("ready", "ˈredi", "sẵn sàng")] },
            { label: "/eɪ/ great", ipa: "/eɪ/", examples: [W("break", "breɪk", "làm vỡ"), W("great", "ɡreɪt", "tuyệt"), W("steak", "steɪk", "bít tết")] },
            { label: "/ɜː/ learn", ipa: "/ɜː/", examples: [W("learn", "lɜːn", "học"), W("heard", "hɜːd", "đã nghe")] }
          ]
        },
        boss: {
          kind: "multi-sound",
          intro: "EA phát ra 4 âm chính trong game này.",
          spelling: "ea",
          sounds: [
            { ipa: "/iː/", example: "eat", meaning: "ăn" },
            { ipa: "/e/", example: "head", meaning: "đầu" },
            { ipa: "/eɪ/", example: "great", meaning: "tuyệt" },
            { ipa: "/ɜː/", example: "learn", meaning: "học" }
          ]
        }
      },
      {
        id: "w5-oaai",
        title: "OA · AI · AY",
        subtitle: "boat, rain, play",
        spelling: "oa / ai / ay",
        targetIpa: "/oʊ/",
        speakWord: "boat",
        core: {
          rule: "OA → /oʊ/ (boat). AI giữa từ /eɪ/ (rain). AY cuối từ /eɪ/ (play).",
          guide: "Team ổn định, ít ngoại lệ hơn EA.",
          examples: [W("boat", "bəʊt", "thuyền"), W("road", "rəʊd", "đường"), W("rain", "reɪn", "mưa"), W("wait", "weɪt", "đợi"), W("play", "pleɪ", "chơi")]
        },
        variation: {
          intro: "Cùng /eɪ/: ai giữa, ay cuối — quy tắc vị trí.",
          branches: [
            { label: "ai giữa", ipa: "/eɪ/", examples: [W("train", "treɪn", "tàu"), W("paint", "peɪnt", "sơn")] },
            { label: "ay cuối", ipa: "/eɪ/", examples: [W("day", "deɪ", "ngày"), W("stay", "steɪ", "ở lại")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "said và again phá AI.",
          items: [
            { word: "said", expectedIpa: "/seɪd/", actualIpa: "/sed/", meaning: "đã nói", note: "Monster ngoại lệ." },
            { word: "again", expectedIpa: "/əˈɡeɪn/", actualIpa: "/əˈɡen/ hoặc /əˈɡeɪn/", meaning: "lại", note: "Hai cách đọc." }
          ]
        }
      },
      {
        id: "w5-oo",
        title: "OO hai độ dài",
        subtitle: "food · book",
        spelling: "oo",
        targetIpa: "/uː/",
        speakWord: "food",
        core: {
          rule: "OO xương sống dài /uː/ (food, moon, school). Nhánh ngắn /ʊ/ (book, good, look).",
          guide: "Không có quy tắc 100%. Học theo cụm từ hay gặp.",
          examples: [W("food", "fuːd", "thức ăn"), W("moon", "muːn", "mặt trăng"), W("school", "skuːl", "trường"), W("book", "bʊk", "sách"), W("good", "ɡʊd", "tốt")]
        },
        variation: {
          intro: "Hai nhánh OO.",
          branches: [
            { label: "/uː/ food", ipa: "/uː/", examples: [W("cool", "kuːl", "mát"), W("room", "ruːm", "phòng")] },
            { label: "/ʊ/ book", ipa: "/ʊ/", examples: [W("look", "lʊk", "nhìn"), W("foot", "fʊt", "bàn chân")] }
          ]
        },
        boss: {
          kind: "multi-sound",
          intro: "OO hai âm chính (+ blood /ʌ/ là trùm nhỏ).",
          spelling: "oo",
          sounds: [
            { ipa: "/uː/", example: "food", meaning: "thức ăn" },
            { ipa: "/ʊ/", example: "book", meaning: "sách" },
            { ipa: "/ʌ/", example: "blood", meaning: "máu" }
          ],
          items: [
            { word: "blood", expectedIpa: "/bluːd/", actualIpa: "/blʌd/", meaning: "máu", note: "flood cũng /ʌ/." }
          ]
        }
      }
    ]
  },
  {
    id: "w6",
    number: 6,
    emoji: "🟠",
    color: "#2dd4bf",
    title: "R-controlled",
    titleVi: "Nguyên âm + R",
    blurb: "R kéo nguyên âm thành một âm mới. EAR là node hay nhất.",
    stages: [
      {
        id: "w6-ar",
        title: "AR → /ɑː/",
        subtitle: "car, park, star",
        spelling: "ar",
        targetIpa: "/ɑː/",
        speakWord: "car",
        core: {
          rule: "AR xương sống /ɑː/ (car, park, star). Anh-Mỹ có R rõ hơn.",
          guide: "Miệng mở, A dài. UK: R cuối thường không rung.",
          examples: [W("car", "kɑː", "xe hơi"), W("park", "pɑːk", "công viên"), W("star", "stɑː", "sao"), W("dark", "dɑːk", "tối"), W("farm", "fɑːm", "nông trại")]
        },
        variation: {
          intro: "war / quar thường /ɔː/.",
          branches: [
            { label: "ar = /ɑː/", ipa: "/ɑː/", examples: [W("hard", "hɑːd", "cứng"), W("card", "kɑːd", "thẻ")] },
            { label: "war = /ɔː/", ipa: "/ɔː/", examples: [W("warm", "wɔːm", "ấm"), W("war", "wɔː", "chiến tranh")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "warm không /ɑː/.",
          items: [
            { word: "warm", expectedIpa: "/wɑːm/", actualIpa: "/wɔːm/", meaning: "ấm", note: "w + ar → /ɔː/." },
            { word: "quart", expectedIpa: "/kwɑːt/", actualIpa: "/kwɔːt/", meaning: "quart", note: "qu + ar → /ɔː/." }
          ]
        }
      },
      {
        id: "w6-er",
        title: "ER · IR · UR",
        subtitle: "her, bird, turn",
        spelling: "er / ir / ur",
        targetIpa: "/ɜː/",
        speakWord: "her",
        isSoundMap: true,
        map: {
          ipa: "/ɜː/",
          spellings: [
            { grapheme: "er", ipa: "/ɜː/", examples: ["her", "term"] },
            { grapheme: "ir", ipa: "/ɜː/", examples: ["bird", "girl"] },
            { grapheme: "ur", ipa: "/ɜː/", examples: ["turn", "hurt"] }
          ]
        },
        core: {
          rule: "ER, IR, UR xương sống cùng âm /ɜː/ (her, bird, turn). Ba cách viết, một âm.",
          guide: "Đây là chiều nghe âm → nhiều cách viết.",
          examples: [W("her", "hɜː", "cô ấy"), W("term", "tɜːm", "học kỳ"), W("bird", "bɜːd", "chim"), W("girl", "ɡɜːl", "bé gái"), W("turn", "tɜːn", "quay")]
        },
        variation: {
          intro: "OR thường /ɔː/ (fork), không nhập nhánh /ɜː/ trừ word / work.",
          branches: [
            { label: "er ir ur = /ɜː/", ipa: "/ɜː/", examples: [W("hurt", "hɜːt", "đau"), W("first", "fɜːst", "thứ nhất")] },
            { label: "or = /ɔː/", ipa: "/ɔː/", examples: [W("fork", "fɔːk", "nĩa"), W("short", "ʃɔːt", "ngắn")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "word / work: or = /ɜː/.",
          items: [
            { word: "word", expectedIpa: "/wɔːd/", actualIpa: "/wɜːd/", meaning: "từ", note: "w + or → /ɜː/." },
            { word: "work", expectedIpa: "/wɔːk/", actualIpa: "/wɜːk/", meaning: "làm việc", note: "Giống word." }
          ]
        }
      },
      {
        id: "w6-or",
        title: "OR → /ɔː/",
        subtitle: "fork, short, horse",
        spelling: "or",
        targetIpa: "/ɔː/",
        speakWord: "fork",
        core: {
          rule: "OR xương sống /ɔː/ (fork, short, horse).",
          guide: "Môi tròn, âm dài.",
          examples: [W("fork", "fɔːk", "nĩa"), W("short", "ʃɔːt", "ngắn"), W("horse", "hɔːs", "ngựa"), W("for", "fɔː", "cho"), W("born", "bɔːn", "sinh")]
        },
        variation: {
          intro: "ore / oar cũng /ɔː/ (more, board).",
          branches: [
            { label: "or", ipa: "/ɔː/", examples: [W("storm", "stɔːm", "bão"), W("corn", "kɔːn", "ngô")] },
            { label: "ore / oar", ipa: "/ɔː/", examples: [W("more", "mɔː", "nhiều hơn"), W("board", "bɔːd", "tấm ván")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "one-off: word không thuộc nhánh này.",
          items: [
            { word: "word", expectedIpa: "/wɔːd/", actualIpa: "/wɜːd/", meaning: "từ", note: "Xem lại ER/IR/UR." }
          ]
        }
      },
      {
        id: "w6-ear",
        title: "EAR — 4 nhánh",
        subtitle: "hear · bear · learn · heart",
        spelling: "ear",
        targetIpa: "/ɪə/",
        speakWord: "hear",
        isSoundMap: true,
        map: {
          ipa: "EAR",
          spellings: [
            { grapheme: "/ɪə/", ipa: "hear", examples: ["hear", "ear", "near"] },
            { grapheme: "/eə/", ipa: "bear", examples: ["bear", "pear", "wear"] },
            { grapheme: "/ɜː/", ipa: "learn", examples: ["learn", "earth"] },
            { grapheme: "/ɑː/", ipa: "heart", examples: ["heart"] }
          ]
        },
        core: {
          rule: "Xương sống EAR → /ɪə/ (hear, ear, near, year).",
          guide: "Hai âm trượt: /ɪ/ + schwa/r.",
          examples: [W("hear", "hɪə", "nghe"), W("ear", "ɪə", "tai"), W("near", "nɪə", "gần"), W("year", "jɪə", "năm"), W("clear", "klɪə", "rõ")]
        },
        variation: {
          intro: "Ba nhánh biến đổi — node game hay nhất khu R.",
          branches: [
            { label: "/eə/ bear", ipa: "/eə/", examples: [W("bear", "beə", "gấu"), W("pear", "peə", "lê"), W("wear", "weə", "mặc")] },
            { label: "/ɜː/ learn", ipa: "/ɜː/", examples: [W("learn", "lɜːn", "học"), W("earth", "ɜːθ", "trái đất")] },
            { label: "/ɑː/ heart", ipa: "/ɑː/", examples: [W("heart", "hɑːt", "trái tim")] }
          ]
        },
        boss: {
          kind: "multi-sound",
          intro: "EAR phát ra 4 âm trong game.",
          spelling: "ear",
          sounds: [
            { ipa: "/ɪə/", example: "hear", meaning: "nghe" },
            { ipa: "/eə/", example: "bear", meaning: "gấu" },
            { ipa: "/ɜː/", example: "learn", meaning: "học" },
            { ipa: "/ɑː/", example: "heart", meaning: "tim" }
          ]
        }
      }
    ]
  },
  {
    id: "w7",
    number: 7,
    emoji: "🔴",
    color: "#f472b6",
    title: "Diphthongs",
    titleVi: "Nguyên âm đôi",
    blurb: "Hai vị trí lưỡi trong một âm: /ɔɪ/ /aɪ/ /aʊ/ /eɪ/ /oʊ/.",
    stages: [
      {
        id: "w7-oi",
        title: "/ɔɪ/ oi · oy",
        subtitle: "coin, boy",
        spelling: "oi / oy",
        targetIpa: "/ɔɪ/",
        speakWord: "boy",
        isSoundMap: true,
        map: {
          ipa: "/ɔɪ/",
          spellings: [
            { grapheme: "oi", ipa: "/ɔɪ/", examples: ["coin", "boil"] },
            { grapheme: "oy", ipa: "/ɔɪ/", examples: ["boy", "toy"] }
          ]
        },
        core: {
          rule: "OI giữa từ, OY cuối từ → /ɔɪ/.",
          guide: "boy, toy, coin, oil. Trượt từ o tròn sang i.",
          examples: [W("boy", "bɔɪ", "cậu bé"), W("toy", "tɔɪ", "đồ chơi"), W("coin", "kɔɪn", "đồng xu"), W("oil", "ɔɪl", "dầu"), W("join", "dʒɔɪn", "tham gia")]
        },
        variation: {
          intro: "Vị trí viết: oi giữa, oy cuối — giống ai/ay.",
          branches: [
            { label: "oi giữa", ipa: "/ɔɪ/", examples: [W("boil", "bɔɪl", "sôi"), W("point", "pɔɪnt", "điểm")] },
            { label: "oy cuối", ipa: "/ɔɪ/", examples: [W("enjoy", "ɪnˈdʒɔɪ", "thích"), W("joy", "dʒɔɪ", "niềm vui")] }
          ]
        },
        boss: null
      },
      {
        id: "w7-au",
        title: "/aʊ/ ou · ow",
        subtitle: "out, now",
        spelling: "ou / ow",
        targetIpa: "/aʊ/",
        speakWord: "now",
        core: {
          rule: "OU / OW xương sống /aʊ/ (out, house, now, cow). OW còn nhánh /oʊ/ (snow).",
          guide: "Miệng mở rồi tròn.",
          examples: [W("out", "aʊt", "ra ngoài"), W("house", "haʊs", "nhà"), W("now", "naʊ", "bây giờ"), W("cow", "kaʊ", "bò"), W("down", "daʊn", "xuống")]
        },
        variation: {
          intro: "OU còn /uː/ (you), /ʌ/ (young), /ɔː/ (thought).",
          branches: [
            { label: "/aʊ/ out", ipa: "/aʊ/", examples: [W("loud", "laʊd", "to"), W("cloud", "klaʊd", "mây")] },
            { label: "ow = /oʊ/", ipa: "/oʊ/", examples: [W("snow", "snəʊ", "tuyết"), W("grow", "ɡrəʊ", "lớn")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "you / could phá OU.",
          items: [
            { word: "you", expectedIpa: "/jaʊ/", actualIpa: "/juː/", meaning: "bạn", note: "ou = /uː/." },
            { word: "could", expectedIpa: "/kaʊld/", actualIpa: "/kʊd/", meaning: "có thể", note: "l câm, ou = /ʊ/." }
          ]
        }
      },
      {
        id: "w7-review",
        title: "Ôn 5 diphthong",
        subtitle: "/eɪ/ /aɪ/ /oʊ/ /ɔɪ/ /aʊ/",
        spelling: "teams",
        targetIpa: "/eɪ aɪ oʊ ɔɪ aʊ/",
        speakWord: "play",
        isSoundMap: true,
        map: {
          ipa: "5 diphthong",
          spellings: [
            { grapheme: "/eɪ/", ipa: "ay", examples: ["play", "cake"] },
            { grapheme: "/aɪ/", ipa: "i_e", examples: ["like", "my"] },
            { grapheme: "/oʊ/", ipa: "oa", examples: ["boat", "home"] },
            { grapheme: "/ɔɪ/", ipa: "oy", examples: ["boy", "coin"] },
            { grapheme: "/aʊ/", ipa: "ow", examples: ["now", "out"] }
          ]
        },
        core: {
          rule: "Diphthong = trượt. Phân biệt /oʊ/ (snow) và /aʊ/ (now); /eɪ/ (play) và /aɪ/ (my).",
          guide: "Nghe âm → chọn chữ. Đây là cầu nối sang đánh vần thật.",
          examples: [W("play", "pleɪ", "chơi"), W("like", "laɪk", "thích"), W("home", "həʊm", "nhà"), W("boy", "bɔɪ", "cậu bé"), W("now", "naʊ", "bây giờ")]
        },
        variation: {
          intro: "Cặp dễ nhầm.",
          branches: [
            { label: "snow vs now", ipa: "/oʊ/ · /aʊ/", examples: [W("snow", "snəʊ", "tuyết"), W("now", "naʊ", "bây giờ")] },
            { label: "day vs die", ipa: "/eɪ/ · /aɪ/", examples: [W("day", "deɪ", "ngày"), W("die", "daɪ", "chết")] }
          ]
        },
        boss: null
      }
    ]
  },
  {
    id: "w8",
    number: 8,
    emoji: "📘",
    color: "#818cf8",
    title: "Syllables",
    titleVi: "Âm tiết",
    blurb: "Cắt từ thành nhịp. Mở / khép / Magic E.",
    stages: [
      {
        id: "w8-count",
        title: "Đếm âm tiết",
        subtitle: "cat · apple · banana",
        spelling: "syllable",
        targetIpa: "nhịp",
        speakWord: "banana",
        quizTypes: ["count-syllables"],
        core: {
          rule: "Mỗi nguyên âm được phát ra ≈ một âm tiết. cat = 1, ap-ple = 2, ba-na-na = 3.",
          guide: "Vỗ tay theo nhịp khi đọc.",
          examples: [W("cat", "kæt", "1 nhịp"), W("apple", "ˈæpl", "2 nhịp"), W("banana", "bəˈnɑːnə", "3 nhịp"), W("computer", "kəmˈpjuːtə", "3 nhịp")]
        },
        variation: {
          intro: "e câm không tạo âm tiết: cake = 1, không phải ca-ke.",
          branches: [
            { label: "1 âm tiết", ipa: "1", examples: [W("cake", "keɪk", "bánh"), W("light", "laɪt", "ánh sáng")] },
            { label: "2+ âm tiết", ipa: "2+", examples: [W("happy", "ˈhæpi", "vui"), W("elephant", "ˈelɪfənt", "voi")] }
          ]
        },
        boss: null,
        extra: {
          counts: [
            { word: "cat", n: 1 },
            { word: "apple", n: 2 },
            { word: "banana", n: 3 },
            { word: "cake", n: 1 },
            { word: "happy", n: 2 },
            { word: "elephant", n: 3 },
            { word: "computer", n: 3 },
            { word: "light", n: 1 }
          ]
        }
      },
      {
        id: "w8-open",
        title: "Âm tiết mở / khép",
        subtitle: "me · men · cake",
        spelling: "CV / CVC / Magic E",
        targetIpa: "mở·khép",
        speakWord: "me",
        core: {
          rule: "Khép (CVC): nguyên âm ngắn — men /men/. Mở (CV): nguyên âm dài — me /miː/. Magic E: cake /keɪk/.",
          guide: "Đây là cầu từ chữ → âm theo cấu trúc, không học vẹt từng từ.",
          examples: [W("me", "miː", "mở /iː/"), W("men", "men", "khép /e/"), W("cake", "keɪk", "Magic E /eɪ/"), W("cap", "kæp", "khép /æ/"), W("cape", "keɪp", "Magic E /eɪ/")]
        },
        variation: {
          intro: "Cặp tối thiểu: cap/cape, kit/kite, hop/hope.",
          branches: [
            { label: "Khép ngắn", ipa: "CVC", examples: [W("kit", "kɪt", "bộ đồ"), W("hop", "hɒp", "nhảy")] },
            { label: "Magic E dài", ipa: "CVCe", examples: [W("kite", "kaɪt", "diều"), W("hope", "həʊp", "hy vọng")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "have / give phá Magic E.",
          items: [
            { word: "have", expectedIpa: "/heɪv/", actualIpa: "/hæv/", meaning: "có", note: "CVCe nhưng ngắn." },
            { word: "give", expectedIpa: "/ɡaɪv/", actualIpa: "/ɡɪv/", meaning: "cho", note: "CVCe nhưng ngắn." }
          ]
        }
      }
    ]
  },
  {
    id: "w9",
    number: 9,
    emoji: "🔵",
    color: "#c084fc",
    title: "Word Stress + Schwa",
    titleVi: "Trọng âm từ",
    blurb: "Âm tiết nhấn giữ nguyên âm đầy. Không nhấn → thường /ə/.",
    stages: [
      {
        id: "w9-primary",
        title: "Primary stress",
        subtitle: "TAble · beGIN",
        spelling: "ˈ",
        targetIpa: "ˈ",
        speakWord: "table",
        quizTypes: ["tap-stress"],
        core: {
          rule: "Mỗi từ có một trọng âm chính. TAble (nhấn 1). beGIN (nhấn 2). Nghe → chọn âm tiết lớn.",
          guide: "Âm tiết nhấn: to hơn, dài hơn, rõ hơn.",
          examples: [W("table", "ˈteɪbl", "TA-ble"), W("begin", "bɪˈɡɪn", "be-GIN"), W("teacher", "ˈtiːtʃə", "TEA-cher"), W("about", "əˈbaʊt", "a-BOUT")]
        },
        variation: {
          intro: "Đổi trọng âm có thể đổi từ loại: REcord (danh) vs reCORD (động).",
          branches: [
            { label: "Nhấn 1", ipa: "ˈxx", examples: [W("photo", "ˈfəʊtəʊ", "PHO-to"), W("city", "ˈsɪti", "CI-ty")] },
            { label: "Nhấn 2", ipa: "xˈx", examples: [W("begin", "bɪˈɡɪn", "be-GIN"), W("about", "əˈbaʊt", "a-BOUT")] }
          ]
        },
        boss: null,
        extra: {
          stress: [
            { word: "table", syllables: ["TA", "ble"], stressed: 0, ipa: "/ˈteɪbl/" },
            { word: "begin", syllables: ["be", "GIN"], stressed: 1, ipa: "/bɪˈɡɪn/" },
            { word: "teacher", syllables: ["TEA", "cher"], stressed: 0, ipa: "/ˈtiːtʃə/" },
            { word: "about", syllables: ["a", "BOUT"], stressed: 1, ipa: "/əˈbaʊt/" },
            { word: "computer", syllables: ["com", "PU", "ter"], stressed: 1, ipa: "/kəmˈpjuːtə/" }
          ]
        }
      },
      {
        id: "w9-schwa",
        title: "Schwa /ə/",
        subtitle: "about · banana",
        spelling: "ə",
        targetIpa: "/ə/",
        speakWord: "about",
        core: {
          rule: "Âm tiết không nhấn thường suy yếu thành /ə/ (schwa) — âm trung tính, rất ngắn. about = ə-BOUT, không phải A-BOUT.",
          guide: "STRESSED → nguyên âm đầy. UNSTRESSED → /ə/.",
          examples: [W("about", "əˈbaʊt", "về"), W("banana", "bəˈnɑːnə", "chuối"), W("sofa", "ˈsəʊfə", "ghế sofa"), W("teacher", "ˈtiːtʃə", "giáo viên")]
        },
        variation: {
          intro: "Mọi nguyên âm viết đều có thể thành /ə/ khi không nhấn: a, e, o, u...",
          branches: [
            { label: "a → /ə/", ipa: "/ə/", examples: [W("about", "əˈbaʊt", "về"), W("sofa", "ˈsəʊfə", "sofa")] },
            { label: "o/e → /ə/", ipa: "/ə/", examples: [W("lemon", "ˈlemən", "chanh"), W("teacher", "ˈtiːtʃə", "giáo viên")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "the: /ðə/ hoặc /ðiː/.",
          items: [
            { word: "the", expectedIpa: "/ðiː/ luôn", actualIpa: "/ðə/ trước phụ âm", meaning: "the", note: "the book /ðə/, the apple /ðiː/." }
          ]
        }
      },
      {
        id: "w9-photo",
        title: "photography",
        subtitle: "Đổi nhấn → đổi schwa",
        spelling: "photo-",
        targetIpa: "ˈ / ˌ / ə",
        speakWord: "photography",
        quizTypes: ["tap-stress"],
        core: {
          rule: "PHOtograph /ˈfəʊtəɡrɑːf/ nhấn PHO. phoTOGraphy /fəˈtɒɡrəfi/ nhấn TOG. Khi nhấn đổi chỗ, nguyên âm đầy cũng đổi chỗ, chỗ cũ thành /ə/.",
          guide: "fə - TOG - rə - fi. Primary ở TOG.",
          examples: [W("photograph", "ˈfəʊtəɡrɑːf", "PHO-to-graph"), W("photography", "fəˈtɒɡrəfi", "pho-TOG-ra-phy"), W("photographer", "fəˈtɒɡrəfə", "pho-TOG-ra-pher")]
        },
        variation: {
          intro: "Ba mức: primary ˈ, secondary ˌ, yếu /ə/.",
          branches: [
            { label: "Primary", ipa: "ˈ", examples: [W("photograph", "ˈfəʊtəɡrɑːf", "nhấn PHO")] },
            { label: "Schwa yếu", ipa: "ə", examples: [W("photography", "fəˈtɒɡrəfi", "pho và ra là /ə/")] }
          ]
        },
        boss: null,
        extra: {
          stress: [
            { word: "photograph", syllables: ["PHO", "to", "graph"], stressed: 0, ipa: "/ˈfəʊtəɡrɑːf/" },
            { word: "photography", syllables: ["pho", "TOG", "ra", "phy"], stressed: 1, ipa: "/fəˈtɒɡrəfi/" },
            { word: "photographer", syllables: ["pho", "TOG", "ra", "pher"], stressed: 1, ipa: "/fəˈtɒɡrəfə/" }
          ]
        }
      }
    ]
  },
  {
    id: "w10",
    number: 10,
    emoji: "💠",
    color: "#60a5fa",
    title: "Sentence + Linking",
    titleVi: "Câu · nối âm",
    blurb: "Từ nội dung được nhấn. Từ chức năng yếu. Nối âm như người bản xứ.",
    stages: [
      {
        id: "w10-content",
        title: "Content vs function",
        subtitle: "WANT · BUY · NEW · CAR",
        spelling: "sentence stress",
        targetIpa: "nhấn câu",
        speakWord: "I want to buy a new car",
        quizTypes: ["content-words"],
        core: {
          rule: "Trong câu, nhấn từ nội dung: danh từ, động từ chính, tính từ, trạng từ. Từ chức năng (a, the, to, of, and) thường yếu.",
          guide: "I WANT to BUY a NEW CAR. Không đều lực.",
          examples: [W("want", "wɒnt", "nội dung"), W("buy", "baɪ", "nội dung"), W("new", "njuː", "nội dung"), W("car", "kɑː", "nội dung")]
        },
        variation: {
          intro: "Function words thường schwa: to /tə/, a /ə/, of /əv/.",
          branches: [
            { label: "Content", ipa: "nhấn", examples: [W("want", "wɒnt", "muốn"), W("car", "kɑː", "xe")] },
            { label: "Function", ipa: "yếu", examples: [W("to", "tə", "đến"), W("a", "ə", "một")] }
          ]
        },
        boss: null,
        extra: {
          sentences: [
            { words: ["I", "WANT", "to", "BUY", "a", "NEW", "CAR"], stressed: [1, 3, 5, 6], text: "I want to buy a new car." },
            { words: ["She", "GOES", "to", "SCHOOL"], stressed: [1, 3], text: "She goes to school." },
            { words: ["The", "CAT", "is", "BLACK"], stressed: [1, 3], text: "The cat is black." }
          ]
        }
      },
      {
        id: "w10-link",
        title: "Linking",
        subtitle: "pick it up",
        spelling: "C+V",
        targetIpa: "/pɪkɪtʌp/",
        speakWord: "pick it up",
        core: {
          rule: "Phụ âm cuối nối sang nguyên âm đầu từ sau: pick + it → /pɪkɪt/. pick it up nghe gần /pɪkɪtʌp/.",
          guide: "Không ngắt từng từ. Trượt.",
          examples: [W("pick it up", "pɪkɪtʌp", "nhặt lên"), W("an apple", "ənæpl", "một quả táo"), W("this is", "ðɪsɪz", "đây là")]
        },
        variation: {
          intro: "Connected speech: sounds → syllables → word stress → schwa → sentence stress → linking.",
          branches: [
            { label: "C + V", ipa: "nối", examples: [W("come in", "kʌmɪn", "vào đi"), W("turn off", "tɜːnɒf", "tắt")] },
            { label: "the + nguyên âm", ipa: "/ðiː/", examples: [W("the apple", "ðiː æpl", "quả táo")] }
          ]
        },
        boss: {
          kind: "exception",
          intro: "Không phải lúc nào cũng nối — khi nhấn mạnh từ, có thể tách.",
          items: [
            { word: "I WANT it", expectedIpa: "nối hết", actualIpa: "WANT được tách/nhấn", meaning: "tôi MUỐN nó", note: "Nhấn cảm xúc có thể phá linking." }
          ]
        }
      }
    ]
  }
];

const FINAL_BOSS = {
  id: "boss",
  number: 11,
  emoji: "👑",
  color: "#f43f5e",
  title: "Exception Monster",
  titleVi: "Trùm ngoại lệ",
  blurb: "Từ bất quy tắc: SPELLING → ÂM DỰ ĐOÁN → ÂM THẬT.",
  stages: [
    {
      id: "boss-irregular",
      title: "Irregular words",
      subtitle: "said · one · two · have",
      spelling: "exceptions",
      targetIpa: "monster",
      speakWord: "said",
      core: {
        rule: "Một số từ phá quy tắc bạn vừa học. Ghi theo 3 cột: viết → đoán → thật.",
        guide: "Đây là boss cuối: không học thêm quy tắc mới, mà khóa các 'quái vật' hay gặp.",
        examples: [W("said", "sed", "đã nói"), W("one", "wʌn", "một"), W("two", "tuː", "hai"), W("have", "hæv", "có"), W("does", "dʌz", "làm")]
      },
      variation: {
        intro: "Thêm đàn quái vật thường gặp.",
        branches: [
          { label: "Số", ipa: "số", examples: [W("one", "wʌn", "một"), W("two", "tuː", "hai"), W("once", "wʌns", "một lần")] },
          { label: "Từ chức năng", ipa: "fn", examples: [W("of", "ɒv", "của"), W("was", "wɒz", "đã"), W("what", "wɒt", "gì")] }
        ]
      },
      boss: {
        kind: "exception",
        intro: "Bảng trùm: quy tắc dự đoán vs thực tế.",
        items: [
          { word: "said", expectedIpa: "/seɪd/", actualIpa: "/sed/", meaning: "đã nói", note: "ai → /e/." },
          { word: "one", expectedIpa: "/oʊn/", actualIpa: "/wʌn/", meaning: "một", note: "thêm /w/, o → /ʌ/." },
          { word: "two", expectedIpa: "/twəʊ/", actualIpa: "/tuː/", meaning: "hai", note: "w câm." },
          { word: "does", expectedIpa: "/doʊz/", actualIpa: "/dʌz/", meaning: "làm", note: "oe → /ʌ/." },
          { word: "have", expectedIpa: "/heɪv/", actualIpa: "/hæv/", meaning: "có", note: "phá Magic E." },
          { word: "of", expectedIpa: "/ɒf/", actualIpa: "/ɒv/", meaning: "của", note: "f → /v/." },
          { word: "was", expectedIpa: "/wæs/", actualIpa: "/wɒz/", meaning: "đã", note: "a → /ɒ/, s → /z/." },
          { word: "what", expectedIpa: "/wæt/", actualIpa: "/wɒt/", meaning: "gì", note: "a → /ɒ/." },
          { word: "who", expectedIpa: "/wuː/", actualIpa: "/huː/", meaning: "ai", note: "wh → /h/, w câm." },
          { word: "friend", expectedIpa: "/friːend/", actualIpa: "/frend/", meaning: "bạn", note: "ie → /e/." },
          { word: "people", expectedIpa: "/ˈpeɒpl/", actualIpa: "/ˈpiːpl/", meaning: "người", note: "eo → /iː/." },
          { word: "could", expectedIpa: "/kaʊld/", actualIpa: "/kʊd/", meaning: "có thể", note: "l câm." }
        ]
      }
    }
  ]
};

const ALL_WORLDS = [...WORLDS, FINAL_BOSS];
