// ServiceLibrary.cpp : Defines the functions for the static library.
//

#include "framework.h"
#include "ServiceLib.h"
#include "HandleTraits.h"
#include <stdio.h>


struct ConnectionHandleTraits : HandleTraits<SC_HANDLE>
{
	static void Close(Type value) noexcept
	{
		if(value)
			CloseServiceHandle(value);
	}
};

using AutomaticHandlerCloser = Handle<ConnectionHandleTraits>;

SC_HANDLE OpenServiceDatabase(DWORD AccessRight)
{
	SC_HANDLE DbHandle = OpenSCManager(NULL, NULL, AccessRight);

	
	return DbHandle;
}

SC_HANDLE OpenServiceHandle(SC_HANDLE DbHandle, LPCWSTR serviceName , DWORD AccessRight)
{
	SC_HANDLE service = OpenServiceW(DbHandle, serviceName, AccessRight);

	return service;
}

bool __declspec(dllexport) GetServiceStatus(LPCWSTR serviceName, LPSERVICE_STATUS serviceStatus, int* lastError)
{	
	try
	{
		SC_HANDLE DbHandle = OpenServiceDatabase(SC_MANAGER_CONNECT);

		if (DbHandle == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceDb(DbHandle);

		SC_HANDLE service = OpenServiceHandle(serviceDb.Get(), serviceName, SERVICE_QUERY_STATUS);

		if (service == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceHandle(service);

		if(!QueryServiceStatus(serviceHandle.Get(), serviceStatus))
			throw ServiceException();

		return true;
	}
	catch (const ServiceException& se)
	{
		*lastError = se.LastError;
		
		return false;
	}

}

int __declspec(dllexport) GetServiceState(LPCWSTR serviceName, int* lastError)
{
	try
	{
		SC_HANDLE DbHandle = OpenServiceDatabase(SC_MANAGER_CONNECT);

		if (DbHandle == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceDb(DbHandle);

		SC_HANDLE service = OpenServiceHandle(serviceDb.Get(), serviceName, SERVICE_QUERY_STATUS);

		if (service == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceHandle(service);

		SERVICE_STATUS status{};

		if (!QueryServiceStatus(serviceHandle.Get(), &status))
			throw ServiceException();

		return status.dwCurrentState;
	}
	catch (const ServiceException& se)
	{
		*lastError = se.LastError;

		return UNSUCESSFUL_QUERY;
	}

}

bool WaitForStatusChange(SC_HANDLE service, DWORD desiredStatus, int *lastError)
{
	SERVICE_STATUS_PROCESS ssp;
	DWORD dwStartTime = GetTickCount64();
	DWORD dwBytesNeeded;
	DWORD dwTimeout = 30000; // 30-second time-out
	DWORD dwWaitTime;

	if (QueryServiceStatusEx(service, SC_STATUS_PROCESS_INFO, (LPBYTE)&ssp, 
		sizeof(SERVICE_STATUS_PROCESS), &dwBytesNeeded) == UNSUCESSFUL_QUERY)
	{
		*lastError = GetLastError();
		return false;
	}

	if (ssp.dwCurrentState == desiredStatus)
		return true;

	dwWaitTime = ssp.dwWaitHint / 10;

	if (dwWaitTime < 1000)
		dwWaitTime = 1000;
	else if (dwWaitTime > 10000)
		dwWaitTime = 10000;

	Sleep(dwWaitTime);

	if (QueryServiceStatusEx(service, SC_STATUS_PROCESS_INFO, (LPBYTE)&ssp,
		sizeof(SERVICE_STATUS_PROCESS),&dwBytesNeeded) == UNSUCESSFUL_QUERY)
	{
		*lastError = GetLastError();

		return false;
	}

	return ssp.dwCurrentState == desiredStatus;
}

bool __declspec(dllexport) StopServiceAndWait(LPCWSTR serviceName, int* lastError)
{
	try
	{
		SC_HANDLE DbHandle = OpenServiceDatabase(SC_MANAGER_CONNECT);

		if (DbHandle == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceDb(DbHandle);

		SC_HANDLE service = OpenServiceHandle(serviceDb.Get(), serviceName, SERVICE_QUERY_STATUS | SERVICE_STOP);

		if (service == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceHandle(service);

		SERVICE_STATUS serviceStatus{};

		bool success = ControlService(serviceHandle.Get(), SERVICE_CONTROL_STOP, &serviceStatus);

		if (success == ERROR_SENDING_CONTROL)
			throw ServiceException();

		success = WaitForStatusChange(serviceHandle.Get(), SERVICE_STOPPED, lastError);

		if (!success)
			throw ServiceException();

		return true;
	}
	catch (const ServiceException& se)
	{
		*lastError = se.LastError;
		return false;
	}

}

bool _declspec(dllexport) StartServiceAndWait(LPCWSTR serviceName, int* lastError)
{
	try
	{
		SC_HANDLE DbHandle = OpenServiceDatabase(SC_MANAGER_CONNECT);

		if (DbHandle == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceDb(DbHandle);

		SC_HANDLE service = OpenServiceHandle(serviceDb.Get(), serviceName, 
	    SERVICE_QUERY_STATUS | SERVICE_START);

		if (service == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceHandle(service);

		SERVICE_STATUS serviceStatus{};

		bool success = StartService(serviceHandle.Get(), ZERO_SERVICE_ARGS, NO_SERVICE_MAIN_ARGS);

		if (success == ERROR_STARTING_SERVICE)
			throw ServiceException();


		success = WaitForStatusChange(serviceHandle.Get(), SERVICE_RUNNING, lastError);

		if (!success)
			throw ServiceException();

		return true;
	}
	catch (const ServiceException& se)
	{
		*lastError = se.LastError;
		return false;
	}
}

bool _declspec(dllexport) PauseServiceAndWait(LPCWSTR serviceName, int* lastError)
{
	try
	{
		SC_HANDLE DbHandle = OpenServiceDatabase(SC_MANAGER_CONNECT);

		if (DbHandle == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceDb(DbHandle);

		SC_HANDLE service = OpenServiceHandle(serviceDb.Get(), serviceName,
			SERVICE_QUERY_STATUS | SERVICE_PAUSE_CONTINUE);

		if (service == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceHandle(service);

		SERVICE_STATUS serviceStatus{};
		
		bool success = ControlService(serviceHandle.Get(), SERVICE_CONTROL_PAUSE, &serviceStatus);

		if (success == ERROR_SENDING_CONTROL)
			throw ServiceException();

		success = WaitForStatusChange(serviceHandle.Get(), SERVICE_PAUSED, lastError);

		if (!success)
			throw ServiceException();

		return true;
	}
	catch (const ServiceException& se)
	{
		*lastError = se.LastError;
		return false;
	}
}

bool _declspec(dllexport) ResumeServiceAndWait(LPCWSTR serviceName, int* lastError)
{
	try
	{
		SC_HANDLE DbHandle = OpenServiceDatabase(SC_MANAGER_CONNECT);

		if (DbHandle == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceDb(DbHandle);

		SC_HANDLE service = OpenServiceHandle(serviceDb.Get(), serviceName,
			SERVICE_QUERY_STATUS | SERVICE_PAUSE_CONTINUE);

		if (service == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceHandle(service);

		SERVICE_STATUS serviceStatus{};

		bool success = ControlService(serviceHandle.Get(), SERVICE_CONTROL_CONTINUE, &serviceStatus);

		if (success == ERROR_SENDING_CONTROL)
			throw ServiceException();

		success = WaitForStatusChange(serviceHandle.Get(), SERVICE_RUNNING, lastError);

		if (!success)
			throw ServiceException();

		return true;
	}
	catch (const ServiceException& se)
	{
		*lastError = se.LastError;
		return false;
	}
}

bool _declspec(dllexport) InstallService(LPCWSTR serviceName, LPCWSTR displayName, DWORD dwStartType,
	LPCWSTR binaryPath, LPCWSTR AccName, LPCWSTR pwd, int* errorCode)
{
	try
	{
		SC_HANDLE DbHandle = OpenServiceDatabase(SC_MANAGER_ALL_ACCESS);

		if (DbHandle == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceDb(DbHandle);

		SC_HANDLE service = CreateService(serviceDb.Get(), serviceName, displayName, SC_MANAGER_ALL_ACCESS,
			SERVICE_WIN32_OWN_PROCESS, dwStartType, SERVICE_ERROR_NORMAL, binaryPath, NULL, NULL,
			NULL, AccName, pwd);

		if (service == PROBLEM_CREATING_SERVICE)
			throw ServiceException();

		AutomaticHandlerCloser serviceHandle(service);

		BOOL installSuccess = StartService(serviceHandle.Get(), ZERO_SERVICE_ARGS, NO_SERVICE_MAIN_ARGS);

		if (!installSuccess)
			throw ServiceException();

		return true;
	}
	catch (const ServiceException& se)
	{
		*errorCode = se.LastError;
		return false;
	}
}

bool _declspec(dllexport) UninstallService(LPCWSTR serviceName, int* lastError)
{
	try
	{
		SC_HANDLE DbHandle = OpenServiceDatabase(SC_MANAGER_ALL_ACCESS);

		if (DbHandle == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceDb(DbHandle);

		SC_HANDLE service = OpenServiceHandle(serviceDb.Get(), serviceName,
			SC_MANAGER_ALL_ACCESS);

		if (service == PROBLEM_OPENING_HANDLE)
			throw ServiceException();

		AutomaticHandlerCloser serviceHandle(service);

		if(!DeleteService(serviceHandle.Get()))
			throw ServiceException();

		return true;
		
	}
	catch (const ServiceException& se)
	{
		*lastError = se.LastError;

		return false;
	}
}

bool _declspec(dllexport) ChangeServiceDescription(LPCWSTR szSvcName, LPCWSTR description, int* lastError)
{
	try
	{
		SC_HANDLE schSCManager;
		SC_HANDLE schService;
		SERVICE_DESCRIPTION sd;
		LPCWSTR szDesc = description;

		// Get a handle to the SCM database. 

		schSCManager = OpenSCManager(NULL, NULL, SC_MANAGER_ALL_ACCESS);

		if (NULL == schSCManager)
		{

			return false;
		}

		AutomaticHandlerCloser serviceDb(schSCManager);
		// Get a handle to the service.

		schService = OpenService(
			schSCManager,            // SCM database 
			szSvcName,               // name of service 
			SERVICE_CHANGE_CONFIG);  // need change config access 

		if (schService == NULL)
			throw ServiceException();

		AutomaticHandlerCloser service(schService);

		// Change the service description.

		sd.lpDescription = (LPWSTR)szDesc;

		if (!ChangeServiceConfig2(service.Get(), SERVICE_CONFIG_DESCRIPTION, &sd))
			throw ServiceException();

		return true;
	}
	catch (const ServiceException& se)
	{
		*lastError = se.LastError;
		return false;
	}




}

bool _declspec(dllexport) SetDelayAutoStart(LPCWSTR szSvcName, BOOL delayStart, int* lastError)
{
	try
	{
		SC_HANDLE schSCManager;
		SC_HANDLE schService;
		SERVICE_DELAYED_AUTO_START_INFO delay;
		
		delay.fDelayedAutostart = delayStart;

		// Get a handle to the SCM database. 

		schSCManager = OpenSCManager(NULL, NULL, SC_MANAGER_ALL_ACCESS);

		if (NULL == schSCManager)
		{

			return false;
		}

		AutomaticHandlerCloser serviceDb(schSCManager);
		// Get a handle to the service.

		schService = OpenService(
			schSCManager,            // SCM database 
			szSvcName,               // name of service 
			SERVICE_CHANGE_CONFIG);  // need change config access 

		if (schService == NULL)
			throw ServiceException();

		AutomaticHandlerCloser service(schService);

		// Change the service description.

		

		if (!ChangeServiceConfig2(service.Get(), SERVICE_CONFIG_DELAYED_AUTO_START_INFO, &delay))
			throw ServiceException();

		return true;
	}
	catch (const ServiceException& se)
	{
		*lastError = se.LastError;
		return false;
	}

}

bool _declspec(dllexport) ChangeBootStart(LPCWSTR szSvcName, DWORD dwStartType, int* lastError)
{
	try
	{
		SC_HANDLE schSCManager;
		SC_HANDLE schService;


		// Get a handle to the SCM database. 

		schSCManager = OpenSCManager(NULL, NULL, SC_MANAGER_ALL_ACCESS);

		if (NULL == schSCManager)
		{

			return false;
		}

		AutomaticHandlerCloser serviceDb(schSCManager);
		// Get a handle to the service.

		schService = OpenService(
			schSCManager,            // SCM database 
			szSvcName,               // name of service 
			SERVICE_CHANGE_CONFIG);  // need change config access 

		if (schService == NULL)
			throw ServiceException();

		AutomaticHandlerCloser service(schService);

		// Change the service description.

		BOOL success = ChangeServiceConfig(service.Get(), SERVICE_NO_CHANGE, dwStartType, SERVICE_NO_CHANGE,
			NULL, NULL, NULL, NULL, NULL, NULL, NULL);

		return success;
		

	}
	catch (const ServiceException& se)
	{
		*lastError = se.LastError;
		return false;
	}




}




