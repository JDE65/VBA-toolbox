function handles = VBA_displayGroupBMC(posterior,out)
% displays group-level BMC analysis results
% function handles = VBA_displayGroupBMC(posterior,out)
% IN:
%   - posterior/out: output structures of VBA_groupBMC.m
% OUT:
%   - handles: structure containing the handles of the graphical objects


[K,n] = size(out.L);
hf = findobj('tag','groupBMC');
if isfield(out.options,'handles') && ismember(out.options.handles.hf,hf)
    ha = intersect(get(out.options.handles.hf,'children'),findobj('type','axes'));
    if all(ismember(out.options.handles.ha,ha))
        handles = out.options.handles;
        doFig = 0;
    else
        doFig = 1;
    end
else
    doFig = 1;
end
if doFig
    pos0 = get(0,'screenSize');
    pos = [0.51*pos0(3),0.05*pos0(4),0.45*pos0(3),0.85*pos0(4)];
    handles.hf = figure(...
        'position',pos,...
        'color',[1 1 1],...
        'name','group-level Bayesian model comparison',...
        'tag','groupBMC');
    handles.ha(1) = subplot(3,2,1,'parent',handles.hf,'nextplot','add');
    handles.ha(2) = subplot(3,2,2,'parent',handles.hf,'nextplot','add','clim',[0,1]);
    colormap(handles.ha(2),flipud(bone))
    handles.hc = colorbar('peer',handles.ha(2),'location','NorthOutside');
    set(handles.hc,'visible','off')
    handles.ha(3) = subplot(3,2,4,'parent',handles.hf,'nextplot','add');
    handles.ha(4) = subplot(3,2,3,'parent',handles.hf,'nextplot','add');
    handles.ha(5) = subplot(3,2,5,'parent',handles.hf,'nextplot','add');
    if ~isempty(out.options.families)
        handles.ha(6) = subplot(8,2,16,'parent',handles.hf,'nextplot','add');
        handles.ha(7) = subplot(8,2,14,'parent',handles.hf,'nextplot','add');
        pos = get(handles.ha(7),'position');
        set(handles.ha(7),'position',pos+[0,pos(4)/2,0,0])
    end
    handles.ho = uicontrol('parent',handles.hf,...
        'style','text',...
        'tag','groupBMC',...
        'units','normalized',...
        'position',[0.2,0.01,0.6,0.02],...
        'backgroundcolor',[1,1,1]);
    % display data (ie log-model evidences)
    col = getColors(n);
    for i=1:n
        plot(handles.ha(1),out.L(:,i),'color',col(i,:))
        plot(handles.ha(1),out.L(:,i),'.','color',col(i,:))
    end
    xlabel(handles.ha(1),'models')
    set(handles.ha(1),...
        'xtick',1:K,...
        'xlim',[0.5,K+0.5],...
        'ygrid','on')
    title(handles.ha(1),'log- model evidences')
    % display families partition
    if ~isempty(out.options.families)
        nf = size(out.options.C,2);
        hi = imagesc(out.options.C','parent',handles.ha(7));
        axis(handles.ha(7),'tight')
        xlabel(handles.ha(7),'models')
        ylabel(handles.ha(7),'families')
        title(handles.ha(7),'families'' partition')
        set(handles.ha(7),...
            'xlim',[0.5,K+0.5],...
            'xtick',[1:K],...
            'ylim',[0.5,nf+0.5],...
            'ytick',[1:nf],...
            'ydir','reverse',...
            'clim',[0 1])
    end
end



% display model attributions
cla(handles.ha(2))
hi = imagesc(posterior.r','parent',handles.ha(2));
axis(handles.ha(2),'tight')
xlabel(handles.ha(2),'models')
ylabel(handles.ha(2),'subjects')
title(handles.ha(2),'model attributions')
set(handles.ha(2),...
    'xlim',[0.5,K+0.5],...
    'xtick',[1:K],...
    'ylim',[0.5,n+0.5],...
    'ytick',[1:n],...
    'ydir','reverse',...
    'clim',[0 1])
set(handles.hc,'visible','on')

% display model frequencies
cla(handles.ha(3))
[haf,hf,hp] = plotUncertainTimeSeries(out.Ef,diag(out.Vf),[],handles.ha(3));
plot(handles.ha(3),[0.5,K+0.5],[1,1]/K,'r')
xlabel(handles.ha(3),'models')
set(handles.ha(3),...
    'xtick',1:K,...
    'xlim',[0.5,K+0.5],...
    'ylim',[0 1],...
    'ygrid','on')
title(handles.ha(3),'estimated model frequencies')

% display exceedance probabilities
cla(handles.ha(4))
bar(handles.ha(4),out.ep,'facecolor',0.8*[1 1 1])
plot(handles.ha(4),[0.5,K+0.5],[0.95,0.95],'r')
xlabel(handles.ha(4),'models')
set(handles.ha(4),...
    'xtick',1:K,...
    'xlim',[0.5,K+0.5],...
    'ylim',[0 1],...
    'ygrid','on')
title(handles.ha(4),'approximated exceedance probabilities')

% display VB algorithm convergence
cla(handles.ha(5))
plot(handles.ha(5),out.F,'k')
plot(handles.ha(5),out.F,'k.')
[haf,hf,hp] = plotUncertainTimeSeries(out.F0.*[1,1],[3,3].^2,[0.5,length(out.F)+0.5],handles.ha(5));
set(hp,'color',[1 0 0])
set(hf,'facecolor',[1 0 0])
text(length(out.F)/2,out.F0-3/2,'log p(y|H0)','color',[1 0 0],'parent',handles.ha(5));
xlabel(handles.ha(5),'VB iterations')
ylabel(handles.ha(5),'VB free energy')
set(handles.ha(5),...
    'xtick',1:length(out.F),...
    'xticklabel',[],...
    'xlim',[0.5,length(out.F)+0.5],...
    'ygrid','on')
title(handles.ha(5),'VB algorithm convergence')

if ~isempty(out.options.families)
    nf = size(out.options.C,2);
    cla(handles.ha(6))
    [haf,hf,hp] = plotUncertainTimeSeries(out.families.Ef,diag(out.families.Vf),[],handles.ha(6));
    plot(handles.ha(6),[0.5,nf+0.5],[1,1]/nf,'r')
    xlabel(handles.ha(6),'families')
    set(handles.ha(6),...
        'xtick',1:nf,...
        'xlim',[0.5,nf+0.5],...
        'ylim',[0 1],...
        'ygrid','on')
    title(handles.ha(6),'estimated family frequencies')
end

% display free energy update
if ~isfield(out,'date')
    dF = diff(out.F);
    set(handles.ho,'string',...
        ['Model evidence: log p(y|m) >= ',num2str(out.F(end),'%1.3e'),...
        ' , dF= ',num2str(dF(end),'%4.3e')])
else
    if floor(out.dt./60) == 0
        timeString = [num2str(floor(out.dt)),' sec'];
    else
        timeString = [num2str(floor(out.dt./60)),' min'];
    end
    str = ['VB inversion complete (took ~',timeString,').'];
    set(handles.ho,'string',[str,' Model evidence: log p(y|m) >= ',num2str(out.F(end),'%1.3e'),'.'])
end

try;getSubplots;end

drawnow


