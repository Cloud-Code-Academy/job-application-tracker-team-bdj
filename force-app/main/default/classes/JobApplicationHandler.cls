public with sharing class JobApplicationHandler {

    public static void afterUpdate(List<Job_Application__c> newJobList, Map<Id, Job_Application__c> oldJobMap) {

        // Updates for merging
        // Initialize List for Job Apps with a changed status
        List<Job_Application__c> appsWithUpdatedStatus = new List<Job_Application__c>();
        
        // Evaluate if Status has changed
        for(Job_Application__c jobApp : newJobList) {
            if(jobApp.Status__c != oldJobMap.get(jobApp.Id).Status__c) {
                appsWithUpdatedStatus.add(jobApp);
            }
        }

        // If Status has changed, pass List to jobAppStatusUpdates class
        if(!appsWithUpdatedStatus.isEmpty()) { 
            jobAppStatusUpdates.jobAppTasks(appsWithUpdatedStatus);
        }

    }    

}