#define _USE_MATH_DEFINES 
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

#include "geometry.cuh"

#include "ground.cuh"

#include <opencv2/core/utils/logger.hpp>

#include <random>


#include <cmath>

#include "other.cuh"
#include "pipe.cuh"



void 建筑重置(std::vector<building>& b, double a_s)
{
	vector 初始解[8] = { vector(0.0,0.0),vector(0.0,-1.0),vector(0.0,-2.0),vector(1.0,-2.0),vector(1.0,-1.0),vector(-1.0,1.0),vector(-1.0,-1.0),vector(-1.0,0.0) };

	double 缩放 = (double(rand()) / RAND_MAX + 0.5);
	vector 平移(double(rand()) / RAND_MAX, double(rand()) / RAND_MAX);
	b = std::vector<building>(8);

	double s = 0;
	while (s < a_s)
	{
		s = 0;
		for (int i = 0; i < b.size(); i++)
		{
			b[i].target_area = double(rand()) / RAND_MAX * a_s * 0.5;
			s += b[i].target_area;
		}
	}

	for (int i = 0; i < b.size(); i++)
	{
		double 半径 = sqrt(b[i].target_area / M_PI) / 8;
		b[i].fun = i;
		for (int j = 0; j < 20; j++)
		{
			b[i].site[j].origin = point(vector(b[i].site[j].origin) + ((初始解[b[i].fun]) * 50) + ((vector(1.0, 0.0).rotate(18 * j + 45)) * 半径));
		}
		b[i].site.reset_seg();
	}
}



