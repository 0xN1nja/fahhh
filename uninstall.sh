#!/usr/bin/env bash

REMOVED=()

remove_from_rc() {
	local rc_file="$1"

	if [[ ! -f "$rc_file" ]]; then
		return
	fi

	if ! grep -q "command_not_found_hand" "$rc_file" 2>/dev/null; then
		echo "fahhh is not installed in $rc_file — skipping."
		return
	fi

	local tmp
	tmp="$(mktemp)"

	awk '
    /^$/ { blank=$0; next }
    /command_not_found_hand/ { skip=1; blank=""; next }
    skip && /^}/ { skip=0; next }
    /export -f command_not_found_handle/ { next }
    !skip { if (blank != "") { print blank; blank="" } print }
  ' "$rc_file" >"$tmp"

	mv "$tmp" "$rc_file"
	REMOVED+=("$rc_file")
}

remove_from_rc "$HOME/.zshrc"
remove_from_rc "$HOME/.bashrc"

if [[ -d "$HOME/.local/share/fahhh" ]]; then
	rm -rf "$HOME/.local/share/fahhh"
fi

if [[ ${#REMOVED[@]} -gt 0 ]]; then
	for rc_file in "${REMOVED[@]}"; do
		echo "fahhh removed from $rc_file"
	done
	echo -n "restart your terminal or run:"
	for rc_file in "${REMOVED[@]}"; do
		echo -n " source $rc_file"
	done
	echo
fi

exit 0
