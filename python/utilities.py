# -*- coding: utf-8 -*-
import os
import pandas as pd
import numpy as np
import plotly.graph_objs as go
from plotly.colors import sequential, n_colors

# Colormaps from https://colorbrewer2.org/#type=qualitative&scheme=Dark2&n=6
colors = [['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c', '#fb9a99', '#e31a1c'],
           ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#ffff33'],
           ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3', '#fdb462'],
           ['#1b9e77', '#d95f02', '#7570b3', '#e7298a', '#66a61e', '#e6ab02']]

def reset_tsnr_summary(fig, data_dir, tsnr_region, tsnr_run):

    if tsnr_region == 'whole brain':
        tsnrmean_fn = os.path.join(data_dir, 'multiecho', 'sub-all_task-all_desc-GMtsnrmean.tsv')
    else:
        tsnrmean_fn = os.path.join(data_dir, 'multiecho', 'sub-all_task-all_desc-' + tsnr_region + 'GMtsnrmean.tsv')


    df_tsnrmean = pd.read_csv(tsnrmean_fn, sep='\t')
    data2 = []
    ts_names2 = ['echo-2', 'combinedMEtsnr', 'combinedMEte', 'combinedMEt2star', 'combinedMEt2starFIT', 't2starFIT']
    ts_names2_disp = ['Echo 2', 'tSNR-combined', 'TE-combined', 'T2*-combined', 'T2*FIT-combined', 'T2*FIT']

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
        fig.add_trace(go.Violin(y=data2[x], line_color=colors[3][x], name=ts_names2_disp[x], points='all', pointpos=-0.4, meanline_visible=True, width=1, side='positive', box_visible=True))

    fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False, violinmode='group', font=dict(size=16))


    for i, ts in enumerate(ts_names2): 
        nl = '<br>'
        mean = np.nanmean(data2[i])
        fig.add_annotation(
            x=i,
            y=mean,
            xref="x",
            yref="y",
            text=f"Mean=<br>{mean:.2f}",
            showarrow=True,
            font=dict(
                family="Courier New, monospace",
                size=17,
                color="#000000"
                ),
            align="center",
            arrowhead=6,
            arrowsize=0.5,
            arrowwidth=1.5,
            arrowcolor="#000000",
            ax=35,
            ay=-90,
            bordercolor="#000000",
            borderwidth=1.5,
            borderpad=4,
            bgcolor=colors[3][i],
            opacity=0.8
            )

    return fig

def reset_tval_summary_img(fig, data_dir, task, summary_opt, cluster_opt):

    tval_fn = os.path.join(data_dir, 'multiecho', 'sub-all_task-' + task + '_desc-' + summary_opt +'Tvalues.tsv')
    df_tval = pd.read_csv(tval_fn, sep='\t')
    data = []
    ts_names = ['Echo 2', 'tSNR-combined', 'TE-combined', 'T2*-combined', 'T2*FIT-combined', 'T2*FIT']
    ts_colnames = ['echo2', 'combTSNR', 'combTE', 'combT2STAR', 'combT2STARfit', 'T2STARfit']

    for x, ts in enumerate(ts_colnames):
        txt = ts + '_' + cluster_opt
        temp_dat = df_tval[txt].to_numpy()
        data.append(temp_dat)
        fig.add_trace(go.Violin(y=data[x], line_color=colors[3][x], name=ts_names[x], points='all', pointpos=-0.4, meanline_visible=True, width=1, side='positive', box_visible=True))

    fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False, violinmode='group', font=dict(size=16))

    for i, ts in enumerate(ts_names): 
        nl = '<br>'
        mean = np.nanmean(data[i])
        fig.add_annotation(
            x=i,
            y=mean,
            xref="x",
            yref="y",
            text=f"Mean=<br>{mean:.2f}",
            showarrow=True,
            font=dict(
                family="Courier New, monospace",
                size=17,
                color="#000000"
                ),
            align="center",
            arrowhead=6,
            arrowsize=0.5,
            arrowwidth=1.5,
            arrowcolor="#000000",
            ax=35,
            ay=-90,
            bordercolor="#000000",
            borderwidth=1.5,
            borderpad=4,
            bgcolor=colors[3][i],
            opacity=0.8
            )

    return fig



