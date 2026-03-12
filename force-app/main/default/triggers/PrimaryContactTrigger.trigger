trigger PrimaryContactTrigger on Job_Application__c (after insert, after update) {
    PrimaryContactHandler.setPrimaryContact(Trigger.new);
}