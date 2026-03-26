@isTest
public class JobApplicationTrigger_Test {

    @TestSetup
    static void createTestData(){
        List<Job_Application__c> jobAppList = new List<Job_Application__c>();
        for(Integer i = 0; i < 50; i++){
            jobAppList.add(new Job_Application__c(
                Name = 'Test ' + String.valueOf(i),
                Status__c = 'New',
                Position_Title__c = 'Test Dev ' + String.valueOf(i),
                Application_Date__c = System.today(),
                Salary__c = '115000',
                Location__c = 'Remote',
                Source_Id__c = 'TriggerSourceId_' + String.valueOf(i)
            ));
        }
        insert jobAppList;
    }

    @isTest
    static void testBeforeInsert(){
        List<Job_Application__c> jobAppList = new List<Job_Application__c>();
        for(Integer i = 50; i < 100; i++){
            jobAppList.add(new Job_Application__c(
                Name = 'Test ' + String.valueOf(i),
                Status__c = 'New',
                Position_Title__c = 'Test Dev ' + String.valueOf(i),
                Application_Date__c = System.today(),
                Salary__c = '115000',
                Location__c = 'Remote',
                Source_Id__c = 'TriggerSourceId_' + String.valueOf(i)
            ));
        }

        Test.startTest();
        insert jobAppList;
        Test.stopTest();

        List<Job_Application__c> inserted = [SELECT Id FROM Job_Application__c WHERE Source_Id__c LIKE 'TriggerSourceId_5%'];
        System.assertNotEquals(0, inserted.size(), 'Expected records to be inserted');
    }

    @isTest
    static void testAfterInsert(){
        List<Job_Application__c> jobAppList = new List<Job_Application__c>();
        for(Integer i = 100; i < 150; i++){
            jobAppList.add(new Job_Application__c(
                Name = 'Test ' + String.valueOf(i),
                Status__c = 'New',
                Position_Title__c = 'Test Dev ' + String.valueOf(i),
                Application_Date__c = System.today(),
                Salary__c = '115000',
                Location__c = 'Remote',
                Source_Id__c = 'TriggerSourceId_' + String.valueOf(i)
            ));
        }

        Test.startTest();
        insert jobAppList;
        Test.stopTest();

        List<Job_Application__c> inserted = [SELECT Id FROM Job_Application__c WHERE Source_Id__c LIKE 'TriggerSourceId_1%'];
        System.assertNotEquals(0, inserted.size(), 'Expected records to be inserted');
    }

    @isTest
    static void testBeforeUpdate(){
        List<Job_Application__c> jobApps = [SELECT Id, Location__c FROM Job_Application__c LIMIT 50];
        for(Job_Application__c jobApp : jobApps){
            jobApp.Location__c = 'Charlotte, NC';
        }

        Test.startTest();
        update jobApps;
        Test.stopTest();

        List<Job_Application__c> updated = [SELECT Location__c FROM Job_Application__c WHERE Location__c = 'Charlotte, NC'];
        System.assertEquals(50, updated.size(), 'Expected 50 records to be updated');
    }

    @isTest
    static void testBeforeDelete(){
        List<Job_Application__c> jobApps = [SELECT Id FROM Job_Application__c LIMIT 50];

        Test.startTest();
        delete jobApps;
        Test.stopTest();

        List<Job_Application__c> deleted = [SELECT Id FROM Job_Application__c WHERE IsDeleted = true ALL ROWS];
        System.assertEquals(50, deleted.size(), 'Expected 50 records to be deleted');
    }

    @isTest
    static void testAfterDelete(){
        List<Job_Application__c> jobApps = [SELECT Id FROM Job_Application__c LIMIT 50];

        Test.startTest();
        delete jobApps;
        Test.stopTest();

        List<Job_Application__c> deleted = [SELECT Id FROM Job_Application__c WHERE IsDeleted = true ALL ROWS];
        System.assertEquals(50, deleted.size(), 'Expected 50 records to be deleted');
    }

    @isTest
    static void testAfterUndelete(){
        List<Job_Application__c> jobApps = [SELECT Id FROM Job_Application__c LIMIT 50];

        Test.startTest();
        delete jobApps;
        undelete jobApps;
        Test.stopTest();

        List<Job_Application__c> undeleted = [SELECT Id FROM Job_Application__c];
        System.assertEquals(50, undeleted.size(), 'Expected 50 records to be undeleted');
    }
}