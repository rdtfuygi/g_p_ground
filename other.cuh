#pragma once
#ifndef ground_
#define ground_
#include "ground.cuh"
#endif

#include <cmath>

float norm_quantile(float a);

float 订货批量(float 年需求量, float 订货成本, float 持有成本);

float 补货点(float 年需求量, float 需求方差, float 提前期, float 提前期方差, float 服务水平);

ground 场地设定(float 面积);

