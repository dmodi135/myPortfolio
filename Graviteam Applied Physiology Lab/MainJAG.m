%Run This Function to call the indivudal functins

function [struct] = MainJAG(pp, lr, toPlotOrNotToPlot)

%input Pre or Post or LOWG- (1 or 2 or 3 respectively)
if pp == 1
    pp = 'PRE';
elseif pp == 2
    pp = 'POST';
elseif pp == 3
    pp = 'LOWG';
end
%input L or R - (1 or 2 respectively)
if lr == 1
    lr = 'L';
elseif lr == 2
    lr = 'R';
end
%input 1 if plot wanted

%runs code
[struct] = allJAG(lr, pp, toPlotOrNotToPlot);

end