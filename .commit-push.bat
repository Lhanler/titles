@echo off
cd /d C:\Users\全村的希望\Desktop\titles
set GIT_SSH_COMMAND=ssh -i C:\Users\全村的希望\.ssh\id_ed25519 -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=C:\Users\全村的希望\.ssh\known_hosts -o ConnectTimeout=30
set GIT_TERMINAL_PROMPT=0
git add -A
git commit -m "chore: weekly schedule + SSH remote + full sync (2026-07-22)"
git push -u origin main
echo === log ===
git log --oneline -3
echo === status ===
git status -sb
