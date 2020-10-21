#pragma once
#include <string>
using namespace std;

class AESCryptManager
{
public:
    AESCryptManager(const std::string& key, const std::string& iv = "RandomInitVector");
    ~AESCryptManager();

    string EncryptionAES(const string& strSrc); //AES加密
    string DecryptionAES(const string& strSrc); //AES解密

private:
    std::string m_key;
    std::string m_iv;//ECB MODE不需要关心chain，可以为空
};

