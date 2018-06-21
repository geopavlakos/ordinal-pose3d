require 'torch'
require 'xlua'
require 'nn'
require 'nnx'
require 'nngraph'
require 'image'
require 'hdf5'
require 'sys'

require 'cunn'
require 'cutorch'
require 'cudnn'

torch.setdefaulttensortype('torch.FloatTensor')

function loadAnnotations(dataset)

    local a = hdf5.open('../data/' .. dataset .. '/annot/' .. set .. '.h5')
    annot = {}

    -- Read in annotation information from hdf5 file
    local tags = {'center','scale'}
    for _,tag in ipairs(tags) do annot[tag] = a:read(tag):all() end
    annot.nsamples = annot.center:size()[1]
    a:close()

    -- Load in image file names
    -- (workaround for not being able to read the strings in the hdf5 file)
    annot.images = {}
    local toIdxs = {}
    local namesFile = io.open('../data/' .. dataset .. '/annot/' .. set .. '_images.txt')
    local idx = 1
    for line in namesFile:lines() do
        annot.images[idx] = line
        if not toIdxs[line] then toIdxs[line] = {} end
        table.insert(toIdxs[line], idx)
        idx = idx + 1
    end
    namesFile:close()

    -- This allows us to reference all people who are in the same image
    annot.imageToIdxs = toIdxs

    return annot
end

function getPreds3D(hm)
    assert(hm:size():size() == 4, 'Input must be 4-D tensor')
    local max, idx = torch.max(hm:view(hm:size(1), hm:size(2)/64, 64*hm:size(3) * hm:size(4)), 3)
    local preds = torch.repeatTensor(idx, 1, 1, 3):float()
    preds[{{}, {}, 1}]:apply(function(x) return (x - 1) % hm:size(4) + 1 end)
    preds[{{}, {}, 2}]:add(-1):div(hm:size(4)):floor():mod(hm:size(3)):add(1)
    preds[{{}, {}, 3}]:add(-1):div(hm:size(3)*hm:size(4)):floor():add(1)
    return preds
end

function getPreds(hms, center, scale)
    if hms:size():size() == 3 then hms = hms:view(1, hms:size(1), hms:size(2), hms:size(3)) end

    -- Get locations of maximum activations
    local max, idx = torch.max(hms:view(hms:size(1), hms:size(2), hms:size(3) * hms:size(4)), 3)
    local preds = torch.repeatTensor(idx, 1, 1, 2):float()
    preds[{{}, {}, 1}]:apply(function(x) return (x - 1) % hms:size(4) + 1 end)
    preds[{{}, {}, 2}]:add(-1):div(hms:size(3)):floor():add(.5)

    -- Get transformed coordinates
    local preds_tf = torch.zeros(preds:size())
    for i = 1,hms:size(1) do        -- Number of samples
        for j = 1,hms:size(2) do    -- Number of output heatmaps for one sample
            preds_tf[i][j] = transform(preds[i][j],center,scale,0,hms:size(3),true)
        end
    end

    return preds, preds_tf
end

local matchedParts = {
    {2,5}, {3,6}, {4,7}, {12,15}, {13,16}, {14,17}
}

matchedParts3D = {}
for j = 1,#matchedParts do
    for k = 1,64 do
         table.insert(matchedParts3D,{(matchedParts[j][1]-1)*64+k,(matchedParts[j][2]-1)*64+k})
    end
end

function applyFn(fn, t, t2)
    -- Helper function for applying an operation whether passed a table or tensor
    local t_ = {}
    if type(t) == "table" then
        if t2 then
            for i = 1,#t do t_[i] = applyFn(fn, t[i], t2[i]) end
        else
            for i = 1,#t do t_[i] = applyFn(fn, t[i]) end
        end
    else t_ = fn(t, t2) end
    return t_
end
