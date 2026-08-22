#!/usr/bin/env bash
set -e

# ログをファイル出力させる場合は有効にする (<< "#LOG" をコメントアウトさせる)
<< "#LOG"
LOG_OUT=/tmp/run_ff_ttx.log
LOG_ERR=/tmp/run_ff_ttx_err.log
exec 1> >(tee -a $LOG_OUT)
exec 2> >(tee -a $LOG_ERR)
#LOG

./benishijimi_generator.sh
./marucue_generator.sh
./mogusa_generator.sh
./syukuzen_generator.sh
./tochinoki_generator.sh
./yuseimarker_generator.sh

echo
echo "Succeeded in generating all custom fonts!"
echo

exit 0
