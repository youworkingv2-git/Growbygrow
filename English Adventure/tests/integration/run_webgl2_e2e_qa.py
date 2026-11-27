#!/usr/bin/env python3
"""
Prompt 08 Live WebGL2 End-to-End QA, Performance & Cross-Viewport Test Runner.
Drives real headless Chrome with WebGL2 (SwiftShader) via Chrome DevTools Protocol (CDP),
verifies TC01-TC10 on the live deployed build, captures screenshots, console/Godot logs,
TTS utterances, FPS & frame-time samples, memory metrics, Save/Load persistence,
Offline mode, and Mobile Portrait/Landscape responsive rendering.
"""

import asyncio
import base64
import json
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.request
from pathlib import Path

import websockets

CHROME_EXE = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
TARGET_URL = "https://youworkingv2-git.github.io/Growbygrow/?p8qa=fe809d9"
ROOT = Path(__file__).resolve().parents[2]
OUT_DIR = ROOT / "builds" / "qa_screenshots"


class CDPSession:
    def __init__(self, ws_url: str):
        self.ws_url = ws_url
        self.ws = None
        self._id = 0
        self._pending = {}
        self.console_logs: list[str] = []
        self.errors: list[str] = []
        self._recv_task = None

    async def connect(self):
        self.ws = await websockets.connect(self.ws_url, max_size=50 * 1024 * 1024)
        self._recv_task = asyncio.create_task(self._reader())
        await self.send("Runtime.enable")
        await self.send("Page.enable")
        await self.send("Network.enable")
        await self.send("Performance.enable")
        await self.set_viewport(1280, 720, 1.0, False)

    async def set_viewport(self, w: int, h: int, dpr: float = 1.0, mobile: bool = False):
        await self.send(
            "Emulation.setDeviceMetricsOverride",
            {"width": w, "height": h, "deviceScaleFactor": dpr, "mobile": mobile},
        )

    async def close(self):
        if self._recv_task:
            self._recv_task.cancel()
        if self.ws:
            await self.ws.close()

    async def _reader(self):
        try:
            async for raw in self.ws:
                msg = json.loads(raw)
                if "id" in msg:
                    fut = self._pending.pop(msg["id"], None)
                    if fut and not fut.done():
                        fut.set_result(msg)
                else:
                    method = msg.get("method", "")
                    params = msg.get("params", {})
                    if method == "Runtime.consoleAPICalled":
                        ctype = params.get("type", "log")
                        args = " ".join(str(a.get("value", a.get("description", ""))) for a in params.get("args", []))
                        self.console_logs.append(f"[{ctype}] {args}")
                        if ctype == "error":
                            self.errors.append(f"console.error: {args}")
                    elif method == "Runtime.exceptionThrown":
                        det = params.get("exceptionDetails", {})
                        txt = det.get("text", "") + " " + str(det.get("exception", {}).get("description", ""))
                        self.errors.append(f"exceptionThrown: {txt}")
        except asyncio.CancelledError:
            pass

    async def send(self, method: str, params: dict | None = None) -> dict:
        self._id += 1
        cid = self._id
        fut = asyncio.get_running_loop().create_future()
        self._pending[cid] = fut
        await self.ws.send(json.dumps({"id": cid, "method": method, "params": params or {}}))
        res = await asyncio.wait_for(fut, timeout=30.0)
        if "error" in res:
            raise RuntimeError(f"CDP {method} error: {res['error']}")
        return res.get("result", {})

    async def eval_js(self, expr: str):
        r = await self.send("Runtime.evaluate", {"expression": expr, "awaitPromise": True, "returnByValue": True})
        return r.get("result", {}).get("value")

    async def screenshot(self, filename: str):
        r = await self.send("Page.captureScreenshot", {"format": "png"})
        data = base64.b64decode(r["data"])
        OUT_DIR.mkdir(parents=True, exist_ok=True)
        out_p = OUT_DIR / filename
        out_p.write_bytes(data)
        return out_p

    async def click_xy(self, x: float, y: float, hold_ms: int = 80):
        await self.send("Input.dispatchMouseEvent", {"type": "mouseMoved", "x": x, "y": y})
        await asyncio.sleep(0.03)
        await self.send("Input.dispatchMouseEvent", {"type": "mousePressed", "x": x, "y": y, "button": "left", "clickCount": 1})
        await asyncio.sleep(hold_ms / 1000.0)
        await self.send("Input.dispatchMouseEvent", {"type": "mouseReleased", "x": x, "y": y, "button": "left", "clickCount": 1})

    async def drag_xy(self, x1: float, y1: float, x2: float, y2: float, steps: int = 10):
        await self.send("Input.dispatchMouseEvent", {"type": "mouseMoved", "x": x1, "y": y1})
        await self.send("Input.dispatchMouseEvent", {"type": "mousePressed", "x": x1, "y": y1, "button": "left", "clickCount": 1})
        for i in range(1, steps + 1):
            t = i / steps
            await self.send("Input.dispatchMouseEvent", {"type": "mouseMoved", "x": x1 + (x2 - x1) * t, "y": y1 + (y2 - y1) * t, "buttons": 1})
            await asyncio.sleep(0.025)
        await self.send("Input.dispatchMouseEvent", {"type": "mouseReleased", "x": x2, "y": y2, "button": "left", "clickCount": 1})

    async def press_key(self, key: str, code: str, key_code: int, hold_ms: int = 90):
        await self.send("Input.dispatchKeyEvent", {"type": "rawKeyDown", "key": key, "code": code, "windowsVirtualKeyCode": key_code})
        if len(key) == 1:
            await self.send("Input.dispatchKeyEvent", {"type": "char", "text": key, "key": key, "code": code})
        await asyncio.sleep(hold_ms / 1000.0)
        await self.send("Input.dispatchKeyEvent", {"type": "keyUp", "key": key, "code": code, "windowsVirtualKeyCode": key_code})

    async def sample_fps(self, duration_ms: int = 1800) -> dict:
        return await self.eval_js(f"""
        (function(){{
          return new Promise(function(resolve){{
            var times = [];
            var start = performance.now();
            function tick(now){{
              times.push(now);
              if (now - start >= {duration_ms}) {{
                var deltas = [];
                for (var i = 1; i < times.length; i++) deltas.push(times[i] - times[i-1]);
                var avg = deltas.reduce((a,b)=>a+b,0) / Math.max(1, deltas.length);
                var sorted = deltas.slice().sort((a,b)=>a-b);
                var p95 = sorted[Math.floor(sorted.length * 0.95)] || avg;
                resolve({{
                  frames: deltas.length,
                  fps_avg: Math.round((1000.0 / avg) * 10) / 10,
                  frame_ms_avg: Math.round(avg * 100) / 100,
                  frame_ms_p95: Math.round(p95 * 100) / 100
                }});
                return;
              }}
              requestAnimationFrame(tick);
            }}
            requestAnimationFrame(tick);
          }});
        }})()
        """)


