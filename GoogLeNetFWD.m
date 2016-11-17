clc;
clear;
inputFile = '';     %Sample input image for which we want to extract 
                    %intermediate results. If intermed = 0, this value is
                    %not requried. 
meanFile = '';      %Path to the mean file of the dataset
cmp = 0;            %If cmp == 1, program checks the intermediate results
                    %with the expected results and print the difference. 
                    %If you want to use your own image file, set this to 0 
                    %in the confix.txt file.
fileId = fopen('Config.txt');
if (fileId == -1)
    error('Cannot find config.txt in the current directory');
end
line = fgets(fileId);
while (ischar(line)) 
    tokens = strsplit(line, '=');
    if (line(1) == '#')
        line = fgets(fileId);
        continue;
    end
    switch(strtrim(tokens{1}))
        case 'input_file'
            inputFile = strtrim(tokens{2});
        case 'mean_file'
            meanFile = strtrim(tokens{2});
        case 'cmp'
            cmp = str2double(strtrim(tokens{2}));
    end
    line = fgets(fileId);
end
fclose(fileId);
img = preproc(inputFile, meanFile);
tic
%load('Intermed_Results\1_data.mat');
%img = data;

load('Params\conv1_7x7_s2_w.mat');
load('Params\conv1_7x7_s2_b.mat');
conv_rslt = conv(img, weights, bias, 7, 2, 3, 1);
conv_rslt = relu(conv_rslt);
load('Intermed_Results\2_conv1_7x7_s2.mat');
if (cmp)
    fprintf('Max error in conv1: %f\n', max(abs(data(:) - conv_rslt(:))));
end
pool_rslt = maxpool(conv_rslt, 3, 2);
load('Intermed_Results\3_pool1_3x3_s2.mat');
if (cmp)
    fprintf('Max error in maxpool1: %f\n', max(abs(data(:) - pool_rslt(:))));
end
lrn_rslt = lrn (pool_rslt, 5, 0.0001, 0.75, 1);
load('Intermed_Results\4_pool1_norm1.mat');
if (cmp)
    fprintf('Max error in LRN1: %f\n', max(abs(data(:) - lrn_rslt(:))));
end

load('Params\conv2_3x3_reduce_b.mat');
load('Params\conv2_3x3_reduce_w.mat');
conv_rslt = conv(lrn_rslt, weights, bias, 1, 1, 0, 1);
conv_rslt = relu(conv_rslt);
load('Intermed_Results\5_conv2_3x3_reduce.mat');
if (cmp)
    fprintf('Max error in conv2 reduce: %f\n', max(abs(data(:) - conv_rslt(:))));
end

load('Params\conv2_3x3_b.mat');
load('Params\conv2_3x3_w.mat');
conv_rslt = conv(conv_rslt, weights, bias, 3, 1, 1, 1);
conv_rslt = relu(conv_rslt);
load('Intermed_Results\6_conv2_3x3.mat');
if (cmp)
    fprintf('Max error in conv2: %f\n', max(abs(data(:) - conv_rslt(:))));
end

lrn_rslt = lrn (conv_rslt, 5, 0.0001, 0.75, 1);
load('Intermed_Results\7_conv2_norm2.mat');
if (cmp)
    fprintf('Max error in LRN2: %f\n', max(abs(data(:) - lrn_rslt(:))));
end

pool_rslt = maxpool(lrn_rslt, 3, 2);
load('Intermed_Results\8_pool2_3x3_s2.mat');
if (cmp)
    fprintf('Max error in maxpool2: %f\n', max(abs(data(:) - pool_rslt(:))));
end
load('Params\inception_3a_1x1_b.mat');
load('Params\inception_3a_1x1_w.mat');
inception_3a_1x1 = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_3a_1x1 = relu(inception_3a_1x1);
load('Intermed_Results\13_inception_3a_1x1.mat');
if (cmp)
    fprintf('Max error in inception_3a_1x1: %f\n', max(abs(data(:) - inception_3a_1x1(:))));
end
load('Params\inception_3a_3x3_reduce_b.mat');
load('Params\inception_3a_3x3_reduce_w.mat');
inception_3a_3x3_red = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_3a_3x3_red = relu(inception_3a_3x3_red);
load('Intermed_Results\14_inception_3a_3x3_reduce.mat');
if (cmp)
    fprintf('Max error in inception_3a_3x3_red: %f\n', max(abs(data(:) - inception_3a_3x3_red(:))));
