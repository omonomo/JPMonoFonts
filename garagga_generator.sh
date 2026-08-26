#!/usr/bin/env bash

# Custom font generator for Garagga
#
# Copyright (c) 2026 omonomo
#
# [Original Script]
# Ricty Generator (ricty_generator-4.1.1.sh)
#
# Copyright (c) 2011-2017 Yasunori Yusa
# All rights reserved.
# (https://rictyfonts.github.io)


# ログをファイル出力させる場合は有効にする (<< "#LOG" をコメントアウトさせる)
<< "#LOG"
LOG_OUT=/tmp/font_generator.log
LOG_ERR=/tmp/font_generator_err.log
exec 1> >(tee -a $LOG_OUT)
exec 2> >(tee -a $LOG_ERR)
#LOG

font_familyname="Garagga"
font_familyname_suffix=""

font_version="1.0.0"
vendor_id="PfEd"

tmpdir_name="font_generator_tmpdir" # 一時保管フォルダ名

# 著作権
copyright="Copyright (c) 2026 omonomo\n\n"
copyright="${copyright}\" + \"[Reggae One]\nCopyright 2020 The Reggae Project Authors (https://github.com/fontworks-fonts/Reggae/), all rights reserved.\n\n"
copyright_license="SIL Open Font License Version 1.1 (http://scripts.sil.org/ofl)"

# name タグ用 (製造元、供給元、デザイナー、ライセンス)
name_manufacturer="omonomo"
name_vendor_url="https://github.com/omonomo/JPMonoFonts"
name_designer="Fontworks Inc."
name_designer_url="http://fontworks.co.jp/"
name_license="SIL Open Font License, Version 1.1"
name_license_url="https://scripts.sil.org/OFL"
change_designer="false" # デザイナー情報の変更

em_ascent="880" # em値用 ※ win_ascent - (設定したい typo_linegap) / 2 が適正っぽい
em_descent="120" # win_descent - (設定したい typo_linegap) / 2 が適正っぽい
typo_ascent="${em_ascent}" # typo_ascent + typo_descent = em値にしないと縦書きで文字間隔が崩れる
typo_descent="${em_descent}" # 縦書きに対応させない場合、linegap = 0で typo、win、hhea 全てを同じにするのが無難
typo_linegap="0" # win_ascent + win_descent = typo_ascent + typo_descent + typo_linegap
win_ascent="1160"
win_descent="288"
hhea_ascent="${win_ascent}"
hhea_descent="${win_descent}"
hhea_linegap="0"
change_metrics="false" # メトリクス情報の変更

width_zero="0" # 文字幅ゼロ
width_xAvg_char="500" # フォントの半角文字幅の指定は常に全角の半分とする
width_hankaku="600" # 半角文字幅
width_threshold="850" # 半角全角判断文字幅
width_zenkaku="1000" # 全角文字幅
width_expand="-15" # 幅広のグリフを縮める際の両端調整幅 (マイナスで文字拡大、プラスで縮小)
weight_narrow="0" # 幅広のグリフを縮める際のウェイト調整値 (小さいほど拡大、0で無効)

build_fonts_dir="build" # 完成品を保管するディレクトリ名

# Set path to command
fontforge_command="fontforge"
ttx_command="ttx"

# Set redirection of stderr
redirection_stderr="/dev/null"

# Set fonts directories used in auto flag
fonts_directories=". ${HOME}/.fonts /usr/local/share/fonts /usr/share/fonts \
${HOME}/Library/Fonts /Library/Fonts \
/c/Windows/Fonts /cygdrive/c/Windows/Fonts"

# Set flags
leaving_tmp_flag="false" # 一時ファイル残す
draft_flag="false" # 下書きモード
check_half_flag="false" # 半角文字確認モード

# Set filenames
origin_regular="ReggaeOne-Regular.ttf"
origin_bold=""
zenkaku_space="ZenkakuSpace.ttf"

custom_font_generator="custom_font_generator.pe"

################################################################################
# Pre-process
################################################################################

# Print information message
cat << _EOT_

----------------------------
${font_familyname} ${font_familyname_suffix} generator
Font version: ${font_version}
----------------------------

_EOT_

remove_temp() {
    echo "Remove temporary files"
    rm -rf $tmpdir
    rm -f ${font_familyname}*.ttx
    rm -f ${font_familyname}*.ttx.bak
}

# Define displaying help function
font_generator_help()
{
    echo "Usage: font_generator.sh [options]"
    echo "       font_generator.sh [options] [font]-{Regular}.ttf [font]-{bold}.ttf"
    echo ""
    echo "Options:"
    echo "  -h                     Display this information"
    echo "  -V                     Display version number"
    echo "  -x                     Cleaning temporary files" # 一時作成ファイルの消去のみ
    echo "  -f /path/to/fontforge  Set path to fontforge command"
    echo "  -v                     Enable verbose mode (display fontforge's warning)"
    echo "  -l                     Leave (do NOT remove) temporary files"
    echo "  -N string              Set fontfamily (\"string\")"
    echo "  -n string              Set fontfamily suffix (\"string\")"
    echo "  -d                     Enable draft mode (doesn't narrow the glyph width)"
    echo "  -c                     Check for half-width characters"
}

