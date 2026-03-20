@isTest
public class JoobleCallout_Test {

    @isTest
    static void testSuccessfulCallout() {
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock());

        Test.startTest();
        System.enqueueJob(new JoobleCallout());
        Test.stopTest();

        List<Job_Application__c> jobApps = [SELECT Id, Position_Title__c, Status__c FROM Job_Application__c];
        System.assertEquals(2, jobApps.size(), 'Expected 2 Job Applications to be created');
        System.assertEquals('New', jobApps[0].Status__c, 'Expected Status to be New');
    }

    @isTest
    static void testFailedCallout() {
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock.FailMock());

        Test.startTest();
        System.enqueueJob(new JoobleCallout());
        Test.stopTest();

        List<Job_Application__c> jobApps = [SELECT Id FROM Job_Application__c];
        System.assertEquals(0, jobApps.size(), 'Expected no Job Applications to be created on failed callout');
    }

    @isTest
    static void testScheduler() {
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock());
        
        Test.startTest();
        String cronExp = '0 0 8 * * ?';
        System.schedule('Test Jooble Scheduler', cronExp, new JoobleCalloutScheduler());
        Test.stopTest();

        List<CronTrigger> scheduledJobs = [SELECT Id, CronExpression FROM CronTrigger WHERE CronJobDetail.Name = 'Test Jooble Scheduler'];
        System.assertEquals(1, scheduledJobs.size(), 'Expected 1 scheduled job to exist');
        System.assertEquals('0 0 8 * * ?', scheduledJobs[0].CronExpression, 'Expected cron expression to match');
    }

}