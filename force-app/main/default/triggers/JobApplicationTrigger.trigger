trigger JobApplicationTrigger on Job_Application__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    switch on Trigger.operationType{
        when BEFORE_INSERT {
            PrimaryContactHandler.setPrimaryContact(Trigger.new);
        }

        when BEFORE_UPDATE {
            PrimaryContactHandler.setPrimaryContact(Trigger.new);
        }

        when BEFORE_DELETE {}

        when AFTER_INSERT {}

        when AFTER_UPDATE {
            JobApplicationHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }

        when AFTER_DELETE {}

        when AFTER_UNDELETE {}

    }

}