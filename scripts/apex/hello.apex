// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
// Query events that already exist in the org
List<Event> cleanup = [SELECT Id, Subject FROM Event WHERE Subject = 'Debug Test Interview'];
System.debug('Events to delete: ' + cleanup.size());
delete cleanup;
System.debug('Cleanup done');