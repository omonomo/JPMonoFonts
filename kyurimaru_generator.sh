#!/usr/bin/env bash

# Custom font generator for Kyuri Maru
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

font_familyname="Kyuri"
font_familyname_suffix="Maru"

font_version="1.0.0"
vendor_id="PfEd"

# Set filenames
origin_regular="KiwiMaru-Regular.ttf"
origin_bold=""
zenkaku_space="ZenkakuSpace.ttf"

# 著作権
copyright="Copyright (c) 2026 omonomo\n\n"
copyright="${copyright}\" + \"[Kiwi Maru]\nCopyright 2020 The Kiwi Maru Project Authors (https://github.com/Kiwi-KawagotoKajiru/Kiwi-Maru)\n\n"
copyright_license="SIL Open Font License Version 1.1 (http://scripts.sil.org/ofl)"

# name タグ用 (製造元、供給元、デザイナー、ライセンス)
name_manufacturer="omonomo"
name_vendor_url="https://github.com/omonomo/JPMonoFonts"
name_designer="Hiroki-Chan"
name_designer_url="https://kiwi-kawagoto.com"
name_license="SIL Open Font License, Version 1.1"
name_license_url="https://scripts.sil.org/OFL"
change_designer="false" # デザイナー情報の変更

em_ascent="880" # em値用 ※ win_ascent - typo_linegap / 2 が適正っぽい
em_descent="120" # win_descent - typo_linegap / 2 が適正っぽい
typo_ascent="${em_ascent}" # typo_ascent + typo_descent = em値にしないと縦書きで文字間隔が崩れる
typo_descent="${em_descent}" # 縦書きに対応させない場合、linegap = 0 で typo、win、hhea 全てを同じにするのが無難
typo_linegap="0" # win_ascent + win_descent = typo_ascent + typo_descent + typo_linegap
win_ascent="1160"
win_descent="288"
hhea_ascent="${win_ascent}"
hhea_descent="${win_descent}"
hhea_linegap="0"
change_metrics="false" # メトリクス情報の変更

# グリフ形状の情報
ibm_family="0x0505" # スラブ タイプライター
panose1=(2 8)
panose_regular_weight="4"
panose_bold_weight="8"
panose2=(9 4 5)
panose3=(2 2 2 4)

width_zero="0" # 文字幅ゼロ
width_xAvg_char="500" # フォントの半角文字幅の指定は常に全角の半分とする
width_hankaku="500" # 半角文字幅
width_threshold="880" # 半角全角判断文字幅
width_zenkaku="1000" # 全角文字幅
width_expand="15" # 幅広のグリフを縮める際の両端調整幅 (マイナスで文字拡大、プラスで縮小)
weight_narrow="4" # 幅広のグリフを縮める際のウェイト調整値 (正の数、小さいほど拡大、0で無効)

tmpdir_name="font_generator_tmpdir" # 一時保管ディレクトリ名
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

custom_font_generator="custom_font_generator.pe"

################################################################################
# Pre-process
################################################################################

# Print information message
cat << _EOT_

----------------------------
${font_familyname}${font_familyname_suffix:+ ${font_familyname_suffix}} generator
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
    panoseweight_list = [${panose_regular_weight}, ${panose_bold_weight}]
else
    input_list        = ["${input_regular}"]
    fontstyle_list    = ["Regular"]
    fontweight_list   = [400]
    panoseweight_list = [${panose_regular_weight}]
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
    SetOS2Value("IBMFamily",   ${ibm_family})
    SetPanose([${panose1[0]}, ${panose1[1]}, panoseweight_list[i], ${panose2[0]}, ${panose2[1]}, ${panose2[2]},\
               ${panose3[0]}, ${panose3[1]}, ${panose3[2]}, ${panose3[3]}])

# --------------------------------------------------

# Clear kerns, position, substitutions
    Print("Clear kerns, position, substitutions")
    RemoveAllKerns()

    lookups = GetLookups("GSUB"); numlookups = SizeOf(lookups); j = 0
    while (j < numlookups)
        if (j == 11)
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

    Print("Copy from hwid glyphs")
