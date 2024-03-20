#include "other.cuh"
#include <float.h>

double norm_quantile(double a)
{
	if (0 >= a)
	{
		return -DBL_MAX;
	}
	if (a >= 1)
	{
		return DBL_MAX;
	}

	const double 表[100] = { 0.0,0.012533469508069276,0.02506890825871106,0.037608287661255936,0.05015358346473367,0.06270677794321385,0.0752698620998299,0.08784483789587182,0.10043372051146988,0.11303854064456524,0.12566134685507416,0.13830420796140466,0.1509692154967774,0.16365848623314114,0.1763741647808612,0.18911842627279238,0.20189347914185074,0.21470156800174442,0.22754497664114934,0.2404260311423079,0.2533471031357997,0.26631061320409494,0.27931903444745415,0.2923748962268042,0.3054807880993974,0.31863936396437514,0.33185334643681663,0.34512553147047237,0.3584587932511938,0.37185608938507475,0.38532046640756773,0.39885506564233686,0.41246312944140495,0.4261480078412783,0.4399131656732339,0.45376219016987956,0.4676987991145084,0.48172684958473044,0.4958503473474532,0.5100734569685946,0.5244005127080407,0.5388360302784502,0.5533847195556727,0.5680514983389827,0.5828415072712162,0.5977601260424784,0.6128129910166272,0.6280060144375695,0.643345405392917,0.6588376927361878,0.6744897501960817,0.6903088239330339,0.7063025628400874,0.7224790519280627,0.7388468491852137,0.7554150263604693,0.7721932141886848,0.7891916526582226,0.8064212470182404,0.8238936303385574,0.8416212335729143,0.8596173642419117,0.8778962950512289,0.8964733640019161,0.9153650878428138,0.93458929107348,0.9541652531461943,0.9741138770593092,0.994457883209753,1.0152220332170279,1.0364333894937898,1.0581216176847767,1.0803193408149558,1.1030625561995975,1.1263911290388007,1.1503493803760079,1.1749867920660904,1.200358858030859,1.2265281200366105,1.2535654384704504,1.2815515655446004,1.3105791121681285,1.3407550336902165,1.3722038089987263,1.4050715603096329,1.4395314709384563,1.475791028179171,1.514101887619284,1.5547735945968535,1.5981931399228175,1.6448536269514722,1.6953977102721358,1.7506860712521692,1.8119106729525973,1.8807936081512509,1.959963984540054,2.0537489106318225,2.17009037758456,2.3263478740408408,2.5758293035489004 };

	double a_t = (((a > 0.5) ? a : (1 - a)) - 0.5) * 200;

	double x = 表[int(a_t)] * (1 - a_t + int(a_t)) + 表[int(a_t) + 1] * (a_t - int(a_t));

	x = (a > 0.5) ? x : -x;

	return x;
}

double 订货批量(double 年需求量, double 订货成本, double 持有成本)
{
	return sqrt(2 * 订货成本 * 年需求量 / 持有成本);
}

double 补货点(double 年需求量, double 需求方差, double 提前期, double 提前期方差, double 服务水平)
{
	return 提前期 * 年需求量 + norm_quantile(服务水平) * sqrt(提前期 * 需求方差 + pow(年需求量, 2) * 提前期方差);
}

ground 场地设定(double 面积)
{
	ground 输出;
	while (true)
	{
		for (int i = 0; i < 20; i++)
		{
			int n = 0;
			while (true)
			{
				输出.site[i].origin = point((double(rand()) / RAND_MAX - 0.5) * sqrt(面积) * 1.4, (double(rand()) / RAND_MAX - 0.5) * sqrt(面积) * 1.4);
				输出.site.reset_seg(i);
				输出.site.reset_seg((i + 19) % 20);

				if (输出.site.legal())
				{
					break;
				}
				n++;

				if (n > 1000)
				{
					输出 = ground();
					n = 0;
					i = 0;
				}
			}
		}
		输出.site.simple(45);
		输出.site.reset_seg();

		double s = 输出.area();



		if (输出.site.legal() && (s > 面积))
		{
			break;
		}
	}
	输出.door[0] = rand() % 20;
	输出.door[1] = rand() % 20;

	return 输出;
}




