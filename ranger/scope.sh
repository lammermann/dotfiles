#!/usr/bin/env sh

# ranger supports enhanced previews.  If the option "use_preview_script"
# is set to True and this file exists, this script will be called and its
# output is displayed in ranger.  ANSI color codes are supported.

## This script is considered a configuration file and must be updated manually.
## It will be left untouched if you upgrade ranger.


## Meanings of exit codes:
## code | meaning    | action of ranger
## -----+------------+-------------------------------------------
## 0    | success    | Display stdout as preview
## 1    | no preview | Display no preview at all
## 2    | plain text | Display the plain content of the file
## 3    | fix width  | Don't reload when width changes
## 4    | fix height | Don't reload when height changes
## 5    | fix both   | Don't ever reload
## 6    | image      | Display the image $cached points to as an image preview
## 7    | image      | Display the file directly as an image

## Script arguments
path="$1"            # Full path of the selected file
width="$2"           # Width of the preview pane (number of fitting characters)
height="$3"          # Height of the preview pane (number of fitting characters)
cached="$4"          # Path that should be used to cache image previews
preview_images="$5"  # "True" if image previews are enabled, "False" otherwise.

maxln=200    # Stop after $maxln lines.  Can be used like ls | head -n $maxln

# Find out something about the file:
mimetype=$(file --mime-type -Lb "$path")
extension=$(/usr/bin/env echo "${path##*.}" | awk '{print tolower($0)}')

## Settings
HIGHLIGHT_SIZE_MAX=262143  # 256KiB
HIGHLIGHT_TABWIDTH="${HIGHLIGHT_TABWIDTH:-8}"
HIGHLIGHT_STYLE="${HIGHLIGHT_STYLE:-pablo}"
HIGHLIGHT_OPTIONS="--replace-tabs=${HIGHLIGHT_TABWIDTH} --style=${HIGHLIGHT_STYLE} ${HIGHLIGHT_OPTIONS:-}"
PYGMENTIZE_STYLE="${PYGMENTIZE_STYLE:-autumn}"
BAT_STYLE="${BAT_STYLE:-plain}"
SQLITE_TABLE_LIMIT=20  # Display only the top <limit> tables in database, set to 0 for no exhaustive preview (only the sqlite_master table is displayed).
SQLITE_ROW_LIMIT=5     # Display only the first and the last (<limit> - 1) records in each table, set to 0 for no limits.

# Functions:
# runs a command and saves its output into $output.  Useful if you need
# the return value AND want to use the output in a pipe
try() { output=$(eval '"$@"'); }

# writes the output of the previously used "try" command
dump() { /usr/bin/env echo "$output"; }

# a common post-processing function used after most commands
trim() { head -n "$maxln"; }

# wraps highlight to treat exit code 141 (killed by SIGPIPE) as success
safepipe() { "$@"; test $? = 0 -o $? = 141; }

