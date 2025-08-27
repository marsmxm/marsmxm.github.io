# %%
import random
from tqdm import tqdm
from faker import Faker
from babel.dates import format_date

fake = Faker()
Faker.seed(12345)

FORMATS = ['short',
           'medium',
           'long',
           'full',
           'full',
           'full',
           'full',
           'full',
           'full',
           'full',
           'full',
           'full',
           'full',
           'd MMM YYY', 
           'd MMMM YYY',
           'dd MMM YYY',
           'd MMM, YYY',
           'd MMMM, YYY',
           'dd, MMM YYY',
           'd MM YY',
           'd MMMM YYY',
           'MMMM d YYY',
           'MMMM d, YYY',
           'dd.MM.YY']

def load_date():
    """
        Loads some fake dates 
        :returns: tuple containing human readable string, machine readable string, and date object
    """
    dt = fake.date_object()

    try:
        human_readable = format_date(dt, format=random.choice(FORMATS),  locale='en_US') # locale=random.choice(LOCALES))
        human_readable = human_readable.lower()
        human_readable = human_readable.replace(',','')
        machine_readable = dt.isoformat()
        
    except AttributeError as e:
        return None, None, None

    return human_readable, machine_readable, dt


def load_dataset(m):
    """
        Loads a dataset with m examples and vocabularies
        :m: the number of examples to generate
    """
    
    dataset = []

    for i in tqdm(range(m)):
        h, m, _ = load_date()
        if h is not None:
            dataset.append((h, m))
 
    return dataset

# %%
m = 100000
dataset = load_dataset(m)
dataset[:5]

# %%
import tensorflow as tf

vocab_size = 50
Tx = 30
Ty = 10
# sos = '@'
# eos = '$'

def custom_standardization(input_string):
    # Lowercase and remove punctuation except '-'
    lowercase = tf.strings.lower(input_string)
    # Remove all punctuation except '-'
    return tf.strings.regex_replace(lowercase, r"[^\w\s-@$]", "")

dates_human = [d[0] for d in dataset]
dates_machine = [d[1] for d in dataset]

vec_layer_human = tf.keras.layers.TextVectorization(
    vocab_size, output_sequence_length=Tx, split="character", name="vec_h", standardize=custom_standardization)
vec_layer_machine = tf.keras.layers.TextVectorization(
    vocab_size, output_sequence_length=Ty, split="character", name="vec_m", standardize=custom_standardization)
vec_layer_human.adapt(dates_human)
vec_layer_machine.adapt([f"{s}" for s in dates_machine])

print(vec_layer_human.get_vocabulary()[:15])
print(vec_layer_machine.get_vocabulary())

# %%
train_size = 60000
valid_size = 20000

X_train = tf.constant(dates_human[:train_size])
X_valid = tf.constant(dates_human[train_size:train_size+valid_size])
X_test = tf.constant(dates_human[train_size+valid_size:])

Y_train = vec_layer_machine([f"{s}" for s in dates_machine[:train_size]])
Y_valid = vec_layer_machine([f"{s}" for s in dates_machine[train_size:train_size+valid_size]])
Y_test = vec_layer_machine([f"{s}" for s in dates_machine[train_size+valid_size:]])

# %%
from tensorflow.keras.layers import RepeatVector, Concatenate, Dense, Dot, Softmax, Activation

repeator = RepeatVector(Tx)
concatenator = Concatenate(axis=-1)
densor1 = Dense(10, activation = "tanh")
densor2 = Dense(1, activation = "relu")
activator = Softmax(axis=1, name='attention_weights')
dotor = Dot(axes = 1)

def one_step_attention(h, s_prev):
    """
    Arguments:
    h -- hidden state output of the Bi-LSTM, numpy-array of shape (m, Tx, n_h)
    s_prev -- previous hidden state of the (decoder) LSTM, numpy-array of shape (m, n_s)
    
    Returns:
    context -- context vector, input of the next (decoder) LSTM cell
    """
    
    s_prev = repeator(s_prev)           # (m, Tx, n_s)              
    concat = concatenator([h, s_prev])  # (m, Tx, n_s + n_h)
    energies = densor2(densor1(concat)) # (m, Tx, 1)
    # print("energies", energies.shape)
    alphas = activator(energies)        # (m, Tx, 1)
    context = dotor([alphas, h])        # (m, 1, n_h)
    
    return context

# %%
from tensorflow.keras.layers import Input, Bidirectional, LSTM, Dense

n_h = 64
n_s = 128


