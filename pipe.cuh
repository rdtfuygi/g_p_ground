#pragma once
#include<string>
#include<vector>
#include<Windows.h>

const char ����_���� = 1;
const char ����_���� = 2;
const char ����_˫�� = 3;

class pipe
{
public:
	HANDLE pip;
	std::vector<char> buffer;
	pipe(std::string ����, int ��������С = 4096, char ���� = ����_˫��);
	~pipe();
	bool connect();

	bool send(std::vector<double>& ����);

	bool receive(std::vector<double>& ����);
};