# Get options
while getopts hVxf:vlN:n:dc OPT
do
    case "${OPT}" in
        "h" )
            font_generator_help
            exit 0
            ;;
        "V" )
            exit 0
            ;;
        "x" )
            echo "Option: Cleaning temporary files"
            remove_temp
            rm -rf ${tmpdir_name}.*
            rm -f ${font_familyname}*.ttf
            exit 0
            ;;
        "f" )
            echo "Option: Set path to fontforge command: ${OPTARG}"
            fontforge_command="${OPTARG}"
            ;;
        "v" )
            echo "Option: Enable verbose mode"
            redirection_stderr="/dev/stderr"
            ;;
        "l" )
            echo "Option: Leave (do NOT remove) temporary files"
            leaving_tmp_flag="true"
            ;;
        "N" )
            echo "Option: Set fontfamily: ${OPTARG}"
            font_familyname=${OPTARG// /}
            ;;
        "n" )
            echo "Option: Set fontfamily suffix: ${OPTARG}"
            font_familyname_suffix=${OPTARG// /}
            ;;
        "d" )
            echo "Option: Enable draft mode (doesn't narrow the glyph width)"
            draft_flag="true"
            ;;
        "c" )
            echo "Check for half-width characters"
            check_half_flag="true"
            draft_flag="false"
            ;;
        * )
            font_generator_help
            exit 1
            ;;
    esac
done
echo

shift $(($OPTIND - 1))

