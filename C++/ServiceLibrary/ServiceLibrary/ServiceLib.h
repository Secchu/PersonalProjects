#pragma once
#include <Windows.h>

#ifdef _DEBUG 
#include <crtdbg.h>
#define ASSERT _ASSERTE
#else
#define ASSERT _noop
#endif

#define UNSUCESSFUL_QUERY 0
#define PROBLEM_OPENING_HANDLE NULL
#define PROBLEM_CREATING_SERVICE NULL
#define ERROR_SENDING_CONTROL 0
#define ZERO_SERVICE_ARGS NULL
#define NO_SERVICE_MAIN_ARGS NULL
#define ERROR_STARTING_SERVICE 0

extern "C" __declspec(dllexport) bool GetServiceStatus(LPCWSTR serviceName, LPSERVICE_STATUS serviceStatus, int *lastError);

extern "C" __declspec(dllexport) int GetServiceState(LPCWSTR serviceName, int* lastError);

extern "C" __declspec(dllexport) bool StopServiceAndWait(LPCWSTR serviceName, int* lastError);

extern "C" _declspec(dllexport) bool StartServiceAndWait(LPCWSTR serviceName, int* lastError);

extern "C" _declspec(dllexport) bool PauseServiceAndWait(LPCWSTR serviceName, int* lastError);

extern "C" _declspec(dllexport) bool ResumeServiceAndWait(LPCWSTR serviceName, int* lastError);

extern "C" _declspec(dllexport) bool InstallService(LPCWSTR serviceName, LPCWSTR displayName, DWORD dwStartType,
 LPCWSTR binaryPath, LPCWSTR AccName, LPCWSTR pwd, int* errorCode);

extern "C" _declspec(dllexport) bool UninstallService(LPCWSTR serviceName, int* lastError);

extern "C" _declspec(dllexport) bool ChangeServiceDescription(LPCWSTR szSvcName, LPCWSTR description, int* lastError);

extern "C" _declspec(dllexport) bool SetDelayAutoStart(LPCWSTR szSvcName, BOOL delayStart, int* lastError);

extern "C" _declspec(dllexport) bool ChangeBootStart(LPCWSTR szSvcName, DWORD dwStartType, int* lastError);

struct ServiceException
{
    DWORD LastError;
    explicit ServiceException()
    {
        LastError = GetLastError();
    }

};