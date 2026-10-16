#!/usr/bin/env sh
# Output a battery level indicator with color based on charging status.
# Used in tmux status-right.
# Options:
#   -n, --numeric    Show percentage instead of graphical bar
#   -s, --symbol     Show the charging lightning bolt symbol (hidden by default)

# Parse arguments
mode="char"
show_symbol=false  # Hidden by default - color is enough indication
while [ $# -gt 0 ]; do
    case "$1" in
        -n|--numeric) mode="numeric" ;;
        -s|--symbol) show_symbol=true ;;  # Use --symbol to show the lightning bolt
        *) ;;
    esac
    shift
done

# Block characters for 8 levels (0-12%, 13-25%, 26-38%, 39-51%, 52-64%, 65-77%, 78-90%, 91-100%)
levels='⡀⣀⣄⣤⣦⣮⣾⣿'

# Gruvbox colors
accent_color="#fabd2f"      # Yellow/orange (accent)
regular_color="#ebdbb2"     # Light gray (default)

get_battery_info() {
    # Try macOS pmset first
    if pmset -g batt 2>/dev/null | grep -q "Battery"; then
        line=$(pmset -g batt 2>/dev/null | grep -E "Battery")
        is_charging=$(echo "$line" | grep -iqw charging && echo "true" || echo "false")
        perc=$(echo "$line" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
        echo "$is_charging:$perc"
        return 0
    # Try Linux acpi
    elif acpi -b 2>/dev/null | grep -q "Battery"; then
        line=$(acpi -b 2>/dev/null | grep -E "Battery")
        is_charging=$(echo "$line" | grep -iqw charging && echo "true" || echo "false")
        perc=$(echo "$line" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
        echo "$is_charging:$perc"
        return 0
    fi
    return 1
}

info=$(get_battery_info) || exit 0
is_charging=$(printf '%s' "$info" | cut -d: -f1)
perc=$(printf '%s' "$info" | cut -d: -f2)

# Choose color based on charging status
if [ "$is_charging" = "true" ]; then
    color="$accent_color"
else
    color="$regular_color"
fi

# Build the battery display (level only)
if [ "$mode" = "numeric" ]; then
    [ -n "$perc" ] && battery_display="${perc}%"
else
    # Map percentage (0-100) to index 0-7
    if [ -z "$perc" ]; then
        idx=0
    else
        idx=$(( (perc * 8) / 100 ))
        # Cap at last index (7)
        if [ $idx -ge 8 ]; then idx=7; fi
    fi
    # Get character at 1-based position idx+1
    level_char=$(printf '%s' "$levels" | cut -c $((idx+1)))
    battery_display="$level_char"
fi

# Add charging symbol if enabled and currently charging
if [ "$show_symbol" = true ] && [ "$is_charging" = "true" ]; then
    battery_display="⚡ $battery_display"
fi

# Output with tmux color escape sequence
printf '#[fg=%s]%s' "$color" "$battery_display"


