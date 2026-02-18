chmod +x /usr/local/bin/asira-startup

if command -v asira-startup >/dev/null 2>&1; then
    asira-startup
else
    /usr/local/bin/asira-startup
fi

