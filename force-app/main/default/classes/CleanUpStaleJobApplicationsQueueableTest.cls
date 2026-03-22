/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CleanUpStaleJobApplicationsQueueableTest {

    @isTest
    static void testCleanUpStaleJobs() {
        // TO DO: implement unit test

        // Set and old date and a new date for follow up
        Date oldDate = Date.today().addDays(-31);
        Date newDate = Date.today().addDays(-10);

        // Create Job Applications with test data
        List<Job_Application__c> jobAppList = new List<Job_Application__c>{
            new Job_Application__c(
                Name = 'Old Test',
                Status__c = 'New',
                Position_Title__c = 'Test Dev',
                Application_Date__c = oldDate,
                Salary__c = '115000',
                Location__c = 'Remote',
                Notes__c = 'Old Application',
                Source_Id__c = 'TriggerSourceId',
                Follow_Up_Date__c = oldDate
                ),
            new Job_Application__c(
                Name = 'New Test',
                Status__c = 'New',
                Position_Title__c = 'Test Jr Dev',
                Application_Date__c = newDate,
                Salary__c = '115000',
                Location__c = 'Remote',
                Notes__c = 'New Application',
                Source_Id__c = 'TriggerSourceId',
                Follow_Up_Date__c = newDate
            ),
            new Job_Application__c(
                Name = 'Accepted Test',
                Status__c = 'New',
                Position_Title__c = 'Test Developer',
                Application_Date__c = oldDate,
                Salary__c = '115000',
                Location__c = 'Remote',
                Notes__c = 'Accepted Application',
                Source_Id__c = 'TriggerSourceId',
                Follow_Up_Date__c = oldDate
            )
          };

          // Insert list of test job applications
          insert jobAppList;

          // Set the status after insert to account for validation rule
          for (Job_Application__c jobApp : jobAppList) {
            if (jobApp.Name ==  'Old Test') {
                jobApp.Status__c = 'Closed';
            }

            if (jobApp.Name ==  'Accepted Test') {
                jobApp.Status__c = 'Accepted';
            }
          }
          
        Test.startTest();
        // Call the queueable class
        System.enqueueJob(new CleanUpStaleJobApplicationsQueueable());
        Test.stopTest();

        // Query for the results and place them in a map with the name as the key
        Map<String, Job_Application__c> results = new Map<String, Job_Application__c>();
            for (Job_Application__c jobMap : [
            SELECT Name, Status__c, Notes__c, Follow_Up_Date__c
            FROM Job_Application__c]) {
                results.put(jobMap.Name, jobMap);
            }
        
        // Old record should be closed
        System.assertEquals('Closed', results.get('Old Test').Status__c);
        System.assert(results.get('Old Test').Notes__c.contains('This job application has been closed by an automated process.'));
        
        // New record should not be closed
        System.assertNotEquals('Closed', results.get('New Test').Status__c);
          
        // Accepted should remain accepted
        System.assertEquals('Accepted', results.get('Accepted Test').Status__c);
    }
}