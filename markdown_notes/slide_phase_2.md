---
title: 'P&D ISSP P.2 G.7 Report'
author: "Chengbin Wang"
date: '2022-04-26'
fontsize: 8pt
bibliography: "./markdown_notes/biblio.bib"
---

# data preprocessing

## data alignment & windowing

### current method

`train_test_split.m` concatenate the "desired" trials (both EEG and envelope) together to form training and validation set.

EEG data (of the concatenated training and validation set) is then lagged for 250 ms, then linear regression is performed.

### drawback

![example of EEG & envelope alignment](./0_Images/alignment.png)

because of inconsistancy of information across trial's borders, window denoted in red is problematic.This problem is left unsolved.

## data balancing

### SNR

- given in test set, so SNR specific model can be used.
- train a `SNR=100` model and fine tune it over `SNR=20` data with a smaller learning rate. apply only in CNN.
- train two SNR specific models (linear regression and CNN) and test the data w.r.t different SNRs.

### `Locus` and `SexOfSpeaker`

- can only be balanced in training set and validation set because of no knowledge of these information over given test set.
- ~~this balancing is a bonus point but is not implemented...~~

# linear regression

## overview

"subject specific" results and "grand-total" results (defined later) are obtained.

### tunable parameters

- `window_len`. how much information used to predict one point of envelope
- regularization strength. `lambda`.
- regularization matrix. identity matrix or discrete derivative matrix.

### tunable strategies

- subject specific: `main_LR_subject.m`. train and test over each subject only & leave one out strategy (see slide 4 in linear regression).
- grand total: `main_LR_all.m`. train over training data chosen from *all* subjects & test individially over validation set of *every* subject.
- ~~(data alignment) maybe there are some better strategies...~~

## subject specific: pseudo code of the process

```txt
accuracy=zeros(len(subjects));
for subject in subjects:
  correct=0;count=0;
  for val_trial in trials:
    train_test_split(subject_specific);
    # obtain subject specific training and validation set
    train(training_set);
    correct=test(test_set);count=count+1;
  end
  accuracy(subject)=correct/count;
end
boxplot(accuracy)
```

### remarks

- one attempt `{window_len, lambda, matrix}` takes about 1697 seconds.
- for saving presentation time, code output is shown next page.
- train and test over one specific subject. use leave one out cross validation strategy to evaluate.
- because of leave one out, train test split ratio is 47:1.

## subject specific: example output

```txt
> main_LR_subject
INFO: suppress warning nearlySingularMatrix
INFO: lambda value is 0.40
INFO: regularizer: discrete derivative regularizer.
INFO: window length: 50 ms.
>OUT: accuracy of subject 001 : 0.541667 WARNING: 0
>OUT: accuracy of subject 002 : 0.604167 WARNING: 1
>OUT: accuracy of subject 003 : 0.479167 WARNING: 47
>OUT: accuracy of subject 004 : 0.645833 WARNING: 1
>OUT: accuracy of subject 005 : 0.583333 WARNING: 0
>OUT: accuracy of subject 006 : 0.500000 WARNING: 0
>OUT: accuracy of subject 007 : 0.666667 WARNING: 0
>OUT: accuracy of subject 008 : 0.604167 WARNING: 47
>OUT: accuracy of subject 009 : 0.895833 WARNING: 48
>OUT: accuracy of subject 010 : 0.562500 WARNING: 0
>OUT: accuracy of subject 011 : 0.452381 WARNING: 42
>OUT: accuracy of subject 012 : 0.638298 WARNING: 0
>OUT: accuracy of subject 013 : 0.680851 WARNING: 0
>OUT: accuracy of subject 014 : 0.531915 WARNING: 46
>OUT: accuracy of subject 015 : 0.510638 WARNING: 0
...
```

## subject specific: finding best parameter combination

### motivation

- because of the time consumed for one whole evaluation is long, estimate the effect of window length first. then for the best window size, try different combinations of lambda and regularization matrix.
- intuition: window size bigger, more information used to determine one point of envelope. so window size is tried first.
- parameters preference of subject specific scenarios are taken into account when testing grand total scenarios as default.

## subject specific results (1)

:::: {.columns}
::: {.column width="60%"}

