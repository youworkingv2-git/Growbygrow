const STORAGE_KEY = "so-chi-tieu-v1";

const els = {
  form: document.getElementById("expenseForm"),
  formTitle: document.getElementById("formTitle"),
  editId: document.getElementById("editId"),
  stt: document.getElementById("stt"),
  ngay: document.getElementById("ngay"),
  noiDung: document.getElementById("noiDung"),
  donGia: document.getElementById("donGia"),
  soLuong: document.getElementById("soLuong"),
  giamGia: document.getElementById("giamGia"),
  vat: document.getElementById("vat"),
  vatMode: document.getElementById("vatMode"),
  vanChuyen: document.getElementById("vanChuyen"),
  thanhTien: document.getElementById("thanhTien"),
  noiMua: document.getElementById("noiMua"),
  noiMuaList: document.getElementById("noiMuaList"),
  calcNote: document.getElementById("calcNote"),
  saveBtn: document.getElementById("saveBtn"),
  resetBtn: document.getElementById("resetBtn"),
  voiceBox: document.getElementById("voiceBox"),
  micBtn: document.getElementById("micBtn"),
  voiceStatus: document.getElementById("voiceStatus"),
  pickFileBtn: document.getElementById("pickFileBtn"),
  fileStatus: document.getElementById("fileStatus"),
  transcript: document.getElementById("transcript"),
  expenseBody: document.getElementById("expenseBody"),
  emptyState: document.getElementById("emptyState"),
  searchBox: document.getElementById("searchBox"),
  monthFilter: document.getElementById("monthFilter"),
  allMonthBtn: document.getElementById("allMonthBtn"),
  exportBtn: document.getElementById("exportBtn"),
  rowCount: document.getElementById("rowCount"),
  filteredTotal: document.getElementById("filteredTotal"),
  statToday: document.getElementById("statToday"),
  statMonth: document.getElementById("statMonth"),
  toast: document.getElementById("toast"),
};

let expenses = loadExpenses();
let recognition = null;
let listening = false;
let wantListening = false;
let committingVoice = false;
let voiceBuffer = "";
let dataFileHandle = null;
let askedForFile = false;
let toastTimer = null;

function todayISO() {
  const d = new Date();
  const offset = d.getTimezoneOffset() * 60000;
  return new Date(d.getTime() - offset).toISOString().slice(0, 10);
}

function monthISO(dateStr = todayISO()) {
  return dateStr.slice(0, 7);
}

function shiftDate(days) {
  const d = new Date();
  d.setDate(d.getDate() + days);
  const offset = d.getTimezoneOffset() * 60000;
  return new Date(d.getTime() - offset).toISOString().slice(0, 10);
}

function parseMoney(value) {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  const raw = String(value ?? "").trim();
  if (!raw) return 0;
  const normalized = raw.replace(/\./g, "").replace(/,/g, ".");
  const n = Number(normalized);
  return Number.isFinite(n) ? n : 0;
}

const ONES_WORDS = {
  không: 0, khong: 0,
  một: 1, mot: 1, mốt: 1,
  hai: 2,
  ba: 3,
  bốn: 4, bon: 4, tư: 4, tu: 4,
  năm: 5, nam: 5, lăm: 5, lam: 5, nhăm: 5, nham: 5,
  sáu: 6, sau: 6,
  bảy: 7, bay: 7,
  tám: 8, tam: 8,
  chín: 9, chin: 9,
};

const DIGIT_WORDS = ONES_WORDS;

const QTY_UNITS = "cái|hộp|kg|kilô|kilo|gói|bịch|chai|lon|bó|ram|thùng|ly|phần|lít|lit|mét|gram|gr";
const DEC_MARK = "phẩy|phay|phải|chấm";
const DIGIT_TOKEN = Object.keys(DIGIT_WORDS).join("|") + "|\\d+";
const SPOKEN_NUMBER_RE = `(?:\\d+[.,]\\d+|${DIGIT_TOKEN}|${DEC_MARK}|\\d+)(?:\\s+(?:\\d+[.,]\\d+|${DIGIT_TOKEN}|${DEC_MARK}|\\d+))*`;
const MONEY_WORD_RE = "không|khong|một|mot|mốt|hai|ba|bốn|bon|tư|tu|năm|nam|lăm|lam|nhăm|sáu|sau|bảy|bay|tám|tam|chín|chin|mười|muoi|mươi|linh|lẻ|le|trăm|tram|nghìn|nghin|ngàn|ngan|triệu|trieu|tỷ|ty|\\d+";

