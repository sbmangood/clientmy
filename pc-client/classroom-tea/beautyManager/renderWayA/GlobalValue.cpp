#include "GlobalValue.h"
//待验证修改
#ifdef _DEBUG
#ifdef _WIN64
std::string g_fuDataDir = "assets/";
#else
std::string g_fuDataDir = "assets/";
#endif
#else
#ifdef _WIN64
std::string g_fuDataDir = "assets/";
#else
std::string g_fuDataDir = "assets/"; //相对路径
std::string g_fuDataDir_Absolute = ""; //绝对路径
#endif
#endif // _DEBUG


const std::string g_v3Data = "v3.bundle";
