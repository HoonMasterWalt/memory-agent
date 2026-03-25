#!/usr/bin/env python3
"""Migrate local memory files to the %memory agent on ship."""

import os
import json
import subprocess
import time

SCRIPT = "/home/ubuntu/.openclaw/workspace/scripts/urbit-mcp.sh"
WORKSPACE = "/home/ubuntu/.openclaw/workspace"

def to_hoon_tape(text):
    """Convert text to a Hoon tape string with escaped chars."""
    result = []
    for ch in text:
        if ch == '\n':
            result.append('\\0a')
        elif ch == '"':
            result.append('\\"')
        elif ch == '\\':
            result.append('\\\\')
        elif ch == '{':
            result.append('\\7b')
        elif ch == '}':
            result.append('\\7d')
        elif ch == '\t':
            result.append('\\09')
        elif ch == '\r':
            continue  # skip carriage returns
        elif ord(ch) < 32 or ord(ch) > 126:
            result.append(f'\\{ord(ch):02x}')
        else:
            result.append(ch)
    return ''.join(result)

def poke_memory(tag, key, content):
    """Poke the memory agent with a %put action using (crip tape) for content."""
    tape_content = to_hoon_tape(content)
    
    if key:
        key_tape = to_hoon_tape(key)
        data = f'[%put %{tag} `(crip "{key_tape}") (crip "{tape_content}")]'
    else:
        data = f'[%put %{tag} ~ (crip "{tape_content}")]'
    
    payload = json.dumps({
        "agent": "memory",
        "mark": "memory-action",
        "data": data
    })
    
    result = subprocess.run(
        ["bash", SCRIPT, "poke-our-agent", payload],
        capture_output=True, text=True, timeout=60
    )
    return result.stdout

def main():
    memory_dir = os.path.join(WORKSPACE, "memory")
    imported = 0
    failed = 0
    
    # Import daily files
    for fname in sorted(os.listdir(memory_dir)):
        if not fname.endswith(".md") or not fname.startswith("2026-"):
            continue
        date_key = fname.replace(".md", "")
        filepath = os.path.join(memory_dir, fname)
        content = open(filepath).read()
        
        print(f"daily/{date_key} ({len(content)}b)...", end=" ", flush=True)
        result = poke_memory("daily", date_key, content)
        
        if "Successfully poked" in result:
            print("OK")
            imported += 1
        else:
            print("FAIL")
            if "500" in result:
                print("  (500 error - content too large or bad chars)")
            failed += 1
        time.sleep(0.5)
    
    # Import SOUL.md
    soul_path = os.path.join(WORKSPACE, "SOUL.md")
    if os.path.exists(soul_path):
        content = open(soul_path).read()
        print(f"soul ({len(content)}b)...", end=" ", flush=True)
        result = poke_memory("soul", None, content)
        print("OK" if "Successfully poked" in result else "FAIL")
        imported += 1 if "Successfully poked" in result else 0
        failed += 0 if "Successfully poked" in result else 1
        time.sleep(0.5)
    
    # Import IDENTITY.md
    id_path = os.path.join(WORKSPACE, "IDENTITY.md")
    if os.path.exists(id_path):
        content = open(id_path).read()
        print(f"identity ({len(content)}b)...", end=" ", flush=True)
        result = poke_memory("identity", None, content)
        print("OK" if "Successfully poked" in result else "FAIL")
        imported += 1 if "Successfully poked" in result else 0
        failed += 0 if "Successfully poked" in result else 1
        time.sleep(0.5)
    
    # Import USER.md
    user_path = os.path.join(WORKSPACE, "USER.md")
    if os.path.exists(user_path):
        content = open(user_path).read()
        print(f"user ({len(content)}b)...", end=" ", flush=True)
        result = poke_memory("preference", "user-profile", content)
        print("OK" if "Successfully poked" in result else "FAIL")
        imported += 1 if "Successfully poked" in result else 0
        failed += 0 if "Successfully poked" in result else 1
    
    print(f"\nDone: {imported} imported, {failed} failed")

if __name__ == "__main__":
    main()