function normalizeSpoken(text) {
  return String(text || "")
    .toLowerCase()
    .normalize("NFC")
    .replace(/[()]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function wordToDigit(token) {
  if (token == null) return null;
  const t = String(token).toLowerCase();
  if (/^\d+$/.test(t)) return t;
  return Object.prototype.hasOwnProperty.call(DIGIT_WORDS, t) ? String(DIGIT_WORDS[t]) : null;
}

function spokenToDigitString(text) {
  const tokens = normalizeSpoken(text).split(" ").filter(Boolean);
  let out = "";
  for (const token of tokens) {
    if (/^(mười|muoi|mươi|trăm|tram|nghìn|nghin|ngàn|ngan)$/.test(token)) continue;
    const d = wordToDigit(token);
    if (d != null) out += d;
  }
  return out;
}

function onesValue(w) {
  return Object.prototype.hasOwnProperty.call(ONES_WORDS, w) ? ONES_WORDS[w] : null;
}

function normalizeMoneyTokens(text) {
  const keep = /^(mười|muoi|mươi|linh|lẻ|le|trăm|tram|nghìn|nghin|ngàn|ngan|triệu|trieu|tỷ|ty)$/;
  const raw = normalizeSpoken(text)
    .replace(/\b(đồng|dong|vnd|việt nam đồng)\b/g, " ")
    .split(/\s+/)
    .filter(Boolean);
  const out = [];
  for (let i = 0; i < raw.length; i += 1) {
    let w = raw[i];
    if (w === "muoi") {
      const prev = out[out.length - 1];
      const prevOnes = onesValue(prev);
      w = prevOnes != null && prevOnes >= 2 ? "mươi" : "mười";
    }
    if (onesValue(w) != null || /^\d+$/.test(w) || keep.test(w)) out.push(w);
  }
  return out;
}

function parseBlock999(tokens, start, end) {
  const slice = tokens.slice(start, end);
  if (!slice.length) return 0;
  if (slice.every((t) => /^\d+$/.test(t))) return Number(slice.join(""));

  let i = 0;
  let n = 0;
  const peek = (k = 0) => slice[i + k];
  const eat = () => slice[i++];

  if (onesValue(peek()) != null && (peek(1) === "trăm" || peek(1) === "tram")) {
    n += onesValue(eat()) * 100;
    eat();
  } else if (peek() === "trăm" || peek() === "tram") {
    n += 100;
    eat();
  } else if (/^\d+$/.test(peek() || "") && (peek(1) === "trăm" || peek(1) === "tram")) {
    n += Number(eat()) * 100;
    eat();
  }

  if (peek() === "linh" || peek() === "lẻ" || peek() === "le") {
    eat();
    const d = onesValue(peek());
    if (d != null) {
      n += d;
      eat();
    } else if (/^\d+$/.test(peek() || "")) n += Number(eat());
    return n;
  }

  if (peek() === "mười" || (peek() === "muoi" && onesValue(peek(1)) != null)) {
    eat();
    n += 10;
    const d = onesValue(peek());
    if (d != null) {
      n += d;
      eat();
    }
    return n;
  }

  if (onesValue(peek()) != null && (peek(1) === "mươi" || peek(1) === "muoi")) {
    n += onesValue(eat()) * 10;
    eat();
    if (peek() === "linh" || peek() === "lẻ" || peek() === "le") eat();
    const d = onesValue(peek());
    if (d != null) {
      n += d;
      eat();
    }
    return n;
  }

  const d = onesValue(peek());
  if (d != null) {
    n += d;
    eat();
  } else if (/^\d+$/.test(peek() || "") && Number(peek()) < 1000) {
    n += Number(eat());
  }
  return n;
}

function parseVietnameseInt(text) {
  const tokens = Array.isArray(text) ? text : normalizeMoneyTokens(text);
  if (!tokens.length) return null;
  if (tokens.length === 1 && /^\d+$/.test(tokens[0])) return Number(tokens[0]);

  const isMag = (w, names) => names.includes(w);
  let total = 0;
  let i = 0;

  const takeMag = (names, mag) => {
    const idx = tokens.findIndex((t, idx2) => idx2 >= i && isMag(t, names));
    if (idx < i) return;
    const left = parseBlock999(tokens, i, idx);
    total += (left || 1) * mag;
    i = idx + 1;
  };

  takeMag(["tỷ", "ty"], 1_000_000_000);
  takeMag(["triệu", "trieu"], 1_000_000);
  takeMag(["nghìn", "nghin", "ngàn", "ngan"], 1000);
  if (i < tokens.length) total += parseBlock999(tokens, i, tokens.length);
  return Number.isFinite(total) ? total : null;
}

function vietnameseWordsToInt(text) {
  return parseVietnameseInt(text);
}

function isVndThousandGrouped(s) {
  return /^[1-9]\d{0,2}([.\s]\d{3})+$/.test(s) || /^[1-9]\d{0,2}(,\d{3})+$/.test(s);
}

function parseThousandGrouped(s) {
  if (/^[1-9]\d{0,2}([.\s]\d{3})+$/.test(s)) return Number(s.replace(/[.\s]/g, ""));
  if (/^[1-9]\d{0,2}(,\d{3})+$/.test(s)) return Number(s.replace(/,/g, ""));
  return null;
}

function parseSpokenNumber(phrase) {
  if (phrase == null) return null;
  if (typeof phrase === "number" && Number.isFinite(phrase)) return phrase;
  let s = normalizeSpoken(phrase).replace(/\b(kg|kilô|kilo|cái|hộp|gói|bịch|chai|lon|bó|ram|thùng|ly|phần|lít|lit|mét|gram|gr)\b/g, " ").trim();
  if (!s) return null;

  const grouped = parseThousandGrouped(s);
  if (grouped != null) return grouped;

  if (/^\d+([.,]\d+)?$/.test(s)) {
    const n = Number(s.replace(",", "."));
    return Number.isFinite(n) ? n : null;
  }

  s = s.replace(/\b(phẩy|phay|phải|chấm)\b/g, " . ");
  s = s.replace(",", " . ");
  const parts = s.split(/\s*\.\s*/).map((p) => p.trim()).filter((p, i, arr) => p || i < arr.length - 1);
  if (!parts.length) return null;

  const intText = parts[0];
  const fracText = parts.slice(1).join(" ");
  let intVal = 0;
  if (intText) {
    if (/^\d+$/.test(intText.replace(/\s/g, ""))) intVal = Number(intText.replace(/\s/g, ""));
    else {
      const tokens = intText.split(" ").filter(Boolean);
      const hasScale = tokens.some((t) => /^(mười|muoi|mươi|trăm|tram|nghìn|nghin|ngàn|ngan)$/.test(t));
      intVal = hasScale || tokens.length === 1
        ? vietnameseWordsToInt(intText)
        : Number(spokenToDigitString(intText));
    }
  }
  if (intVal == null || !Number.isFinite(intVal)) return null;
  if (!fracText) return intVal;

  const fracTokens = fracText.split(" ").filter(Boolean);
  const fracHasScale = fracTokens.some((t) => /^(mười|muoi|mươi|trăm|tram)$/.test(t));
  const fracDigits = fracHasScale
    ? String(vietnameseWordsToInt(fracText) ?? "")
    : spokenToDigitString(fracText);
  if (!fracDigits) return intVal;
  if (intVal >= 1 && /^\d{3}$/.test(fracDigits) && !/\b(phẩy|phay|phải)\b/.test(normalizeSpoken(phrase))) {
    return intVal * 1000 + Number(fracDigits);
  }
  const n = Number(`${intVal}.${fracDigits}`);
  return Number.isFinite(n) ? n : null;
}

function parseQuantity(value) {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  const raw = String(value ?? "").trim();
  if (!raw) return 0;
  const spoken = parseSpokenNumber(raw);
  if (spoken != null) return spoken;
  if (raw.includes(",")) {
    const n = Number(raw.replace(/\./g, "").replace(",", "."));
    return Number.isFinite(n) ? n : 0;
  }
  if (/^\d+\.\d+$/.test(raw)) {
    const n = Number(raw);
    return Number.isFinite(n) ? n : 0;
  }
  return parseMoney(raw);
}

function formatQuantity(n) {
  if (n == null || !Number.isFinite(Number(n))) return "";
  return new Intl.NumberFormat("vi-VN", {
    maximumFractionDigits: 6,
    minimumFractionDigits: 0,
  }).format(Number(n));
}

function extractQuantity(text) {
  const src = normalizeSpoken(text);
  const labeled = src.match(new RegExp(`(?:số\\s*lượng|so\\s*luong|sl)(?:\\s+là)?\\s*:?\\s+(${SPOKEN_NUMBER_RE})`, "i"));
  if (labeled) {
    const n = parseSpokenNumber(labeled[1]);
    if (n != null) return { value: n, matched: labeled[0] };
  }
  const withUnit = src.match(new RegExp(`(${SPOKEN_NUMBER_RE})\\s*(?:${QTY_UNITS})\\b`, "i"));
  if (withUnit) {
    const n = parseSpokenNumber(withUnit[1]);
    if (n != null) return { value: n, matched: withUnit[0] };
  }
  if (/\b(phẩy|phay|chấm)\b/.test(src) || /\d+[.,]\d+/.test(src)) {
    const onlyNum = src.match(new RegExp(`(?:^|\\s)(${SPOKEN_NUMBER_RE})(?:\\s|$)`, "i"));
    if (onlyNum && !isVndThousandGrouped(onlyNum[1].replace(/\s/g, ""))) {
      const n = parseSpokenNumber(onlyNum[1]);
      if (n != null && !Number.isInteger(n) && n < 1000) return { value: n, matched: onlyNum[1] };
    }
  }
  return null;
}

function escapeRegex(s) {
  return String(s).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function tidySpokenText(value) {
  let s = String(value || "").replace(/\s+/g, " ").trim();
  s = s.replace(/^[\s,.;:!?…“”"'‘’()[\]]+/u, "").replace(/[\s,.;:!?…“”"'‘’()[\]]+$/u, "");
  s = s.replace(/\s+,/g, ",").replace(/,(?=\S)/g, ", ");
  s = s.replace(/^,+\s*/g, "").replace(/\s*,+$/g, "");
  return s.replace(/\s+/g, " ").trim();
}

function cleanNoiDung(original, qtyMatched) {
  const labeled = original.match(/nội dung\s+(.+?)(?=\s+(?:số lượng|sl|đơn giá|giá|ngày|nơi mua|vat|thuế|giảm|vận chuyển|ship|tại|ở|chỗ)|$)/i);
  let s = labeled ? labeled[1] : original;
  s = ` ${s.trim()} `;

  const strip = (re) => {
    s = s.replace(re, " ");
  };

  strip(/\bhôm nay\b/gi);
  strip(/\bhôm qua\b/gi);
  strip(/\bngày kia\b/gi);
  strip(/ngày\s+\d{1,2}[/\-]\d{1,2}(?:[/\-]\d{2,4})?/gi);
  strip(/ngày\s+\d{1,2}\s*tháng\s*\d{1,2}(?:\s*năm\s*\d{4})?/gi);
  if (qtyMatched) strip(new RegExp(escapeRegex(qtyMatched), "gi"));
  strip(new RegExp(`(?:số\\s*lượng|so\\s*luong|sl)(?:\\s+là)?\\s*:?\\s+(?:${SPOKEN_NUMBER_RE})(?:\\s+(?:${QTY_UNITS}))?`, "gi"));
  strip(new RegExp(`(?:${SPOKEN_NUMBER_RE})\\s+(?:${QTY_UNITS})\\b`, "gi"));
  strip(/(?:đơn giá|(?<!giảm )giá)\s+(?:\d{1,3}(?:[.\s]\d{3})+|\d+(?:[.,]\d+)?)\s*(?:triệu|tr|nghìn|ngàn|k)?\s*(?:đồng|vnd)?/gi);
  strip(/(?:giảm giá|giảm|chiết khấu)\s+(?:\d+(?:[.,]\d+)?\s*(?:%|phần trăm)|(?:\d{1,3}(?:[.\s]\d{3})+|\d+(?:[.,]\d+)?)\s*(?:triệu|tr|nghìn|ngàn|k)?\s*(?:đồng|vnd)?)/gi);
  strip(/(?:vat|thuế gtgt|thuế)\s+\d+(?:[.,]\d+)?\s*(?:%|phần trăm|đồng|nghìn|ngàn|k)?/gi);
  strip(/(?:vận chuyển|phí ship|ship|giao hàng)\s+(?:\d{1,3}(?:[.\s]\d{3})+|\d+(?:[.,]\d+)?)\s*(?:triệu|tr|nghìn|ngàn|k)?\s*(?:đồng|vnd)?/gi);
  strip(/(?:tại|ở|chỗ|mua tại|mua ở)\s+.+$/gi);
  strip(/(?:\d{1,3}(?:[.\s]\d{3})+|\d+(?:[.,]\d+)?)\s*(?:triệu|tr|nghìn|ngàn|ngan|k)\s*(?:đồng|vnd|việt nam đồng)?/gi);
  strip(/(?:\d{1,3}(?:[.\s]\d{3})+|\d+(?:[.,]\d+)?)\s*(?:đồng|vnd|việt nam đồng)\b/gi);
  strip(/(?:đơn giá|(?<!giảm )giá)\s+/gi);
  strip(/\b(?:không|khong|một|mot|mốt|hai|ba|bốn|bon|tư|năm|lăm|sáu|bảy|tám|chín|chin|mười|mươi|linh|lẻ|trăm|tram|nghìn|nghin|ngàn|ngan|triệu|\d+)(?:\s+(?:không|khong|một|mot|mốt|hai|ba|bốn|bon|tư|năm|lăm|sáu|bảy|tám|chín|chin|mười|mươi|linh|lẻ|trăm|tram|nghìn|nghin|ngàn|ngan|triệu|\d+))+\s*(?:đồng|vnd)?/gi);
  strip(/\b(?:nội dung|khoản chi)\b/gi);

  s = s.replace(/\s+/g, " ").trim();
  s = s.replace(/(?:^|\s)hết(?:\s+(?:rồi|nhé|nha|ạ))?\s*$/i, "").trim();
  if (!/\bcá\s+đồng$/i.test(s)) {
    s = s.replace(/\s+(?:đồng|vnd|việt nam đồng)\s*$/i, "").trim();
  }
  return tidySpokenText(s);
}

function formatVND(n) {
  return new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
    maximumFractionDigits: 0,
  }).format(Math.round(n || 0));
}

function formatNumber(n) {
  return new Intl.NumberFormat("vi-VN", { maximumFractionDigits: 2 }).format(n || 0);
}

function formatDate(iso) {
  if (!iso) return "";
  const [y, m, d] = iso.split("-");
  return `${d}/${m}/${y}`;
}

function calcTotals(input) {
  const donGia = parseMoney(input.donGia);
  const soLuong = parseQuantity(input.soLuong);
  const giamGia = parseMoney(input.giamGia);
  const vanChuyen = parseMoney(input.vanChuyen);
  const vatRaw = parseMoney(input.vat);
  const hangHoa = Math.max(0, donGia * soLuong - giamGia);
  const vatAmount = input.vatMode === "percent" ? hangHoa * (vatRaw / 100) : vatRaw;
  const thanhTien = hangHoa + vatAmount + vanChuyen;
  return { donGia, soLuong, giamGia, vanChuyen, vatRaw, hangHoa, vatAmount, thanhTien };
}

function updateCalc() {
  const totals = calcTotals({
    donGia: els.donGia.value,
    soLuong: els.soLuong.value,
    giamGia: els.giamGia.value,
    vat: els.vat.value,
    vatMode: els.vatMode.value,
    vanChuyen: els.vanChuyen.value,
  });
  els.thanhTien.value = formatNumber(totals.thanhTien);
  const vatLabel = els.vatMode.value === "percent"
    ? `VAT ${totals.vatRaw}% = ${formatVND(totals.vatAmount)}`
    : `VAT ${formatVND(totals.vatAmount)}`;
  els.calcNote.textContent = `(Đơn giá × số lượng − giảm giá) + ${vatLabel} + vận chuyển`;
}

function nextStt() {
  return expenses.length ? Math.max(...expenses.map((x) => x.stt)) + 1 : 1;
}

function resetForm({ keepTranscript = false } = {}) {
  els.form.reset();
  els.editId.value = "";
  els.stt.value = nextStt();
  els.ngay.value = todayISO();
  els.soLuong.value = "1";
  els.vatMode.value = "percent";
  els.formTitle.textContent = "Thêm khoản chi";
  els.saveBtn.textContent = "Lưu khoản chi";
  if (!keepTranscript) els.transcript.textContent = "";
  updateCalc();
}

function loadExpenses() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY) || "[]");
  } catch {
    return [];
  }
}

