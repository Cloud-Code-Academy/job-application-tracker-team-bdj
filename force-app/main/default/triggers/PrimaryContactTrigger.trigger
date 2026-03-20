trigger PrimaryContactTrigger on Job_Application__c (before insert, before update) {
    PrimaryContactHandler.setPrimaryContact(Trigger.new);
}