end
load('Params\inception_3a_5x5_reduce_b.mat');
load('Params\inception_3a_5x5_reduce_w.mat');
inception_3a_5x5_red = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_3a_5x5_red = relu(inception_3a_5x5_red);
load('Intermed_Results\16_inception_3a_5x5_reduce.mat');
if (cmp)
    fprintf('Max error in inception_3a_5x5_red: %f\n', max(abs(data(:) - inception_3a_5x5_red(:))));
end
pool_rslt = maxpool(pool_rslt, 3, 1);
load('Intermed_Results\18_inception_3a_pool.mat');
if (cmp)
    fprintf('Max error in maxpool2: %f\n', max(abs(data(:) - pool_rslt(:))));
end
load('Params\inception_3a_3x3_b.mat');
load('Params\inception_3a_3x3_w.mat');
inception_3a_3x3 = conv(inception_3a_3x3_red, weights, bias, 3, 1, 1, 1);
inception_3a_3x3 = relu(inception_3a_3x3);
load('Intermed_Results\15_inception_3a_3x3.mat');
if (cmp)
    fprintf('Max error in inception_3a_3x3: %f\n', max(abs(data(:) - inception_3a_3x3(:))));
end
load('Params\inception_3a_5x5_b.mat');
load('Params\inception_3a_5x5_w.mat');
inception_3a_5x5 = conv(inception_3a_5x5_red, weights, bias, 5, 1, 2, 1);
inception_3a_5x5 = relu(inception_3a_5x5);
load('Intermed_Results\17_inception_3a_5x5.mat');
if (cmp)
    fprintf('Max error in inception_3a_5x5: %f\n', max(abs(data(:) - inception_3a_5x5(:))));
end
load('Params\inception_3a_pool_proj_b.mat');
load('Params\inception_3a_pool_proj_w.mat');
inception_3a_proj = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_3a_proj = relu(inception_3a_proj);
load('Intermed_Results\19_inception_3a_pool_proj.mat');
if (cmp)
    fprintf('Max error in inception_3a_5x5: %f\n', max(abs(data(:) - inception_3a_proj(:))));
end
output_3a = zeros(28, 28, 256);
output_3a(:, :, 1:64) = inception_3a_1x1;
output_3a(:, :, 65:192) = inception_3a_3x3;
output_3a(:, :, 193:224) = inception_3a_5x5;
output_3a(:, :, 225:256) = inception_3a_proj;
load('Intermed_Results\20_inception_3a_output.mat')
if (cmp)
    fprintf('Max error in output 3a: %f\n', max(abs(data(:) - output_3a(:))));
end
%%
load('Params\inception_3b_1x1_b.mat');
load('Params\inception_3b_1x1_w.mat');
inception_3b_1x1 = conv(output_3a, weights, bias, 1, 1, 0, 1);
inception_3b_1x1 = relu(inception_3b_1x1);
load('Intermed_Results\25_inception_3b_1x1.mat');
if (cmp)
    fprintf('Max error in inception_3b_1x1: %f\n', max(abs(data(:) - inception_3b_1x1(:))));
end

load('Params\inception_3b_3x3_reduce_b.mat');
load('Params\inception_3b_3x3_reduce_w.mat');
inception_3b_3x3_red = conv(output_3a, weights, bias, 1, 1, 0, 1);
inception_3b_3x3_red = relu(inception_3b_3x3_red);
load('Intermed_Results\26_inception_3b_3x3_reduce.mat');
if (cmp)
    fprintf('Max error in inception_3b_3x3_red: %f\n', max(abs(data(:) - inception_3b_3x3_red(:))));
end
load('Params\inception_3b_5x5_reduce_b.mat');
load('Params\inception_3b_5x5_reduce_w.mat');
inception_3b_5x5_red = conv(output_3a, weights, bias, 1, 1, 0, 1);
inception_3b_5x5_red = relu(inception_3b_5x5_red);
load('Intermed_Results\28_inception_3b_5x5_reduce.mat');
if (cmp)
    fprintf('Max error in inception_3b_5x5_red: %f\n', max(abs(data(:) - inception_3b_5x5_red(:))));
end
pool_rslt = maxpool(output_3a, 3, 1);
load('Intermed_Results\30_inception_3b_pool.mat');
if (cmp)
    fprintf('Max error in maxpool 3b: %f\n', max(abs(data(:) - pool_rslt(:))));
end

