#include <iostream>
#include "ServiceLib.h"

using namespace std;

void TestGetServiceStausUsingAssertions()
{
    SERVICE_STATUS status{};
    int error = 0;

    bool zeroSuccess = GetServiceStatus(L"MySQL80", &status, &error);

    ASSERT(!zeroSuccess);

    if (zeroSuccess)
    {
        cout << "Successful call to function" << endl;
        cout << "State: " << status.dwCurrentState << endl;
        cout << "Service Type: " << status.dwServiceType << endl;
        cout << "Exit Code: " << status.dwWin32ExitCode << endl;
        cout << "Check Point: " << status.dwCheckPoint << endl;
        cout << " Controls Accepted" << status.dwControlsAccepted << endl;
        cout << "Wait Hint" << status.dwWaitHint << endl;

        ASSERT(status.dwCurrentState == SERVICE_STOPPED);
        ASSERT(status.dwServiceType == SERVICE_WIN32_OWN_PROCESS);

        cout << "TestGetServiceStausUsingAssertions passed" << endl;
    }
    else
    {
        cout << "Something went wrong" << endl;
        cout << "The error code returned by the function is " << error << endl;

    }
}

void ServiceStatusTest()
{
    int lastError = 0;
    int rtn = GetServiceState(L"MySQL80", &lastError);

    ASSERT(rtn == SERVICE_STOPPED);

    int shouldNotSucceed = GetServiceState(L"NonExistant", &lastError);

    ASSERT(shouldNotSucceed == UNSUCESSFUL_QUERY);
    ASSERT(lastError == 1060);

    cout << "ServiceStatusTest passed" << endl;

}

void StopServiceTestError()
{
    int errors = 0;
    DWORD status = GetServiceState(L"MYSQL80", &errors);

    ASSERT(status == SERVICE_RUNNING);

    bool success = StopServiceAndWait(L"MYSQL80", &errors);

    ASSERT(success);

    status = GetServiceState(L"MYSQL80", &errors);

    ASSERT(status == SERVICE_STOPPED);

    cout << "StopServiceTestError passed" << endl;
}

void StopServiceAlreadyStoppedReturnsFalse()
{
    int errors = 0;

    DWORD status = GetServiceState(L"MYSQL80", &errors);

    ASSERT(status == SERVICE_STOPPED);

    bool success = StopServiceAndWait(L"MYSQL80", &errors);
    ASSERT(!success);

    status = GetServiceState(L"MYSQL80", &errors);
    ASSERT(status == SERVICE_STOPPED);

    cout << "StopServiceAlreadyStoppedReturnsFalse passed" << endl;
}

void StopInvalidServiceGivesNoErrorTest()
{
    int error = 0;
    bool success = StopServiceAndWait(L"DoesNotExist.exe", &error);

    ASSERT(!success);

    ASSERT(error == ERROR_SERVICE_DOES_NOT_EXIST);

    cout << "StopInvalidServiceGivesNoErrorTest passed" << endl;
}

void StartServiceTest()
{
    int error = 0;
    DWORD status = GetServiceState(L"MySQL80", &error);

    ASSERT(status == SERVICE_STOPPED);

    bool success = StartServiceAndWait(L"MYSQL80", &error);

    ASSERT(success == true);

    ASSERT(GetServiceState(L"MySQL80", &error) == SERVICE_RUNNING);

    cout << "StartServiceTest passed" << endl;
}

void StartServiceALreadyRunningReturnsFalse()
{

    int error = 0;
    DWORD status = GetServiceState(L"MySQL80", &error);

    if (status == SERVICE_RUNNING)
        cout << "Initial service is running. Test is ok so far";

    else
    {
        cout << "Test failed. Service not running" << endl;
        return;
    }

    bool success = StartServiceAndWait(L"MYSQL80", &error);

    if (success)
    {
        cout << "Function returned true when expected is failed. test failed" << endl;
        return;
    }

    cout << "StartServiceALreadyRunningReturnsFalse passed" << endl;
}

void PauseServiceTest()
{
    int error = 0;
    DWORD status = GetServiceState(L"ftpsvc", &error);

    ASSERT(status == SERVICE_RUNNING);

    bool success = PauseServiceAndWait(L"ftpsvc", &error);

    ASSERT(success == true);

    ASSERT(GetServiceState(L"ftpsvc", &error) == SERVICE_PAUSED);

    cout << "PauseServiceTest test passed" << endl;
}

void PauseServiceNotPausibleGivesFalse()
{
    int error = 0;
    DWORD status = GetServiceState(L"MYSQL80", &error);

    ASSERT(status == SERVICE_RUNNING);

    bool success = PauseServiceAndWait(L"MYSQL80", &error);

    ASSERT(!success);


    cout << "PauseServiceNotPausibleGivesFalse test passed" << endl;
}

void PauseNonExistantService()
{
    int error;
    bool success = PauseServiceAndWait(L"rrrrr", &error);

    ASSERT(!success);
    ASSERT(error == ERROR_SERVICE_DOES_NOT_EXIST);

    cout << "PauseNonExistantService Test passed" << endl;
}

void ResumeServiceTest()
{
    int error = 0;
    DWORD status = GetServiceState(L"ftpsvc", &error);

    ASSERT(status == SERVICE_PAUSED);

    bool success = ResumeServiceAndWait(L"ftpsvc", &error);

    ASSERT(success == true);

    ASSERT(GetServiceState(L"ftpsvc", &error) == SERVICE_RUNNING);

    cout << "ResumeServiceTest test passed" << endl;
}

void TestServiceInstall()
{
    int error = 0;
    bool success = InstallService(L"NancyChartService", L"Demo Service", SERVICE_AUTO_START, 
    L"C:\\Users\\chu\\Source\\Repos\\NancyChart\\NancyChartService\\NancyChartService\\bin\\Release\\NancyChartService.exe", NULL
    , NULL, &error);

    if (success)
        cout << "Successful" << endl;
    else
        cout << "Error" << endl;
}

void  TestUninstallService()
{
    int error;
    bool success = UninstallService(L"NancyChartService", &error);

    ASSERT(success);
}

void TestChangeServiceDescription()
{
    int error = 0;
    bool success = ChangeServiceDescription(L"NancyChartService", (LPWSTR)L"This is a demo service", &error);

    ASSERT(success);
    cout << "TestChangeServiceDescription passed" << endl;
}

void TestSetDelayAutoStart()
{
    int error = 0;
    bool val = SetDelayAutoStart(L"NancyChartService", TRUE, &error);
    
    ASSERT(val);
    cout << "TestSetDelayAutoStart" << endl;
}

void TestChangeServiceStartupType()
{
    int error = 0;
    bool val = ChangeBootStart(L"NancyChartService", SERVICE_DEMAND_START, &error);

    ASSERT(val);
    cout << "TestChangeServiceStartupType passed" << endl;
}