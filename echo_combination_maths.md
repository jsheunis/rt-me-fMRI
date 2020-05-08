# Multi-echo fMRI and echo combination strategies
By Stephan Heunis

---

This document first provides some background information on multi-echo (ME) fMRI and its usefulness, and then focuses on mathematical equations and explanations for various strategies of echo combination.

- [Overview of multi-echo fMRI](#)
- [Background on summation and averaging](#)
- [Multi-echo combination methods](#)


## Multi-echo fMRI
Standard fMRI data is often acquired using an echo-planar imaging (EPI) sequence with a single echo, yielding a single $T_2^*$-weighted functional volume per time point, i.e. one image per repetition time (TR). This is done after transverse excitation in the scanner, at an echo time that has been simulated and tested to be optimal for  ME fMRI 

[...]

[more content to follow....]

[...]


## Summation, weighting and averaging

Before we look into the available multi-echo combination methods and how to apply them, let's focus sortly on the underlying concepts of data summation and averaging.

Say we have a dataset $\{x_{1},x_{2},\dots ,x_{n}\}$ with elements $x_i$. The dataset has corresponding weights $\{w_{1},w_{2},\dots ,w_{n}\}$ with elements $w_i$.

The notation for the dataset ***summation*** (or sum of the dataset) is given by:

$$
\sum_{i=i}^{n} x_{i}=x_{1}+x_{2}+\cdots+x_{n-1}+x_{n}
$$

The ***weighted summation*** is calculated as the summation of the dataset after multiplying each element with its corresponding weight, thus:

$$
\sum_{i=i}^{n} x_{i}w_{i}=x_{1}w_{1}+x_{2}w_{2}+\cdots+x_{n-1}w_{n-1}+x_{n}w_{n}
$$

Here, there are no restrictions on the values of the weights.

The ***weighted average*** or ***mean*** of the dataset is calculated by dividing the weighted summation by the sum of weights:

$$
\bar{x}_{w}=\frac{\sum_{i=1}^{n} w_{i} x_{i}}{\sum_{i=1}^{n} w_{i}} = \frac{w_{1} x_{1}+w_{2} x_{2}+\cdots+w_{n} x_{n}}{w_{1}+w_{2}+\cdots+w_{n}}
$$

A special case occurs when the weights are normalized (indicated by $w_{i}^{\prime}$) such that the sum of weights is equal to 1. Weights are normalized by dividing each weight element by the sum of weights, i.e.:

$$
w_{i}^{\prime}=\frac{w_{i}}{\sum_{j=1}^{n} w_{j}}
$$

And hence:

$$
\sum_{i=1}^{n} w_{i}^{\prime}=1
$$

Calculating the weighted average of the dataset using normalized weights, we then get:
 
$$
\bar{x}_{{w}^{\prime}}=\frac{\sum_{i=1}^{n} w_{i}^{\prime} x_{i}}{\sum_{i=1}^{n} w_{i}^{\prime}} =\sum_{i=1}^{n} w_{i}^{\prime} x_{i}
$$

since the denominator, the sum of weights, is equal to 1.

**It therefore follows that the *weighted average* of a dataset using ordinary non-normalized weights is equal to the *weighted summation* of the dataset when using normalized weights.**

Note also that the ordinary average or mean of the dataset ($\frac{1}{n} \sum_{i=1}^{n} x_{i}$)  is a special case of the weighted mean where all elements in the dataset have equal weights, $w_{i}=1$

Sources:
- https://en.wikipedia.org/wiki/Weighted_arithmetic_mean
- 

## Multi-echo combination methods

From [Posse et al. (1999)](https://doi.org/10.1002/(SICI)1522-2594(199907)42:1<87::AID-MRM13>3.0.CO;2-O)

$$
\hat{S}\left(t_{r}\right)=\sum_{n=1}^{N} S\left(t_{r}, T E_{n}\right)
$$

[Marxen et al. (2003)](https://www.frontiersin.org/articles/10.3389/fnhum.2016.00183/full)

>  To maximize blood oxygenation level dependent (BOLD) sensitivity in the amygdala, which suffers considerable susceptibility-related signal losses, we employed a multi-echo EPI sequence and online T∗2-weighted echo averaging optimized for the amygdala as described in our previous studies (Posse et al., 1999, 2003a). Functional data were acquired with six echoes (TR = 2.54 s, TE = 8.6, 18.3, 28, 38, 48, 57 ms, FOV = 192 × 192 × 132 mm3, voxel size = 4 × 4 × 3.2 mm3 with a slice gap of 25%, GRAPPA with ipat factor three and 42 reference lines, FA = 82°, BW = 2084 Hz/Px, slice orientation A > C, slice order: descending).

> Multi-echo images were combined using fixed TE-dependent weights 0.59, 0.90, 1, 0.97, 0.88, 0.77, which were selected for an average T∗2-value of 30 ms in the amygdala (Posse et al., 1999, 2003b). The fixed weights in this analysis minimized possible fluctuations due to instability in T∗2 fitting during the real-time scan, while only slightly reducing the maximum possible BOLD sensitivity in the rest of the brain.


https://www.sciencedirect.com/science/article/abs/pii/S1053811902000162?via%3Dihub

https://www.sciencedirect.com/science/article/abs/pii/S1053811903000041?via%3Dihub

https://www.sciencedirect.com/science/article/pii/S105381191500988X

https://www.tandfonline.com/doi/full/10.1080/14459795.2018.1449884

https://cds.ismrm.org/ismrm-2008/files/03562.pdf

https://github.com/Donders-Institute/multiecho/blob/master/multiecho/combination.py