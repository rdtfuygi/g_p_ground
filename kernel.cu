﻿#define _USE_MATH_DEFINES 
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

#ifndef geometry
#define geometry
#include "geometry.cuh"
#endif

#ifndef ground_
#define ground_
#include "ground.cuh"
#endif



#include <opencv2/core/utils/logger.hpp>

#include <random>

#include <algorithm>
#include <cmath>

#include "other.cuh"
#include "pipe.cuh"



void 建筑重置(std::vector<building>& b, float a_s)
{
	vector 初始解[8] = { vector(0.0f,0.0f),vector(0.0f,-1.0f),vector(0.0f,-2.0f),vector(1.0f,-2.0f),vector(1.0f,-1.0f),vector(-1.0f,1.0f),vector(-1.0f,-1.0f),vector(-1.0f,0.0f) };

	float 缩放 = (float(rand()) / RAND_MAX + 0.5f);
	vector 平移(float(rand()) / RAND_MAX, float(rand()) / RAND_MAX);
	b = std::vector<building>(8);

	float s = 0;
	while (true)
	{
		s = 0;
		for (int i = 0; i < b.size(); i++)
		{
			b[i].target_area = (float(rand()) / RAND_MAX + 0.01f) * a_s * 0.5f;
			s += b[i].target_area;
		}
		if (((0.5 * a_s) < s) && (s < a_s))
		{
			break;
		}
	}

	for (int i = 0; i < b.size(); i++)
	{
		float 半径 = sqrt(b[i].target_area / float(M_PI)) / 8;
		b[i].fun = i;
		for (int j = 0; j < 20; j++)
		{
			b[i].site[j].origin = point(vector(b[i].site[j].origin) + ((初始解[b[i].fun]) * 100) + ((vector(1.0f, 0.0f).rotate(18 * j + 45)) * 半径));
		}
		b[i].site.reset_seg();
	}
}

float 非法_权重 = 10;
void 权重调整()
{
	std::string temp[] = { "面积_权重 = ","平直角_权重 = ","距离_权重 = ","门_权重 = ","周长_权重 = ","非法_权重 = "};
	float* t_d[] = { &面积_权重,&平直角_权重,&距离_权重,&门_权重,&周长_权重,&非法_权重 };
	for (int i = 0; i < 6; i++)
	{
		std::string t = temp[i] + "%.3f\n" + temp[i];
		printf(t.c_str(), *t_d[i]);
		float t_t;
		int t_i = 0;
		rewind(stdin);
		t_i = scanf("%f", &t_t);
		if (t_i == 1)
		{
			*t_d[i] = float(t_t);
		}
		printf("%.3f\n", *t_d[i]);
	}
}