load('Params\inception_3b_3x3_b.mat');
load('Params\inception_3b_3x3_w.mat');
inception_3b_3x3 = conv(inception_3b_3x3_red, weights, bias, 3, 1, 1, 1);
inception_3b_3x3 = relu(inception_3b_3x3);
load('Intermed_Results\27_inception_3b_3x3.mat');
if (cmp)
    fprintf('Max error in inception_3b_3x3: %f\n', max(abs(data(:) - inception_3b_3x3(:))));
end

load('Params\inception_3b_5x5_b.mat');
load('Params\inception_3b_5x5_w.mat');
inception_3b_5x5 = conv(inception_3b_5x5_red, weights, bias, 5, 1, 2, 1);
inception_3b_5x5 = relu(inception_3b_5x5);
load('Intermed_Results\29_inception_3b_5x5.mat');
if (cmp)
    fprintf('Max error in inception_3b_5x5: %f\n', max(abs(data(:) - inception_3b_5x5(:))));
end
load('Params\inception_3b_pool_proj_b.mat');
load('Params\inception_3b_pool_proj_w.mat');
inception_3b_proj = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_3b_proj = relu(inception_3b_proj);
load('Intermed_Results\31_inception_3b_pool_proj.mat');
if (cmp)
    fprintf('Max error in inception_3b_5x5: %f\n', max(abs(data(:) - inception_3b_proj(:))));
end

output_3b = zeros(28, 28, 480);
output_3b(:, :, 1:128) = inception_3b_1x1;
output_3b(:, :, 129:320) = inception_3b_3x3;
output_3b(:, :, 321:416) = inception_3b_5x5;
output_3b(:, :, 417:480) = inception_3b_proj;
load('Intermed_Results\32_inception_3b_output.mat')
if (cmp)
    fprintf('Max error in output 3b: %f\n', max(abs(data(:) - output_3b(:))));
end
%%
pool_rslt = maxpool(output_3b, 3, 2);
load('Intermed_Results\33_pool3_3x3_s2.mat');
if (cmp)
    fprintf('Max error in maxpool 3x3 s2: %f\n', max(abs(data(:) - pool_rslt(:))));
end    
%%
load('Params\inception_4a_1x1_b.mat');
load('Params\inception_4a_1x1_w.mat');
inception_1x1 = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_1x1 = relu(inception_1x1);
load('Intermed_Results\38_inception_4a_1x1.mat');
if (cmp)
    fprintf('Max error in inception_4a_1x1: %f\n', max(abs(data(:) - inception_1x1(:))));
end

load('Params\inception_4a_3x3_reduce_b.mat');
load('Params\inception_4a_3x3_reduce_w.mat');
inception_3x3_red = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_3x3_red = relu(inception_3x3_red);
load('Intermed_Results\39_inception_4a_3x3_reduce.mat');
if (cmp)
    fprintf('Max error in inception_4a_3x3_red: %f\n', max(abs(data(:) - inception_3x3_red(:))));
end

load('Params\inception_4a_5x5_reduce_b.mat');
load('Params\inception_4a_5x5_reduce_w.mat');
inception_5x5_red = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_5x5_red = relu(inception_5x5_red);
load('Intermed_Results\41_inception_4a_5x5_reduce.mat');
if (cmp)
    fprintf('Max error in inception_4a_5x5_red: %f\n', max(abs(data(:) - inception_5x5_red(:))));
end

pool_rslt = maxpool(pool_rslt, 3, 1);
load('Intermed_Results\43_inception_4a_pool.mat');
if (cmp)
    fprintf('Max error in maxpool 4a: %f\n', max(abs(data(:) - pool_rslt(:))));
end

load('Params\inception_4a_3x3_b.mat');
load('Params\inception_4a_3x3_w.mat');
inception_3x3 = conv(inception_3x3_red, weights, bias, 3, 1, 1, 1);
inception_3x3 = relu(inception_3x3);
load('Intermed_Results\40_inception_4a_3x3.mat');
if (cmp)
    fprintf('Max error in inception_4a_3x3: %f\n', max(abs(data(:) - inception_3x3(:))));
end

load('Params\inception_4a_5x5_b.mat');
load('Params\inception_4a_5x5_w.mat');
inception_5x5 = conv(inception_5x5_red, weights, bias, 5, 1, 2, 1);
inception_5x5 = relu(inception_5x5);
load('Intermed_Results\42_inception_4a_5x5.mat');
if (cmp)
    fprintf('Max error in inception_4a_5x5: %f\n', max(abs(data(:) - inception_5x5(:))));
