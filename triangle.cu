//#include "geometry.cuh"
//
//#define _USE_MATH_DEFINES 
//#include <math.h>
//
//__host__ __device__ triangle::triangle()
//{
//	segs[0].origin = point(0, 0);
//	segs[0].dir = vector(point(1, 0));
//	segs[0].dist = 1;
//	segs[1].origin = point(1, 0);
//	segs[1].dir = vector(point(-M_SQRT1_2, M_SQRT1_2));
//	segs[1].dist = M_SQRT2;
//	segs[2].origin = point(0, 1);
//	segs[2].dir = vector(point(0, -1));
//	segs[2].dist = 1;
//}
//
//__host__ __device__ triangle::triangle(point* ��)
//{
//	segs[0] = seg(��[0], ��[1]);
//	segs[1] = seg(��[1], ��[2]);
//	segs[2] = seg(��[2], ��[0]);
//}
//
//__host__ __device__ triangle::triangle(seg* �߶�)
//{
//	segs[0] = �߶�[0];
//	segs[1] = �߶�[1];
//	segs[2] = �߶�[2];
//}
