---
title: 'P&D ISSP Phase 2 Report'
author: "Chengbin Wang"
fontsize: 10pt
geometry: margin=2cm
classoption: twocolumn
bibliography: "./markdown_notes/biblio.bib"
---

## Data Preprocessing

This chapter explains the choices involved for splitting training set and test (or validation) set and set some notations for further chapters.

For subject-specific results, we use leave-one-out strategy to evaluate the effectiveness of models, both linear models (with and without regularization) and CNN models. For example, there are 24 trials of high SNR in each subject, then we use the same model trained over 24 different groups and evaluate the results over 24 leaved out groups, then we draw a boxplot of these results as the finale of one experiment.

The most subtle problem in data preprocessing is the alignment of EEG and speech envelope regarding to the delay. Because of the biological efffect, human's EEG signal responds slower than the speech signal,

Different subjects has their different mappings.

## Least Square Regression

Several parameters are concerned in applying least square to design auditory attention decoders.

- *Different strategies to split training and test dataset*. 
- *Regularization matrix*. When using Least Squares to perform regression, the dimension of the autocorrelation matrix $\tilde R_k$ is rather large compared to the trials, resulting into an ill-conditioned $\tilde R_k$. According to [@linear_regression]
- *Window length*. Apparently, increasing window size can boost accuracy with a cost of increasing latency.

The comparisions between different setups of these parameters are shown in Figure ...

## CNN: Baseline Model

First, we implemented the baseline model and the dilated convolutional network denoted in [@CNN].

make sure that you know why you are making certain choices and that you are able to motivate this!!! this is more important than pure accuracy.

- which building blocks
- how many parameters
- regularization
- overfitting
- loss functions

## CNN: Dilated Convolutional Network

before using deep neural nets, data still has to be normalized.

## References