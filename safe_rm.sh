TRASH_DIR="$HOME/.safetrash"
mkdir -p "$TRASH_DIR" 2>/dev/null
recursive=0
files=()
force=0
for arg in "$@"; do
    case "$arg" in
        -r|-R|-rf|-fr|-rfi|-fri)
            recursive=1
            ;;
        -f|-fi|-if)
            force=1
            ;;
        -*)
            ;;
        *)
            files+=("$arg")
            ;;
    esac
done
if [ ${
    exit 0
fi
if [ "${files[0]}" = "clean" ]; then
    find "$TRASH_DIR" -maxdepth 1 -type f -mtime +30 -delete 2>/dev/null
    exit 0
elif [ "${files[0]}" = "list" ]; then
    ls -1 "$TRASH_DIR" 2>/dev/null
    exit 0
elif [ "${files[0]}" = "restore" ]; then
    if [ -n "${files[1]}" ]; then
        mv "$TRASH_DIR/${files[1]}" "./$(echo ${files[1]} | cut -d'_' -f1)" 2>/dev/null
    fi
    exit 0
fi
for target in "${files[@]}"; do
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        echo "rm: cannot remove '$target': No such file or directory" >&2
        continue
    fi
    if [ -d "$target" ] && [ $recursive -eq 0 ]; then
        echo "rm: cannot remove '$target': Is a directory" >&2
        continue
    fi
    basename=$(basename "$target")
    timestamp=$(date +%Y%m%d_%H%M%S)
    random=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c4)
    trash_name="${basename}_${timestamp}_${random}"
    mv "$target" "$TRASH_DIR/$trash_name" 2>/dev/null
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $(pwd)/$target -> $trash_name" >> "$TRASH_DIR/.log" 2>/dev/null
done
exit 0
