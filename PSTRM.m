classdef PSTRM
    properties
        
    end
    
    methods
        function r = compute_ability(obj)
            tau = [0:99];
            Pout = 10 * (10^-3);
            
            for i=1:iterations
                if (func == 1)
                    tau1 = tau - 100;
                    ability = (1./(1 + exp((Pout * tau1) .^ -1)));
                elseif (func == 0)
                    ability = 0;
                end
                %disp(A);
            end
        end
    end
