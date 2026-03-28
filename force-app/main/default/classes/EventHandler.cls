/**
 * EventHandler
 * Handler class for the EventTrigger. Contains all validation logic for the
 * standard Event object to prevent scheduling conflicts.
 * 
 * Features:
 * 1. Fixed Duration — Interviews must be exactly 60 minutes
 * 2. Business Hours — Interviews must be between 8:00 AM and 5:00 PM
 * 3. Weekend Validation — Interviews cannot be scheduled on Saturday or Sunday
 * 4. Overlap Validation — Interviews cannot overlap for the same interviewer
 * 5. Buffer Time — 30-minute buffer required between interviews for the same interviewer
 * 6. Max Per Day — Maximum 3 interviews per interviewer per day
 * 
 * "with sharing" enforces the running user's sharing rules so users can only
 * see/validate against events they have access to.
 */
public with sharing class EventHandler{

    /* 
     * 1. Overlapping Interviews
     * Pseudo Rules:
     * When an interview is created or updated
     *     Find existing interviews with the same interviewer (OwnerId).
     *     For each existing interview
     *         If new interview start time is before existing interview end time
     *         AND new interview end time is after existing interview start time
     *             Prevent the interview from being saved.
     *             Display overlap error:
     *             "This interview conflicts with another interview scheduled
     *              for this interviewer. Please select a different time."
     */
    private static List<Event> getExistingEvents(List<Event> newEvents) {
        
        //Look through the interviews already scheduled and get the owner Id//
        Set<Id> ownerIds = new Set<Id>();
        for (Event evt : newEvents) {
            ownerIds.add(evt.OwnerId);
        }
    
        /* Now that we have all of our currently booked interviews we need to
        look through them to see if they have a start time that is before an 
        existing interview endtime and if the endtime is after an existing interview start time 
        by using a query*/

    List<Event> existingEvents = [
        SELECT Id, OwnerId, StartDateTime, EndDateTime
        FROM Event 
        WHERE OwnerId IN :ownerIds


    ];

      return existingEvents;
    }

    public static void validateNoOverlappingEvents(List<Event> newEvents) {

        /*Call the method from above "ExistingEvents" to get existing
        events and loop through them*/
        List<Event> existingEvents = getExistingEvents(newEvents);

        //This is where you would look through each event the user is trying to book.
        for (Event newEvt : newEvents) {
        
        // now convert the new event time to minutes
        Long newStartMinutes = newEvt.StartDateTime.getTime() / 60000;
        Long newEndMinutes = newEvt.EndDateTime.getTime() / 60000;
        
        //Now we can look through everything in our data to see if we find matches.
        //And have it skip itself if it is the same ID.  

        for (Event existingEvt : existingEvents) {

            if (existingEvt.OwnerId != newEvt.OwnerId || existingEvt.Id == newEvt.Id) {
                continue;
            }

            // convert the existing event time to minutes

            Long existingStartMinutes = existingEvt.StartDateTime.getTime()/ 60000;
            Long existingEndMinutes = existingEvt.EndDateTime.getTime()/ 60000;

         // Final part of checking for over lapping
            
            if (newStartMinutes < existingEndMinutes && newEndMinutes > existingStartMinutes) {
                newEvt.addError(
                    'This interview time conflicts with another meeting scheduled. ' + 
                    'Please select a different time.'
                );
                break;
    
            }
        }
    }
    }
    
     // 2. Fixed Interview Duration

public static void validateFixedDuration(List<Event> newEvents) {
            System.debug('Checking event duration');
        for(Event evt: newEvents) {
            Long startMinutes = evt.StartDateTime.getTime()/60000;
            Long endMinutes = evt.EndDateTime.getTime() / 60000;
            Long durationMinutes = endMinutes - startMinutes;
            System.debug('Duration:' + durationMinutes + 'minutes');
    
        if (durationMinutes != 60) {

        evt.addError ('Interviews can only be scheduled for 60 mins.');

        }
    }
}

    /*
     * 3. Business Hours Restriction
     * Note: Time zone awareness is handled natively by Salesforce DateTime fields.
     * DateTime values are stored in UTC and displayed in each user's local time zone.
     * Strictly using this for the sake of building code
     */
    // TODO: validateBusinessHours()
public static void validateBusinessHours(List<Event> newEvents) {
    for (Event evt: newEvents) {
        Integer startHour = evt.StartDateTime.hour();
        Integer endHour = evt.EndDateTime.hour();
System.debug('Start hour:' + startHour + ' | End hour: ' + endHour);
        if(startHour < 8 || endHour > 17) {
            evt.addError('Interviews have to be scheduled between 8am and 5pm.');
        }
    }
}
    /*
     * 5. No Weekend Scheduling
     * Pseudo Rules:
     * For each new interview record
     *     If start date falls on Saturday or Sunday
     *         Prevent the interview from being saved.
     *         Display error: "Interviews cannot be scheduled on weekends."
     */
    // TODO: validateNoWeekendEvents()

public static void validateNoWeekendEvents (List<Event> newEvents) {
    System.debug('Checking for weekend interviews');
    for (Event evt : newEvents) {
        String dayOfWeek = evt.StartDateTime.format('EEEE');
        System.debug('Day of week:' + dayOfWeek);

        if( dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') {
            evt.affError('Cannot schedule interviews on the weekend');
        }
    }
}
  /*
     * 6. Interview Buffer Time
     * Pseudo Rules:
     * For each new interview record
     *     Find existing interviews for the same interviewer.
     *     For each existing interview
     *         Expand existing event by 30 minutes on both ends
     *         (subtract 30 min from start, add 30 min to end)
     *         If new event overlaps with the expanded time range
     *             Prevent the interview from being booked.
     *             Display an error message:
     *             "Interviews must have a 30-minute buffer between meetings.
     *              Please select a later time."
     */
    // TODO: validateBufferTime()
public static void validateBufferTime (List<Event> newEvents) {
    List<Event> existingEvents = getExistingEvents(newEvents);
System.debug ('Checking buffer time');

    for (Event newEvt : newEvents) {
        Long newStartMinutes = newEvtStartDateTime.getTime()/60000;
        Long newEndMinute = newEvtEndTime.getTime()/60000;

        for(Event existingEvt : newEvents) {
            if( existingEvt.OwnerId != newEvent.OwnerId || existingEvt.Id == newEvt.Id) {
                continue;
            }

            Long existingStartMinutes = existingEvt.StartDatetiem.getTime() / 60000;
            Long existingEndMinutes = existingEvt.EndDateTime.getTime() / 60000;

            Long bufferedStart = existingEvt.StartDateTime - 30;
            Long bufferedEnd = existingEvt.EndDateTime + 30;
            System.debug('Buffered windows:' + bufferedStart ' to ' + bufferedEnd);

            if(newStartMinutes < bufferedEnd && newEndMinutes > bufferedStart) {
                newEvt.addError(
                    'Interviews need to have a 30 min buffer time betweeen them' +
                    'to allow time to prep for the next interview.' +
                    'Please select a new time.'
                    );
                    break;
                }
            }
        }
    }


    /*
     * 7. Maximum Interviews Per Day
     * Pseudo Rules:
     * For each new interview record (insert or update)
     *     Find interviews for the same interviewer on the same date.
     *     Count the number of existing interviews.
     *     If the number of total interviews is greater than or equal to 3
     *         Prevent the interview from being saved.
     *         Display an error message:
     *         "This interviewer already has 3 interviews scheduled for this date.
     *          Please select a different date."
     */
public static void validateMaxPerDay (List<Event> newEvents) {
    System.debug('Check for max interview in a day');
    List<Event> existingEvents = getExistingEvents(newEvents);

    for (Event newEvt : newEvents) {
        Date eventDate = newEvt.StartDateTime.date();
        Integer count = 0;

        for (Event existingEvt : existingEvents) {
            if(existingEvt.Id == newEvt.Id) {
              continue;
            }
            if(existingEvt.OwnerId == newEvt.OwnerId
            && existingEvt.StartDateTime.date()== eventDate){
                count++;
        }
    }
    System.debug('Events on' + eventDate + 'for this owner:' + count);

        if (count >= 3) {
            newEvt.addError(
                'This interviewer already has three interviews scheduled for this date.' +
                'Please Select a different date.'
            );
        }
    }
}

}
