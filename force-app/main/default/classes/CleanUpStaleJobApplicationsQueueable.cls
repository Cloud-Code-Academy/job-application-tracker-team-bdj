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

            // Setting the closed comment to app has been closed plus date
            String closedComment = 'This job application has been closed by an automated process on ' + String.valueOf(Date.today()) + '.';

            // If there is no note, add the closed comment
            if (String.isBlank(jobAppsToUpdate.Notes__c)) {
                jobAppsToUpdate.Notes__c = closedComment;
            }

            // If there is a note, add a new line and the closed comment
            else {
                jobAppsToUpdate.Notes__c += '\n\n' + closedComment;
            }
        }

        // If there are stale job apps, update them
        if (!staleJobApps.isEmpty()) {
            update staleJobApps;
        }
    }
}
