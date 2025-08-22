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
Ty = 12
sos = '@'
eos = '$'

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
vec_layer_machine.adapt([f"{sos}{s}{eos}" for s in dates_machine])

print(vec_layer_human.get_vocabulary()[:15])
print(vec_layer_machine.get_vocabulary())

# %%
train_size = 60000
valid_size = 20000

X_train = tf.constant(dates_human[:train_size])
X_valid = tf.constant(dates_human[train_size:train_size+valid_size])
X_test = tf.constant(dates_human[train_size+valid_size:])

X_train_dec = tf.constant([f"{sos}{s}" for s in dates_machine[:train_size]])
X_valid_dec = tf.constant([f"{sos}{s}" for s in dates_machine[train_size:train_size+valid_size]])
X_test_dec = tf.constant([f"{sos}{s}" for s in dates_machine[train_size+valid_size:]])

Y_train = vec_layer_machine([f"{s}{eos}" for s in dates_machine[:train_size]])
Y_valid = vec_layer_machine([f"{s}{eos}" for s in dates_machine[train_size:train_size+valid_size]])
Y_test = vec_layer_machine([f"{s}{eos}" for s in dates_machine[train_size+valid_size:]])

print(X_train[0])
tf.cast(tf.expand_dims(vec_layer_human(X_train[0]), axis=1), dtype=tf.float32)

# %%
encoder_inputs = tf.keras.layers.Input(name="encoder_inputs", shape=[], dtype=tf.string)
decoder_inputs = tf.keras.layers.Input(name="decoder_inputs",shape=[], dtype=tf.string)

encoder_input_ids = tf.cast(tf.expand_dims(vec_layer_human(encoder_inputs), axis=-1), dtype=tf.float32)
decoder_input_ids = tf.cast(tf.expand_dims(vec_layer_machine(decoder_inputs), axis=-1), dtype=tf.float32)

encoder = tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(256, return_state=True), name="encoder")
encoder_outputs, *encoder_states = encoder(encoder_input_ids)
encoder_states = [tf.concat(encoder_states[::2], axis=-1),  # hidden states (0 & 2)
                  tf.concat(encoder_states[1::2], axis=-1)] # cell states (1 & 3)

decoder = tf.keras.layers.LSTM(512, name="decoder", return_sequences=True)
decoder_outputs = decoder(decoder_input_ids, initial_state=encoder_states)

output_layer = tf.keras.layers.Dense(vocab_size, name="dense", activation="softmax")
Y_proba = output_layer(decoder_outputs)

model = tf.keras.Model(inputs=[encoder_inputs, decoder_inputs],
                       outputs=[Y_proba])
model.compile(loss="sparse_categorical_crossentropy", optimizer="nadam",
              metrics=["accuracy"])

model.summary(line_length=120, expand_nested=True)

# %%
model.fit((X_train, X_train_dec), Y_train, epochs=10,
          validation_data=((X_valid, X_valid_dec), Y_valid))

print("Evaluate on test data")
results = model.evaluate((X_test, X_test_dec), Y_test)
print("test loss, test acc:", results)

# %%
import numpy as np

def translate(hunman_date):
    translation = ""
    for t in range(Ty):
        X = np.array([hunman_date])  # encoder input 
        X_dec = np.array([sos + translation])  # decoder input
        y_proba = model.predict((X, X_dec), verbose=0)[0, t]  # last token's probas
        char_id = np.argmax(y_proba)
        predicted_char = vec_layer_machine.get_vocabulary()[char_id]
        if predicted_char == eos:
            break
        translation += predicted_char
    return translation.strip()

# %%
for i in range(10):
    human_date= format_date(fake.date_object(), format=random.choice(FORMATS),  locale='en_US')
    print("human: " + human_date)
    print("machine: " + translate(human_date) + "\n")
