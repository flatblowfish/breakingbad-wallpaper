###########################################################
# 1. 下载网页
###########################################################
#
# curl https://wallpapersafari.com/breaking-bad-iphone-wallpaper -o download.html
###########################################################
# 2. 获取下载链接，去重，保存
###########################################################
#
# https://wallpaperbat.com/img/121845-breaking-bad-s4-aaron-paul-1-dvdbash-wordpress.jpg
#
cat download.html | grep "thumb ads_popup" | gawk 'BEGIN{FS="\""} {print "https://wallpaperbat.com"$10}' | sort | uniq | wc -l > url-count.txt
#
cat download.html | grep "thumb ads_popup" | gawk 'BEGIN{FS="\""} {print "https://wallpaperbat.com"$10}' | sort | uniq > url.txt
###########################################################
# 3. 下载文件
###########################################################
#
unset download_url
download_url[0]=''
count=1
while read line; do
    echo "Line ${count}: ${line}"
    download_url[${count}]="${line}"
    count=$[${count} + 1]
done < url.txt
count=$[${count} - 1]
echo "数组元素个数为: $((${#download_url[@]}-1))"
echo "第一个链接：${download_url[1]}"
echo "最后一个链接：${download_url[${count}]}"
#
mkdir -p downloads
rm -rf download-fail.log
for (( i=1; i <= ${count}; i++ )); do
    echo "${i}. downloading \"${download_url[${i}]}\""
    echo ${i} > download-cur.log
    wget ${download_url[${i}]} -P downloads
    if [ $? -ne 0 ]; then
        echo "${i}. wget ${download_url[${i}]}" >> download-fail.log
    fi
    #sleep $(($RANDOM%9+2))
    #if [ $((${i}%100)) -eq 0 ]; then
    #    sleep 20
    #fi
done
