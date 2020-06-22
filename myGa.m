clear all;
clc;

% ����6��������id��type��score��difficult��point��interval
% ���2000�⣬������500������˳������

problem = zeros(1,6);
global problem_size;
global problemDB;
global population_size;
global chromosome_size;

problem_size = 2000;
problemDB = zeros(problem_size,6);
population_size = 20;
chromosome_size = 20;  

population = zeros(population_size,chromosome_size); % ����������


ProblemDB_create();
population = population_init(population);

for i = 1:200
[adapt, best_indiv, best_adp(i)] = adapt_calc(population);
population_sel = select(population, adapt);
population_new = cross(population_sel);
population_new = mutation(population_new);
population_new(20,:) = population(best_indiv, :);
population = population_new; 
end
plot(best_adp)

% �������������   
function[] =  ProblemDB_create()
global problem_size;
global problemDB;
for i = 1:problem_size
    type_size = problem_size/4;
    % id��type��score��difficult��section��interval
    problemDB(i,1) = i; %id
    problemDB(i,4) = randperm(4,1)/5; %�Ѷ�ϵ������Ŀ����Ϊ��ȷ��0.2/0.4/0.6/0.8�ĵ�
    problemDB(i,5) = randperm(10,1); %֪ʶ�㣬���½ڣ����ָ��������ʮ���½�
    problemDB(i,6) = randperm(5,1); %�ع�ʱ�䣬1-5���ع�ʱ��>3��Ϊ����δ����
    % ��ѡ 5��     
    if i<=type_size
       problemDB(i,2) = 1;
       problemDB(i,3) = 5;
    % ��ѡ 5��      
    elseif (type_size<i)&& (i<=type_size*2)
       problemDB(i,2) = 2;
       problemDB(i,3) = 5;
    % �ж�  5��     
    elseif (type_size*2<i)&& (i<=type_size*3)
       problemDB(i,2) = 3;
       problemDB(i,3) = 5;                   
    % ���  5��     
    elseif (type_size*3<i)&& (i<=type_size*4)
       problemDB(i,2) = 4;
       problemDB(i,3) = 5;
    end
end
end


function[population] = population_init(population)
global problem_size;
global chromosome_size;
type_size = problem_size/4;
% ����ʵ�����뷽ʽ��Ϊ�˱����ظ�ѡ�⣬ֱ��������ظ���ȡ105����ѡ����ѡ���жϡ���գ����20��������������ǰ�����������
type_0 = randperm(type_size,105);
type_1 = randperm(type_size,105) + 500;
type_2 = randperm(type_size,105) + 1000; 
type_3 =  randperm(type_size,105) + 1500;
 
% ������ʼ��Ⱥ
% ������(ѡ��*5 | ��ѡ*5 | �ж�*5 | ���*5)��
for i = 1:chromosome_size
    j = i*5;
	population(i,:) = [type_0(j:j+4), type_1(j:j+4), type_2(j:j+4), type_3(j:j+4)];    
end
end

function[adapt,best_indiv,best_adp]  = adapt_calc(population)
% ��Ӧ�Ⱥ�������
global population_size;
global chromosome_size;
global problemDB;

difficult = zeros(chromosome_size,1); % ͳ��һ����������ƽ���Ѷ�
points = zeros(chromosome_size,1); % ͳ��һ������������ѡ��֪ʶ����ִ���
interval = zeros(chromosome_size,1); % ͳ��һ����������ƽ���ع�ʱ��
adapt = zeros(chromosome_size,1); % ͳ�ƻ�������Ӧ��


for i = 1:population_size
    for k = 1: chromosome_size
        id = population(i,k);
        difficult(i) = difficult(i) + problemDB(id,4)/chromosome_size;  %����ÿ��������ƽ���Ѷ�        
        if problemDB(id,5) == 4 %Ԥ��Ҫ��������
            points(i) = points(i) + 1; %����Ҫ������½�֪ʶ�㸲����
        end          
        if problemDB(id,6) > 3
           interval(i) = interval(i) + 1; %����ÿ���������ع�ʱ��>3�ĸ���
        end        
    end
    % ����ÿ����������Ӧ�ȣ�Ԥ���Ѷ�0.4���Ѷȡ��½ڡ��ع�ʱ�����0.4 0.3 0.3    
    adapt(i) = -0.4*abs(difficult(i) - 0.4) + 0.3*points(i) + 0.3*interval(i);
    [best_adp, best_indiv] = max(adapt); %��¼��Ӣ����
end
end

function[population_sel]  = select(population, adapt)
global population_size;
global chromosome_size;

% ѡ�����ӣ�������Ӧ�ȣ��������̶�ѡ��
adapt_sum = sum(adapt);
population_sel = zeros(population_size,chromosome_size); % ����������

for i = 1:population_size
   pro_sum = 0;
   sel_rand = rand;
   for j = 1:population_size
   pro_sum = pro_sum + adapt(j)/adapt_sum;
        if pro_sum >= sel_rand
                population_sel(i,:) = population(j,:);
                break
        end
   end
end
end

function [population_new] = cross(population_sel)
global population_size;
global chromosome_size;
% �������ӣ�ȡ0.6���ʣ�����������
father = population_sel(1:population_size/2,:);
mother = population_sel(population_size/2+1:population_size,:);
population_new = zeros(population_size,chromosome_size);
for i = 1:population_size/2
    change_pos = randperm(chromosome_size,1); %�������λ��
    if rand <= 0.6  % 0.6���ʽ���    
        population_new(i*2-1,:) = [father(i,1:change_pos),mother(i,change_pos+1:chromosome_size)];
        population_new(i*2,:) = [mother(i,1:change_pos),father(i,change_pos+1:chromosome_size)];
    else %ֱ���Ŵ�
        population_new(i*2-1,:) = father(i,:);
        population_new(i*2,:) = mother(i,:);
    end
end
end

function [population_new] = mutation(population_new)
global population_size;
global chromosome_size;
% �������� ��0.01�������λ�ò����������
for i = 1:population_size
    mutation_pos = randperm(chromosome_size,1); %�������λ��
    % �ж����λ�õ�����
    if mutation_pos<=5
        type = 0;
    elseif (5<mutation_pos) && (mutation_pos<=10)
        type = 1;
    elseif (10<mutation_pos) && (mutation_pos<=15)
        type = 2;
    else
        type = 3;
    end
    
    if rand < 0.01
        mutation_gen = type*500 + randperm(500,1);
        if ismember(mutation_gen,population_new(i,:)) ~= 1
             population_new(i,mutation_pos) = mutation_gen;
        end       
    end
end

end

