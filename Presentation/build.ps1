# ============================================================
# build.ps1 — Lancer la présentation Marp dans le navigateur
# ============================================================

$port = 8080
$file = "README.md"
$url  = "http://localhost:$port/$file"

Write-Host "--- Démarrage du serveur Marp ---" -ForegroundColor Cyan

# Ouvre le navigateur après 2 secondes (laisse le temps au serveur de démarrer)
Start-Job -ScriptBlock {
    param($u)
    Start-Sleep -Seconds 2
    Start-Process $u
} -ArgumentList $url | Out-Null

# Lance le serveur Marp (bloquant — Ctrl+C pour arrêter)
npx @marp-team/marp-cli --server . --port $port