int main()
{
	srand(time(0));
	cv::utils::logging::setLogLevel(cv::utils::logging::LOG_LEVEL_ERROR);



	////m^3
	//std::vector<float>年需求量 = { 13950000,13950000 * 0.3,13950000 * 0.2 };
	//
	//std::vector<float>订货成本 = { 10000,10000,10000 };
	//std::vector<float>持有成本 = { 10,20,30 };
	//
	//std::vector<float>需求方差 = { 400,100,100 };
	//std::vector<float>提前期 = { 0.0004,0.0003,0.0003 };
	//std::vector<float>提前期方差 = { 0.003,0.003,0.003 };
	//std::vector<float>服务水平 = { 0.95,0.95,0.95 };
	//
	//std::vector<char>库存类型 = { 0,1,2 };
	//
	//std::vector<float>补货点_(年需求量.size());
	//std::vector<float>订货批量_(年需求量.size());
	//
	//
	//float 总需求 = 0;
	//for (int i = 0; i < 年需求量.size(); i++)
	//{
	//	补货点_[i] = 补货点(年需求量[i], 需求方差[i], 提前期[i], 提前期方差[i], 服务水平[i]);
	//	订货批量_[i] = 订货批量(年需求量[i], 订货成本[i], 持有成本[i]);
	//
	//
	//	总需求 += 年需求量[i];
	//}
	//
	//std::vector<float>仓库面积;
	//std::vector<float>仓库限高 = { 30,10,10 };
	//仓库面积_计算(仓库面积, 补货点_, 订货批量_, 库存类型, 仓库限高);
	//
	//std::vector<building> b;
	//
	//面积设定(b, 总需求, 仓库面积);


	int w = 800, h = 800;
	float 比例 = 1;
	point o(0, 0);


	pipe output_pip("asd_out", 8192);
	pipe input_pip("asd_in");
	//pipe action_pip("asd_act");
	pipe callback_pip("asd_back");
	pipe G_pipe("asd_G");

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

	int loops = 0;

	权重调整();

	while(true)
	{
		ground a;
		cv::Mat p;

		float a_s;

		std::vector<building> b(8);
		while (true)
		{
			a = 场地设定(float(rand()) / RAND_MAX * 100000 + 300000);
			a.site.move2center();

			a_s = a.area();
			建筑重置(b, a_s);

			bool reset = false;
			for (int i = 0; i < 8; i++)
			{
				
				if (!a.site.full_overlap(b[i].site))
				{
					reset = true;
					break;
				}
			}

			if (reset)
			{
				continue;
			}

			p = cv::Mat::zeros(h, w, CV_8UC3);
			a.print(p, 比例, cv::Scalar(255, 255, 255));

			for (int i = 0; i < b.size(); i++)
			{
				b[i].print(p, 比例, cv::Scalar(255, 255 / b.size() * i, 0));
			}

			cv::imshow("123", p);
			if (cv::waitKey(3000) != 'n')
			{
				break;
			}
		}


		int r_times = 0;

		float 分数;
		{
			bool temp;
			分数 = 奖励函数(a, b, temp);
		}

		while(true)
		{
			/////////////////////////////////////////////////////////////////////////
			std::vector<float> output;
			output.reserve(952);

			std::vector<float> a_data;
			a.data(a_data);
			output.insert(output.end(), a_data.begin(), a_data.end());
			for (int i = 0; i < b.size(); i++)
			{
				std::vector<float> b_data;
				b[i].data(b_data);
				output.insert(output.end(), b_data.begin(), b_data.end());
			}

			output_pip.send(output);
			/////////////////////////////////////////////////////////////////////////

			int 非法动作 = 0;
			/////////////////////////////////////////////////////////////////////////
			std::vector<float> input;
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
				b[i].move(input_point, b, a, 非法动作);
				b[i].door[0] = int(std::round(input[i * 42 + 40])) % 20;
				b[i].door[1] = int(std::round(input[i * 42 + 41])) % 20;
				b[i].site.reset_seg();
				//b[i].site.simple(5);
				for (int j = 0; j < 20; j++)
				{
					input[i * 42 + j * 2] = input_point[i][0];
					input[i * 42 + j * 2 + 1] = input_point[i][1];
				}
			}
			/////////////////////////////////////////////////////////////////////////

			bool reset = false;
			/////////////////////////////////////////////////////////////////////////
			std::vector<float> callback;
			callback.reserve(2);
			{
				float temp = 奖励函数(a, b, reset);
				callback.push_back(temp - 分数 - 非法动作 * 非法_权重 / 20 / 8);
				分数 = temp;
			}
			callback_pip.send(callback);
			/////////////////////////////////////////////////////////////////////////


			/////////////////////////////////////////////////////////////////////////
			std::vector<float> G_;	
			/////////////////////////////////////////////////////////////////////////
			if (reset)
			{
				r_times += 10;
			}
			if (r_times > 1000)
			{
				G_.push_back(分数);
				r_times = 0;
				建筑重置(b, a_s);
				a.door[0] = rand() % 20;
				a.door[1] = rand() % 20;
				{
					bool temp;
					分数 = 奖励函数(a, b, temp);
				}
			}
			r_times = (r_times > 0) ? r_times - 5 : 0;

			if (((loops % 1000) == 0) && (loops != 0))
			{
				G_.push_back(分数);
				r_times = 0;
				a.door[0] = rand() % 20;
				a.door[1] = rand() % 20;
				建筑重置(b, a_s);
				{
					bool temp;
					分数 = 奖励函数(a, b, temp);
				}
			}

			if ((loops % 10) == 0)
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
					G_.push_back(分数);
					G_pipe.send(G_);
					loops = 0;
					break;
				}

				switch (key)
				{
				case 'r':
				{
					G_.push_back(分数);
					a.door[0] = rand() % 20;
					a.door[1] = rand() % 20;
					建筑重置(b, a_s);
					{
						bool temp;
						分数 = 奖励函数(a, b, temp);
					}
					break;
				}
				case 'c':
				{
					权重调整();
					bool temp;
					分数 = 奖励函数(a, b, temp);
					break;
				}
				default:
					break;
				}
			}

			{
				float s = 0;
				for (int i = 0; i < b.size(); i++)
				{
					s += b[i].area();
				}
				if (s > a_s)
				{
					G_.push_back(分数);
					a.door[0] = rand() % 20;
					a.door[1] = rand() % 20;
					建筑重置(b, a_s);
					{
						bool temp;
						分数 = 奖励函数(a, b, temp);
					}
				}
			}



			loops++;
			if (loops >= 10000)
			{
				G_.push_back(分数);
				G_pipe.send(G_);
				loops = 0;
				break;
			}

			if (G_.size() == 0)
			{
				G_.push_back(0.0);
			}

			G_pipe.send(G_);
		}
	}

	CloseHandle(pi.hProcess);
	CloseHandle(pi.hThread);

	return 0;
}