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

    System.debug('EventTrigger fired | Operation: ' + Trigger.operationType + '|Records:' + Trigger.new.size());

    //Validating only Events where Subject = "Interview"

     List<Event> interviewEvents = new List<Event>();
    for (Event evt : Trigger.new) {
        if (evt.Subject != null && evt.Subject.contains('Interview')) {
            interviewEvents.add(evt);
        }

    }
    if (interviewEvents.isEmpty()) {
        return;
    }
            switch on Trigger.opperationType {

            
        when BEFORE_INSERT {
            EventHandler.validateFixedDuration(interviewEvents);
            EventHandler.validateBusinessHours(interviewEvents);
            EventHandler.validateNoWeekendEvents(interviewEvents);
            EventHandler.validateNoOverlappingEvents(interviewEvents);
            EventHandler.validateBufferTime(interviewEvents);
            EventHandler.validateMaxPerDay(interviewEvents);    
        }

      
        when BEFORE_UPDATE {
            EventHandler.validateFixedDuration(interviewEvents);
            EventHandler.validateBusinessHours(interviewEvents);
            EventHandler.validateNoWeekendEvents(interviewEvents);
            EventHandler.validateNoOverlappingEvents(interviewEvents);
            EventHandler.validateBufferTime(interviewEvents);
            EventHandler.validateMaxPerDay(interviewEvents);
        }
    }
}