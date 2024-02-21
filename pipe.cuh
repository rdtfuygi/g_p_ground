#pragma once
#include<string>
#include<vector>
#include<Windows.h>

const char 方向_发送 = 1;
const char 方向_接收 = 2;
const char 方向_双向 = 3;

class pipe
{
public:
	HANDLE pip;
	std::vector<char> buffer;
	pipe(std::string 名字, int 缓冲区大小 = 4096, char 方向 = 方向_双向);
	~pipe();
	bool connect();

	bool send(std::vector<double>& 数据);

	bool receive(std::vector<double>& 数据);
};