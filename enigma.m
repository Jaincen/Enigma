% Version:V0.5
% Author: 赵健成
% Date ： 2020.04.05
% 参数说明：
   % text 待加密字符串变量
   % sumcog 使用的转子数
   % retext 加密后的字符串变量
   % key 加密的key值
   % reflector 反射器
   % raw_cog 初始转子
   % new_cog 旋转后的转子
   % new_text 用于存储暴力破解后的所有可能结果
   % key_pos 破解后转子的位置存储

clear all;
c1 = [];
sumcog = input('请输入要使用的转子数(最多三个)：'); %3;
for i=1:sumcog
    c1 = [c1 input(sprintf('请输入第%d个转子的位置：',i))];
end 
text = input('请输入待加密字符串：','s');% 'aaaaa';
newtext='';
%c1 = input('请输入三个转子的起始位置(1-26，如[5,6,7])：');%[5,6,7];
reflector = [18, 16, 12, 15, 19, 13, 23, 20, 9, 8, 21, 14, 2, 5, 11, 3, 1, 22, 0, 4, 7, 10, 17, 6, 25, 24];
raw_cog = [[6, 10, 23, 9, 19, 2, 21, 1, 7, 24, 0, 17, 15, 3, 8, 4, 14, 12, 16, 25, 11, 18, 22, 20, 13, 5]
           [0, 7, 1, 10, 19, 5, 9, 18, 4, 23, 2, 20, 15, 24, 22, 8, 12, 25, 6, 13, 3, 11, 21, 17, 16, 14]
           [23, 2, 4, 13, 14, 21, 12, 0, 9, 16, 5, 17, 20, 22, 10, 24, 7, 3, 25, 8, 15, 6, 19, 18, 11, 1]];
%以上参数来自于提供的参考网址

for i = 1:sumcog
    new_cog(i,:) = [raw_cog(i,c1(i):end) raw_cog(i,1:c1(i)-1)];
    %raw_cog(i,:) = [raw_cog(i,c1(i):end) raw_cog(i,1:c1(i))];
end
count = 1;
for c = text
    num = 1+c-'a';
    for i=1:sumcog
        num = new_cog(i,num)+1;
    end
    num = reflector(num) + 1;    
    for i = 3:-1:1
        num = find(new_cog(i,:) == (num-1));        
    end
    for i = 0:sumcog-1
        if(26^i<= count && mod(count,26^i) == 0)
            new_cog(i+1,:) = [new_cog(i+1,2:end) new_cog(i+1,1:1)];
        %raw_cog(i,:) = [raw_cog(i,c1(i):end) raw_cog(i,1:c1(i))];
        end
    end
    count= count+1;
    x = char(num+'a'-1);
    newtext = [newtext x];
            
end
disp('加密后为：');
disp(newtext);

%------------------------------PART II 破解--------------------------------%
tic;
key=[];
j = 1;
for f1=1:26
    for f2 = 1:26
        for f3 = 1:26
            c2 = [f1 f2 f3];
            tempText = [];
            
            for i = 1:sumcog
              new_cog(i,:) = [raw_cog(i,c2(i):end) raw_cog(i,1:c2(i)-1)];
            end
            count = 1;
            for c = text
                num = 1+c-'a';
                for i=1:sumcog
                    num = new_cog(i,num)+1;
                end
                num = reflector(num) + 1;    
                for i = 3:-1:1
                    num = find(new_cog(i,:) == (num-1));        
                end
                for i = 0:sumcog-1
                    if(26^i<= count && mod(count,26^i) == 0)
                        new_cog(i+1,:) = [new_cog(i+1,2:end) new_cog(i+1,1:1)];
                    %raw_cog(i,:) = [raw_cog(i,c1(i):end) raw_cog(i,1:c1(i))];
                    end
                end
                count= count+1;
                x = char(num+'a'-1);
                tempText = [tempText x];
                

            end
            if (strcmp(tempText,newtext)==true)
                key_pos(j,:) = c2;
                newtext = tempText;
                j = j+1;
            end
            
        end
    end
end
toc;
disp('破解的转子位置为：');
disp(key_pos);
time = toc;
%----------------------PART III 改进 对Enigma加密后的结果进行多表代替------------------------%
%例如其当日转子位置为一个表，enigma最终的输出结果做一次多表代替
disp('多表代替：');
text = newtext;
%text = 'This is a test author by ZhaoJianCheng'; %待加密字符串
key = 'cipher'; %加密的Key值
i = 0;
keyIndex = 0;
for t = text

    %对每个英文字符进行加密
    i=i+1;
    keyIndex = mod(i,6);
    if(keyIndex == 0)
        keyIndex = 6;
    end
    if(t>='A' && t<='Z')
        retext(i) = char(mod(t-'A'+key(keyIndex) - 'a',26) + 'A'); 
    else if(t>='a' && t<= 'z')
        retext(i) = char(mod(t-'a'+key(keyIndex)-'a',26) + 'a');
        else
          retext(i) = t;
        end
    end
        
end
disp('原加密字符串为：');
disp(text);
disp('加密后为：');
disp(retext);
i = 0;
for t = retext

    %对每个英文字符进行加密
    i=i+1;
    keyIndex = mod(i,6);
    if(keyIndex == 0)
        keyIndex = 6;
    end
    if(t>='A' && t<='Z')
        decodeText(i) = char(mod(t-'A'-(key(keyIndex) - 'a'),26) + 'A'); 
    else if(t>='a' && t<= 'z')
        decodeText(i) = char(mod(t-'a'-(key(keyIndex)-'a'),26) + 'a');
        else
          decodeText(i) = t;
        end
    end
        
end


clear c;
clear i;
clear count;