function saveExpenses() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(expenses));
}

function upsertExpense(item) {
  const idx = expenses.findIndex((x) => x.id === item.id);
  if (idx >= 0) expenses[idx] = item;
  else expenses.push(item);
  saveExpenses();
  renderTable();
  return idx >= 0 ? "updated" : "created";
}

function updateFileStatus() {
  els.fileStatus.textContent = dataFileHandle
    ? `Sẽ ghi vào: ${dataFileHandle.name}`
    : "Chưa chọn file JSON";
}

async function pickDataFile() {
  if (!window.showSaveFilePicker) {
    showToast("Trình duyệt không cho chọn file. Dùng Chrome hoặc Edge.");
    return null;
  }
  askedForFile = true;
  try {
    const handle = await window.showSaveFilePicker({
      suggestedName: "chi-tieu.json",
      types: [{ description: "JSON chi tiêu", accept: { "application/json": [".json"] } }],
    });
    dataFileHandle = handle;
    const file = await handle.getFile();
    const text = (await file.text()).trim();
    if (text) {
      const parsed = JSON.parse(text);
      if (Array.isArray(parsed) && parsed.length) {
        expenses = parsed;
        saveExpenses();
        renderTable();
        resetForm({ keepTranscript: true });
      }
    } else {
      await writeDataFile();
    }
    updateFileStatus();
    showToast(`Đã chọn file ${handle.name}.`);
    return handle;
  } catch (err) {
    if (err && err.name !== "AbortError") {
      showToast("Không chọn được file lưu.");
    }
    return null;
  }
}

