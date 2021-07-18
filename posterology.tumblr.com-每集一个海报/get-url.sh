###########################################################
# 1. 下载网页
###########################################################
#
# https://posterology.tumblr.com/tagged/Breaking+Bad/chrono/page/5
#
curl "https://posterology.tumblr.com/tagged/Breaking+Bad/chrono" >> download.html
for (( i=2; i <= 5; i++ )); do
    curl "https://posterology.tumblr.com/tagged/Breaking+Bad/chrono/page/${i}" >> download.html
done
###########################################################
# 2. 获取下载链接，去重，保存
###########################################################
#
# https://64.media.tumblr.com/7fc8c021913dc11650fe202753faab1e/tumblr_n0zdh9Y3af1slqxs4o1_1280.jpg
# 缺少S02E03
#
cat download.html | grep "alt=\"Breaking Bad" | gawk 'BEGIN{FS="\""} {print ""$2}' | sort | uniq | wc -l > url-count.txt
#
cat download.html | grep "alt=\"Breaking Bad" | gawk 'BEGIN{FS="\""} {print ""$2}' > url.txt
#
# 替换文件名的有特殊字符
cat download.html | grep "alt=\"Breaking Bad" | gawk 'BEGIN{FS="\""} {print ""$4}' | grep "&"
cat download.html | grep "alt=\"Breaking Bad" | gawk 'BEGIN{FS="\""} {print ""$4}' | sed -e 's! / !-!g;s!/ !-!g; s! /!-!g; s!&rsquo;!’!g; s!&hellip;!…!g; s!&aacute;!á!g;' | sed "s/&#039;/'/g" > name.txt
###########################################################
# 3. 下载文件
###########################################################
#
unset download_url
unset download_extension
download_url[0]=''
download_extension[0]=''
count=1
while read line; do
    echo "Line ${count}: ${line}"
    download_url[${count}]="${line}"
    download_extension[${count}]="${line##*.}"
    count=$[${count} + 1]
done < url.txt
count=$[${count} - 1]
echo ">> download_url"
echo "数组元素个数为: $((${#download_url[@]}-1))"
echo "第一个元素：${download_url[1]}"
echo "最后一个元素：${download_url[${count}]}"
echo ">> download_extension"
echo "数组元素个数为: $((${#download_extension[@]}-1))"
echo "第一个元素：${download_extension[1]}"
echo "最后一个元素：${download_extension[${count}]}"
#
unset download_name
download_name[0]=''
count=1
while read line; do
    echo "Line ${count}: ${line}"
    download_name[${count}]="${line}"
    count=$[${count} + 1]
done < name.txt
count=$[${count} - 1]
echo ">> download_name"
echo "数组元素个数为: $((${#download_name[@]}-1))"
echo "第一个元素：${download_name[1]}"
echo "最后一个元素：${download_name[${count}]}"
#
mkdir -p downloads
rm -rf download-fail.log
for (( i=1; i <= ${count}; i++ )); do
    echo "${i}. downloading \"${download_name[${i}]}\" \"${download_url[${i}]}\""
    echo ${i} > download-cur.log
    wget ${download_url[${i}]} -O "downloads/${download_name[${i}]}.${download_extension[${i}]}"
    if [ $? -ne 0 ]; then
        echo "${i}. wget ${download_url[${i}]}" >> download-fail.log
    fi
    #sleep $(($RANDOM%9+2))
    #if [ $((${i}%100)) -eq 0 ]; then
    #    sleep 20
    #fi
done
