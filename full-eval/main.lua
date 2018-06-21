require 'paths'
paths.dofile('util.lua')
paths.dofile('img.lua')

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

dataset = arg[1]

set = 'valid'

if dataset == 'h36m' then
    -- Evaluation on users S9 and S11 of Human3.6M dataset
    a = loadAnnotations('h36m')
    m_ord = torch.load('ordinal-h36m.t7')   -- Load pre-trained model
    m_rec = torch.load('rec-h36m.t7')   -- Load pre-trained model

elseif dataset == 'h36m-sample' then
    -- Small set of Human3.6M for action Posing_1 of subject S9 and camera 55011271 
    a = loadAnnotations('h36m-sample')
    m_ord = torch.load('ordinal-h36m.t7')   -- Load pre-trained model
    m_rec = torch.load('rec-h36m.t7')   -- Load pre-trained model

else
    print("Please use one of the following input arguments:")
    print("    h36m : Full test set of Human3.6M dataset (users S9 and S11)")
    print("    h36m-sample : Small set of Human3.6M")
    return
end
m_ord:cuda()
m_rec:cuda()

idxs = torch.range(1,a.nsamples)

nsamples = idxs:nElement() 
-- Displays a convenient progress bar
xlua.progress(0,nsamples)
preds3D = torch.Tensor(1,17,3)

scaling = torch.Tensor(1,17,64)
for i = 1, 17 do
    for j = 1, 64 do
         scaling[1][i][j] = (j-32)*10
    end
end

expDir = paths.concat('exp',dataset)
os.execute('mkdir -p ' .. expDir)

--------------------------------------------------------------------------------
-- Main loop
--------------------------------------------------------------------------------

for i = 1,nsamples do
    -- Set up input image
    local im = image.load('../data/' .. dataset ..'/images/' .. a['images'][idxs[i]])
    local center = a['center'][idxs[i]]
    local scale = a['scale'][idxs[i]]
    local inp = crop(im, center, scale, 0, 256)

    -- Get network output
    local outVol = m_ord:forward({inp:view(1,3,256,256):cuda(),scaling:cuda()})
    outVol = applyFn(function (x) return x:clone() end, outVol[#outVol-1])
    local flippedOutVol = m_ord:forward({flip(inp:view(1,3,256,256):cuda()),scaling:cuda()})
    flippedOutVol = applyFn(function (x) return flip(shuffleLR(x)) end, flippedOutVol[#flippedOutVol-1])
    outVol = applyFn(function (x,y) return x:add(y):div(2) end, outVol, flippedOutVol)
    -- size 1x17x3
    local outOrd = getPreds3D(outVol)

    outOrd = outOrd[1]:transpose(1,2)
    pts = outOrd:sub(1,2)
    pts[1] = pts[1] - pts[1][1]
    pts[2] = pts[2] - pts[2][1]
    scale = torch.max(torch.abs(pts))
    pts[1] = pts[1]/scale
    pts[2] = pts[2]/scale
    zind = (outOrd[3]:double()-33)/32.0

    local inp_rec = torch.Tensor(3*17)
    inp_rec:sub(1,17):copy(pts[1])
    inp_rec:sub(18,34):copy(pts[2])
    inp_rec:sub(35,51):copy(zind)

    -- reshape to 1x3x17 and then view as 1x51
    local out3D = m_rec:forward(inp_rec:view(1,51):cuda())
    cutorch.synchronize()

    preds3D:copy(torch.reshape(out3D,1,3,17):transpose(2,3))

    local predFile = hdf5.open(paths.concat(expDir, set .. '_' .. idxs[i] .. '.h5'), 'w')
    predFile:write('preds3D', preds3D)
    predFile:close()

    xlua.progress(i,nsamples)

    collectgarbage()
end

