#include"pipe.cuh"
#include <codecvt>
#include <locale>
#include <ctime>

pipe::pipe(std::string 名字, int 缓冲区大小, char 方向) :buffer(缓冲区大小)
{
	std::string 管道名字 = "\\\\.\\pipe\\" + 名字 + "_pipe";
	std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>, wchar_t> 转换器;
	std::wstring 管道名字_Unicode = 转换器.from_bytes(管道名字);
	int 传输模式;
	switch (方向)
	{
	case 方向_接收:
		传输模式 = PIPE_ACCESS_INBOUND;
		break;
	case 方向_发送:
		传输模式 = PIPE_ACCESS_OUTBOUND;
		break;
	case 方向_双向:
		传输模式 = PIPE_ACCESS_DUPLEX;
		break;
	default:
		传输模式 = PIPE_ACCESS_DUPLEX;
		break;
	}
	pip = CreateNamedPipeW(
		管道名字_Unicode.c_str(),
		传输模式,
		PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
		PIPE_UNLIMITED_INSTANCES,
		缓冲区大小,
		缓冲区大小,
		NMPWAIT_WAIT_FOREVER,
		NULL);
}

pipe::~pipe()
{
	CloseHandle(pip);
}

bool pipe::connect()
{
	return ConnectNamedPipe(pip, NULL);
}


bool pipe::send(std::vector<double>& 数据)
{
	DWORD 数据量 = 1;
	while (数据量 != 0)
	{
		PeekNamedPipe(pip, NULL, NULL, NULL, &数据量, NULL);
		//Sleep(1000);
	}
	数据.push_back(数据.size());
	bool 结果 = WriteFile(pip, 数据.data(), sizeof(double) * 数据.size(), &数据量, NULL);
	if (结果 && (数据量 == sizeof(double) * 数据.size()))
	{
		return true;
	}
	return false;
}


bool pipe::receive(std::vector<double>& 数据)
{
	DWORD 数据量 = 0;
	while (数据量 == 0)
	{
		PeekNamedPipe(pip, NULL, NULL, NULL, &数据量, NULL);
	}
	数据 = std::vector<double>(数据量 / sizeof(double));
	bool 结果 = ReadFile(pip, 数据.data(), sizeof(double) * 数据.size(), &数据量, NULL);
	double 尺寸 = 数据[数据.size() - 1];
	数据.erase(数据.end() - 1);
	if (结果 && (数据.size() == 尺寸))
	{
		return true;
	}	
	return false;
}
