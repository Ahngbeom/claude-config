#!/bin/bash
# Claude Code Cross-Platform Notification Script
# Usage: notify.sh "title" "message" ["summary"]

TITLE="${1:-Claude Code}"
MESSAGE="${2:-알림}"
SUMMARY="${3:-}"

# 요약이 있으면 메시지에 줄바꿈으로 추가
if [ -n "$SUMMARY" ]; then
    MESSAGE="$MESSAGE
$SUMMARY"
fi

case "$(uname -s)" in
    Darwin)
        # macOS - osascript
        osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"Glass\""
        ;;
    Linux)
        # Linux - notify-send (requires libnotify)
        if command -v notify-send &> /dev/null; then
            notify-send "$TITLE" "$MESSAGE"
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*)
        # Windows Git Bash / MSYS2 / Cygwin
        powershell.exe -Command "[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null; \$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02); \$textNodes = \$template.GetElementsByTagName('text'); \$textNodes.Item(0).AppendChild(\$template.CreateTextNode('$TITLE')) | Out-Null; \$textNodes.Item(1).AppendChild(\$template.CreateTextNode('$MESSAGE')) | Out-Null; \$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Code'); \$notifier.Show([Windows.UI.Notifications.ToastNotification]::new(\$template))"
        ;;
esac