def reset_psc_summary_img(fig, data_dir, task, summary_opt, cluster_opt):
    
    psc_fn = os.path.join(data_dir, 'multiecho', 'sub-all_task-' + task +'_desc-' + summary_opt +'PSCvalues.tsv')
    df_psc = pd.read_csv(psc_fn, sep='\t')
    data = []
    ts_names = ['Echo 2', 'tSNR-combined', 'TE-combined', 'T2*-combined', 'T2*FIT-combined', 'T2*FIT']
    ts_colnames = ['echo2', 'combTSNR', 'combTE', 'combT2STAR', 'combT2STARfit', 'T2STARfit']

    for x, ts in enumerate(ts_colnames):
        txt = ts + '_' + cluster_opt
        temp_dat = df_psc[txt].to_numpy()
        data.append(temp_dat)
        fig.add_trace(go.Violin(y=data[x], line_color=colors[3][x], name=ts_names[x], points='all', pointpos=-0.4, meanline_visible=True, width=1, side='positive', box_visible=True))
    fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False, violinmode='group', font=dict(size=16))
    
    for i, ts in enumerate(ts_names): 
        nl = '<br>'
        mean = np.nanmean(data[i])
        fig.add_annotation(
            x=i,
            y=mean,
            xref="x",
            yref="y",
            text=f"Mean=<br>{mean:.2f}",
            showarrow=True,
            font=dict(
                family="Courier New, monospace",
                size=17,
                color="#000000"
                ),
            align="center",
            arrowhead=6,
            arrowsize=0.5,
            arrowwidth=1.5,
            arrowcolor="#000000",
            ax=35,
            ay=-90,
            bordercolor="#000000",
            borderwidth=1.5,
            borderpad=4,
            bgcolor=colors[3][i],
            opacity=0.8
            )
    
    return fig


def reset_psc_timeseries_img(fig, data_dir, sub, task, cluster_opt):

    ts_names2 = ['Echo 2', 'tSNR-combined', 'TE-combined', 'T2*-combined', 'T2*FIT-combined', 'T2*FIT']
    ts_colnames = ['echo2', 'combTSNR', 'combTE', 'combT2STAR', 'combT2STARfit', 'T2STARfit']

    psc_ts_fn = os.path.join(data_dir, 'multiecho', sub+'_task-'+task+'_desc-PSCtimeseries.tsv')
    df_psc_ts = pd.read_csv(psc_ts_fn, sep='\t')
    data_pscts = []
    for i, ts in enumerate(ts_colnames):
        txt = ts + '_' + cluster_opt
        data_pscts.append(df_psc_ts[txt].to_numpy())
        fig.add_trace(go.Scatter(y=data_pscts[i], mode='lines', line = dict(color=colors[3][i], width=2), name=ts_names2[i] ))
        fig.update_yaxes(showticklabels=True)

    fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False, font=dict(size=16))

    return fig


def reset_psc_cnr_img(fig, data_dir, cnr_opt, task, cluster_opt):

    
    cnr_fn = os.path.join(data_dir, 'multiecho', 'sub-all_task-' + task + '_desc-offlineROI' + cnr_opt + '.tsv')
    df_cnr = pd.read_csv(cnr_fn, sep='\t')

    data = []
    ts_names = ['Echo 2', 'tSNR-combined', 'TE-combined', 'T2*-combined', 'T2*FIT-combined', 'T2*FIT']
    ts_colnames = ['echo2', 'combTSNR', 'combTE', 'combT2STAR', 'combT2STARfit', 'T2STARfit']

    # ['glm_RTecho2', 'kalm_RTecho2', 'glm_RTcombinedTSNR', 'kalm_RTcombinedTSNR', 'glm_RTcombinedT2STAR', 'kalm_RTcombinedT2STAR', 'glm_RTcombinedTE', 'kalm_RTcombinedTE', 'glm_RTcombinedRTt2star', 'kalm_RTcombinedRTt2star', 'glm_RTt2starFIT', 'kalm_RTt2starFIT', 'glm_RTs0FIT', 'kalm_RTs0FIT']

    for x, ts in enumerate(ts_colnames):
        txt = ts + '_' + cluster_opt
        temp_dat = df_cnr[txt].to_numpy()
        data.append(temp_dat)
        fig.add_trace(go.Violin(y=data[x], line_color=colors[3][x], name=ts_names[x], points='all', pointpos=-0.4, meanline_visible=True, width=1, side='positive', box_visible=True))
    
    fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False, violinmode='group', font=dict(size=16))

    for i, ts in enumerate(ts_names): 
        nl = '<br>'
        mean = np.nanmean(data[i])
        fig.add_annotation(
            x=i,
            y=mean,
            xref="x",
            yref="y",
            text=f"Mean=<br>{mean:.2f}",
            showarrow=True,
            font=dict(
                family="Courier New, monospace",
                size=17,
                color="#000000"
                ),
            align="center",
            arrowhead=6,
            arrowsize=0.5,
            arrowwidth=1.5,
            arrowcolor="#000000",
            ax=35,
            ay=-90,
            bordercolor="#000000",
            borderwidth=1.5,
            borderpad=4,
            bgcolor=colors[3][i],
            opacity=0.8
            )

    return fig


