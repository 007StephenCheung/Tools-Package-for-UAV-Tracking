% Fangqiang Ding 2019/11/20

function run_group_VisDrone(save_dir)                                        % û�����룬��Ĭ�ϱ����ڵ�ǰ�ļ����µ�\all_trk_results\
%%  ��ȡ��Ƶ���к�groundtruth
where_is_your_groundtruth_folder = 'D:\BaiduNetdiskDownload\VisDrone-test-dev\annotations';         % �����������ݼ�groundtruth�ļ���·��
where_is_your_VisDrone_database_folder = 'D:\BaiduNetdiskDownload\VisDrone-test-dev\sequences'; % �����������ݼ�ͼƬ���е�·��
%VisDrone���ݼ�����Ƶ���к�groundtruth�Ƿֿ���
%�˴�����VisDrone2018-SOT-test-dev (��35��sequences)
%VisDrone���ݼ���35����Ƶ���У��ܹ�29365֡��ƽ�����г���Ϊ839֡
addpath('.\UAV_Basic_Framework\');

%% Read all video names using grouthtruth.txt
ground_truth_folder = where_is_your_groundtruth_folder;
dir_output = dir(fullfile(ground_truth_folder, '\*.txt'));             % ��ȡ���ļ����µ����е�txt�ļ�
contents = {dir_output.name}';
all_video_name = cell(numel(contents),1);
for k = 1:numel(contents)
    name = contents{k}(1:end-4);                                       % ȥ����׺ .txt
    all_video_name{k,1} = name;                                    % �����������ݼ�����
end
dataset_num = length(all_video_name);                                  % ��groundtruth���ļ����õ����ݼ�����
main_folder = pwd;                                                     % ��ȡ��ǰ·��
all_trackers_dir = '.\tracker_set\';                                   % ��������tracker���ļ���
if nargin < 1
    save_dir = [main_folder '\group_results\VisDrone\'];              % ��������Ľ����ָ���ļ���
end
run_trackers_info = struct('AutoTrack',@run_AutoTrack);                               % ��ȡ����tracker�ĺ�����Ϣ�����������run_xxx(seq, res_path, bSaveImage))����
tracker_name= fieldnames(run_trackers_info);                      % ��ȡtracker_set�ĳ�Ա��
tracker_name=tracker_name{1};
cd(all_trackers_dir);                                                  % �����������tracker���ļ���
%%
addpath(genpath(tracker_name));                                    % �����ļ����Լ��������ļ��е�·��
cd(tracker_name);                                                  % ����ָ��tracker���ļ���

group=[1 2 3 4; 2 4 5 6;7 4 2 1; 4 3 2 1];               %ÿһ�����Ϊһ��
num_group=size(group,1);
%����������
name1='p1';
name2='p2';
name3='p3';
name4='p4';

for dataset_count =1:dataset_num
    video_name = all_video_name{dataset_count};                    % ��ȡ���ݼ�����
    database_folder = where_is_your_VisDrone_database_folder;
    seq = load_video_info_VisDrone(database_folder, ground_truth_folder, video_name); % ����������Ϣ
    assignin('base','subS',seq);                                   % ��seqд�빤���ռ䣬����ΪsubS
    % main function
    run_tracker = getfield(run_trackers_info, tracker_name); %#ok<GFLD> % ���run_xxx�ĺ������
    
    for i=1:num_group
        param1=group(i,1);
        param2=group(i,2);
        param3=group(i,3);
        param4=group(i,4);
        save_res_dir = [save_dir, tracker_name,'-',name1,'-',num2str(param1),'-',name2,'-',num2str(param2),'-',name3,'-',num2str(param3),'-',name4,'-',num2str(param4),'\']; 
        if ~exist(save_res_dir, 'dir')
            mkdir(save_res_dir);
        end
        fprintf('run %s on %d %s\nindex:%d/%d      ', tracker_name, dataset_count, video_name,i,num_group);
        result = run_tracker(seq);               % ִ�и�tracker��������
     
        % save results
        results = cell(1,1);                                           % results�ǰ���һ���ṹ���Ԫ�����ṹ�����type,res,fps,len,annoBegin,startFrame������Ա
        results{1}=result;
        results{1}.len = seq.len;
        results{1}.annoBegin = seq.st_frame;
        results{1}.startFrame = seq.st_frame;
        fprintf('fps: %f\n', results{1}.fps);
        
        save([save_res_dir, video_name, '_', tracker_name,'-',name1,'-',num2str(param1),'-',name2,'-',num2str(param2),'-',name3,'-',num2str(param3),'-',name4,'-',num2str(param4)]);
        % plot precision figure
%         show_visualization =false;                                       % ��ʾͼƬ��precision_plot�����
%         precision_plot_save(results{1}.res, seq.ground_truth, video_name, save_pic_dir, show_visualization);
%         close all;
    end
end