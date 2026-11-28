#!/usr/bin/env python3
"""Generates 109 distinct, clean vector SVG illustrations for Pre-A1 and A1 vocabulary."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IMG_DIR = ROOT / "assets" / "learning" / "images"
IMG_DIR.mkdir(parents=True, exist_ok=True)


def wrap(body: str, bg: str = "#172B4D") -> str:
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128"><rect width="128" height="128" rx="22" fill="{bg}"/>{body}</svg>'


SVGS = {
    # Greetings
    "hello": wrap('<circle cx="52" cy="54" r="18" fill="#FBBF24"/><circle cx="46" cy="50" r="2.5" fill="#1E293B"/><circle cx="58" cy="50" r="2.5" fill="#1E293B"/><path d="M45 59c3 4 11 4 14 0" stroke="#1E293B" stroke-width="3" fill="none" stroke-linecap="round"/><path d="M36 96c0-14 32-14 32 0" fill="#38BDF8"/><path d="M78 44c6-10 18-6 14 6l-6 14-12-4z" fill="#FDE68A"/><path d="M74 36l8-6M88 38l10-2" stroke="#FDE047" stroke-width="3" stroke-linecap="round"/>'),
    "bye": wrap('<path d="M44 82V46a6 6 0 0 1 12 0v20V38a6 6 0 0 1 12 0v28V42a6 6 0 0 1 12 0v40c0 16-10 24-22 24s-14-10-14-24z" fill="#FBBF24"/><path d="M28 42c-4 8-4 16 0 24M96 42c4 8 4 16 0 24" stroke="#38BDF8" stroke-width="4" fill="none" stroke-linecap="round"/>'),
    "please": wrap('<path d="M64 32c18 0 32 14 32 30 0 18-16 32-32 38-16-6-32-20-32-38 0-16 14-30 32-30z" fill="#F472B6"/><path d="M52 54l12-16 12 16v30H52z" fill="#FDE68A"/><line x1="64" y1="38" x2="64" y2="84" stroke="#D97706" stroke-width="3"/>'),
    "sorry": wrap('<circle cx="64" cy="60" r="30" fill="#FDE047"/><circle cx="53" cy="54" r="3.5" fill="#1E293B"/><circle cx="75" cy="54" r="3.5" fill="#1E293B"/><path d="M52 74c6-6 18-6 24 0" stroke="#1E293B" stroke-width="4" fill="none" stroke-linecap="round"/><path d="M84 44c3 5 3 10 0 14-3-4-3-9 0-14z" fill="#38BDF8"/>'),
    "yes": wrap('<circle cx="64" cy="64" r="38" fill="#22C55E"/><path d="M44 64l14 14 28-28" stroke="#FFFFFF" stroke-width="10" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'),

    # Numbers 6-10
    "six": wrap('<circle cx="64" cy="58" r="34" fill="#3B82F6"/><text x="64" y="72" text-anchor="middle" font-family="Arial,sans-serif" font-weight="bold" font-size="44" fill="#FFFFFF">6</text><g fill="#FDE047"><circle cx="28" cy="108" r="5"/><circle cx="42" cy="108" r="5"/><circle cx="56" cy="108" r="5"/><circle cx="72" cy="108" r="5"/><circle cx="86" cy="108" r="5"/><circle cx="100" cy="108" r="5"/></g>'),
    "seven": wrap('<circle cx="64" cy="58" r="34" fill="#8B5CF6"/><text x="64" y="72" text-anchor="middle" font-family="Arial,sans-serif" font-weight="bold" font-size="44" fill="#FFFFFF">7</text><g fill="#FDE047"><circle cx="22" cy="108" r="4.5"/><circle cx="36" cy="108" r="4.5"/><circle cx="50" cy="108" r="4.5"/><circle cx="64" cy="108" r="4.5"/><circle cx="78" cy="108" r="4.5"/><circle cx="92" cy="108" r="4.5"/><circle cx="106" cy="108" r="4.5"/></g>'),
    "eight": wrap('<circle cx="64" cy="58" r="34" fill="#EC4899"/><text x="64" y="72" text-anchor="middle" font-family="Arial,sans-serif" font-weight="bold" font-size="44" fill="#FFFFFF">8</text><g fill="#FDE047"><circle cx="20" cy="108" r="4"/><circle cx="32" cy="108" r="4"/><circle cx="44" cy="108" r="4"/><circle cx="56" cy="108" r="4"/><circle cx="72" cy="108" r="4"/><circle cx="84" cy="108" r="4"/><circle cx="96" cy="108" r="4"/><circle cx="108" cy="108" r="4"/></g>'),
    "nine": wrap('<circle cx="64" cy="58" r="34" fill="#F97316"/><text x="64" y="72" text-anchor="middle" font-family="Arial,sans-serif" font-weight="bold" font-size="44" fill="#FFFFFF">9</text><g fill="#FDE047"><circle cx="20" cy="106" r="4"/><circle cx="38" cy="106" r="4"/><circle cx="56" cy="106" r="4"/><circle cx="72" cy="106" r="4"/><circle cx="90" cy="106" r="4"/><circle cx="108" cy="106" r="4"/><circle cx="46" cy="116" r="4"/><circle cx="64" cy="116" r="4"/><circle cx="82" cy="116" r="4"/></g>'),
    "ten": wrap('<circle cx="64" cy="58" r="34" fill="#10B981"/><text x="64" y="72" text-anchor="middle" font-family="Arial,sans-serif" font-weight="bold" font-size="40" fill="#FFFFFF">10</text><g fill="#FDE047"><circle cx="24" cy="104" r="4"/><circle cx="44" cy="104" r="4"/><circle cx="64" cy="104" r="4"/><circle cx="84" cy="104" r="4"/><circle cx="104" cy="104" r="4"/><circle cx="24" cy="116" r="4"/><circle cx="44" cy="116" r="4"/><circle cx="64" cy="116" r="4"/><circle cx="84" cy="116" r="4"/><circle cx="104" cy="116" r="4"/></g>'),

    # Colors
    "black": wrap('<path d="M64 24c22 22 30 38 30 52a30 30 0 1 1-60 0c0-14 8-30 30-52z" fill="#0F172A" stroke="#94A3B8" stroke-width="4"/><circle cx="52" cy="68" r="5" fill="#475569"/>'),
    "white": wrap('<path d="M64 24c22 22 30 38 30 52a30 30 0 1 1-60 0c0-14 8-30 30-52z" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="3"/><circle cx="52" cy="68" r="5" fill="#E2E8F0"/>'),
    "purple": wrap('<path d="M64 24c22 22 30 38 30 52a30 30 0 1 1-60 0c0-14 8-30 30-52z" fill="#A855F7"/><circle cx="52" cy="68" r="5" fill="#E9D5FF"/>'),
    "brown": wrap('<path d="M64 24c22 22 30 38 30 52a30 30 0 1 1-60 0c0-14 8-30 30-52z" fill="#92400E"/><circle cx="52" cy="68" r="5" fill="#D97706"/>'),

    # Shapes
    "circle": wrap('<circle cx="64" cy="64" r="36" fill="#38BDF8" stroke="#E0F2FE" stroke-width="6"/>'),
    "square": wrap('<rect x="28" y="28" width="72" height="72" rx="8" fill="#F97316" stroke="#FFEDD5" stroke-width="6"/>'),
    "triangle": wrap('<polygon points="64,24 102,98 26,98" fill="#22C55E" stroke="#DCFCE7" stroke-width="5" stroke-linejoin="round"/>'),
    "star": wrap('<polygon points="64,20 76,48 106,52 84,72 90,102 64,88 38,102 44,72 22,52 52,48" fill="#FACC15" stroke="#FEF9C3" stroke-width="4" stroke-linejoin="round"/>'),

    # Family
    "baby": wrap('<circle cx="64" cy="58" r="26" fill="#FDE68A"/><path d="M60 32c2-8 10-8 10 0" stroke="#92400E" stroke-width="4" fill="none" stroke-linecap="round"/><circle cx="54" cy="56" r="3" fill="#1E293B"/><circle cx="74" cy="56" r="3" fill="#1E293B"/><circle cx="64" cy="72" r="7" fill="#F472B6"/><circle cx="64" cy="72" r="3.5" fill="#FBCFE8"/>'),
    "grandma": wrap('<circle cx="64" cy="30" r="14" fill="#E2E8F0"/><circle cx="64" cy="64" r="26" fill="#FDE68A"/><path d="M38 56c4-20 48-20 52 0" fill="#E2E8F0"/><circle cx="54" cy="64" r="6" fill="none" stroke="#475569" stroke-width="3"/><circle cx="74" cy="64" r="6" fill="none" stroke="#475569" stroke-width="3"/><line x1="60" y1="64" x2="68" y2="64" stroke="#475569" stroke-width="3"/><path d="M56 76c4 4 12 4 16 0" stroke="#9A3412" stroke-width="3" fill="none" stroke-linecap="round"/>'),
    "grandpa": wrap('<circle cx="64" cy="64" r="26" fill="#FDE68A"/><path d="M40 52c0-18 48-18 48 0" fill="#CBD5E1"/><circle cx="54" cy="62" r="6" fill="none" stroke="#334155" stroke-width="3"/><circle cx="74" cy="62" r="6" fill="none" stroke="#334155" stroke-width="3"/><path d="M48 76c6-6 26-6 32 0" fill="#E2E8F0"/><path d="M58 82c4 3 8 3 12 0" stroke="#9A3412" stroke-width="3" fill="none"/>'),

    # Body parts
    "head": wrap('<circle cx="64" cy="64" r="30" fill="#FDBA74"/><path d="M36 52c4-24 52-24 56 0" fill="#78350F"/><circle cx="52" cy="62" r="3.5" fill="#1E293B"/><circle cx="76" cy="62" r="3.5" fill="#1E293B"/><path d="M56 76c4 4 12 4 16 0" stroke="#9A3412" stroke-width="3" fill="none" stroke-linecap="round"/>'),
    "eye": wrap('<path d="M22 64c16-24 68-24 84 0-16 24-68 24-84 0z" fill="#FFFFFF"/><circle cx="64" cy="64" r="18" fill="#3B82F6"/><circle cx="64" cy="64" r="9" fill="#0F172A"/><circle cx="70" cy="58" r="4" fill="#FFFFFF"/>'),
    "ear": wrap('<path d="M48 34c20-10 38 6 34 26-3 14-14 14-14 26 0 10-12 14-20 8" fill="#FDBA74" stroke="#C2410C" stroke-width="4" stroke-linecap="round"/><path d="M54 48c10-4 18 6 12 18-4 8-10 6-10 14" stroke="#C2410C" stroke-width="4" fill="none" stroke-linecap="round"/>'),
    "nose": wrap('<path d="M64 30v42c0 12 14 14 14 4s-6-10-14-10" fill="none" stroke="#FDBA74" stroke-width="10" stroke-linecap="round"/><circle cx="58" cy="82" r="4" fill="#C2410C"/>'),
    "mouth": wrap('<path d="M28 64c16-18 56-18 72 0-16 26-56 26-72 0z" fill="#EF4444"/><path d="M38 60h52l-6 8H44z" fill="#FFFFFF"/><path d="M48 78c8 6 24 6 32 0" fill="#F472B6"/>'),
    "hand": wrap('<rect x="44" y="60" width="40" height="38" rx="14" fill="#FDBA74"/><g fill="#FDBA74"><rect x="44" y="34" width="8" height="32" rx="4"/><rect x="54" y="26" width="8" height="40" rx="4"/><rect x="64" y="28" width="8" height="38" rx="4"/><rect x="74" y="36" width="8" height="30" rx="4"/><rect x="30" y="64" width="18" height="9" rx="4.5" transform="rotate(-28 30 64)"/></g>'),
    "foot": wrap('<path d="M44 28h24v46c0 12 28 10 28 24 0 8-12 10-30 10-18 0-22-10-22-24V28z" fill="#FDBA74"/><circle cx="96" cy="94" r="5" fill="#FDBA74"/>'),

    # Animals
    "lion": wrap('<circle cx="64" cy="64" r="38" fill="#D97706"/><circle cx="64" cy="66" r="24" fill="#FBBF24"/><circle cx="46" cy="42" r="7" fill="#FBBF24"/><circle cx="82" cy="42" r="7" fill="#FBBF24"/><circle cx="56" cy="62" r="3" fill="#1E293B"/><circle cx="72" cy="62" r="3" fill="#1E293B"/><polygon points="64,68 58,74 70,74" fill="#9A3412"/>'),
    "rabbit": wrap('<ellipse cx="50" cy="36" rx="8" ry="22" fill="#FFFFFF"/><ellipse cx="78" cy="36" rx="8" ry="22" fill="#FFFFFF"/><ellipse cx="50" cy="38" rx="4" ry="14" fill="#F9A8D4"/><ellipse cx="78" cy="38" rx="4" ry="14" fill="#F9A8D4"/><circle cx="64" cy="76" r="26" fill="#FFFFFF"/><circle cx="54" cy="72" r="3" fill="#1E293B"/><circle cx="74" cy="72" r="3" fill="#1E293B"/><circle cx="64" cy="80" r="4" fill="#F472B6"/>'),
    "bear": wrap('<circle cx="38" cy="38" r="12" fill="#92400E"/><circle cx="90" cy="38" r="12" fill="#92400E"/><circle cx="64" cy="68" r="32" fill="#B45309"/><ellipse cx="64" cy="76" rx="14" ry="11" fill="#FDE68A"/><circle cx="52" cy="60" r="3.5" fill="#1E293B"/><circle cx="76" cy="60" r="3.5" fill="#1E293B"/><ellipse cx="64" cy="72" rx="6" ry="4" fill="#1E293B"/>'),
    "frog": wrap('<circle cx="44" cy="44" r="12" fill="#22C55E"/><circle cx="84" cy="44" r="12" fill="#22C55E"/><ellipse cx="64" cy="74" rx="34" ry="24" fill="#22C55E"/><circle cx="44" cy="44" r="6" fill="#FFFFFF"/><circle cx="84" cy="44" r="6" fill="#FFFFFF"/><circle cx="44" cy="44" r="3" fill="#0F172A"/><circle cx="84" cy="44" r="3" fill="#0F172A"/><path d="M44 76c10 10 30 10 40 0" stroke="#14532D" stroke-width="4" fill="none" stroke-linecap="round"/>'),
    "cow": wrap('<rect x="34" y="42" width="60" height="54" rx="22" fill="#FFFFFF"/><ellipse cx="30" cy="46" rx="10" ry="6" fill="#1E293B"/><ellipse cx="98" cy="46" rx="10" ry="6" fill="#1E293B"/><ellipse cx="64" cy="82" rx="24" ry="14" fill="#FBCFE8"/><circle cx="56" cy="82" r="3" fill="#9D174D"/><circle cx="72" cy="82" r="3" fill="#9D174D"/><circle cx="50" cy="58" r="4" fill="#0F172A"/><circle cx="78" cy="58" r="4" fill="#0F172A"/><circle cx="46" cy="48" r="8" fill="#1E293B"/>'),

    # Fruits
    "grape": wrap('<path d="M64 20v16" stroke="#16A34A" stroke-width="5" stroke-linecap="round"/><g fill="#9333EA"><circle cx="52" cy="48" r="11"/><circle cx="76" cy="48" r="11"/><circle cx="42" cy="66" r="11"/><circle cx="64" cy="66" r="11"/><circle cx="86" cy="66" r="11"/><circle cx="52" cy="84" r="11"/><circle cx="76" cy="84" r="11"/><circle cx="64" cy="100" r="11"/></g>'),
    "mango": wrap('<path d="M72 26c18 0 28 18 22 42-6 24-26 36-42 30-16-6-16-24-4-42 8-12 14-30 24-30z" fill="#F59E0B"/><path d="M68 24l10-8" stroke="#16A34A" stroke-width="5" stroke-linecap="round"/><circle cx="76" cy="46" r="6" fill="#FEF08A" opacity="0.6"/>'),
    "pear": wrap('<path d="M64 26c10 0 14 14 16 26 4 12 14 18 14 32 0 16-14 24-30 24s-30-8-30-24c0-14 10-20 14-32 2-12 6-26 16-26z" fill="#84CC16"/><path d="M64 26v-10" stroke="#78350F" stroke-width="5" stroke-linecap="round"/>'),
    "lemon": wrap('<ellipse cx="64" cy="64" rx="38" ry="26" fill="#FACC15"/><circle cx="26" cy="64" r="6" fill="#FACC15"/><circle cx="102" cy="64" r="6" fill="#FACC15"/><ellipse cx="78" cy="36" rx="12" ry="6" transform="rotate(-24 78 36)" fill="#22C55E"/>'),

    # Food & Drinks
    "bread": wrap('<path d="M26 56c0-18 18-26 38-26s38 8 38 26c0 8-6 12-6 12v28H32V68s-6-4-6-12z" fill="#D97706"/><rect x="36" y="64" width="56" height="30" rx="6" fill="#FDE68A"/>'),
    "egg": wrap('<path d="M64 22c20 0 30 32 30 52 0 20-12 32-30 32S34 94 34 74c0-20 10-52 30-52z" fill="#FEF3C7"/><ellipse cx="52" cy="50" rx="6" ry="12" transform="rotate(-14 52 50)" fill="#FFFFFF" opacity="0.8"/>'),
    "rice": wrap('<path d="M32 62c0-18 64-18 64 0z" fill="#FFFFFF"/><path d="M26 62h76c0 24-16 38-38 38S26 86 26 62z" fill="#EF4444"/><rect x="46" y="96" width="36" height="8" rx="3" fill="#B91C1C"/>'),
    "juice": wrap('<rect x="42" y="40" width="44" height="62" rx="6" fill="#F97316"/><rect x="42" y="54" width="44" height="14" fill="#FACC15"/><path d="M72 40l8-18h14" stroke="#EC4899" stroke-width="5" fill="none" stroke-linecap="round"/>'),

    # School & Classroom
    "pencil": wrap('<polygon points="28,96 34,76 84,26 100,42 50,92" fill="#FACC15"/><polygon points="28,96 34,76 48,90" fill="#FDE68A"/><polygon points="28,96 31,86 38,93" fill="#1E293B"/><rect x="82" y="24" width="16" height="14" transform="rotate(45 90 31)" fill="#F472B6"/>'),
    "ruler": wrap('<rect x="22" y="48" width="84" height="32" rx="4" fill="#FBBF24"/><g stroke="#78350F" stroke-width="3"><line x1="36" y1="48" x2="36" y2="62"/><line x1="50" y1="48" x2="50" y2="58"/><line x1="64" y1="48" x2="64" y2="64"/><line x1="78" y1="48" x2="78" y2="58"/><line x1="92" y1="48" x2="92" y2="62"/></g>'),
    "desk": wrap('<rect x="24" y="44" width="80" height="12" rx="3" fill="#D97706"/><rect x="30" y="56" width="10" height="44" fill="#92400E"/><rect x="88" y="56" width="10" height="44" fill="#92400E"/><rect x="38" y="56" width="52" height="16" fill="#B45309"/>'),
    "teacher": wrap('<circle cx="52" cy="48" r="16" fill="#FDE68A"/><path d="M36 44c2-16 30-16 32 0" fill="#78350F"/><path d="M32 96c0-18 40-18 40 0" fill="#3B82F6"/><rect x="74" y="34" width="34" height="28" rx="3" fill="#166534" stroke="#D97706" stroke-width="3"/><line x1="66" y1="74" x2="88" y2="54" stroke="#FACC15" stroke-width="4" stroke-linecap="round"/>'),
    "school": wrap('<polygon points="64,22 24,52 104,52" fill="#EF4444"/><rect x="30" y="52" width="68" height="48" fill="#FEF3C7"/><rect x="54" y="70" width="20" height="30" fill="#92400E"/><circle cx="64" cy="40" r="6" fill="#FACC15"/><rect x="38" y="62" width="12" height="12" fill="#38BDF8"/><rect x="78" y="62" width="12" height="12" fill="#38BDF8"/>'),

    # Toys
    "doll": wrap('<circle cx="64" cy="42" r="16" fill="#FDE68A"/><path d="M48 38c2-16 30-16 32 0" fill="#92400E"/><polygon points="64,58 40,98 88,98" fill="#EC4899"/><circle cx="58" cy="42" r="2.5" fill="#1E293B"/><circle cx="70" cy="42" r="2.5" fill="#1E293B"/>'),
    "kite": wrap('<polygon points="64,20 94,54 64,88 34,54" fill="#38BDF8"/><polygon points="64,20 94,54 64,54" fill="#FACC15"/><polygon points="64,54 34,54 64,88" fill="#EF4444"/><path d="M64 88c-8 10 8 16 0 26" stroke="#FFFFFF" stroke-width="3" fill="none"/>'),
    "robot": wrap('<rect x="40" y="32" width="48" height="34" rx="8" fill="#94A3B8"/><line x1="64" y1="20" x2="64" y2="32" stroke="#FACC15" stroke-width="4"/><circle cx="64" cy="18" r="5" fill="#EF4444"/><circle cx="52" cy="46" r="5" fill="#38BDF8"/><circle cx="76" cy="46" r="5" fill="#38BDF8"/><rect x="36" y="70" width="56" height="34" rx="6" fill="#64748B"/><rect x="50" y="78" width="28" height="14" rx="3" fill="#22C55E"/>'),
    "bike": wrap('<circle cx="38" cy="82" r="18" fill="none" stroke="#38BDF8" stroke-width="6"/><circle cx="90" cy="82" r="18" fill="none" stroke="#38BDF8" stroke-width="6"/><path d="M38 82l24-28h20l8 28M62 54l-8-14h-10M82 54l4-14h10" stroke="#FACC15" stroke-width="5" fill="none" stroke-linecap="round"/>'),

    # Clothes
    "shirt": wrap('<path d="M40 32l-18 14 10 14 10-8v46h44V52l10 8 10-14-18-14-14 8H54z" fill="#3B82F6"/><path d="M52 34c4 8 20 8 24 0" stroke="#DBEAFE" stroke-width="4" fill="none"/>'),
    "shoes": wrap('<path d="M26 74c8-16 24-12 34-4l16 6v14H26z" fill="#EF4444"/><rect x="24" y="88" width="54" height="7" rx="3" fill="#FFFFFF"/><path d="M54 56c8-14 22-10 30-2l16 6v14H54z" fill="#DC2626"/><rect x="52" y="72" width="50" height="7" rx="3" fill="#FFFFFF"/>'),
    "coat": wrap('<path d="M44 28l-20 22 10 10 12-10v50h36V50l12 10 10-10-20-22z" fill="#10B981"/><line x1="64" y1="36" x2="64" y2="100" stroke="#065F46" stroke-width="3"/><circle cx="64" cy="52" r="3" fill="#FDE047"/><circle cx="64" cy="70" r="3" fill="#FDE047"/><circle cx="64" cy="88" r="3" fill="#FDE047"/>'),
    "dress": wrap('<path d="M48 28h32l-6 26 20 46H34l20-46z" fill="#EC4899"/><path d="M50 54h28" stroke="#FCE7F3" stroke-width="4"/>'),

    # House & Rooms
    "house": wrap('<polygon points="64,20 22,58 106,58" fill="#EF4444"/><rect x="32" y="58" width="64" height="44" fill="#FEF3C7"/><rect x="54" y="72" width="20" height="30" fill="#92400E"/><rect x="38" y="66" width="12" height="12" fill="#38BDF8"/>'),
    "door": wrap('<rect x="38" y="24" width="52" height="80" rx="4" fill="#B45309"/><rect x="46" y="34" width="36" height="28" fill="#92400E"/><rect x="46" y="68" width="36" height="26" fill="#92400E"/><circle cx="80" cy="64" r="4" fill="#FACC15"/>'),
    "bed": wrap('<rect x="22" y="62" width="84" height="24" rx="4" fill="#3B82F6"/><rect x="22" y="42" width="10" height="56" rx="3" fill="#92400E"/><rect x="96" y="54" width="10" height="44" rx="3" fill="#92400E"/><rect x="34" y="52" width="22" height="12" rx="4" fill="#FFFFFF"/>'),
    "table": wrap('<rect x="22" y="48" width="84" height="12" rx="4" fill="#D97706"/><rect x="32" y="60" width="10" height="40" fill="#92400E"/><rect x="86" y="60" width="10" height="40" fill="#92400E"/>'),
    "window": wrap('<rect x="28" y="28" width="72" height="72" rx="6" fill="#38BDF8" stroke="#D97706" stroke-width="8"/><line x1="64" y1="28" x2="64" y2="100" stroke="#D97706" stroke-width="6"/><line x1="28" y1="64" x2="100" y2="64" stroke="#D97706" stroke-width="6"/>'),

    # Daily Activities
    "eat": wrap('<circle cx="64" cy="68" r="28" fill="#FFFFFF"/><circle cx="64" cy="68" r="18" fill="#FDE68A"/><rect x="24" y="34" width="6" height="60" rx="3" fill="#94A3B8"/><rect x="98" y="34" width="6" height="60" rx="3" fill="#94A3B8"/>'),
    "drink": wrap('<polygon points="42,38 86,38 78,98 50,98" fill="#BAE6FD"/><polygon points="46,56 82,56 78,96 50,96" fill="#38BDF8"/><path d="M74 38l8-14h10" stroke="#F472B6" stroke-width="4" fill="none"/>'),
    "read": wrap('<path d="M22 40c16-8 32-4 42 4 10-8 26-12 42-4v52c-16-8-32-4-42 4-10-8-26-12-42-4z" fill="#FEF3C7" stroke="#3B82F6" stroke-width="5"/><line x1="64" y1="44" x2="64" y2="96" stroke="#3B82F6" stroke-width="4"/>'),
    "play": wrap('<circle cx="44" cy="76" r="18" fill="#EF4444"/><rect x="68" y="42" width="34" height="34" rx="6" fill="#22C55E"/><polygon points="64,22 76,42 52,42" fill="#FACC15"/>'),
    "sleep": wrap('<path d="M72 28a30 30 0 1 0 28 42A24 24 0 1 1 72 28z" fill="#FDE047"/><text x="74" y="48" font-family="Arial,sans-serif" font-weight="bold" font-size="22" fill="#93C5FD">Z</text><text x="90" y="36" font-family="Arial,sans-serif" font-weight="bold" font-size="16" fill="#93C5FD">z</text>'),
    "run": wrap('<circle cx="72" cy="34" r="10" fill="#FDE68A"/><path d="M68 46l-14 20 18 10 8 22M54 66l-18 14M68 48l18 8" stroke="#38BDF8" stroke-width="8" stroke-linecap="round" stroke-linejoin="round" fill="none"/>'),

    # Weather
    "sun": wrap('<circle cx="64" cy="64" r="24" fill="#FACC15"/><g stroke="#FACC15" stroke-width="6" stroke-linecap="round"><line x1="64" y1="18" x2="64" y2="30"/><line x1="64" y1="98" x2="64" y2="110"/><line x1="18" y1="64" x2="30" y2="64"/><line x1="98" y1="64" x2="110" y2="64"/><line x1="32" y1="32" x2="40" y2="40"/><line x1="88" y1="88" x2="96" y2="96"/><line x1="96" y1="32" x2="88" y2="40"/><line x1="40" y1="88" x2="32" y2="96"/></g>'),
    "rain": wrap('<path d="M38 66h54a14 14 0 0 0 0-28 20 20 0 0 0-38-4 16 16 0 0 0-16 32z" fill="#CBD5E1"/><g stroke="#38BDF8" stroke-width="5" stroke-linecap="round"><line x1="44" y1="78" x2="38" y2="96"/><line x1="64" y1="78" x2="58" y2="96"/><line x1="84" y1="78" x2="78" y2="96"/></g>'),
    "wind": wrap('<path d="M24 52h56a10 10 0 1 0-10-10" stroke="#7DD3FC" stroke-width="7" fill="none" stroke-linecap="round"/><path d="M20 70h70a10 10 0 1 1-10 10" stroke="#38BDF8" stroke-width="7" fill="none" stroke-linecap="round"/><path d="M32 88h36" stroke="#BAE6FD" stroke-width="6" stroke-linecap="round"/>'),
    "cloud": wrap('<path d="M34 82h60a16 16 0 0 0 2-32 24 24 0 0 0-46-6 18 18 0 0 0-16 38z" fill="#F8FAFC"/>'),

    # Feelings
    "happy": wrap('<circle cx="64" cy="64" r="34" fill="#FACC15"/><circle cx="52" cy="56" r="4" fill="#1E293B"/><circle cx="76" cy="56" r="4" fill="#1E293B"/><path d="M48 72c6 12 26 12 32 0" stroke="#1E293B" stroke-width="5" fill="none" stroke-linecap="round"/>'),
    "sad": wrap('<circle cx="64" cy="64" r="34" fill="#93C5FD"/><circle cx="52" cy="56" r="4" fill="#1E293B"/><circle cx="76" cy="56" r="4" fill="#1E293B"/><path d="M48 80c6-10 26-10 32 0" stroke="#1E293B" stroke-width="5" fill="none" stroke-linecap="round"/>'),
    "tired": wrap('<circle cx="64" cy="64" r="34" fill="#C4B5FD"/><line x1="44" y1="58" x2="56" y2="58" stroke="#1E293B" stroke-width="4" stroke-linecap="round"/><line x1="72" y1="58" x2="84" y2="58" stroke="#1E293B" stroke-width="4" stroke-linecap="round"/><ellipse cx="64" cy="78" rx="8" ry="6" fill="#1E293B"/>'),
    "hungry": wrap('<circle cx="64" cy="64" r="34" fill="#FDBA74"/><circle cx="52" cy="54" r="4" fill="#1E293B"/><circle cx="76" cy="54" r="4" fill="#1E293B"/><path d="M52 74c6 6 18 6 24 0" stroke="#1E293B" stroke-width="4" fill="none"/><path d="M84 68c4 4 4 10 0 12" stroke="#EF4444" stroke-width="4" fill="none" stroke-linecap="round"/>'),

    # Places
    "park": wrap('<rect x="20" y="84" width="88" height="20" rx="6" fill="#22C55E"/><rect x="44" y="64" width="10" height="26" fill="#78350F"/><circle cx="49" cy="50" r="18" fill="#16A34A"/><rect x="70" y="72" width="28" height="8" rx="3" fill="#D97706"/><line x1="74" y1="80" x2="74" y2="88" stroke="#78350F" stroke-width="4"/><line x1="94" y1="80" x2="94" y2="88" stroke="#78350F" stroke-width="4"/>'),
    "home": wrap('<polygon points="64,22 22,56 106,56" fill="#F97316"/><rect x="34" y="56" width="60" height="46" fill="#FDE68A"/><path d="M64 70c-6-8-16-2-12 8l12 12 12-12c4-10-6-16-12-8z" fill="#EF4444"/>'),
    "shop": wrap('<rect x="28" y="48" width="72" height="54" fill="#FEF3C7"/><path d="M22 48l8-20h68l8 20z" fill="#EF4444"/><rect x="42" y="64" width="24" height="24" fill="#38BDF8"/><rect x="72" y="64" width="18" height="38" fill="#D97706"/>'),
    "beach": wrap('<rect x="20" y="64" width="88" height="20" fill="#38BDF8"/><rect x="20" y="82" width="88" height="22" rx="6" fill="#FDE047"/><circle cx="88" cy="36" r="14" fill="#FACC15"/><path d="M36 82c0-18 16-26 24-26" stroke="#EF4444" stroke-width="6" fill="none"/>'),

    # A1 Sample Pack (32 words)
    "friend": wrap('<circle cx="46" cy="48" r="14" fill="#FDE68A"/><circle cx="82" cy="48" r="14" fill="#FDBA74"/><path d="M28 96c0-16 36-16 36 0" fill="#3B82F6"/><path d="M64 96c0-16 36-16 36 0" fill="#EC4899"/>'),
    "kind": wrap('<path d="M64 96S26 74 26 48c0-12 10-22 22-22 7 0 12 4 16 10 4-6 9-10 16-10 12 0 22 10 22 22 0 26-38 48-38 48z" fill="#F43F5E"/>'),
    "funny": wrap('<circle cx="64" cy="64" r="34" fill="#FACC15"/><path d="M44 54l10-6 10 6M70 54l10-6 10 6" stroke="#1E293B" stroke-width="4" fill="none" stroke-linecap="round"/><path d="M44 70c8 16 32 16 40 0z" fill="#EF4444"/>'),
    "share": wrap('<circle cx="42" cy="70" r="16" fill="#38BDF8"/><circle cx="86" cy="70" r="16" fill="#22C55E"/><path d="M48 44l16-14 16 14M64 30v26" stroke="#FACC15" stroke-width="6" fill="none" stroke-linecap="round"/>'),
    "library": wrap('<rect x="26" y="28" width="76" height="72" rx="6" fill="#78350F"/><rect x="34" y="36" width="14" height="24" fill="#EF4444"/><rect x="50" y="36" width="14" height="24" fill="#3B82F6"/><rect x="66" y="36" width="14" height="24" fill="#22C55E"/><rect x="34" y="68" width="14" height="24" fill="#FACC15"/><rect x="50" y="68" width="14" height="24" fill="#A855F7"/><rect x="66" y="68" width="14" height="24" fill="#38BDF8"/>'),
    "homework": wrap('<rect x="32" y="24" width="64" height="80" rx="6" fill="#FFFFFF"/><line x1="44" y1="44" x2="84" y2="44" stroke="#94A3B8" stroke-width="5"/><line x1="44" y1="60" x2="84" y2="60" stroke="#94A3B8" stroke-width="5"/><line x1="44" y1="76" x2="72" y2="76" stroke="#94A3B8" stroke-width="5"/><polygon points="74,88 94,68 100,74 80,94" fill="#FACC15"/>'),
    "science": wrap('<path d="M54 26h20v20l18 42a8 8 0 0 1-7 12H43a8 8 0 0 1-7-12l18-42z" fill="#38BDF8"/><path d="M40 74h48l4 14a6 6 0 0 1-6 8H42a6 6 0 0 1-6-8z" fill="#22C55E"/><circle cx="60" cy="64" r="4" fill="#FFFFFF"/>'),
    "music": wrap('<path d="M50 84V36l40-10v48" stroke="#F472B6" stroke-width="8" fill="none" stroke-linecap="round"/><circle cx="42" cy="86" r="12" fill="#EC4899"/><circle cx="82" cy="76" r="12" fill="#EC4899"/>'),
    "breakfast": wrap('<circle cx="64" cy="68" r="32" fill="#FFFFFF"/><circle cx="56" cy="66" r="12" fill="#FEF3C7"/><circle cx="56" cy="66" r="6" fill="#FACC15"/><rect x="74" y="54" width="12" height="24" rx="4" fill="#F97316"/>'),
    "brush": wrap('<rect x="24" y="64" width="76" height="12" rx="6" fill="#38BDF8"/><rect x="76" y="48" width="24" height="16" rx="3" fill="#FFFFFF"/>'),
    "study": wrap('<rect x="26" y="52" width="76" height="46" rx="6" fill="#1E40AF"/><rect x="34" y="60" width="60" height="30" fill="#BAE6FD"/><circle cx="64" cy="36" r="12" fill="#FDE047"/>'),
    "clean": wrap('<rect x="58" y="24" width="10" height="48" rx="4" fill="#D97706"/><polygon points="44,72 82,72 90,100 36,100" fill="#FACC15"/>'),
    "draw": wrap('<rect x="28" y="28" width="56" height="72" rx="6" fill="#FFFFFF"/><polygon points="56,92 64,74 96,42 104,50 72,82" fill="#EC4899"/><path d="M40 58c8-12 20-12 28 0" stroke="#38BDF8" stroke-width="5" fill="none"/>'),
    "swim": wrap('<path d="M20 74c14-10 28 10 44 0s30 10 44 0" stroke="#38BDF8" stroke-width="8" fill="none" stroke-linecap="round"/><path d="M20 92c14-10 28 10 44 0s30 10 44 0" stroke="#0284C7" stroke-width="8" fill="none" stroke-linecap="round"/><circle cx="64" cy="48" r="14" fill="#FACC15"/>'),
    "sing": wrap('<circle cx="50" cy="66" r="20" fill="#FDE68A"/><circle cx="56" cy="70" r="6" fill="#EF4444"/><path d="M80 48V28l18-6v20" stroke="#38BDF8" stroke-width="5" fill="none"/><circle cx="76" cy="50" r="6" fill="#38BDF8"/>'),
    "dance": wrap('<circle cx="64" cy="32" r="10" fill="#FDE68A"/><path d="M64 44v26l-18 22M64 70l18 22M40 52l24-6 24-10" stroke="#EC4899" stroke-width="7" fill="none" stroke-linecap="round"/>'),
    "chicken": wrap('<path d="M36 68c0-20 20-32 42-28l16-12c6 4 6 12 0 18L82 58c6 18-8 36-26 36-14 0-20-12-20-26z" fill="#D97706"/><circle cx="96" cy="32" r="6" fill="#FFFFFF"/>'),
    "noodles": wrap('<path d="M28 64h72c0 24-16 36-36 36S28 88 28 64z" fill="#F97316"/><path d="M36 58c8-14 48-14 56 0" stroke="#FDE047" stroke-width="8" fill="none"/><line x1="42" y1="30" x2="58" y2="58" stroke="#78350F" stroke-width="4"/><line x1="56" y1="28" x2="68" y2="58" stroke="#78350F" stroke-width="4"/>'),
    "soup": wrap('<path d="M28 60h72c0 24-16 36-36 36S28 84 28 60z" fill="#38BDF8"/><ellipse cx="64" cy="60" rx="34" ry="8" fill="#F59E0B"/><path d="M48 36c-4 8 4 12 0 18M64 32c-4 8 4 12 0 18M80 36c-4 8 4 12 0 18" stroke="#E2E8F0" stroke-width="4" fill="none" stroke-linecap="round"/>'),
    "salad": wrap('<path d="M28 66h72c0 20-16 32-36 32S28 86 28 66z" fill="#FFFFFF"/><circle cx="48" cy="58" r="14" fill="#22C55E"/><circle cx="72" cy="56" r="14" fill="#4ADE80"/><circle cx="62" cy="52" r="8" fill="#EF4444"/><circle cx="80" cy="62" r="7" fill="#FACC15"/>'),
    "market": wrap('<rect x="26" y="52" width="76" height="48" fill="#FEF3C7"/><path d="M20 52l8-20h72l8 20z" fill="#22C55E"/><circle cx="48" cy="76" r="10" fill="#EF4444"/><circle cx="76" cy="76" r="10" fill="#FACC15"/>'),
    "hospital": wrap('<rect x="30" y="28" width="68" height="72" rx="6" fill="#FFFFFF"/><rect x="58" y="42" width="12" height="36" fill="#EF4444"/><rect x="46" y="54" width="36" height="12" fill="#EF4444"/>'),
    "museum": wrap('<polygon points="64,22 22,46 106,46" fill="#CBD5E1"/><rect x="26" y="46" width="76" height="8" fill="#94A3B8"/><rect x="34" y="54" width="10" height="38" fill="#E2E8F0"/><rect x="59" y="54" width="10" height="38" fill="#E2E8F0"/><rect x="84" y="54" width="10" height="38" fill="#E2E8F0"/><rect x="24" y="92" width="80" height="10" fill="#94A3B8"/>'),
    "street": wrap('<rect x="36" y="24" width="56" height="80" fill="#475569"/><line x1="64" y1="30" x2="64" y2="44" stroke="#FACC15" stroke-width="6"/><line x1="64" y1="56" x2="64" y2="70" stroke="#FACC15" stroke-width="6"/><line x1="64" y1="82" x2="64" y2="96" stroke="#FACC15" stroke-width="6"/>'),
    "price": wrap('<polygon points="34,32 70,32 98,64 64,98 34,68" fill="#FACC15"/><circle cx="48" cy="48" r="6" fill="#172B4D"/><text x="64" y="76" text-anchor="middle" font-family="Arial,sans-serif" font-weight="bold" font-size="24" fill="#9A3412">$</text>'),
    "money": wrap('<rect x="24" y="40" width="80" height="48" rx="6" fill="#22C55E"/><circle cx="64" cy="64" r="14" fill="#DCFCE7"/><text x="64" y="71" text-anchor="middle" font-family="Arial,sans-serif" font-weight="bold" font-size="22" fill="#166534">$</text>'),
    "buy": wrap('<path d="M24 38h16l10 38h44l8-28H46" stroke="#38BDF8" stroke-width="6" fill="none" stroke-linecap="round" stroke-linejoin="round"/><circle cx="54" cy="90" r="7" fill="#FACC15"/><circle cx="88" cy="90" r="7" fill="#FACC15"/>'),
    "cheap": wrap('<circle cx="64" cy="64" r="34" fill="#10B981"/><text x="64" y="72" text-anchor="middle" font-family="Arial,sans-serif" font-weight="bold" font-size="28" fill="#FFFFFF">%</text>'),
    "cousin": wrap('<circle cx="46" cy="52" r="14" fill="#FDE68A"/><circle cx="82" cy="52" r="14" fill="#FDE68A"/><path d="M28 96c0-14 36-14 36 0" fill="#22C55E"/><path d="M64 96c0-14 36-14 36 0" fill="#F59E0B"/>'),
    "uncle": wrap('<circle cx="64" cy="50" r="20" fill="#FDE68A"/><path d="M44 46c4-18 36-18 40 0" fill="#78350F"/><rect x="46" y="74" width="36" height="24" rx="8" fill="#3B82F6"/>'),
    "aunt": wrap('<circle cx="64" cy="50" r="20" fill="#FDE68A"/><path d="M42 54c0-24 44-24 44 0" fill="#92400E"/><rect x="46" y="74" width="36" height="24" rx="8" fill="#A855F7"/>'),
    "parents": wrap('<circle cx="46" cy="48" r="15" fill="#FDE68A"/><circle cx="82" cy="48" r="15" fill="#FDBA74"/><path d="M28 96c0-16 36-16 36 0" fill="#3B82F6"/><path d="M64 96c0-16 36-16 36 0" fill="#EC4899"/><path d="M64 78c-4-5-10-1-7 5l7 7 7-7c3-6-3-10-7-5z" fill="#EF4444"/>'),
}


def main() -> None:
    for name, content in SVGS.items():
        (IMG_DIR / f"{name}.svg").write_text(content, encoding="utf-8")
    print(f"Generated {len(SVGS)} SVGs. Total SVGs in dir: {len(list(IMG_DIR.glob('*.svg')))}")


if __name__ == "__main__":
    main()