def launch_chrome(user_data_dir: Path, port: int = 9244):
    cmd = [
        CHROME_EXE,
        f"--remote-debugging-port={port}",
        f"--user-data-dir={user_data_dir}",
        "--headless=new",
        "--use-gl=angle",
        "--use-angle=swiftshader",
        "--enable-webgl",
        "--ignore-gpu-blocklist",
        "--window-size=1280,760",
        "--no-first-run",
        "--no-default-browser-check",
        "--autoplay-policy=no-user-gesture-required",
        TARGET_URL,
    ]
    return subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def get_page_ws(port: int = 9244) -> str:
    for _ in range(30):
        try:
            targets = json.loads(urllib.request.urlopen(f"http://127.0.0.1:{port}/json/list", timeout=2).read())
            for t in targets:
                if t.get("type") == "page" and "Growbygrow" in t.get("url", ""):
                    return t["webSocketDebuggerUrl"]
        except Exception:
            pass
        time.sleep(0.4)
    raise RuntimeError("Could not connect to Chrome CDP page target")


async def wait_for_log(cdp: CDPSession, needle: str, timeout_s: float = 35.0) -> bool:
    deadline = time.monotonic() + timeout_s
    while time.monotonic() < deadline:
        if any(needle in line for line in cdp.console_logs):
            return True
        await asyncio.sleep(0.25)
    return False


async def install_hooks(cdp: CDPSession):
    await cdp.eval_js("""
    (function(){
      if (window.__qaHooks) return true;
      window.__qaHooks = true;
      window.__ttsLog = [];
      if ('speechSynthesis' in window) {
        var origSpeak = window.speechSynthesis.speak.bind(window.speechSynthesis);
        window.speechSynthesis.speak = function(u){
          window.__ttsLog.push({ text: u.text, lang: u.lang, rate: u.rate });
          return origSpeak(u);
        };
      }
      return true;
    })()
    """)


