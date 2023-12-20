%%%%%%%%%%%%%%%%%%
% Routine to extract particle metadata from csv files and match 
% to detected events
%
% Produces an array (metadata) that includes columns timestamp, mass, and
% velocity
%
% 6/08/21 - LKT
%%%%%%%%%%%%%%%%%%

dpath = '/media/lita3520/IMPACTablation/dust_data/';
pname = ['6_14_21'];

cd(strcat(dpath,pname))

tmp = dir('*.csv');
m = readmatrix(tmp.name);
%%%%% 
% Columns:
% 1 event ID
% 2 UTC timestamp
% 3 local timestamp
% 4 integer timestamp (ms)
% 5 velocity (m/s)
% 6 mass (kg)
% 7 charge (C)
% 8 radius (m)
%%%%%%

metadata_in.tstamp = m(:,3);
metadata_in.velocity = m(:,5);
metadata_in.mass = m(:,6);

switch pname
    case '6_1_21'
        disp('No timestamp info')
    case '6_3_21'
        bstr = '20210603';
        nsets = 4;
        t1 = strcat(bstr,'104300.143');
        t2 = strcat(bstr,'112300.021');
        t3 = strcat(bstr,'120000.244');
        t4 = strcat(bstr,'125536.912');
    case '6_7_21'
        bstr = '20210607';
        nsets = 3;
        t1 = strcat(bstr,'104606.005');
        t2 = strcat(bstr,'113617.593');
        t3 = strcat(bstr,'120820.870');
        %t4 = strcat(bstr,'125917.153');
    case '6_14_21'
        bstr = '20210614';
        nsets = 7;
        t1 = strcat(bstr,'095738.764');
        t2 = strcat(bstr,'103658.111');
        t3 = strcat(bstr,'110352.209');
        t4 = strcat(bstr,'112852.060');
        t5 = strcat(bstr,'120239.472');
        t6 = strcat(bstr,'124017.870');
        t7 = strcat(bstr,'131119.777');
        %t8 = strcat(bstr,'134059.675');
    case '6_15_21'
        bstr = '20210615';
        nsets = 7;
        t1 = strcat(bstr,'103016.964');
        t2 = strcat(bstr,'111410.982');
        t3 = strcat(bstr,'113917.949');
        t4 = strcat(bstr,'120459.838');
        t5 = strcat(bstr,'123016.484');
        t6 = strcat(bstr,'125859.644');
        t7 = strcat(bstr,'133036.420');
    case '6_16_21'
        bstr = '20210616';
        nsets = 7;
        t1 = strcat(bstr,'101401.556');
        t2 = strcat(bstr,'104640.690');
        t3 = strcat(bstr,'112358.831');
        t4 = strcat(bstr,'115435.857');
        t5 = strcat(bstr,'122845.000');
        t6 = strcat(bstr,'130412.735');
        t7 = strcat(bstr,'134017.044');
    otherwise
        disp('Incorrect path')
        return
end

for iset = 1:nsets
    tmp = find(metadata_in.tstamp > str2double(eval(strcat('t',string(iset)))));
    sind = tmp(1)-1;
    
    cd(strcat(dpath,pname,'/',string(iset)))
    load('flag.mat')
    flag_inds = find(flag == 1);
    metadata = nan(size(flag_inds,1),3);
    metadata(:,1) = metadata_in.tstamp(flag_inds+sind);
    metadata(:,2) = metadata_in.mass(flag_inds+sind);
    metadata(:,3) = metadata_in.velocity(flag_inds+sind);
    
    save('metadata.mat','metadata')
end