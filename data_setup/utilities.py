import numpy as np
import pandas as pd

def appendRowToDf(main_df, block_df, event_type, txt_col):
    # ['onset', 'duration', 'response_time', 'button_pressed', 'trial_type']
    onset = np.round(block_df[txt_col + '.OnsetTime'], 3)
    duration = block_df[txt_col + '.OnsetToOnsetTime']
    if duration == 0.0:
        duration = 2008.0
    duration = np.round(duration/1000, 3)
    rt = np.round(block_df[txt_col + '.RT']/1000, 3)

    main_df = main_df.append({'onset':onset,
                            'duration':duration,
                            'response_time':rt,
                            'button_pressed':block_df[txt_col + '.RESP'],
                            'trial_type':event_type}, ignore_index = True)
    return main_df

def appendRowToDfProblem(main_df, block_df, event_type, txt_col):
    # ['onset', 'duration', 'response_time', 'button_pressed', 'trial_type']
    onset = np.nan
    duration = np.nan
    rt = np.nan
    bp = np.nan
    # duration = 2008.0
    # duration = np.round(duration/1000, 3)
    # rt = np.round(block_df[txt_col + '.RT']/1000, 3)
    # block_df[txt_col + '.RESP']

    main_df = main_df.append({'onset':onset,
                            'duration':duration,
                            'response_time':rt,
                            'button_pressed':bp,
                            'trial_type':event_type}, ignore_index = True)
    return main_df


