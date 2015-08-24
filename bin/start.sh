#!/bin/sh 

# Author: vicklin123@gmail.com
# Date: 2015-07-20 14:07:54
# Version: 0.0.1
#This application helps you to get information of stocks in terminal.
#Usage:
# 1. put stock code in the file called "codes", eg. sh000001
# 2. execute the script "start.sh"(remember to use chmod +x to authorize)

#Notice:
# 1. this app shows result in terminal, refresh every 3s by clean up terminal so that the history of terminal log will easily full filled. I will fix this bug soon.

sinaurl="http://hq.sinajs.cn/list=" 
context=$(dirname $0)
result=$context"/.result"
codes=$context"/codes"
refreshGap=3s


# curl one stock from sina, save cache in $result
getStock()
{
 target=${sinaurl}""$1
 curl ${target} 2>.log |iconv -fgb2312 -t utf-8 >> $result
}

# for each code in $codes, -> getStock
readStock()
{
 echo  'var title="---name----,open,old,cur,top,bottom,\%"'> $result
 while read myline
 do
  getStock $myline
 done < $codes
}

# show stock info on terminal
printStock()
{
 clear
 cat $result | awk '{
	len=split(substr($result,index($result,"=")+2,100),arr,",");
		name=substr(arr[1],0,16)
		open=substr(arr[2],0,8)
	if(open=="0.00"){ #check if is suspended
		open="---"
		old="---"
		cur="---"
		top="---"
		bottom="---"
		gap="---"
	} else {
		old=substr(arr[3],0,8)
		cur=substr(arr[4],0,8)
		top=substr(arr[5],0,8)
		bottom=substr(arr[6],0,8)
		gap=substr((cur-old)/old*100,0,8)
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
}

# main entrance, execute every 5s
main()
{
  while ((true))
  do
   readStock
   printStock
   sleep $refreshGap
  done
}

# main entrance
main