end

load('Params\inception_4a_pool_proj_b.mat');
load('Params\inception_4a_pool_proj_w.mat');
inception_proj = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_proj = relu(inception_proj);
load('Intermed_Results\44_inception_4a_pool_proj.mat');
if (cmp)
    fprintf('Max error in inception_4a_5x5 proj: %f\n', max(abs(data(:) - inception_proj(:))));
end

output = zeros(14, 14, 512);
output(:, :, 1:192) = inception_1x1;
output(:, :, 193:400) = inception_3x3;
output(:, :, 401:448) = inception_5x5;
output(:, :, 449:512) = inception_proj;
load('Intermed_Results\45_inception_4a_output.mat')
if (cmp)
    fprintf('Max error in output 4a: %f\n', max(abs(data(:) - output(:))));
end    
%%
load('Params\inception_4b_1x1_b.mat');
load('Params\inception_4b_1x1_w.mat');
inception_1x1 = conv(output, weights, bias, 1, 1, 0, 1);
inception_1x1 = relu(inception_1x1);
load('Intermed_Results\50_inception_4b_1x1.mat');
if (cmp)
    fprintf('Max error in inception_4b_1x1: %f\n', max(abs(data(:) - inception_1x1(:))));
end

load('Params\inception_4b_3x3_reduce_b.mat');
load('Params\inception_4b_3x3_reduce_w.mat');
inception_3x3_red = conv(output, weights, bias, 1, 1, 0, 1);
inception_3x3_red = relu(inception_3x3_red);
load('Intermed_Results\51_inception_4b_3x3_reduce.mat');
if (cmp)
    fprintf('Max error in inception_4b_3x3_red: %f\n', max(abs(data(:) - inception_3x3_red(:))));
end

load('Params\inception_4b_5x5_reduce_b.mat');
load('Params\inception_4b_5x5_reduce_w.mat');
inception_5x5_red = conv(output, weights, bias, 1, 1, 0, 1);
inception_5x5_red = relu(inception_5x5_red);
load('Intermed_Results\53_inception_4b_5x5_reduce.mat');
if (cmp)
    fprintf('Max error in inception_4b_5x5_red: %f\n', max(abs(data(:) - inception_5x5_red(:))));
end

pool_rslt = maxpool(output, 3, 1);
load('Intermed_Results\55_inception_4b_pool.mat');
if (cmp)
    fprintf('Max error in maxpool 4b: %f\n', max(abs(data(:) - pool_rslt(:))));
end

load('Params\inception_4b_3x3_b.mat');
load('Params\inception_4b_3x3_w.mat');
inception_3x3 = conv(inception_3x3_red, weights, bias, 3, 1, 1, 1);
inception_3x3 = relu(inception_3x3);
load('Intermed_Results\52_inception_4b_3x3.mat');
if (cmp)
    fprintf('Max error in inception_4b_3x3: %f\n', max(abs(data(:) - inception_3x3(:))));
end

load('Params\inception_4b_5x5_b.mat');
load('Params\inception_4b_5x5_w.mat');
inception_5x5 = conv(inception_5x5_red, weights, bias, 5, 1, 2, 1);
inception_5x5 = relu(inception_5x5);
load('Intermed_Results\54_inception_4b_5x5.mat');
if (cmp)
    fprintf('Max error in inception_4b_5x5: %f\n', max(abs(data(:) - inception_5x5(:))));
end

load('Params\inception_4b_pool_proj_b.mat');
load('Params\inception_4b_pool_proj_w.mat');
inception_proj = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_proj = relu(inception_proj);
load('Intermed_Results\56_inception_4b_pool_proj.mat');
if (cmp)
    fprintf('Max error in inception_4b proj: %f\n', max(abs(data(:) - inception_proj(:))));
end

output = zeros(14, 14, 512);
output(:, :, 1:160) = inception_1x1;
output(:, :, 161:384) = inception_3x3;
output(:, :, 385:448) = inception_5x5;
output(:, :, 449:512) = inception_proj;
load('Intermed_Results\57_inception_4b_output.mat')
if (cmp)
    fprintf('Max error in output 4b: %f\n', max(abs(data(:) - output(:))));
