// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
// Query events that already exist in the org
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
