import { FormulaTopic } from '../types/exam';

export const FORMULAS_DATA: FormulaTopic[] = [
  {
    id: 'f-math-1',
    subject: 'Toán',
    category: 'Khảo sát & Đạo hàm',
    title: 'Bảng Đạo Hàm Các Hàm Số Cơ Bản & Nâng Cao',
    latex: '\\left(x^n\\right)\' = n x^{n-1}, \\quad (\\sin x)\' = \\cos x, \\quad (\\cos x)\' = -\\sin x, \\quad (e^x)\' = e^x',
    description: 'Các quy tắc tính đạo hàm tổng, tích, thương và đạo hàm của hàm hợp $y = f(u(x))$.',
    keyNotes: [
      'Đạo hàm hàm hợp: $(f(u))\' = u\' \\cdot f\'(u)$',
      'Đạo hàm thương: $\\left(\\frac{u}{v}\\right)\' = \\frac{u\'v - uv\'}{v^2}$',
      'Tiệm cận ngang $y = y_0$ khi $\\lim_{x \\to \\pm\\infty} f(x) = y_0$'
    ]
  },
  {
    id: 'f-math-2',
    subject: 'Toán',
    category: 'Tích Phân & Nguyên Hàm',
    title: 'Công Thức Nguyên Hàm Cơ Bản & Đổi Biến',
    latex: '\\int x^n dx = \\frac{x^{n+1}}{n+1} + C, \\quad \\int \\frac{1}{x} dx = \\ln|x| + C, \\quad \\int u\' e^u dx = e^u + C',
    description: 'Phương pháp đổi biến số và tích phân từng phần $\\int u dv = uv - \\int v du$.',
    keyNotes: [
      'Công thức Newton-Leibniz: $\\int_{a}^{b} f(x)dx = F(b) - F(a)$',
      'Diện tích hình phẳng: $S = \\int_{a}^{b} |f(x) - g(x)| dx$',
      'Thể tích khối tròn xoay quanh Oy/Ox: $V = \\pi \\int_{a}^{b} [f(x)]^2 dx$'
    ]
  },
  {
    id: 'f-math-3',
    subject: 'Toán',
    category: 'Hình Học Oxyz',
    title: 'Phương Trình Mặt Phẳng & Đường Thẳng',
    latex: '(P): A(x-x_0) + B(y-y_0) + C(z-z_0) = 0 \\quad | \\quad d(M, P) = \\frac{|Ax_M + By_M + Cz_M + D|}{\\sqrt{A^2 + B^2 + C^2}}',
    description: 'Phương trình mặt cầu $(x-a)^2 + (y-b)^2 + (z-c)^2 = R^2$ và khoảng cách từ điểm tới mặt phẳng.',
    keyNotes: [
      'Tích có hướng của 2 vectơ: $\\vec{n} = [\\vec{u}_1, \\vec{u}_2]$',
      'Mặt phẳng đi qua 3 điểm $A, B, C$ có VPT $\\vec{n} = [\\vec{AB}, \\vec{AC}]$'
    ]
  },
  {
    id: 'f-phy-1',
    subject: 'Vật Lý',
    category: 'Dao Động Cơ',
    title: 'Phương Trình Dao Động Điều Hòa',
    latex: 'x = A \\cos(\\omega t + \\varphi), \\quad v = x\' = -\\omega A \\sin(\\omega t + \\varphi), \\quad a = v\' = -\\omega^2 x',
    description: 'Các đại lượng đặc trưng của dao động điều hòa: Biên độ $A$, Tần số góc $\\omega$, Pha ban đầu $\\varphi$.',
    keyNotes: [
      'Vận tốc cực đại $v_{\\max} = \\omega A$ tại VTCB',
      'Gia tốc cực đại $a_{\\max} = \\omega^2 A$ tại vị trí biên',
      'Năng lượng dao động $W = \\frac{1}{2} m \\omega^2 A^2$'
    ]
  },
  {
    id: 'f-phy-2',
    subject: 'Vật Lý',
    category: 'Sóng Cơ & Âm',
    title: 'Công Thức Bước Sóng & Độ Lệch Pha',
    latex: '\\lambda = v \\cdot T = \\frac{v}{f}, \\quad \\Delta \\varphi = \\frac{2\\pi d}{\\lambda}',
    description: 'Sự truyền sóng cơ và điều kiện giao thoa sóng.',
    keyNotes: [
      'Cực đại giao thoa: $d_2 - d_1 = k \\lambda$',
      'Cực tiểu giao thoa: $d_2 - d_1 = (k + 0.5) \\lambda$'
    ]
  },
  {
    id: 'f-chem-1',
    subject: 'Hóa Học',
    category: 'Este - Lipit',
    title: 'Phản Ứng Thủy Phân & Xà Phòng Hóa',
    latex: '\\text{RCOOR\'} + \\text{NaOH} \\xrightarrow{t^o} \\text{RCOONa} + \\text{R\'OH}',
    description: 'Phương pháp giải toán Este đơn chức và đa chức bằng bảo toàn khối lượng & bảo toàn nguyên tố.',
    keyNotes: [
      '$n_{\\text{NaOH}} = n_{\\text{gốc este}} = n_{\\text{muối}}$ (đối với este đơn chức mạch hở)',
      'Bảo toàn khối lượng: $m_{\\text{este}} + m_{\\text{NaOH}} = m_{\\text{muối}} + m_{\\text{ancol}}$'
    ]
  },
  {
    id: 'f-eng-1',
    subject: 'Tiếng Anh',
    category: 'Ngữ Pháp Trọng Tâm 12',
    title: 'Câu Điều Kiện Trộn & Thức Giả Định (Conditionals & Subjunctive)',
    description: 'Cấu trúc và cách sử dụng câu điều kiện Mix 2-3 và cấu trúc giả định với Wish/If only.',
    keyNotes: [
      'Mixed Conditional (If Past Perfect, S + would + V-bare): If I had studied harder, I would have a high score now.',
      'Wish in the past: S + wish + S + had V3/ed',
      'Passive Voice with Modal Verbs: S + modal + be + V3/ed'
    ]
  }
];