end    
%%
load('Params\inception_4c_1x1_b.mat');
load('Params\inception_4c_1x1_w.mat');
inception_1x1 = conv(output, weights, bias, 1, 1, 0, 1);
inception_1x1 = relu(inception_1x1);
load('Intermed_Results\62_inception_4c_1x1.mat');
if (cmp)
    fprintf('Max error in inception_4c_1x1: %f\n', max(abs(data(:) - inception_1x1(:))));
end

load('Params\inception_4c_3x3_reduce_b.mat');
load('Params\inception_4c_3x3_reduce_w.mat');
inception_3x3_red = conv(output, weights, bias, 1, 1, 0, 1);
inception_3x3_red = relu(inception_3x3_red);
load('Intermed_Results\63_inception_4c_3x3_reduce.mat');
if (cmp)
    fprintf('Max error in inception_4c_3x3_red: %f\n', max(abs(data(:) - inception_3x3_red(:))));
end

load('Params\inception_4c_5x5_reduce_b.mat');
load('Params\inception_4c_5x5_reduce_w.mat');
inception_5x5_red = conv(output, weights, bias, 1, 1, 0, 1);
inception_5x5_red = relu(inception_5x5_red);
load('Intermed_Results\65_inception_4c_5x5_reduce.mat');
if (cmp)
    fprintf('Max error in inception_4c_5x5_red: %f\n', max(abs(data(:) - inception_5x5_red(:))));
end

pool_rslt = maxpool(output, 3, 1);
load('Intermed_Results\67_inception_4c_pool.mat');
if (cmp)
    fprintf('Max error in maxpool 4c: %f\n', max(abs(data(:) - pool_rslt(:))));
end

load('Params\inception_4c_3x3_b.mat');
load('Params\inception_4c_3x3_w.mat');
inception_3x3 = conv(inception_3x3_red, weights, bias, 3, 1, 1, 1);
inception_3x3 = relu(inception_3x3);
load('Intermed_Results\64_inception_4c_3x3.mat');
if (cmp)
    fprintf('Max error in inception_4c_3x3: %f\n', max(abs(data(:) - inception_3x3(:))));
end

load('Params\inception_4c_5x5_b.mat');
load('Params\inception_4c_5x5_w.mat');
inception_5x5 = conv(inception_5x5_red, weights, bias, 5, 1, 2, 1);
inception_5x5 = relu(inception_5x5);
load('Intermed_Results\66_inception_4c_5x5.mat');
if (cmp)
    fprintf('Max error in inception_4c_5x5: %f\n', max(abs(data(:) - inception_5x5(:))));
end

load('Params\inception_4c_pool_proj_b.mat');
load('Params\inception_4c_pool_proj_w.mat');
inception_proj = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_proj = relu(inception_proj);
load('Intermed_Results\68_inception_4c_pool_proj.mat');
if (cmp)
    fprintf('Max error in inception_4c proj: %f\n', max(abs(data(:) - inception_proj(:))));
end

output = zeros(14, 14, 512);
output(:, :, 1:128) = inception_1x1;
output(:, :, 129:384) = inception_3x3;
output(:, :, 385:448) = inception_5x5;
output(:, :, 449:512) = inception_proj;
load('Intermed_Results\69_inception_4c_output.mat')
if (cmp)
    fprintf('Max error in output 4c: %f\n', max(abs(data(:) - output(:))));
end

%%
load('Params\inception_4d_1x1_b.mat');
load('Params\inception_4d_1x1_w.mat');
inception_1x1 = conv(output, weights, bias, 1, 1, 0, 1);
inception_1x1 = relu(inception_1x1);
load('Intermed_Results\74_inception_4d_1x1.mat');
if (cmp)
    fprintf('Max error in inception_4d_1x1: %f\n', max(abs(data(:) - inception_1x1(:))));
end
load('Params\inception_4d_3x3_reduce_b.mat');
load('Params\inception_4d_3x3_reduce_w.mat');
inception_3x3_red = conv(output, weights, bias, 1, 1, 0, 1);
inception_3x3_red = relu(inception_3x3_red);
load('Intermed_Results\75_inception_4d_3x3_reduce.mat');
if (cmp)
    fprintf('Max error in inception_4d_3x3_red: %f\n', max(abs(data(:) - inception_3x3_red(:))));
end

load('Params\inception_4d_5x5_reduce_b.mat');
load('Params\inception_4d_5x5_reduce_w.mat');
inception_5x5_red = conv(output, weights, bias, 1, 1, 0, 1);
inception_5x5_red = relu(inception_5x5_red);
load('Intermed_Results\77_inception_4d_5x5_reduce.mat');
if (cmp)
    fprintf('Max error in inception_4d_5x5_red: %f\n', max(abs(data(:) - inception_5x5_red(:))));
