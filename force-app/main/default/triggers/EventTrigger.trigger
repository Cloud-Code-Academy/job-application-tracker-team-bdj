/**
 * EventTrigger
 * Single trigger for the standard Event object.
 * 
 * Follows the "one trigger per object" best practice — all trigger contexts are
 * defined here but business logic is delegated to the EventHandler class.
 * This keeps the trigger thin and the logic testable and maintainable.
 * 
 * Fires on before insert and before update so we can validate events
 * BEFORE they are saved to the database and add errors to block invalid records.
 */
trigger EventTrigger on Event (before insert, before update) {

    System.debug('EventTrigger fired | Operation: ' +  Trigger.operationType + '|Records:' + Trigger.new.size());
     switch on Trigger.operationType {

       
        when BEFORE_INSERT {
            EventHandler.validateFixedDuration(Trigger.new);
            EventHandler.validateBusinessHours(Trigger.new);
            EventHandler.validateNoWeekendEvents(Trigger.new);
            EventHandler.validateNoOverlappingEvents(Trigger.new);
            EventHandler.validateBufferTime(Trigger.new);
            EventHandler.validateMaxPerDay(Trigger.new);    
        }

      
        when BEFORE_UPDATE {
            EventHandler.validateFixedDuration(Trigger.new);
            EventHandler.validateBusinessHours(Trigger.new);
            EventHandler.validateNoWeekendEvents(Trigger.new);
            EventHandler.validateNoOverlappingEvents(Trigger.new);
            EventHandler.validateBufferTime(Trigger.new);
            EventHandler.validateMaxPerDay(Trigger.new);
        }
    }
}