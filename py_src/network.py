time_window = 640;
eeg = tf.keras.layers.Input(shape=[time_window, 64])
env1 = tf.keras.layers.Input(shape=[time_window, 1])
env2 = tf.keras.layers.Input(shape=[time_window, 1])

filters = 1
kernel_size = 16
eeg_conv = tf.keras.layers.Conv1D(filters, kernel_size=kernel_size)(eeg)
cos1 = tf.keras.layers.Dot(1,normalize= True)([eeg_conv , env1[:,:-(kernel_size-1),:]])
cos2 = tf.keras.layers.Dot(1,normalize= True)([eeg_conv , env2[:,:-(kernel_size-1),:]])

cos_similarity = tf.keras.layers.Concatenate()([cos1, cos2])
cos_flat = tf.keras.layers.Flatten()(cos_similarity)
out = tf.keras.layers.Dense(1, activation="sigmoid")(cos_flat)
model = tf.keras.Model(inputs=[eeg, env1, env2], outputs=[out])
model.summary()