end

pool_rslt = maxpool(output, 3, 1);
load('Intermed_Results\79_inception_4d_pool.mat');
if (cmp)
    fprintf('Max error in maxpool 4d: %f\n', max(abs(data(:) - pool_rslt(:))));
end

load('Params\inception_4d_3x3_b.mat');
load('Params\inception_4d_3x3_w.mat');
inception_3x3 = conv(inception_3x3_red, weights, bias, 3, 1, 1, 1);
inception_3x3 = relu(inception_3x3);
load('Intermed_Results\76_inception_4d_3x3.mat');
if (cmp)
    fprintf('Max error in inception_4d_3x3: %f\n', max(abs(data(:) - inception_3x3(:))));
end
load('Params\inception_4d_5x5_b.mat');
load('Params\inception_4d_5x5_w.mat');
inception_5x5 = conv(inception_5x5_red, weights, bias, 5, 1, 2, 1);
inception_5x5 = relu(inception_5x5);
load('Intermed_Results\78_inception_4d_5x5.mat');
if (cmp)
    fprintf('Max error in inception_4d_5x5: %f\n', max(abs(data(:) - inception_5x5(:))));
end
load('Params\inception_4d_pool_proj_b.mat');
load('Params\inception_4d_pool_proj_w.mat');
inception_proj = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_proj = relu(inception_proj);
load('Intermed_Results\80_inception_4d_pool_proj.mat');
if (cmp)
    fprintf('Max error in inception_4d proj: %f\n', max(abs(data(:) - inception_proj(:))));
end
output = zeros(14, 14, 528);
output(:, :, 1:112) = inception_1x1;
output(:, :, 113:400) = inception_3x3;
output(:, :, 401:464) = inception_5x5;
output(:, :, 465:528) = inception_proj;
load('Intermed_Results\81_inception_4d_output.mat')
if (cmp)
    fprintf('Max error in output 4d: %f\n', max(abs(data(:) - output(:))));
end
%%
load('Params\inception_4e_1x1_b.mat');
load('Params\inception_4e_1x1_w.mat');
inception_1x1 = conv(output, weights, bias, 1, 1, 0, 1);
inception_1x1 = relu(inception_1x1);
load('Intermed_Results\86_inception_4e_1x1.mat');
if (cmp)
    fprintf('Max error in inception_4e_1x1: %f\n', max(abs(data(:) - inception_1x1(:))));
end

load('Params\inception_4e_3x3_reduce_b.mat');
load('Params\inception_4e_3x3_reduce_w.mat');
inception_3x3_red = conv(output, weights, bias, 1, 1, 0, 1);
inception_3x3_red = relu(inception_3x3_red);
load('Intermed_Results\87_inception_4e_3x3_reduce.mat');
if (cmp)
    fprintf('Max error in inception_4e_3x3_red: %f\n', max(abs(data(:) - inception_3x3_red(:))));
end

load('Params\inception_4e_5x5_reduce_b.mat');
load('Params\inception_4e_5x5_reduce_w.mat');
inception_5x5_red = conv(output, weights, bias, 1, 1, 0, 1);
inception_5x5_red = relu(inception_5x5_red);
load('Intermed_Results\89_inception_4e_5x5_reduce.mat');
if (cmp)
    fprintf('Max error in inception_4e_5x5_red: %f\n', max(abs(data(:) - inception_5x5_red(:))));
end

pool_rslt = maxpool(output, 3, 1);
load('Intermed_Results\91_inception_4e_pool.mat');
if (cmp)
    fprintf('Max error in maxpool 4e: %f\n', max(abs(data(:) - pool_rslt(:))));
end

load('Params\inception_4e_3x3_b.mat');
load('Params\inception_4e_3x3_w.mat');
inception_3x3 = conv(inception_3x3_red, weights, bias, 3, 1, 1, 1);
inception_3x3 = relu(inception_3x3);
load('Intermed_Results\88_inception_4e_3x3.mat');
if (cmp)
    fprintf('Max error in inception_4e_3x3: %f\n', max(abs(data(:) - inception_3x3(:))));
end

