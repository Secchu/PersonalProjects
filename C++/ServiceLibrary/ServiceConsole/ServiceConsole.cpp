// ServiceConsole.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include "ServiceTest.h"
using namespace std;


int main()
{
    ServiceStatusTest();
    TestGetServiceStausUsingAssertions();
    StopServiceTestError();
    StopServiceAlreadyStoppedReturnsFalse();
    StopInvalidServiceGivesNoErrorTest();
    TestChangeServiceStartupType();

}


