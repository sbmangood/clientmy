#include "AESCryptManager.h"
#include "AES.h"
#include "Base64.h"
#include <iostream>

AESCryptManager::AESCryptManager(const std::string& key, const std::string& iv)
{
    m_key = key;
    m_iv = iv;
}

AESCryptManager::~AESCryptManager()
{
}

string AESCryptManager::EncryptionAES(const string& strSrc) //AES����
{
    size_t length = strSrc.length();
    int block_num = length / BLOCK_SIZE + 1;
    //����
    char* szDataIn = new char[block_num * BLOCK_SIZE + 1];
    memset(szDataIn, 0x00, block_num * BLOCK_SIZE + 1);
    strcpy(szDataIn, strSrc.c_str());

    //����PKCS7Padding��䡣
    int k = length % BLOCK_SIZE;
    int j = length / BLOCK_SIZE;
    int padding = BLOCK_SIZE - k;
    for (int i = 0; i < padding; i++)
    {
        szDataIn[j * BLOCK_SIZE + k + i] = padding;
    }
    szDataIn[block_num * BLOCK_SIZE] = '\0';

    //���ܺ������
    char *szDataOut = new char[block_num * BLOCK_SIZE + 1];
    memset(szDataOut, 0, block_num * BLOCK_SIZE + 1);

    //���н���AES��CBCģʽ����
    AES aes;
    aes.MakeKey(m_key.c_str(), m_iv.c_str(), 16, 16);
    aes.Encrypt(szDataIn, szDataOut, block_num * BLOCK_SIZE, AES::CBC);
    string str = base64_encode((unsigned char*)szDataOut,
                               block_num * BLOCK_SIZE);
    delete[] szDataIn;
    delete[] szDataOut;
    return str;
}

string AESCryptManager::DecryptionAES(const string& strSrc) //AES����
{
    string strData = base64_decode(strSrc);
    size_t length = strData.length();
    //����
    char *szDataIn = new char[length + 1];
    memcpy(szDataIn, strData.c_str(), length + 1);
    //����
    char *szDataOut = new char[length + 1];
    memcpy(szDataOut, strData.c_str(), length + 1);

    //����AES��CBCģʽ����
    AES aes;
    aes.MakeKey(m_key.c_str(), m_iv.c_str(), 16, 16);
    aes.Decrypt(szDataIn, szDataOut, length, AES::CBC);

    //ȥPKCS7Padding���
    if (0x00 < szDataOut[length - 1] <= 0x16)
    {
        int tmp = szDataOut[length - 1];
        for (int i = length - 1; i >= length - tmp; i--)
        {
            if (szDataOut[i] != tmp)
            {
                memset(szDataOut, 0, length);
                cout << "ȥ���ʧ�ܣ����ܳ�������" << endl;
                break;
            }
            else
                szDataOut[i] = 0;
        }
    }
    string strDest(szDataOut);
    delete[] szDataIn;
    delete[] szDataOut;
    return strDest;
}