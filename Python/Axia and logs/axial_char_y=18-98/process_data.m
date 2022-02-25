function processdata(dirname, save, all_plots);
    files = dir(dirname);
    index = 1;
    data = zeros(12, 5000, 9);
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

    %find where the encoder measures a whole turn for each run to align them
    locs = zeros(12);
    locvals = zeros(12);
    for i = [1, 2, 3, 5, 6, 7, 8, 9, 10 ,11, 12]
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
    for i = [1, 2, 3, 5, 6, 7, 8, 9, 10 ,11, 12]
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
    for i = [1, 2, 3, 5, 6, 7, 8, 9, 10 ,11, 12]
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

    % add similar encoder positions to the same bin
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
    %binsize = 10000/360
    min_m = min(master(:,1));
    %max_m = max(master(:,1));
    bin_res = 30;
    binned_master = zeros([length(master),100]);
    for i = 1:length(master)
        %round((master(i,1)-min_m)/360)
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
    x = 1:length(means);
    % to scatter all data:
    %plot((master(:,1)-min_m)*bin_res/10000,master(:,2),'.','color',[0.5,0.5,0.95])
    %hold on
    shadedErrorBar(x,means./1000000,stds./1000000);
    title("complete data binned and mean")
    ylabel("Force(N)")
    xlabel("Radius (mm)")
    if save
        saveas(fig1,dirname + "/" + "full_mean.pdf")
    end
    maximum_force = max(means)/1000000;

    % for out
    for i = [1, 2, 3, 5, 6, 7, 8, 9, 10 ,11, 12]
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
    for i = 1:length(master)
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
    maximum_force(2) = max(out_means)/1000000;
    x = 1:length(out_means);
    shadedErrorBar(x,out_means./1000000,out_stds./1000000);
    %hold on
    %plot(x,out_means,'.','color',[0.5,0.5,0.95])
    %plot(binned_master(:,1)./binned_master(:,2))
    title("out data binned and mean")
    ylabel("Force(N)")
    xlabel("Radius (mm)")
    if save
        saveas(fig2,dirname + "/" + "out_mean.pdf")
    end

    fig3 = figure;
    hold on
    shadedErrorBar(x,out_means./1000000,out_stds./1000000);
    title("out data binned and mean")
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
    for i = 1:length(master)
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
    maximum_force(3) = max(in_means)/1000000
    x = 1:length(in_means);
    y = in_means./1000000;
    shadedErrorBar(x,y,in_stds./1000000);
    ylabel("Force(N)")
    xlabel("Radius (mm)")
    %plot(binned_master(:,1)./binned_master(:,2))
    title("hysteresis in and out pass")
    if save
        saveas(fig3,dirname + "/" + "hysteresis_mean.pdf")
    end

    fig4 = figure;
    hold on
    shadedErrorBar(x,y,in_stds./1000000);
    ylabel("Force(N)")
    xlabel("Radius (mm)")
    title("in data binned and mean")
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
    if all_plots
        for i = [1, 2, 3, 5, 6, 7, 8, 9, 10 ,11]
            % seperate data into inpass and outpass
            disp(i)
            turning = find(data(i,:,1)==max(data(i,:,1)));
            fh(i) = figure;
            hold on
            data_ind = squeeze(data(i,:,:));
            data_indout = squeeze(data(i,1:turning,:));
            data_indin = squeeze(data(i,turning:end,:));
            %plot(data_ind(:,1),data_ind(:,2));
            plot(data_indout(:,1),data_indout(:,2))
            plot(data_indin(:,1),data_indin(:,2))
            ylabel("Force(N)")
            xlabel("Radius (mm)")
            xlim([0 25000])
            ylim([0 10000000])
            hold (hAxes, 'on');
            plot(hAxes, data_ind(:,1),data_ind(:,2)./1000000)
            ylabel("Force(N)")
            xlabel("Radius (mm)")
        end
        if save
            saveas(hAxes,dirname + "/" + "all_data.pdf")
        end
    end
return