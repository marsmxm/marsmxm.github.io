---
layout: post
title: ! 'Django: 用Chrome的developer tool来debug AJAX response'
categories:
- Python
tags: []
status: publish
type: post
published: false
meta:
  _wpas_done_all: '1'
  _edit_last: '1'
---

如果一个Django的AJAX请求出错的话，只会在console里看到诸如404，500之类的HTTP状态码，而没有了Django的error page，这给调试带来了毁灭性的打击。好在不少开发工具可以救我们于水火，比如Firefox的firebug插件和Chrome自带的developer tool。

这里说下developer tool里找到失散的error page的方法:
1. 在Chrome的菜单，工具下打开developer tool（ctrl+shift+j)。
2. 选择Network标签页。这时测试有问题的AJAX请求，会在左侧的列表里出现对应的URL。
3. 选择之后，Preview里就会出现熟悉的Django error page了。

![screenshot]({{ site.url }}/public/img/chrome-dev-tool.png)

(EOF)
