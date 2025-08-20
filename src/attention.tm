<TeXmacs|2.1.4>

<style|<tuple|notes|std-shadow>>

<\body>
  <\hide-preamble>
    \;

    <assign|notes-header-name|Notes on Programming and Others>

    <assign|notes-header-image|<image|../penguin.png|20pt|||>>

    <assign|html-title|mxm notes>

    <assign|html-head-favicon|../penguin.png>

    <assign|javascript-code|<\macro|body>
      <\pseudo-code>
        <javascript-lang|<arg|body>>
      </pseudo-code>
    </macro>>

    <assign|big-figure|<\macro|body|caption>
      <surround|<compound|next-figure>||<render-big-figure|figure|<compound|figure-text>
      <compound|the-figure>|<arg|body>|<surround|<set-binding|<compound|the-figure>>||<arg|caption>>>>
    </macro>>
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

  To better understand this neural network architecture, we will build an
  encoder\Udecoder network to solve a relatively simple task: converting
  human-readable date strings into the ISO date format. And here are some
  task samples:

  <\eqnarray*>
    <tformat|<table|<row|<cell|17 December, 2003
    >|<cell|\<Rightarrow\>>|<cell|2003-12-17>>|<row|<cell|Thursday, October
    31, 2019 >|<cell|\<Rightarrow\>>|<cell|2019-10-31>>|<row|<cell|05.05.12
    >|<cell|\<Rightarrow\>>|<cell|2012-05-05>>>>
  </eqnarray*>

  The figure below describes our intented architecture:

  <\big-figure|<image|../resources/articles/attention/seq2seq.png|1par|||>>
    A encoder-decoder network
  </big-figure>

  The left-side LSTM is the encoder. To better capture information from the
  input sequences, we use a bidirectional RNN for this component. The
  encoder's hidden and cell states form the vector representation of input
  sequence, and they are then passed to the decoder as its initial state. The
  decoder returns all cells' output sequences instead of states from the last
  cell. It then passes its output to a dense layer which uses softmax as the
  activation funciton, to get probabilities of each output character. The
  complete implementation can be found <hlink|here|https://github.com/marsmxm/marsmxm.github.io/blob/main/resources/articles/attention/seq2seq.py>.
  We will now build this network step by step.

  First we need to prepare the training dataset. The
  <hlink|faker|https://faker.readthedocs.io/en/master/> is used here to
  generate some random dates, which are then formatted in random formats:

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

  \;

  The size of our training dataset is 100,000:

  <\python-code>
    m = 100000

    dataset = load_dataset(m)

    dataset[:5]
  </python-code>

  =\<gtr\>

  <\python-code>
    [('saturday june 29 1996', '1996-06-29'),

    \ ('15 march 1978', '1978-03-15'),

    \ ('thursday december 28 2023', '2023-12-28'),

    \ ('wednesday december 31 1980', '1980-12-31'),

    \ ('apr 5 1995', '1995-04-05')]
  </python-code>

  \;

  The next step is to vectorize all the texts in the dataset. Since we are
  translating date strings, we will use character-level vectorization rather
  than word-level vectorization (as commonly used in NLP):

  <\python-code>
    import tensorflow as tf

    \;

    vocab_size = 50

    Tx = 30

    Ty = 12

    sos = '@'

    eos = '$'

    \;

    def custom_standardization(input_string):

    \ \ \ \ # Lowercase and remove punctuation except '-'

    \ \ \ \ lowercase = tf.strings.lower(input_string)

    \ \ \ \ # Remove all punctuation except '-'

    \ \ \ \ return tf.strings.regex_replace(lowercase, r"[^\\w\\s-@$]", "")

    \;

    dates_human = [d[0] for d in dataset]

    dates_machine = [d[1] for d in dataset]

    \;

    vec_layer_human = tf.keras.layers.TextVectorization(

    \ \ \ \ vocab_size, output_sequence_length=Tx, split="character",
    name="vec_h",

    \ \ \ \ standardize=custom_standardization)

    vec_layer_machine = tf.keras.layers.TextVectorization(

    \ \ \ \ vocab_size, output_sequence_length=Ty, split="character",
    name="vec_m",

    \ \ \ \ standardize=custom_standardization)

    \ \ \ \ 

    vec_layer_human.adapt(dates_human)

    vec_layer_machine.adapt([f"{sos}{s}{eos}" for s in dates_machine])

    \;

    print(vec_layer_human.get_vocabulary()[:15])

    print(vec_layer_machine.get_vocabulary())
  </python-code>

  =\<gtr\>

  <\python-code>
    ['', '[UNK]', ' ', '1', '2', 'a', '0', '9', 'e', 'r', 'y', 'u', 'd', 's',
    'n']

    ['', '[UNK]', '-', '0', '1', '2', '@', '$', '9', '7', '8', '3', '4', '5',
    '6']
  </python-code>

  The empty string (\P\Q) and<python|[UNK]>are tensorflow's built-in
  representations for padding and unknown characters, repectively. We use a
  custom <verbatim|strandardization> function here because we need two
  special characters, <verbatim|@> and <verbatim|$>, to denote the start and
  end of the sequences, and in the default settings, these special characters
  are removed by tensorflow's <verbatim|TextVectorization>.\ 

  Next we split the whole dataset into training and validation sets:

  <\python-code>
    train_size = 80000

    \;

    X_train = tf.constant(dates_human[:train_size])

    X_valid = tf.constant(dates_human[train_size:])

    X_train_dec = tf.constant([f"{sos}{s}" for s in
    dates_machine[:train_size]])

    X_valid_dec = tf.constant([f"{sos}{s}" for s in
    dates_machine[train_size:]])

    Y_train = vec_layer_machine([f"{s}{eos}" for s in
    dates_machine[:train_size]])

    Y_valid = vec_layer_machine([f"{s}{eos}" for s in
    dates_machine[train_size:]])
  </python-code>

  \;

  \;

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
    <associate|auto-3|<tuple|1|?>>
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
    </associate>
  </collection>
</auxiliary>