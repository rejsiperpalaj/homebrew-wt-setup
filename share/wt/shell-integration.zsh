# wt shell integration
# Source this in ~/.zshrc:
#   source "$(brew --prefix)/share/wt/shell-integration.zsh"
#
# This thin wrapper calls wt-core for all logic and handles two things
# that a subprocess cannot do on its own:
#   1. cd into the new directory after setup/branch creation
#   2. Strip the __WTF_CD__ sentinel line from visible output

wt() {
  if ! command -v wt-core &>/dev/null; then
    print -u2 "wt: wt-core not found — is 'brew install --HEAD rejsiperpalaj/wt/wt' complete?"
    return 1
  fi

  # Capture stdout to intercept __WTF_CD__; let stderr flow through naturally.
  local tmpfile
  tmpfile=$(mktemp /tmp/wt-output.XXXXXX)
  wt-core "$@" > "$tmpfile"
  local exit_code=$?

  local cd_target="" line
  while IFS= read -r line; do
    if [[ "$line" == __WTF_CD__:* ]]; then
      cd_target="${line#__WTF_CD__:}"
    else
      print -- "$line"
    fi
  done < "$tmpfile"
  rm -f "$tmpfile"

  if [[ -n "$cd_target" && $exit_code -eq 0 ]]; then
    cd "$cd_target"
  fi

  return $exit_code
}
