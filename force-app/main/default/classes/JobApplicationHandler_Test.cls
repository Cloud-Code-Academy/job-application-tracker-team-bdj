/**
 * JobApplicationHandler_Test
 * Test class for JobApplicationHandler. Validates that status-based Task creation
 * works correctly across all 7 statuses (positive test) and confirms that
 * non-status field changes do not generate Tasks (negative test).
 * 
 * Uses @TestSetup to create shared test data once, which improves performance
 * and ensures each test method starts with the same baseline data.
 */
@IsTest
public with sharing class JobApplicationHandler_Test {

    /**
     * @TestSetup - Creates 50 Job Application records with Status = 'New'.
     * 50 records tests bulkification — ensures the handler doesn't hit governor
     * limits when processing records in bulk.
     * Status is set to 'New' because the validation rule requires it on insert.
     */
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
                Salary__c = 115000,
                Location__c = 'Remote'
                )
            );
        }

        insert jobAppList;
    }

    /**
     * Positive Test: Verifies that changing status to each of the 7 statuses
     * creates the correct number of Tasks for each.
     * 
     * Approach: Updates 7 records to 7 different statuses in a single DML call,
     * then uses an AggregateResult query to count Tasks per Job Application.
     * A Map<Id, Integer> allows efficient lookup of task counts by record Id.
     * 
     * Expected task counts: Saved=3, Applying=5, Applied=4, Interviewing=5,
     * Negotiating=3, Accepted=3, Closed=2
     */
    @IsTest
    public static void JobApplicationHandler_afterUpdate_happyPath() {
        // Query 7 test records to assign one to each status
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

        // Update all 7 records in a single DML to fire the trigger once (bulk test)
        Test.startTest();
        update testJobApps;
        Test.stopTest();

        // Use AggregateResult to count Tasks grouped by their parent Job Application.
        // This is more efficient than querying all Task records individually.
        List<AggregateResult> taskCounts = [
            SELECT WhatId, COUNT(Id) taskCount
            FROM Task
            WHERE WhatId IN :testJobApps
            GROUP BY WhatId
        ];

        // Build a Map of Job Application Id => Task count for easy assertion lookups.
        // This avoids looping through results for each assert statement.
        Map<Id, Integer> taskCountMap = new Map<Id, Integer>();

        // Populate the map from AggregateResult records
        for(AggregateResult ar : taskCounts){
            taskCountMap.put((Id)ar.get('WhatId'), (Integer)ar.get('taskCount'));
        }

        // Assert each status generated the expected number of Tasks.
        // Third parameter is a descriptive message for debugging failed assertions.
        System.assertEquals(3, taskCountMap.get(testJobApps[0].Id), 'Saved status should have 3 tasks');
        System.assertEquals(5, taskCountMap.get(testJobApps[1].Id), 'Applying status should have 5 tasks');
        System.assertEquals(4, taskCountMap.get(testJobApps[2].Id), 'Applied status should have 4 tasks');
        System.assertEquals(5, taskCountMap.get(testJobApps[3].Id), 'Interviewing status should have 5 tasks');
        System.assertEquals(3, taskCountMap.get(testJobApps[4].Id), 'Negotiating status should have 3 tasks');
        System.assertEquals(3, taskCountMap.get(testJobApps[5].Id), 'Accepted status should have 3 tasks');
        System.assertEquals(2, taskCountMap.get(testJobApps[6].Id), 'Closed status should have 2 tasks');
        
    }

    /**
     * Negative Test: Verifies that updating non-status fields (e.g., Salary)
     * does NOT create any Tasks. This tests the early-exit logic in afterUpdate()
     * where statusesChanged == false triggers a return.
     */
    @IsTest
    public static void JobApplicationHandler_afterUpdate_NoStatusChange() {
        // Query records and change only the Salary field (not Status)
        List<Job_Application__c> testJobApps = [
            SELECT Id, Status__c FROM Job_Application__c LIMIT 5
        ];

        for(Job_Application__c jobApp : testJobApps) {
            jobApp.Salary__c = 120000;
        }

        // Update records — only Salary changed, Status unchanged
        Test.startTest();
        update testJobApps;
        Test.stopTest();

        // Verify no Tasks were created since Status didn't change
        List<Task> createdTasks = [SELECT Id FROM Task WHERE WhatId IN :testJobApps];

        // Assert zero Tasks — confirms the handler correctly exits early
        System.assertEquals(0, createdTasks.size(), 'No tasks should be created when status has not changed');
    }
}