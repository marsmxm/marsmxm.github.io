---
layout: post
title: ! '捕获Thread对象抛出的异常'
categories:
- Java
tags: []
status: publish
type: post
published: true
meta:
  _wpas_done_all: '1'
  _edit_last: '1'
---

Java中，在未作任何处理的情况下，父线程（比如main()所在的线程）无法捕获子线程抛出的异常：
{% highlight java %} 
public class ExceptionThread implements Runnable {
	public void run() {
		throw new RuntimeException();
	}

	public static void main(String[] args) {
		try {
			Thread t = new Thread(new ExceptionThread());
			t.start();
		} catch(RuntimeException e) {
			System.out.println("Caught " + e);
		}
	}
}
{% endhighlight %}
输出的结果是：
{% highlight java %} 
java.lang.RuntimeException
    at ExceptionThread.run(ExceptionThread.java:7)
    at ThreadPoolExecutor$Worker.runTask(Unknown Source)
    at ThreadPoolExecutor$Worker.run(Unknown Source)
    at Java.lang.Thread.run(Unknown Source)
{% endhighlight %}
一个解决办法是，通过Thread对象t的setUncaughtExceptionHandler()方法，提供给t一个Thread.UncaughtExceptionHandler类型的对象，要实现Thread.UncaughtExceptionHandler接口，只需实现uncaughtException()方法，该方法在线程将要抛出异常前被调用:
{% highlight java %} 
import java.util.concurrent.*;

public class ExceptionThread implements Runnable {
	public void run() {
		throw new RuntimeException();
	}

	public static void main(String[] args) {
		Thread t = new Thread(new ExceptionThread());
		t.setUncaughtExceptionHandler(
                        new Thread.UncaughtExceptionHandler() {
			    public void uncaughtException(Thread t, Throwable e) {
				    System.out.println("Caught " + e);
			    }});
		t.start();
	}
}
{% endhighlight %}
如果使用Executor来创建线程的话，可以通过ThreadFactory来实现：
{% highlight java %} 
iimport java.util.concurrent.*;

class HandlerThreadFactory implements ThreadFactory {
	public Thread newThread(Runnable r) {
		Thread t = new Thread(r);
		t.setUncaughtExceptionHandler(
			new Thread.UncaughtExceptionHandler() {
				public void uncaughtException(Thread t, Throwable e) {
					System.out.println("Caught " + e);
				}
			});
		return t;
	}
}

public class ExceptionThread implements Runnable {
	public void run() {
		throw new RuntimeException();
	}

	public static void main(String[] args) {
		ExecutorService executor =
			Executors.newCachedThreadPool(new HandlerThreadFactory());
		executor.execute(new ExceptionThread());
	}
}
{% endhighlight %}

(EOF)

[![Creative Commons License](http://i.creativecommons.org/l/by/3.0/cn/88x31.png)](http://creativecommons.org/licenses/by/3.0/cn/deed.en_US)

This work is licensed under a [Creative Commons Attribution 3.0 China Mainland License.](http://creativecommons.org/licenses/by/3.0/cn/deed.en_US)