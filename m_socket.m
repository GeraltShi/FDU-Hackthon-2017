clc
clear

data_all=[];%���ڴ洢���е�����
u = udp('127.0.0.1', 54377, 'Timeout', 60,'InputBufferSize',10240);%�������ip������˿ڵ�UDP��������60�볬ʱ�������С1024
fopen(u);
fwrite(u,'get');%����һ�����ݸ�udp����������������֪��matlab��ip�Ͷ˿�
receive = fread(u, 40960);%��ȡUDP����������������
data=str2num(char(receive(1:end)')); %��ASCII��ת��Ϊstr���ٽ�strת��Ϊ����
data_all=[data_all;data];
pause(0.0001);
fprintf(num2str(data));
fclose(u);
delete(u);