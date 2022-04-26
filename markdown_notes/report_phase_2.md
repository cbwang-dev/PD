---
title: 'P&D ISSP Phase 2 Report'
author: "Chengbin Wang"
fontsize: 10pt
geometry: margin=2cm
classoption: twocolumn
bibliography: "./markdown_notes/biblio.bib"
---

## Introduction

This report explains the work done in Phase 2. It includes linear regression results, baseline CNN and dilated CNN results over different parameter settings. The linear regression results are not promising because the accuracy is too low, and the dilated CNN results are too high to be expected. Also, LSTM blocks are not implemented and the report lacks of discussion over 1) different window lengths and 2) subject-specific boxplots. These are to be corrected and implemented in the coming weeks.

## Data Preprocessing

The choices involved for splitting training set and test (or validation) set is explained, and some notations for further chapters are set.

Because of limited amount of data, we use *leave one out strategy* to evaluate the effectiveness of one specific model performed over each subject. Take one subject with 48 trials as an example. In one train-validation process, a random trial is treated as validation set and the model is trained over the rest 48 trials. This process is done 48 times, and the statistics is carried out by a box plot. This method is noted as *subject-specific training* in further chapters.

Apart from that, the grand total evaluation is also performed. In this setup, the test set is constructed by randomly chosen trials in all subjects, what is left constructed the train and validation set. Data balancing is considered in this split by the distribution of different EEG labels (such as `Locus` and `SexOfSpeaker`) are balanced between training set and test set. This method is noted as *grand-total training* in further chapters.

Speaking of the labeling of EEG, we found that if we balance EEG tested in different SNR setup (i.e. split high-SNR EEG trials between training set and test set so that the percentage of high-SNR trials are identical in both sets), the accuracy is relatively low. Thus, we proposed to use the model trained on high-SNR trials as a pre-trained model, and fine-tune the model on low-SNR trials with a smaller learning rate. Currently, this method is only tested in CNN baseline and dilated CNN.

## Linear Regression

In linear regression, several parameters listed below are able to be fine-tuned.

- *Different strategies to split training and test dataset*. As mentioned above, this gives opportunity to do subject-specific training and grand-total training.
- *Regularization matrix*. When using Least Squares to perform regression, the dimension of the autocorrelation matrix $\tilde R_k$ is rather large compared to the trials, resulting into an ill-conditioned $\tilde R_k$. According to [@linear_regression], regularization metrics can be applied to prevent this from happening. Identity matrix and discrete derivative matrix is applied and tested. Accordingly, the regularization parameter $\lambda$ is also able to be fine-tuned.
- *Window length*. Apparently, increasing window size can boost accuracy with a cost of increasing latency.

Figure \ref{lr_lmbd_04_matrix_id_subj} shows the effect of different window lengths with the setup of 1) subject-specific training, 2) $\lambda=0.04$, and 3) use identity matrix as regularization matrix. Figure \ref{lr_lmbd_04_matrix_dd_subj} shows the effect of different window lengths with the setup of 1) subject-specific training, 2) $\lambda=0.04$, and 3) use discrete derivative matrix as regularization matrix.

![accuracy over different window sizes\label{lr_lmbd_04_matrix_id_subj}](./0_Images/lr_lmbd_04_matrix_id_subj.bmp)

![accuracy over different window sizes\label{lr_lmbd_04_matrix_dd_subj}](./0_Images/lr_lmbd_04_matrix_dd_subj.bmp)

### Errors

It is clear that the linear model doesn't work. We started linear regression based on the successful code of previous year's work, so the results are unexpected. We tried to debug based on the alignment of data and the `nearlySingularMatrix` warning produced by MATLAB while computing the least square.

For the ill-conditioned matrix problem, We found that when discrete derivative matrix is used, when $\lambda$ is set to 0.04, it is likely that for subject 3, 8, 9, 11, 14, 19, 27, and 31, least square procedure returns the `nearlySingularMatrix` warning almost every time.

Then, We explored the impact of different window sizes, regularization matrix over the total number of "ill conditioned least square" instances. The ratio between number of ill-conditioned least square operations and total number of least square operations (the ratio for short) is evaluated. We found that:

- When using discrete derivative regularization matrix, the ill-conditioned problem always stays inside the subjects listed above.
- When using identity regularization matrix, the ratio increases when the window length decreasing. For window lengths of `{50,25,10}` ms, the ratios are `{0.40,0.78,0.99}`. This is expected because of the amount of data used to calculate $\tilde{R_t}$ is not sufficient, as noted in Chapter 2.C of [@linear_regression].