load('Params\inception_4e_5x5_b.mat');
load('Params\inception_4e_5x5_w.mat');
inception_5x5 = conv(inception_5x5_red, weights, bias, 5, 1, 2, 1);
inception_5x5 = relu(inception_5x5);
load('Intermed_Results\90_inception_4e_5x5.mat');
if (cmp)
    fprintf('Max error in inception_4e_5x5: %f\n', max(abs(data(:) - inception_5x5(:))));
end

load('Params\inception_4e_pool_proj_b.mat');
load('Params\inception_4e_pool_proj_w.mat');
inception_proj = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_proj = relu(inception_proj);
load('Intermed_Results\92_inception_4e_pool_proj.mat');
if (cmp)
    fprintf('Max error in inception_4e proj: %f\n', max(abs(data(:) - inception_proj(:))));
end

output = zeros(14, 14, 832);
output(:, :, 1:256) = inception_1x1;
output(:, :, 257:576) = inception_3x3;
output(:, :, 577:704) = inception_5x5;
output(:, :, 705:832) = inception_proj;
load('Intermed_Results\93_inception_4e_output.mat')
if (cmp)
    fprintf('Max error in output 4e: %f\n', max(abs(data(:) - output(:))));
end

%%
output = maxpool(output, 3, 2);
load('Intermed_Results\94_pool4_3x3_s2.mat');
if (cmp)
    fprintf('Max error in maxpool 4 3x3 s2: %f\n', max(abs(data(:) - output(:))));
end    
%%
load('Params\inception_5a_1x1_b.mat');
load('Params\inception_5a_1x1_w.mat');
inception_1x1 = conv(output, weights, bias, 1, 1, 0, 1);
inception_1x1 = relu(inception_1x1);
load('Intermed_Results\99_inception_5a_1x1.mat');
if (cmp)
    fprintf('Max error in inception_5a_1x1: %f\n', max(abs(data(:) - inception_1x1(:))));
end

load('Params\inception_5a_3x3_reduce_b.mat');
load('Params\inception_5a_3x3_reduce_w.mat');
inception_3x3_red = conv(output, weights, bias, 1, 1, 0, 1);
inception_3x3_red = relu(inception_3x3_red);
load('Intermed_Results\100_inception_5a_3x3_reduce.mat');
if (cmp)
    fprintf('Max error in inception_5a_3x3_red: %f\n', max(abs(data(:) - inception_3x3_red(:))));
end

load('Params\inception_5a_5x5_reduce_b.mat');
load('Params\inception_5a_5x5_reduce_w.mat');
inception_5x5_red = conv(output, weights, bias, 1, 1, 0, 1);
inception_5x5_red = relu(inception_5x5_red);
load('Intermed_Results\102_inception_5a_5x5_reduce.mat');
if (cmp)
    fprintf('Max error in inception_5a_5x5_red: %f\n', max(abs(data(:) - inception_5x5_red(:))));
end

pool_rslt = maxpool(output, 3, 1);
load('Intermed_Results\104_inception_5a_pool.mat');
if (cmp)
    fprintf('Max error in maxpool 5a: %f\n', max(abs(data(:) - pool_rslt(:))));
end

load('Params\inception_5a_3x3_b.mat');
load('Params\inception_5a_3x3_w.mat');
inception_3x3 = conv(inception_3x3_red, weights, bias, 3, 1, 1, 1);
inception_3x3 = relu(inception_3x3);
load('Intermed_Results\101_inception_5a_3x3.mat');
if (cmp)
    fprintf('Max error in inception_5a_3x3: %f\n', max(abs(data(:) - inception_3x3(:))));
end

load('Params\inception_5a_5x5_b.mat');
load('Params\inception_5a_5x5_w.mat');
inception_5x5 = conv(inception_5x5_red, weights, bias, 5, 1, 2, 1);
inception_5x5 = relu(inception_5x5);
load('Intermed_Results\103_inception_5a_5x5.mat');
if (cmp)
    fprintf('Max error in inception_5a_5x5: %f\n', max(abs(data(:) - inception_5x5(:))));
end

load('Params\inception_5a_pool_proj_b.mat');
load('Params\inception_5a_pool_proj_w.mat');
inception_proj = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_proj = relu(inception_proj);
load('Intermed_Results\105_inception_5a_pool_proj.mat');
if (cmp)
    fprintf('Max error in inception_5a proj: %f\n', max(abs(data(:) - inception_proj(:))));
end

