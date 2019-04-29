function [] = hcolor(handles)

% screenwid = get(0,'ScreenSize');
% screenwid = screenwid(3)/get(0,'ScreenPixelsPerInch');
% if screenwid > 17
%     fntsize = 10;
% elseif screenwid > 15
%     fntsize = 8;
% else
%     fntsize = 8;
% end


pnl_clr = [.95 .95 .95];
bttn_clr = [.75 1 .75];
edit_clr = [1 1 1];
dflt = [.95 .95 .95];

handlenms = fieldnames(handles);

for i = 1:length(handlenms)
    h = getfield(handles,handlenms{i});
    if ishandle(h) & isfield(get(h),'BackgroundColor')
        
        clr = get(h,'BackgroundColor');
        
        switch get(h,'Type')
            case 'uipanel'
                clr = pnl_clr;
                
            case 'uicontrol'
                switch get(h,'Style')
                    case 'pushbutton'
                        clr = bttn_clr;
                    case 'edit'
                        clr = edit_clr;
                    otherwise
                        clr = dflt;
                end
                
        end

        set(h,'BackgroundColor',clr);
    end
    
%     if ishandle(h) & isfield(get(h),'FontSize')
%         set(h,'FontSize',fntsize);
%     end
end