% Simulator Design Files

% socio-Phychological Trust Model
% Henry Nunoo-Mensah
% Date: 06/06/2017

clear; 
clc;
close all;
a = Network; % Create network object

%a.compute_node_id = 3; % set compute node of networkobject

%a.net_type = 0;  % set network type of the network object

%a.sensor_range = 100; % set sensor range for the network object

[net_plot_matrix, node_x, node_y] = generate_net(a); % generate the cordinate of the sensor nodes and deploy (plot) network based on network type

hold on;  % hold figure

highlight_compute_node(a, a.compute_node_id, node_x, node_y); % select trustor node on the network

[x_neigh_cor,y_neigh_cor, neigh_label] = get_neighbours(a,a.compute_node_id, node_x, node_y, net_plot_matrix); % determine the cordinates and labels for neighbours of the trustor node

highlight_neighbours(a, x_neigh_cor, y_neigh_cor); % select neighbours (within the neighbourhood) of trustor on the network

percentage_of_malicious_neighbours = 80; % set the percentage of nodes in neighbourhood that should be malicious.

[x_mali_cor, y_mali_cor, mali_label, actual_mali_trust] = place_malicious_nodes(a,percentage_of_malicious_neighbours, x_neigh_cor, y_neigh_cor, neigh_label); % identify the malicious nodes (candidate trustees) within the neighbourhood of the trustor

%% Malicious node parameters.
[mali_bat, mali_pout] = generate_mali_param(a, x_mali_cor);  % generate the battery_levels and outage probability of malicious nodes

ability = compute_ability(a, mali_bat, mali_pout);  % compute the ability of all malicious nodes in neighbourhood

[diff_labels,diff_label_ids] = setdiff(neigh_label,mali_label);  % get non-malicious node ids and labels

indirect_info = compute_indirect_info(a, actual_mali_trust , 'co100', diff_labels); % generate the indirect information of all malicious nodes on each node 
% sensor node

average_indirect = average_indirect_values(a, indirect_info); % average all the received indirect information from all the sensor nodes concerning nodes

benevolence = compute_benevolence(a, actual_mali_trust, average_indirect);

[positives, negatives] = generate_consistency_parameters(a, 10, 40, numel(mali_label));

consistency = compute_consistency(a, positives, negatives);

measured_trust = compute_pstrm_trust(a, ability, benevolence, consistency);

rathore_trust = compute_rathore_trust(a, 0.5, 1, (actual_mali_trust - average_indirect), consistency);

direct_benevolence = compute_direct_benevolence(a, actual_mali_trust);

actual_direct_trust = compute_direct_trust(a, ability, direct_benevolence, consistency);


make_trust_plot(a, actual_mali_trust, measured_trust, actual_direct_trust, rathore_trust, mali_label);










