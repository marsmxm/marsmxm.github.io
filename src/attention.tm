<TeXmacs|2.1.4>

<style|notes>

<\body>
  <\hide-preamble>
    \;

    <assign|notes-header-name|Notes on Programming and Others>

    <assign|notes-header-image|<image|../penguin.png|20pt|||>>
  </hide-preamble>

  <notes-header><chapter*|Understanding Attention Mechanisms>

  This article discusses the attention mechanisms both as an extension to the
  encoder-decoder RNN models, and as a fundamental component to the
  Transformer architecture. It serves as a record of my learning process and
  a reference for the future use.

  <section*|Neural Machine Translation>

  Machine translation can be viewed as constructing conditional language
  models that generate the most probable output in a target language for a
  given input in the other source language. To express this in a mathematical
  way:

  <\equation*>
    arg max<rsub|y<rsup|\<less\>1\<gtr\>>,\<ldots\>.,y<rsup|\<less\>T<rsub|y>\<gtr\>>>
    P<around*|(|y<rsup|\<less\>1\<gtr\>>,\<ldots\>.,y<rsup|\<less\>T<rsub|y>\<gtr\>>
    <around*|\||x|\<nobracket\>>|)>\ 
  </equation*>

  Here, x and y denote the input and output sequence respectively, while
  superscripts in angle brackets (<math|\<less\>1\<gtr\>,\<ldots\>.,\<less\>T<rsub|y>\<gtr\>>)
  indicate the position of each word within the sequence. Traditionally, a
  method called statistical machine translation (SMT) was the dominant
  approach (as used in early versions of Google Translate). SMT models are
  trained on large amount of <hlink|parallel
  corpra|https://en.wikipedia.org/wiki/Parallel_text>, and analyzes these
  corpora to identify statistical relationships between words, phrases, and
  sentence structures in different languages.

  In the 2010s, another method called neural machine translation (NMT)
  rapidly gained popularity following the successful application of RNN-based
  models to translation tasks.\ 

  <subsection|architect>

  <subsection|code>\ 

  <section*|transformer>

  \;

  In a <hlink|2014 paper|https://arxiv.org/abs/1409.3215>
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|?|1>>
    <associate|auto-2|<tuple|?|?>>
    <associate|auto-3|<tuple|1|?>>
    <associate|auto-4|<tuple|2|?>>
    <associate|auto-5|<tuple|2|?>>
    <associate|auto-6|<tuple|2|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|font-shape|<quote|small-caps>|Understanding
      Attention Mechanism and Transformers>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <pageref|auto-1><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>