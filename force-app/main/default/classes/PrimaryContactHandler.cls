public with sharing class PrimaryContactHandler {
// Public is accessible outside the class, with sharing to respect sharing rules/user permissions

    public static void setPrimaryContact(List<Job_Application__c> apps) {
    //Passing in a list of Job Applications

        // Sets to store Ids of the applications that need contacts and the accounts
        Set<Id> applicationIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        // Looping through Job Applications
        for (Job_Application__c app : apps) {

            // For each application, checking if it is missing a primary contact and adding to the set
            if (app.Primary_Contact__c == null) {
                applicationIds.add(app.Id);
            }

            // For each application, checking if an account (company) exists and adding to the set
            if (app.Company_Name__c != null) {
                accountIds.add(app.Company_Name__c);
            }
        }

        // Query the Job Application Contact object to retrieve contact information for applications in our set
        List<Job_Application_Contact__c> contacts = [
            SELECT Job_Application__c, Contact__c
            FROM Job_Application_Contact__c
            WHERE Job_Application__c IN :applicationIds
        ];

        // Creating a map to connect the application (key) to the contact (value)
        Map<Id,Id> appToContact = new Map<Id,Id>();

        // Looping through Job Application contacts
        for (Job_Application_Contact__c cont : contacts) {

            // If the job application contact is related to a job application, assign the first contact found
            if (!appToContact.containsKey(cont.Job_Application__c)) {
                appToContact.put(cont.Job_Application__c, cont.Contact__c);
            }

        }

        // Query contacts from accounts ordered by newest first
        List<Contact> accountContacts = [
            SELECT Id, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds
            ORDER BY CreatedDate DESC
        ];

        // Creating a map to connect account to the contact
        Map<Id,Id> accountToContact = new Map<Id,Id>();

        // Looping through the contacts, if the account does not have a contact assigned, assign this contact
        for (Contact c : accountContacts) {
            if (!accountToContact.containsKey(c.AccountId)) {
                accountToContact.put(c.AccountId, c.Id);
            }
        }

        // Creating a list to store the applications to update
        List<Job_Application__c> appsToUpdate = new List<Job_Application__c>();

        // Loop through Job Applications
        for (Job_Application__c app : apps) {

            // If primary contact is null
            if (app.Primary_Contact__c == null) {
                Id contactId;

                // And a related job application contact exists, link that contact to the job application
                if (appToContact.containsKey(app.Id)) {
                    contactId = appToContact.get(app.Id);
                }

                // If no related job application, check for the account contact
                else if (accountToContact.containsKey(app.Company_Name__c)) {
                    contactId = accountToContact.get(app.Company_Name__c);
                }

                // If a contact was found, set the contact as the Primary Contact
                if (contactId != null) {
                    app.Primary_Contact__c = contactId;
                }

            }

        }

    }

}