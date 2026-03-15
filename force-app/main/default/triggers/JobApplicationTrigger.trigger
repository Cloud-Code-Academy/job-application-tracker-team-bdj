/**
 * JobApplicationTrigger
 * Single trigger for the Job_Application__c object.
 * 
 * Follows the "one trigger per object" best practice — all trigger contexts are
 * defined here but business logic is delegated to handler classes.
 * This keeps the trigger thin and the logic testable and maintainable.
 * 
 * All contexts are stubbed out (empty blocks) so new functionality can be
 * added without modifying the trigger definition, only the handler calls inside.
 */
trigger JobApplicationTrigger on Job_Application__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    switch on Trigger.operationType{
        when BEFORE_INSERT {}

        when BEFORE_UPDATE {}

        when BEFORE_DELETE {}

        when AFTER_INSERT {}

        // AFTER_UPDATE: Calls the handler to create status-based Tasks.
        // Uses Trigger.new (updated records) and Trigger.oldMap (previous values)
        // so the handler can detect which records actually changed status.
        when AFTER_UPDATE {
            JobApplicationHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }

        when AFTER_DELETE {}

        when AFTER_UNDELETE {}

    }

}