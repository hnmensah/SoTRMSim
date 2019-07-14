classdef Network
    properties
        network_size;
        sensor_range;
        num_of_nodes;
        compute_node_id = 6;
        net_type;
 
        alpha = 0.39;
        psi = 0.26;
        phi = 0.15;
        
        
    end
    methods
%%        
        function r = Network(network_type, num_of_nodes, network_size, sensor_range) %constructor to initialize properties
                        
            if(~exist('network_type', 'var'))
               r.net_type = 2;
            else
                r.net_type = network_type;
            end
             if(~exist('num_of_nodes', 'var'))
               r.num_of_nodes = 100;
             else
                 r.num_of_nodes = num_of_nodes;
             end
             if(~exist('network_size', 'var'))
               r.network_size = 100;
             else
                 r.network_size = network_size;
             end
             if(~exist('sensor_range', 'var'))
               r.sensor_range = 20;
             else
                 r.sensor_range = sensor_range;
             end

             
            
        end

%%
        function r = multiplyBy(obj,n)
            r = [obj.Value] * n;
        end
%% 
        function [r, x_cord, y_cord] = generate_net(obj)  % method to generate the WSN topology for simulation
            noOfNodes = obj.num_of_nodes; % set the number of nodes within the sensor network
            rand('state', obj.net_type);    % set/initialize the random generator
            figure(1);  % show figure to display network
            set(gcf,'name','WSN simulation deployment','numbertitle','off');
            clf;  % clear the figure window
            hold on;  % hold the figure
            L = obj.network_size;  % maximum network size
            R = obj.sensor_range; % maximum sensor range;
            netXcor = rand(1,noOfNodes)*L;  % generate random numbers for the x-cordinates of sensor nodes
            netYcor = rand(1,noOfNodes)*L;  % generate random numbers for the y-cordinates of sensor nodes
            
            for i = 1:noOfNodes
                plot(netXcor(i), netYcor(i), '.');    % plot the sensor nodes on the field
                text(netXcor(i), netYcor(i), num2str(i));  % plot the label numbers of the sensor nodes
                
                %Determine the neighbours
                %matrix = zeros(noOfNodes);
                for j = 1:noOfNodes
                    distance = sqrt((netXcor(i) - netXcor(j))^2 + (netYcor(i) - netYcor(j))^2);
                    if distance <= R
                        matrix(i, j) = 1; % there is a link
                        line([netXcor(i) netXcor(j)], [netYcor(i) netYcor(j)], 'LineStyle', ':');  % show coverage connector                      
                    else
                        matrix(i, j) = inf; % there is no link
                    end
                   
                end 
            end
            r = matrix;
            x_cord = netXcor;
            y_cord = netYcor;
            
        end
%%
        function r = highlight_compute_node(obj, compute_node_id, netXvar, netYvar)
          scatter(netXvar(1, compute_node_id) ,netYvar(1, compute_node_id),70, 'green', 'filled'); 
          r=0;
        end
        
%%
        function [neighbour_x_cord, neighbour_y_cord, neighbour_label] = get_neighbours(obj, compute_node_id, neigh_x_cord, neigh_y_cord, net_plot_matrix)
            
            
            for k = 1:obj.num_of_nodes
                if net_plot_matrix(compute_node_id, k) == 1
                    if k~= compute_node_id
                        line([neigh_x_cord(compute_node_id) neigh_x_cord(k)], [neigh_y_cord(compute_node_id) neigh_y_cord(k)], 'Color','red','LineStyle','--');
                        neighbour_x_cord1(k) = neigh_x_cord(1, k);
                        neighbour_y_cord1(k) = neigh_y_cord(1, k);
                        neighbour_label1(k) = k;
                    end
                end
            end
            neighbour_x_cord2 = find(neighbour_x_cord1 > 0);
            neighbour_y_cord2 = find(neighbour_y_cord1 > 0);
            neighbour_label = find(neighbour_label1 > 0);
            
            neighbour_x_cord = neigh_x_cord(1, neighbour_x_cord2);
            neighbour_y_cord = neigh_y_cord(1, neighbour_y_cord2);
        end
        
        
        function r = highlight_neighbours(obj, neighbour_x_cor, neighbour_y_cor)
          noOfNeighbours = length(neighbour_x_cor);
          for i = 1:noOfNeighbours
            scatter(neighbour_x_cor(i) ,neighbour_y_cor(i),50, 'cyan', 'filled'); 
          r=0;
          end
        end
