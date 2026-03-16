public with sharing class PrimaryContactHandler {

    public static void setPrimaryContact(List<Job_Application__c> apps) {

        // Sets to store Ids of the applications and the accounts
        Set<Id> applicationIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        // Looping through Job Applications
        for (Job_Application__c app : apps) {

            // For each application, checking if it is missing a primary contact
            if (app.Primary_Contact__c == null) {
                applicationIds.add(app.Id);
            }

            // Currently not doing anything
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

        // Creating a map to connect the application to the contact
        Map<Id,Id> appToContact = new Map<Id,Id>();

        // Looping through Job Application contacts
        for (Job_Application_Contact__c cont : contacts) {

            // If no contact is assigned, choose the first related contact and make it the primary contact
            if (!appToContact.containsKey(cont.Job_Application__c)) {
                appToContact.put(cont.Job_Application__c, cont.Contact__c);
            }

        }

        // Creating a list to store the applications to update
        List<Job_Application__c> appsToUpdate = new List<Job_Application__c>();

        // Loop through Job Applications
        for (Job_Application__c app : apps) {

            // If primary contact is missing
            if (app.Primary_Contact__c == null) {

                // And a related contact exists
                if (appToContact.containsKey(app.Id)) {

                    // Add that application to the list to update
                    appsToUpdate.add(
                        new Job_Application__c(
                            Id = app.Id,
                            Primary_Contact__c = appToContact.get(app.Id)
                        )
                    );

                }

            }

        }

        // Update applications if list is not empty
        if (!appsToUpdate.isEmpty()) {
            update appsToUpdate;
        }

    }

}