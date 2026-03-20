public with sharing class JoobleCalloutScheduler implements Schedulable {

    public void execute(SchedulableContext schedContext){
        System.enqueueJob(new JoobleCallout());
    }
    
}