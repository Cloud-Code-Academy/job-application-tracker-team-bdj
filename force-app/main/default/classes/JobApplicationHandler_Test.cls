@IsTest
public with sharing class JobApplicationHandler_Test {

    // Updates for Merge
    @TestSetup
    static void createTestData(){
        List<Job_Application__c> jobAppList = new List<Job_Application__c>();
        
        for (Integer i = 0; i < 7; i++){
            jobAppList.add(new Job_Application__c(
                Name = 'Test ' + String.valueOf(i),
                Status__c = 'New',
                Position_Title__c = 'Test Dev ' + String.valueOf(i),
                Application_Date__c = System.today(),
                Salary__c = '115000',
                Location__c = 'Remote',
                Source_Id__c = 'SourceId_' + String.valueOf(i)
            ));
        }

        insert jobAppList;

    }

    @IsTest
    static void handler_afterUpdate_statusChanged(){
        
        // Query records and update statuses
        List<Job_Application__c> testJobApps = [
            SELECT Id, Status__c FROM Job_Application__c LIMIT 3
        ];

        testJobApps[0].Status__c = 'Saved';
        testJobApps[1].Status__c = 'Applying';
        testJobApps[2].Status__c = 'Applied';

        Test.startTest();
        update testJobApps;
        Test.stopTest();

        // Confirm that records were routed to the status update class by checking for created tasks
        List<Task> createdTasks = [SELECT Id, WhatId FROM Task WHERE WhatId IN :testJobApps];
        Assert.isTrue(!createdTasks.isEmpty(), 'Handler should pass records with updated status to a separate class were task records are created');

        // Confirm every updated record got tasks
        Set<Id> appsWithTasks = new Set<Id>();
        for (Task t : createdTasks) {
            appsWithTasks.add(t.WhatId);
        }

        for (Job_Application__c jobApp : testJobApps) {
            Assert.isTrue(appsWithTasks.contains(jobApp.Id), 'Every record with a changed status should have tasks: ' + jobApp.Id);
        }

    }

    @IsTest
    static void handler_afterUpdate_statusNotChanged(){

        // Query records and update a non-status field
        List<Job_Application__c> testJobApps = [
            SELECT Id, Status__c FROM Job_Application__c LIMIT 3
        ];

        for (Job_Application__c jobApp : testJobApps) {
            jobApp.Salary__c = '125000';
        }

        Test.startTest();
        update testJobApps;
        Test.stopTest();

        // Confirm that records were not routed to the status update class by returning an empty list of tasks
        List<Task> createdTasks = [SELECT Id FROM Task WHERE WhatId IN :testJobApps];
        Assert.areEqual(0, createdTasks.size(), 'Handler should not pass records to the service class when status has not changed');

    }

    @IsTest
    static void handler_afterUpdate_mixedRecords(){

        // Query records, update the status on half and a non-status field on the other half
        List<Job_Application__c> testJobApps = [
            SELECT Id, Status__c FROM Job_Application__c LIMIT 4
        ];

        testJobApps[0].Status__c = 'Saved';
        testJobApps[1].Status__c = 'Closed';
        testJobApps[2].Salary__c = '130000';
        testJobApps[3].Salary__c = '130000';

        Test.startTest();
        update testJobApps;
        Test.stopTest();

        List<Id> changedIds   = new List<Id>{ testJobApps[0].Id, testJobApps[1].Id };
        List<Id> unchangedIds = new List<Id>{ testJobApps[2].Id, testJobApps[3].Id };

        List<Task> statusChanged   = [SELECT Id FROM Task WHERE WhatId IN :changedIds];
        List<Task> statusUnchanged = [SELECT Id FROM Task WHERE WhatId IN :unchangedIds];

        Assert.isTrue(!statusChanged.isEmpty(),   'Records with a status change should have tasks created');
        Assert.areEqual(0, statusUnchanged.size(), 'Records without a status change should have no tasks created');

    }

}