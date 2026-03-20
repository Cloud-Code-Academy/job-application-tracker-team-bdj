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
public class PrimaryContactHandlerTest {

    @isTest
    static void testSetPrimaryContact() {
        // TO DO: implement unit test

        // Create Account
        Account acc = new Account(Name = 'Test Company');
        insert acc;

        // Create Contact
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = acc.Id
        );
        insert con;

        // Create Job Application (Primary Contact blank)
        Job_Application__c app = new Job_Application__c(
            Name = 'Test Application',
            Company_Name__c = acc.Id,
            Primary_Contact__c = null,
            Application_Date__c = Date.today(),
            Location__c = 'Remote',
            Position_Title__c = 'Test Position',
            Salary__c = 100000,
            Status__c = 'Applied'
        );
        insert app;

        // Create Job Application Contact
        Job_Application_Contact__c junction = new Job_Application_Contact__c(
            Job_Application__c = app.Id,
            Contact__c = con.Id
        );
        insert junction;

        // Query application before running handler
        List<Job_Application__c> apps = [
            SELECT Id, Primary_Contact__c
            FROM Job_Application__c
            WHERE Id = :app.Id
        ];

        Test.startTest();
        update app;
        Test.stopTest();

        // Verify Primary Contact was set from Job Application Contact
        Job_Application__c updatedApp = [
            SELECT Primary_Contact__c
            FROM Job_Application__c
            WHERE Id = :app.Id
        ];

        System.assertEquals(con.Id, updatedApp.Primary_Contact__c, 'Primary Contact should be set from Job Application Contact object');
    }

    @isTest
    static void testSetPrimaryContactFromAccount() {

        // Create Account
        Account acc = new Account(Name = 'Another Company');
        insert acc;

        // Create old Contact
        Contact con1 = new Contact(
            FirstName = 'Old',
            LastName = 'Contact',
            AccountId = acc.Id
        );
        insert con1;

        // Create new Contact
        Contact con2 = new Contact(
            FirstName = 'New',
            LastName = 'Contact',
            AccountId = acc.Id
        );
        insert con2;

        // Create Job Application (Primary Contact blank)
        Job_Application__c app = new Job_Application__c(
            Name = 'Another Application',
            Company_Name__c = acc.Id,
            Primary_Contact__c = null,
            Application_Date__c = Date.today(),
            Location__c = 'Remote',
            Position_Title__c = 'Another Position',
            Salary__c = 100000,
            Status__c = 'Applied'
        );
        insert app;

        Test.startTest();
        update app;
        Test.stopTest();

        // Verify Primary Contact was set from Account
        Job_Application__c updatedApp = [
            SELECT Primary_Contact__c
            FROM Job_Application__c
            WHERE Id = :app.Id
        ];

        System.assertEquals(con1.Id, updatedApp.Primary_Contact__c, 'Primary Contact should be set from the newest Account Contact');
    }


    @isTest
    static void testSetPrimaryContactNoContact() {

        // Create Account
        Account acc = new Account(Name = 'Bad Company');
        insert acc;

        // Create Job Application (Primary Contact blank)
        Job_Application__c app = new Job_Application__c(
            Name = 'Bad Application',
            Company_Name__c = acc.Id,
            Primary_Contact__c = null,
            Application_Date__c = Date.today(),
            Location__c = 'Remote',
            Position_Title__c = 'Bad Position',
            Salary__c = 100000,
            Status__c = 'Applied'
        );
        insert app;

        Test.startTest();
        update app;
        Test.stopTest();

        // Verify Primary Contact was set from Account
        Job_Application__c updatedApp = [
            SELECT Primary_Contact__c
            FROM Job_Application__c
            WHERE Id = :app.Id
        ];

        System.assertEquals(null, updatedApp.Primary_Contact__c, 'Primary Contact should be null if no related Contacts exist');
    }
}