def reset_realtime_summary_img(fig, data_dir, cnr_opt, task, cluster_opt, psc_opt):

    if psc_opt == 'glm':
        cnr_fn = os.path.join(data_dir, 'realtime', 'sub-all_task-' + task + '_desc-' + cluster_opt +'_ROI' + cnr_opt + '.tsv')
        df_cnr = pd.read_csv(cnr_fn, sep='\t')
        data = []
        ts_names = ['Echo 2', 'tSNR-combined', 'TE-combined', 'T2*-combined', 'T2*FIT-combined', 'T2*FIT']
        rtts_colnames = ['RTecho2', 'RTcombinedTSNR', 'RTcombinedTE', 'RTcombinedT2STAR', 'RTcombinedRTt2star', 'RTt2starFIT']
        for x, ts in enumerate(rtts_colnames):
            txt = 'glm_' + ts
            temp_dat = df_cnr[txt].to_numpy()
            data.append(temp_dat)
            fig.add_trace(go.Violin(y=data[x], line_color=colors[3][x], name=ts_names[x], points='all', pointpos=-0.4, meanline_visible=True, width=1, side='positive', box_visible=True))
        fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False, violinmode='group') # , legend={'traceorder':'reversed'}
    else:
        cnr_fn = os.path.join(data_dir, 'realtime', 'sub-all_task-' + task + '_desc-realtimeROI' + cnr_opt + '_' + psc_opt + '.tsv')
        df_cnr = pd.read_csv(cnr_fn, sep='\t')
        data = []
        ts_names = ['Echo 2', 'tSNR-combined', 'TE-combined', 'T2*-combined', 'T2*FIT-combined', 'T2*FIT']
        rtts_colnames = ['RTecho2', 'RTcombinedTSNR', 'RTcombinedTE', 'RTcombinedT2STAR', 'RTcombinedRTt2star', 'RTt2starFIT']
        # realtimeROItcnr
        for x, ts in enumerate(rtts_colnames):
            txt = ts + '_' + cluster_opt
            temp_dat = df_cnr[txt].to_numpy()
            data.append(temp_dat)
            fig.add_trace(go.Violin(y=data[x], line_color=colors[3][x], name=ts_names[x], points='all', pointpos=-0.4, meanline_visible=True, width=1, side='positive', box_visible=True))
        fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False, violinmode='group', font=dict(size=16))
        
    for i, ts in enumerate(ts_names): 
        nl = '<br>'
        mean = np.nanmean(data[i])
        fig.add_annotation(
            x=i,
            y=mean,
            xref="x",
            yref="y",
            text=f"Mean=<br>{mean:.2f}",
            showarrow=True,
            font=dict(
                family="Courier New, monospace",
                size=17,
                color="#000000"
                ),
            align="center",
            arrowhead=6,
            arrowsize=0.5,
            arrowwidth=1.5,
            arrowcolor="#000000",
            ax=35,
            ay=-100,
            bordercolor="#000000",
            borderwidth=1.5,
            borderpad=4,
            bgcolor=colors[3][i],
            opacity=0.8
            )
    return fig