## CNN

### General Information

To make sure that there is no (potential) error in dataset split propagated from linear regression, we rewrote the dataset generation function for CNN. Then, we implemented the baseline model along with the dilated convolutional network denoted in [@CNN].

We follow the above strategies to tune the parameters:

- The baseline model is trained effectively by applying early stopping strategy which monitors the validation loss. If the validation loss does not decrease after 20 epochs, then the training process is stopped. The results are evaluated over test set separated from the given dataset.
- Then, the baseline model is set to free-running for 100 epochs. The underlying reasoning is that we do not know whether the network has sufficient parameters to capture the non-linearity of the EEG signal. If the validation accuracy stucked after certain epochs and the network cannot overfit the training data even after 100 epochs, then the network is considered under-parameterized.
- If the network is under-parameterized, then additional changes of layers are tested inorder to add more parameters. This includes increasing tohe number of convolution kernels, the number of convolutional layers, etc. Then, the network is set to free-running. If a valley in validation loss is found accompanied with a steady decrease of training loss, then the network is overparameterized. We tried to increase the number of parameters steadily until this is observed.
- The last step is to fine-tune the network by using regularization methods such as dropout.

For realizing these strategies, several additional methods are implemented and concatenated in the training/testing process.

- *Model checkpoint.* The intermediate weights of the network can be saved based on some user-defined strategies such as: *save when the validation accuracy outperforms all previous epochs*. This can be realized using `keras.callbacks.ModelCheckpoint`. Moreover, by saving checkpoints, additional opportunity to manually choose the weights at the exact time when the network is not overfitting to training set based on the loss and accuracy curve is given.
- *Learning rate scheduler*. In order to prevent the network from overfitting during larger epochs, leaining rate is set differently with respect to different epoch checkpoints. When fine-tuning the high SNR model over low SNR dataset, the learning rate is set smaller than the pre training process.
- *Early stopping*. This method gives opportunities to automatically stop the training procedure based on the user-defined criterias such as *stop when the validation loss does not decrease after 20 epochs (with a fluctuation tolerance of 5%)*. The fluctuation tolerance can be tuned based on the loss curves trained previously.

The final part is to normalize the data. The original pre-processed EEG training data has a mean of $1\cdot 10^{-10}$ and a standard derivation of $11$, while the mean and standard derivation of envelope are $7\cdot 10^{-4}$ and $0.24$, respectively. Especially for EEG signal with the large standard derivation, if is not normalized, then issues like:

- performs badly when evaluating data from unknown subjects whose distribution is different from the training set,
- potential gradient exploding during training,

will occur during training. Here, the normalization strategy is taken place in data preparation. The EEG and envelope data is normalized to normal distribution per channel. However, because of the limited amount of RAM in Google Colab, We normalized the EEG and envelope data based on the overall channel statistics.

Last to mention, we trained two SNR-specific models both for baseline CNN model and dilated CNN model. The details and necessary data we collected are noted in the last part of the following two chapters. Dataset is splitted into low-SNR part and high-SNR part before the pre=training and fine-tuning procedure due to the limitation of RAM in Google Colab. If the code is to be tested, there is potential crash of RAM before fine-tuning.

## CNN: Baseline

Figure \ref{exp_1_accu} and \ref{exp_1_loss} show the accuracy and loss curves of the baseline model.

![Accuracy (Original Baseline)\label{exp_1_accu}](./0_Images/exp_1_accu.png)

![Loss (Original Baseline)\label{exp_1_loss}](./0_Images/exp_1_loss.png)

The performance evaluated over test set is 73.72% which is reasonable compared to the results in [@CNN]. From Figure \ref{exp_1_accu} and \ref{exp_1_loss}, we can see that:

- Early stopping is triggered at epoch 35. The early stopping criteria is set as *stop when validation accuracy is not increasing for 10 consecutive epochs*.
- Loss stays almost constant at around 0.75. It is reasonable to assume that the network is under-parameterized. To further reason this assumption, a free-running version of this experiment is applied consecutively.

Figure \ref{exp_2_accu} and \ref{exp_2_loss} show the accuracy and loss curves of the free-running baseline model.

![Accuracy (Free Running Baseline)\label{exp_2_accu}](./0_Images/exp_2_accu.png)

![Loss (Free Running Baseline)\label{exp_2_loss}](./0_Images/exp_2_loss.png)

