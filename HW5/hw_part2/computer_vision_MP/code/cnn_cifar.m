% function are called with two types
% either cnn_cifar('coarse') or cnn_cifar('fine')
% coarse will classify the image into 20 catagories
% fine will classify the image into 100 catagories
function cnn_cifar(type, varargin)

type = 'fine';
% if ~(strcmp(type, 'fine') || strcmp(type, 'coarse')) 
%     error('The argument has to be either fine or coarse');
% end

% record the time
tic
%% --------------------------------------------------------------------
%                                                         Set parameters
% --------------------------------------------------------------------
%
% data directory
opts.dataDir = fullfile('cifar_data','cifar') ;
% experiment result directory
opts.expDir = fullfile('cifar_data','cifar-baseline') ;
% image database
opts.imdbPath = fullfile(opts.expDir, 'imdb.mat');
% set up the batch size (split the data into batches)
opts.train.batchSize = 128 ;
% number of Epoch (iterations)
opts.train.numEpochs = 21 ;
% resume the train
opts.train.continue = true ;
% use the GPU to train
opts.train.useGpu = true ;
% set the learning rate
opts.train.learningRate = [0.001*ones(1, 10) 0.0001*ones(1,15)] ;
% set weight decay
opts.train.weightDecay = 0.0005 ;
% set momentum
opts.train.momentum = 0.9 ;
% experiment result directory
opts.train.expDir = opts.expDir ;
% parse the varargin to opts. 
% If varargin is empty, opts argument will be set as above
opts = vl_argparse(opts, varargin);

% --------------------------------------------------------------------
%                                                         Prepare data
% --------------------------------------------------------------------

imdb = load(opts.imdbPath) ;

f = 1/100;

%% Define network 
% The part you have to modify
net.layers = {} ;

% 1 conv1
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.03*randn(4,4,3,48, 'single'), zeros(1, 48, 'single')}}, ...
                           'learningRate',[1,2],...
                           'dilate', 1, ...
                           'stride', 1, ...
                           'pad', 1,...
                           'opts',{{}}) ;
% 2 conv1
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.03*randn(4,4,48,48, 'single'), zeros(1, 48, 'single')}}, ...
                           'learningRate',[1,2],...
                           'dilate', 1, ...
                           'stride', 1, ...
                           'pad', 1,...
                           'opts',{{}}) ;

% 3 relu2
net.layers{end+1} = struct('type', 'relu','leak',0) ;

% 4 pool1 (avg pool)
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'avg', ...
                           'pool', [2 2], ...
                           'stride', 2, ...
                           'pad', 0,...
                           'opts',{{}}) ;
                       
% 5 conv1
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.03*randn(4,4,48,48, 'single'), zeros(1, 48, 'single')}}, ...
                           'learningRate',[1,2],...
                           'dilate', 1, ...
                           'stride', 1, ...
                           'pad', 0,...
                           'opts',{{}}) ;
% 6 conv1
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.03*randn(5,5,48,48, 'single'), zeros(1, 48, 'single')}}, ...
                           'learningRate',[1,2],...
                           'dilate', 1, ...
                           'stride', 1, ...
                           'pad', 1,...
                           'opts',{{}}) ;

% 7 relu2
net.layers{end+1} = struct('type', 'relu','leak',0) ;

% 8 pool1 (avg pool)
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'avg', ...
                           'pool', [2 2], ...
                           'stride', 2, ...
                           'pad', 0,...
                           'opts',{{}}) ;
                       
% 9 conv1
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.03*randn(4,4,48,48, 'single'), zeros(1, 48, 'single')}}, ...
                           'learningRate',[1,2],...
                           'dilate', 1, ...
                           'stride', 1, ...
                           'pad', 1,...
                           'opts',{{}}) ;
% 10 conv1
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.03*randn(5,5,48,64, 'single'), zeros(1, 64, 'single')}}, ...
                           'learningRate',[1,2],...
                           'dilate', 1, ...
                           'stride', 1, ...
                           'pad', 1,...
                           'opts',{{}}) ;

% 11 relu2
net.layers{end+1} = struct('type', 'relu','leak',0) ;

% 12 pool1 (avg pool)
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'avg', ...
                           'pool', [2 2], ...
                           'stride', 2, ...
                           'pad', 0,...
                           'opts',{{}}) ;

% 13 Dropout
net.layers{end+1} = struct('type', 'dropout', 'rate', 0.4);


% 14 conv2
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.02*randn(1,1,64,100, 'single'), zeros(1, 100, 'single')}}, ...
                           'learningRate',[1,2],...
                           'dilate', 1, ...
                           'stride', 1, ...
                           'pad', 0,...
                           'opts',{{}}) ;
              
% 15 relu2
net.layers{end+1} = struct('type', 'relu','leak',0);
                      
% 16 loss
net.layers{end+1} = struct('type', 'softmaxloss');
% --------------------------------------------------------------------
%                                                                Train
% --------------------------------------------------------------------

% Take the mean out and make GPU if needed
imdb.images.data = bsxfun(@minus, imdb.images.data, mean(imdb.images.data,4)) ;
if opts.train.useGpu
  imdb.images.data = gpuArray(imdb.images.data) ;
end
%% display the net
vl_simplenn_display(net);
%% start training
[net,info] = cnn_train_cifar(net, imdb, @getBatch, ...
    opts.train, ...
    'val', find(imdb.images.set == 2) , 'test', find(imdb.images.set == 3)) ;
%% Record the result into csv and draw confusion matrix
load(['cifar_data/cifar-baseline/net-epoch-' int2str(opts.train.numEpochs) '.mat']);
load(['cifar_data/cifar-baseline/imdb' '.mat']);
fid = fopen('cifar_prediction.csv', 'w');
strings = {'ID','Label'};
for row = 1:size(strings,1)
    fprintf(fid, repmat('%s,',1,size(strings,2)-1), strings{row,1:end-1});
    fprintf(fid, '%s\n', strings{row,end});
end
fclose(fid);
ID = 1:numel(info.test.prediction_class);
dlmwrite('cifar_prediction.csv',[ID', info.test.prediction_class], '-append');

val_groundtruth = images.labels(45001:end);
val_prediction = info.val.prediction_class;
val_confusionMatrix = confusion_matrix(val_groundtruth , val_prediction);
cmp = jet(50);
figure ;
imshow(ind2rgb(uint8(val_confusionMatrix),cmp));
imwrite(ind2rgb(uint8(val_confusionMatrix),cmp) , 'cifar_confusion_matrix.png');
toc

% --------------------------------------------------------------------
%% call back function get the part of the batch
function [im, labels] = getBatch(imdb, batch , set)
% --------------------------------------------------------------------
im = imdb.images.data(:,:,:,batch) ;
% data augmentation
% if set == 1 % training
%     for i = 1:length(batch)
%         im(:, :, :, i) = imrotate(im(:, :, :, i), randi(25), 'bilinear', 'crop');
%     end
% end


if set ~= 3
    labels = imdb.images.labels(1,batch) ;
end



