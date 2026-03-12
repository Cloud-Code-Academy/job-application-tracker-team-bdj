public with sharing class PrimaryContactHandler {

    public static void setPrimaryContact(List<Job_Application__c> apps) {

        Set<Id> applicationIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for (Job_Application__c app : apps) {

            if (app.Primary_Contact__c == null) {
                applicationIds.add(app.Id);
            }

            if (app.Company_Name__c != null) {
                accountIds.add(app.Company_Name__c);
            }
        }

        List<Job_Application_Contact__c> contacts = [
            SELECT Job_Application__c, Contact__c
            FROM Job_Application_Contact__c
            WHERE Job_Application__c IN :applicationIds
        ];

        Map<Id,Id> appToContact = new Map<Id,Id>();

        for (Job_Application_Contact__c cont : contacts) {

            if (!appToContact.containsKey(cont.Job_Application__c)) {
                appToContact.put(cont.Job_Application__c, cont.Contact__c);
            }

        }

        List<Job_Application__c> appsToUpdate = new List<Job_Application__c>();

        for (Job_Application__c app : apps) {

            if (app.Primary_Contact__c == null) {

                if (appToContact.containsKey(app.Id)) {

                    appsToUpdate.add(
                        new Job_Application__c(
                            Id = app.Id,
                            Primary_Contact__c = appToContact.get(app.Id)
                        )
                    );

                }

            }

        }

        if (!appsToUpdate.isEmpty()) {
            update appsToUpdate;
        }

    }

}