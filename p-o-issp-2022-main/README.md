# Phase 2: P&amp;O ISSP: Brain-computer interface voor sturing van een directionele akoestische zoom

## Main dependencies

This code is written in python. To use it you will need:

* Python 3.7
* Keras 2.3.1
* Tensorflow 2.1.0
* Numpy 1.18.1
* Scipy 1.1.0
* Matplotlib
* H5py
* JupyterLab
* Jupyter Notebook

## Getting started

- This code can be executed in jupyter/ipython notebook environment.
- Clone the repository, you can directly clone it from inside the jupyter notebook environment using: ```git clone https://github.com/abskjha/p-o-issp-2021.git```
- Online services like [Google Colaboratory](https://colab.research.google.com/notebooks/intro.ipynb#recent=true), Kaggle etc also provide jupyter notebook environments.

To open these notebooks in Google Colab:

- Login to your Google Colab account.
- Open a new notebook. In code cell enter: ```!git clone https://github.com/abskjha/p-o-issp-2021.git```

**Note:** Google Colab allows active session upto 12hrs. After 12 hrs, the session expires and all the data in the environment is **deleted**. Therefore, **ALWAYS keep a backup**. Another way to solve this is by saving the code and data in google drive and mounting google drive on colab:

```python
from google.colab import drive
drive.mount('/content/drive')
```
- The notebooks provided here contain images. In case you are running the code from google drive mount, those links may appear to be broken, change the image path accordingly in the respective markdown cells.

- To run the EEG experiments, you would require to download the dataset from the source directly sent to you.

## Sequence

(There's no sequence as such regarding which tutorial to run first. If you are new to python you can follow the following sequence:)

- Basics_Python.ipynb
- Basics_Visualization_matplotlib.ipynb
- Basic_keras.ipynb
- MNIST_digit_classification_using_keras.ipynb
- CNN_S_D.ipynb



## Disclaimer

This sample code is only a sample and is NOT guaranteed to be bug-free and production quality. The code provided here is solely for the purpose of learning. This is NOT intended to be used in production environment. You must adapt the code to work with your custom application.

We don't endorse or promote any of the 3rd party services. All the liabilities rest with the end-user.

Some parts of this code have been adapted/added from other sources. Proper references and credits have been provided inside the notebooks. Intimation of any missing source will be appreciated.

