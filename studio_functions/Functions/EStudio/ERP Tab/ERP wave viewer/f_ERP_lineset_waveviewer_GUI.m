%%This function is to plot the panel for "Viewer properties".

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022


function varargout = f_ERP_lineset_waveviewer_GUI(varargin)

global viewer_ERPDAT;
addlistener(viewer_ERPDAT,'legend_change',@legend_change);
addlistener(viewer_ERPDAT,'page_xyaxis_change',@page_xyaxis_change);
addlistener(viewer_ERPDAT,'count_loadproper_change',@count_loadproper_change);
addlistener(viewer_ERPDAT,'v_currentERP_change',@v_currentERP_change);
% addlistener(viewer_ERPDAT,'Process_messg_change',@Process_messg_change);

gui_erplinset_waveviewer = struct();

%-----------------------------Name the title----------------------------------------------
% global box_erplineset_viewer_property;

[version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    box_erplineset_viewer_property = uiextras.BoxPanel('Parent', fig, 'Title', 'Lines & Legends', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize', 12); % Create boxpanel
elseif nargin == 1
    box_erplineset_viewer_property = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Lines & Legends', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w');%[0.7765,0.7294,0.8627]
else
    box_erplineset_viewer_property = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Lines & Legends', 'Padding', 5, ...
        'FontSize', varargin{2},'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w');
