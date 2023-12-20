base_path = '/media/lita3520/IMPACTablation/dust_data/6_14_21/';
nsets = 8;

for iset = 1:nsets

    set = strcat(string(iset),'/');
    nevents = 600;
    
    fid = fopen(strcat(base_path,set,'flag.txt'));
    formatSpec = '%i%';
    
    A = fscanf(fid,'%f');
    
    flag = zeros(nevents,1);
    flag(A) = 1;
    
    save(strcat(base_path,set,'flag.mat'),'flag')

end