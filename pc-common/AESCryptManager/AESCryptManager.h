#pragma once
#include <string>
using namespace std;

class AESCryptManager
{
public:
    AESCryptManager(const std::string& key, const std::string& iv = "RandomInitVector");
    ~AESCryptManager();

    string EncryptionAES(const string& strSrc); //AES����
    string DecryptionAES(const string& strSrc); //AES����

private:
    std::string m_key;
    std::string m_iv;//ECB MODE����Ҫ����chain������Ϊ��
};

