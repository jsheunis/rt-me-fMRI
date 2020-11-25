# -*- coding: utf-8 -*-
import os
import pandas as pd
import numpy as np
import plotly.graph_objs as go
from plotly.colors import sequential, n_colors


def reset_tsnr_summary(fig, data_dir, tsnr_region, tsnr_run):

    if tsnr_region == 'whole brain':
        tsnrmean_fn = os.path.join(data_dir, 'multiecho', 'sub-all_task-all_desc-GMtsnrmean.tsv')
    else:
        tsnrmean_fn = os.path.join(data_dir, 'multiecho', 'sub-all_task-all_desc-' + tsnr_region + 'GMtsnrmean.tsv')


    df_tsnrmean = pd.read_csv(tsnrmean_fn, sep='\t')
    data2 = []
    ts_names2 = ['echo-2', 'combinedMEtsnr', 'combinedMEt2star', 'combinedMEte', 'combinedMEt2starFIT', 't2starFIT']
    ts_names2_disp = ['Echo 2', 'tSNR-combined', 'T2*-combined', 'TE-combined', 'T2*FIT-combined', 'T2*FIT']

    if tsnr_run == 'all runs':
        cols_tasksruns = ['fingerTapping', 'emotionProcessing', 'rest_run-2', 'fingerTappingImagined','emotionProcessingImagined']
    else:
        cols_tasksruns = [tsnr_run]

    for x, ts in enumerate(ts_names2):
        for c, coltaskrun in enumerate(cols_tasksruns):
            txt = coltaskrun + '_' + ts
            if c == 0:
                temp_dat = df_tsnrmean[txt].to_numpy()
            else:
                temp_dat = np.concatenate((temp_dat, df_tsnrmean[txt].to_numpy()))
        data2.append(temp_dat)
        fig.add_trace(go.Violin(y=data2[x], line_color=sequential.Inferno[3+x], name=ts_names2_disp[x], points='all', pointpos=-0.4, meanline_visible=True, width=1, side='positive', box_visible=True))

    fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False, violinmode='group')

    return fig

def reset_tval_summary_img(fig, data_dir, task, summary_opt, cluster_opt):

    tval_fn = os.path.join(data_dir, 'multiecho', 'sub-all_task-' + task + '_desc-' + summary_opt +'Tvalues.tsv')
    df_tval = pd.read_csv(tval_fn, sep='\t')
    data = []
    ts_names = ['Echo 2', 'tSNR-combined', 'T2*-combined', 'TE-combined', 'T2*FIT-combined', 'T2*FIT']
    ts_colnames = ['echo2', 'combTSNR', 'combT2STAR', 'combTE', 'combT2STARfit', 'T2STARfit']

    for x, ts in enumerate(ts_colnames):
        txt = ts + '_' + cluster_opt
        temp_dat = df_tval[txt].to_numpy()
        data.append(temp_dat)
        fig.add_trace(go.Violin(y=data[x], line_color=sequential.Agsunset[0+x], name=ts_names[x], points='all', pointpos=-0.4, meanline_visible=True, width=1, side='positive', box_visible=True))

    fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False, violinmode='group') # , legend={'traceorder':'reversed'}

    return fig



def reset_realtime_summary_img(fig, data_dir, cnr_opt, task, cluster_opt, psc_opt):

    if psc_opt == 'glm':
        cnr_fn = os.path.join(data_dir, 'sub-all_task-' + task + '_desc-' + cluster_opt +'_ROI' + cnr_opt + '.tsv')
        df_cnr = pd.read_csv(cnr_fn, sep='\t')
        data = []
        ts_names = ['Echo 2', 'tSNR-combined', 'T2*-combined', 'TE-combined', 'T2*FIT-combined', 'T2*FIT']
        rtts_colnames = ['RTecho2', 'RTcombinedTSNR', 'RTcombinedT2STAR', 'RTcombinedTE', 'RTcombinedRTt2star', 'RTt2starFIT']
        for x, ts in enumerate(rtts_colnames):
            txt = 'glm_' + ts
            temp_dat = df_cnr[txt].to_numpy()
            data.append(temp_dat)
            fig.add_trace(go.Violin(y=data[x], line_color=sequential.Viridis[3+x], name=ts_names[x], points='all', pointpos=-0.4, meanline_visible=True, width=1, side='positive', box_visible=True))
        fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False, violinmode='group') # , legend={'traceorder':'reversed'}
    else:
        cnr_fn = os.path.join(data_dir, 'sub-all_task-' + task + '_desc-realtimeROI' + cnr_opt + '_' + psc_opt + '.tsv')
        df_cnr = pd.read_csv(cnr_fn, sep='\t')
        data = []
        ts_names = ['Echo 2', 'tSNR-combined', 'T2*-combined', 'TE-combined', 'T2*FIT-combined', 'T2*FIT']
        rtts_colnames = ['RTecho2', 'RTcombinedTSNR', 'RTcombinedT2STAR', 'RTcombinedTE', 'RTcombinedRTt2star', 'RTt2starFIT']
        # realtimeROItcnr
        for x, ts in enumerate(rtts_colnames):
            txt = ts + '_' + cluster_opt
            temp_dat = df_cnr[txt].to_numpy()
            data.append(temp_dat)
            fig.add_trace(go.Violin(y=data[x], line_color=sequential.Viridis[3+x], name=ts_names[x], points='all', pointpos=-0.4, meanline_visible=True, width=1, side='positive', box_visible=True))
        fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False, violinmode='group') # , legend={'traceorder':'reversed'}

    return fig