# Get input fonts
if [ $# -eq 0 ]; then
    # Check existance of directories
    tmp=""
    for i in $fonts_directories
    do
        [ -d "${i}" ] && tmp="${tmp} ${i}"
    done
    fonts_directories=$tmp
    # Search latin fonts
    input_regular=$(find $fonts_directories -follow -name "${origin_regular}" | head -n 1)
    if [ -z "${input_regular}" ]; then
        echo "Error: ${origin_regular} not found" >&2
        exit 1
    fi
    if [ -n "${origin_bold}" ]; then
        input_bold=$(find $fonts_directories -follow -name "${origin_bold}" | head -n 1)
        if [ -z "${input_bold}" ]; then
            echo "Error: ${origin_bold} not found" >&2
            exit 1
        fi
    fi
elif [ $# -eq 1 ] || [ $# -eq 2 ]; then
    # Get arguments
    input_regular=$1
    input_bold=$2
    # Check existance of files
    if [ ! -r "${input_regular}" ]; then
        echo "Error: ${input_regular} not found" >&2
        exit 1
    elif [ -n "${origin_bold}" ]; then
        if [ ! -r "${input_bold}" ]; then
            echo "Error: ${input_bold} not found" >&2
            exit 1
        fi
    fi
    # Check filename
    [ "$(basename $input_regular)" != "${origin_regular}" ] &&
        echo "Warning: ${input_regular} does not seem to be ${origin_regular}" >&2
    if [ -n "${origin_bold}" ]; then
        [ "$(basename $input_bold)" != "${origin_bold}" ] &&
            echo "Warning: ${input_bold} does not seem to be ${origin_bold}" >&2
    fi
else
    echo "Error: missing arguments"
    echo
    font_generator_help
    exit 1
fi

# Search zenkaku space font
input_zenkaku_space=$(find $fonts_directories -follow -name "${zenkaku_space}" | head -n 1)
if [ -z "${input_zenkaku_space}" ]; then
    echo "Error: ${zenkaku_space} not found" >&2
    exit 1
fi

# Check fontforge existance
if ! which $fontforge_command > /dev/null 2>&1
then
    echo "Error: ${fontforge_command} command not found" >&2
    exit 1
fi
fontforge_v=$(${fontforge_command} -version)
fontforge_version=$(echo ${fontforge_v} | cut -d ' ' -f2)

# Check ttx existance
if ! which $ttx_command > /dev/null 2>&1
then
    echo "Error: ${ttx_command} command not found" >&2
    exit 1
fi
ttx_version=$(${ttx_command} --version)

# Make temporary directory
if [ -w "/tmp" -a "${leaving_tmp_flag}" = "false" ]; then
    tmpdir=$(mktemp -d /tmp/"${tmpdir_name}".XXXXXX) || exit 2
else
    tmpdir=$(mktemp -d ./"${tmpdir_name}".XXXXXX)    || exit 2
fi

# Remove temporary directory by trapping
if [ "${leaving_tmp_flag}" = "false" ]; then
    trap "if [ -d \"$tmpdir\" ]; then echo 'Remove temporary files'; rm -rf $tmpdir; echo 'Abnormally terminated'; fi; exit 3" HUP INT QUIT
    trap "if [ -d \"$tmpdir\" ]; then echo 'Remove temporary files'; rm -rf $tmpdir; echo 'Abnormally terminated'; fi" EXIT
else
    trap "echo 'Abnormally terminated'; exit 3" HUP INT QUIT
fi
echo

# フォントバージョンにビルドNo追加
buildNo=$(date "+%s")
buildNo=$((buildNo % 315360000 / 60))
buildNo=$(bc <<< "obase=16; ibase=10; ${buildNo}")
font_version="${font_version} (${buildNo})"

################################################################################
# Generate script for custom fonts
################################################################################

cat > ${tmpdir}/${custom_font_generator} << _EOT_
#!$fontforge_command -script

Print("- Generate custom fonts -")

# Set parameters
if ("${origin_bold}" != "")
    input_list        = ["${input_regular}", "${input_bold}"]
    fontstyle_list    = ["Regular", "Bold"]
    fontweight_list   = [400,       700]
    panoseweight_list = [6,         8]
else
    input_list        = ["${input_regular}"]
    fontstyle_list    = ["Regular"]
    fontweight_list   = [400]
    panoseweight_list = [6]
endif
input_zenkaku_space = "${input_zenkaku_space}"
fontfamily        = "${font_familyname}"
fontfamilysuffix  = "${font_familyname_suffix}"

copyright         = "${copyright}" \\
                  + "${copyright_license}"
version           = "${font_version}"

# Begin loop of regular and bold
i = 0
while (i < SizeOf(fontstyle_list))

# Open new file
    Print("Open " + input_list[i])
    Open(input_list[i])
# Merge with ZenkakuSpace fonts
    Print("Merge " + input_zenkaku_space)
    MergeFonts(input_zenkaku_space)

    SelectWorthOutputting()
    UnlinkReference()

# Set configuration
    if (fontfamilysuffix != "")
        SetFontNames(fontfamily + fontfamilysuffix + "-" + fontstyle_list[i], \\
                     fontfamily + " " + fontfamilysuffix, \\
                     fontfamily + " " + fontfamilysuffix + " " + fontstyle_list[i], \\
                     fontstyle_list[i], \\
                     copyright, version)
    else
        SetFontNames(fontfamily + "-" + fontstyle_list[i], \\
                     fontfamily, \\
                     fontfamily + " " + fontstyle_list[i], \\
                     fontstyle_list[i], \\
                     copyright, version)
    endif

    j = 0
    while (j < 20)
        SetTTFName(0x411, j, "") # 日本語
        j+=1
    endloop

    SetTTFName(0x409,  2, fontstyle_list[i])
    SetTTFName(0x409,  3, "FontForge ${fontforge_version} : " + "FontTools ${ttx_version} : " + \$fullname + " : " + Strftime("%d-%m-%Y", 0))
    SetTTFName(0x409,  5, version)
    SetTTFName(0x409,  8, "${name_manufacturer}")
    SetTTFName(0x409, 11, "${name_vendor_url}")
    if ("${change_designer}" == "true")
        SetTTFName(0x409,  9, "${name_designer}")
        SetTTFName(0x409, 12, "${name_designer_url}")
    endif
    SetTTFName(0x409, 13, "${name_license}")
    SetTTFName(0x409, 14, "${name_license_url}")
    if ("${change_metrics}" == "true")
        ScaleToEm(${em_ascent}, ${em_descent})
        SetOS2Value("Weight", fontweight_list[i])
        SetOS2Value("Width",                   5)
        SetOS2Value("WinAscentIsOffset",       0)
        SetOS2Value("WinDescentIsOffset",      0)
        SetOS2Value("TypoAscentIsOffset",      0)
        SetOS2Value("TypoDescentIsOffset",     0)
        SetOS2Value("HHeadAscentIsOffset",     0)
        SetOS2Value("HHeadDescentIsOffset",    0)
        SetOS2Value("WinAscent",             ${win_ascent})
        SetOS2Value("WinDescent",            ${win_descent})
        SetOS2Value("TypoAscent",            ${typo_ascent})
        SetOS2Value("TypoDescent",          -${typo_descent})
        SetOS2Value("TypoLineGap",           ${typo_linegap})
        SetOS2Value("HHeadAscent",           ${hhea_ascent})
        SetOS2Value("HHeadDescent",         -${hhea_descent})
        SetOS2Value("HHeadLineGap",          ${hhea_linegap})
    endif
    SetOS2Value("FSType",                  0)
    SetOS2Value("VendorID",   "${vendor_id}")
    SetOS2Value("IBMFamily",          0x0a00) # 手書き 分類無し
    SetPanose([3, 4, panoseweight_list[i], 3, 3, 4,\
               2, 2, 2, 5])

# --------------------------------------------------

# 使用しないグリフクリア
    Print("Remove not used glyphs")
    Select(0, 31); Clear(); DetachAndRemoveGlyphs()

# Clear kerns, position, substitutions
    Print("Clear kerns, position, substitutions")
    RemoveAllKerns()

    lookups = GetLookups("GSUB"); numlookups = SizeOf(lookups); j = 0
    while (j < numlookups)
        if (j == 8)
            Print("Remove " + lookups[j])
            RemoveLookup(lookups[j])
        endif
        j++
    endloop

    # lookups = GetLookups("GPOS"); numlookups = SizeOf(lookups); j = 0
    # while (j < numlookups)
    #     Print("Remove GPOS_" + lookups[j])
    #     RemoveLookup(lookups[j])
    #     j++
    # endloop

# Clear instructions, hints
    Print("Clear instructions, hints")
    SelectWorthOutputting()
    ClearInstrs()
    ClearHints()

    Print("Correct stroke direction")
    CorrectDirection()

# --------------------------------------------------

    Print("Edit numbers")
# 0 (スター0にする)
    Select(0u002b); Copy() # +
    Select(65552);  Paste() # Temporary glyph
    Scale(40)
    Copy()
    Select(0u0030) # 0
    PasteWithOffset(0, 110)
    Select(65552);  Clear() # Temporary glyph

# ０ (スター0にする)
    Select(0u002b); Copy() # +
    Select(65552);  Paste() # Temporary glyph
    Scale(40)
    Copy()
    Select(0uff10) # 全角０
    PasteWithOffset(155, 110)
    Select(65552);  Clear() # Temporary glyph

    Print("Edit alphabets")
# I (セリフを付ける)
    Select(0u002d); Copy() # -
    Select(65552);  Paste() # Temporary glyph
    Scale(100, 50)
    HFlip(); CorrectDirection()
    Rotate(-3)
    Copy()
    Select(0u0049) # I
    PasteWithOffset(-120, 480)

    Select(0u002d); Copy() # -
    Select(65552);  Paste() # Temporary glyph
    Scale(100, 50)
    Rotate(-3)
    Copy()
    Select(0u0049) # I
    PasteWithOffset(-20, -253)

    RemoveOverlap()
    SetWidth(372)
    Select(65552);  Clear() # Temporary glyph

# Ｉ (セリフを付ける)
    Select(0u0049); Copy() # I
    Select(0uff29) # 全角ｌ
    Clear()
    Paste()
    Move(315, 0)
    SetWidth(1000)

# l (つま先を追加する)
    Select(0u002d); Copy() # -
    Select(65552);  Paste() # Temporary glyph
    Scale(80, 50)
    Rotate(2)
    Copy()
    Select(0u006c) # l
    PasteWithOffset(8, -245)
    RemoveOverlap()
    Simplify()
    Move(-20, 0)
    SetWidth(321)
    Select(65552);  Clear() # Temporary glyph

# ｌ (つま先を追加する)
    Select(0u006c); Copy() # l
    Select(0uff4c) # 全角ｌ
    Clear()
    Paste()
    Move(361 -20, 0)
    SetWidth(1000)

    Print("Edit Symbols")
# * (拡大して下げる)
    Select(0u002a) # *
    Scale(120)
    Move(0, -316)
    SetWidth(500)

# .:．： (向きを変更)
    Select(0u002e) # .
    SelectMore(0u003a) # :
    SelectMore(0uff0e) # 全角．
    SelectMore(0uff1a) # 全角：
    VFlip()
    HFlip(); CorrectDirection()

# ,.:; (拡大)
    Select(0u002c) # ,
    SelectMore(0u002e) # .
    SelectMore(0u003a,0u003b) # :;
    Scale(110, 0, 0)

# ，．：； (拡大)
    Select(0uff0c) # 全角，
    SelectMore(0uff0e) # 全角．
    Scale(110, 190, 0)
    SetWidth(1000)

    Select(0uff1a,0uff1b) # 全角：；
    Scale(110, 500, 0)
    SetWidth(1000)

# { (波の先端をとがらせる)
    Select(0u003c); Copy() # <
    Select(65552);  Paste() # Temporary glyph
    Select(0u25a0); Copy() # Black square
    Select(65552);  PasteWithOffset(-690, 0) # Temporary glyph
    OverlapIntersect()
    Copy()
    Select(0u007b) # {
    PasteWithOffset(-44, 60)
    RemoveOverlap()
    Simplify()
    SetWidth(400)
    Select(65552);  Clear() # Temporary glyph

# { (波の先端をとがらせる)
    Select(0u007b); Copy() # {
    Select(0uff5b); # 全角｛
    Clear()
    Paste()
    Move(571, 41)
    Scale(100, 92)
    SetWidth(1000)

# } (波の先端をとがらせる)
    Select(0u003e); Copy() # >
    Select(65552);  Paste() # Temporary glyph
    Select(0u25a0); Copy() # Black square
    Select(65552);  PasteWithOffset(379, 0) # Temporary glyph
    OverlapIntersect()
    Copy()
    Select(0u007d) # }
    PasteWithOffset(-246, 60)
    RemoveOverlap()
    Simplify()
    SetWidth(400)
    Select(65552);  Clear() # Temporary glyph

# } (波の先端をとがらせる)
    Select(0u007d); Copy() # }
    Select(0uff5d); # 全角｝
    Clear()
    Paste()
    Move(29, 41)
    Scale(100, 92)
    SetWidth(1000)

# | (下げる)
    Select(0u007c) # |
    Move(0, -112)

# 文字幅調整
    if ("${draft_flag}" == "false")
        Print("Narrows some glyph width (it may take a few minutes)")
        Select(0u0000, 0u007f) # 基本ラテン文字
        SelectMore(0u0174) # Ŵ
        SelectMore(0u0175) # ŵ
        SelectMore(0u0271) # ɱ
        SelectMore(0u1d6f) # ᵯ
        SelectMore(0u1d86) # ᶆ
        SelectMore(0u1e3e) # Ḿ
        SelectMore(0u1e3f) # ḿ
        SelectMore(0u1e40) # Ṁ
        SelectMore(0u1e41) # ṁ
        SelectMore(0u1e42) # Ṃ
        SelectMore(0u1e43) # ṃ
        SelectMore(0u1e80) # Ẁ
        SelectMore(0u1e81) # ẁ
        SelectMore(0u1e82) # Ẃ
        SelectMore(0u1e83) # ẃ
        SelectMore(0u1e84) # Ẅ
        SelectMore(0u1e85) # ẅ
        SelectMore(0u1e86) # Ẇ
        SelectMore(0u1e87) # ẇ
        SelectMore(0u1e88) # Ẉ
        SelectMore(0u1e89) # ẉ
        SelectMore(0u1e98) # ẘ
        SelectMore(0u2c6e) # Ɱ
        SelectMore(0u2c72) # Ⱳ
        SelectMore(0u2c73) # ⱳ
        SelectMore(0uab3a) # ꬺ
        foreach
            if (WorthOutputting())
                glyph_width = GlyphInfo("Width")
                Move(${width_expand}, 0)
                SetWidth(glyph_width + ${width_expand} + ${width_expand})
            endif
        endloop

        SelectWorthOutputting()
        SelectFewer(0u0000, 0u007f) # 基本ラテン文字
        SelectFewer(0u0174) # Ŵ
        SelectFewer(0u0175) # ŵ
        SelectFewer(0u0271) # ɱ
        SelectFewer(0u1d6f) # ᵯ
        SelectFewer(0u1d86) # ᶆ
        SelectFewer(0u1e3e) # Ḿ
        SelectFewer(0u1e3f) # ḿ
        SelectFewer(0u1e40) # Ṁ
        SelectFewer(0u1e41) # ṁ
        SelectFewer(0u1e42) # Ṃ
        SelectFewer(0u1e43) # ṃ
        SelectFewer(0u1e80) # Ẁ
        SelectFewer(0u1e81) # ẁ
        SelectFewer(0u1e82) # Ẃ
        SelectFewer(0u1e83) # ẃ
        SelectFewer(0u1e84) # Ẅ
        SelectFewer(0u1e85) # ẅ
        SelectFewer(0u1e86) # Ẇ
        SelectFewer(0u1e87) # ẇ
        SelectFewer(0u1e88) # Ẉ
        SelectFewer(0u1e89) # ẉ
        SelectFewer(0u1e98) # ẘ
        SelectFewer(0u2c6e) # Ɱ
        SelectFewer(0u2c72) # Ⱳ
        SelectFewer(0u2c73) # ⱳ
        SelectFewer(0uab3a) # ꬺ
        foreach
            glyph_width = GlyphInfo("Width")
            if (glyph_width <= ${width_threshold})
                Move(${width_expand}, 0)
                SetWidth(glyph_width + ${width_expand} + ${width_expand})
            endif
        endloop

        Select(0u0000, 0u007f) # 基本ラテン文字
        SelectMore(0u0174) # Ŵ
        SelectMore(0u0175) # ŵ
        SelectMore(0u0271) # ɱ
        SelectMore(0u1d6f) # ᵯ
        SelectMore(0u1d86) # ᶆ
        SelectMore(0u1e3e) # Ḿ
        SelectMore(0u1e3f) # ḿ
        SelectMore(0u1e40) # Ṁ
        SelectMore(0u1e41) # ṁ
        SelectMore(0u1e42) # Ṃ
        SelectMore(0u1e43) # ṃ
        SelectMore(0u1e80) # Ẁ
        SelectMore(0u1e81) # ẁ
        SelectMore(0u1e82) # Ẃ
        SelectMore(0u1e83) # ẃ
        SelectMore(0u1e84) # Ẅ
        SelectMore(0u1e85) # ẅ
        SelectMore(0u1e86) # Ẇ
        SelectMore(0u1e87) # ẇ
        SelectMore(0u1e88) # Ẉ
        SelectMore(0u1e89) # ẉ
        SelectMore(0u1e98) # ẘ
        SelectMore(0u2c6e) # Ɱ
        SelectMore(0u2c72) # Ⱳ
        SelectMore(0u2c73) # ⱳ
        SelectMore(0uab3a) # ꬺ
        foreach
            if (WorthOutputting())
                SetGlyphClass("none") # ついでにグリフクラスをなしにする(表示被り対策)
                glyph_width = GlyphInfo("Width")
                if (glyph_width == 0)
                    SetWidth(0)
                elseif (glyph_width <= ${width_hankaku})
                    Move(${width_hankaku} / 2 - glyph_width / 2, 0)
                    SetWidth(${width_hankaku})
                else
                    temp = 100 * ${width_hankaku} / glyph_width
                    Scale(temp, 100, 0, 0)
                    if (0 < ${weight_narrow})
                        ChangeWeight((100 - temp) / ${weight_narrow} + 1); CorrectDirection()
                    endif
                    Move(${width_hankaku} / 2 - GlyphInfo("Width") / 2, 0)
                    SetWidth(${width_hankaku})
                endif
            endif
        endloop

        Select(0u0080, 0u1fff)
        SelectFewer(0u0174) # Ŵ
        SelectFewer(0u0175) # ŵ
        SelectFewer(0u0271) # ɱ
        SelectFewer(0u1d6f) # ᵯ
        SelectFewer(0u1d86) # ᶆ
        SelectFewer(0u1e3e) # Ḿ
        SelectFewer(0u1e3f) # ḿ
        SelectFewer(0u1e40) # Ṁ
        SelectFewer(0u1e41) # ṁ
        SelectFewer(0u1e42) # Ṃ
        SelectFewer(0u1e43) # ṃ
        SelectFewer(0u1e80) # Ẁ
        SelectFewer(0u1e81) # ẁ
        SelectFewer(0u1e82) # Ẃ
        SelectFewer(0u1e83) # ẃ
        SelectFewer(0u1e84) # Ẅ
        SelectFewer(0u1e85) # ẅ
        SelectFewer(0u1e86) # Ẇ
        SelectFewer(0u1e87) # ẇ
        SelectFewer(0u1e88) # Ẉ
        SelectFewer(0u1e89) # ẉ
        SelectFewer(0u1e98) # ẘ
        foreach
            if (WorthOutputting())
                glyph_width = GlyphInfo("Width")
                if (glyph_width == 0)
                    SetWidth(0)
                elseif (glyph_width <= ${width_hankaku})
                    Move(${width_hankaku} / 2 - glyph_width / 2, 0)
                    SetWidth(${width_hankaku})
                elseif (glyph_width <= ${width_threshold})
                    temp = 100 * ${width_hankaku} / glyph_width
                    Scale(temp, 100, 0, 0)
                    if (0 < ${weight_narrow})
                        ChangeWeight((100 - temp) / ${weight_narrow} + 1); CorrectDirection()
                    endif
                    Move(${width_hankaku} / 2 - GlyphInfo("Width") / 2, 0)
                    SetWidth(${width_hankaku})
                elseif (glyph_width <= ${width_zenkaku})
                    Move(${width_zenkaku} / 2 - glyph_width / 2, 0)
                    SetWidth(${width_zenkaku})
                else
                    Scale(100 * ${width_zenkaku} / glyph_width, 100, 0, 0)
                    Move(${width_zenkaku} / 2 - GlyphInfo("Width") / 2, 0)
                    SetWidth(${width_zenkaku})
                endif
            endif
        endloop

        Select(0u2001) # em quad
        SelectMore(0u2003) # em space
        foreach
            if (WorthOutputting())
                SetWidth(${width_zenkaku})
            endif
        endloop

        Select(0u2000) # en quad
        SelectMore(0u2002) # en space
        SelectMore(0u2004) # three-per-em space
        SelectMore(0u2005) # four-per-em space
        SelectMore(0u2006) # six-per-em space
        SelectMore(0u2007) # figure space
        SelectMore(0u2008) # punctuation space
        SelectMore(0u2009) # thin space
        SelectMore(0u200a) # hair space
        SelectMore(0u202f) # narrow no-break space
        SelectMore(0u205f) # medium mathematical space
        foreach
            if (WorthOutputting())
                SetWidth(${width_hankaku})
            endif
        endloop

        Select(0u200c) # zero width non-joiner
        SelectMore(0u200d) # zero width joiner
        foreach
            if (WorthOutputting())
                SetWidth(0)
            endif
        endloop

        Select(0u2010, 0u2013) # Hypen - En dash
        foreach
            if (WorthOutputting())
                glyph_width = GlyphInfo("Width")
                if (glyph_width <= ${width_hankaku})
                    Move(${width_hankaku} / 2 - glyph_width / 2, 0)
                    SetWidth(${width_hankaku})
                else
                    Scale(100 * ${width_hankaku} / glyph_width, 100, 0, 0)
                    Move(${width_hankaku} / 2 - GlyphInfo("Width") / 2, 0)
                    SetWidth(${width_hankaku})
                endif
            endif
        endloop

        Select(0u2014, 0u2015) # Em dash, Horizontal bar
        foreach
            if (WorthOutputting())
                glyph_width = GlyphInfo("Width")
                if (glyph_width <= ${width_zenkaku})
                    Move(${width_zenkaku} / 2 - glyph_width / 2, 0)
                    SetWidth(${width_zenkaku})
                else
                    Scale(100 * ${width_zenkaku} / glyph_width, 100, 0, 0)
                    Move(${width_zenkaku} / 2 - GlyphInfo("Width") / 2, 0)
                    SetWidth(${width_zenkaku})
                endif
            endif
        endloop

        Select(0u2010, 0u2fff)
        SelectFewer(0u2c6e) # Ɱ
        SelectFewer(0u2c72) # Ⱳ
        SelectFewer(0u2c73) # ⱳ
        foreach
            if (WorthOutputting())
                glyph_width = GlyphInfo("Width")
                if (glyph_width == 0)
                    SetWidth(0)
                elseif (glyph_width <= ${width_hankaku})
                    Move(${width_hankaku} / 2 - glyph_width / 2, 0)
                    SetWidth(${width_hankaku})
                elseif (glyph_width <= ${width_threshold})
                    temp = 100 * ${width_hankaku} / glyph_width
                    Scale(temp, 100, 0, 0)
                    if (0 < ${weight_narrow})
                        ChangeWeight((100 - temp) / ${weight_narrow} + 1); CorrectDirection()
                    endif
                    Move(${width_hankaku} / 2 - GlyphInfo("Width") / 2, 0)
                    SetWidth(${width_hankaku})
                elseif (glyph_width <= ${width_zenkaku})
                    Move(${width_zenkaku} / 2 - glyph_width / 2, 0)
                    SetWidth(${width_zenkaku})
                else
                    Scale(100 * ${width_zenkaku} / glyph_width, 100, 0, 0)
                    Move(${width_zenkaku} / 2 - GlyphInfo("Width") / 2, 0)
                    SetWidth(${width_zenkaku})
                endif
            endif
        endloop

        Select(0u3000) # Ideographic space
        SetWidth(${width_zenkaku})

        Select(0u3001, 0uff60)
        SelectFewer(0uab3a) # ꬺ
        foreach
            if (WorthOutputting())
                glyph_width = GlyphInfo("Width")
                if (glyph_width == 0)
                    SetWidth(0)
                elseif (glyph_width <= ${width_zenkaku})
                    Move(${width_zenkaku} / 2 - glyph_width / 2, 0)
                    SetWidth(${width_zenkaku})
                else
                    Scale(100 * ${width_zenkaku} / glyph_width, 100, 0, 0)
                    Move(${width_zenkaku} / 2 - GlyphInfo("Width") / 2, 0)
                    SetWidth(${width_zenkaku})
                endif
            endif
        endloop

        Select(0uff61, 0uff9f) # 半角形
        foreach
            if (WorthOutputting())
                glyph_width = GlyphInfo("Width")
                if (glyph_width == 0)
                    SetWidth(0)
                elseif (glyph_width <= ${width_hankaku})
                    Move(${width_hankaku} / 2 - glyph_width / 2, 0)
                    SetWidth(${width_hankaku})
                else
                    temp = 100 * ${width_hankaku} / glyph_width
                    Scale(temp, 100, 0, 0)
                    if (0 < ${weight_narrow})
                        ChangeWeight((100 - temp) / ${weight_narrow} + 1); CorrectDirection()
                    endif
                    Move(${width_hankaku} / 2 - GlyphInfo("Width") / 2, 0)
                    SetWidth(${width_hankaku})
                endif
            endif
        endloop

        Select(0uffa0, 0uffff)
        foreach
            if (WorthOutputting())
                glyph_width = GlyphInfo("Width")
                if (glyph_width == 0)
                    SetWidth(0)
                elseif (glyph_width <= ${width_zenkaku})
                    Move(${width_zenkaku} / 2 - glyph_width / 2, 0)
                    SetWidth(${width_zenkaku})
                else
                    Scale(100 * ${width_zenkaku} / glyph_width, 100, 0, 0)
                    Move(${width_zenkaku} / 2 - GlyphInfo("Width") / 2, 0)
                    SetWidth(${width_zenkaku})
                endif
            endif
        endloop

        SelectWorthOutputting()
        SelectFewer(0u0000, 0uffff)
        foreach
            if (WorthOutputting())
                glyph_width = GlyphInfo("Width")
                if (glyph_width == 0)
                    SetWidth(0)
                elseif (glyph_width <= ${width_hankaku})
                    Move(${width_hankaku} / 2 - glyph_width / 2, 0)
                    SetWidth(${width_hankaku})
                elseif (glyph_width <= ${width_threshold})
                    temp = 100 * ${width_hankaku} / glyph_width
                    Scale(temp, 100, 0, 0)
                    if (0 < ${weight_narrow})
                        ChangeWeight((100 - temp) / ${weight_narrow} + 1); CorrectDirection()
                    endif
                    Move(${width_hankaku} / 2 - GlyphInfo("Width") / 2, 0)
                    SetWidth(${width_hankaku})
                elseif (glyph_width <= ${width_zenkaku})
                    Move(${width_zenkaku} / 2 - glyph_width / 2, 0)
                    SetWidth(${width_zenkaku})
                else
                    Scale(100 * ${width_zenkaku} / glyph_width, 100, 0, 0)
                    Move(${width_zenkaku} / 2 - GlyphInfo("Width") / 2, 0)
                    SetWidth(${width_zenkaku})
                endif
            endif
        endloop
    endif

# ss・sv 対応
    Print("Add cv lookups")
    lookups = GetLookups("GSUB"); numlookups = SizeOf(lookups)
    lookupName = "'cv01' 異体字1"
    AddLookup(lookupName, "gsub_single", 0, [["cv01",[["DFLT",["dflt"]],["kana",["dflt"]]]]], lookups[numlookups - 1])
    lookupSub = lookupName + "サブテーブル"
    AddLookupSubtable(lookupName, lookupSub)

    Select(0uf8fe) # 可視化した全角スペース
    glyphName = GlyphInfo("Name")
    Select(0u3000) # 全角スペース
    AddPosSub(lookupSub, glyphName)

    Print("Add ss lookups")
    lookups = GetLookups("GSUB"); numlookups = SizeOf(lookups)
    lookupName = "'ss01' スタイルセット1"
    AddLookup(lookupName, "gsub_single", 0, [["ss01",[["DFLT",["dflt"]],["kana",["dflt"]]]]], lookups[numlookups - 1])
    lookupSub = lookupName + "サブテーブル"
    AddLookupSubtable(lookupName, lookupSub)

    Select(0uf8fe) # 可視化した全角スペース
    glyphName = GlyphInfo("Name")
    Select(0u3000) # 全角スペース
    AddPosSub(lookupSub, glyphName)

# 半角文字チェック
    if ("${check_half_flag}" == "true")
        Select(0u002f); Copy() # Solidus
        SelectWorthOutputting()
        foreach
            if (GlyphInfo("Width") == ${width_hankaku})
                PasteWithOffset(150, -150)
            endif
        endloop
    endif

# --------------------------------------------------

# Proccess before saving
    Print("Process before saving")
    if (0 < SelectIf(".notdef"))
        Clear(); DetachAndRemoveGlyphs()
    endif
    RemoveDetachedGlyphs()
    SelectWorthOutputting()
    # RemoveOverlap()
    RoundToInt()
    # AutoHint()
    # AutoInstr()
    SetGasp(65535, 15) # Windows のジャギー対策

# --------------------------------------------------

# Save custom font
    if (fontfamilysuffix != "")
        Print("Save " + fontfamily + fontfamilysuffix + "-" + fontstyle_list[i] + ".ttf")
        Generate(fontfamily + fontfamilysuffix + "-" + fontstyle_list[i] + ".ttf", "", 0x04)
        # Generate(fontfamily + fontfamilysuffix + "-" + fontstyle_list[i] + ".ttf", "", 0x84)
    else
        Print("Save " + fontfamily + "-" + fontstyle_list[i] + ".ttf")
        Generate(fontfamily + "-" + fontstyle_list[i] + ".ttf", "", 0x04)
        # Generate(fontfamily + "-" + fontstyle_list[i] + ".ttf", "", 0x84)
    endif
    Close()
    Print("")

    i += 1
endloop

Quit()
_EOT_

################################################################################
# Generate custom fonts
################################################################################

# FontForge スクリプト実行
$fontforge_command -script ${tmpdir}/${custom_font_generator} \
    2> $redirection_stderr || exit 4

# ttx ファイルを削除
rm -f ${font_familyname}*.ttx ${font_familyname}*.ttx.bak

# フォントがあるかチェック
fontName_ttf=$(find . -maxdepth 1 -name "${font_familyname}*.ttf" | head -n 1)
if [ -z "${fontName_ttf}" ]; then
    echo "Error: ${font_familyname} not found" >&2
    exit 1
fi

# テーブル更新 ----------
find . -maxdepth 1 -not -name "*.*.ttf" | \
grep -e "${font_familyname}.*\.ttf$" | while read P
do
    ttx -t name -t head -t OS/2 -t post -t hmtx -t hhea "$P" # フォントスタイル判定のため、name テーブルも取得

    # head, OS/2 (フォントスタイルを修正、Oblique の場合 Italic のフラグも立てた方がよい)
    if [ "$(grep -m 1 "Bold Oblique" "${P%%.ttf}.ttx")" ]; then
        sed -i.bak -e 's,macStyle value="........ ........",macStyle value="00000000 00000011",' "${P%%.ttf}.ttx"
        sed -i.bak -e 's,fsSelection value="........ ........",fsSelection value="00000011 10100001",' "${P%%.ttf}.ttx"
    elif [ "$(grep -m 1 "Oblique" "${P%%.ttf}.ttx")" ]; then
        sed -i.bak -e 's,macStyle value="........ ........",macStyle value="00000000 00000010",' "${P%%.ttf}.ttx"
        sed -i.bak -e 's,fsSelection value="........ ........",fsSelection value="00000011 10000001",' "${P%%.ttf}.ttx"
    elif [ "$(grep -m 1 "Bold" "${P%%.ttf}.ttx")" ]; then
        sed -i.bak -e 's,macStyle value="........ ........",macStyle value="00000000 00000001",' "${P%%.ttf}.ttx"
        sed -i.bak -e 's,fsSelection value="........ ........",fsSelection value="00000001 10100000",' "${P%%.ttf}.ttx"
    elif [ "$(grep -m 1 "Regular" "${P%%.ttf}.ttx")" ]; then
        sed -i.bak -e 's,macStyle value="........ ........",macStyle value="00000000 00000000",' "${P%%.ttf}.ttx"
        sed -i.bak -e 's,fsSelection value="........ ........",fsSelection value="00000001 11000000",' "${P%%.ttf}.ttx"
    fi

    # head (フォントの情報を修正)
    sed -i.bak -e "s,fontRevision value=\".*\",fontRevision value=\"${font_version%.*}\"," "${P%%.ttf}.ttx"
    sed -i.bak -e 's,flags value="........ ........",flags value="00000000 00000011",' "${P%%.ttf}.ttx"

    # OS/2 (全体のWidthを修正)
    sed -i.bak -e "s,xAvgCharWidth value=\".*\",xAvgCharWidth value=\"${width_xAvg_char}\"," "${P%%.ttf}.ttx"

    # post (等幅フォントであることを示す)
    sed -i.bak -e 's,isFixedPitch value=".",isFixedPitch value="1",' "${P%%.ttf}.ttx"

    if [ "${draft_flag}" = "false" ]; then
        # hmtx (Widthのブレを修正)
        sed -i.bak -e "s,width=\".\",width=\"${width_zero}\"," "${P%%.ttf}.ttx" # zero width
        sed -i.bak -e "s,width=\"3..\",width=\"${width_hankaku}\"," "${P%%.ttf}.ttx" # .notdef
        sed -i.bak -e "s,width=\"4..\",width=\"${width_hankaku}\"," "${P%%.ttf}.ttx" # 半角
        sed -i.bak -e "s,width=\"5..\",width=\"${width_hankaku}\"," "${P%%.ttf}.ttx"
        sed -i.bak -e "s,width=\"6..\",width=\"${width_hankaku}\"," "${P%%.ttf}.ttx"
        sed -i.bak -e "s,width=\"7..\",width=\"${width_hankaku}\"," "${P%%.ttf}.ttx"
        sed -i.bak -e "s,width=\"8..\",width=\"${width_zenkaku}\"," "${P%%.ttf}.ttx" # 全角
        sed -i.bak -e "s,width=\"9..\",width=\"${width_zenkaku}\"," "${P%%.ttf}.ttx"
        sed -i.bak -e "s,width=\"1...\",width=\"${width_zenkaku}\"," "${P%%.ttf}.ttx"
    fi

    # hhea (最大Widthの修正)
    sed -i.bak -e "s,advanceWidthMax value=\".*\",advanceWidthMax value=\"${width_zenkaku}\"," "${P%%.ttf}.ttx"

    # テーブル更新
    mv "$P" "${P%%.ttf}.orig.ttf"
    ttx -m "${P%%.ttf}.orig.ttf" "${P%%.ttf}.ttx"
    echo
done
rm -f ${font_familyname}*.orig.ttf
rm -f ${font_familyname}*.ttx.bak

# Remove temporary directory
if [ "${leaving_tmp_flag}" = "false" ]; then
    remove_temp
    echo
fi

# 完成したフォントを移動
if [ "${draft_flag}" = "false" ] && [ "${check_half_flag}" = "false" ]; then
    echo "Move customized fonts"
    echo
    mkdir -p "${build_fonts_dir}/${font_familyname}${font_familyname_suffix}"
    mv -f ${font_familyname}${font_familyname_suffix}*.ttf "${build_fonts_dir}/${font_familyname}${font_familyname_suffix}/."
fi

# Exit
echo "Finished generating ${font_familyname} ${font_familyname_suffix}."
echo
exit 0
