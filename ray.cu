#include "geometry.cuh"

__host__ __device__ ray::ray() :line() {}

__host__ __device__ ray::ray(point 点, vector 向量) :line(点, 向量) {}

__host__ __device__ ray::ray(point 点, double 角度, bool rad) :line(点, 角度, rad) {}

__host__ __device__ ray::ray(double 点_1_x, double 点_1_y, double 点_2_x, double 点_2_y) :line(点_1_x, 点_1_y, 点_2_x, 点_2_y) {}

__host__ __device__ ray::ray(point 点_1, point 点_2) :line(点_1, 点_2) {}

