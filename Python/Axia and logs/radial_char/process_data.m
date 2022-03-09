function [max_lin_force, gradients]= process_data(dirname, save, all_plots, range, calib_point)
%{
% mass execution
i = 0;
folders = dir;
for folder = 1:length(folders)
    if contains(folders(folder).name, "=")
        i = i + 1
        disp(folders(folder).name)
        if i >= 1 % for resuming after a failed batch
            if i == 10 % for specially treating one set of data
                close all; [force_data(i,1:13) gradients(i,1:13)] = process_data(folders(folder).name, 1, 1, [1:10], 2000000);
            elseif i == 7 % for specially treating one set of data
                close all; [force_data(i,1:14) gradients(i,1:14)] = process_data(folders(folder).name, 1, 1, [1:11], 2000000);
            elseif i == 1 % for specially treating one set of data
                close all; [force_data(i,1:15) gradients(i,1:15)] = process_data(folders(folder).name, 1, 1, [1:10 12], 2000000);
            elseif i == 8 % for specially treating one set of data
                close all; [force_data(i,1:14) gradients(i,1:14)] = process_data(folders(folder).name, 1, 1, [1:11], 2000000);
            elseif i == 13 % for specially treating one set of data
                close all; [force_data(i,1:14) gradients(i,1:14)] = process_data(folders(folder).name, 1, 1, [1:6 8:11], 2000000);
            elseif i == 3 % for specially treating one set of data
                close all; [force_data(i,1:15) gradients(i,1:15)] = process_data(folders(folder).name, 1, 1, [1:9 11 12], 2000000);
            elseif i == 14 % for specially treating one set of data
                close all; [force_data(14,1:13) gradients(14,1:13)] = process_data(folders(folder).name, 1, 1, [4:10], 1000000);
            else
                close all; [force_data(i,1:15) gradients(i,1:15)] = process_data(folders(folder).name, 1, 1, [1:12], 2000000);
            end
        end
    end
end
%}

