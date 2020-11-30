# Multi-echo fMRI and echo combination strategies
By Stephan Heunis

---

All widely used multi-echo combination schemes are based on the underlying concepts of data weighting, summation and averaging.

Say we have a dataset $\{x_{1},x_{2},\dots ,x_{n}\}$ with elements $x_i$, and the dataset has corresponding weights $\{w_{1},w_{2},\dots ,w_{n}\}$ with elements $w_i$.

The notation for the dataset ***summation*** is given by:

$$
\sum_{i=i}^{n} x_{i}=x_{1}+x_{2}+\cdots+x_{n-1}+x_{n}
$$

The ***weighted summation*** is calculated as the summation of the dataset after multiplying each element with its corresponding weight, thus:

$$
\sum_{i=i}^{n} x_{i}w_{i}=x_{1}w_{1}+x_{2}w_{2}+\cdots+x_{n-1}w_{n-1}+x_{n}w_{n}
$$

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

It therefore follows that the ***weighted average*** of a dataset using ordinary non-normalized weights is equal to the ***weighted summation*** of the dataset when using normalized weights.

Below, we present several multi-echo combination schemes, using the convention of ***weighted summation*** with ***normalized weights***.

<br>
  
## Multi-echo combination methods

The relaxation of the fMRI signal in a given voxel after transverse excitation,
assuming a mono-exponential decay model, is estimated as:

$$
S\left(t\right)= S_{0} \cdot e^{
\frac{-t}{T_{2}^{\ast}}} = S_{0} \cdot e^{-t \cdot R_{2}^{\ast}}
$$


hello


$$
S\left(t\right)= S_{0} \cdot e^{
\frac{-t}{T_{2}^{\ast}}} + \varepsilon = S_{0} \cdot e^{-t \cdot 
R_{2}^{\ast}} + \varepsilon
$$

$$
S\left(t\right) \approx S_{0} \cdot e^{
\frac{-t}{T_{2}^{\ast}}} = S_{0} \cdot e^{-t \cdot 
R_{2}^{\ast}}
$$

$$
TE = T_{2}^{\ast} 
\approx 30 ms \space @ \space 3T
$$

If we sample our data along this decay curve at specific echo times, Eq. X can be written as:

$$
S\left(TE\right)= S_{0} \cdot exp\left(
\frac{-TE}{T_{2}^{\ast}}\right)
$$

Simple echo summation assumes equal weights for all echoes (totaling $N$), which is calculated for an individual echo $n$ as:

$$
w_{n}^{SUM}=\frac{1}{N}
$$

The $T_{2}^{\ast}$-weighted combination scheme used by Posse et al. (1999) and termed "optimal combination" by Kundu et al. (2012), calculates the individual echo weights $w_{n}$:

$$
w_{n}^{T_{2}^{\ast}}=\frac{TE_{n} \cdot \exp \left(-T E_{n} / T_{2}^{*}\right)}{\sum_{i=1}^{N} TE_{i} \cdot \exp \left(-TE_{i} / T_{2}^{*}\right)}
$$

The PAID method put forward by Poser et al. (2006) uses the voxel-based tSNR measures at each echo as the weights:

$$
w_{n}^{tSNR}=\frac{tSNR_{n} \cdot TE_{n}}{\sum_{i=1}^{N} tSNR_{i} \cdot T E_{i}}
$$

Using each echo's echo time, $TE_{n}$, as the weight for that echo has also been used:

$$
w_{n}^{TE}=\frac{TE_{n}}{\sum_{i=1}^{N} TE_{i}}
$$

$$
w_{n}^{SW}=\frac{SW_{n}}{\sum_{i=1}^{N} SW_{i}}
$$

Finally, as proposed in the introduction the per-volume estimation of $T_{2}^{\ast}$ at each voxel, also termed $T_{2 FIT}^{\ast}$, can also be used as the weighting factor in a per-volume echo comination scheme:

$$
w_{n}^{T_{2}^{\ast}FIT}=\frac{TE_{n} \cdot \exp \left(-T E_{n} / T_{2}^{*}FIT\right)}{\sum_{i=1}^{N} TE_{i} \cdot \exp \left(-TE_{i} / T_{2}^{*}FIT\right)}
$$



<br>
<br><br><br><br><br><br>
---



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