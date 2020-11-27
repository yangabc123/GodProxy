#!/bin/sh

#alias echo_date='echo $(date +%Y年%m月%d日\ %X):'
alias echo_date='echo $(date "+%F %T"):'

LOGFILE="tmp/rulesupdate.log"
url_cjx="https://github.com/cjx82630/cjxlist/blob/master/cjx-annoyance.txt"
url_easylist="https://easylist-downloads.adblockplus.org/easylistchina.txt"
url_kp="https://raw.githubusercontent.com/houzi-/CDN/master/kp.dat"
url_kp_md5="https://raw.githubusercontent.com/houzi-/CDN/master/kp.dat.md5"
url_yhosts="https://raw.githubusercontent.com/VeleSila/yhosts/master/hosts"
url_kpr_our_rule="https://raw.githubusercontent.com/user1121114685/koolproxyR_rule_list/master/kpr_our_rule.txt"
url_kpr_our_rule2="https://raw.githubusercontent.com/ihuaer/koolproxy/master/dykpr.txt"
url_fanboy="https://secure.fanboy.co.nz/fanboy-annoyance.txt"
url_antiad="https://anti-ad.net/surge.txt"

#先清空以前的日志
cat /dev/null > $LOGFILE
    echo_date ------------------- 规则更新 ----------------------- >>$LOGFILE
	echo_date ==================================================== >>$LOGFILE
	echo_date 开始更新koolproxy的规则，请等待... >>$LOGFILE
	# 赋予文件夹权限 
	chmod -R 777 rules
	
	
	# update easylistchina中国简易列表 2.0
		echo_date " ---------------------------------------------------------------------------------------"  >>$LOGFILE
		for i in {1..5}; do
			wget --no-check-certificate --timeout=8 -qO - $url_easylist > tmp/easylistchina.txt
			#wget -4 -a tmp/upload/kpr_log.txt -O tmp/easylistchina.txt $url_easylist
			easylistchina_rule_nu_local=`grep -E -v "^!" tmp/easylistchina.txt | wc -l`
			if [ "$easylistchina_rule_nu_local" -gt 5000 ]; then
				break
			else
				echo_date easylistchina规则文件下载失败 >>$LOGFILE
				koolproxy_basic_easylist_failed=1
			fi
		done
		
	# update CJX's Annoyance List (反自我推广,移除anti adblock,防跟踪规则列表)是"EasyList China+EasyList" & "EasyPrivacy"的补充
		for i in {1..5}; do
			wget --no-check-certificate --timeout=8 -qO - $url_cjx > tmp/cjx-annoyance.txt
			cjx_rule_nu_local=`grep -E -v "^!" tmp/cjx-annoyance.txt | wc -l`
			if [ "$cjx_rule_nu_local" -gt 500 ]; then
				break
			else
				echo_date cjx-annoyance规则文件下载失败 >>$LOGFILE
				koolproxy_basic_cjx-annoyance_failed=1
			fi
		done
		
		# 将cjx-annoyance和easylistchina合二为ABP规则
		# expr 进行运算，将统计到的规则条数相加 如果条数大于 10000 条就说明下载完毕
		#easylistchina_rule_local=`expr $kpr_our_rule_nu_local + $cjx_rule_nu_local + $easylistchina_rule_nu_local`
		easylistchina_rule_local=`expr $cjx_rule_nu_local + $easylistchina_rule_nu_local`
		cat tmp/cjx-annoyance.txt >> tmp/easylistchina.txt
		rm tmp/cjx-annoyance.txt
		easylist_rules_local=`cat rules/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`
		easylist_rules_remote=`cat tmp/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`

		echo_date ABP规则的本地版本号： $easylist_rules_local >>$LOGFILE
		echo_date ABP规则的在线版本号： $easylist_rules_remote >>$LOGFILE
		if [ "$koolproxy_basic_easylist_failed" != "1" ]; then
			if [ "$easylistchina_rule_local" -gt 10000 ]; then
				if [ "$easylist_rules_local" != "$easylist_rules_remote" ]; then
					echo_date 检测到 ABP规则 已更新，现在开始更新... >>$LOGFILE
					echo_date 将临时的ABP规则文件移动到指定位置 >>$LOGFILE
					mv tmp/easylistchina.txt rules/easylistchina.txt
					koolproxy_https_ABP=1
				else
					echo_date 检测到 ABP规则本地版本号和在线版本号相同，那还更新个毛啊! >>$LOGFILE
				fi
			fi
		else
			echo_date ABP规则文件下载失败！>>$LOGFILE >>$LOGFILE
		fi
	
	# update kpr_our_rule
		for i in {1..5}; do
			#wget -4 -a tmp/upload/kpr_log.txt -O rules/kpr_our_rule.txt $kpr_our_rule
			wget --no-check-certificate --timeout=8 -qO - $url_kpr_our_rule > tmp/kpr_our_rule.txt
			kpr_our_rule_nu_local=`grep -E -v "^!" tmp/kpr_our_rule.txt | wc -l`
			if [ "$kpr_our_rule_nu_local" -gt 500 ]; then
				break
			else
				echo_date kpr_our_rule规则文件下载失败 >>$LOGFILE
				koolproxy_basic_kpr_our_rule_failed=1
			fi
		done
		
	# update kpr_our_rule2
		for i in {1..5}; do
			#wget -4 -a tmp/upload/kpr_log.txt -O rules/kpr_our_rule.txt $kpr_our_rule
			wget --no-check-certificate --timeout=8 -qO - $url_kpr_our_rule2 > tmp/kpr_our_rule2.txt
			kpr_our_rule2_nu_local=`grep -E -v "^!" tmp/kpr_our_rule2.txt | wc -l`
			if [ "$kpr_our_rule2_nu_local" -gt 500 ]; then
				break
			else
				echo_date kpr_our_rule2规则文件下载失败 >>$LOGFILE
				koolproxy_basic_kpr_our_rule2_failed=1
			fi
		done
		
		
	# 将kpr_our_rule和kpr_our_rule2合二为kpr_our_rule规则
		# expr 进行运算，将统计到的规则条数相加 如果条数大于 10000 条就说明下载完毕
		#easylistchina_rule_local=`expr $kpr_our_rule_nu_local + $cjx_rule_nu_local + $easylistchina_rule_nu_local`
		cat tmp/kpr_our_rule2.txt >> tmp/kpr_our_rule.txt
		rm tmp/kpr_our_rule2.txt
		mv tmp/kpr_our_rule.txt rules/kpr_our_rule.txt
	
		
		# update yhosts规则
		for i in {1..5}; do
			wget --no-check-certificate --timeout=8 -qO - $url_yhosts > tmp/yhosts.txt
			wget --no-check-certificate --timeout=8 -qO - $url_yhosts1 > tmp/tvbox.txt
			#wget -4 -a tmp/upload/kpr_log.txt -O tmp/yhosts.txt $url_yhosts
			#wget -4 -a tmp/upload/kpr_log.txt -O tmp/tvbox.txt $url_yhosts1
			cat tmp/tvbox.txt >> tmp/yhosts.txt
			yhosts_rules_local=`cat rules/yhosts.txt  | sed -n '1p' | cut -d "=" -f2`
			yhosts_rules_remote=`cat tmp/yhosts.txt | sed -n '1p' | cut -d "=" -f2`
			mobile_nu_local=`grep -E -v "^!" tmp/yhosts.txt | wc -l`
			echo_date yhosts规则本地版本号： $yhosts_rules_local >>$LOGFILE
			echo_date yhosts规则在线版本号： $yhosts_rules_remote >>$LOGFILE
			if [ "$mobile_nu_local" -gt 5000 ]; then
				if [ "$yhosts_rules_local" != "$yhosts_rules_remote" ]; then
					echo_date 检测到 yhosts规则 已更新，现在开始更新... >>$LOGFILE
					echo_date 将临时文件覆盖到原始yhosts文件 >>$LOGFILE
					mv tmp/yhosts.txt rules/yhosts.txt
					koolproxy_https_yhosts=1
					break
				else
					echo_date 检测到yhosts本地版本号和在线版本号相同，那还更新个毛啊! >>$LOGFILE
				fi
			else
				echo_date yhosts文件下载失败！ >>$LOGFILE
				koolproxy_basic_yhosts_failed=1
			fi
		done
	

	# update 视频规则
		for i in {1..5}; do
			kpr_video_md5=`md5sum rules/kp.dat | awk '{print $1}'`
			wget --no-check-certificate --timeout=8 -qO - $url_kp_md5 > tmp/kp.dat.md5
			#wget -4 -a tmp/upload/kpr_log.txt -O tmp/kp.dat.md5 $url_kp_md5
			kpr_video_new_md5=`cat tmp/kp.dat.md5 | sed -n '1p'`
			echo_date 远程视频规则md5：$kpr_video_new_md5 >>$LOGFILE
			echo_date 您本地视频规则md5：$kpr_video_md5 >>$LOGFILE

			if [ "$kpr_video_md5" != "$kpr_video_new_md5" ]; then
				echo_date 检测到新版视频规则.开始更新.......... >>$LOGFILE
				wget --no-check-certificate --timeout=8 -qO - $url_kp > tmp/kp.dat
				#wget -4 -a tmp/upload/kpr_log.txt -O tmp/kp.dat $url_kp
				kpr_video_download_md5=`md5sum tmp/kp.dat | awk '{print $1}'`
				echo_date 您下载的视频规则md5：$kpr_video_download_md5 >>$LOGFILE
				if [ "$kpr_video_download_md5" = "$kpr_video_new_md5" ]; then
					echo_date 将临时文件覆盖到原始 视频规则 文件 >>$LOGFILE
					mv tmp/kp.dat rules/kp.dat
					mv tmp/kp.dat.md5 rules/kp.dat.md5
					video_md5=$kpr_video_new_md5
					break
				else
					echo_date 视频规则md5校验不通过... >>$LOGFILE
				fi
			else
				video_md5=$kpr_video_md5
				echo_date 检测到 视频规则 本地版本号和在线版本号相同，那还更新个毛啊! >>$LOGFILE
			fi
		done
	

	# update fanboy规则
		for i in {1..5}; do
			wget --no-check-certificate --timeout=8 -qO - $url_fanboy > tmp/fanboy.txt
			fanboy_rules_local=`cat rules/fanboy.txt  | sed -n '3p'|awk '{print $3,$4}'`
			fanboy_rules_remote=`cat tmp/fanboy.txt  | sed -n '3p'|awk '{print $3,$4}'`
			fanboy_nu_local=`grep -E -v "^!" tmp/fanboy.txt | wc -l`
			echo_date fanboy规则本地版本号： $fanboy_rules_local >>$LOGFILE
			echo_date fanboy规则在线版本号： $fanboy_rules_remote >>$LOGFILE
			if [ "$fanboy_nu_local" -gt 15000 ]; then
				if [ "$fanboy_rules_local" != "$fanboy_rules_remote" ]; then
					echo_date 检测到新版本 fanboy规则 列表，开始更新... >>$LOGFILE
					echo_date 将临时文件覆盖到原始 fanboy规则 文件 >>$LOGFILE
					mv tmp/fanboy.txt rules/fanboy.txt
					koolproxy_https_fanboy=1
					break
				else
					echo_date 检测到 fanboy规则 本地版本号和在线版本号相同，那还更新个毛啊! >>$LOGFILE
				fi
			else
				echo_date fanboy规则 文件下载失败！ >>$LOGFILE
				koolproxy_basic_fanboy_failed=1
			fi
		done
	

	# update AntiAD规则
		for i in {1..5}; do
			wget --no-check-certificate --timeout=8 -qO - $url_antiad > tmp/antiad.txt
			antiad_rules_local=`cat rules/antiad.txt  | sed -n '2p' | cut -d "=" -f2`
			antiad_rules_remote=`cat tmp/antiad.txt  | sed -n '2p' | cut -d "=" -f2` 
			antiad_nu_local=`grep -E -v "^#" tmp/antiad.txt | wc -l`
			echo_date antiad规则本地版本号： $antiad_rules_local >>$LOGFILE
			echo_date antiad规则在线版本号： $antiad_rules_remote >>$LOGFILE
			if [ "$antiad_nu_local" -gt 5000 ]; then
				if [ "$antiad_rules_local" != "$antiad_rules_remote" ]; then
					echo_date 检测到新版本 antiad规则 列表，开始更新... >>$LOGFILE
					echo_date 将临时文件覆盖到原始 antiad规则 文件 >>$LOGFILE
					mv tmp/antiad.txt rules/antiad.txt
					koolproxy_https_antiad=1
					break
				else
					echo_date 检测到 antiad规则 本地版本号和在线版本号相同，那还更新个毛啊! >>$LOGFILE
				fi
			else
				echo_date antiad规则 文件下载失败！ >>$LOGFILE
				koolproxy_basic_antiad_failed=1
			fi
		done


	if [ "$koolproxy_https_fanboy" = "1" ]; then
		echo_date 正在优化 fanboy规则。。。。。 >>$LOGFILE
		# 删除导致KP崩溃的规则
		# 听说高手?都打的很多、这样才能体现技术
		sed -i '/^\$/d' rules/fanboy.txt
		sed -i '/\*\$/d' rules/fanboy.txt
		# 给三大视频网站放行 由kp.dat负责
		sed -i '/youku.com/d' rules/fanboy.txt
		sed -i '/iqiyi.com/d' rules/fanboy.txt
		sed -i '/qq.com/d' rules/fanboy.txt
		sed -i '/g.alicdn.com/d' rules/fanboy.txt
		sed -i '/tudou.com/d' rules/fanboy.txt
		sed -i '/gtimg.cn/d' rules/fanboy.txt
		# 给知乎放行
		sed -i '/zhihu.com/d' rules/fanboy.txt

		# 将规则转化成kp能识别的https
		cat rules/fanboy.txt | grep "^||" | sed 's#^||#||https://#g' >> rules/fanboy_https.txt
		# 移出https不支持规则domain=
		sed -i 's/\(,domain=\).*//g' rules/fanboy_https.txt
		sed -i 's/\(\$domain=\).*//g' rules/fanboy_https.txt
		sed -i 's/\(domain=\).*//g' rules/fanboy_https.txt
		sed -i '/\^$/d' rules/fanboy_https.txt
		sed -i '/\^\*\.gif/d' rules/fanboy_https.txt
		sed -i '/\^\*\.jpg/d' rules/fanboy_https.txt

		cat rules/fanboy.txt | grep "^||" | sed 's#^||#||http://#g' >> rules/fanboy_https.txt

		cat rules/fanboy.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> rules/fanboy_https.txt
		cat rules/fanboy.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> rules/fanboy_https.txt
		cat rules/fanboy.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> rules/fanboy_https.txt

		# 给github放行
		sed -i '/github/d' rules/fanboy_https.txt
		# 给api.twitter.com的https放行
		sed -i '/twitter.com/d' rules/fanboy_https.txt
		# 给facebook.com的https放行
		sed -i '/facebook.com/d' rules/fanboy_https.txt
		sed -i '/fbcdn.net/d' rules/fanboy_https.txt
		# 给 instagram.com 放行
		sed -i '/instagram.com/d' rules/fanboy_https.txt
		# 给 twitch.tv 放行
		sed -i '/twitch.tv/d' rules/fanboy_https.txt
		# 删除可能导致卡顿的HTTPS规则
		sed -i '/\.\*\//d' rules/fanboy_https.txt
		# 给国内三大电商平台放行
		sed -i '/jd.com/d' rules/fanboy_https.txt
		sed -i '/taobao.com/d' rules/fanboy_https.txt
		sed -i '/tmall.com/d' rules/fanboy_https.txt

		# 删除不必要信息重新打包 15 表示从第15行开始 $表示结束
		sed -i '15,$d' rules/fanboy.txt
		# 合二归一
		cat rules/fanboy_https.txt >> rules/fanboy.txt
		# 删除可能导致kpr卡死的神奇规则
		sed -i '/https:\/\/\*/d' rules/fanboy.txt
		# 给 netflix.com 放行
		sed -i '/netflix.com/d' rules/fanboy.txt
		# 给 tvbs.com 放行
		sed -i '/tvbs.com/d' rules/fanboy.txt
		sed -i '/googletagmanager.com/d' rules/fanboy.txt
		# 给 microsoft.com 放行
		sed -i '/microsoft.com/d' rules/fanboy.txt
		# 给apple的https放行
		sed -i '/apple.com/d' rules/fanboy.txt
		sed -i '/mzstatic.com/d' rules/fanboy.txt
		# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
		# 当 koolproxy_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
		koolproxy_del_rule=1
		while [ $koolproxy_del_rule = 1 ];do
			del_rule=`cat rules/fanboy.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
			if [ "$del_rule" != "" ]; then
				sed -i "${del_rule}d" rules/fanboy.txt
			else
				koolproxy_del_rule=0
			fi
		done	
	else
		echo_date 跳过优化 fanboy规则。。。。。 >>$LOGFILE
	fi


	if [ "$koolproxy_https_ABP" = "1" ]; then
		echo_date 正在优化 ABP规则。。。。。 >>$LOGFILE
		sed -i '/^\$/d' rules/easylistchina.txt
		sed -i '/\*\$/d' rules/easylistchina.txt
		# 给btbtt.替换过滤规则。
		sed -i 's#btbtt.\*#\*btbtt.\*#g' rules/easylistchina.txt
		# 给手机百度图片放行
		sed -i '/baidu.com\/it\/u/d' rules/easylistchina.txt
		# # 给手机百度放行
		# sed -i '/mbd.baidu.comd' rules/easylistchina.txt
		# 给知乎放行
		sed -i '/zhihu.com/d' rules/easylistchina.txt
		# 给apple的https放行
		sed -i '/apple.com/d' rules/easylistchina.txt
		sed -i '/mzstatic.com/d' rules/easylistchina.txt

		# 将规则转化成kp能识别的https
		cat rules/easylistchina.txt | grep "^||" | sed 's#^||#||https://#g' >> rules/easylistchina_https.txt
		# 移出https不支持规则domain=
		sed -i 's/\(,domain=\).*//g' rules/easylistchina_https.txt
		sed -i 's/\(\$domain=\).*//g' rules/easylistchina_https.txt
		sed -i 's/\(domain=\).*//g' rules/easylistchina_https.txt
		sed -i '/\^$/d' rules/easylistchina_https.txt
		sed -i '/\^\*\.gif/d' rules/easylistchina_https.txt
		sed -i '/\^\*\.jpg/d' rules/easylistchina_https.txt

		cat rules/easylistchina.txt | grep "^||" | sed 's#^||#||http://#g' >> rules/easylistchina_https.txt
		cat rules/easylistchina.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> rules/easylistchina_https.txt
		cat rules/easylistchina.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> rules/easylistchina_https.txt
		cat rules/easylistchina.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> rules/easylistchina_https.txt
		# 给facebook.com的https放行
		sed -i '/facebook.com/d' rules/easylistchina_https.txt
		sed -i '/fbcdn.net/d' rules/easylistchina_https.txt
		# 删除可能导致卡顿的HTTPS规则
		sed -i '/\.\*\//d' rules/easylistchina_https.txt



		# 删除不必要信息重新打包 15 表示从第15行开始 $表示结束
		sed -i '6,$d' rules/easylistchina.txt
		# 合二归一
		cat rules/easylistchina_https.txt >> rules/easylistchina.txt
		# 给三大视频网站放行 由kp.dat负责
		sed -i '/youku.com/d' rules/easylistchina.txt
		sed -i '/iqiyi.com/d' rules/easylistchina.txt
		sed -i '/g.alicdn.com/d' rules/easylistchina.txt
		sed -i '/tudou.com/d' rules/easylistchina.txt
		sed -i '/gtimg.cn/d' rules/easylistchina.txt
		# 给https://qq.com的html规则放行
		sed -i '/qq.com/d' rules/easylistchina.txt
		# 删除可能导致kpr卡死的神奇规则
		sed -i '/https:\/\/\*/d' rules/easylistchina.txt
		# 给国内三大电商平台放行
		sed -i '/jd.com/d' rules/easylistchina.txt
		sed -i '/taobao.com/d' rules/easylistchina.txt
		sed -i '/tmall.com/d' rules/easylistchina.txt
		# 给 netflix.com 放行
		sed -i '/netflix.com/d' rules/easylistchina.txt
		# 给 tvbs.com 放行
		sed -i '/tvbs.com/d' rules/easylistchina.txt
		sed -i '/googletagmanager.com/d' rules/easylistchina.txt
		# 给 microsoft.com 放行
		sed -i '/microsoft.com/d' rules/easylistchina.txt
		# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
		# 当 koolproxy_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
		koolproxy_del_rule=1
		while [ $koolproxy_del_rule = 1 ];do
			del_rule=`cat rules/easylistchina.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
			if [ "$del_rule" != "" ]; then
				sed -i "${del_rule}d" rules/easylistchina.txt
			else
				koolproxy_del_rule=0
			fi
		done	
		#cat rules/kpr_our_rule.txt >> rules/easylistchina.txt

	else
		echo_date 跳过优化 ABP规则。。。。。 >>$LOGFILE
	fi

                #优化Yhosts规则
	if [ "$koolproxy_https_yhosts" = "1" ]; then
		# 删除不必要信息重新打包 0-11行 表示从第15行开始 $表示结束
		# sed -i '1,11d' rules/yhosts.txt
		echo_date 正在优化 补充规则yhosts。。。。。 >>$LOGFILE

		# 开始Kpr规则化处理
		cat rules/yhosts.txt > rules/yhosts_https.txt
		sed -i 's/^127.0.0.1\ /||https:\/\//g' rules/yhosts_https.txt
		cat rules/yhosts.txt >> rules/yhosts_https.txt
		sed -i 's/^127.0.0.1\ /||http:\/\//g' rules/yhosts_https.txt
		# 处理tvbox.txt本身规则。
		sed -i 's/^127.0.0.1\ /||/g' tmp/tvbox.txt
		# 合二归一
		cat  rules/yhosts_https.txt > rules/yhosts.txt
		cat tmp/tvbox.txt >> rules/yhosts.txt
		rm -rf tmp/tvbox.txt

		# 此处对yhosts进行单独处理
		sed -i 's/^@/!/g' rules/yhosts.txt
		sed -i 's/^#/!/g' rules/yhosts.txt
		sed -i '/localhost/d' rules/yhosts.txt
		sed -i '/broadcasthost/d' rules/yhosts.txt
		sed -i '/broadcasthost/d' rules/yhosts.txt
		sed -i '/cn.bing.com/d' rules/yhosts.txt
		# 给三大视频网站放行 由kp.dat负责
		sed -i '/youku.com/d' rules/yhosts.txt
		sed -i '/iqiyi.com/d' rules/yhosts.txt
		sed -i '/g.alicdn.com/d' rules/yhosts.txt
		sed -i '/tudou.com/d' rules/yhosts.txt
		sed -i '/gtimg.cn/d' rules/yhosts.txt


		# 给知乎放行
		sed -i '/zhihu.com/d' rules/yhosts.txt
		# 给https://qq.com的html规则放行
		sed -i '/qq.com/d' rules/yhosts.txt
		# 给github的https放行
		sed -i '/github/d' rules/yhosts.txt
		# 给apple的https放行
		sed -i '/apple.com/d' rules/yhosts.txt
		sed -i '/mzstatic.com/d' rules/yhosts.txt
		# 给api.twitter.com的https放行
		sed -i '/twitter.com/d' rules/yhosts.txt
		# 给facebook.com的https放行
		sed -i '/facebook.com/d' rules/yhosts.txt
		sed -i '/fbcdn.net/d' rules/yhosts.txt
		# 给 instagram.com 放行
		sed -i '/instagram.com/d' rules/yhosts.txt
		# 删除可能导致kpr卡死的神奇规则
		sed -i '/https:\/\/\*/d' rules/yhosts.txt
		# 给国内三大电商平台放行
		sed -i '/jd.com/d' rules/yhosts.txt
		sed -i '/taobao.com/d' rules/yhosts.txt
		sed -i '/tmall.com/d' rules/yhosts.txt
		# 给 netflix.com 放行
		sed -i '/netflix.com/d' rules/yhosts.txt
		# 给 tvbs.com 放行
		sed -i '/tvbs.com/d' rules/yhosts.txt
		sed -i '/googletagmanager.com/d' rules/yhosts.txt
		# 给 microsoft.com 放行
		sed -i '/microsoft.com/d' rules/yhosts.txt
		# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
		# 当 koolproxy_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
		koolproxy_del_rule=1
		while [ $koolproxy_del_rule = 1 ];do
			del_rule=`cat rules/yhosts.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
			if [ "$del_rule" != "" ]; then
				sed -i "${del_rule}d" rules/yhosts.txt
			else
				koolproxy_del_rule=0
			fi
		done	
	else
		echo_date 跳过优化 补充规则yhosts。。。。。 >>$LOGFILE
	fi

         #正在优化 补充规则antiad
	if [ "$koolproxy_https_antiad" = "1" ]; then
		# 删除不必要信息重新打包 0-11行 表示从第15行开始 $表示结束
		# sed -i '1,11d' rules/antiad.txt
		echo_date 正在优化 补充规则antiad。。。。。 >>$LOGFILE
		sed -i 's/DOMAIN-SUFFIX\,/||https:\/\//g' rules/antiad.txt
			
		
		# 此处对AntiAD进行处理
		sed -i 's/^@/!/g' rules/antiad.txt
		sed -i 's/^#/!/g' rules/antiad.txt
		sed -i '/localhost/d' rules/antiad.txt
		sed -i '/broadcasthost/d' rules/antiad.txt
		sed -i '/broadcasthost/d' rules/antiad.txt
		sed -i '/cn.bing.com/d' rules/antiad.txt
		# 给三大视频网站放行 由kp.dat负责
		sed -i '/youku.com/d' rules/antiad.txt
		sed -i '/iqiyi.com/d' rules/antiad.txt
		sed -i '/g.alicdn.com/d' rules/antiad.txt
		sed -i '/tudou.com/d' rules/antiad.txt
		sed -i '/gtimg.cn/d' rules/antiad.txt


		# 给知乎放行
		sed -i '/zhihu.com/d' rules/antiad.txt
		# 给https://qq.com的html规则放行
		sed -i '/qq.com/d' rules/antiad.txt
		# 给github的https放行
		sed -i '/github/d' rules/antiad.txt
		# 给apple的https放行
		sed -i '/apple.com/d' rules/antiad.txt
		sed -i '/mzstatic.com/d' rules/antiad.txt
		# 给api.twitter.com的https放行
		sed -i '/twitter.com/d' rules/antiad.txt
		# 给facebook.com的https放行
		sed -i '/facebook.com/d' rules/antiad.txt
		sed -i '/fbcdn.net/d' rules/antiad.txt
		# 给 instagram.com 放行
		sed -i '/instagram.com/d' rules/antiad.txt
		# 删除可能导致kpr卡死的神奇规则
		sed -i '/https:\/\/\*/d' rules/antiad.txt
		# 给国内三大电商平台放行
		sed -i '/jd.com/d' rules/antiad.txt
		sed -i '/taobao.com/d' rules/antiad.txt
		sed -i '/tmall.com/d' rules/antiad.txt
		# 给 netflix.com 放行
		sed -i '/netflix.com/d' rules/antiad.txt
		# 给 tvbs.com 放行
		sed -i '/tvbs.com/d' rules/antiad.txt
		sed -i '/googletagmanager.com/d' rules/antiad.txt
		# 给 microsoft.com 放行
		sed -i '/microsoft.com/d' rules/antiad.txt
		# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
		# 当 koolproxy_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
		koolproxy_del_rule=1
		while [ $koolproxy_del_rule = 1 ];do
			del_rule=`cat rules/antiad.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
			if [ "$del_rule" != "" ]; then
				sed -i "${del_rule}d" rules/antiad.txt
			else
				koolproxy_del_rule=0
			fi
		done	
	else
		echo_date 跳过优化 补充规则antiad。。。。。 >>$LOGFILE
	fi
	# 删除临时文件
	rm -rf rules/*_https.txt
	rm tmp/*.txt
	rm tmp/kp.dat.md5

	echo_date 所有规则更新并优化完毕！ >>$LOGFILE
	echo_date ==================================================== >>$LOGFILE
	
	wget 'https://raw.githubusercontent.com/houzi-/CDN/master/daily.txt' -q -O rules/daily.txt
	wget 'https://raw.githubusercontent.com/houzi-/CDN/master/koolproxy.txt' -q -O rules/koolproxy.txt
	#wget 'https://raw.fastgit.org/fw869/AD/master/daily.txt' -q -O rules/daily.txt
        #wget 'https://down.cmccw.xyz/daily.txt' -q -O rules/daily.txt
	#wget 'https://raw.fastgit.org/fw869/AD/master/koolproxy.txt' -q -O rules/koolproxy.txt
        #wget 'https://down.cmccw.xyz/koolproxy.txt' -q -O rules/koolproxy.txt
	#乘风视频
        wget 'https://gitee.com/xinggsf/Adblock-Rule/raw/master/mv.txt' -q -O rules/mv.txt
	#wget 'https://raw.fastgit.org/fw869/AD/master/user.txt' -q -O rules/user.txt
	#wget 'https://github.com/firkerword/ADB/blob/main/user.txt' -q -O rules/user.txt
	wget 'https://raw.githubusercontent.com/firkerword/ADB/main/koolproxy_ipset.conf' -q -O ipsetadblock/koolproxy_ipset.conf

	wget https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt -O- | grep ^\|\|[^\*]*\^$ | sed -e 's:||:address\=\/:' -e 's:\^:/0\.0\.0\.0:' > ipsetadblock/dnsmasq.adblock
        sed -i '/youku/d' ipsetadblock/dnsmasq.adblock
        sed -i '/[1-9]\{1,3\}\.[1-9]\{1,3\}\.[1-9]\{1,3\}\.[1-9]\{1,3\}/d' ipsetadblock/dnsmasq.adblock
	
	yhosts_rules_local=`cat rules/yhosts.txt | sed -n '1p' | cut -d "=" -f2`
	easylist_rules_local=`cat rules/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`
        fanboy_rules_local=`cat rules/fanboy.txt  | sed -n '3p'|awk '{print $3,$4}'`
	antiad_rules_local=`cat rules/antiad.txt  | sed -n '2p' | cut -d "=" -f2`
	koolproxy_rules_local=`cat rules/koolproxy.txt  | sed -n '3p'|awk '{print $3,$4}'`
        mv_rules_local=`cat rules/mv.txt  | sed -n '3p'|awk '{print $3,$4}'`
		 echo $(date "+%F %T"): -------------------Yhosts规则 version $yhosts_rules_local >>$LOGFILE
                 echo $(date "+%F %T"): -------------------ABP规则 version $easylist_rules_local >>$LOGFILE
                 echo $(date "+%F %T"): -------------------Fanboy规则 version $fanboy_rules_local >>$LOGFILE
		 echo $(date "+%F %T"): -------------------Antiad规则 version $antiad_rules_local >>$LOGFILE
		 echo $(date "+%F %T"): -------------------静态规则 version $koolproxy_rules_local >>$LOGFILE
		 echo $(date "+%F %T"): -------------------乘风视频 version $mv_rules_local >>$LOGFILE
                 echo $(date "+%F %T"): ------------------- 内置规则更新成功！ ------------------- >>$LOGFILE
	echo_date ------------------- 规则更新成功！ -------------------    >>$LOGFILE

	#cat  $LOGFILE