def create_event_files(all_dfs, paradigms, dct_df, sub):
    ## 3. Extract necessary data from dataframes, reorder into sensible blocks, write to text file
    ## 3.1) Motor, motor-imagine, and emotion-imagine (same structure or eprime files)

    ## Description  of data to extract:
    # Rows 0:9 (including 9) - ['Rest.OnsetTime', 'Rest.OnsetToOnsetTime', 'Tap.OnsetTime']
    # Row 10 - ['LastRest.OnsetTime']

    # paradigms = ['motor-', 'motor-imagine-', 'emotion-', 'emotion-imagine-']

    task = ['FingerTapping', 'MentalFingerTapping', '', 'MentalEmotion']
    keys = ['df0', 'df1', 'df2', 'df3']

    for p in [0,1,3]:

        if not sub == 'sub-001':
            df = all_dfs[paradigms[p]]
            # print(df)
            columns = ['onset', 'duration', 'trial_type']
            events3_df = pd.DataFrame(columns=columns)

            for i in np.arange(10):
                rest_onset = np.round(df.loc[i, 'Rest.OnsetTime']/1000, 3)
                task_onset = np.round(df.loc[i, 'Tap.OnsetTime']/1000, 3)
                events3_df = events3_df.append({'onset': rest_onset, 'duration': 20, 'trial_type': 'Rest'}, ignore_index=True)
                events3_df = events3_df.append({'onset': task_onset, 'duration': 20, 'trial_type': task[p]}, ignore_index=True)

            rest_onset = np.round(df.loc[10, 'LastRest.OnsetTime']/1000, 3)
            events3_df = events3_df.append({'onset': rest_onset, 'duration': 20, 'trial_type': 'Rest'}, ignore_index=True)
            events3_df['onset'] = np.round(events3_df['onset'] - events3_df.loc[0,'onset'], 3)

            dct_df[keys[p]] = events3_df

    ## 3.2) Emotion

    ## Description  of data to extract:
    # { Cue+Match(shape)+5*[ITI+Match(shape)] + Cue+Match(face)+5*[ITI+Match(face)] }*10 + Cue+Match(shape)+5*[ITI+Match(shape)]
    # --0--
    # 0-4 = ShapeTaskList:ShapesDisplay.OnsetToOnsetTime
    # 5 = ShapesList:Shape.OnsetToOnsetTime
    # 6-10 = FaceTaskList:FacesDisplay.OnsetToOnsetTime
    # 11 = FacesList:Face.OnsetToOnsetTime
    # --1--
    # 12-16 = ShapeTaskList1:ShapesDisplay1.OnsetToOnsetTime
    # 17 = ShapesList1:Shape1.OnsetToOnsetTime
    # 18-22 = FaceTaskList1:FacesDisplay1.OnsetToOnsetTime
    # 23 = FacesList1:Face1.OnsetToOnsetTime
    # --2--

    # (1) Extract interpretable blocks

    df = all_dfs[paradigms[2]]
    all_blocks = {}

    for i in np.arange(11):
        loc1 = i*12
        loc2 = loc1+4
        loc3 = loc2+1
        loc4 = loc3+1
        loc5 = loc4+4
        loc6 = loc5+1

        all_blocks[i] = {}

        if i == 0:
            txt = ''
        else:
            txt = str(i)

        marker1a = 'ShapeTaskList' + txt
        marker1b = 'ShapesDisplay' + txt + '.OnsetToOnsetTime'
        marker2a = 'ShapesList' + txt
        marker2b = 'Shape' + txt + '.OnsetToOnsetTime'
        marker3a = 'FaceTaskList' + txt
        marker3b = 'FacesDisplay' + txt + '.OnsetToOnsetTime'
        marker4a = 'FacesList' + txt
        marker4b = 'Face' + txt + '.OnsetToOnsetTime'

        if i < 10:
            all_blocks[i]['shape1'] = df.loc[loc3, marker2a:marker2b]
            all_blocks[i]['shape5'] = df.loc[loc1:loc2, marker1a:marker1b]
            all_blocks[i]['face1'] = df.loc[loc6, marker4a:marker4b]
            all_blocks[i]['face5'] = df.loc[loc4:loc5, marker3a:marker3b]
        else:
            all_blocks[i]['shape1'] = df.loc[loc3, marker2a:marker2b]
            all_blocks[i]['shape5'] = df.loc[loc1:loc2, marker1a:marker1b]


    # (2) Test some (potentially problematic) blocks; in sub-001, these are likely still problems: ShapesCue0, FacesCue2
    # if sub == 'sub-001':
    #     print(all_blocks[0]['shape1'])
    #     print(all_blocks[2]['face1'])

    # (3) Add rows of data iteratively to new dataframe, and write dataframe to "events" file
    columns = ['onset', 'duration', 'response_time', 'button_pressed', 'trial_type']
    events1_df = pd.DataFrame(columns=columns)

    for i in np.arange(11):
        loc1 = i*12
        loc2 = loc1+4
        loc3 = loc2+1
        loc4 = loc3+1
        loc5 = loc4+4
        loc6 = loc5+1

        if i == 0:
            txt = ''
        else:
            txt = str(i)

        block_df = all_blocks[i]['shape1']

        event_type = 'CueShapes'
        txt_col = 'ShapesCue' + txt
        events1_df = appendRowToDf(events1_df, block_df, event_type, txt_col)

        event_type = 'Shapes'
        txt_col = 'Shape' + txt
        events1_df = appendRowToDf(events1_df, block_df, event_type, txt_col)

        # all_blocks[i]['shape5']
        for j in range(loc1,loc2+1):
            block_df = all_blocks[i]['shape5'].loc[j]
            event_type = 'ITI'
            txt_col = 'ShapeRest' + txt
            events1_df = appendRowToDf(events1_df, block_df, event_type, txt_col)
            event_type = 'Shapes'
            txt_col = 'ShapesDisplay' + txt
            events1_df = appendRowToDf(events1_df, block_df, event_type, txt_col)

        if i < 10:
            # all_blocks[i]['face1']
            block_df = all_blocks[i]['face1']

            event_type = 'CueFaces'
            txt_col = 'FacesCue' + txt

            if sub == 'sub-001':
                if i in [2]:
                    events1_df = appendRowToDfProblem(events1_df, block_df, event_type, txt_col)
                else:
                    events1_df = appendRowToDf(events1_df, block_df, event_type, txt_col)
            else:
                events1_df = appendRowToDf(events1_df, block_df, event_type, txt_col)

            event_type = 'Faces'
            txt_col = 'Face' + txt
            events1_df = appendRowToDf(events1_df, block_df, event_type, txt_col)

            # all_blocks[i]['face5']
            for j in range(loc4,loc5+1):
                block_df = all_blocks[i]['face5'].loc[j]
                event_type = 'ITI'
                txt_col = 'FaceRest' + txt
                events1_df = appendRowToDf(events1_df, block_df, event_type, txt_col)
                event_type = 'Faces'
                txt_col = 'FacesDisplay' + txt
                events1_df = appendRowToDf(events1_df, block_df, event_type, txt_col)

    dct_df[keys[2]] = events1_df

    return dct_df