def reset_realtime_series_img(fig, data_dir, sub, task, cluster_opt, psc_opt):

    if psc_opt == 'glm':
        psc_ts_fn = os.path.join(data_dir, 'realtime', sub + '_task-' + task + '_desc-' + cluster_opt + '_ROIpsc.tsv')
        df_psc_ts = pd.read_csv(psc_ts_fn, sep='\t')
        ts_names = ['Echo 2', 'tSNR-combined', 'TE-combined', 'T2*-combined', 'T2*FIT-combined', 'T2*FIT']
        rtts_colnames = ['RTecho2', 'RTcombinedTSNR', 'RTcombinedTE', 'RTcombinedT2STAR', 'RTcombinedRTt2star', 'RTt2starFIT']
        data_pscts = []
        for i, ts in enumerate(rtts_colnames):
            txt = 'glm_' + ts
            data_pscts.append(df_psc_ts[txt].to_numpy())
            fig.add_trace(go.Scatter(y=data_pscts[i], mode='lines', line = dict(color=colors[3][x], width=2), name=ts_names[i] ))
            fig.update_yaxes(showticklabels=True)
        fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False)
    else:
        psc_ts_fn = os.path.join(data_dir, 'realtime', sub + '_task-' + task + '_desc-realtimeROIsignals_psc' + psc_opt + '.tsv')
        df_psc_ts = pd.read_csv(psc_ts_fn, sep='\t')
        ts_names = ['Echo 2', 'tSNR-combined', 'TE-combined', 'T2*-combined', 'T2*FIT-combined', 'T2*FIT']
        rtts_colnames = ['RTecho2', 'RTcombinedTSNR', 'RTcombinedTE', 'RTcombinedT2STAR', 'RTcombinedRTt2star', 'RTt2starFIT']
        data_pscts = []
        for i, ts in enumerate(rtts_colnames):
            txt = ts + '_' + cluster_opt
            data_pscts.append(df_psc_ts[txt].to_numpy())
            fig.add_trace(go.Scatter(y=data_pscts[i], mode='lines', line = dict(color=colors[3][i], width=2), name=ts_names[i] ))
            fig.update_yaxes(showticklabels=True)
        fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False, font=dict(size=16))

    return fig


def reset_realtime_series_smoothed_img(fig, data_dir, sub, task, cluster_opt, psc_opt, window):

    if psc_opt == 'glm':
        psc_ts_fn = os.path.join(data_dir, 'realtime', sub + '_task-' + task + '_desc-' + cluster_opt + '_ROIpsc.tsv')
        df_psc_ts = pd.read_csv(psc_ts_fn, sep='\t')
        ts_names = ['Echo 2', 'tSNR-combined', 'TE-combined', 'T2*-combined', 'T2*FIT-combined', 'T2*FIT']
        rtts_colnames = ['RTecho2', 'RTcombinedTSNR', 'RTcombinedTE', 'RTcombinedT2STAR', 'RTcombinedRTt2star', 'RTt2starFIT']
        data_pscts = []
        for i, ts in enumerate(rtts_colnames):
            txt = 'glm_' + ts
            data_pscts.append(df_psc_ts[txt].to_numpy())
            fig.add_trace(go.Scatter(y=data_pscts[i], mode='lines', line = dict(color=colors[3][x], width=2), name=ts_names[i] ))
            fig.update_yaxes(showticklabels=True)
        fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False)
    else:
        psc_ts_fn = os.path.join(data_dir, 'realtime', sub + '_task-' + task + '_desc-realtimeROIsignals_psc' + psc_opt + '.tsv')
        df_psc_ts = pd.read_csv(psc_ts_fn, sep='\t')
        ts_names = ['Echo 2', 'tSNR-combined', 'TE-combined', 'T2*-combined', 'T2*FIT-combined', 'T2*FIT']
        rtts_colnames = ['RTecho2', 'RTcombinedTSNR', 'RTcombinedTE', 'RTcombinedT2STAR', 'RTcombinedRTt2star', 'RTt2starFIT']
        data_pscts = []
        for i, ts in enumerate(rtts_colnames):
            txt = ts + '_' + cluster_opt
            
            raw_data = df_psc_ts[txt].to_numpy()
            filtered_data = np.zeros_like(raw_data)
            for j, x in enumerate(raw_data):
                if j < window:
                    filtered_data[j] = np.mean(raw_data[0:j+1])
                else:
                    filtered_data[j] = np.mean(raw_data[j-window+1:j+1])

            data_pscts.append(filtered_data)
            fig.add_trace(go.Scatter(y=data_pscts[i], mode='lines', line = dict(color=colors[3][i], width=2), name=ts_names[i] ))
            fig.update_yaxes(showticklabels=True)
        fig.update_layout(xaxis_showgrid=True, yaxis_showgrid=True, xaxis_zeroline=False, font=dict(size=16))

    return fig