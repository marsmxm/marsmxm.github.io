---
layout: post
title: ! '几种惰性求值方法的Racket实现'
categories:
- PL
- Racket
tags: [lazy evaluation, racket, Lisp, thunk, force, delay, stream]
status: publish
type: post
published: true
---

避免不必要的计算有时候是对程序的优化，有时候却是一个必要的手段。用求阶乘的递归函数作为一个简单的例子：

```racket
(define (factorial n)
  (if (= n 0)
      1
      (* n (factorial (sub1 n)))))
```
当n = 0时，`if`表达式的值即整个函数的值就是1，而且解释器不会再去额外的计算`(* 1 (factorial 0))`的值。如果`if`没有这种"避免不必要求值"的语义，那么这个函数会无限地递归下去直到把内存填满，比如这个例子：

```racket
(define (my-bad-if e1 e2 e3) (if e1 e2 e3))

(define (factorial-wrong n)
  (my-bad-if (= n 0)
             1
             (* n (factorial-wrong (sub1 n)))))
```
即使n = 0，`factorial-wrong`也会继续无限递归下去。这是因为`my-bad-if`是函数，而racket里函数调用时的求值方式是call-by-value，即先对参数`e1`，`e2`和`e3`求值，再把结果带入函数体里进行求值。如果想在racket里用函数实现`if`相同的语义，就需要用到本文要讨论的第一个延迟求值技术。

### Thunk

现在把`my-bad-if`重写成如下形式：

```racket
(define (my-if e1 e2 e3) (if e1 (e2) (e3)))
```
`(e2)`，`(e3)`是对参数为零的函数的调用，也就是说新的`my-if`中的`e2`和`e3`不是真正需要的表达式，而是**两个参数个数为零的函数，当被调用时会返回真正需要的表达式**。这种用不含参数的函数包装所需表达式的方式就称作thunk。这时`factorial-wrong`需要重写成如下形式：

```racket
(define (factorial x)
  (my-if (= x 0)
         (lambda () 1)
         (lambda () (* x (factorial (sub1 x))))))
```
现在程序可以正确地得出结果了。Thunk之所以奏效是因为`lambda`返回的是一个函数，对**函数求值**(而非调用)时不会去执行函数体中的代码(只有在调用时才会)，相反对函数的求值结果是一个闭包(closure)。

<br />
Racket(以及大多数语言)的call-by-value函数调用语义当然有它的优点，那就是可以避免重复的计算。相反如果使用thunk，每次都需要对thunk包装的表达式进行一次求值，如果我们thunk的是一个特别耗时的表达式，而且这个表达式在函数体中会被用到多次，那么就会对程序执行速度带来特别大的影响。下面这段代码中用`slow-add`模拟一个耗时的计算，在`my-mult`函数会被调用到多次：

```racket
(define (slow-add x y)
  (sleep 2)
  (+ x y))

> (time (slow-add 1 2))
cpu time: 73 real time: 2004 gc time: 0
3

(define (my-mult x y-thunk)
  (cond [(= x 0) 0]
        [(= x 1) (y-thunk)]
        [else (+ (y-thunk) (my-mult (sub1 x) y-thunk))]))

> (time (my-mult 0 (lambda () (slow-add 3 4))))
cpu time: 0 real time: 1 gc time: 0
0
> (time (my-mult 1 (lambda () (slow-add 3 4))))
cpu time: 75 real time: 2002 gc time: 0
7
> (time (my-mult 2 (lambda () (slow-add 3 4))))
cpu time: 142 real time: 4009 gc time: 0
14
```
调用`my-mult`时，当x = 0，会避免对`slow-add`的调用；但是随着x的增大，对`slow-add`的调用次数增多，程序的执行速度会显著地变慢。
如果把`my-mult`改写成thunk前的形式，虽然随着x增大，程序可以保持一个稳定的执行速度，但当x = 0时，还是无法避免对`slow-add`不必要的调用：

```racket
(define (my-mult x y)
  (cond [(= x 0) 0]
        [(= x 1) y]
        [else (+ y (my-mult (sub1 x) y))]))

> (time (my-mult 0 (slow-add 3 4)))
cpu time: 73 real time: 2003 gc time: 0
0
> (time (my-mult 1 (slow-add 3 4)))
cpu time: 74 real time: 2006 gc time: 0
7
> (time (my-mult 2 (slow-add 3 4)))
cpu time: 74 real time: 2012 gc time: 0
14
```

那么有没有一种办法能同时避免不必要的和重复的计算？答案是有，我们可以使用下面这个手段来达到目的。

### Delay 和 Force

Delay和Force的核心思想就是在第一次对thunk求值后把结果缓存，下一次求值时直接使用缓存的结果：

```racket
(define (slow-add x y)
  (sleep 2)
  (+ x y))

(define (my-mult x y-thunk)
  (cond [(= x 0) 0]
        [(= x 1) (y-thunk)]
        [else (+ (y-thunk) (my-mult (sub1 x) y-thunk))]))

(define (my-delay th) 
  (mcons #f th))

(define (my-force p)
  (if (mcar p)
      (mcdr p)
      (begin (set-mcar! p #t)
             (set-mcdr! p ((mcdr p)))
             (mcdr p))))

> (time (my-mult 0 
         (let ([x (my-delay (lambda () (slow-add 3 4)))]) 
           (lambda () (my-force x)))))
cpu time: 0 real time: 0 gc time: 0
0
> (time (my-mult 1 
         (let ([x (my-delay (lambda () (slow-add 3 4)))]) 
           (lambda () (my-force x)))))
cpu time: 119 real time: 2006 gc time: 0
7
> (time (my-mult 2 
         (let ([x (my-delay (lambda () (slow-add 3 4)))]) 
           (lambda () (my-force x)))))
cpu time: 123 real time: 2002 gc time: 0
14
```
`my-delay`会构造一个含有两个元素的mpair(mutable pair)，其中首元素是#f，第二个元素是传入的thunk。`my-force`接受一个参数p(p代表promise，它也是delay的另一个名字)，当`(mcar p)`为#f，说明delay还未被计算这是第一次调用，这时会调用delay中的thunk，然后将结果存入mpair中，并把`(mcar p)`设为#t。这样对`my-force`的下次调用中，`(mcar p)`为#t，就可以直接使用缓存中的结果了。

