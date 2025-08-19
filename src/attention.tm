<TeXmacs|2.1.4>

<style|<tuple|notes|std-shadow>>

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

  <section*|Encoder-Decoder Neural Network>

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

  During the 2010s, another method called neural machine translation (NMT)
  rapidly gained popularity following the successful application of RNN
  models to translation tasks. A <hlink|2014
  paper|https://arxiv.org/abs/1409.3215> demonstrated how
  <hlink|long-short-term memory (LSTM)|https://en.wikipedia.org/wiki/Long_short-term_memory>
  cells could be employed to address sequence-to-sequence problems. The idea
  is to use an encoder LSTM to read the input sequence, one timestep at a
  time, generating a fixed-dimensional vector representation, which was then
  decoded by a second LSTM to produce the corresponding output sequence.

  To better understand this architecture, we will build an encoder\Udecoder
  network to solve a relatively simple task: converting human-readable date
  strings into the ISO date format. Here are some examples:

  <\eqnarray*>
    <tformat|<table|<row|<cell|17 December, 2003
    >|<cell|\<Rightarrow\>>|<cell|2003-12-17>>|<row|<cell|Thursday, October
    31, 2019 >|<cell|\<Rightarrow\>>|<cell|2019-10-31>>|<row|<cell|05.05.12
    >|<cell|\<Rightarrow\>>|<cell|2012-05-05>>>>
  </eqnarray*>

  First we need to prepare the training dataset. We use
  <hlink|faker|https://faker.readthedocs.io/en/master/> to generate random
  dates, and format them in random formats:

  <\python-code>
    def load_date():

    \ \ \ \ dt = fake.date_object()

    \ \ \ \ try:

    \ \ \ \ \ \ \ \ human_readable = format_date(dt,
    format=random.choice(FORMATS), \ locale='en_US')

    \ \ \ \ \ \ \ \ human_readable = human_readable.lower()

    \ \ \ \ \ \ \ \ human_readable = human_readable.replace(',','')

    \ \ \ \ \ \ \ \ machine_readable = dt.isoformat()

    \ \ \ \ \ \ \ \ 

    \ \ \ \ except AttributeError as e:

    \ \ \ \ \ \ \ \ return None, None, None

    \;

    \ \ \ \ return human_readable, machine_readable, dt
  </python-code>

  <section*|transformer>

  \;

  \;
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|?|1>>
    <associate|auto-2|<tuple|?|1>>
    <associate|auto-3|<tuple|?|1>>
    <associate|auto-4|<tuple|2|1>>
    <associate|auto-5|<tuple|2|1>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|font-shape|<quote|small-caps>|Understanding
      Attention Mechanisms> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <pageref|auto-1><vspace|0.5fn>

      Encoder-Decoder Neural Network <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2>

      <with|par-left|<quote|1tab>|1.<space|2spc>architect
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3>>

      <with|par-left|<quote|1tab>|2.<space|2spc>code
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>

      transformer <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5>
    </associate>
  </collection>
</auxiliary>