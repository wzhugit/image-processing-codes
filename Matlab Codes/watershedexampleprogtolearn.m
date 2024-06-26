clear 
clear
picture = imread("coins.jpg");
picture = rgb2gray(picture);
[row,col] = size(picture);   % 获得图片尺寸
watershed_result = -ones(row,col);  % 将结果矩阵全部赋值为-1表示所有点都未处理过
valley_number = 0; % 谷底数为0

tic

[picture_value, picture_index] = sort(picture(:)); % 将图片中所有元素按像素值大小排序

toc

total_pixel_number = row*col;  % 总元素个数

tic

for now_index = 1:total_pixel_number   % 对每个像素都要处理
    if watershed_result(picture_index(now_index)) ~= -1  % 如果标记为处理过跳过该像素
        continue;
    end
    now_picture_index = picture_index(now_index);     % 正在处理的像素的位置
    now_picture_value = picture(now_picture_index);   % 正在处理的像素的像素值
    vector_now_pixel_neighbor = neighbor_find_C(row,col,now_picture_index); % 获取当前像素点的周围8个像素点的位置
    temp_vector = sort(watershed_result(vector_now_pixel_neighbor));%获取周围像素点的标签
    temp_vector = unique(temp_vector);
    temp_vector = temp_vector(temp_vector>0);  %除了-1，0的标签种类
    temp_vector_length = length(temp_vector); 
    
    if temp_vector_length == 0  %种类为0
        is_same_area_index = zeros(2*col+2*row,1,'double');%和处理点像素值相同的连通区域
        is_same_area_index(1) = now_picture_index;
        area_num = 1;%连通区域的像素个数
        while(1)   %获得和处理点像素值相同的连通区域
            %获取联通区域的周围像素点的位置          
            is_same_area_neighbor_index = area_neighbor_find_C(row,col,is_same_area_index(1:area_num));
            %获取联通区域的周围像素点像素值大小和当前点像素值大小相同的点的像素值
            temp_vector = is_same_area_neighbor_index(picture(is_same_area_neighbor_index) == now_picture_value);
            temp_vector_length = length(temp_vector);
            if temp_vector_length == 0
                break;
            end
        is_same_area_index(area_num+1:area_num+temp_vector_length) = temp_vector;
        area_num = area_num + temp_vector_length;
        is_same_area_index = is_same_area_index(is_same_area_index>0);
        end
        temp_vector = sort(watershed_result(is_same_area_neighbor_index));%获取连通区域周围像素点的标签
        temp_vector = unique(temp_vector);
        temp_vector = temp_vector(temp_vector>0);
        temp_vector_length = length(temp_vector);%除了-1，0的标签种类
        if temp_vector_length == 0%种类为0
            valley_number = valley_number+1;%谷底数加1
            watershed_result(is_same_area_index(is_same_area_index>0)) = valley_number;%认为该连通区域为一个新的谷底
        else 
            watershed_result(now_picture_index) = temp_vector(1);%否则该点贴与之相邻的标签中除-1，0外较小的标签
        end
    else
        if temp_vector_length == 1      % 相邻8个像素中标签种类除-1，0还有1个
            watershed_result(now_picture_index) = temp_vector(1);               % 该像素点贴相同标签
        else                             % 相邻8个像素中标签种类除-1，0为1个以上
            watershed_result(now_picture_index) = 0;                            % 认为该点为分水岭
        end
    end
end
toc
figure,imshow(watershed_result);%输出分水岭


function vector_neighbor_C = neighbor_find_C(row,col,nn)
    total_number=row*col;
    now_col= floor(nn/row)+1;
    temp=rem(nn,row);    %r = rem(a,b) returns the remainder after division of a by b, 
                         %where a is the dividend and b is the divisor. This function is often called the remainder operation, 
                         %which can be expressed as r = a - b.*fix(a./b). The rem function follows the convention that rem(a,0) is NaN.
    if temp==0
        now_row=row;
    else
        now_row=temp;
    end
    
    if nn==1
        vector_neighbor_C=[2;row+1;row+2];    %vector_neighbor_C表示当前处理的单索引表示的像素的8领域的单索引值
    elseif nn==row
        vector_neighbor_C=[row;row+row;row+row-1];
    elseif nn==total_number-row+1
        vector_neighbor_C=[total_number-row+2;total_number-row-row;total_number-row-row+1];
    elseif nn==total_number
        vector_neighbor_C=[total_number-1;total_number-row;total_number-row-1];
    elseif now_row==1
        vector_neighbor_C=[nn+row;nn-row;nn+1;nn+row+1;nn-row+1];
    elseif now_row==row
        vector_neighbor_C=[nn+row;nn-row;nn-1;nn+row-1;nn-row-1];
    elseif now_col==1
        vector_neighbor_C=[nn+1;nn-1;nn+row;nn+row+1;nn+row-1];
    elseif now_col==col
        vector_neighbor_C=[nn+1;nn-1;nn-row;nn-row+1;nn-row-1];
    else
        vector_neighbor_C=[nn+1;nn-1;nn-row;nn+row;nn-row+1;nn-row-1;nn+row+1;nn+row-1];
    end
end
    

function vector_neighbor = area_neighbor_find_C(row,col,area_index)
    I = zeros(row,col);
    se=ones(3);
    I(area_index) = 1;
    I2 = imfilter(I,se);  % 滤波，imfilter(I,se)采用相关操作，imfilter(I,se,'conv')使用卷积操作
    I2=I2-I.*9;
    vector_neighbor = find(I2>0);
end