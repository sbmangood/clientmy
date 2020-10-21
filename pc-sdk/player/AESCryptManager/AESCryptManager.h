#pragma once
#include <string>
using namespace std;

class AESCryptManager
{
public:
	AESCryptManager();
	~AESCryptManager();

	string EncryptionAES(const string& strSrc); //AESº”√‹
	string DecryptionAES(const string& strSrc); //AESΩ‚√‹

private:

};

