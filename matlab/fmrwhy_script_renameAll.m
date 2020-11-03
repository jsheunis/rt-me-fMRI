
bids_dir = '/Volumes/TSM/NEUFEPME_data_BIDS/';
% bids_dir = '/Users/jheunis/Desktop/NEUFEPME_data_BIDS/';

% tasks = {'rest', 'motor', 'emotion'};
% runs = {'1', '2'};
% runs = {'1'};
% echoes = {'2', 'combinedMEtsnr', 'combinedMEt2star', 'combinedMEte'};
subs = {'001', '002', '003', '004', '005', '006', '007', '010', '011', '012', '013', '015', '016', '017', '018', '019', '020', '021', '022', '023', '024', '025', '026', '027', '029', '030', '031', '032'};
% subs = {'002'};
% ses = '';

runs_old = {'motor_run-1', 'motor_run-2', 'emotion_run-1', 'emotion_run-2'};
tasks_new = {'fingerTapping', 'fingerTappingImagined', 'emotionProcessing', 'emotionProcessingImagined'};

% % Core bids files
% tic;
% for s = 1:numel(subs)

%     clearvars -except bids_dir subs s runs_old tasks_new
%     sub = subs{s};
%     disp(sub);
%     sub_dir = fullfile(bids_dir, ['sub-' sub]);
%     anat_dir = fullfile(sub_dir, 'anat');
%     func_dir = fullfile(sub_dir, 'func');
%     cd(func_dir)

%     for r = 1:numel(runs_old)
%         files = dir(['*' runs_old{r} '*']);

%         for i = 1:numel(files)
%             src = fullfile(files(i).folder, files(i).name);
%             dest = fullfile(files(i).folder, strrep(files(i).name, runs_old{r}, tasks_new{r}));
%             movefile(src, dest);
%         end
%     end
% end
% toc;

% Derivatives: QC / stats
tic;
for s = 1:numel(subs)
    % clearvars -except bids_dir subs s runs_old tasks_new
    sub = subs{s};
    % disp(sub);
    stats_dir = fullfile(bids_dir, 'derivatives', 'fmrwhy-stats', '2ndlevel');
    sub_dir = fullfile(bids_dir, 'derivatives', 'fmrwhy-stats', ['sub-' sub]);
    cd(sub_dir)
    % func_dir = fullfile(sub_dir, 'func');
    % cd(func_dir)
    for r = 1:numel(runs_old)
        files = dir(['*' runs_old{r} '*']);

        for i = 1:numel(files)
            src = fullfile(files(i).folder, files(i).name);
            dest = fullfile(files(i).folder, strrep(files(i).name, runs_old{r}, tasks_new{r}));
            movefile(src, dest);

            if files(i).isdir
                subfiles = dir(fullfile(dest, ['*' runs_old{r} '*']));
                for j = 1:numel(subfiles)
                    subsrc = fullfile(subfiles(j).folder, subfiles(j).name);
                    subdest = fullfile(subfiles(j).folder, strrep(subfiles(j).name, runs_old{r}, tasks_new{r}));
                    movefile(subsrc, subdest);
                end
            end
        end
    end
end
toc;

% % Derivatives: multi-echo / preproc
% tic;
% for s = 1:numel(subs)
%     % clearvars -except bids_dir subs s runs_old tasks_new
%     sub = subs{s};
%     disp(sub);
%     sub_dir = fullfile(bids_dir, 'derivatives', 'fmrwhy-preproc', ['sub-' sub]);
%     func_dir = fullfile(sub_dir, 'func');
%     cd(func_dir)

%     for r = 1:numel(runs_old)
%         files = dir(['*' runs_old{r} '*']);

%         for i = 1:numel(files)
%             src = fullfile(files(i).folder, files(i).name);
%             dest = fullfile(files(i).folder, strrep(files(i).name, runs_old{r}, tasks_new{r}));
%             movefile(src, dest);
%         end
%     end
% end
% toc;

