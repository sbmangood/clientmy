#pragma once
#include <string>
using namespace std;

class AESCryptManager
{
public:
	AESCryptManager();
	~AESCryptManager();

	string EncryptionAES(const string& strSrc); //AES����
	string DecryptionAES(const string& strSrc); //AES����

private:

};