The performance evaluated over test set is 72.73%. We can see that the main trend of validation curve is almost identical to experiment 1. The fluctuation is mainly caused by randomness hidden in the Adam optimizer. Next several experiments added more parameters by increasing kernel size and/or number of kernels.

The original `CONV1D` kernel size is `(16,64)`, whose second dimension is the number of EEG channels. Considering 70 Hz sample rate of the preprocessed EEG signal, the kernel size is set to `(16,64)`, 16 samples of preprocessed EEG signal represent a time lapse of 250 ms, which is aligned to the optimal rceptive field introduced in [@linear_regression]. However, [@CNN] conclude that the optimal receptive field is 250-500 ms. This is tested by using a kernel size of `(32,64)`. Figure \ref{exp_4_accu} and \ref{exp_4_loss} show the accuracy and loss curves of the model whose receptive field is approximately 500 ms.

![Accuracy (500 ms Receptive Field)\label{exp_4_accu}](./0_Images/exp_4_accu.png)

![Loss (500 ms Receptive Field)\label{exp_4_loss}](./0_Images/exp_4_loss.png)

The performance evaluated over test set is 79.94%. From the figure, we can clearly see the effect of adding more parameters (non-linearity) to the training process. In Figure \ref{exp_4_loss}, the difference of losses becomes drastically smaller with the increase of epochs, which is not observed clearly in Figure \ref{exp_2_loss}. This result provides practical evidence for "under-parameterized baseline model" assumption mentioned above.

After the baseline model is fine-tuned and the best variant is selected, a fine-tuning version of a low-SNR-specific model is trained and fine-tuned. The performance evaluated over test set is 72.69%, and the accuracy and loss trend during fine-tuning is shown in Figure \ref{exp_7_accu} and \ref{{exp_7_loss}.

![Accuracy (Fine-Tuned Model for SNR=4)\label{exp_7_accu}](./0_Images/exp_7_accu.png)

![Loss (Fine-Tuned Model for SNR=4)\label{exp_7_loss}](./0_Images/exp_7_loss.png)

**The labels of test set for baseline CNN model is provided by using this model.** As a sidenote of this part, the SNR-specific model is not implemented and tested over baseline CNN and its variants, but is tested in dilated CNN model and its variants, which are presented in the following chapter. Also, different optimizers (RMSProp, SGD) are tested, but the variation of the  test accuracy is less than 1%, which is rather trivial to be concluded in the report. Further experiments like a grid search over window length and kernel size are also need to be done to get a better conclusion.

## CNN: Dilated Convolution

Dilated convolution is designed to maximizing receptive field while keeping the number of parameters low, which will make the network easier to train. The baseline model of dilated convolution stated in [@CNN] is implemented and fine-tuned. The accuracy and loss curves are shown in Figure \ref{exp_5_accu} and \ref{exp_5_loss}, respectively.

![Accuracy (Fine-Tuned Dilated Convolutional Network)\label{exp_5_accu}](./0_Images/exp_5_accu.png)

![Loss (Fine-Tuned Dilated Convolutional Network)\label{exp_5_loss}](./0_Images/exp_5_loss.png)

The number of layers are set to 3 and the kernel size is 3. This parameter setting is chosen based on the best result obtained in Fig.3 of [@CNN]. The performance evaluated over test set is 93.02%. An accuracy this high is comparable, but doubtful. For further investigation, the dataset used is double checked after the report, and an evidence of "the best performance of baseline CNN model trained over the same dataset never exceeds 75%" is obtained.

From Figure \ref{exp_5_accu}, an interesting observation is that during initial epochs, the validation accuracy is stucked in 0. It is not desired since the accuracy of random guess is 0.5. *We didn't get the reasoning of 0 accuracy over validation set.* During training, we encountered the problem of 'loss stays the same as the initial epochs' and the problem is solved by running multiple experiments with random network weight initializations.

The fine-tuning version of a low-SNR-specific dilated CNN model is trained and fine-tuned after that. The performance evaluated over test set is 76.97%, and the accuracy and loss trend during fine-tuning is shown in Figure \ref{exp_6_accu} and \ref{exp_6_loss}.

![Accuracy (Dilated CNN for SNR=4)\label{exp_6_accu}](./0_Images/exp_6_accu.png)

![Loss (Dilated CNN for SNR=4)\label{exp_6_loss}](./0_Images/exp_6_loss.png)

## References