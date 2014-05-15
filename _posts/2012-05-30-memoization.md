---
layout: post
title: ! 'Memoization'
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


最近在《JavaScript The Good Parts》和<a href="http://www.udacity.com/view#Course/cs212/CourseRev/apr2012" target="_blank">Udacity的CS212这门课</a>里都遇到了memoization这个概念。所以打算记下来方便以后参考。

个人理解，memoization就是一种cache，用来减少耗时（资源）的程序段的运行次数。以一个python实现的计算Fibonacci数列的程序为例：
{% highlight python %}
def fib(n):
    if n < 2:
        return n
    else:
        return fib(n-2) + fib(n-1)
{% endhighlight %}
那么fib(5)的计算过程可以用下图来表示：
<img src="http://blog.xming.me/wp-content/uploads/2012/05/fib5.jpeg" alt="" title="fib(5)" width="742" height="404" class="aligncenter size-full wp-image-63" />

可以看到重复的计算非常多。如果运用memoization，我们可以将每次的计算结果存在一个cache里，这样每次计算前先查看cache，如果有需要的值，直接取，没有再计算：
{% highlight python %}
def gen_fib():
    cache = {0:0, 1:1}
    def fib_memo(n):
        if n not in cache:
            cache[n] = fib_memo(n-2) + fib_memo(n-1)
        return cache[n]
    return fib_memo
{% endhighlight %}
这里用了closure在外层函数持久保存一个cache。可以用python的time模块提供的函数来比较一下前后两个版本的fib消耗的时间：
{% highlight python %}
import time

def timedcall(fn, *args):
    "Call function with args; return the time in seconds and result."
    t0 = time.clock()
    result = fn(*args)
    t1 = time.clock()
    return t1-t0, result

def fib(n):
    if n < 2:
        return n
    else:
        return fib(n-2) + fib(n-1)

def gen_fib():
    cache = {0:0, 1:1}
    def fib_memo(n):
        if n not in cache:
            cache[n] = fib_memo(n-2) + fib_memo(n-1)
        return cache[n]
    return fib_memo

print "fib: " + str(timedcall(fib, 40))
fib_memo = gen_fib()
print "fib_memo: " + str(timedcall(fib_memo, 40))
{% endhighlight %}
我这里执行之后得到的结果是：
{% highlight python %}
fib: (108.5130336397503, 102334155)
fib_memo: (4.833016485861208e-05, 102334155)
{% endhighlight %}
时间相差了足有7个数量级。
最后这段代码可以作为一个decorator来为任何一个函数实现memoization：
{% highlight python %}
def memo(f):
    """Decorator that caches the return value for each call to f(args).
    Then when called again with same args, we can just look it up."""
    cache = {}
    def _f(*args):
        try:
            return cache[args]
        except KeyError:
            result = f(*args)
            cache[args] = result
            return result
        except TypeError:
            # some element of args can't be a dict key
            return f(*args)
    _f.cache = cache
    return _f

#Take fib for an example
def fib(n):
    if n < 2:
        return n
    else:
        return fib(n-2) + fib(n-1)
fib = memo(fib)

#or

@memo
def fib(n):
    if n < 2:
        return n
    else:
        return fib(n-2) + fib(n-1)
{% endhighlight %}

(EOF)

[![Creative Commons License](http://i.creativecommons.org/l/by/3.0/cn/88x31.png)](http://creativecommons.org/licenses/by/3.0/cn/deed.en_US)

This work is licensed under a [Creative Commons Attribution 3.0 China Mainland License.](http://creativecommons.org/licenses/by/3.0/cn/deed.en_US)