%% 
        function [mali_x_cor, mali_y_cor, mali_label, mali_trust_levels] = place_malicious_nodes(obj, percentage, neighbour_x_cor, neighbour_y_cor, neighbour_label)
            rand('state', obj.net_type);
            xmin = 0.4;
            xmax = 0.59;
            
            size_neighbours = length(neighbour_x_cor);
            actual_mali = ceil((percentage/100) * size_neighbours);
            malicious_node_id = randperm(size_neighbours, actual_mali);  % randomize the ids used for the selection of malicious nodes within neighbourhood.
            
            for i = 1:size_neighbours
            scatter(neighbour_x_cor(malicious_node_id) ,neighbour_y_cor(malicious_node_id),50, 'red', 'filled');  % indicate the malicious nodes on the network
           mali_x_cor = neighbour_x_cor(malicious_node_id);    % return x-cordinates for malicious nodes
            mali_y_cor = neighbour_y_cor(malicious_node_id);   % return y-cordinates for malicious nodes
            mali_label = neighbour_label(malicious_node_id);  % return labels for malicious nodes
            mali_trust_levels = xmin+rand(1,actual_mali)*(xmax-xmin);   % return randomly generate trust levels of malicious nodes between 0.4 - 0.59
          end
            
        end
   

%%
        function [battery_level, outage_probability] = generate_mali_param(obj, size_of_malicious_nodes, bat, pout)
            rand('state', obj.net_type);
            taumin = 70;
            taumax = 99;
            poutmin = 10^-3;
            poutmax = 10^-2;

            for i = 1:numel(size_of_malicious_nodes)
                if(~exist('pout', 'var'))
                    battery_level = taumin+rand(1,numel(size_of_malicious_nodes))*(taumax-taumin);
                else
                    battery_level = bat;
                end

                if(~exist('pout', 'var'))
                    outage_probability = 10 * (poutmin+rand(1,numel(size_of_malicious_nodes))*(poutmax-poutmin));
                else
                    outage_probability = 10 * pout;
                end


            end

        end
       

%% 
        function ability = compute_ability(obj, mali_bat, mali_pout)
            for i =1:numel(mali_bat)
            mali_bat1 = mali_bat - 100;
            ability = (1./(1 + exp((mali_pout .* mali_bat1) .^ -1)));
            
            
            end

        end
       
%%
function SHI = compute_indirect_info(obj, mali_levels, indirect_mode, diff_value)
    
    
    size_diff = numel(diff_value);
    if (strcmp(indirect_mode, 'co100'))
        
        for i = 1:size_diff

                copemin = mali_levels - (0.2 * mali_levels);
                copemax = mali_levels + (0.2 * mali_levels);
                SHI(i, :) = copemin+rand(1,(numel(mali_levels))) .* (copemax-copemin);

          
        end
        
    elseif (strcmp(indirect_mode, 'co80'))
        for i = 1:size_diff

                copemin = mali_levels - (0.2 * mali_levels);
                copemax = mali_levels + (0.2 * mali_levels);
                  if (i <= floor(0.80 * size_diff))
                SHI(i, :) = copemin+rand(1,(numel(mali_levels))) .* (copemax-copemin);
                else
                    SHI(i, :) = 0 +rand(1,(numel(mali_levels))) .* 0;
                end

          
        end
        
        elseif (strcmp(indirect_mode, 'co60'))
        for i = 1:size_diff

                copemin = mali_levels - (0.2 * mali_levels);
                copemax = mali_levels + (0.2 * mali_levels);
                  if (i <= floor(0.6 * size_diff))
                SHI(i, :) = copemin+rand(1,(numel(mali_levels))) .* (copemax-copemin);
                else
                    SHI(i, :) = 0+rand(1,(numel(mali_levels))) .* 0;
                end

          
        end
        
        
        elseif (strcmp(indirect_mode, 'co40'))
        for i = 1:size_diff

                copemin = mali_levels - (0.2 * mali_levels);
                copemax = mali_levels + (0.2 * mali_levels);
                 
                if (i <= floor(0.4 * size_diff))
                SHI(i, :) = copemin+rand(1,(numel(mali_levels))) .* (copemax-copemin);
                else
                    SHI(i, :) = 0+rand(1,(numel(mali_levels))) .* 0;
                end

          
        end
        
        elseif (strcmp(indirect_mode, 'co20'))
        for i = 1:size_diff

                copemin = mali_levels - (0.2 * mali_levels);
                copemax = mali_levels + (0.2 * mali_levels);
                if (i <= floor(0.2 * size_diff))
                SHI(i, :) = copemin+rand(1,(numel(mali_levels))) .* (copemax-copemin);
                else
                    SHI(i, :) = 0 + rand(1,(numel(mali_levels))) .* 0;
                end
          
        end
    end
   
