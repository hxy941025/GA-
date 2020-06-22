clear all;
clc;

% 问题6个参数：id、type、score、difficult、point、interval
% 题库2000题，各类型500个，按顺序区分

problem = zeros(1,6);
global problem_size;
global problemDB;
global population_size;
global chromosome_size;

problem_size = 2000;
problemDB = zeros(problem_size,6);
population_size = 20;
chromosome_size = 20;  

population = zeros(population_size,chromosome_size); % 基因链数组


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

% 生成试题库数组   
function[] =  ProblemDB_create()
global problem_size;
global problemDB;
for i = 1:problem_size
    type_size = problem_size/4;
    % id、type、score、difficult、section、interval
    problemDB(i,1) = i; %id
    problemDB(i,4) = randperm(4,1)/5; %难度系数，题目划分为正确率0.2/0.4/0.6/0.8四档
    problemDB(i,5) = randperm(10,1); %知识点，即章节，随机指定，划分十个章节
    problemDB(i,6) = randperm(5,1); %曝光时间，1-5，曝光时间>3视为近期未出现
    % 单选 5分     
    if i<=type_size
       problemDB(i,2) = 1;
       problemDB(i,3) = 5;
    % 多选 5分      
    elseif (type_size<i)&& (i<=type_size*2)
       problemDB(i,2) = 2;
       problemDB(i,3) = 5;
    % 判断  5分     
    elseif (type_size*2<i)&& (i<=type_size*3)
       problemDB(i,2) = 3;
       problemDB(i,3) = 5;                   
    % 填空  5分     
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
% 采用实数编码方式，为了避免重复选题，直接随机不重复抽取105个单选、多选、判断、填空，组成20条基因链，其中前五个被舍弃；
type_0 = randperm(type_size,105);
type_1 = randperm(type_size,105) + 500;
type_2 = randperm(type_size,105) + 1000; 
type_3 =  randperm(type_size,105) + 1500;
 
% 产生初始种群
% 基因链(选择*5 | 多选*5 | 判断*5 | 填空*5)；
for i = 1:chromosome_size
    j = i*5;
	population(i,:) = [type_0(j:j+4), type_1(j:j+4), type_2(j:j+4), type_3(j:j+4)];    
end
end

function[adapt,best_indiv,best_adp]  = adapt_calc(population)
% 适应度函数计算
global population_size;
global chromosome_size;
global problemDB;

difficult = zeros(chromosome_size,1); % 统计一条基因链的平均难度
points = zeros(chromosome_size,1); % 统计一条基因链的挑选的知识点出现次数
interval = zeros(chromosome_size,1); % 统计一条基因链的平均曝光时间
adapt = zeros(chromosome_size,1); % 统计基因链适应度


for i = 1:population_size
    for k = 1: chromosome_size
        id = population(i,k);
        difficult(i) = difficult(i) + problemDB(id,4)/chromosome_size;  %计算每条基因链平均难度        
        if problemDB(id,5) == 4 %预设要考第四章
            points(i) = points(i) + 1; %计算要考察的章节知识点覆盖率
        end          
        if problemDB(id,6) > 3
           interval(i) = interval(i) + 1; %计算每条基因链曝光时间>3的个数
        end        
    end
    % 计算每条基因链适应度，预设难度0.4，难度、章节、曝光时间比例0.4 0.3 0.3    
    adapt(i) = -0.4*abs(difficult(i) - 0.4) + 0.3*points(i) + 0.3*interval(i);
    [best_adp, best_indiv] = max(adapt); %记录精英个体
end
end

function[population_sel]  = select(population, adapt)
global population_size;
global chromosome_size;

% 选择算子，根据适应度，进行轮盘赌选择
adapt_sum = sum(adapt);
population_sel = zeros(population_size,chromosome_size); % 基因链数组

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
% 交叉算子，取0.6概率（比例）交叉
father = population_sel(1:population_size/2,:);
mother = population_sel(population_size/2+1:population_size,:);
population_new = zeros(population_size,chromosome_size);
for i = 1:population_size/2
    change_pos = randperm(chromosome_size,1); %随机交叉位置
    if rand <= 0.6  % 0.6概率交叉    
        population_new(i*2-1,:) = [father(i,1:change_pos),mother(i,change_pos+1:chromosome_size)];
        population_new(i*2,:) = [mother(i,1:change_pos),father(i,change_pos+1:chromosome_size)];
    else %直接遗传
        population_new(i*2-1,:) = father(i,:);
        population_new(i*2,:) = mother(i,:);
    end
end
end

function [population_new] = mutation(population_new)
global population_size;
global chromosome_size;
% 变异算子 ，0.01概率随机位置产生基因变异
for i = 1:population_size
    mutation_pos = randperm(chromosome_size,1); %随机变异位置
    % 判断随机位置的题型
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

