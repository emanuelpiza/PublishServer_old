#!/bin/bash

equipe="$1"
dia=$(date "--date=${dataset_date} -1 day" +%Y%m%d)
dia_pasta=$(date "--date=${dataset_date} -1 day" +%Y-%m-%d)
horario="$2"
duracao="$3"
trechos=$((duracao/30))

for(( cont=0; cont<trechos; cont++ ))
do
   minutos=$((36*$cont))
   horamin=$(date -d "$horario today + $minutos minutes" +'%H%M')
   ffmpeg -i ./${dia_pasta}/001/HDCVI_ch1_main_${dia}${horamin}* -vf "crop=1400:1080:0:0" ./${dia_pasta}/ch1_$cont.mp4
   ffmpeg -i ./${dia_pasta}/002/HDCVI_ch2_main_${dia}${horamin}* -vf "crop=1400:1080:460:0" ./${dia_pasta}/ch2_$cont.mp4
done

printf "file '.%s'\n" ./${dia_pasta}/ch1_* > ./${dia_pasta}/ch1.txt & wait

ffmpeg -f concat -i ./${dia_pasta}/ch1.txt -c copy ./${dia_pasta}/channel1.mp4 & wait

printf "file '.%s'\n" ./${dia_pasta}/ch2_* > ./${dia_pasta}/ch2.txt & wait

ffmpeg -f concat -i ./${dia_pasta}/ch2.txt -c copy ./${dia_pasta}/channel2.mp4 & wait

ffmpeg -i  ./${dia_pasta}/channel2.mp4 -i  ./${dia_pasta}/channel2.mp4 -filter_complex "[0:v:0]pad=iw*2:ih[bg]; [bg][1:v:0]overlay=w" ./${dia_pasta}/$dia.mp4

python ./upload/upload_video.py --file=./${dia_pasta}/$dia.mp4 --title="$equipe $dia" --description="Jogo no Paradiso Futebol Society" --keywords="futebol, futebol society" --category=17 --privacyStatus="unlisted" 

 ffmpeg -i ./${dia_pasta}/channel1.mp4 -vf "crop=1400:787:0:150" ./${dia_pasta}/channel1_youtube.mp4

 ffmpeg -i ./${dia_pasta}/channel2.mp4 -vf "crop=1400:787:0:150" ./${dia_pasta}/channel2_youtube.mp4

python ./upload/upload_video.py --file=./${dia_pasta}/channel1_youtube.mp4 --title="Esportes_Co $equipe $dia Esquerda" --description="Jogo no Paradiso Futebol Society" --keywords="futebol, futebol society" --category=17 --privacyStatus="unlisted" & wait

python ./upload/upload_video.py --file=./${dia_pasta}/channel2_youtube.mp4 --title="Esportes_Co $equipe $dia Direita" --description="Jogo no Paradiso Futebol Society" --keywords="futebol, futebol society" --category=17 --privacyStatus="unlisted"
