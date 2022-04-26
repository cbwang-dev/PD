clear accuracy;

% evaluate lambda = 0.4, discrete derivative, on differnet window length.
% load variables_accuracy_regularizedLS_lambda_0.4_windowlen_50_Q_2.mat
% accuracy_50 = accuracy; clear accuracy;
% load variables_accuracy_regularizedLS_lambda_0.4_windowlen_25_Q_2.mat
% accuracy_25 = accuracy; clear accuracy;
% load variables_accuracy_regularizedLS_lambda_0.4_windowlen_10_Q_2.mat
% accuracy_10 = accuracy; clear accuracy;
% load variables_accuracy_regularizedLS_lambda_0.4_windowlen_5_Q_2.mat
% accuracy_5 = accuracy; clear accuracy;
% load variables_accuracy_regularizedLS_lambda_0.4_windowlen_2_Q_2.mat
% accuracy_2 = accuracy; clear accuracy;
% load variables_accuracy_regularizedLS_lambda_0.4_windowlen_1_Q_2.mat
% accuracy_1 = accuracy; clear accuracy;
% boxplot([accuracy_50 accuracy_25 accuracy_10 accuracy_5 accuracy_2 accuracy_1], 'Labels', {'50','25','10','5','2','1'});ylim([0 1]);
% xlabel('window size'); ylabel('accuracy');
% title('linear regression accuracy w.r.t window size')
% subtitle('lambda = 0.4, discrete derivative regularization matrix, train & test over each subj');


load variables_accuracy_regularizedLS_lambda_0.4_windowlen_50_Q_1.mat
accuracy_50 = accuracy; clear accuracy;
load variables_accuracy_regularizedLS_lambda_0.4_windowlen_25_Q_1.mat
accuracy_25 = accuracy; clear accuracy;
load variables_accuracy_regularizedLS_lambda_0.4_windowlen_10_Q_1.mat
accuracy_10 = accuracy; clear accuracy;
load variables_accuracy_regularizedLS_lambda_0.4_windowlen_5_Q_1.mat
accuracy_5 = accuracy; clear accuracy;
load variables_accuracy_regularizedLS_lambda_0.4_windowlen_2_Q_1.mat
accuracy_2 = accuracy; clear accuracy;
load variables_accuracy_regularizedLS_lambda_0.4_windowlen_1_Q_1.mat
accuracy_1 = accuracy; clear accuracy;
boxplot([accuracy_50 accuracy_25 accuracy_10 accuracy_5 accuracy_2 accuracy_1], 'Labels', {'50','25','10','5','2','1'});ylim([0 1]);
xlabel('window size'); ylabel('accuracy');
title('linear regression accuracy w.r.t window size')
subtitle('lambda = 0.4, identity regularization matrix, train & test over each subj');