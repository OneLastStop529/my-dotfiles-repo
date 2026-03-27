#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/zsh/.zsh/completions"
mkdir -p "$OUT_DIR"

generated=()
skipped=()

generate_function() {
  local name="$1"
  local cmd="$2"
  local outfile="$OUT_DIR/_$name"
  local tmpfile
  tmpfile="$(mktemp)"

  if eval "$cmd" > "$tmpfile" 2>/dev/null && [ -s "$tmpfile" ]; then
    # compinit expects #compdef/#autoload at the start of the file.
    awk '{
      if (!started && $0 ~ /^[[:space:]]*$/) next
      started=1
      print
    }' "$tmpfile" > "$outfile"
    rm -f "$tmpfile"
    generated+=("$name")
  else
    rm -f "$tmpfile"
    rm -f "$outfile"
    skipped+=("$name")
  fi
}

generate_script() {
  local name="$1"
  local cmd="$2"
  local outfile="$OUT_DIR/$name-completion.zsh"

  if eval "$cmd" > "$outfile" 2>/dev/null && [ -s "$outfile" ]; then
    generated+=("$name")
  else
    rm -f "$outfile"
    skipped+=("$name")
  fi
}

generate_bash_script() {
  local name="$1"
  local cmd="$2"
  local outfile="$OUT_DIR/$name-completion.zsh"

  if {
    echo 'autoload -U +X bashcompinit && bashcompinit'
    eval "$cmd"
  } > "$outfile" 2>/dev/null && [ -s "$outfile" ]; then
    generated+=("$name")
  else
    rm -f "$outfile"
    skipped+=("$name")
  fi
}

generate_nim_completion() {
  local outfile="$OUT_DIR/_nim"
  cat > "$outfile" <<'EOF'
#compdef nim

_nim() {
  local -a commands
  commands=(
    "compile:Compile project with default backend"
    "c:Compile project with default backend"
    "r:Compile and run"
    "doc:Generate documentation"
  )

  _arguments -C \
    '1:command:->cmds' \
    '*::args:->rest' && return 0

  case $state in
    cmds)
      _describe -t commands "nim command" commands
      ;;
    rest)
      _arguments -s \
        '--help[Show help]' \
        '--fullhelp[Show all command line switches]' \
        '--version[Show version information]' \
        '--run[Run compiled program]' \
        '--eval[Evaluate Nim code]:code:' \
        '--backend[Select backend]:backend:(c cpp objc js)' \
        '--path[Add search path]:path:_files -/' \
        '--define[Define conditional symbol]:symbol:' \
        '--undef[Undefine conditional symbol]:symbol:' \
        '--forceBuild[Force rebuild]:bool:(on off)' \
        '--stackTrace[Stack tracing]:bool:(on off)' \
        '--lineTrace[Line tracing]:bool:(on off)' \
        '--threads[Thread support]:bool:(on off)' \
        '--checks[Runtime checks]:bool:(on off)' \
        '--assertions[Assertions]:bool:(on off)' \
        '--opt[Optimization level]:level:(none speed size)' \
        '--debugger[Debugger]:debugger:(native)' \
        '--app[App type]:type:(console gui lib staticlib)' \
        '-p[Add search path]:path:_files -/' \
        '-d[Define conditional symbol]:symbol:' \
        '-u[Undefine conditional symbol]:symbol:' \
        '-f[Force rebuild]:bool:(on off)' \
        '-x[Runtime checks]:bool:(on off)' \
        '-a[Assertions]:bool:(on off)' \
        '-r[Run compiled program]' \
        '*:file:_files'
      ;;
  esac
}

_nim "$@"
EOF
  generated+=("nim")
}

command -v bun >/dev/null 2>&1 && generate_function bun "bun completions" || skipped+=("bun")
command -v rustup >/dev/null 2>&1 && generate_function cargo "rustup completions zsh cargo" || skipped+=("cargo")
command -v docker >/dev/null 2>&1 && generate_function docker "docker completion zsh" || skipped+=("docker")
command -v kubectl >/dev/null 2>&1 && generate_function kubectl "kubectl completion zsh" || skipped+=("kubectl")
command -v gh >/dev/null 2>&1 && generate_function gh "gh completion -s zsh" || skipped+=("gh")
command -v uv >/dev/null 2>&1 && generate_function uv "uv generate-shell-completion zsh" || skipped+=("uv")
command -v codex >/dev/null 2>&1 && generate_function codex "codex completion zsh" || skipped+=("codex")
command -v openclaw >/dev/null 2>&1 && generate_function openclaw "openclaw completion -s zsh" || skipped+=("openclaw")
command -v nim >/dev/null 2>&1 && generate_nim_completion || skipped+=("nim")

if command -v npm >/dev/null 2>&1; then
  generate_script npm "npm completion"
else
  skipped+=("npm")
fi

if command -v node >/dev/null 2>&1; then
  generate_bash_script node "node --completion-bash"
else
  skipped+=("node")
fi

if command -v aws >/dev/null 2>&1 && command -v aws_completer >/dev/null 2>&1; then
  cat > "$OUT_DIR/aws-completion.zsh" <<'EOF'
if command -v aws_completer >/dev/null 2>&1; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o default -C aws_completer aws
fi
EOF
  generated+=("aws")
else
  rm -f "$OUT_DIR/aws-completion.zsh"
  skipped+=("aws")
fi

if command -v yarn >/dev/null 2>&1; then
  yarn_version="$(yarn --version 2>/dev/null || true)"
  if [[ "$yarn_version" == 1.* ]]; then
    rm -f "$OUT_DIR/yarn-completion.zsh"
    skipped+=("yarn")
  elif yarn completion zsh > "$OUT_DIR/yarn-completion.zsh" 2>/dev/null && [ -s "$OUT_DIR/yarn-completion.zsh" ]; then
    generated+=("yarn")
  else
    rm -f "$OUT_DIR/yarn-completion.zsh"
    skipped+=("yarn")
  fi
else
  skipped+=("yarn")
fi

echo "Generated: ${generated[*]:-none}"
echo "Skipped: ${skipped[*]:-none}"
