#!/usr/bin/env bash
set -e

# ログをファイル出力させる場合は有効にする (<< "#LOG" をコメントアウトさせる)
<< "#LOG"
LOG_OUT=/tmp/run_ff_ttx.log
LOG_ERR=/tmp/run_ff_ttx_err.log
exec 1> >(tee -a $LOG_OUT)
exec 2> >(tee -a $LOG_ERR)
#LOG

# ./benishijimi_generator.sh -c
# ./cueyen_generator.sh -c
# ./garagga_generator.sh -c
# ./mogusa_generator.sh -c
# ./potori_generator.sh -c
# ./syukuzen_generator.sh -c
# ./tochinoki_generator.sh -c
# ./yuseimarker_generator.sh -c

./benishijimi_generator.sh
./cueyen_generator.sh
./garagga_generator.sh
./mogusa_generator.sh
./potori_generator.sh
./syukuzen_generator.sh
./tochinoki_generator.sh
./yuseimarker_generator.sh

./benishijimi_generator.sh -x
./cueyen_generator.sh -x
./garagga_generator.sh -x
./mogusa_generator.sh -x
./potori_generator.sh -x
./syukuzen_generator.sh -x
./tochinoki_generator.sh -x
./yuseimarker_generator.sh -x

echo
echo "Succeeded in generating all custom fonts!"
echo

exit 0
