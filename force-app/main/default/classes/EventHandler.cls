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

         /* Final part of checking for over lapping. "If new interview start time is before existing interview end time
          *AND new interview end time is after existing interview start time prevent the interview from being booked
          *prevent it from happening and display an error message.*/
            
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
    
     /* 2. Fixed Interview Duration
     * Pseudo Rules:
     * For each interview record
     *     Calculate the duration between start and end time.
     *     If the duration is longer or shorter than 60 minutes
     *         Prevent the system from saving.
     *         Display an error message:
     *         "Interviews must be scheduled for exactly 60 minutes."
     */
    // TODO: validateFixedDuration()


    /*
     * 3. Business Hours Restriction
     * Pseudo Rules:
     * For each new interview record
     *     If start time is before 8:00 AM
     *         Prevent the interview from being saved.
     *         Display error: "Interviews must be scheduled between 8:00 AM and 5:00 PM."
     *     If end time is after 5:00 PM
     *         Prevent the interview from being saved.
     *         Display error: "Interviews must be scheduled between 8:00 AM and 5:00 PM."
     *
     * Note: Time zone awareness is handled natively by Salesforce DateTime fields.
     * DateTime values are stored in UTC and displayed in each user's local time zone.
     */
    // TODO: validateBusinessHours()


    /*
     * 5. No Weekend Scheduling
     * Pseudo Rules:
     * For each new interview record
     *     If start date falls on Saturday or Sunday
     *         Prevent the interview from being saved.
     *         Display error: "Interviews cannot be scheduled on weekends."
     */
    // TODO: validateNoWeekendEvents()


    /// *** SHARED SOQL QUERY *** ///


    /*
     * getExistingEvents — Shared query method used by overlap, buffer, and max-per-day.
     * Queries existing Event records for the same interviewer(s) within the relevant
     * date range. One query feeds all three validations to stay under governor limits.
     */
    // TODO: getExistingEvents()


    /// *** VALIDATION METHODS (Require SOQL) *** ///



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
    }
