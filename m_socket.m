clc
clear

data_all=[]; %用于存储所有的数据
u = udp('127.0.0.1', 54377, 'Timeout', 60,'InputBufferSize',10240); %连接这个ip和这个端口的UDP服务器，60秒超时，缓冲大小1024
fopen(u);
fwrite(u,'get'); %发送一段数据给udp服务器。服务器好知道matlab的ip和端口
receive = fread(u, 40960); %读取UDP服务器传来的数据
data=str2num(char(receive(1:end)')); %将ASCII码转换为str，再将str转换为数组
data_all=[data_all;data];
pause(0.0001);
fprintf(num2str(data));
fclose(u);
delete(u);