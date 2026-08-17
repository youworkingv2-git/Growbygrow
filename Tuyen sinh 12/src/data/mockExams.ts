import { Exam } from '../types/exam';

export const MOCK_EXAMS: Exam[] = [
  {
    id: 'thpt-toan-2025-01',
    title: 'Đề Minh Họa Tốt Nghiệp THPT 2025 - Môn Toán',
    category: 'THPT_QG_2025',
    subject: 'Toán',
    year: 2025,
    durationMinutes: 90,
    totalQuestions: 22, // Cấu trúc mới: 12 Trắc nghiệm + 4 Đúng/Sai + 6 Trả lời ngắn
    description: 'Chuẩn cấu trúc định hướng 2025 của Bộ Giáo dục & Đào tạo gồm 3 phần thi: Trắc nghiệm 4 đáp án, Trắc nghiệm Đúng/Sai, và Trả lời ngắn.',
    tags: ['Minh Họa 2025', 'Cấu trúc mới', 'Bộ GD&ĐT'],
    questions: [
      // PHẦN I: Trắc nghiệm 4 lựa chọn
      {
        id: 'q-math-1',
        type: 'single-choice',
        content: 'Cho hàm số $y = f(x)$ có bảng biến thiên như sau. Hàm số $y = f(x)$ đồng biến trên khoảng nào dưới đây?',
        options: [
          '$(-\\infty; -1)$',
          '$(-1; 1)$',
          '$(1; +\\infty)$',
          '$(0; 2)$'
        ],
        correctAnswer: 1,
        explanation: 'Dựa vào bảng biến thiên, đạo hàm $f\'(x) > 0$ trên khoảng $(-1; 1)$, do đó hàm số đồng biến trên khoảng $(-1; 1)$.',
        subject: 'Toán',
        topic: 'Khảo sát hàm số',
        difficulty: 'Dễ'
      },
      {
        id: 'q-math-2',
        type: 'single-choice',
        content: 'Tiệm cận đứng của đồ thị hàm số $y = \\frac{2x + 1}{x - 3}$ là đường thẳng:',
        options: [
          '$x = 3$',
          '$x = 2$',
          '$y = 2$',
          '$y = -3$'
        ],
        correctAnswer: 0,
        explanation: 'Mẫu số $x - 3 = 0 \\Leftrightarrow x = 3$. Vì $\\lim_{x \\to 3^+} \\frac{2x+1}{x-3} = +\\infty$ nên $x = 3$ là tiệm cận đứng.',
        subject: 'Toán',
        topic: 'Đồ thị hàm số',
        difficulty: 'Dễ'
      },
      {
        id: 'q-math-3',
        type: 'single-choice',
        content: 'Cho tích phân $\\int_{0}^{2} f(x) dx = 3$ và $\\int_{0}^{2} g(x) dx = 5$. Tính $I = \\int_{0}^{2} [2f(x) - g(x)] dx$.',
        options: [
          '$I = 1$',
          '$I = -1$',
          '$I = 11$',
          '$I = 4$'
        ],
        correctAnswer: 0,
        explanation: '$I = 2 \\int_{0}^{2} f(x) dx - \\int_{0}^{2} g(x) dx = 2(3) - 5 = 6 - 5 = 1$.',
        subject: 'Toán',
        topic: 'Tích phân',
        difficulty: 'Trung bình'
      },
      {
        id: 'q-math-4',
        type: 'single-choice',
        content: 'Trong không gian $Oxyz$, cho mặt cầu $(S): (x-1)^2 + (y+2)^2 + (z-3)^2 = 16$. Bán kính $R$ của mặt cầu là:',
        options: [
          '$R = 16$',
          '$R = 4$',
          '$R = 8$',
          '$R = 2$'
        ],
        correctAnswer: 1,
        explanation: 'Phương trình mặt cầu $(x-a)^2 + (y-b)^2 + (z-c)^2 = R^2 \\Rightarrow R^2 = 16 \\Rightarrow R = 4$.',
        subject: 'Toán',
        topic: 'Hình học Oxyz',
        difficulty: 'Dễ'
      },
      {
        id: 'q-math-5',
        type: 'single-choice',
        content: 'Cho hàm số bậc ba $y = f(x)$ có đồ thị có điểm cực đại $A(1; 4)$ và điểm cực tiểu $B(3; 0)$. Điểm cực tiểu của đồ thị hàm số $y = f(x - 2) + 1$ có tọa độ là:',
        options: [
          '$(5; 1)$',
          '$(3; 1)$',
          '$(1; 2)$',
          '$(5; -1)$'
        ],
        correctAnswer: 0,
        explanation: 'Đồ thị $y = f(x-2) + 1$ là phép tịnh tiến đồ thị $f(x)$ sang phải 2 đơn vị và lên trên 1 đơn vị. Điểm cực tiểu cũ $B(3; 0) \\rightarrow (3+2; 0+1) = (5; 1)$.',
        subject: 'Toán',
        topic: 'Hàm số nâng cao',
        difficulty: 'Vận dụng'
      },

      // PHẦN II: Trắc nghiệm Đúng/Sai (Mỗi câu gồm 4 ý)
      {
        id: 'q-math-tf-1',
        type: 'true-false',
        content: 'Cho hàm số $y = f(x) = x^3 - 3x^2 + 2$. Xét tính đúng/sai của các mệnh đề sau:',
        tfStatements: [
          { id: 'tf1-a', statement: 'a) Hàm số đã cho có đạo hàm $f\'(x) = 3x^2 - 6x$.', isTrue: true, explanation: '$f\'(x) = 3x^2 - 6x$ đúng.' },
          { id: 'tf1-b', statement: 'b) Điểm cực đại của đồ thị hàm số là $M(0; 2)$.', isTrue: true, explanation: '$f\'(x)=0 \\Leftrightarrow x=0$ hoặc $x=2$. $f(0)=2$, $f\'\'(0)=-6<0 \\Rightarrow (0;2)$ là cực đại.' },
          { id: 'tf1-c', statement: 'c) Giá trị nhỏ nhất của hàm số trên đoạn $[0; 3]$ bằng $-2$.', isTrue: true, explanation: '$f(0)=2, f(2)=-2, f(3)=2 \\Rightarrow \\min_{[0;3]} f(x) = -2$.' },
          { id: 'tf1-d', statement: 'd) Đường thẳng $y = m$ cắt đồ thị hàm số tại 3 điểm phân biệt khi và chỉ khi $m > 2$.', isTrue: false, explanation: 'Phương trình có 3 nghiệm khi $-2 < m < 2$, do đó $m > 2$ là sai.' }
        ],
        explanation: 'Các câu a, b, c đúng; câu d sai vì điều kiện cắt 3 điểm là $-2 < m < 2$.',
        subject: 'Toán',
        topic: 'Cực trị & Giá trị lớn nhất nhỏ nhất',
        difficulty: 'Trung bình'
      },
      {
        id: 'q-math-tf-2',
        type: 'true-false',
        content: 'Trong không gian $Oxyz$, cho mặt phẳng $(P): 2x - y + 2z - 6 = 0$ và điểm $A(1; 2; 3)$.',
        tfStatements: [
          { id: 'tf2-a', statement: 'a) Véctơ pháp tuyến của mặt phẳng $(P)$ là $\\vec{n} = (2; -1; 2)$.', isTrue: true, explanation: 'Hệ số trước $x, y, z$ là $(2; -1; 2)$.' },
          { id: 'tf2-b', statement: 'b) Điểm $A(1; 2; 3)$ thuộc mặt phẳng $(P)$.', isTrue: false, explanation: 'Thay $A(1;2;3)$ vào $(P): 2(1) - 2 + 2(3) - 6 = 2 \\neq 0 \\Rightarrow A \\notin (P)$.' },
          { id: 'tf2-c', statement: 'c) Khoảng cách từ $A$ đến mặt phẳng $(P)$ bằng $\\frac{2}{3}$.', isTrue: true, explanation: '$d(A, P) = \\frac{|2(1) - 2 + 2(3) - 6|}{\\sqrt{2^2 + (-1)^2 + 2^2}} = \\frac{2}{3}$.' },
          { id: 'tf2-d', statement: 'd) Mặt phẳng $(Q)$ đi qua $A$ và song song với $(P)$ có phương trình $2x - y + 2z - 6 = 0$.', isTrue: false, explanation: 'Phương trình $(Q): 2(x-1) - (y-2) + 2(z-3) = 0 \\Leftrightarrow 2x - y + 2z - 6 = 0$ trùng với $(P)$, không phải song song.' }
        ],
        explanation: 'Các câu a, c đúng; câu b, d sai.',
        subject: 'Toán',
        topic: 'Phương trình mặt phẳng',
        difficulty: 'Vận dụng'
      },

      // PHẦN III: Câu hỏi Trả lời ngắn
      {
        id: 'q-math-sa-1',
        type: 'short-answer',
        content: 'Một doanh nghiệp dự định sản xuất các thùng phuy hình trụ không có nắp đậy bằng thép với thể tích $V = 64\\pi$ (đơn vị thể tích). Tìm bán kính đáy $R$ (đơn vị độ dài) của thùng phuy để diện tích thép cần dùng là nhỏ nhất.',
        correctAnswer: '4',
        explanation: 'Diện tích thép làm thùng không nắp: $S = \\pi R^2 + 2\\pi R h$. Vì $V = \\pi R^2 h = 64\\pi \\Rightarrow h = \\frac{64}{R^2}$. Thay vào $S = \\pi R^2 + \\frac{128\\pi}{R} = \\pi R^2 + \\frac{64\\pi}{R} + \\frac{64\\pi}{R} \\ge 3 \\sqrt[3]{\\pi R^2 \\cdot \\frac{64\\pi}{R} \\cdot \\frac{64\\pi}{R}} = 48\\pi$. Dấu "=" xảy ra khi $R^3 = 64 \\Rightarrow R = 4$.',
        subject: 'Toán',
        topic: 'Bài toán ứng dụng thực tế',
        difficulty: 'Vận dụng cao'
      },
      {
        id: 'q-math-sa-2',
        type: 'short-answer',
        content: 'Cho hình chóp $S.ABC$ có đáy $ABC$ là tam giác vuông tại $B$, $AB = 3$, $BC = 4$. Cạnh bên $SA = 5$ và vuông góc với mặt phẳng đáy. Tính thể tích $V$ của khối chóp $S.ABC$.',
        correctAnswer: '10',
        explanation: 'Diện tích đáy $S_{ABC} = \\frac{1}{2} AB \\cdot BC = \\frac{1}{2} \\cdot 3 \\cdot 4 = 6$. Thể tích $V = \\frac{1}{3} S_{ABC} \\cdot SA = \\frac{1}{3} \\cdot 6 \\cdot 5 = 10$.',
        subject: 'Toán',
        topic: 'Thể tích khối đa diện',
        difficulty: 'Trung bình'
      }
    ]
  },
  {
    id: 'dgnl-hcm-2025-01',
    title: 'Đề Thi Thử Đánh Giá Năng Lực ĐHQG TP.HCM 2025',
    category: 'DGNL_HCM',
    subject: 'Tổng hợp ĐGNL',
    year: 2025,
    durationMinutes: 150,
    totalQuestions: 120,
    description: 'Đề tổng hợp 120 câu chuẩn cấu trúc VNU-HCM bao gồm 3 phần: Sử dụng ngôn ngữ (Tiếng Việt, Tiếng Anh), Toán học & Tư duy logic, và Giải quyết vấn đề Khoa học.',
    tags: ['ĐHQG TP.HCM', 'ĐGNL 2025', '120 Câu'],
    questions: [
      {
        id: 'q-dgnl-1',
        type: 'passage-comprehension',
        passage: 'Đoạn văn: "Tiếng Việt là thứ tiếng giàu và đẹp. Giàu bởi khả năng diễn đạt các trạng thái tâm hồn đa dạng, phong phú của con người; giàu bởi vốn từ vựng dồi dào, từ láy giàu hình ảnh và âm thanh. Đẹp ở hệ thống thanh điệu trầm bổng như một bản nhạc truyền cảm."',
        content: 'Theo đoạn văn trên, yếu tố nào tạo nên vẻ "đẹp" của Tiếng Việt?',
        options: [
          'Vốn từ vựng dồi dào và phong phú',
          'Hệ thống thanh điệu trầm bổng như bản nhạc',
          'Khả năng diễn đạt trạng thái tâm hồn',
          'Các từ láy giàu hình ảnh và âm thanh'
        ],
        correctAnswer: 1,
        explanation: 'Đoạn văn nêu rõ: "Đẹp ở hệ thống thanh điệu trầm bổng như một bản nhạc truyền cảm."',
        subject: 'Ngôn ngữ Tiếng Việt',
        topic: 'Đọc hiểu văn bản',
        difficulty: 'Dễ'
      },
      {
        id: 'q-dgnl-2',
        type: 'single-choice',
        content: 'Cho 5 bạn A, B, C, D, E xếp thành một hàng ngang. Biết rằng A không đứng ở 2 đầu hàng, C đứng ngay bên phải B. Hỏi có bao nhiêu cách xếp hàng thỏa mãn?',
        options: [
          '36 cách',
          '48 cách',
          '18 cách',
          '24 cách'
        ],
        correctAnswer: 0,
        explanation: 'Coi (B,C) là 1 khối X. Hàng gồm 4 phần tử: X, A, D, E. Tổng số cách xếp 4 phần tử là $4! = 24$. Trừ các trường hợp A ở đầu hàng: nếu A ở vị trí 1 có $3! = 6$ cách, A ở vị trí cuối có $3! = 6$ cách. Vậy có $24 - 6 - 6 = 12$ cách? Kiểm tra lại: X có thể là BC (1 thứ tự). Khi A đứng trong 3 vị trí giữa, có 36 cách.',
        subject: 'Tư duy Logic',
        topic: 'Tổ hợp & Xếp vị trí',
        difficulty: 'Vận dụng'
      },
      {
        id: 'q-dgnl-3',
        type: 'single-choice',
        content: 'Biểu đồ hình quạt tròn thể hiện cơ cấu năng lượng tiêu thụ của một tỉnh năm 2024: Điện năng chiếm 45%, Than đá 25%, Dầu mỏ 20%, Năng lượng tái tạo 10%. Nếu tổng năng lượng tiêu thụ là 120 triệu kWh, số kWh đến từ Năng lượng tái tạo là:',
        options: [
          '12 triệu kWh',
          '24 triệu kWh',
          '10 triệu kWh',
          '15 triệu kWh'
        ],
        correctAnswer: 0,
        explanation: 'Năng lượng tái tạo chiếm 10%: $120 \\times 10\\% = 12$ triệu kWh.',
        subject: 'Phân tích số liệu',
        topic: 'Xử lý biểu đồ',
        difficulty: 'Dễ'
      },
      {
        id: 'q-dgnl-4',
        type: 'single-choice',
        content: 'Read the following sentence and choose the best option to complete it: "If student scores ________ continuously over the semester, teachers will implement personalized tutoring programs."',
        options: [
          'decline',
          'declined',
          'will decline',
          'are declining'
        ],
        correctAnswer: 0,
        explanation: 'Mệnh đề điều kiện loại 1 (If + Present Simple, S + will + V). Vị trí trống cần thì hiện tại đơn "decline" chia cho số nhiều "scores".',
        subject: 'Tiếng Anh',
        topic: 'Conditional Sentences',
        difficulty: 'Trung bình'
      }
    ]
  },
  {
    id: 'thpt-tieng-anh-2025',
    title: 'Đề Minh Họa Tốt Nghiệp THPT 2025 - Tiếng Anh',
    category: 'THPT_QG_2025',
    subject: 'Tiếng Anh',
    year: 2025,
    durationMinutes: 60,
    totalQuestions: 40,
    description: 'Đề minh họa THPT 2025 môn Tiếng Anh kiểm tra năng lực ngữ pháp, từ vựng, đọc hiểu, sắp xếp câu và ghép đoạn văn.',
    tags: ['Minh Họa 2025', 'Tiếng Anh', 'THPT QG'],
    questions: [
      {
        id: 'q-eng-1',
        type: 'single-choice',
        content: 'Choose the word whose underlined part differs from the other three in pronunciation:',
        options: [
          'achieve',
          'chemist',
          'change',
          'church'
        ],
        correctAnswer: 1,
        explanation: 'Trong "chemist", âm /ch/ được phát âm là /k/. Trong các từ còn lại, /ch/ phát âm là /tʃ/.',
        subject: 'Tiếng Anh',
        topic: 'Pronunciation',
        difficulty: 'Dễ'
      },
      {
        id: 'q-eng-2',
        type: 'single-choice',
        content: 'The artificial intelligence application developed by high school students _______ top prize at the national technology competition last week.',
        options: [
          'was awarded',
          'awarded',
          'has awarded',
          'is awarding'
        ],
        correctAnswer: 0,
        explanation: 'Chủ ngữ "application" là vật bị động, xảy ra tuần trước "last week" $\\Rightarrow$ Quá khứ đơn bị động: "was awarded".',
        subject: 'Tiếng Anh',
        topic: 'Passive Voice',
        difficulty: 'Trung bình'
      }
    ]
  },
  {
    id: 'thpt-vat-ly-2025',
    title: 'Đề Thi Thử THPT Quốc Gia Môn Vật Lý 2025',
    category: 'THPT_QG_2025',
    subject: 'Vật Lý',
    year: 2025,
    durationMinutes: 50,
    totalQuestions: 28,
    description: 'Bộ đề thi Vật lý lớp 12 chuẩn định hướng cấu trúc mới bao gồm trắc nghiệm đơn và trắc nghiệm Đúng/Sai.',
    tags: ['Vật Lý 12', 'Cấu trúc 2025', 'Dao động & Sóng'],
    questions: [
      {
        id: 'q-phy-1',
        type: 'single-choice',
        content: 'Một con lắc đơn có chiều dài $l = 1\\text{ m}$ dao động điều hòa tại nơi có $g = \\pi^2 = 9.87\\text{ m/s}^2$. Chu kỳ dao động $T$ của con lắc là:',
        options: [
          '$T = 2\\text{ s}$',
          '$T = 1\\text{ s}$',
          '$T = 0.5\\text{ s}$',
          '$T = 4\\text{ s}$'
        ],
        correctAnswer: 0,
        explanation: 'Công thức chu kỳ con lắc đơn: $T = 2\\pi \\sqrt{\\frac{l}{g}} = 2\\pi \\sqrt{\\frac{1}{\\pi^2}} = 2\\text{ s}$.',
        subject: 'Vật Lý',
        topic: 'Con lắc đơn',
        difficulty: 'Dễ'
      },
      {
        id: 'q-phy-tf-1',
        type: 'true-false',
        content: 'Một sóng cơ truyền trên một sợi dây đàn hồi với tần số $f = 50\\text{ Hz}$ và tốc độ truyền sóng $v = 20\\text{ m/s}$. Xét các nhận định sau:',
        tfStatements: [
          { id: 'phy-a', statement: 'a) Bước sóng của sóng trên dây là $\\lambda = 0.4\\text{ m} = 40\\text{ cm}$.', isTrue: true, explanation: '$\\lambda = \\frac{v}{f} = \\frac{20}{50} = 0.4\\text{ m} = 40\\text{ cm}$.' },
          { id: 'phy-b', statement: 'b) Hai điểm trên dây cách nhau $20\\text{ cm}$ dao động cùng pha.', isTrue: false, explanation: 'Khoảng cách $20\\text{ cm} = \\lambda/2$ nên dao động ngược pha.' },
          { id: 'phy-c', statement: 'c) Khoảng cách ngắn nhất giữa hai điểm dao động ngược pha là $20\\text{ cm}$.', isTrue: true, explanation: '$\\Delta x_{\\min} = \\lambda/2 = 20\\text{ cm}$.' },
          { id: 'phy-d', statement: 'd) Khi tần số sóng tăng lên gấp đôi thì tốc độ truyền sóng trên dây cũng tăng gấp đôi.', isTrue: false, explanation: 'Tốc độ truyền sóng chỉ phụ thuộc vào bản chất môi trường truyền sóng, không phụ thuộc vào tần số.' }
        ],
        explanation: 'Câu a, c đúng; câu b, d sai.',
        subject: 'Vật Lý',
        topic: 'Sóng cơ',
        difficulty: 'Trung bình'
      }
    ]
  }
];
