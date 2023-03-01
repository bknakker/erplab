%CHECK BEST WITH MULTIPLE FILES
% Once BEST structure is created (for one file, or more than one file,
% check to see if fields are correct
% Checks for more than one subject:
% Same number of bins
% Same bin labels


function checking = checkmultiBEST(BEST)

    %multiple files
    try
        %take the first file's properties and check against each subseqent 
        bins_in_data1 = numel(BEST(1).binwise_data);
        
        for n = 1:numel(BEST)
            bin_in_data = numel(BEST(n).binwise_data); 
            if bin_in_data == bins_in_data1
                
            else
                error();
            end
            
        end
        
        if isequaln(BEST.bindesc) 
            
        else
            error();
        end
        checking = 1;
        
    catch
        
        if numel(BEST) == 1
            checking = 1; 
            return
        else
            checking = 0;
            disp('Error: multiple BEST files do not match!'); 
           % error(); 
        end
      
    end


end