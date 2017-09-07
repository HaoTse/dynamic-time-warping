addpath(genpath('rastamat'));

% Clean-up MATLAB's environment
clear all; close all; clc;

col_header = ['    ', '      0(1)', '      0(2)', '      1(1)', '      1(2)',...
                '      2(1)', '      2(2)', '      3(1)', '      3(2)'...
                '      4(1)', '      4(2)', '      5(1)', '      5(2)'];

%% compute distance
for i = 0 : 5
    row_header(i + 1, 1) = {sprintf('%d(1)', i)};
    for j = 0 : 5
        wave_file = sprintf('record/%d_1.wav', i);

        % Load a speech waveform
        [d,sr] = audioread(wave_file);

        % Calculate 12th order PLP features without RASTA
        ord = 12;
        [cep, spec] = melfcc(d,sr,'preemph',0,'modelorder',ord,'numcep',ord+1,...
                        'dcttype',1,'dither',1,'nbands',ceil(hz2bark(sr/2))+1,...
                        'fbtype','bark','usecmp',1,'wintime',0.032,'hoptime',0.016);

        del = deltas(cep);
        % Double deltas are deltas applied twice with a shorter window
        ddel = deltas(deltas(cep,5),5);
        % Composite, 39-element feature vector, just like we use for speech recognition
        feature1 = [cep;del;ddel];
        
        for k = 1 : 2
            wave_file = sprintf('record/%d_%d.wav', j, k);

            % Load a speech waveform
            [d,sr] = audioread(wave_file);

            % Calculate 12th order PLP features without RASTA
            [cep, spec] = melfcc(d,sr,'preemph',0,'modelorder',ord,'numcep',ord+1,...
                            'dcttype',1,'dither',1,'nbands',ceil(hz2bark(sr/2))+1,...
                            'fbtype','bark','usecmp',1,'wintime',0.032,'hoptime',0.016);

            del = deltas(cep);
            % Double deltas are deltas applied twice with a shorter window
            ddel = deltas(deltas(cep,5),5);
            % Composite, 39-element feature vector, just like we use for speech recognition
            feature2 = [cep;del;ddel];

            dis(i + 1, j * 2 + k) = dtw(feature1, feature2);
        end
    end
end

%% output result
filename = 'result.txt';
fout = fopen(filename, 'w');
fprintf(fout, col_header);
fprintf(fout, '\n');
format = '%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f\n';
[nrows, ncols] = size(dis);
for row = 1:nrows
    fprintf(fout, row_header{row,:});
    fprintf(fout, format, dis(row,:));
end
fclose(fout);