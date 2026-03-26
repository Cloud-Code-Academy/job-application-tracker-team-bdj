@IsTest

public with sharing class jobAppStatusUpdates_Test {
    @TestSetup

    static void createTestData(){
        // create with bulkification in mind, if needed
        List<Job_Application__c> jobAppList = new List<Job_Application__c>();
        for(Integer i = 0; i < 50; i++){
            jobAppList.add(new Job_Application__c(
                Name = 'Test ' + String.valueOf(i),
                Status__c = 'New',
                Position_Title__c = 'Test Dev ' + String.valueOf(i),
                Application_Date__c = System.today(),
                Salary__c = '115000',
                Location__c = 'Remote',
                Source_Id__c = 'SourceId_' + String.valueOf(i)
                )
            );
        }

        insert jobAppList;
    }

    @IsTest
    public static void jobAppStatusUpdates_afterUpdate_statusChange() {
        // Query and Edit Test Data
        List<Job_Application__c> testJobApps = [
            SELECT Id, Status__c 
            FROM Job_Application__c 
            ORDER BY CreatedDate ASC 
            LIMIT 7];

        testJobApps[0].Status__c = 'Saved';
        testJobApps[1].Status__c = 'Applying';
        testJobApps[2].Status__c = 'Applied';
        testJobApps[3].Status__c = 'Interviewing';
        testJobApps[4].Status__c = 'Negotiating';
        testJobApps[5].Status__c = 'Accepted';
        testJobApps[6].Status__c = 'Closed';

        // Test
        Test.startTest();
        update testJobApps;
        Test.stopTest();

        // Query count of tasks created based on Job App Id
        List<AggregateResult> taskCounts = [
            SELECT WhatId, COUNT(Id) taskCount
            FROM Task
            WHERE WhatId IN :testJobApps
            GROUP BY WhatId
        ];

        // Instantiate Map to associate Id and taskCounts
        Map<Id, Integer> taskCountMap = new Map<Id, Integer>();

        // Loop through Aggregate Results to build Map
        for(AggregateResult ar : taskCounts){
            taskCountMap.put((Id)ar.get('WhatId'), (Integer)ar.get('taskCount'));
        }

        // Assert correct number of tasks created based on Status
        Assert.areEqual(3, taskCountMap.get(testJobApps[0].Id), 'Saved status should have 3 tasks');
        Assert.areEqual(5, taskCountMap.get(testJobApps[1].Id), 'Applying status should have 5 tasks');
        Assert.areEqual(4, taskCountMap.get(testJobApps[2].Id), 'Applied status should have 4 tasks');
        Assert.areEqual(5, taskCountMap.get(testJobApps[3].Id), 'Interviewing status should have 5 tasks');
        Assert.areEqual(3, taskCountMap.get(testJobApps[4].Id), 'Negotiating status should have 3 tasks');
        Assert.areEqual(3, taskCountMap.get(testJobApps[5].Id), 'Accepted status should have 3 tasks');
        Assert.areEqual(2, taskCountMap.get(testJobApps[6].Id), 'Closed status should have 2 tasks');
        
    }

    @IsTest
    public static void jobAppStatusUpdates_afterUpdate_noStatusChange() {
        // Query and Edit Test Data
        List<Job_Application__c> testJobApps = [
            SELECT Id, Status__c FROM Job_Application__c LIMIT 5
        ];

        for(Job_Application__c jobApp : testJobApps) {
            jobApp.Salary__c = '120000 - 14000';
        }

        // Test
        Test.startTest();
        update testJobApps;
        Test.stopTest();

        // Query to find any created Tasks
        List<Task> createdTasks = [SELECT Id FROM Task WHERE WhatId IN :testJobApps];

        // Assert to confirm empty list
        Assert.areEqual(0, createdTasks.size(), 'No tasks should be created when status has not changed');
    }


}