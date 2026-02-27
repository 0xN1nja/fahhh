#!/usr/bin/env bash

REPO="https://raw.githubusercontent.com/0xN1nja/fahhh/master"
INSTALL_DIR="$HOME/.local/share/fahhh"
SOUND_FILE="$INSTALL_DIR/fahhh.mp3"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]:-$0}")"

mkdir -p "$INSTALL_DIR"

if [[ -f "$SCRIPT_DIR/assets/fahhh.mp3" ]]; then
	cp "$SCRIPT_DIR/assets/fahhh.mp3" "$SOUND_FILE"
else
	curl -fsSL "$REPO/assets/fahhh.mp3" -o "$SOUND_FILE"
fi

if [[ ! -f "$SOUND_FILE" ]]; then
	echo "failed to get fahhh.mp3"
	exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
	PLAYER="afplay"
elif command -v paplay &>/dev/null; then
	PLAYER="paplay"
elif command -v aplay &>/dev/null; then
	PLAYER="aplay"
else
	echo "no supported audio player found (afplay, paplay, aplay)"
	exit 1
fi

read -r -d '' HANDLER_ZSH <<EOF || true

command_not_found_handler() {
  $PLAYER "$SOUND_FILE" >/dev/null 2>&1 &
  echo "zsh: command not found: \$1" >&2
  return 127
}
EOF

read -r -d '' HANDLER_BASH <<EOF || true

command_not_found_handle() {
  $PLAYER "$SOUND_FILE" >/dev/null 2>&1 &
  echo "bash: command not found: \$1" >&2
  return 127
}
export -f command_not_found_handle
EOF

inject_rc() {
	local rc_file="$1"
	local snippet="$2"

	if grep -q "command_not_found_hand" "$rc_file" 2>/dev/null; then
		echo "fahhh is already installed in $rc_file — skipping."
		return
	fi

	echo "$snippet" >>"$rc_file"
	echo "fahhh installed into $rc_file"
	echo "restart your terminal or run: source $rc_file"
}

[[ -f "$HOME/.zshrc" ]] && inject_rc "$HOME/.zshrc" "$HANDLER_ZSH"
[[ -f "$HOME/.bashrc" ]] && inject_rc "$HOME/.bashrc" "$HANDLER_BASH"

exit 0
