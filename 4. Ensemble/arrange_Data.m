function [ D, Label, nDim, IFoutDim ] = arrange_Data( Feature, Options, tidx )

nData = length(Feature.Time);

Used_FieldName = Options.Used_FieldName;

% Calculate dimension of data
nDim = 0;
IFoutDim = 0;
for i = 1:length(Used_FieldName)
    cur_fieldname = char(Used_FieldName(i));
    if strcmp(cur_fieldname, 'Implicit')
        nDim = nDim + size(Feature.Implicit.Feature, 2);
        IFoutDim = size(Feature.Implicit.Feature, 2);
    else
        nDim = nDim + size(Feature.(cur_fieldname), 2);
    end
end


% Arrange data matrix from several features
D = zeros(nData, 1);
count_dim = 0;
for i = 1:length(Used_FieldName)
    cur_fieldname = char(Used_FieldName(i));
    
    if strcmp(cur_fieldname, 'Implicit')
        cur_fielddim = size(Feature.Implicit.Feature, 2);
        train_IFmatrix = Feature.Implicit.Feature;
        train_IFmatrix(tidx, :) = [];
        test_IFmatrix = Feature.Implicit.FeatureT(tidx, :);
        
        % Implicit feature PCA
        if Options.PCA.IFFlag
            [pca_coeff, ~, pca_latent] = pca(train_IFmatrix);
            if Options.PCA.UseCUT
                vsum = 0;
                for j = 1:length(pca_latent)
                    vsum = vsum + pca_latent(j);
                    if sqrt(vsum/sum(pca_latent)) >= Options.PCA.CUTVal
                        break;
                    end
                end
                
                IFoutDim = j;
                nDim = nDim - (cur_fielddim - IFoutDim);
                cur_fielddim = IFoutDim;
            end
            
            train_IFmatrix = train_IFmatrix * pca_coeff(:, 1:IFoutDim);
            test_IFmatrix = test_IFmatrix * pca_coeff(:, 1:IFoutDim);
        end
        
        D(:, count_dim+1:count_dim+cur_fielddim) = [train_IFmatrix; test_IFmatrix];
    else
        cur_fielddim = size(Feature.(cur_fieldname), 2);
        
        D(:, count_dim+1:count_dim+cur_fielddim) = Feature.(cur_fieldname);
    end
    
    count_dim = count_dim + cur_fielddim;
end

Label = Feature.Label;

end