int main()
{
	srand(time(0));
	cv::utils::logging::setLogLevel(cv::utils::logging::LOG_LEVEL_ERROR);



	////m^3
	//std::vector<double>年需求量 = { 13950000,13950000 * 0.3,13950000 * 0.2 };
	//
	//std::vector<double>订货成本 = { 10000,10000,10000 };
	//std::vector<double>持有成本 = { 10,20,30 };
	//
	//std::vector<double>需求方差 = { 400,100,100 };
	//std::vector<double>提前期 = { 0.0004,0.0003,0.0003 };
	//std::vector<double>提前期方差 = { 0.003,0.003,0.003 };
	//std::vector<double>服务水平 = { 0.95,0.95,0.95 };
	//
	//std::vector<char>库存类型 = { 0,1,2 };
	//
	//std::vector<double>补货点_(年需求量.size());
	//std::vector<double>订货批量_(年需求量.size());
	//
	//
	//double 总需求 = 0;
	//for (int i = 0; i < 年需求量.size(); i++)
	//{
	//	补货点_[i] = 补货点(年需求量[i], 需求方差[i], 提前期[i], 提前期方差[i], 服务水平[i]);
	//	订货批量_[i] = 订货批量(年需求量[i], 订货成本[i], 持有成本[i]);
	//
	//
	//	总需求 += 年需求量[i];
	//}
	//
	//std::vector<double>仓库面积;
	//std::vector<double>仓库限高 = { 30,10,10 };
	//仓库面积_计算(仓库面积, 补货点_, 订货批量_, 库存类型, 仓库限高);
	//
	//std::vector<building> b;
	//
	//面积设定(b, 总需求, 仓库面积);


	int w = 900, h = 900;
	double 比例 = 1;
	point o(0, 0);


	pipe output_pip("asd_out", 8192);
	pipe input_pip("asd_in");
	pipe callback_pip("asd_back");


	wchar_t command[] = L"python D:\\Users\\57247\\OneDrive\\Desktop\\g_p\\g_p_ground_ai\\g_p_ground_ai.py asd";
	STARTUPINFOW si = { 0 };
	PROCESS_INFORMATION pi = { 0 };
	CreateProcessW
	(
		NULL,
		command,
		NULL,
		NULL,
		FALSE,
		NULL,
		NULL,
		NULL,
		&si,
		&pi
	);

	//vector 初始解[8] = { vector(0.0,0.0),vector(0.0,-1.0),vector(0.0,-2.0),vector(1.0,-2.0),vector(1.0,-1.0),vector(-1.0,1.0),vector(-1.0,-1.0),vector(-1.0,0.0) };

	int loops = 0;



	while(true)
	{
		ground a;
		cv::Mat p;
		while (true)
		{
			a = 场地设定(double(rand()) / RAND_MAX * 200000 + 200000);
			a.site.move2center();

			p = cv::Mat::zeros(h, w, CV_8UC3);
			a.print(p, 比例, cv::Scalar(255, 255, 255));

			cv::imshow("123", p);
			cv::waitKey(1000);
			if (cv::waitKey(3000) != 'n')
			{
				break;
			}
		}

		double a_s = a.area();

		std::vector<building> b(8);



		建筑重置(b, a_s);

		for (int i = 0; i < b.size(); i++)
		{
			b[i].print(p, 比例, cv::Scalar(255, 255 / b.size() * i, 0));
		}

		cv::imshow("123", p);
		cv::waitKey(1);

		int r = 0;

		double 分数;
		{
			bool temp;
			分数 = 奖励函数(a, b, temp);
		}

		while(true)
		{
			std::vector<double> output;
			output.reserve(936);
			std::vector<double> a_data;
			a.data(a_data);
			output.insert(output.end(), a_data.begin(), a_data.end());
			for (int i = 0; i < b.size(); i++)
			{
				std::vector<double> b_data;
				b[i].data(b_data);
				output.insert(output.end(), b_data.begin(), b_data.end());
			}

			output_pip.send(output);

			std::vector<double> input;
			input_pip.receive(input);

			
			for (int i = 0; i < b.size(); i++)
			{
				std::vector<vector> input_point;
				input_point.reserve(20);
				for (int j = 0; j < 20; j++)
				{				
					vector temp = vector(point(input[i * 42 + j * 2], input[i * 42 + j * 2 + 1]));
					input_point.push_back(temp);
				}
				b[i].move(input_point.data());
				b[i].door[0] = int(input[i * 42 + 40]);
				b[i].door[1] = int(input[i * 42 + 41]);
				b[i].site.reset_seg();
				//b[i].site.simple(5);
			}
			std::vector<double> callback;
			bool reset = false;
			callback.reserve(2);

			{
				double temp = 奖励函数(a, b, reset);
				callback.push_back(temp - 分数);
				分数 = temp;
			}
			callback_pip.send(callback);

			if (reset)
			{
				r += 10;
			}
			if (r > 1000)
			{
				r = 0;
				建筑重置(b, a_s);
				{
					bool temp;
					分数 = 奖励函数(a, b, temp);
				}
			}
			r = (r > 0) ? r - 5 : 0;

			if ((loops % 1) == 0)
			{
				p = cv::Mat::zeros(h, w, CV_8UC3);
				a.print(p, 比例, cv::Scalar(255, 255, 255));
				for (int i = 0; i < b.size(); i++)
				{
					b[i].print(p, 比例, cv::Scalar(255, 255 / b.size() * i, 0));
				}


				cv::imshow("123", p);
				int key = cv::waitKey(1);
				if (key == 'n')
				{
					loops = 0;
					break;
				}
				else if (key == 'r')
				{
					建筑重置(b, a_s);
					{
						bool temp;
						分数 = 奖励函数(a, b, temp);
					}
				}
			}

			double s = 0;
			for (int i = 0; i < b.size(); i++)
			{
				s += b[i].area();
			}
			if (s > a_s)
			{
				建筑重置(b, a_s);
				{
					bool temp;
					分数 = 奖励函数(a, b, temp);
				}
			}

			loops++;
			if (loops >= 10000)
			{
				loops = 0;
				break;
			}
		}
	}

	CloseHandle(pi.hProcess);
	CloseHandle(pi.hThread);

	return 0;
}