async function ensureFilePermission() {
  if (!dataFileHandle) return false;
  const opts = { mode: "readwrite" };
  let perm = await dataFileHandle.queryPermission(opts);
  if (perm !== "granted") perm = await dataFileHandle.requestPermission(opts);
  return perm === "granted";
}

async function writeDataFile() {
  const payload = JSON.stringify(expenses, null, 2);
  if (dataFileHandle) {
    const ok = await ensureFilePermission();
    if (!ok) return "denied";
    const writable = await dataFileHandle.createWritable();
    await writable.write(payload);
    await writable.close();
    return "file";
  }
  if (!window.showSaveFilePicker) {
    const blob = new Blob([payload], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "chi-tieu.json";
    a.click();
    URL.revokeObjectURL(url);
    return "download";
  }
  return "none";
}

function showToast(message) {
  els.toast.textContent = message;
  els.toast.classList.add("show");
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => els.toast.classList.remove("show"), 2200);
}

function readForm() {
  const totals = calcTotals({
    donGia: els.donGia.value,
    soLuong: els.soLuong.value,
    giamGia: els.giamGia.value,
    vat: els.vat.value,
    vatMode: els.vatMode.value,
    vanChuyen: els.vanChuyen.value,
  });
  return {
    id: els.editId.value || crypto.randomUUID(),
    stt: Number(els.stt.value) || nextStt(),
    ngay: els.ngay.value,
    noiDung: els.noiDung.value.trim(),
    donGia: totals.donGia,
    soLuong: totals.soLuong,
    giamGia: totals.giamGia,
    vat: totals.vatAmount,
    vatInput: totals.vatRaw,
    vatMode: els.vatMode.value,
    vanChuyen: totals.vanChuyen,
    thanhTien: totals.thanhTien,
    noiMua: els.noiMua.value.trim(),
  };
}