end

%% 
function r = average_indirect_values(obj, indirect_info)

       r= sum(indirect_info(), 1) ./ size(indirect_info,1); 
        
 
end

%%
        function benevolence = compute_benevolence(obj, actual_mali_trust, average_indirect)
            direct_indirect = actual_mali_trust + average_indirect ./ 2;
            %direct_indirect = actual_mali_trust - average_indirect;

                      benevolence = (1./(1 + exp(-(2 * direct_indirect))));

                 
        end
  
        %%
        function [positives, negatives] = generate_consistency_parameters(obj, posmin, posmax, size_mali)
     
                positives = posmin+rand(1,size_mali) .* (posmax-posmin);
                negatives = 100 - positives;
                  
        end
      
%%        
        function consistency = compute_consistency(obj, positives, negatives)
              consistency = positives./(positives + negatives);
                
        end
        
        
%%        
        function trust = compute_pstrm_trust(obj, ability, benevolence, consistency)
            first = (obj.alpha .* ability);
            second = (obj.psi .* benevolence);
            third = (obj.phi .* consistency);
            
            trust = first + second + third;
                
        end  
        
%%
    function r = make_trust_plot(obj, actual_direct_trust, indirect_trust, direct_trust, rathore_trust, mali_label)
        figure;
        set(gcf,'name','Direct interaction against both direct and indirect interactions','numbertitle','off'); 
        
        semilogy(actual_direct_trust,'go-');
             
        hold on;
        grid on;
        semilogy(indirect_trust,'bh-');
        semilogy(direct_trust,'cd-');
        semilogy(rathore_trust,'m^-');
        size_mali = numel(mali_label);
        for i = 1:size_mali
           new_label(:,i) = strcat({'Node '}, {num2str(mali_label(i))});
        end
    
        set(gca, 'xtick', (1:1:size_mali), 'xticklabel', new_label);
        
        title('Sociopsychological Trust Computations')
        legend('random actual', 'pstrm', 'direct', 'rathore et al.' );
        xlabel('Malicious Nodes');
        ylabel('Trust');
    end
    
%%
function rathore_trust = compute_rathore_trust(obj, alpha_value, ability, data_diff, consistency)
   benevolence = exp(-(abs(data_diff)));
   first = alpha_value .* benevolence;
   second = ((1-alpha_value) .* consistency);
   rathore_trust = ability * (first + second);
end

%%        
        function trust = compute_direct_trust(obj, ability, benevolence, consistency)
            first = (obj.alpha .* ability);
            second = (obj.psi .* benevolence);
            third = (obj.phi .* consistency);
            
            trust = first + second + third;
                
        end 
        
%%
        function benevolence = compute_direct_benevolence(obj, actual_mali_trust)
            %direct_indirect = actual_mali_trust + average_indirect ./ 2;
            %direct_indirect = actual_mali_trust - average_indirect;

                      benevolence = (1./(1 + exp(-(2 * actual_mali_trust))));

                 
        end
    end
end


% 
% set(handleToYourMainGUI, 'HandleVisibility', 'off');
% close all;
% set(handleToYourMainGUI, 'HandleVisibility', 'on');