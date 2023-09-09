#pragma once

void TestGetServiceStausUsingAssertions();
void ServiceStatusTest();
void StopServiceTestError();
void StopServiceAlreadyStoppedReturnsFalse();
void StopInvalidServiceGivesNoErrorTest();
void StartServiceTest();
void StartServiceALreadyRunningReturnsFalse();
void PauseServiceTest();
void PauseServiceNotPausibleGivesFalse();
void PauseNonExistantService();
void ResumeServiceTest();
void TestServiceInstall();
void  TestUninstallService();
void TestChangeServiceDescription();
void TestSetDelayAutoStart();
void TestChangeServiceStartupType();