public with sharing class CleanUpStaleJobApplicationsQueueable implements Queueable {
    public void execute(QueueableContext queueContext) {

        // Sets the follow up cut off date to be today minus 30 days
        Date staleDate = Date.today().addDays(-30);

        // Query Job Applications for those with status that is not Closed/Accepted and the follow up date is 30 days+ ago
        List<Job_Application__c> staleJobApps = [
            SELECT Id, Status__c, Follow_Up_Date__c, Notes__c
            FROM Job_Application__c
            WHERE Status__c NOT IN ('Closed', 'Accepted')
            AND Follow_Up_Date__c <= :staleDate
        ];

        // Loop through the stale job apps, update the status to Closed, add a note to the job application
        for (Job_Application__c jobAppsToUpdate : staleJobApps) {
            jobAppsToUpdate.Status__c = 'Closed';
            jobAppsToUpdate.Notes__c = 'This job application has been closed by an automated process.';
        }

        // If there are stale job apps, update them
        if (!staleJobApps.isEmpty()) {
            update staleJobApps;
        }
    }
}
