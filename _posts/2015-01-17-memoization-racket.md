---
layout: post
title: ! 'Memoization in Racket'
categories:
- PL
- Racket
tags: [memmoization, racket]
status: publish
type: post
published: true
---

Coursera的[Programming Languages(by Dan Grossman)](https://www.coursera.org/course/proglang)这门课里的Racket部分又一次讲到了这个技巧。记下来权当对[n年前的那篇博文]({% post_url 2012-05-30-memoization %})的一个补充。
下面这段程序用对list的读取来模拟一个耗时的操作，缓存下每次成功的读取结果：

```racket
(define (cached-assoc lst n)
  (letrec ([cache (make-vector n #f)]
           [next-to-replace 0]
           [vector-assoc (lambda (v vec)
                           (letrec ([loop (lambda (i)
                                            (if (= i (vector-length vec))
                                                #f
                                                (let ([x (vector-ref vec i)])
                                                  (if (and (cons? x) 
                                                           (equal? (car x) v))
                                                      x
                                                      (loop (+ i 1))))))])
                             (loop 0)))])
    (lambda (v)
      (or (vector-assoc v cache)
          (let ([ans (assoc v lst)])
            (and ans
                 (begin (vector-set! cache next-to-replace ans)
                        (set! next-to-replace 
                              (if (= (+ next-to-replace 1) n)
                                  0
                                  (+ next-to-replace 1)))
                        ans)))))))
```
可以将上面的程序稍作修改，支持给任意函数一个cache：

```racket
(define (make-cached-function func n)
  (letrec ([cache (make-vector n #f)]
           [next-to-replace 0]
           [vector-assoc (lambda (arg-lst vec)
                           (letrec ([loop (lambda (i)
                                            (if (= i (vector-length vec))
                                                #f
                                                (let ([x (vector-ref vec i)])
                                                  (if (and (cons? x) 
                                                           (equal? (car x) arg-lst))
                                                      (second x)
                                                      (loop (+ i 1))))))])
                             (loop 0)))])
    (lambda args
      (or (vector-assoc args cache)
          (let ([ans (apply func args)])
            (and ans
                 (begin
                   (vector-set! cache next-to-replace 
                                (list args ans))
                   (set! next-to-replace 
                         (if (= (+ next-to-replace 1) n)
                             0
                             (+ next-to-replace 1)))
                   ans)))))))

(define (fib n)
  (if (< n 2)
      n
      (+ (fib (- n 2)) (fib (- n 1)))))

(define fib-cached 
  (make-cached-function 
   (lambda (n)
     (if (< n 2)
         n
         (+ (fib-cached  (- n 2)) (fib-cached  (- n 1)))))
   100))

> (time (fib 35))
cpu time: 1181 real time: 1230 gc time: 0
9227465

> (time (fib-cached 35))
cpu time: 0 real time: 0 gc time: 0
9227465
```

一个更简洁的写法是用racket的hash(thanks to [StackOverflow](http://stackoverflow.com/questions/23170706/is-there-a-valid-usecase-for-redefining-define-in-scheme-racket))：

```racket
(define (memoize fn)
  (let ((cache (make-hash)))
    (lambda arg (hash-ref! cache arg (thunk (apply fn arg))))))

(define fib
  (memoize
   (lambda (n)
     (if (< n 2) n (+ (fib (sub1 n)) (fib (- n 2)))))))

> (time (fib 35))
cpu time: 0 real time: 0 gc time: 0
9227465
```
