# Jalankan dari folder root proyek (yang berisi pubspec.yaml dan env.json):
#   .\deploy.ps1

$ErrorActionPreference = "Stop"

if (-not (Test-Path "env.json")) {
    Write-Error "env.json tidak ditemukan di folder ini."
    exit 1
}

# Token WAJIB dikirim saat build, karena String.fromEnvironment dibaca saat compile.
flutter build web --release --dart-define-from-file=env.json

firebase deploy --only hosting