# Image previews, if enabled in ranger.
if [ "$preview_images" = "True" ]; then
    case "$mimetype" in
        # Image previews for SVG files, disabled by default.
        ###image/svg+xml)
        ###   convert "$path" "$cached" && exit 6 || exit 1;;
        # Image previews for image files. w3mimgdisplay will be called for all
        # image files (unless overriden as above), but might fail for
        # unsupported types.
        image/*)
            exit 7;;
        # Image preview for video, disabled by default.:
        ###video/*)
        ###    ffmpegthumbnailer -i "$path" -o "$cached" -s 0 && exit 6 || exit 1;;
    esac
fi

handle_extension() {
    case "$extension" in
        ## Archive
        a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
        rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)
            try atool -l "$path" && { dump | trim; exit 0; }
            try als "$path" && { dump | trim; exit 0; }
            try acat "$path" && { dump | trim; exit 3; }
            try bsdtar -lf "$path" && { dump | trim; exit 0; }
            exit 1;;
        rar)
            ## Avoid password prompt by providing empty password
            try unrar -p- lt "$path" && { dump | trim; exit 0; } || exit 1;;
        7z)
            ## Avoid password prompt by providing empty password
            try 7z -p l "$path" && { dump | trim; exit 0; } || exit 1;;
        ## PDF
        pdf)
            try pdftotext -l 10 -nopgbrk -q "$path" - && \
                { dump | trim | fmt -s -w $width; exit 0; } || exit 1;;
        ## BitTorrent
        torrent)
            try transmission-show "$path" && { dump | trim; exit 5; } || exit 1;;
        ## ODT Files
        odt|ods|odp|sxw)
            try odt2txt "$path" && { dump | trim; exit 5; } || exit 1;;
        ## HTML
        htm|html|xhtml)
            try w3m    -dump "$path" && { dump | trim | fmt -s -w $width; exit 4; }
            try lynx   -dump "$path" && { dump | trim | fmt -s -w $width; exit 4; }
            try elinks -dump "$path" && { dump | trim | fmt -s -w $width; exit 4; }
            ;; # fall back to highlight/cat if the text browsers fail
    esac
}

handle_mime() {
    case "${mimetype}" in
        ## RTF and DOC
        text/rtf|*msword)
            ## Preview as text conversion
            ## note: catdoc does not always work for .doc files
            ## catdoc: http://www.wagner.pp.ru/~vitus/software/catdoc/
            catdoc -- "${path}" && exit 5
            exit 1;;

        ## SQLite
        *sqlite3)
            ## Preview as text conversion
            sqlite_tables="$( sqlite3 "file:${path}?mode=ro" '.tables' )" \
                || exit 1
            [ -z "${sqlite_tables}" ] &&
                { echo "Empty SQLite database." && exit 5; }
            sqlite_show_query() {
                sqlite-utils query "${path}" "${1}" --table --fmt fancy_grid \
                || sqlite3 "file:${path}?mode=ro" "${1}" -header -column
            }
            ## Display basic table information
            sqlite_rowcount_query="$(
                sqlite3 "file:${path}?mode=ro" -noheader \
                    'SELECT group_concat(
                        "SELECT """ || name || """ AS tblname,
                                          count(*) AS rowcount
                         FROM " || name,
                        " UNION ALL "
                    )
                    FROM sqlite_master
                    WHERE type="table" AND name NOT LIKE "sqlite_%";'
            )"
            sqlite_show_query \
                "SELECT tblname AS 'table', rowcount AS 'count',
                (
                    SELECT '(' || group_concat(name, ', ') || ')'
                    FROM pragma_table_info(tblname)
                ) AS 'columns',
                (
                    SELECT '(' || group_concat(
                        upper(type) || (
                            CASE WHEN pk > 0 THEN ' PRIMARY KEY' ELSE '' END
                        ),
                        ', '
                    ) || ')'
                    FROM pragma_table_info(tblname)
                ) AS 'types'
                FROM (${sqlite_rowcount_query});"
            if [ "${SQLITE_TABLE_LIMIT}" -gt 0 ] &&
               [ "${SQLITE_ROW_LIMIT}" -ge 0 ]; then
                ## Do exhaustive preview
                echo && printf '>%.0s' $( seq "${width}" ) && echo
                sqlite3 "file:${path}?mode=ro" -noheader \
                    "SELECT name FROM sqlite_master
                    WHERE type='table' AND name NOT LIKE 'sqlite_%'
                    LIMIT ${SQLITE_TABLE_LIMIT};" |
                    while read -r sqlite_table; do
                        sqlite_rowcount="$(
                            sqlite3 "file:${path}?mode=ro" -noheader \
                                "SELECT count(*) FROM ${sqlite_table}"
                        )"
                        echo
                        if [ "${SQLITE_ROW_LIMIT}" -gt 0 ] &&
                           [ "${SQLITE_ROW_LIMIT}" \
                             -lt "${sqlite_rowcount}" ]; then
                            echo "${sqlite_table} [${SQLITE_ROW_LIMIT} of ${sqlite_rowcount}]:"
                            sqlite_ellipsis_query="$(
                                sqlite3 "file:${path}?mode=ro" -noheader \
                                    "SELECT 'SELECT ' || group_concat(
                                        '''...''', ', '
                                    )
                                    FROM pragma_table_info(
                                        '${sqlite_table}'
                                    );"
                            )"
                            sqlite_show_query \
                                "SELECT * FROM (
                                    SELECT * FROM ${sqlite_table} LIMIT 1
                                )
                                UNION ALL ${sqlite_ellipsis_query} UNION ALL
                                SELECT * FROM (
                                    SELECT * FROM ${sqlite_table}
                                    LIMIT (${SQLITE_ROW_LIMIT} - 1)
                                    OFFSET (
                                        ${sqlite_rowcount}
                                        - (${SQLITE_ROW_LIMIT} - 1)
                                    )
                                );"
                        else
                            echo "${sqlite_table} [${sqlite_rowcount}]:"
                            sqlite_show_query "SELECT * FROM ${sqlite_table};"
                        fi
                    done
            fi
            exit 5;;

        ## Text
        text/* | */xml | application/javascript)
            ## Syntax highlight
            if [[ "$( stat --printf='%s' -- "${path}" )" -gt "${HIGHLIGHT_SIZE_MAX}" ]]; then
                exit 2
            fi
            if [[ "$( tput colors )" -ge 256 ]]; then
                local pygmentize_format='terminal256'
                local highlight_format='xterm256'
            else
                local pygmentize_format='terminal'
                local highlight_format='ansi'
            fi
            env HIGHLIGHT_OPTIONS="${HIGHLIGHT_OPTIONS}" highlight \
                --out-format="${highlight_format}" \
                --force -- "${path}" && exit 5
            env COLORTERM=8bit bat --color=always --style="${BAT_STYLE}" \
                -- "${path}" && exit 5
            pygmentize -f "${pygmentize_format}" -O "style=${PYGMENTIZE_STYLE}"\
                -- "${path}" && exit 5
            exit 2;;
        ## Image
        image/*)
            ## Preview as text conversion
            img2txt --gamma=0.6 --width="$width" "$path" && exit 4 || exit 1;;
        # Display information about media files:
        video/* | audio/*)
            exiftool "$path" && exit 5
            # Use sed to remove spaces so the output fits into the narrow window
            try mediainfo "$path" && { dump | trim | sed 's/  \+:/: /;';  exit 5; } || exit 1;;
    esac
}

handle_fallback() {
    echo '----- File Type Classification -----' && file --dereference --brief -- "${path}" && exit 5
}

handle_extension
handle_mime
handle_fallback

exit 1
