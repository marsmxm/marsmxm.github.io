---
layout: post
title: ! '理解Python的with语句'
categories:
- Python
tags: []
status: publish
type: post
published: true
meta:
  _wpas_done_all: '1'
  _edit_last: '1'
---

Python从2.5之后引入了with语句，最广泛的用处当属用来处理文件。之前的传统方法是这样的：
{% highlight python %}
f = open("a file on disk")
try:
    # deal with f
finally:
    f.close()
{% endhighlight %}
可以保证文件的关闭，而用with语句可以简单的写成：
{% highlight python %}
from __future__ import with_statement # only requried by python2.5

with open("a file on disk") as f:
    # deal with f
{% endhighlight %}
这相当于由with语句创建了一个安全的范围，在这个范围内可以随意处理一些外部资源而不用担心由于exception被抛出而无法关闭该资源，可以在with语句里使用的对象都属于Context Manager数据类型，比如上例中的open()返回的文件对象，Context Manager需要实现的方法有__enter__()和__exit__()。能把open()放入with语句的原因就是，python的文件类型都实现了前述两个方法。

__enter__和__exit__的签名如下：
{% highlight python %}
object.__enter__(self)
object.__exit__(self, exc_type, exc_value, traceback)
{% endhighlight %}
with语句的语法如下定义：
{% highlight python %}
with_stmt ::=  "with" with_item ("," with_item)* ":" suite
with_item ::=  expression ["as" target]
{% endhighlight %}
下面是详细的with语句执行流程：
<ol>
<li>执行with_item中的expression得到所返回的Context Manager。</li>
<li><b>载入</b>Context Manager的__exit__()方法，为稍后的执行做准备。</li>
<li><b>调用</b>Context Manager的__enter__()方法。</li>
<li>如果with语句中包含了"as target"部分，__enter__()的返回值会被赋给target。</li>
<li>执行suite部分。</li>
<li>调用__exit__()方法，如果第5步中有异常被抛出的话，它的type，value，traceback会被作为参数传给__exit__，此时如果__exit__返回True，这个异常会被抑制，返回False的话，这个异常会被继续抛出。如果suite正常退出的话None会被作为参数传给__exit__，此时__exit__的返回值会被忽略。</li>
</ol>


除了用with语句来处理外部资源，前几天在Quora上也看到了一个用with实现Timer的好办法：
{% highlight python %}
import time
class Timer:
    def __enter__(self):
        self.start = time.clock()
        return self

    def __exit__(self,*args):
        self.end = time.clock()
        self.interval = self.end-self.start
        return False


with Timer() as t:
    dosomesuch()
print t.interval
{% endhighlight %}



<h3>延伸阅读：</h3>
<ul>
<li><a href="http://effbot.org/zone/python-with-statement.htm" target="_blank">Understanding Python's "with" statement</a></li>
<li><a href="http://docs.python.org/2.7/reference/compound_stmts.html#with" target="_blank">http://docs.python.org/2.7/reference/compound_stmts.html#with</a></li>
<li><a href="http://docs.python.org/2.7/reference/datamodel.html#with-statement-context-managers" target="_blank">http://docs.python.org/2.7/reference/datamodel.html#with-statement-context-managers</a></li>
<li><a href="http://docs.python.org/2.7/library/contextlib.html#module-contextlib" target="_blank">http://docs.python.org/2.7/library/contextlib.html#module-contextlib</a></li>
</ul>

(EOF)

[![Creative Commons License](http://i.creativecommons.org/l/by/3.0/cn/88x31.png)](http://creativecommons.org/licenses/by/3.0/cn/deed.en_US)

This work is licensed under a [Creative Commons Attribution 3.0 China Mainland License.](http://creativecommons.org/licenses/by/3.0/cn/deed.en_US)