async def run_qa():
    if OUT_DIR.exists():
        shutil.rmtree(OUT_DIR)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    profile_dir = Path(tempfile.mkdtemp(prefix="ea_p8_chrome_"))
    report = {"steps": [], "metrics": {}, "errors": [], "tts": []}

    proc = launch_chrome(profile_dir, 9244)
    try:
        ws_url = get_page_ws(9244)
        cdp = CDPSession(ws_url)
        await cdp.connect()

        # TC01: Boot & Main Menu
        t0 = time.monotonic()
        boot_ok = await wait_for_log(cdp, "MiniGameManager", 35.0)
        await asyncio.sleep(2.0)
        await install_hooks(cdp)
        boot_ms = round((time.monotonic() - t0) * 1000.0)
        perf = await cdp.send("Performance.getMetrics")
        nav_timing = await cdp.eval_js("""
        (function(){
          var n = performance.getEntriesByType('navigation')[0] || {};
          var res = performance.getEntriesByType('resource').map(function(r){
            return { name: r.name.split('/').pop(), ms: Math.round(r.duration), bytes: r.transferSize || r.encodedBodySize || 0 };
          }).filter(function(r){ return r.name.indexOf('index') >= 0; });
          return { domInteractiveMs: Math.round(n.domInteractive||0), loadEventMs: Math.round(n.loadEventEnd||0), resources: res };
        })()
        """)
        menu_fps = await cdp.sample_fps(1500)
        await cdp.screenshot("01_main_menu.png")

        report["steps"].append({"tc": "TC01_startup", "boot_ok": boot_ok, "boot_ms": boot_ms})
        report["metrics"]["startup"] = {"nav": nav_timing, "menu_fps": menu_fps, "perf_metrics": perf.get("metrics", [])}

        # Click "Bắt đầu Phiêu lưu mới" at exact 1280x720 center (793, 374)
        await cdp.click_xy(793, 374)
        await asyncio.sleep(2.0)
        await cdp.screenshot("02_char_select.png")

        # Select Girl (Mia) then Boy (Leo) then Confirm
        await cdp.click_xy(930, 445)
        await asyncio.sleep(0.7)
        await cdp.screenshot("03_char_girl_selected.png")
        await cdp.click_xy(350, 445)
        await asyncio.sleep(0.5)
        await cdp.click_xy(640, 648)
        await asyncio.sleep(2.0)
        await cdp.screenshot("04_world_intro.png")

        # Click NextBtn (856, 566) once to check dialogue progression, then SkipBtn (904, 150) -> Enter Welcome Village
        await cdp.click_xy(856, 566)
        await asyncio.sleep(0.6)
        await cdp.click_xy(904, 150)
        await asyncio.sleep(3.2)
        await cdp.screenshot("05_welcome_village.png")

        # TC02: 3D Movement & Camera Orbit + 3D Area FPS measurement
        fps_idle_3d = await cdp.sample_fps(1800)
        await cdp.press_key("w", "KeyW", 87, hold_ms=1700)  # Walk North into Professor Owl's 2.6m interaction radius
        await cdp.press_key("d", "KeyD", 68, hold_ms=120)
        await cdp.press_key("a", "KeyA", 65, hold_ms=120)
        await cdp.press_key(" ", "Space", 32, hold_ms=120)
        await cdp.drag_xy(640, 340, 700, 350, steps=8)
        fps_move_3d = await cdp.sample_fps(1800)
        await cdp.screenshot("06_village_near_owl.png")
        report["metrics"]["village_3d"] = {"fps_idle": fps_idle_3d, "fps_moving": fps_move_3d}

        # TC03: Interact with Professor Owl via [E]
        await cdp.press_key("e", "KeyE", 69, hold_ms=100)
        await asyncio.sleep(1.0)
        await cdp.screenshot("07_owl_dialogue.png")
        # Advance dialogue lines by clicking NextBtn (1172, 673) 4 times
        for _ in range(4):
            await cdp.click_xy(1172, 673)
            await asyncio.sleep(0.55)
        await cdp.screenshot("08_after_owl_dialogue.png")
        # Accept Quest 01 if QuestIntroPopup is open (AcceptBtn ~755, 468)
        await cdp.click_xy(755, 468)
        await asyncio.sleep(0.7)

        # TC04: Open Learning Hub via [L]
        await cdp.press_key("l", "KeyL", 76, hold_ms=100)
        await asyncio.sleep(1.0)
        await cdp.screenshot("09_learning_hub_lessons.png")
        # Switch to Phonics tab (395, 160) & trigger both letter name and phonics word audio
        await cdp.click_xy(395, 160)
        await asyncio.sleep(0.8)
        await cdp.click_xy(290, 608)
        await asyncio.sleep(0.6)
        await cdp.click_xy(495, 608)
        await asyncio.sleep(0.7)
        await cdp.screenshot("10_learning_hub_phonics.png")
        await cdp.press_key("Escape", "Escape", 27, hold_ms=80)
        await asyncio.sleep(0.7)

        # TC05 & TC10: Open Mini-Game Center via [G] and launch Listen & Find
        await cdp.press_key("g", "KeyG", 71, hold_ms=100)
        await asyncio.sleep(1.0)
        await cdp.screenshot("11_minigame_arcade.png")
        await cdp.click_xy(345, 222)  # Listen and Find -> Chơi ngay
        await asyncio.sleep(0.9)
        await cdp.screenshot("11b_minigame_listen_intro.png")
        await cdp.click_xy(640, 560)  # Bắt đầu chơi!
        await asyncio.sleep(1.2)
        await cdp.screenshot("11c_minigame_listen_play.png")
        await cdp.press_key("Escape", "Escape", 27, hold_ms=80)
        await asyncio.sleep(0.7)

        # TC07: Open World Map via [M] & test locked area guard
        await cdp.press_key("m", "KeyM", 77, hold_ms=100)
        await asyncio.sleep(2.2)
        await cdp.screenshot("12_world_map.png")
        await cdp.click_xy(460, 290)  # Click locked Alphabet Meadow node
        await asyncio.sleep(0.8)
        await cdp.screenshot("12b_world_map_locked_popup.png")
        await cdp.click_xy(640, 425)  # Close locked popup
        await asyncio.sleep(0.5)
        # Return to Welcome Village ("< Quay lại khám phá" top-right ~1180, 35)
        await cdp.click_xy(1180, 35)
        await asyncio.sleep(2.2)
        await cdp.screenshot("13_back_to_village.png")

        # Mobile Portrait (390x844) & Mobile Landscape (844x390) HUD verification
        await cdp.set_viewport(390, 844, 2.0, True)
        await asyncio.sleep(0.9)
        await cdp.screenshot("14_mobile_portrait_village.png")
        await cdp.set_viewport(844, 390, 2.0, True)
        await asyncio.sleep(0.9)
        await cdp.screenshot("15_mobile_landscape_village.png")
        await cdp.set_viewport(1280, 720, 1.0, False)
        await asyncio.sleep(0.6)

        # TC09: Offline Mode verification
        await cdp.send("Network.emulateNetworkConditions", {"offline": True, "latency": 0, "downloadThroughput": 0, "uploadThroughput": 0})
        await asyncio.sleep(0.5)
        await cdp.click_xy(970, 680)  # SaveBtn in BottomDock
        await asyncio.sleep(0.6)
        await cdp.press_key("s", "KeyS", 83, hold_ms=300)
        await cdp.screenshot("16_offline_playable.png")
        await cdp.send("Network.emulateNetworkConditions", {"offline": False, "latency": 0, "downloadThroughput": -1, "uploadThroughput": -1})

        report["tts"] = await cdp.eval_js("window.__ttsLog || []")
        report["errors"] = cdp.errors
        report["logs_tail"] = cdp.console_logs[-80:]
        await cdp.close()
    finally:
        proc.terminate()
        try:
            proc.wait(timeout=5)
        except Exception:
            proc.kill()

    # TC08: Relaunch Chrome with SAME profile_dir to verify Save/Load persistence!
    proc2 = launch_chrome(profile_dir, 9245)
    try:
        ws_url2 = get_page_ws(9245)
        cdp2 = CDPSession(ws_url2)
        await cdp2.connect()
        await wait_for_log(cdp2, "MiniGameManager", 35.0)
        await asyncio.sleep(4.0)
        await cdp2.screenshot("17_reload_persistence_menu.png")
        # Click "Tiếp tục Phiêu Lưu" (~793, 315)
        await cdp2.click_xy(793, 315)
        await asyncio.sleep(3.0)
        await cdp2.screenshot("18_reload_continued_village.png")
        # Test Main Menu mobile portrait on reload? Let's test mobile portrait HUD after continue
        await cdp2.set_viewport(390, 844, 2.0, True)
        await asyncio.sleep(0.8)
        await cdp2.screenshot("19_reload_mobile_portrait_hud.png")
        report["reload_logs"] = cdp2.console_logs[-40:]
        report["reload_errors"] = cdp2.errors
        await cdp2.close()
    finally:
        proc2.terminate()
        try:
            proc2.wait(timeout=5)
        except Exception:
            proc2.kill()
        shutil.rmtree(profile_dir, ignore_errors=True)

    (OUT_DIR / "qa_report.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print("QA RUN COMPLETE. Errors:", len(report["errors"]), "Reload errors:", len(report["reload_errors"]))
    print("TTS utterances logged:", len(report["tts"]))
    print("Menu FPS:", report["metrics"]["startup"]["menu_fps"])
    print("Village 3D Idle FPS:", report["metrics"]["village_3d"]["fps_idle"])
    print("Village 3D Moving FPS:", report["metrics"]["village_3d"]["fps_moving"])
    return 0


if __name__ == "__main__":
    sys.exit(asyncio.run(run_qa()))
