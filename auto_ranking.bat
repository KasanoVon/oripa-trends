@echo off
chcp 65001 > nul
setlocal

set PYTHON=C:\Users\sota\venv\Program\.venv\Scripts\python.exe
set SITE_DIR=C:\Users\sota\venv\Program\oripa_site

cd /d "%SITE_DIR%"

:: 1. 直近15分の投稿を取得
echo [%date% %time%] fetch_tweets_test.py 開始
"%PYTHON%" fetch_tweets_test.py
if %errorlevel% neq 0 (
    echo [ERROR] fetch_tweets_test.py 失敗
    exit /b 1
)

:: 2. 投稿数を累積集計
echo [%date% %time%] ranking.py 開始
"%PYTHON%" ranking.py
if %errorlevel% neq 0 (
    echo [ERROR] ranking.py 失敗
    exit /b 1
)

:: 3. 変更があれば git push
git add data/tweets/ranking_history.json data/tweets/seen_ids.json

git diff --staged --quiet
if %errorlevel% equ 0 (
    echo [%date% %time%] 変更なし、スキップ
    exit /b 0
)

git commit -m "ランキング自動更新: %date% %time%"
git push origin main

echo [%date% %time%] 完了
endlocal