output = zeros(7, 7, 832);
output(:, :, 1:256) = inception_1x1;
output(:, :, 257:576) = inception_3x3;
output(:, :, 577:704) = inception_5x5;
output(:, :, 705:832) = inception_proj;
load('Intermed_Results\106_inception_5a_output.mat')
if (cmp)
    fprintf('Max error in output 5a: %f\n', max(abs(data(:) - output(:))));
end

%%
load('Params\inception_5b_1x1_b.mat');
load('Params\inception_5b_1x1_w.mat');
inception_1x1 = conv(output, weights, bias, 1, 1, 0, 1);
inception_1x1 = relu(inception_1x1);
load('Intermed_Results\111_inception_5b_1x1.mat');
if (cmp)
    fprintf('Max error in inception_5b_1x1: %f\n', max(abs(data(:) - inception_1x1(:))));
end

load('Params\inception_5b_3x3_reduce_b.mat');
load('Params\inception_5b_3x3_reduce_w.mat');
inception_3x3_red = conv(output, weights, bias, 1, 1, 0, 1);
inception_3x3_red = relu(inception_3x3_red);
load('Intermed_Results\112_inception_5b_3x3_reduce.mat');
if (cmp)
    fprintf('Max error in inception_5b_3x3_red: %f\n', max(abs(data(:) - inception_3x3_red(:))));
end

load('Params\inception_5b_5x5_reduce_b.mat');
load('Params\inception_5b_5x5_reduce_w.mat');
inception_5x5_red = conv(output, weights, bias, 1, 1, 0, 1);
inception_5x5_red = relu(inception_5x5_red);
load('Intermed_Results\114_inception_5b_5x5_reduce.mat');
if (cmp)
    fprintf('Max error in inception_5b_5x5_red: %f\n', max(abs(data(:) - inception_5x5_red(:))));
end

pool_rslt = maxpool(output, 3, 1);
load('Intermed_Results\116_inception_5b_pool.mat');
if (cmp)
    fprintf('Max error in maxpool 5b: %f\n', max(abs(data(:) - pool_rslt(:))));
end

load('Params\inception_5b_3x3_b.mat');
load('Params\inception_5b_3x3_w.mat');
inception_3x3 = conv(inception_3x3_red, weights, bias, 3, 1, 1, 1);
inception_3x3 = relu(inception_3x3);
load('Intermed_Results\113_inception_5b_3x3.mat');
if (cmp)
    fprintf('Max error in inception_5b_3x3: %f\n', max(abs(data(:) - inception_3x3(:))));
end

load('Params\inception_5b_5x5_b.mat');
load('Params\inception_5b_5x5_w.mat');
inception_5x5 = conv(inception_5x5_red, weights, bias, 5, 1, 2, 1);
inception_5x5 = relu(inception_5x5);
load('Intermed_Results\115_inception_5b_5x5.mat');
if (cmp)
    fprintf('Max error in inception_5b_5x5: %f\n', max(abs(data(:) - inception_5x5(:))));
end

load('Params\inception_5b_pool_proj_b.mat');
load('Params\inception_5b_pool_proj_w.mat');
inception_proj = conv(pool_rslt, weights, bias, 1, 1, 0, 1);
inception_proj = relu(inception_proj);
load('Intermed_Results\117_inception_5b_pool_proj.mat');
if (cmp)
    fprintf('Max error in inception_5b proj: %f\n', max(abs(data(:) - inception_proj(:))));
end

output = zeros(7, 7, 1024);
output(:, :, 1:384) = inception_1x1;
output(:, :, 385:768) = inception_3x3;
output(:, :, 769:896) = inception_5x5;
output(:, :, 897:1024) = inception_proj;
load('Intermed_Results\118_inception_5b_output.mat')
if (cmp)
    fprintf('Max error in output 5b: %f\n', max(abs(data(:) - output(:))));
end

%%
output = avgpool(output, 7, 1);
load('Intermed_Results\119_pool5_7x7_s1.mat');
if (cmp)
    fprintf('Max error in avgpool: %f\n', max(abs(data(:) - output(:))));
end
%%
load('Params\loss3_classifier_b.mat');
load('Params\loss3_classifier_w.mat');
output = fc(output, weights, bias);
load('Intermed_Results\120_loss3_classifier.mat')
if (cmp)
    fprintf('Max error in FC : %f\n', max(abs(data(:) - output(:))));
end
%%
output = softmax(output);
load('Intermed_Results\121_prob.mat')
if (cmp)
    fprintf('Max error in prob : %f\n', max(abs(data(:) - output(:))));
end
toc