![accuracy over different window sizes](./0_Images/lr_lmbd_04_matrix_id_subj.bmp){width=250}

:::
::: {.column width="40%"}

### details

- lambda=0.4
- identity matrix
- evaluated over different window sizes
- train test split = 47:1, all data is used (no balancing)
- leave one out cross validation

### comments

- increase lambda?
- not enough training data?

:::
::::

## subject specific results (2)

:::: {.columns}
::: {.column width="60%"}

![accuracy over different window sizes](./0_Images/lr_lmbd_04_matrix_dd_subj.bmp){width=250}

:::
::: {.column width="40%"}

### details

- lambda=0.4
- discrete derivative matrix
- evaluated over different window sizes
- train test split = 47:1, all data is used (no balancing)
- leave one out cross validation

### comments

- ill-conditioned. (see next slides)
- increase lambda?
- not enough training data?

:::
::::

## ill-conditioned $\tilde{R_t}$`.intro`

### questions

- what regularization martix is better? identity matrix (ridge regression) or discrete derivative matrix?
- what should be penalized? L2 norm of $d$ or discrete derivative of $d$?
- when will the ill-conditioned matrix occur?

### answers

- experiment evidence: see next slides

## ill-conditioned $\tilde{R_t}$`.evidence`

| subject | accuracy | warnings | subject | accuracy | warnings | subject | accuracy | warnings |
| ------- | -------- | -------- | ------- | -------- | -------- | ------- | -------- | -------- |
| 1       | 0.5416   | 0        | 14      | 0.5319   | 46       | 27      | 0.4255   | 47       |
| 2       | 0.6041   | 1        | 15      | 0.5106   | 0        | 28      | 0.6595   | 0        |
| 3       | 0.4791   | 47       | 16      | 0.5106   | 1        | 29      | 0.5744   | 0        |
| 4       | 0.6458   | 1        | 17      | 0.6170   | 0        | 30      | 0.5744   | 0        |
| 5       | 0.5833   | 0        | 18      | 0.6829   | 0        | 31      | 0.5744   | 46       |
| 6       | 0.5000   | 0        | 19      | 0.6808   | 46       | 32      | 0.6808   | 0        |
| 7       | 0.6667   | 0        | 20      | 0.4255   | 1        | 33      | 0.5365   | 0        |
| 8       | 0.6042   | 47       | 21      | 0.4468   | 0        | 34      | 0.5106   | 0        |
| 9       | 0.8958   | 48       | 22      | 0.6808   | 0        | 35      | 0.4042   | 0        |
| 10      | 0.5625   | 0        | 23      | 0.7428   | 0        | 36      | 0.5957   | 0        |
| 11      | 0.4523   | 42       | 24      | 0.5531   | 0        | 37      | 0.5957   | 0        |
| 12      | 0.6382   | 0        | 25      | 0.5106   | 0        | --      | ---      | ---      |
| 13      | 0.6805   | 0        | 26      | 0.6829   | 1        | --      | ---      | ---      |

### remarks

- `{window_len=50ms, lambda=0.4, matrix=discreteDerivative}`
- tried different `lambda` while keeping `matrix` same. warnings still bump out in the same order (`corr(warn1,warn2)==1`).

## ill-conditioned $\tilde{R_t}$`.otherObservations`

$$
Q=\begin{bmatrix}
1  & -1 &        &        &        &    \\
-1 &  2 &     -1 &        &        &    \\
   & -1 &      2 & -1     &        &    \\
   &    & \ddots & \ddots & \ddots &    \\
   &    &        &     -1 &    2   & -1 \\
   &    &        &        &   -1   &  1
\end{bmatrix}
$$

### observation

- when using `matrix=discreteDerivative`, the warning message `nearlySingularMatrix` is always present for `lambda=0.2;0.4;0.6`.
- when using `matrix=eye` and `window_len=50ms`, *all* the warning message disappears, meaning that the condition of $\tilde{R_t}$ is good. 
- when`matrix=eye` and `window_len=25ms`, 40.5% of the calculated $\tilde{R_t}$ are experiencing numerical issues. 
- when `matrix=eye` and `window_len=10ms`, 78.3%; `window_len=5ms`, 99%, ...

## ill-conditioned $\tilde{R_t}$`.theoretical`

