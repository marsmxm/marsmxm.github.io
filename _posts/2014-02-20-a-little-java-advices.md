---
layout: post
title: A Little Java Advices
date: 2014-02-20
category: Java
tags: [Java]
published: false
---

The First Bit of Advice
===
When specifying a collection of data,
use abstract classes for datatypes and
extended classes for variants.

The Second Bit of Advice
===
When writing a function over a
data type, place a method in each of the
variants that make up the datatype. If
a field of a variant belongs to the same
datatype, the method may call the
corresponding method of the field in
computing the function.

The Third Bit of Advice
===
When writing a function that returns
values of a datatype, use new to create
these values.