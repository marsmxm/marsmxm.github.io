---
layout: post
title: ! 'Y Combinator in Scheme'
categories:
- PL
tags: [Scheme, Y Combinator]
status: publish
type: post
published: true
---

看了[王垠](http://www.yinwang.org/)的[幻灯片](http://www.slideshare.net/yinwang0/reinventing-the-ycombinator)又回忆起了Y combinator的推导过程。感觉他的解释比《The Little Schemer》来的更易懂，作为备忘，把推导过程记录如下：

```scheme
;; 有define的时候递归是这样的
(define length
  (lambda (xs)
    (if (null? xs)
        0
        (add1 (length (cdr xs))))))

;; 在lambda calculus里没有define， 所以我们有了poor man's Y
((lambda (length)
   (lambda (xs)
     (if (null? xs)
         0
         (add1 ((length length) (cdr xs))))))
 (lambda (length)
   (lambda (xs)
     (if (null? xs)
         0
         (add1 ((length length) (cdr xs)))))))

;; abstract outer self-application
((lambda (u) (u u))
 (lambda (length)
   (lambda (xs)
     (if (null? xs)
         0
         (add1 ((length length) (cdr xs)))))))

;; abstract inner self-application
;; 注释掉是因为这个调用会造成无限递归
;((lambda (u) (u u))
; (lambda (length)
;   ((lambda (g)
;      (lambda (xs)
;        (if (null? xs)
;            0
;            (add1 (g (cdr xs))))))
;    (length length))))

;; 解决call-by-value调用造成的无限递归
((lambda (u) (u u))
 (lambda (length)
   ((lambda (g)
      (lambda (xs)
        (if (null? xs)
            0
            (add1 (g (cdr xs))))))
    (lambda (v) ((length length) v)))))

;; 把中间的length函数体抽象为函数参数f
((lambda (f)
   ((lambda (u) (u u))
    (lambda (length)
      (f
       (lambda (v) ((length length) v))))))
 (lambda (g)
   (lambda (xs)
     (if (null? xs)
         0
         (add1 (g (cdr xs)))))))

;; 上面的前半部分被调方就是 Y combinator
(lambda (f)
  ((lambda (u) (u u))
   (lambda (x)
     (f (lambda (v) ((x x) v))))))

;; Test
(((lambda (f)
    ((lambda (u) (u u))
     (lambda (x)
       (f (lambda (v) ((x x) v))))))
  (lambda (length)
    (lambda (xs)
      (if (null? xs)
          0
          (add1 (length (cdr xs)))))))
 '(1 2 3 4 5))
;; => 5

(((lambda (f)
    ((lambda (u) (u u))
     (lambda (x)
       (f (lambda (v) ((x x) v))))))
  (lambda (factorial)
    (lambda (n)
      (if (zero? n)
          1
          (* n (factorial (sub1 n)))))))
 5)
;; => 120
```