# 半角文字形をコピー (罫線のみ)
    Select("uni2500.half"); Copy(); Select("uni2500"); Paste()
    Select("uni2501.half"); Copy(); Select("uni2501"); Paste()
    Select("uni2502.half"); Copy(); Select("uni2502"); Paste()
    Select("uni2503.half"); Copy(); Select("uni2503"); Paste()
    Select("uni2504.half"); Copy(); Select("uni2504"); Paste()
    Select("uni2505.half"); Copy(); Select("uni2505"); Paste()
    Select("uni2506.half"); Copy(); Select("uni2506"); Paste()
    Select("uni2507.half"); Copy(); Select("uni2507"); Paste()
    Select("uni2508.half"); Copy(); Select("uni2508"); Paste()
    Select("uni2509.half"); Copy(); Select("uni2509"); Paste()
    Select("uni250A.half"); Copy(); Select("uni250A"); Paste()
    Select("uni250B.half"); Copy(); Select("uni250B"); Paste()
    Select("uni250C.half"); Copy(); Select("uni250C"); Paste()
    Select("uni250D.half"); Copy(); Select("uni250D"); Paste()
    Select("uni250E.half"); Copy(); Select("uni250E"); Paste()
    Select("uni250F.half"); Copy(); Select("uni250F"); Paste()
    Select("uni2510.half"); Copy(); Select("uni2510"); Paste()
    Select("uni2511.half"); Copy(); Select("uni2511"); Paste()
    Select("uni2512.half"); Copy(); Select("uni2512"); Paste()
    Select("uni2513.half"); Copy(); Select("uni2513"); Paste()
    Select("uni2514.half"); Copy(); Select("uni2514"); Paste()
    Select("uni2515.half"); Copy(); Select("uni2515"); Paste()
    Select("uni2516.half"); Copy(); Select("uni2516"); Paste()
    Select("uni2517.half"); Copy(); Select("uni2517"); Paste()
    Select("uni2518.half"); Copy(); Select("uni2518"); Paste()
    Select("uni2519.half"); Copy(); Select("uni2519"); Paste()
    Select("uni251A.half"); Copy(); Select("uni251A"); Paste()
    Select("uni251B.half"); Copy(); Select("uni251B"); Paste()
    Select("uni251C.half"); Copy(); Select("uni251C"); Paste()
    Select("uni251D.half"); Copy(); Select("uni251D"); Paste()
    Select("uni251E.half"); Copy(); Select("uni251E"); Paste()
    Select("uni251F.half"); Copy(); Select("uni251F"); Paste()
    Select("uni2520.half"); Copy(); Select("uni2520"); Paste()
    Select("uni2521.half"); Copy(); Select("uni2521"); Paste()
    Select("uni2522.half"); Copy(); Select("uni2522"); Paste()
    Select("uni2523.half"); Copy(); Select("uni2523"); Paste()
    Select("uni2524.half"); Copy(); Select("uni2524"); Paste()
    Select("uni2525.half"); Copy(); Select("uni2525"); Paste()
    Select("uni2526.half"); Copy(); Select("uni2526"); Paste()
    Select("uni2527.half"); Copy(); Select("uni2527"); Paste()
    Select("uni2528.half"); Copy(); Select("uni2528"); Paste()
    Select("uni2529.half"); Copy(); Select("uni2529"); Paste()
    Select("uni252A.half"); Copy(); Select("uni252A"); Paste()
    Select("uni252B.half"); Copy(); Select("uni252B"); Paste()
    Select("uni252C.half"); Copy(); Select("uni252C"); Paste()
    Select("uni252D.half"); Copy(); Select("uni252D"); Paste()
    Select("uni252E.half"); Copy(); Select("uni252E"); Paste()
    Select("uni252F.half"); Copy(); Select("uni252F"); Paste()
    Select("uni2530.half"); Copy(); Select("uni2530"); Paste()
    Select("uni2531.half"); Copy(); Select("uni2531"); Paste()
    Select("uni2532.half"); Copy(); Select("uni2532"); Paste()
    Select("uni2533.half"); Copy(); Select("uni2533"); Paste()
    Select("uni2534.half"); Copy(); Select("uni2534"); Paste()
    Select("uni2535.half"); Copy(); Select("uni2535"); Paste()
    Select("uni2536.half"); Copy(); Select("uni2536"); Paste()
    Select("uni2537.half"); Copy(); Select("uni2537"); Paste()
    Select("uni2538.half"); Copy(); Select("uni2538"); Paste()
    Select("uni2539.half"); Copy(); Select("uni2539"); Paste()
    Select("uni253A.half"); Copy(); Select("uni253A"); Paste()
    Select("uni253B.half"); Copy(); Select("uni253B"); Paste()
    Select("uni253C.half"); Copy(); Select("uni253C"); Paste()
    Select("uni253D.half"); Copy(); Select("uni253D"); Paste()
    Select("uni253E.half"); Copy(); Select("uni253E"); Paste()
    Select("uni253F.half"); Copy(); Select("uni253F"); Paste()
    Select("uni2540.half"); Copy(); Select("uni2540"); Paste()
    Select("uni2541.half"); Copy(); Select("uni2541"); Paste()
    Select("uni2542.half"); Copy(); Select("uni2542"); Paste()
    Select("uni2543.half"); Copy(); Select("uni2543"); Paste()
    Select("uni2544.half"); Copy(); Select("uni2544"); Paste()
    Select("uni2545.half"); Copy(); Select("uni2545"); Paste()
    Select("uni2546.half"); Copy(); Select("uni2546"); Paste()
    Select("uni2547.half"); Copy(); Select("uni2547"); Paste()
    Select("uni2548.half"); Copy(); Select("uni2548"); Paste()
    Select("uni2549.half"); Copy(); Select("uni2549"); Paste()
    Select("uni254A.half"); Copy(); Select("uni254A"); Paste()
    Select("uni254B.half"); Copy(); Select("uni254B"); Paste()

    Print("Edit numbers")
# 0 (スラッシュ0にする)
    Select("zero.zero"); Copy() # 半角スラッシュ0
    Select("zero"); Paste() # 0

# ０ (スラッシュ0にする)
    Select("zero.zero.full"); Copy() # スラッシュ0
    Select("uniFF10"); Paste() # 全角０

    Print("Edit Symbols")
# * (下げる)
    Select(0u002a) # *
    Move(0, -218)

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

# --------------------------------------------------

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
echo "Finished generating ${font_familyname}${font_familyname_suffix:+ ${font_familyname_suffix}}."
echo
exit 0