According to [@linear_regression]:

> This (discrete derivative matrix) can be preferred if the spatio-temporal decoder is expected to be smooth in the temporal dimension.

- not enough training data for the matrix if window size is set small.
- discrete derivative matrix need more training data (or bigger `lambda`) in order not to be ill conditioned.
- possibly some bugs in my code.
- this is left undone...

## grand total: pseudo code of the process

```txt
correct,count=zeros(len(subjects));
for experiment in experiments #get more tests for statistics
  for subject in subjects:
    train_test_split(grand_total,rand_trial_test);
  end % obtain training set and subject specific validation set
  train(training_set);
  for subject in subjects:
    for test_trial in test_set(subject):
      prediction=test(test_trial);
      correct(subject)+=prediction;count+=1;
    end
  end
end
accuracy=correct./count;
boxplot(accuracy)
```

### remarks

leave one out should be implemented, but cost time to execute, thus randomly choose 8 trials (~20%) from each subject as validation set. for more data to do statistics, randomly choose validation trials for `num_experiments`.

## grand total results (1)

## grand total results (2)

## conclusion over linear regression

- Accuracy is not as good as what is displayed in the slides (~70% median for window length of 50 ms).
- too much ill-conditioned matrixes during training with discrete derivative matrix.

# CNN in general

## tunable parameters

### dataset related parameters

- training and test split. cover the diversity among training, validation and test set.
  - subject-specific box plot not implemented because some subjects have less than 48 trials, imbalance, the alignment of `SNR=100` produces errors in my code.
- window length. 

## evaluation: is it a good network?

### train, validation and test accuracy curve

- if validation accuracy goes up after certain epochs, then it is necessary to apply early stopping. It also implies that the model is overfitting to training set.
- if validation & test accuracy is stuck around 70%, consider using a larger parameterized network.
- test set is to be splitted out form the dataset in order to prove that it is not overfitting to existant training & validation set. But it also reduces the amount of data to train the model. The trade-off is trivial for choosing correct network architectures and optimizing methods, because during testing over the pre-given test set, all the data is used as training and validation set.

### number of parameters

- if the number of parameters is set large, then there is a big possibility of overfitting to the dataset.

## evaluation: is it working properly?

- is weights updating? this problem occurs when the input data is not normalized.
- is the loss curve fluctuating rapidly? the possible underlying reason is the optimizer. TODO.
- is the network learning slowly? change the initialization of weight to another distribution.

## tricks (1)

### save the pretrained model

- `keras.callbacks.ModelCheckpoint`.
- save the model based on (validation loss or others) and other options.
- give opportunity to fine-tuning the model based on previous results.

### normalization

- dataset should be normalized in order to let the network learn faster and not stuck into weight numerical issues (weight is too small to be presented in limited precision).
- if used multi CNN layers and the learning is stucked,possibly the reason is that the feature maps in between different CNN layers are poorly conditioned. Thus, batch normalization [@batchnorm] can be considered.

### learning rate scheduler

- learning rate is set smaller when the number of epochs gets larger.
- prevent the network from overfitting in later epochs.
- best combined with early stopping (make sure that the saved model is not overfitting, because it is hard to fine tuning an overfitted model).

## tricks (2)

### early stopping

- if criterias are met (eg. `val_accu` ~increase for `n` epochs), then stop training and save the model.
- make experiments cheaper by stopping after certain epochs whose `val_accu` ~increase.

### model checkpoint

- save model parameters dynamically while monitoring `val_loss` (or others).
- give opportunity to grab the best performance evaluated over `val_loss` (or others).

### fine tuning

- fine-tuning the model over different subjects.
- fine-tuning the model for `SNR=4` noisy scenario based on the best model achieved over `SNR=100` scenario.

# baseline CNN

## roadmap

- start from [@CNN]. use easiest CNN architecture with early stopping and learning rate scheduler. (78.3%)
  - 1 CNN layer with 1 size `(16,64)` CONV kernel (parameters: 1025)
  - mimic the structure of linear regression.
- free running it, see if there is a valley in validation accuracy (overfit).
  - equivalent reception field (eg. 2 `(8,64)` == 1 `(15,64)`): #params and training characteristics
