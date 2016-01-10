#!/bin/sh 

# Author: vicklin123@gmail.com
# Date: 2015-07-20 14:07:54
# Version: 0.0.1
#This application helps you to get information of stocks in terminal.
#Usage:
# 1. put stock code in the file called "codes", eg. sh000001
# 2. execute the script "start.sh"(remember to use chmod +x to authorize)

sinaurl="http://hq.sinajs.cn/list=" 
context=$(dirname $0)
codes=$context"/codes"
refreshGap=3s


# curl one stock from sina, save cache in $result
getStock()
{
 target=${sinaurl}""$1
 result=$result$'\n'`curl ${target} 2>/dev/null | iconv -f gb2312 -t utf-8 | sed "s/var //"`
}

# for each code in $codes, -> getStock
readStock()
{
 result=`echo 'title="---name----,open,old,cur,top,bottom,\%"'`
 while read myline
 do
  getStock $myline
 done < $codes
}

# show stock info on terminal
printStock()
{
 clear
 for r in $result
 do
  echo $r | awk '{
	len=split(substr($r,index($r,"=")+2,100),arr,",");
		name=substr(arr[1],0,16)
		open=substr(arr[2],0,7)
	if(open=="0.00"){ #check if is suspended
		open="---"
		old="---"
		cur="---"
		top="---"
		bottom="---"
		gap="---"
	} else {
		old=substr(arr[3],0,7)
		cur=substr(arr[4],0,7)
		top=substr(arr[5],0,7)
		bottom=substr(arr[6],0,7)
		if(old=="old"){
			gap="%"
		} else {
			gap=substr((cur-old)/old*100,0,7)
		}
	}
	printf("%s\t",name)
	printf("\033[36m%s\033[0m\t",open)
	printf("%s\t",old)

	if (gap>0) {
		printf("\033[31m%s\033[0m\t",cur)
	} else {
		printf("\033[32m%s\033[0m\t",cur)
	}
	printf("\033[33m%s\033[0m\t",top)
	printf("%s\t",bottom)

	if (gap>0) {
		printf("\033[31m%s\033[0m\t",gap)
	} else {
		printf("\033[32m%s\033[0m\t",gap)
	}

	print"\n"
  }'
 done
}

# main entrance, execute every 5s
main()
{
  while (true)
  do
   readStock
   printStock
   sleep $refreshGap
  done
}

# main entrance
main