function fillForm(item) {
  els.editId.value = item.id || "";
  els.stt.value = item.stt ?? nextStt();
  els.ngay.value = item.ngay || todayISO();
  els.noiDung.value = item.noiDung || "";
  els.donGia.value = item.donGia != null ? formatNumber(item.donGia) : "";
  els.soLuong.value = item.soLuong != null ? formatQuantity(item.soLuong) : "1";
  els.giamGia.value = item.giamGia ? formatNumber(item.giamGia) : "";
  els.vatMode.value = item.vatMode || "percent";
  els.vat.value = item.vatInput != null ? item.vatInput : "";
  els.vanChuyen.value = item.vanChuyen ? formatNumber(item.vanChuyen) : "";
  els.noiMua.value = item.noiMua || "";
  updateCalc();
}

function filteredExpenses() {
  const q = els.searchBox.value.trim().toLowerCase();
  const month = els.monthFilter.value;
  return expenses
    .filter((row) => {
      const matchMonth = !month || row.ngay.startsWith(month);
      const blob = `${row.noiDung} ${row.noiMua}`.toLowerCase();
      return matchMonth && (!q || blob.includes(q));
    })
    .sort((a, b) => a.ngay.localeCompare(b.ngay) || a.stt - b.stt);
}

function escapeHtml(s) {
  return String(s).replace(/[&<>"']/g, (ch) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  }[ch]));
}

function renderPlaces() {
  const places = [...new Set(expenses.map((x) => x.noiMua).filter(Boolean))];
  els.noiMuaList.innerHTML = places.map((p) => `<option value="${escapeHtml(p)}"></option>`).join("");
}

function renderStats() {
  const today = todayISO();
  const month = monthISO();
  const todaySum = expenses.filter((x) => x.ngay === today).reduce((s, x) => s + x.thanhTien, 0);
  const monthSum = expenses.filter((x) => x.ngay.startsWith(month)).reduce((s, x) => s + x.thanhTien, 0);
  els.statToday.textContent = formatVND(todaySum);
  els.statMonth.textContent = formatVND(monthSum);
}

function renderTable() {
  const rows = filteredExpenses();
  els.expenseBody.innerHTML = rows.map((row) => `
    <tr>
      <td>${row.stt}</td>
      <td>${formatDate(row.ngay)}</td>
      <td>${escapeHtml(row.noiDung)}</td>
      <td class="num">${formatVND(row.donGia)}</td>
      <td class="num">${formatQuantity(row.soLuong)}</td>
      <td class="num">${formatVND(row.giamGia)}</td>
      <td class="num">${formatVND(row.vat)}</td>
      <td class="num">${formatVND(row.vanChuyen)}</td>
      <td class="num"><strong>${formatVND(row.thanhTien)}</strong></td>
      <td>${escapeHtml(row.noiMua || "")}</td>
      <td>
        <button class="btn icon" data-edit="${row.id}" type="button">Sửa</button>
        <button class="btn icon danger" data-del="${row.id}" type="button">Xóa</button>
      </td>
    </tr>
  `).join("");
  els.emptyState.classList.toggle("is-hidden", rows.length > 0);
  els.rowCount.textContent = `${rows.length} dòng`;
  const total = rows.reduce((sum, row) => sum + (row.thanhTien || 0), 0);
  els.filteredTotal.textContent = `Tổng: ${formatVND(total)}`;
  renderStats();
  renderPlaces();
}

function csvCell(value) {
  return `"${String(value ?? "").replace(/"/g, '""')}"`;
}

function exportCsv() {
  const rows = filteredExpenses();
  const header = ["STT", "Ngày", "Nội dung", "Đơn giá", "Số lượng", "Giảm giá", "VAT", "Vận chuyển", "Thành tiền", "Nơi mua"];
  const lines = [header.join(",")].concat(rows.map((r) => [
    r.stt,
    formatDate(r.ngay),
    csvCell(r.noiDung),
    r.donGia,
    r.soLuong,
    r.giamGia,
    r.vat,
    r.vanChuyen,
    r.thanhTien,
    csvCell(r.noiMua),
  ].join(",")));
  const blob = new Blob(["\uFEFF" + lines.join("\n")], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `chi-tieu-${els.monthFilter.value || todayISO()}.csv`;
  a.click();
  URL.revokeObjectURL(url);
}

function setMode(mode) {
  document.querySelectorAll(".mode-btn").forEach((btn) => {
    const active = btn.dataset.mode === mode;
    btn.classList.toggle("is-active", active);
    btn.setAttribute("aria-selected", String(active));
  });
  els.voiceBox.hidden = mode !== "voice";
}

function toAmount(raw) {
  if (raw == null) return null;
  if (typeof raw === "number" && Number.isFinite(raw)) return raw;
  let s = normalizeSpoken(raw);
  if (!s) return null;

  const grouped = s.match(/[1-9]\d{0,2}(?:[.\s]\d{3})+|[1-9]\d{0,2}(?:,\d{3})+/);
  if (grouped) {
    const n = parseThousandGrouped(grouped[0].replace(/\s+/g, ".").replace(/\.\./g, "."))
      ?? Number(grouped[0].replace(/[.\s,]/g, ""));
    if (Number.isFinite(n) && n >= 1000) return n;
  }

  if (/(?:trăm|tram|nghìn|nghin|ngàn|ngan|triệu|mười|mươi)\b/.test(s)) {
    const spoken = parseVietnameseInt(s);
    if (spoken != null && spoken >= 100) return spoken;
  }

  s = s.replace(/đồng|vnd|việt nam đồng/g, " ").replace(/\s+/g, " ").trim();
  const hasMillion = /triệu|\btr\b/.test(s);
  const hasThousand = /nghìn|ngàn|ngan|\bk\b/.test(s);
  const nums = [...s.matchAll(/(\d+(?:[.,]\d+)?)/g)].map((x) => x[1]);
  if (!nums.length) return null;

  if (hasMillion) {
    const tr = Number(nums[0].replace(",", "."));
    if (!Number.isFinite(tr)) return null;
    let extra = 0;
    if (nums[1]) {
      const n2 = Number(nums[1].replace(",", "."));
      if (n2 < 10) extra = n2 * 100_000;
      else if (n2 < 1000) extra = n2 * 1000;
      else extra = n2;
    }
    return tr * 1_000_000 + extra;
  }

  const first = nums[0];
  const thousand = parseThousandGrouped(first);
  if (thousand != null) return hasThousand ? thousand : thousand;
  const compact = first.includes(",") && !/,\d{3}$/.test(first)
    ? first.replace(/\./g, "").replace(",", ".")
    : first.replace(/\./g, "");
  let n = Number(compact);
  if (!Number.isFinite(n)) return null;
  if (hasThousand) n *= 1000;
  return n;
}

function moneyFromPhrase(text) {
  const src = normalizeSpoken(text);
  if (!src) return null;

  const grouped = src.match(/[1-9]\d{0,2}(?:[.\s]\d{3})+|[1-9]\d{0,2}(?:,\d{3})+/);
  if (grouped) {
    const n = toAmount(grouped[0]);
    if (n != null) return n;
  }

  const tokens = normalizeMoneyTokens(src);
  const isNumTok = (w) => onesValue(w) != null || /^\d+$/.test(w)
    || ["mười", "mươi", "linh", "lẻ", "le", "trăm", "tram", "nghìn", "nghin", "ngàn", "ngan", "triệu", "trieu", "tỷ", "ty"].includes(w);
  let best = null;
  for (let i = 0; i < tokens.length; i += 1) {
    if (!isNumTok(tokens[i])) continue;
    let j = i;
    while (j < tokens.length && isNumTok(tokens[j])) j += 1;
    const slice = tokens.slice(i, j);
    const hasScale = slice.some((t) => ["trăm", "tram", "nghìn", "nghin", "ngàn", "ngan", "triệu", "trieu", "tỷ", "ty", "mươi", "mười"].includes(t));
    if (hasScale) {
      const val = parseVietnameseInt(slice);
      if (val != null && val >= 100 && (best == null || val > best)) best = val;
    }
    i = j - 1;
  }
  if (best != null) return best;

  const match = src.match(/(\d{1,3}(?:[.\s]\d{3})+|\d+(?:[.,]\d+)?)(\s*(triệu|tr|nghìn|ngàn|ngan|k))?(\s+\d+(?:[.,]\d+)?)?/);
  return match ? toAmount(match[0]) : null;
}

function parseVoice(transcript) {
  const original = transcript.trim();
  const text = original.toLowerCase();
  const result = {};

  if (/\bhôm nay\b/.test(text)) result.ngay = todayISO();
  else if (/\bhôm qua\b/.test(text)) result.ngay = shiftDate(-1);
  else if (/\bngày kia\b/.test(text)) result.ngay = shiftDate(-2);

  const dateSlash = text.match(/ngày\s+(\d{1,2})[/\-](\d{1,2})(?:[/\-](\d{2,4}))?/);
  const dateWords = text.match(/ngày\s+(\d{1,2})\s*tháng\s*(\d{1,2})(?:\s*năm\s*(\d{4}))?/);
  const picked = dateSlash || dateWords;
  if (picked) {
    const dd = picked[1].padStart(2, "0");
    const mm = picked[2].padStart(2, "0");
    const year = picked[3] ? (picked[3].length === 2 ? `20${picked[3]}` : picked[3]) : String(new Date().getFullYear());
    result.ngay = `${year}-${mm}-${dd}`;
  }

  const qty = extractQuantity(text);
  if (qty) result.soLuong = qty.value;

  const discount = text.match(/(?:giảm giá|giảm|chiết khấu)\s*(\d+(?:[.,]\d+)?\s*(?:%|phần trăm)|\d{1,3}(?:[.\s]\d{3})+|\d+(?:[.,]\d+)?\s*(?:triệu|tr|nghìn|ngàn|k)?)/);
  if (discount) {
    if (/%|phần trăm/.test(discount[1])) {
      result._giamPercent = Number(discount[1].replace(/[^\d.,]/g, "").replace(",", "."));
    } else {
      result.giamGia = toAmount(discount[1]);
    }
  }

  const vat = text.match(/(?:vat|thuế gtgt|thuế)\s*(\d+(?:[.,]\d+)?)\s*(%|phần trăm|đồng|nghìn|ngàn|k)?/);
  if (vat) {
    const n = Number(vat[1].replace(",", "."));
    if (!vat[2] || vat[2] === "%" || vat[2] === "phần trăm") {
      result.vatMode = "percent";
      result.vatInput = n;
    } else {
      result.vatMode = "amount";
      result.vatInput = toAmount(vat[0]);
    }
  }

  const ship = text.match(/(?:vận chuyển|phí ship|ship|giao hàng)\s*(\d{1,3}(?:[.\s]\d{3})+|\d+(?:[.,]\d+)?\s*(?:triệu|tr|nghìn|ngàn|k)?)/);
  if (ship) result.vanChuyen = toAmount(ship[1]);

  const unitPrice = text.match(/(?:đơn giá|(?<!giảm )giá)\s*(\d{1,3}(?:[.\s]\d{3})+|\d+(?:[.,]\d+)?\s*(?:triệu|tr|nghìn|ngàn|k)?)/);
  if (unitPrice) result.donGia = toAmount(unitPrice[1]);

  const place = original.match(/(?:tại|ở|chỗ|mua tại|mua ở)\s+(.+)$/i);
  if (place) result.noiMua = place[1].replace(/[.?!]+$/, "").trim();

  if (result.donGia == null) {
    const leftover = text
      .replace(/(hôm nay|hôm qua|ngày kia)/g, " ")
      .replace(/ngày\s+\d{1,2}.+?(năm\s+\d{4})?/g, " ")
      .replace(qty?.matched ? new RegExp(escapeRegex(qty.matched), "gi") : /(?:số lượng|sl)\s*\d+(?:[.,]\d+)?/gi, " ")
      .replace(/\d+(?:[.,]\d+)?\s*(cái|hộp|kg|gói|bịch|chai|lon|bó|ram|thùng|ly|phần)/g, " ")
      .replace(/(?:giảm giá|giảm|chiết khấu)\s*(?:\d+(?:[.,]\d+)?\s*(?:%|phần trăm)|\d{1,3}(?:[.\s]\d{3})+|\d+(?:[.,]\d+)?\s*(?:triệu|tr|nghìn|ngàn|k)?)/g, " ")
      .replace(/(?:vat|thuế gtgt|thuế)\s*\d+(?:[.,]\d+)?\s*(?:%|phần trăm|đồng|nghìn|ngàn|k)?/g, " ")
      .replace(/(?:vận chuyển|phí ship|ship|giao hàng)\s*(?:\d{1,3}(?:[.\s]\d{3})+|\d+(?:[.,]\d+)?\s*(?:triệu|tr|nghìn|ngàn|k)?)/g, " ")
      .replace(/(?:đơn giá|(?<!giảm )giá)\s*(?:\d{1,3}(?:[.\s]\d{3})+|\d+(?:[.,]\d+)?\s*(?:triệu|tr|nghìn|ngàn|k)?)/g, " ")
      .replace(/(?:tại|ở|chỗ|mua tại|mua ở)\s+.+$/g, " ");
    result.donGia = moneyFromPhrase(leftover);
  }

  result.noiDung = cleanNoiDung(original, qty?.matched);

  if (result._giamPercent != null && result.donGia != null) {
    const qtyN = result.soLuong != null ? result.soLuong : 1;
    result.giamGia = result.donGia * qtyN * (result._giamPercent / 100);
  }

  return result;
}

function applyVoiceResult(parsed) {
  if (parsed.ngay) els.ngay.value = parsed.ngay;
  if (parsed.noiDung != null) els.noiDung.value = tidySpokenText(parsed.noiDung);
  if (parsed.donGia != null) els.donGia.value = formatNumber(parsed.donGia);
  if (parsed.soLuong != null) els.soLuong.value = formatQuantity(parsed.soLuong);
  if (parsed.giamGia != null) els.giamGia.value = formatNumber(parsed.giamGia);
  if (parsed.vatMode) els.vatMode.value = parsed.vatMode;
  if (parsed.vatInput != null) els.vat.value = parsed.vatInput;
  if (parsed.vanChuyen != null) els.vanChuyen.value = formatNumber(parsed.vanChuyen);
  if (parsed.noiMua) els.noiMua.value = parsed.noiMua;
  updateCalc();
}

function joinSpeech(a, b) {
  const left = String(a || "").trim();
  const right = String(b || "").trim();
  if (!left) return right;
  if (!right) return left;
  return `${left} ${right}`;
}

function detectStopCommand(text) {
  const cleaned = String(text || "").trim();
  const match = cleaned.match(/^(.*?)(?:^|[\s,.;:!?])hết(?:\s+(?:rồi|nhé|nha|ạ))?\s*[.!?]*$/i);
  if (!match) return null;
  return tidySpokenText(match[1]);
}

async function commitVoiceEntry(spoken) {
  if (committingVoice) return;
  committingVoice = true;
  wantListening = false;
  try {
    if (recognition && listening) {
      try { recognition.stop(); } catch {}
    }
    const text = String(spoken || "").trim();
    els.transcript.textContent = text ? `${text} hết` : "hết";
    if (!text) {
      els.voiceStatus.textContent = "Đã nghe “hết” nhưng chưa có nội dung nên chưa ghi file.";
      showToast("Nói nội dung trước, rồi mới nói hết.");
      return;
    }

    resetForm({ keepTranscript: true });
    applyVoiceResult(parseVoice(text));
    const item = readForm();
    item.id = crypto.randomUUID();
    item.stt = nextStt();
    item.noiDung = tidySpokenText(item.noiDung || text);
    upsertExpense(item);

    let savedTo = "none";
    try {
      savedTo = await writeDataFile();
    } catch (err) {
      savedTo = "error";
    }

    if (savedTo === "file") {
      els.voiceStatus.textContent = `Đã ghi vào ${dataFileHandle.name} sau khi bạn nói hết.`;
      showToast(`Đã ghi khoản chi vào ${dataFileHandle.name}.`);
    } else if (savedTo === "download") {
      els.voiceStatus.textContent = "Đã tải file chi-tieu.json sau khi bạn nói hết.";
      showToast("Đã ghi khoản chi ra file chi-tieu.json.");
    } else if (!dataFileHandle) {
      els.voiceStatus.textContent = "Đã lưu trên trang. Hãy chọn file JSON nếu muốn ghi ra file.";
      showToast("Đã lưu khoản chi. Chưa chọn file nên chưa ghi ra đĩa.");
    } else {
      els.voiceStatus.textContent = "Đã lưu trên trang nhưng chưa ghi được file. Hãy chọn lại file.";
      showToast("Đã lưu khoản chi, nhưng ghi file bị lỗi.");
    }
    resetForm();
    els.transcript.textContent = `Đã ghi: ${item.noiDung}`;
  } finally {
    committingVoice = false;
    listening = false;
    voiceBuffer = "";
    els.micBtn.classList.remove("is-listening");
  }
}

function startRecognition() {
  if (!recognition || !wantListening) return;
  try {
    recognition.start();
  } catch {
    // already started
  }
}

function setupVoice() {
  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  if (!SpeechRecognition) {
    els.voiceStatus.textContent = "Trình duyệt này chưa hỗ trợ giọng nói. Hãy dùng Chrome hoặc Edge.";
    els.micBtn.disabled = true;
    return;
  }

  recognition = new SpeechRecognition();
  recognition.lang = "vi-VN";
  recognition.interimResults = true;
  recognition.continuous = true;

  recognition.onstart = () => {
    listening = true;
    els.micBtn.classList.add("is-listening");
    els.voiceStatus.textContent = "Đang nghe... nói xong thì nói “hết” để ghi dữ liệu.";
  };
  recognition.onend = () => {
    listening = false;
    if (wantListening && !committingVoice) {
      setTimeout(startRecognition, 250);
      return;
    }
    els.micBtn.classList.remove("is-listening");
    if (!committingVoice) {
      els.voiceStatus.textContent = voiceBuffer
        ? "Đã dừng. Chưa ghi vì chưa nói “hết”."
        : "Nhấn micro, nói khoản chi, khi xong hãy nói “hết”.";
    }
  };
  recognition.onerror = (e) => {
    if (e.error === "not-allowed") {
      wantListening = false;
      els.voiceStatus.textContent = "Cần cho phép micro rồi thử lại.";
      return;
    }
    if (e.error === "no-speech" || e.error === "aborted") return;
    els.voiceStatus.textContent = "Không nhận được giọng nói. Hãy thử lại.";
  };
  recognition.onresult = (event) => {
    if (!wantListening || committingVoice) return;
    let interim = "";
    for (let i = event.resultIndex; i < event.results.length; i += 1) {
      const t = event.results[i][0].transcript;
      if (event.results[i].isFinal) voiceBuffer = joinSpeech(voiceBuffer, t);
      else interim += t;
    }
    const live = joinSpeech(voiceBuffer, interim);
    els.transcript.textContent = live;
    const stopped = detectStopCommand(voiceBuffer);
    if (stopped != null) commitVoiceEntry(stopped);
  };
}

els.form.addEventListener("submit", (e) => {
  e.preventDefault();
  const item = readForm();
  if (!item.noiDung || !item.ngay) return;
  const action = upsertExpense(item);
  writeDataFile().catch(() => {});
  showToast(action === "updated" ? "Đã cập nhật khoản chi." : "Đã lưu khoản chi.");
  resetForm();
});

els.resetBtn.addEventListener("click", resetForm);
["donGia", "soLuong", "giamGia", "vat", "vanChuyen"].forEach((id) => {
  els[id].addEventListener("input", updateCalc);
});
els.vatMode.addEventListener("change", updateCalc);
els.searchBox.addEventListener("input", renderTable);
els.monthFilter.addEventListener("change", renderTable);
els.allMonthBtn.addEventListener("click", () => {
  els.monthFilter.value = "";
  renderTable();
});
els.exportBtn.addEventListener("click", exportCsv);

document.querySelectorAll(".mode-btn").forEach((btn) => {
  btn.addEventListener("click", () => setMode(btn.dataset.mode));
});

els.pickFileBtn.addEventListener("click", () => {
  pickDataFile();
});

els.micBtn.addEventListener("click", async () => {
  if (!recognition) return;
  if (wantListening || listening) {
    wantListening = false;
    try { recognition.stop(); } catch {}
    els.voiceStatus.textContent = voiceBuffer
      ? "Đã dừng. Chưa ghi vì chưa nói “hết”."
      : "Nhấn micro, nói khoản chi, khi xong hãy nói “hết”.";
    showToast("Đã dừng nghe. Dữ liệu chưa được ghi.");
    return;
  }

  if (!dataFileHandle && !askedForFile && window.showSaveFilePicker) {
    askedForFile = true;
    await pickDataFile();
  }

  voiceBuffer = "";
  committingVoice = false;
  wantListening = true;
  els.transcript.textContent = "";
  els.voiceStatus.textContent = "Đang nghe... nói xong thì nói “hết” để ghi dữ liệu.";
  startRecognition();
});

els.expenseBody.addEventListener("click", (e) => {
  const editId = e.target.dataset.edit;
  const delId = e.target.dataset.del;
  if (editId) {
    const item = expenses.find((x) => x.id === editId);
    if (!item) return;
    fillForm(item);
    els.formTitle.textContent = "Sửa khoản chi";
    els.saveBtn.textContent = "Cập nhật";
    window.scrollTo({ top: 0, behavior: "smooth" });
  }
  if (delId) {
    if (!confirm("Xóa khoản chi này?")) return;
    expenses = expenses.filter((x) => x.id !== delId);
    saveExpenses();
    writeDataFile().catch(() => {});
    renderTable();
    if (!els.editId.value) els.stt.value = nextStt();
    showToast("Đã xóa khoản chi.");
  }
});

els.monthFilter.value = monthISO();
updateFileStatus();
setupVoice();
resetForm();
renderTable();
