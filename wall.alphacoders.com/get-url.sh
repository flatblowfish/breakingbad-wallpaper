###########################################################
# 1. 下载网页
###########################################################
#
# https://wall.alphacoders.com/by_sub_category.php?id=146143&name=Breaking+Bad+Wallpapers&quickload=201&page=7
#
curl "https://wall.alphacoders.com/by_sub_category.php?id=146143&name=Breaking+Bad+Wallpapers" >> download.html
for (( i=2; i <= 7; i++ )); do
    curl "https://wall.alphacoders.com/by_sub_category.php?id=146143&name=Breaking+Bad+Wallpapers&quickload=201&page=${i}" >> download.html
done
###########################################################
# 2. 获取下载链接，去重，保存
###########################################################
#
# https://images6.alphacoders.com/321/321927.jpg
# https://images6.alphacoders.com/321/thumbbig-321927.jpg
# https://images2.alphacoders.com/591/591596.jpg
# https://images2.alphacoders.com/591/thumbbig-591596.jpg
#
cat download.html | grep "img-responsive big-thumb" | gawk 'BEGIN{FS="\""} {print ""$10}' | sed 's/thumbbig-//' | sort | uniq | wc -l > url-count.txt
#
cat download.html | grep "img-responsive big-thumb" | gawk 'BEGIN{FS="\""} {print ""$10}' | sed 's/thumbbig-//' | sort | uniq  > url.txt
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
