public with sharing class CleanUpStaleJobApplicationsScheduler implements Schedulable {

    public void execute(SchedulableContext schedContext){
        System.enqueueJob(new CleanUpStaleJobApplicationsQueueable());
    }
}