def build_model():
    encoder_inputs = Input(name="encoder_inputs", shape=[], dtype=tf.string)
    encoder_input_ids = tf.cast(tf.expand_dims(vec_layer_human(encoder_inputs), axis=-1), dtype=tf.float32)

    encoder = Bidirectional(LSTM(n_h, return_sequences=True), name="encoder")
    encoder_outputs = encoder(encoder_input_ids)

    s0 = Input(shape=(n_s,), name='s0')
    c0 = Input(shape=(n_s,), name='c0')
    s = s0
    c = c0

    decoder_LSTM_cell = LSTM(n_s, name="decoder", return_state = True)
    output_layer = Dense(vocab_size, name="output", activation="softmax")
    outputs = []

    for t in range(Ty):
        context = one_step_attention(encoder_outputs, s)
        _, s, c = decoder_LSTM_cell(inputs=context, initial_state=[s, c])
        out = output_layer(s)
        outputs.append(out)

    # Stack outputs to create a single tensor of shape (batch_size, Ty, vocab_size)
    outputs = tf.stack(outputs, axis=1)

    model = tf.keras.Model(inputs=[encoder_inputs, s0, c0], outputs=outputs)
    model.compile(loss="sparse_categorical_crossentropy", optimizer="nadam",
                metrics=["accuracy"])

    model.summary(line_length=120, expand_nested=True)
    return model

# %%
import numpy as np

s0_train = np.zeros((train_size, n_s))
c0_train = np.zeros((train_size, n_s))
s0_valid = np.zeros((valid_size, n_s))
c0_valid = np.zeros((valid_size, n_s))
s0_test = np.zeros((len(X_test), n_s))
c0_test = np.zeros((len(X_test), n_s))

model = build_model()

model.fit((X_train, s0_train, c0_train), Y_train, epochs=10,
          validation_data=((X_valid, s0_valid, c0_valid), Y_valid))

print("Evaluate on test data")
results = model.evaluate((X_test, s0_test, c0_test), Y_test)
print("test loss, test acc:", results)

# %%
def translate(human_date):
    s = np.zeros((1, n_s))
    c = np.zeros((1, n_s))
    
    X = np.array([human_date])
    y_proba = model.predict((X, s, c), verbose=0)  # shape: (1, Ty, vocab_size)

    translation = ""
    for t in range(Ty):
        char_id = np.argmax(y_proba[0, t])  # Get prediction for time step t
        predicted_char = vec_layer_machine.get_vocabulary()[char_id]
        translation += predicted_char
        
    return translation.strip()

# %%
def plot_attention_map(modelx, text):
    """
    Plot the attention map for a given input text.
    This is a simplified version that creates a new model to extract attention weights.
    """
    layer = modelx.get_layer('attention_weights')
    f = tf.keras.Model(modelx.inputs, [layer.get_output_at(t) for t in range(Ty)])

    s = np.zeros((1, n_s))
    c = np.zeros((1, n_s))
    X = np.array([text])
    attention_weights = f.predict([X, s, c])

    attention_map = np.zeros((Ty, Tx))
    for t in range(Ty):
        for t_prime in range(Tx):
            attention_map[t][t_prime] = attention_weights[t][0, t_prime, 0]

    # Normalize attention map
    row_max = attention_map.max(axis=1)
    attention_map = attention_map / row_max[:, None]

    prediction = modelx.predict([X, s, c], verbose=0)
    # print("prediction", prediction)
    
    predicted_text = []
    for i in range(len(prediction[0])):
        char_id = np.argmax(prediction[0, i]) 
        predicted_char = vec_layer_machine.get_vocabulary()[char_id]

        predicted_text.append(predicted_char)
        
    text_ = list(text)

    # print("predicted_text", predicted_text)
    # print("text_", text_)
    
    # get the lengths of the string
    input_length = len(text)
    output_length = Ty
    
    # Plot the attention_map
    plt.clf()
    f = plt.figure(figsize=(8, 8.5))
    ax = f.add_subplot(1, 1, 1)

    # add image
    i = ax.imshow(attention_map, interpolation='nearest', cmap='Blues')

    # add colorbar
    cbaxes = f.add_axes([0.2, 0, 0.6, 0.03])
    cbar = f.colorbar(i, cax=cbaxes, orientation='horizontal')
    cbar.ax.set_xlabel('Alpha value (Probability output of the "softmax")', labelpad=2)

    # add labels
    ax.set_yticks(range(output_length))
    ax.set_yticklabels(predicted_text[:output_length])

    ax.set_xticks(range(input_length))
    ax.set_xticklabels(text_[:input_length], rotation=45)

    ax.set_xlabel('Input Sequence')
    ax.set_ylabel('Output Sequence')

    # add grid and legend
    ax.grid()
    
    return attention_map

# %%
for i in range(5):
    human_date= format_date(fake.date_object(), format=random.choice(FORMATS),  locale='en_US')
    print("human: " + human_date)
    print("machine: " + translate(human_date) + "\n")
        

# %%
# attention_map = plot_attention_map(model, "Tuesday, January 17, 1995")
attention_map = plot_attention_map(model, "Tuesday, January 17, 1995")