end
%-----------------------------Draw the panel-------------------------------------
drawui_lineset_property();
varargout{1} = box_erplineset_viewer_property;

    function drawui_lineset_property()
        [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewer = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        %%--------------------channel and bin setting----------------------
        gui_erplinset_waveviewer.DataSelBox = uiextras.VBox('Parent', box_erplineset_viewer_property,'BackgroundColor',ColorBviewer_def);
        %%-----------------Setting for Auto-------
        linAutoValue = 1;
        if linAutoValue ==1
            DataEnable = 'off';
        else
            DataEnable = 'on';
        end
        gui_erplinset_waveviewer.parameters_title = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_erplinset_waveviewer.parameters_title,'String','Lines:',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left','FontWeight','bold'); %
        
        gui_erplinset_waveviewer.linesauto = uicontrol('Style','radiobutton','Parent', gui_erplinset_waveviewer.parameters_title,'String','Auto',...
            'callback',@lines_auto,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',linAutoValue); %
        gui_erplinset_waveviewer.linescustom = uicontrol('Style','radiobutton','Parent', gui_erplinset_waveviewer.parameters_title,'String','Custom',...
            'callback',@lines_custom,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',~linAutoValue); %
        
        set(gui_erplinset_waveviewer.parameters_title,'Sizes',[40 80 80]);
        
        %%-----------Setting for line table-----------------------------
        gui_erplinset_waveviewer.line_customtable_title = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        try
            plot_org = ERPwaviewer.plot_org;
            if plot_org.Grid ==1
                GridNum = numel(ERPwaviewer.chan);
            elseif plot_org.Grid ==2
                GridNum = numel(ERPwaviewer.bin);
            elseif plot_org.Grid ==3
                GridNum = numel(ERPwaviewer.SelectERPIdx);
            else
                GridNum = numel(ERPwaviewer.chan);
            end
        catch
            GridNum = [];
        end
        [lineNameStr,linecolors,linetypes,linewidths,linecolors_str,linetypes_str,linewidths_str,linecolorsrgb] = f_get_lineset_ERPviewer();
        if linAutoValue
            lineset_str  =table(lineNameStr,linecolors,linetypes,linewidths);
            lineset_str = table2cell(lineset_str);
        else
            lineset_str  =table(lineNameStr,linecolorsrgb,linetypes,linewidths);
            lineset_str = table2cell(lineset_str);
        end
        gui_erplinset_waveviewer.line_customtable = uitable(gui_erplinset_waveviewer.line_customtable_title);
        gui_erplinset_waveviewer.line_customtable.ColumnFormat = {'char', 'char',...
            {'solid','dash','dot','dashdot','plus','circle','asterisk'},...
            {'0.25','0.5','1','1.5','2','2.5','3','3.5','4','4.5','5','5.5','6','6.5','7','7.5','8','8.5','9','9.5','10','10.5'}};
        gui_erplinset_waveviewer.line_customtable.Data = lineset_str;
        gui_erplinset_waveviewer.line_customtable.ColumnEditable = [false, true,true,true];
        gui_erplinset_waveviewer.line_customtable.FontSize = 12;
        gui_erplinset_waveviewer.line_customtable.ColumnName = {'<html><font size=3 >#','<html><font size= 3>Color','<html><font size=3 >Style', '<html><font size=3 >Width'};
        gui_erplinset_waveviewer.line_customtable.Enable = DataEnable;
        gui_erplinset_waveviewer.line_customtable.BackgroundColor = [1 1 1;1 1 1];
        gui_erplinset_waveviewer.line_customtable.RowName = [];
        gui_erplinset_waveviewer.line_customtable.ColumnWidth = {25 80 65 50};
        gui_erplinset_waveviewer.line_customtable.CellEditCallback  = @line_customtable;
        %%setting for uitable: https://undocumentedmatlab.com/artiALLERPwaviewercles/multi-line-uitable-column-headers
        if gui_erplinset_waveviewer.linesauto.Value ==1
            gui_erplinset_waveviewer.line_customtable.Enable = 'off';
        else
            gui_erplinset_waveviewer.line_customtable.Enable = 'on';
        end
        ERPwaviewer.Lines.auto =gui_erplinset_waveviewer.linesauto.Value;
        ERPwaviewer.Lines.data =gui_erplinset_waveviewer.line_customtable.Data;
        
        %%------------------setting for legend---------------------------------------
        legendAuto = 1;
        gui_erplinset_waveviewer.legend_title = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_erplinset_waveviewer.legend_title,'String','Legend:',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left','FontWeight','bold'); %
        gui_erplinset_waveviewer.legendauto = uicontrol('Style','radiobutton','Parent', gui_erplinset_waveviewer.legend_title,'String','Auto',...
            'callback',@legend_auto,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',legendAuto); %
        gui_erplinset_waveviewer.legendcustom = uicontrol('Style','radiobutton','Parent', gui_erplinset_waveviewer.legend_title,'String','Custom',...
            'callback',@legend_custom,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',~legendAuto); %
        set( gui_erplinset_waveviewer.legend_title,'Sizes',[50 80 80]);
        
        
        %%-----------Setting for legend table -----------------------------
        gui_erplinset_waveviewer.legend_customtable_title = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        for ii = 1:100
            LegendName{ii,1} = '';
            LegendNamenum(ii,1) =ii;
        end
        ALLERPIN = ERPwaviewer.ALLERP;
        ERPsetArray = ERPwaviewer.SelectERPIdx;
        if max(ERPsetArray(:))> length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        try
            plot_org = ERPwaviewer.plot_org;
            ERPIN = ERPwaviewer.ERP;
            if plot_org.Overlay ==1
                ChanArray = ERPwaviewer.chan;
                for Numofchan = 1:numel(ChanArray)
                    LegendName{Numofchan,1} = char(chanStr(ChanArray(Numofchan)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            elseif plot_org.Overlay ==2
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            elseif plot_org.Overlay ==3
                ALLERP = ERPwaviewer.ALLERP;
                ERPsetArray = ERPwaviewer.SelectERPIdx;
                for Numoferpset = 1:numel(ERPsetArray)
                    LegendName{Numoferpset,1} = char(ALLERP(Numoferpset).erpname);
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            else
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            end
        catch
            legendset_str = table(LegendNamenum,LegendName);
            legendset_str = table2cell(legendset_str);
        end
        gui_erplinset_waveviewer.legend_customtable = uitable(gui_erplinset_waveviewer.legend_customtable_title);
        gui_erplinset_waveviewer.legend_customtable.ColumnEditable = [false,true];
        
        gui_erplinset_waveviewer.legend_customtable.Data = legendset_str;
        gui_erplinset_waveviewer.legend_customtable.FontSize = 12;
        gui_erplinset_waveviewer.legend_customtable.ColumnName = {'<html><font size=3 >#','<html><font size=3 >Name'};
        gui_erplinset_waveviewer.legend_customtable.CellEditCallback  = @legend_customtable;
        gui_erplinset_waveviewer.legend_customtable.BackgroundColor = [1 1 1;1 1 1];
        gui_erplinset_waveviewer.legend_customtable.RowName = [];
        gui_erplinset_waveviewer.legend_customtable.ColumnWidth = {20 200};
        %         gui_erplinset_waveviewer.legend_customtable.CellEditCallback  = {@legend_customtable,ERPwaviewer_num};
        %%setting for uitable: https://undocumentedmatlab.com/artiALLERPwaviewercles/multi-line-uitable-column-headers
        if gui_erplinset_waveviewer.legendauto.Value ==1
            gui_erplinset_waveviewer.legend_customtable.Enable = 'off';
            fontEnable = 'off';
        else
            gui_erplinset_waveviewer.legend_customtable.Enable = 'on';
            fontEnable = 'on';
        end
        ERPwaviewer.Legend.auto = gui_erplinset_waveviewer.legendauto.Value;
        ERPwaviewer.Legend.data = gui_erplinset_waveviewer.legend_customtable.Data;
        
        
        %
        %%--------------------legend font and font size---------------------------
        gui_erplinset_waveviewer.labelfont_title = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        fontDef = 1;
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        labelfontsizeinum = str2num(char(fontsize));
        LabelfontsizeValue = 5;
        uicontrol('Style','text','Parent', gui_erplinset_waveviewer.labelfont_title ,'String','Font',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def); %
        fonttype = {'Courier','Geneva','Helvetica','Monaco','Times'};
        gui_erplinset_waveviewer.font_custom_type = uicontrol('Style','popupmenu','Parent', gui_erplinset_waveviewer.labelfont_title ,'String',fonttype,...
            'callback',@legendfont,'FontSize',12,'BackgroundColor',[1 1 1],'Value',fontDef,'Enable',fontEnable); %
        uicontrol('Style','text','Parent', gui_erplinset_waveviewer.labelfont_title ,'String','Size',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def); %
        gui_erplinset_waveviewer.font_custom_size = uicontrol('Style','popupmenu','Parent', gui_erplinset_waveviewer.labelfont_title ,'String',fontsize,...
            'callback',@legendfontsize,'FontSize',12,'BackgroundColor',[1 1 1],'Value',LabelfontsizeValue,'Enable',fontEnable); %
        set(gui_erplinset_waveviewer.labelfont_title,'Sizes',[30 110 30 70]);
        ERPwaviewer.Legend.font = gui_erplinset_waveviewer.font_custom_type.Value;
        ERPwaviewer.Legend.fontsize = labelfontsizeinum(gui_erplinset_waveviewer.font_custom_size.Value);
        
        
        %%----------------------------Legend textcolor---------------------
        legendtextcolorAuto =1;
        gui_erplinset_waveviewer.legend_textitle = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_erplinset_waveviewer.legend_textitle,'String','Text color',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        gui_erplinset_waveviewer.legendtextauto = uicontrol('Style','radiobutton','Parent', gui_erplinset_waveviewer.legend_textitle,'String','Auto',...
            'callback',@legendtextauto,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',legendtextcolorAuto,'Enable',fontEnable); %
        gui_erplinset_waveviewer.legendtextcustom = uicontrol('Style','radiobutton','Parent',gui_erplinset_waveviewer.legend_textitle,'String','Same as lines',...
            'callback',@legendtextcustom,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',~legendtextcolorAuto,'Enable',fontEnable,'HorizontalAlignment','left'); %
        set(gui_erplinset_waveviewer.legend_textitle,'Sizes',[70 60 150]);
        ERPwaviewer.Legend.textcolor = gui_erplinset_waveviewer.legendtextauto.Value;
        
        %%------------------------Legend columns---------------------------
        legendcolumns =1;
        gui_erplinset_waveviewer.legend_columnstitle = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_erplinset_waveviewer.legend_columnstitle,'String','Columns',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %
        for Numoflegend = 1:100
            columnStr{Numoflegend} = num2str(Numoflegend);
        end
        gui_erplinset_waveviewer.legendcolumns = uicontrol('Style','popupmenu','Parent', gui_erplinset_waveviewer.legend_columnstitle,'String',columnStr,...
            'callback',@legendcolumns,'FontSize',12,'BackgroundColor',[1 1 1],'Value',legendcolumns,'Enable',fontEnable); %
        uiextras.Empty('Parent', gui_erplinset_waveviewer.legend_columnstitle );
        set(gui_erplinset_waveviewer.legend_columnstitle,'Sizes',[60 100 70]);
        ERPwaviewer.Legend.columns = gui_erplinset_waveviewer.legendcolumns.Value;
        
        
        %%-------------------------help and apply--------------------------
        gui_erplinset_waveviewer.help_apply_title = uiextras.HBox('Parent', gui_erplinset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',gui_erplinset_waveviewer.help_apply_title );
        uicontrol('Style','pushbutton','Parent', gui_erplinset_waveviewer.help_apply_title  ,'String','?',...
            'callback',@linelegend_help,'FontSize',16,'BackgroundColor',[1 1 1],'FontWeight','bold'); %,'HorizontalAlignment','left'
        uiextras.Empty('Parent',gui_erplinset_waveviewer.help_apply_title  );
        gui_erplinset_waveviewer.apply = uicontrol('Style','pushbutton','Parent',gui_erplinset_waveviewer.help_apply_title  ,'String','Apply',...
            'callback',@LineLegend_apply,'FontSize',12,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        uiextras.Empty('Parent',gui_erplinset_waveviewer.help_apply_title  );
        set(gui_erplinset_waveviewer.help_apply_title ,'Sizes',[40 70 20 70 20]);
        
        set(gui_erplinset_waveviewer.DataSelBox ,'Sizes',[20 200 20 180 25 25 25 25]);
        ALLERPwaviewer=ERPwaviewer;
        assignin('base','ALLERPwaviewer',ALLERPwaviewer);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-------------------------Setting for load--------------------------------
    function lines_auto(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            linesAutovalue =  ERPwaviewerIN.Lines.auto;
            gui_erplinset_waveviewer.linesauto.Value =linesAutovalue;
            gui_erplinset_waveviewer.linescustom.Value = ~linesAutovalue;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902]; %%mark the changes
        
        gui_erplinset_waveviewer.linesauto.Value =1;
        gui_erplinset_waveviewer.linescustom.Value = 0;
        gui_erplinset_waveviewer.line_customtable.Enable = 'off';
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewer = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        try
            plot_org = ERPwaviewer.plot_org;
            if plot_org.Grid ==1
                GridNum = numel(ERPwaviewer.chan);
            elseif plot_org.Grid ==2
                GridNum = numel(ERPwaviewer.bin);
            elseif plot_org.Grid ==3
                GridNum = numel(ERPwaviewer.SelectERPIdx);
                
            else
                GridNum = numel(ERPwaviewer.chan);
            end
        catch
            GridNum = [];
        end
        [lineNameStr,linecolors,linetypes,linewidths,linecolors_str,linetypes_str,linewidths_str,linecolorsrgb] = f_get_lineset_ERPviewer();
        lineset_str  =table(lineNameStr,linecolors,linetypes,linewidths);
        lineset_str = table2cell(lineset_str);
        gui_erplinset_waveviewer.line_customtable.ColumnFormat = {'char', 'char',...
            {'solid','dash','dot','dashdot','plus','circle','asterisk'},...
            {'0.25','0.5','1','1.5','2','2.5','3','3.5','4','4.5','5','5.5','6','6.5','7','7.5','8','8.5','9','9.5','10','10.5'}};
        gui_erplinset_waveviewer.line_customtable.Data = lineset_str;
    end

%%-------------------------Setting for Save--------------------------------
    function lines_custom(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            linesAutovalue =  ERPwaviewerIN.Lines.auto;
            gui_erplinset_waveviewer.linesauto.Value =linesAutovalue;
            gui_erplinset_waveviewer.linescustom.Value = ~linesAutovalue;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902]; %%mark the changes
        
        
        gui_erplinset_waveviewer.linesauto.Value =0;
        gui_erplinset_waveviewer.linescustom.Value = 1;
        gui_erplinset_waveviewer.line_customtable.Enable = 'on';
        [lineNameStr,linecolors,linetypes,linewidths,linecolors_str,linetypes_str,linewidths_str,linecolorsrgb] = f_get_lineset_ERPviewer();
        lineset_str  =table(lineNameStr,linecolorsrgb,linetypes,linewidths);
        lineset_str = table2cell(lineset_str);
        gui_erplinset_waveviewer.line_customtable.ColumnFormat = {'char', 'char',...
            {'solid','dash','dot','dashdot','plus','circle','asterisk'},...
            {'0.25','0.5','1','1.5','2','2.5','3','3.5','4','4.5','5','5.5','6','6.5','7','7.5','8','8.5','9','9.5','10','10.5'}};
        for ii = 1:length(linecolorsrgb)
            gui_erplinset_waveviewer.line_customtable.Data{ii,2} = linecolorsrgb{ii};
        end
    end

%%-------------------------Setting for Save as--------------------------------
    function line_customtable(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            linesData=  ERPwaviewerIN.Lines.data;
            gui_erplinset_waveviewer.line_customtable.Data = linesData;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902]; %%mark the changes
        
    end


%%--------------------legend auto-----------------------------------
    function legend_auto(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            LegendAuto=  ERPwaviewerIN.Legend.auto;
            gui_erplinset_waveviewer.legendauto.Value = LegendAuto;
            gui_erplinset_waveviewer.legendcustom.Value = ~LegendAuto;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902]; %%mark the changes
        
        
        gui_erplinset_waveviewer.legendauto.Value = 1;
        gui_erplinset_waveviewer.legendcustom.Value = 0;
        gui_erplinset_waveviewer.legend_customtable.Enable = 'off';
        
        gui_erplinset_waveviewer.font_custom_type.Enable = 'off'; %
        gui_erplinset_waveviewer.font_custom_size.Enable = 'off';
        gui_erplinset_waveviewer.legendtextauto.Enable = 'off';
        gui_erplinset_waveviewer.legendtextcustom.Enable = 'off';
        gui_erplinset_waveviewer.legendtextauto.Value = 1;
        gui_erplinset_waveviewer.legendtextcustom.Value = 0;
        gui_erplinset_waveviewer.legendcolumns.Value =1;
        gui_erplinset_waveviewer.legendcolumns.Enable = 'off';
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewer = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for ii = 1:100
            LegendName{ii,1} = '';
            LegendNamenum(ii,1) =ii;
        end
        try
            plot_org = ERPwaviewer.plot_org;
            ERPIN = ERPwaviewer.ERP;
            if plot_org.Overlay ==1
                LegendName = [];
                ChanArray = ERPwaviewer.chan;
                
                for Numofchan = 1:numel(ChanArray)
                    LegendName{Numofchan,1} = ERPIN.chanlocs(ChanArray(Numofchan)).labels;
                end
                for ii = length(LegendName)+1:100
                    LegendName{ii,1} = '';
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            elseif plot_org.Overlay ==2
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(ERPIN.bindescr{binArray(Numofbin)});
                end
                for ii = length(LegendName)+1:100
                    LegendName{ii,1} = '';
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            elseif plot_org.Overlay ==3
                ALLERP = ERPwaviewer.ALLERP;
                ERPsetArray = ERPwaviewer.SelectERPIdx;
                for Numoferpset = 1:numel(ERPsetArray)
                    LegendName{Numoferpset,1} = char(ALLERP(ERPsetArray(Numoferpset)).erpname);
                end
                for ii = length(LegendName)+1:100
                    LegendName{ii,1} = '';
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            else
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(ERPIN.bindescr{binArray(Numofbin)});
                end
                for ii = length(LegendName)+1:100
                    LegendName{ii,1} = '';
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            end
        catch
            legendset_str = table(LegendNamenum,LegendName);
            legendset_str = table2cell(legendset_str);
        end
        gui_erplinset_waveviewer.legend_customtable.ColumnEditable = [false,true];
        gui_erplinset_waveviewer.legend_customtable.Data = legendset_str;
        gui_erplinset_waveviewer.font_custom_size.Value = 5;
        gui_erplinset_waveviewer.font_custom_type.Value =1;
    end

%%-------------------legend custom-----------------------------------------
    function legend_custom(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            LegendAuto=  ERPwaviewerIN.Legend.auto;
            gui_erplinset_waveviewer.legendauto.Value = LegendAuto;
            gui_erplinset_waveviewer.legendcustom.Value = ~LegendAuto;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902]; %%mark the changes
        
        gui_erplinset_waveviewer.legendauto.Value = 0;
        gui_erplinset_waveviewer.legendcustom.Value = 1;
        gui_erplinset_waveviewer.legend_customtable.Enable = 'on';
        gui_erplinset_waveviewer.font_custom_type.Enable = 'on'; %
        gui_erplinset_waveviewer.font_custom_size.Enable = 'on';
        gui_erplinset_waveviewer.legendtextauto.Enable = 'on';
        gui_erplinset_waveviewer.legendtextcustom.Enable = 'on';
        gui_erplinset_waveviewer.legendcolumns.Enable = 'on';
    end

%%---------------------------legend table----------------------------------
    function legend_customtable(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            legendData=  ERPwaviewerIN.Legend.data;
            gui_erplinset_waveviewer.legend_customtable.Data = legendData;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902]; %%mark the changes
    end

%%----------------------font of legend text--------------------------------
    function legendfont(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            legendfont=  ERPwaviewerIN.Legend.font;
            gui_erplinset_waveviewer.font_custom_type.Value = legendfont;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902]; %%mark the changes
    end

%%----------------------fontsize of legend text----------------------------
    function legendfontsize(Source,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            legendfontsize=  ERPwaviewerIN.Legend.fontsize;
            fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
                '40','50','60','70','80','90','100'};
            gui_erplinset_waveviewer.font_custom_size.String = fontsize;
            fontsize = str2num(char(fontsize));
            [xsize,y] = find(fontsize ==legendfontsize);
            gui_erplinset_waveviewer.font_custom_size.Value = xsize;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902]; %%mark the changes
    end


%%----------------------------textcolor auto-------------------------------
    function legendtextauto(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            legendtextcolor=  ERPwaviewerIN.Legend.textcolor;
            gui_erplinset_waveviewer.legendtextauto.Value =legendtextcolor; %
            gui_erplinset_waveviewer.legendtextcustom.Value =~legendtextcolor;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902]; %%mark the changes
        
        gui_erplinset_waveviewer.legendtextauto.Value =1; %
        gui_erplinset_waveviewer.legendtextcustom.Value =0;
    end


%%----------------------------textcolor auto-------------------------------
    function legendtextcustom(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            legendtextcolor=  ERPwaviewerIN.Legend.textcolor;
            gui_erplinset_waveviewer.legendtextauto.Value =legendtextcolor; %
            gui_erplinset_waveviewer.legendtextcustom.Value =~legendtextcolor;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902]; %%mark the changes
        
        gui_erplinset_waveviewer.legendtextauto.Value =0; %
        gui_erplinset_waveviewer.legendtextcustom.Value =1;
    end

%%----------------------Columns of legend names----------------------------
    function legendcolumns(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();%%check if the changes were applied for the other panels
        if ~isempty(messgStr) && viewerpanelIndex~=6
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            ERPwaviewerIN = evalin('base','ALLERPwaviewer');
            legendcolumns=  ERPwaviewerIN.Legend.columns;
            gui_erplinset_waveviewer.legendcolumns.Value = legendcolumns;
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_linelegend',1);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [0.5569    0.9373    0.8902]; %%mark the changes
    end


%%-------------------------------Help--------------------------------------
    function linelegend_help(~,~)
        
        
    end


%%-----------------Apply the changed parameters----------------------------
    function LineLegend_apply(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=6
            erpworkingmemory('ERPViewer_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            viewer_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('MyViewer_linelegend',0);
        gui_erplinset_waveviewer.apply.BackgroundColor =  [1 1 1];
        
        MessageViewer= char(strcat('Lines & Legends > Apply'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewer_apply = ALLERPwaviewer;
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n Lines & Legends > Apply-f_ERP_lineset_waveviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        ERPwaviewer_apply.Lines.auto = gui_erplinset_waveviewer.linesauto.Value;
        ERPwaviewer_apply.Lines.data = gui_erplinset_waveviewer.line_customtable.Data;
        ERPwaviewer_apply.Legend.auto = gui_erplinset_waveviewer.legendauto.Value;
        ERPwaviewer_apply.Legend.data = gui_erplinset_waveviewer.legend_customtable.Data;
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        labelfontsizeinum = str2num(char(fontsize));
        ERPwaviewer_apply.Legend.font = gui_erplinset_waveviewer.font_custom_type.Value;
        ERPwaviewer_apply.Legend.fontsize = labelfontsizeinum(gui_erplinset_waveviewer.font_custom_size.Value);
        ERPwaviewer_apply.Legend.textcolor = gui_erplinset_waveviewer.legendtextauto.Value;
        ERPwaviewer_apply.Legend.columns = gui_erplinset_waveviewer.legendcolumns.Value;
        ALLERPwaviewer=ERPwaviewer_apply;
        assignin('base','ALLERPwaviewer',ALLERPwaviewer);
        f_redrawERP_viewer_test();
        viewer_ERPDAT.Process_messg =2;
    end


%%--------------change the legend name-------------------------------------
    function legend_change(~,~)
        if viewer_ERPDAT.count_legend==0
            return;
        end
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewer = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for ii = 1:100
            LegendName{ii,1} = '';
            LegendNamenum(ii,1) =ii;
        end
        ALLERPIN = ERPwaviewer.ALLERP;
        ERPsetArray = ERPwaviewer.SelectERPIdx;
        if max(ERPsetArray(:))> length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        try
            plot_org = ERPwaviewer.plot_org;
            ERPIN = ERPwaviewer.ERP;
            if plot_org.Overlay ==1
                ChanArray = ERPwaviewer.chan;
                for Numofchan = 1:numel(ChanArray)
                    LegendName{Numofchan,1} = char(chanStr(ChanArray(Numofchan)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            elseif plot_org.Overlay ==2
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            elseif plot_org.Overlay ==3
                ALLERP = ERPwaviewer.ALLERP;
                ERPsetArray = ERPwaviewer.SelectERPIdx;
                for Numoferpset = 1:numel(ERPsetArray)
                    LegendName{Numoferpset,1} = char(ALLERP(ERPsetArray(Numoferpset)).erpname);
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            else
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            end
        catch
            legendset_str = table(LegendNamenum,LegendName);
            legendset_str = table2cell(legendset_str);
        end
        if gui_erplinset_waveviewer.legendauto.Value ==1
            gui_erplinset_waveviewer.legend_customtable.Data = legendset_str;
            ERPwaviewer.Legend.auto = gui_erplinset_waveviewer.legendauto.Value;
            ERPwaviewer.Legend.data = gui_erplinset_waveviewer.legend_customtable.Data;
            ALLERPwaviewer=ERPwaviewer;
            assignin('base','ALLERPwaviewer',ALLERPwaviewer);
        end
    end

%%--------changed the legend names based on the current page---------------
    function page_xyaxis_change(~,~)
        if viewer_ERPDAT.page_xyaxis==0
            return;
        end
        try
            ERPwaviewer = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for ii = 1:100
            LegendName{ii,1} = '';
            LegendNamenum(ii,1) =ii;
        end
        ALLERPIN = ERPwaviewer.ALLERP;
        ERPsetArray = ERPwaviewer.SelectERPIdx;
        if max(ERPsetArray(:))> length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        try
            plot_org = ERPwaviewer.plot_org;
            ERPIN = ERPwaviewer.ERP;
            if plot_org.Overlay ==1
                ChanArray = ERPwaviewer.chan;
                for Numofchan = 1:numel(ChanArray)
                    LegendName{Numofchan,1} = char(chanStr(ChanArray(Numofchan)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            elseif plot_org.Overlay ==2
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            elseif plot_org.Overlay ==3
                ALLERP = ERPwaviewer.ALLERP;
                ERPsetArray = ERPwaviewer.SelectERPIdx;
                for Numoferpset = 1:numel(ERPsetArray)
                    LegendName{Numoferpset,1} = char(ALLERP(ERPsetArray(Numoferpset)).erpname);
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            else
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            end
        catch
            legendset_str = table(LegendNamenum,LegendName);
            legendset_str = table2cell(legendset_str);
        end
        if gui_erplinset_waveviewer.legendauto.Value ==1 && plot_org.Pages ==3
            gui_erplinset_waveviewer.legend_customtable.Data = legendset_str;
            ERPwaviewer.Legend.auto = gui_erplinset_waveviewer.legendauto.Value;
            ERPwaviewer.Legend.data = gui_erplinset_waveviewer.legend_customtable.Data;
            assignin('base','ALLERPwaviewer',ERPwaviewer);
        end
    end


%%-----change legend if ERPsets is changed from the first two panels-------
    function v_currentERP_change(~,~)
        if viewer_ERPDAT.Count_currentERP == 0
            return;
        end
        try
            ERPwaviewer = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        for ii = 1:100
            LegendName{ii,1} = '';
            LegendNamenum(ii,1) =ii;
        end
        ALLERPIN = ERPwaviewer.ALLERP;
        ERPsetArray = ERPwaviewer.SelectERPIdx;
        if max(ERPsetArray(:))> length(ALLERPIN)
            ERPsetArray =length(ALLERPIN);
        end
        [chanStr,binStr,diff_mark] = f_geterpschanbin(ALLERPIN,ERPsetArray);
        try
            plot_org = ERPwaviewer.plot_org;
            ERPIN = ERPwaviewer.ERP;
            if plot_org.Overlay ==1
                ChanArray = ERPwaviewer.chan;
                for Numofchan = 1:numel(ChanArray)
                    LegendName{Numofchan,1} = char(chanStr(ChanArray(Numofchan)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            elseif plot_org.Overlay ==2
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            elseif plot_org.Overlay ==3
                ALLERP = ERPwaviewer.ALLERP;
                ERPsetArray = ERPwaviewer.SelectERPIdx;
                for Numoferpset = 1:numel(ERPsetArray)
                    LegendName{Numoferpset,1} = char(ALLERP(ERPsetArray(Numoferpset)).erpname);
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            else
                binArray = ERPwaviewer.bin;
                for Numofbin = 1:numel(binArray)
                    LegendName{Numofbin,1} = char(binStr(binArray(Numofbin)));
                end
                legendset_str = table(LegendNamenum,LegendName);
                legendset_str = table2cell(legendset_str);
            end
        catch
            legendset_str = table(LegendNamenum,LegendName);
            legendset_str = table2cell(legendset_str);
        end
        if gui_erplinset_waveviewer.legendauto.Value ==1
            gui_erplinset_waveviewer.legend_customtable.Data = legendset_str;
            ERPwaviewer.Legend.auto = gui_erplinset_waveviewer.legendauto.Value;
            ERPwaviewer.Legend.data = gui_erplinset_waveviewer.legend_customtable.Data;
            assignin('base','ALLERPwaviewer',ERPwaviewer);
        end
    end



%%-------------change this panel based on the loaded parameters------------
    function count_loadproper_change(~,~)
        if viewer_ERPDAT.count_loadproper ==0
            return;
        end
        try
            ERPwaviewer = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        %%Line settings
        LineValue =  ERPwaviewer.Lines.auto;
        if numel(LineValue)~=1 || (LineValue~=1 && LineValue~=0)
            LineValue  = 1;
            ERPwaviewer.Lines.auto = 1;
        end
        if LineValue==1
            gui_erplinset_waveviewer.linesauto.Value =1;
            gui_erplinset_waveviewer.linescustom.Value = 0;
            gui_erplinset_waveviewer.line_customtable.Enable = 'off';
        else
            gui_erplinset_waveviewer.linesauto.Value =0;
            gui_erplinset_waveviewer.linescustom.Value = 1;
            gui_erplinset_waveviewer.line_customtable.Enable = 'on';
        end
        
        LineData = ERPwaviewer.Lines.data;
        gui_erplinset_waveviewer.line_customtable.Data = LineData;
        %
        %%Legend setting
        LegendAuto = ERPwaviewer.Legend.auto;
        if LegendAuto==1
            gui_erplinset_waveviewer.legendauto.Value = 1;
            gui_erplinset_waveviewer.legendcustom.Value = 0;
            gui_erplinset_waveviewer.legend_customtable.Enable = 'off';
            gui_erplinset_waveviewer.font_custom_type.Enable = 'off'; %
            gui_erplinset_waveviewer.font_custom_size.Enable = 'off';
            gui_erplinset_waveviewer.legendtextauto.Enable = 'off';
            gui_erplinset_waveviewer.legendtextcustom.Enable = 'off';
            gui_erplinset_waveviewer.legendtextauto.Value = 1;
            gui_erplinset_waveviewer.legendtextcustom.Value = 0;
            gui_erplinset_waveviewer.legendcolumns.Value =1;
            gui_erplinset_waveviewer.legendcolumns.Enable = 'off';
        else
            gui_erplinset_waveviewer.legendauto.Value = 0;
            gui_erplinset_waveviewer.legendcustom.Value = 1;
            gui_erplinset_waveviewer.legend_customtable.Enable = 'on';
            gui_erplinset_waveviewer.font_custom_type.Enable = 'on'; %
            gui_erplinset_waveviewer.font_custom_size.Enable = 'on';
            gui_erplinset_waveviewer.legendtextauto.Enable = 'on';
            gui_erplinset_waveviewer.legendtextcustom.Enable = 'on';
            gui_erplinset_waveviewer.legendcolumns.Enable = 'on';
        end
        LegendData = ERPwaviewer.Legend.data;
        gui_erplinset_waveviewer.legend_customtable.Data = LegendData;
        legendfont =ERPwaviewer.Legend.font;
        gui_erplinset_waveviewer.font_custom_type.Value = legendfont;
        legendfontsize = ERPwaviewer.Legend.fontsize;
        fontsize  = {'4','6','8','10','12','14','16','18','20','24','28','32','36',...
            '40','50','60','70','80','90','100'};
        gui_erplinset_waveviewer.font_custom_size.String = fontsize;
        fontsize = str2num(char(fontsize));
        [xsize,y] = find(fontsize ==legendfontsize);
        gui_erplinset_waveviewer.font_custom_size.Value = xsize;
        
        Legendtextcolor = ERPwaviewer.Legend.textcolor;
        if Legendtextcolor==1
            gui_erplinset_waveviewer.legendtextauto.Value =1; %
            gui_erplinset_waveviewer.legendtextcustom.Value =0;
        else
            gui_erplinset_waveviewer.legendtextauto.Value =0; %
            gui_erplinset_waveviewer.legendtextcustom.Value =1;
        end
        legendColumns = ERPwaviewer.Legend.columns;
        gui_erplinset_waveviewer.legendcolumns.Value = legendColumns;
        for Numoflegend = 1:100
            columnStr{Numoflegend} = num2str(Numoflegend);
        end
        gui_erplinset_waveviewer.legendcolumns.String = columnStr;
    end

end