---
layout: post
title: ! 'Memoization Racket Version'
categories:
- PL
- Racket
tags: [memmoization, racket]
status: publish
type: post
published: true
meta:
  _wpas_done_all: '1'
  _edit_last: '1'
---

{% highlight lisp %}
#lang racket

(define (cached-assoc lst n)
  (letrec ([cache (make-vector n #f)]
           [next-to-replace 0]
           [vector-assoc (lambda (v vec)
                           (letrec ([loop (lambda (i)
                                            (if (= i (vector-length vec))
                                                #f
                                                (let ([x (vector-ref vec i)])
                                                  (if (and (cons? x) (equal? (car x) v))
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
{% endhighlight %}