<br />
Delay和Force是一个广泛使用的技术，有时也被叫做promise或call-by-need，在Haskell中也被叫做惰性求值(lazy evaluation)。在实践中不用每次都构建自己的`my-delay`和`my-force`，Racket的函数库提供了[`delay`](http://docs.racket-lang.org/reference/Delayed_Evaluation.html?q=delay#%28form._%28%28lib._racket%2Fpromise..rkt%29._delay%29%29)和[`force`](http://docs.racket-lang.org/reference/Delayed_Evaluation.html?q=delay#%28def._%28%28lib._racket%2Fpromise..rkt%29._force%29%29)，可以直接使用：

```racket
> (time (my-mult 0 (lambda () (force (delay (slow-add 3 4))))))
cpu time: 0 real time: 0 gc time: 0
0
> (time (my-mult 1 (lambda () (force (delay (slow-add 3 4))))))
cpu time: 137 real time: 2003 gc time: 0
7
> (time (my-mult 3 (lambda () (force (delay (slow-add 3 4))))))
cpu time: 72 real time: 2006 gc time: 0
21
```

最后要提及的一个延迟求值技术是

### Streams

Stream代表的是一个无限序列。一般来说对stream的使用涉及两方，stream的生产者和它的消费者。生产者负责生成这个无限序列，但是并不知道有多长的stream会被使用；消费者决定使用多少stream，但是对stream是如何生成的并不关心。在计算机和软件领域会经常遇到stream的例子。UNIX中的管道(pipe)就是一个stream，在`cmd1 | cmd2`中，`cmd1`这个生产者只输出消费者`cmd2`所需长度的输入；对Web应用来说，用户的输入也可以看做是一个stream；甚至Lambda Calculus中的Y Combinator也可以看做是函数递归调用的一个stream。

<br />
在Racket中可以用一个thunk来表示一个stream，当调用它时会得到一个pair，这个pair由两部分组成

	1. stream无限序列中的第一个元素
	2. 另一个thunk，代表从第二个元素开始的无限序列

下面是两个stream的例子：

```racket
(define ones (lambda () (cons 1 ones)))

> (car (ones))
1
> (car ((cdr (ones))))
1

(define powers-of-two
  (letrec ([f (lambda (x) (cons x (lambda () (f (* x 2)))))])
    (lambda () (f 2))))

> (car (powers-of-two))
2
> (car ((cdr (powers-of-two))))
4
> 
```
下面这个stream接受另一个stream作为参数，生成的无限序列中的每个元素是在参数stream的每个元素前加上一个0：

```racket
(define (stream-add-zero s)
  (lambda () 
    (let ([pr (s)])
      (cons (cons 0 (car pr)) (stream-add-zero (cdr pr))))))

> (car ((stream-add-zero powers-of-two)))
'(0 . 2)
> (car ((cdr ((stream-add-zero powers-of-two)))))
'(0 . 4)
```
可以写一个stream的消费者，返回stream的前n个元素：

```racket
(define (stream-for-n-steps s n)
  (if (zero? n)
      null
      (let ([pr (s)])
		(cons (car pr)
	      	  (stream-for-n-steps (cdr pr) (- n 1))))))

> (stream-for-n-steps ones 3)
'(1 1 1)
> (stream-for-n-steps powers-of-two 5)
'(2 4 8 16 32)
> (stream-for-n-steps (stream-add-zero powers-of-two) 7)
'((0 . 2) (0 . 4) (0 . 8) (0 . 16) (0 . 32) (0 . 64) (0 . 128))
```
下面这个stream消费者接受两个参数，一个stream和一个测试函数，返回使测试函数返回#t的元素的序号：

```racket
(define (steps-until stream tester)
  (letrec ([f (lambda (stream ans)
                (let ([pr (stream)])
                  (if (tester (car pr))
                      ans
                      (f (cdr pr) (+ ans 1)))))])
	(f stream 1)))

> (steps-until powers-of-two even?)
1
> (steps-until powers-of-two (lambda (x) (> x 50)))
6
> (stream-for-n-steps powers-of-two 6)
'(2 4 8 16 32 64)
```
函数式编程的一大乐趣是使用高阶函数来抽象出重复的模式，同样可以用一个高阶函数来生成stream：

```racket
(define (stream-maker fn start-from)
  (letrec ([f (lambda (x)
                (cons x (lambda () (f (fn x start-from)))))])
    (lambda () (f start-from))))

(define ones (stream-maker (lambda (x y) 1) 1))
(define powers-of-two (stream-maker * 2))
```

<h3>参考:</h3>
<ol>
  <li><a href="http://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book-Z-H-24.html#%_sec_3.5" title="3.5 Streams" target="_blank">SICP Section 3.5</a></li>
  <li><a href="https://www.coursera.org/learn/programming-languages" title="I/O statistics fields" target="_blank">Programming Languages 这门课</a></li>
</ol>

