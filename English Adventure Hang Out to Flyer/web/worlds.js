const WORLD_ORDER = ["W0", "W1", "W2", "W3", "W4", "W5", "W6", "W7", "W8", "W9", "W10"];

const WORLD_PLAY = {
  W0: {
    scene: "village",
    items: [
      { type: "listen_choose", scene: "village", say: "Hello!", line: "Hello! Hi! Come in.", choices: ["Hello", "Goodbye", "Please"], answer: "hello", hint: "Chọn Hello" },
      { type: "name", scene: "village", say: "What's your name?", line: "What's your name?", hint: "Gõ tên" },
      { type: "find_it", scene: "village", say: "Find the star.", line: "Find the star.", objects: ["ball", "star", "hat"], answer: "star", hint: "Chạm ngôi sao" },
      { type: "listen_choose", scene: "village", say: "Thank you.", line: "Please help. Thank you! Goodbye!", choices: ["Hello", "Thank you", "No"], answer: "thank you", hint: "Chọn Thank you" }
    ]
  },
  W1: {
    scene: "room",
    items: [
      { type: "find_it", scene: "room", say: "Find the lamp.", answer: "lamp", objects: ["door", "window", "bed", "desk", "chair", "lamp"], hint: "Tìm đèn" },
      { type: "find_it", scene: "room", say: "Find the chair.", answer: "chair", objects: ["door", "window", "bed", "desk", "chair", "lamp"], hint: "Tìm ghế" },
      { type: "find_it", scene: "room", say: "This is my mum. Who is this?", answer: "mum", objects: ["mum", "dad", "sister", "ball"], hint: "Chọn mum" },
      { type: "listen_choose", scene: "room", say: "I have a doll.", answer: "doll", choices: ["doll", "lamp", "jacket"], hint: "Chọn doll" },
      { type: "listen_choose", scene: "room", say: "What color is it? It's blue.", answer: "blue", choices: ["red", "blue", "green"], hint: "Chọn blue" }
    ]
  },
  W2: {
    scene: "school",
    items: [
      { type: "find_it", scene: "school", say: "Find the pencil.", answer: "pencil", objects: ["pencil", "book", "bag", "ruler"], hint: "Tìm pencil" },
      { type: "find_it", scene: "school", say: "Find the bag.", answer: "bag", objects: ["pencil", "book", "bag", "eraser"], hint: "Tìm bag" },
      { type: "listen_choose", scene: "school", say: "I have a book.", answer: "book", choices: ["book", "apple", "dog"], hint: "Chọn book" },
      { type: "listen_choose", scene: "school", say: "Where is the book? It's on the desk.", answer: "on", choices: ["in", "on", "under"], hint: "Chọn on" },
      { type: "listen_choose", scene: "school", say: "How are you? I'm happy.", answer: "happy", choices: ["happy", "sad", "angry"], hint: "Chọn happy" }
    ]
  },
  W3: {
    scene: "food",
    items: [
      { type: "find_it", scene: "food", say: "Find the apple.", answer: "apple", objects: ["apple", "banana", "carrot", "milk"], hint: "Tìm apple" },
      { type: "find_it", scene: "food", say: "Find the banana.", answer: "banana", objects: ["apple", "banana", "cake", "fish"], hint: "Tìm banana" },
      { type: "listen_choose", scene: "food", say: "I like cake.", answer: "cake", choices: ["cake", "onion", "ruler"], hint: "Chọn cake" },
      { type: "listen_choose", scene: "food", say: "I don't like fish.", answer: "fish", choices: ["milk", "fish", "apple"], hint: "Chọn fish" },
      { type: "listen_choose", scene: "food", say: "Can I have some milk?", answer: "milk", choices: ["milk", "bag", "desk"], hint: "Chọn milk" }
    ]
  },
  W4: {
    scene: "animals",
    items: [
      { type: "find_it", scene: "animals", say: "Find the cat.", answer: "cat", objects: ["cat", "dog", "bird", "fish"], hint: "Tìm cat" },
      { type: "find_it", scene: "animals", say: "Find the elephant.", answer: "elephant", objects: ["cat", "cow", "elephant", "bird"], hint: "Tìm elephant" },
      { type: "listen_choose", scene: "animals", say: "A bird can fly.", answer: "fly", choices: ["fly", "swim", "read"], hint: "Chọn fly" },
      { type: "listen_choose", scene: "animals", say: "A fish can swim.", answer: "swim", choices: ["fly", "swim", "sing"], hint: "Chọn swim" },
      { type: "listen_choose", scene: "animals", say: "The elephant is big.", answer: "big", choices: ["big", "small", "blue"], hint: "Chọn big" }
    ]
  },
  W5: {
    scene: "city",
    items: [
      { type: "find_it", scene: "city", say: "Find the park.", answer: "park", objects: ["park", "school", "hospital", "library"], hint: "Tìm park" },
      { type: "find_it", scene: "city", say: "Find the library.", answer: "library", objects: ["shop", "hospital", "library", "bus"], hint: "Tìm library" },
      { type: "listen_choose", scene: "city", say: "She's a doctor.", answer: "doctor", choices: ["doctor", "pilot", "farmer"], hint: "Chọn doctor" },
      { type: "listen_choose", scene: "city", say: "I go by bus.", answer: "bus", choices: ["bus", "milk", "hat"], hint: "Chọn bus" },
      { type: "listen_choose", scene: "city", say: "The library is next to the school.", answer: "next to", choices: ["under", "next to", "in"], hint: "Chọn next to" }
    ]
  },
  W6: {
    scene: "weather",
    items: [
      { type: "find_it", scene: "weather", say: "Find the umbrella.", answer: "umbrella", objects: ["sun", "umbrella", "coat", "snow"], hint: "Tìm umbrella" },
      { type: "listen_choose", scene: "weather", say: "It's sunny.", answer: "sunny", choices: ["sunny", "rainy", "cold"], hint: "Chọn sunny" },
      { type: "listen_choose", scene: "weather", say: "It's rainy.", answer: "rainy", choices: ["sunny", "rainy", "hot"], hint: "Chọn rainy" },
      { type: "listen_choose", scene: "weather", say: "I'm wearing a jacket.", answer: "jacket", choices: ["jacket", "banana", "bus"], hint: "Chọn jacket" },
      { type: "listen_choose", scene: "weather", say: "How's the weather? It's windy today.", answer: "windy", choices: ["windy", "hungry", "yellow"], hint: "Chọn windy" }
    ]
  },
  W7: {
    scene: "hobbies",
    items: [
      { type: "find_it", scene: "hobbies", say: "Find the football.", answer: "football", objects: ["football", "piano", "book", "computer"], hint: "Tìm football" },
      { type: "listen_choose", scene: "hobbies", say: "I like swimming.", answer: "swimming", choices: ["swimming", "onion", "hospital"], hint: "Chọn swimming" },
      { type: "listen_choose", scene: "hobbies", say: "She plays football.", answer: "football", choices: ["football", "milk", "rainy"], hint: "Chọn football" },
      { type: "listen_choose", scene: "hobbies", say: "I like reading.", answer: "reading", choices: ["reading", "flying", "sunny"], hint: "Chọn reading" },
      { type: "listen_choose", scene: "hobbies", say: "What are you doing? I'm playing.", answer: "playing", choices: ["sleeping", "playing", "cooking"], hint: "Chọn playing" }
    ]
  },
  W8: {
    scene: "travel",
    items: [
      { type: "find_it", scene: "travel", say: "Find the plane.", answer: "plane", objects: ["plane", "train", "ticket", "beach"], hint: "Tìm plane" },
      { type: "find_it", scene: "travel", say: "Find the beach.", answer: "beach", objects: ["hotel", "beach", "bus", "key"], hint: "Tìm beach" },
      { type: "listen_choose", scene: "travel", say: "We're at the airport.", answer: "airport", choices: ["airport", "kitchen", "farm"], hint: "Chọn airport" },
      { type: "listen_choose", scene: "travel", say: "Where are you going? I'm going to the beach.", answer: "beach", choices: ["beach", "desk", "lion"], hint: "Chọn beach" },
      { type: "listen_choose", scene: "travel", say: "I'm going to visit grandma tomorrow.", answer: "tomorrow", choices: ["yesterday", "tomorrow", "under"], hint: "Chọn tomorrow" }
    ]
  },
  W9: {
    scene: "adventure",
    items: [
      { type: "listen_choose", scene: "adventure", say: "I was at home yesterday.", answer: "yesterday", choices: ["yesterday", "tomorrow", "sunny"], hint: "Chọn yesterday" },
      { type: "listen_choose", scene: "adventure", say: "We went to the park.", answer: "went", choices: ["go", "went", "going"], hint: "Chọn went" },
      { type: "listen_choose", scene: "adventure", say: "I saw a bird.", answer: "saw", choices: ["see", "saw", "seen"], hint: "Chọn saw" },
      { type: "listen_choose", scene: "adventure", say: "The elephant is bigger than the cat.", answer: "bigger", choices: ["small", "bigger", "blue"], hint: "Chọn bigger" },
      { type: "find_it", scene: "adventure", say: "Find the map.", answer: "map", objects: ["map", "key", "book", "lamp"], hint: "Tìm map" }
    ]
  },
  W10: {
    scene: "island",
    items: [
      { type: "listen_choose", scene: "island", say: "The boy is wearing a hat.", answer: "hat", choices: ["hat", "bed", "cow"], hint: "Chọn hat" },
      { type: "listen_choose", scene: "island", say: "Where is the library? It's next to the school.", answer: "library", choices: ["library", "banana", "snow"], hint: "Chọn library" },
      { type: "listen_choose", scene: "island", say: "I like swimming.", answer: "swimming", choices: ["swimming", "angry", "ticket"], hint: "Chọn swimming" },
      { type: "listen_choose", scene: "island", say: "We went to the beach yesterday.", answer: "yesterday", choices: ["tomorrow", "yesterday", "please"], hint: "Chọn yesterday" },
      { type: "find_it", scene: "island", say: "Find the castle.", answer: "castle", objects: ["castle", "plane", "cat", "apple"], hint: "Tìm castle" }
    ]
  }
};
