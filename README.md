# 日本語フォント開発用途対応化計画

プログラミングフォントってもっと自由でもいいんじゃなかろうかというコンセプトの元、Google Fonts から6個の日本語フォントを厳選して等幅化しました。

## サンプル

### Benishijimi

素材フォント: [Zen Kurenaido](https://github.com/googlefonts/zen-kurenaido)
半角:全角比率 1:2

### MaruCue Pop

素材フォント: [Hachi Maru Pop](https://github.com/noriokanisawa/HachiMaruPop)
半角:全角比率 3:4

### Mogusa

素材フォント: [Yomogi](https://github.com/satsuyako/YomogiFont)
半角:全角比率 1:2

### SyukuZen

素材フォント: [Yuji Syuku](https://github.com/Kinutafontfactory/Yuji)
半角:全角比率 1:2

### Tochinoki Pop

素材フォント: [Mochiy Pop One](https://github.com/fontdasu/Mochiypop)
半角:全角比率 3:5

### Yusei Marker

素材フォント: [Yusei Magic](https://github.com/tanukifont/YuseiMagic)
半角:全角比率 3:5

## 各フォントの共通事項

- 生成スクリプトにより機械的に半角文字と全角文字に振り分け、サイズやウェイトを調整しました。
- 識別性向上のために手動で手を加えたグリフは横書き用の基本ラテン文字や全角形文字のみです。
- OpenTypeの "ss01" または "cv01" フィーチャータグを有効にすると全角スペースを可視化できます。

## フォント個別の改変内容

### Benishijimi

- ` のグリフクラスを「マーク」から「クラスなし」に変更しています。
- 手動で調整、改変したグリフ: 0 I * + \ ~ ´ (半角)、０ Ｉ (全角)
- 追加したグリフ: － ～ (全角)、可視化した全角スペース

### MaruCue Pop

- 手動で調整、改変したグリフ: 0 " ' , . ; : (半角)、０ ， ． ； ： 敲 寂 (全角)
- 追加したグリフ: 㪣 (全角)、可視化した全角スペース

### Mogusa

- OpenTypeの "liga" フィーチャーを削除しています。
- 手動で調整、改変したグリフ: 0 a j l * = (半角)、０ ｌ (全角)
- 追加したグリフ: 可視化した全角スペース

### SyukuZen

- OpenTypeの "liga" フィーチャーを削除しています。
- 手動で調整、改変したグリフ: 0 1 l # * (半角)、０ １ ｌ (全角)
- 追加したグリフ: 可視化した全角スペース

### Tochinoki Pop

- 手動で調整、改変したグリフ: 0 I * - , . ; : @ (半角)、０ Ｉ ， ． ； ： (全角)
- 追加したグリフ: ＂ ＃ ＄ ＇ ＊ － ＜ ＞ ＾ ＿ ｀ ｜ (全角)、可視化した全角スペース

### Yusei Marker

- 手動で調整、改変したグリフ: 0 l * - , . ; : " ' { } @ (半角)、０ ｌ ， ． ； ： ＂ ＇ ｛ ｝ (全角)
- 追加したグリフ: 可視化した全角スペース

## ライセンス

- 各フォントのライセンスは [SIL Open Font License Version 1.1](https://github.com/omonomo/JPMonoFonts/blob/main/OFL.txt) です。
- 素材フォントのライセンスにつきましては別途確認をお願いいたします。
- 生成スクリプトのライセンスは [MIT License](https://github.com/omonomo/JPMonoFonts/blob/main/LICENSE.txt) です。
- 生成スクリプトの一部に [ricty_generator-4.1.1.sh](https://rictyfonts.github.io) を使用しています。

## メモ

- 自作合成フォント[Cyroit](https://omonomo.github.io/Cyroit/)シリーズはいろいろとこだわりすぎたためフォントも生成スクリプトを肥大化してしまいました。
- 今回は肩の力を抜いて必要最低限と思われる改変のみを行っています。
- 自動生成で文字幅の統一化をしているため、縦線の太さのばらつきなど少し気になるところもありますので、あまりモニタに近づかないようお願いいたします。