- add layers and CONV kernels size, redo step 2, till there is a valley. Catch that valley and evaluate the accuracy.
- add more regularization to conquer the "slightly overparameterized" problem.
- after achieving the best performance over `SNR=100` scenario, try to use a smaller learning rate to 
- end of baseline CNN trials and produce the last model, evaluate over given test set.

### remarks

for each experiments, best viewed in `exp_*.ipynb` if time permitted.

## baseline CNN results (1)

:::: {.columns}
::: {.column width="50%"}

![accuracy, exp 1](./0_Images/exp_1_accu.png){width=150}

![loss, exp 1](./0_Images/exp_1_loss.png){width=150}
:::
::: {.column width="50%"}

### details

- accuracy over test set: 73.72%.
- reasonable compared to the results in [@CNN].
- CONV: 1 layer with `(16,64),1` kernel.
- stop when `val_accu` not increasing for 10 epochs.
- save model dynamically based on best `val_accu`.

### comments

- run more epochs to see the capacity of this setup.
- not enough training data?

:::
::::

## baseline CNN results (2)

:::: {.columns}
::: {.column width="50%"}

![accuracy, exp 2](./0_Images/exp_2_accu.png){width=150}

![loss, exp 2](./0_Images/exp_2_loss.png){width=150}
:::
::: {.column width="50%"}

### details

- accuracy over test set: 72.73%
- free running version of experiment 1.
- best model epoch 147, accuracy over test set: 73.02%

### comments

:::
::::

## baseline CNN results (3)

:::: {.columns}
::: {.column width="50%"}

![accuracy, exp 3](./0_Images/exp_3_accu.png){width=150}

![loss, exp 3](./0_Images/exp_3_loss.png){width=150}
:::
::: {.column width="50%"}

### details

- accuracy over test set: 70.93%.
- CONV: 1 layer with `(16,64),2` kernel.
- stop when `val_accu` not increasing for 20 epochs.
- save model dynamically based on best `val_accu`.

### comments

- bad performance over validation set. reasoning: cosine similarity is calculated over each CONV out layers, dimension 3, so there are two elements for each cosine similarity. violate the intension of this similarity.

:::
::::

## baseline CNN results (4)

:::: {.columns}
::: {.column width="50%"}

![accuracy, exp 3](./0_Images/exp_4_accu.png){width=150}

![loss, exp 3](./0_Images/exp_4_loss.png){width=150}
:::
::: {.column width="50%"}

### details

- accuracy over test set: 79.94%
- CONV: 1 layer with `(32,64),1` kernel (which violates the 250 ms assumption)
- stop when `val_accu` not increasing for 20 epochs.
- save model dynamically based on best `val_accu`.

### comments

- bad performance over validation set. reasoning: cosine similarity is calculated over each CONV out layers, dimension 3, so there are two elements for each cosine similarity. violate the intension of this similarity.

:::
::::

# dilated CNN

## overview

- start from [@CNN].
- tunable parameters:
  - depth, kernel size, window length, 

## dilated CNN results (1)

:::: {.columns}
::: {.column width="50%"}

![accuracy, exp 5](./0_Images/exp_5_accu.png){width=150}

![loss, exp 5](./0_Images/exp_5_loss.png){width=150}
:::
::: {.column width="50%"}

### details

- accuracy over test set: 93.02%.

### comments

- it is tricky to get this result. I trained this model from scratch several times, and both loss is stucked after the initial several epochs. 
- random initialization of weights, and I get a good pretrained model, then based on this model, I do fine tuning over `SNR=100` scenario.
- the plot shows one successful training instance.

:::
::::

## dilated CNN results (2)

:::: {.columns}
::: {.column width="50%"}

![accuracy, exp 6](./0_Images/exp_6_accu.png){width=150}

![loss, exp 6](./0_Images/exp_6_loss.png){width=150}
:::
::: {.column width="50%"}

### details

- accuracy over test set: 76.97%.
- use pre-trained model from SNR 100 scenario to fine tune SNR 20 data.
- learning rate is set to 0.1 in firrst 40 epochs, then 0.05.

### comments

- training starts with a validation acuracy of 1%. Worse than random guess.
  - compared with baseline CNN fine-tuning (starting at 48.86%).

:::
::::

# reference