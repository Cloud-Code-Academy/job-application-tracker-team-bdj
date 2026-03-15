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

    switch on Trigger.operationType {

        // Validate new events for scheduling rules
        when BEFORE_INSERT {
            // TODO: Call EventHandler validation methods
        }

        // Validate updated events in case the date/time was changed
        when BEFORE_UPDATE {
            // TODO: Call EventHandler validation methods
        }
    }
}