%{
%plot method
fig3 = figure('units','centimeters','position',[0,0,12,8]);
set(fig3,'PaperSize',[12 8]);
yplot=gradients(:,2);
yplot(yplot==0)=nan;
scatter(85-(1:length(gradients(:,2))).*5,yplot, 'filled')
hold on;
for i = 1:14
    yplot = gradients(i,4:15)/1000000;
    yplot(yplot==0)=nan;
    scatter(ones(1,12)*(85-5*i),yplot, '.', 'k')
end
xlabel("Distance From Centre (mm)")
ylabel("F/motor")
title("Gradient of Linear Region")
xlim([0 100])
ylim([0 0.001])
print(fig3,'Gradient_of_Linear_Region_at_Radius.pdf','-dpdf') 

fig4 = figure('units','centimeters','position',[0,0,12,8]);
set(fig4,'PaperSize',[12 8]);
yplot=force_data(:,2);
yplot(yplot==0)=nan;
scatter(85-(1:length(force_data(:,2))).*5,yplot, 'filled')
hold on;
for i = 1:14
    yplot=force_data(i,4:15);
    yplot(yplot==0)=nan;
    scatter(ones(1,12)*(85-5*i),yplot, '.', 'k')
end
xlim([0 100])
ylim([0 10])
xlabel("Distance From Centre (mm)")
ylabel("Maximum Force (N)")
title("Force Available At Varying Radius")
print(fig4,'Force_Available_at_Inc_Radius.pdf','-dpdf') 
%}
    files = dir(dirname);
    index = 1;
    data = zeros(12, 5000, 9);
    comp_data = zeros(12, 5000, 9);
    outdata = zeros(12, 5000, 9);
    indata = zeros(12, 5000, 9);
    for file = 1:length(files)
        if contains(files(file).name, "zipped")
            mat = readmatrix(dirname+"/"+files(file).name);
            sz_mat = size(mat);
            data(index,1:sz_mat(1),1:sz_mat(2)) = mat;
            index = index + 1;
        end
    end
    
    for i = range
        % seperate data into inpass and outpass
        %disp(i)
        turning = find(data(i,:,1)==max(data(i,:,1)));
        data_indout = squeeze(data(i,1:turning,:));
        data_indin = squeeze(data(i,turning:end,:));
        % offset if belt skips by multiple of 500
        % find the index where they are both at 1N
        [~,matchin]=min(abs(data_indin(:,2)-calib_point));
        [~,matchout]=min(abs(data_indout(:,2)-calib_point));
        while data_indout(matchout,1) - data_indin(matchin,1) > 500
            disp("skip in run " + num2str(i));
            data_indin(:,1) = data_indin(:,1) + 500;
        end
        while data_indout(matchout,1) - data_indin(matchin,1) < - 500
            disp("skip in run " + num2str(i));
            data_indin(:,1) = data_indin(:,1) - 500;
        end
        data(i,:,:) = [data_indout(:,:); data_indin(2:end,:)];
    end

    %find where the encoder measures a whole turn for each run to align them
    locs = zeros(12);
    locvals = zeros(12);
    for i = range
        %disp(i)
        % this is for the data recorded before using the encoder trick to
        % synch the data:
        if isempty(find(data(i,:,9)==1, 1, 'first')) && isempty(find(data(i,:,9)==-1, 1, 'first'))
            
        elseif isempty(find(data(i,:,9)==1, 1, 'first'))
            locs(i) = find(data(i,:,9)==-1, 1, 'first');
            locvals(i) = data(i,locs(i),1);
        else
            locs(i) = find(data(i,:,9)==1, 1, 'first');
            locvals(i) = data(i,locs(i),1);
        end
    end
    % calibrate the encoder starting position using the encoder data
    final_locval = max(locvals);
    for i = range
        % this is for the data recorded before using the encoder trick to
        % synch the data:
        if locs(i) ~= 0
            data(i,:,1) = data(i,:,1) - (locvals(i) - final_locval(1));
        end
    end
    % attempt to find encoder mismatch due to belt slippage
    % pulley has 20 teeth
    % encoder has 10000 ticks per whole turn -> 500 difference on encoder per
    % slip. try multiples of 500 until match is good (choice of zeroing at 5000
    % encoder tics is quite arbitrary
    for i = range
        if locs(i) ~= 0
            % find where the force becomes a little significant
            contact = find(data(i,:,2)>50000,1,'first')-1;
            zero_at = 0; %can set this to account for non-contact time
            while((data(i,contact,1) - zero_at) < -250)
                data(i,:,1) = data(i,:,1) + 500;
            end
            while((data(i,contact,1) - zero_at) > 250)
                data(i,:,1) = data(i,:,1) - 500;
            end
        else
            % find where the force becomes a little significant
            contact = find(data(i,:,2)>50000,1,'first')-1;
            zero_at = 0; %can set this to account for non-contact time
            while((data(i,contact,1) - zero_at) < 0)
                data(i,:,1) = data(i,:,1) + 1;
            end
            while((data(i,contact,1) - zero_at) > 0)
                data(i,:,1) = data(i,:,1) - 1;
            end
        end
    end
    
    for i = range
        comp_data(i,:,:) = squeeze(data(i,:,:));
    end
    % add similar encoder positions to the same bin
    master = [squeeze(comp_data (1,:,:));
            squeeze(comp_data (2,:,:));
            squeeze(comp_data (3,:,:));
            squeeze(comp_data (4,:,:));
            squeeze(comp_data (5,:,:));
            squeeze(comp_data (6,:,:));
            squeeze(comp_data (7,:,:));
            squeeze(comp_data (8,:,:));
            squeeze(comp_data (9,:,:));
            squeeze(comp_data (10,:,:));
            squeeze(comp_data (11,:,:));
            squeeze(comp_data (12,:,:))];
    %binsize = 10000/360
    min_m = min(master(:,1));
    %max_m = max(master(:,1));
    %*bin_res/10000 gives angle in degrees of 360/bin_res
    bin_res = 30;
    binned_master = zeros([length(master),100]);
    %values each row of the binned matrix corresponds to
    binned_index = zeros([length(master), 1]);
    for i = 1:length(master)
        binned_index(i) = i*10000/bin_res+min_m;
        %round((master(i,1)-min_m)/360)
        % find the next available slot to add the data (next  in the
        % relevant row)
        index = find(binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,:)==0,1,'first');
        binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,index) = master(i,2);
        %binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,1) = binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,1) + master(i,2);
        %binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,2) = binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,2)+1;
    end
    fig1 = figure;
    master_mean = mean(binned_master, 2);
    whole_binned_master = binned_master;
    means = zeros([length(binned_master), 1]);
    stds = zeros([length(binned_master), 1]);
    for i = 1:length(binned_master)
        means(i) = mean(nonzeros(binned_master(i,:)));
        stds(i) = std(nonzeros(binned_master(i,:)));
    end
    %plot(means);
    %plot(binned_master(:,1)./binned_master(:,2))
    %x is the bins
    %x = 1:length(means);
    x = binned_index(1:length(means));
    y = means./1000000;
    % to scatter all data:
    %plot((master(:,1)-min_m)*bin_res/10000,master(:,2),'.','color',[0.5,0.5,0.95])
    %hold on
    shadedErrorBar(x,y,stds./1000000);
    title("complete data binned and mean")
    ylabel("Force(N)")
    xlabel("Radius (mm)")
    if save
        saveas(fig1,dirname + "/" + "full_mean.pdf")
    end
    
    %extract linear region
    TF=ischange(y,'linear');
    brkpt=x(TF==1);
    linear_x= x(x>=brkpt(1) & x<=brkpt(2));
    linear_y= y(x>=brkpt(1) & x<=brkpt(2));
    figure
    plot(linear_x, linear_y)
    max_lin_force(1) = linear_y(end);
    P(1,1:2) = polyfit(linear_x,linear_y,1);

    % for out
    for i = range
        turning = find(data(i,:,1)==max(data(i,:,1)));
        outdata(i,1:turning,:) = squeeze(data(i,1:turning,:));
        indata(i,turning:end,:) = squeeze(data(i,turning:end,:));
    end
    master = [squeeze(outdata(1,:,:));
            squeeze(outdata(2,:,:));
            squeeze(outdata(3,:,:));
            squeeze(outdata(4,:,:));
            squeeze(outdata(5,:,:));
            squeeze(outdata(6,:,:));
            squeeze(outdata(7,:,:));
            squeeze(outdata(8,:,:));
            squeeze(outdata(9,:,:));
            squeeze(outdata(10,:,:));
            squeeze(outdata(11,:,:));
            squeeze(outdata(12,:,:))];
    %binsize = 10000/360
    min_m = min(master(:,1));
    %max_m = max(master(:,1));
    %bins = round((max_m - min_m)/bin_res);
    binned_master = zeros([length(master),100]);
    %values each row of the binned matrix corresponds to
    binned_index = zeros([length(master), 1]);
    for i = 1:length(master)
        binned_index(i) = i*10000/bin_res+min_m;
        %round((master(i,1)-min_m)/bin_res)
        index = find(binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,:)==0,1,'first');
        binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,index) = master(i,2);
        %binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,1) = binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,1) + master(i,2);
        %binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,2) = binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,2)+1;
    end
    fig2 = figure;
    hold on;
    out_master_mean = mean(binned_master, 2);
    out_binned_master = binned_master;
    out_means = zeros([length(binned_master),1]);
    out_stds = zeros([length(binned_master), 1]);
    for i = 1:length(binned_master)
        out_means(i) = mean(nonzeros(binned_master(i,:)));
        out_stds(i) = std(nonzeros(binned_master(i,:)));
    end
    %plot(1:length(out_means),out_means);
    %maximum_force(2) = max(out_means)/1000000;
    %x = 1:length(out_means);
    x_out = binned_index(1:length(out_means));
    y_out = out_means./1000000;
    shadedErrorBar(x_out,out_means./1000000,out_stds./1000000);
    %hold on
    %plot(x,out_means,'.','color',[0.5,0.5,0.95])
    %plot(binned_master(:,1)./binned_master(:,2))
    title("Contracting data binned and mean")
    ylabel("Force(N)")
    xlabel("Radius (mm)")
    if save
        saveas(fig2,dirname + "/" + "out_mean.pdf")
    end
    
    %extract linear region
    TF=ischange(y,'linear');
    brkpt=x(TF==1);
    linear_x_out= x_out(x_out>=brkpt(1) & x_out<=brkpt(2));
    linear_y_out= y_out(x_out>=brkpt(1) & x_out<=brkpt(2));
    figure
    plot(linear_x_out, linear_y_out)
    max_lin_force(2) = linear_y_out(end);
    P(2,1:2) = polyfit(linear_x_out,linear_y_out,1);

    fig3 = figure;
    hold on
    shadedErrorBar(x,out_means./1000000,out_stds./1000000);
    ylabel("Force(N)")
    xlabel("Radius (mm)")

    % for in
    master = [squeeze(indata(1,:,:));
            squeeze(indata(2,:,:));
            squeeze(indata(3,:,:));
            squeeze(indata(4,:,:));
            squeeze(indata(5,:,:));
            squeeze(indata(6,:,:));
            squeeze(indata(7,:,:));
            squeeze(indata(8,:,:));
            squeeze(indata(9,:,:));
            squeeze(indata(10,:,:));
            squeeze(indata(11,:,:));
            squeeze(indata(12,:,:))];
    %binsize = 10000/360
    min_m = min(master(:,1));
    %max_m = max(master(:,1));
    %bins = round((max_m - min_m)/bin_res);
    binned_master = zeros([length(master),100]);
    %values each row of the binned matrix corresponds to
    binned_index = zeros([length(master), 1]);
    for i = 1:length(master)
        binned_index(i) = i*10000/bin_res+min_m;
        %round((master(i,1)-min_m)/bin_res)
        index = find(binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,:)==0,1,'first');
        binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,index) = master(i,2);
        %binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,1) = binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,1) + master(i,2);
        %binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,2) = binned_master(round((master(i,1)-min_m)*bin_res/10000)+1,2)+1;
    end
    in_master_mean = mean(binned_master, 2);
    in_binned_master = binned_master;
    %calculate means
    in_means = zeros([length(binned_master), 1]);
    in_stds = zeros([length(binned_master), 1]);
    for i = 1:length(binned_master)
        in_means(i) = mean(nonzeros(binned_master(i,:)));
        in_stds(i) = std(nonzeros(binned_master(i,:)));
    end
    %plot(in_means);
    %shadedErrorBar(in_means , 1:length(in_means) , in_stds , '-r' , 0);
    x_in = binned_index(1:length(in_means));
    %x = 1:length(in_means);
    y_in = in_means./1000000;
    
    shadedErrorBar(x_in,in_means./1000000,in_stds./1000000);
    ylabel("Force(N)")
    xlabel("Radius (mm)")
    %plot(binned_master(:,1)./binned_master(:,2))
    title("hysteresis in and out pass")
    if save
        saveas(fig3,dirname + "/" + "hysteresis_mean.pdf")
    end
    
    %extract linear region
    TF=ischange(y,'linear');
    brkpt=x(TF==1);
    linear_x_in = x_in(x_in>=brkpt(1) & x_in<=brkpt(2));
    linear_y_in = y_in(x_in>=brkpt(1) & x_in<=brkpt(2));
    figure
    plot(linear_x_in, linear_y_in)
    max_lin_force(3) = linear_y_in(end)
    P(3,1:2) = polyfit(linear_x_in,linear_y_in,1)
    
    fig4 = figure;
    hold on
    shadedErrorBar(x,in_means./1000000,in_stds./1000000);
    ylabel("Force(N)")
    xlabel("Radius (mm)")
    title("Extending data binned and mean")
    if save
        saveas(fig4,dirname + "/" + "in_mean.pdf")
    end

    %{
    %sort by encoder position, and smooth to get combined values
    master = [squeeze(data(1,:,:));
            squeeze(data(2,:,:));
            squeeze(data(3,:,:));
            squeeze(data(4,:,:));
            squeeze(data(5,:,:));
            squeeze(data(6,:,:));
            squeeze(data(7,:,:));
            squeeze(data(8,:,:));
            squeeze(data(9,:,:));
            squeeze(data(10,:,:));
            squeeze(data(11,:,:));
            squeeze(data(12,:,:))];
    [~,idx] = sort(master(:,1)); % sort just the first column
    sortedmat = master(idx,:);   % sort the whole matrix using the sort indices

    figure;
    plot(sortedmat(:,1), sortedmat(:,2));
    %}

    fh = zeros(13);
    fh(13) = figure; hAxes = gca;
    P_all = 0*range;
    lin_force_all = 0*range;
    for i = range
        % seperate data into inpass and outpass
        %disp(i)
        turning = find(data(i,:,1)==max(data(i,:,1)));
        data_ind = squeeze(data(i,:,:));
        data_indout = squeeze(data(i,1:turning,:));
        data_indin = squeeze(data(i,turning:end,:));
        %{
        % offset if belt skips by multiple of 500
        % find the index where they are both at 1N
        [~,matchin]=min(abs(data_indin(:,2)-2000000));
        [~,matchout]=min(abs(data_indout(:,2)-2000000));
        in = data_indin(matchin,1)
        out = data_indout(matchout,1)
        while data_indout(matchout,1) - data_indin(matchin,1) > 500
            disp("skip in run " + num2str(i));
            data_indin(:,1) = data_indin(:,1) + 500;
        end
        while data_indout(matchout,1) - data_indin(matchin,1) < - 500
            disp("skip in run " + num2str(i));
            data_indin(:,1) = data_indin(:,1) - 500;
        end
        %}
        
        
        if all_plots
            fh(i) = figure;
            hold on
            plot(data_indout(:,1),data_indout(:,2))
            plot(data_indin(:,1),data_indin(:,2))
            ylabel("Force(N)")
            xlabel("Radius (mm)")
            xlim([0 25000])
            ylim([0 10000000])
        end
        
        % Get gradient for each data run
        x_single = data_indout(:,1);
        y_single = data_indout(:,2);
        brkpt=x(TF==1);
        linear_x_single = x_single(x_single>=brkpt(1) & x_single<=brkpt(2));
        linear_y_single = y_single(x_single>=brkpt(1) & x_single<=brkpt(2));
        figure
        plot(linear_x_single, linear_y_single)
        lin_force_all(i) = linear_y_single(end)/1000000;
        holder = polyfit(linear_x_single,linear_y_single,1);
        P_all(i) = holder(1);
        
        hold (hAxes, 'on');
        %plot(hAxes, [data_indout(:,1); data_indin(2:end,1)],data_ind(:,2)./1000000)
        plot(hAxes, data_ind(:,1),data_ind(:,2)./1000000)
        ylabel("Force(N)")
        xlabel("Radius (mm)")
    end
    if save
        saveas(hAxes,dirname + "/" + "all_data.pdf")
    end
    gradients = [transpose(P(:,1)) P_all]
    max_lin_force = [max_lin_force lin_force_all]
return