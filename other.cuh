#pragma once

#include <cmath>

double norm_quantile(double a);

double 订货批量(double 年需求量, double 订货成本, double 持有成本);

double 补货点(double 年需求量, double 需求方差, double 提前期, double 提前期方差, double 服务水平);

