@isTest
public class JobApplicationCreateFromCallout_Test {

    @TestSetup
    static void setupTestData(){
        Account existingAccount = new Account(Name = 'Test Company One');
        insert existingAccount;
    }

    @isTest
    static void testCreateJobApps(){
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock());

        Test.startTest();
        System.enqueueJob(new JoobleCallout());
        Test.stopTest();

        // Verify Job Applications were created
        List<Job_Application__c> jobApps = [
            SELECT Id, Name, Position_Title__c, Location__c, Description__c,
                   Salary__c, Employment_Type__c, URL__c, Application_Date__c,
                   Status__c, Source_Id__c, Company_Name__c, Sourced_From__c
            FROM Job_Application__c
            ORDER BY Position_Title__c
        ];

        System.assertEquals(2, jobApps.size(), 'Expected 2 Job Applications to be created');

        // Verify Job App 1 - Salesforce Admin
        System.assertEquals('Salesforce Admin - Test Company Two', jobApps[0].Name, 'Expected Name to be concatenation of title and company');
        System.assertEquals('Salesforce Admin', jobApps[0].Position_Title__c, 'Expected Position Title to match');
        System.assertEquals('Charlotte, NC', jobApps[0].Location__c, 'Expected Location to match');
        System.assertEquals('Not Listed', jobApps[0].Salary__c, 'Expected blank salary to default to Not Listed');
        System.assertEquals('Not Listed', jobApps[0].Employment_Type__c, 'Expected blank type to default to Not Listed');
        System.assertEquals('https://jooble.org/away/67890', jobApps[0].URL__c, 'Expected URL to match');
        System.assertEquals(Date.valueOf('2026-03-09'), jobApps[0].Application_Date__c, 'Expected Application Date to match');
        System.assertEquals('New', jobApps[0].Status__c, 'Expected Status to be New');
        System.assertEquals('67890', jobApps[0].Source_Id__c, 'Expected Source Id to match');
        System.assertEquals('appcast.io', jobApps[0].Sourced_From__c, 'Expected Source to match');

        // Verify Job App 2 - Salesforce Developer
        System.assertEquals('Salesforce Developer - Test Company One', jobApps[1].Name, 'Expected Name to be concatenation of title and company');
        System.assertEquals('Salesforce Developer', jobApps[1].Position_Title__c, 'Expected Position Title to match');
        System.assertEquals('Remote', jobApps[1].Location__c, 'Expected Location to match');
        System.assertEquals('$100k - $120k', jobApps[1].Salary__c, 'Expected Salary to match');
        System.assertEquals('Full-Time', jobApps[1].Employment_Type__c, 'Expected Employment Type to match');
        System.assertEquals('https://jooble.org/away/12345', jobApps[1].URL__c, 'Expected URL to match');
        System.assertEquals(Date.valueOf('2026-03-06'), jobApps[1].Application_Date__c, 'Expected Application Date to match');
        System.assertEquals('New', jobApps[1].Status__c, 'Expected Status to be New');
        System.assertEquals('12345', jobApps[1].Source_Id__c, 'Expected Source Id to match');
        System.assertEquals('Lensa.com', jobApps[1].Sourced_From__c, 'Expected Source to match');
    }

    @isTest
    static void testDescriptionHtmlStripping(){
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock());

        Test.startTest();
        System.enqueueJob(new JoobleCallout());
        Test.stopTest();

        Job_Application__c jobApp = [SELECT Description__c FROM Job_Application__c WHERE Source_Id__c = '12345'];
        System.assertEquals('A great Salesforce job', jobApp.Description__c, 'Expected HTML to be stripped from Description');
    }

    @isTest
    static void testAccountMatching(){
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock());

        Test.startTest();
        System.enqueueJob(new JoobleCallout());
        Test.stopTest();

        // Verify existing account was matched
        Account existingAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Company One'];
        Job_Application__c jobApp = [SELECT Company_Name__c FROM Job_Application__c WHERE Source_Id__c = '12345'];
        System.assertEquals(existingAccount.Id, jobApp.Company_Name__c, 'Expected Job App to be linked to existing Account');
    }

    @isTest
    static void testAccountCreation(){
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock());

        Test.startTest();
        System.enqueueJob(new JoobleCallout());
        Test.stopTest();

        // Verify new account was created for Test Company Two
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Company Two'];
        System.assertEquals(1, accounts.size(), 'Expected new Account to be created for Test Company Two');

        Job_Application__c jobApp = [SELECT Company_Name__c FROM Job_Application__c WHERE Source_Id__c = '67890'];
        System.assertEquals(accounts[0].Id, jobApp.Company_Name__c, 'Expected Job App to be linked to newly created Account');
    }

    @isTest
    static void testDeduplication(){
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock());

        // Run the callout twice
        Test.startTest();
        System.enqueueJob(new JoobleCallout());
        System.enqueueJob(new JoobleCallout());
        Test.stopTest();

        List<Job_Application__c> jobApps = [SELECT Id FROM Job_Application__c];
        System.assertEquals(2, jobApps.size(), 'Expected dedup logic to prevent duplicate Job Applications');
    }

    @isTest
    static void testEmptyJobsResponse(){
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock.EmptyMock());

        Test.startTest();
        System.enqueueJob(new JoobleCallout());
        Test.stopTest();

        List<Job_Application__c> jobApps = [SELECT Id FROM Job_Application__c];
        System.assertEquals(0, jobApps.size(), 'Expected no Job Applications to be created for empty response');
    }

    @isTest
    static void testParseDateFallbacks(){
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock.BadDateMock());

        Test.startTest();
        System.enqueueJob(new JoobleCallout());
        Test.stopTest();

        List<Job_Application__c> jobApps = [SELECT Application_Date__c FROM Job_Application__c ORDER BY Source_Id__c];
        System.assertEquals(Date.today(), jobApps[0].Application_Date__c, 'Expected blank date to fall back to today');
        System.assertEquals(Date.today(), jobApps[1].Application_Date__c, 'Expected bad date format to fall back to today');
    }
    
}