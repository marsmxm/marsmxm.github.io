---
layout: post
title: ! '让OpenWRT下的空闲硬盘自动停转'
categories:
- Linux
tags: []
status: publish
type: post
published: true
meta:
  _wpas_done_all: '1'
  _edit_last: '1'
---

前一段时间在一个跑着OpenWRT的路由器上加了个移动硬盘，但是过了段时间发现硬盘一直不停的转，不管有没有存取操作。这不行啊，既费电也减少硬盘寿命。后来发现OpenWRT里可以安装一个可以对SCSI驱动器进行操作的软件，sdparm。
关于sdparm的详细解释可以看<a href="http://sg.danny.cz/sg/sdparm.html" target="_blank">官方文档</a>。这里只用到一条简单的命令，
{% highlight bash %}
sdparm -C stop /dev/$DISKNAME
{% endhighlight %}
作用就是使指定的硬盘停转。接下来的问题是怎样判断硬盘是否空闲。可以根据/proc/diskstats里的状态信息来判断。这个文件里的一条典型记录长这个样：
{% highlight bash %}
8       8 sda8 11831 25104 1228898 1598268 4290 4388 249536 3469116 0 83176 5067356
{% endhighlight %}
前三列分别是主设备号，次设备号和设备名称。而倒数第三列是当前对硬盘的IO操作数，正是需要的信息。可以看出来sda8分区现在就是空闲的。

有了这些准备就可一写出一个简单的脚本了：
{% highlight bash %}
#!/bin/bash
DISKNAME='sda1'
a=0
for i in `seq 0 10`
do
    b=`cat /proc/diskstats | grep $DISKNAME | awk '{print $(NF-2)}'`
    a=`expr $a + $b`
    sleep 1
done
echo $a
if [ $a == 0 ]
then
    echo "No Activity"
    sdparm -C stop /dev/$DISKNAME
else
    echo "Disk Active"
fi
exit 0
{% endhighlight %}
for循环是判断在10s内对硬盘是否有存取操作，如果没有就认为空闲。其中的awk '{print $(NF-2)}'是打印出倒数第三列，NF=number of fields。
接下来还需要建立一个周期任务来执行这个脚本。OpenWRT下root用户的crontab是/etc/crontabs/root这个文件。加入如下这行：
{% highlight bash %}
*/10 * * * * sh /usr/bin/spindown >> /var/log/spindown.log
{% endhighlight %}
每十分钟判断一下硬盘是否空闲。

<h3>参考:</h3>
<ol>
	<li><a href="http://sg.danny.cz/sg/sdparm.html" title="The sdparm utility" target="_blank">The sdparm utility</a></li>
	<li><a href="http://www.kernel.org/doc/Documentation/iostats.txt" title="I/O statistics fields" target="_blank">I/O statistics fields</a></li>
</ol>


(EOF)