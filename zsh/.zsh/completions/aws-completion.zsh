if command -v aws_completer >/dev/null 2>&1; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o default -C aws_completer aws
fi
