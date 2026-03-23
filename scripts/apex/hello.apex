// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
// Query events that already exist in the org
Event event1 = new Event(
    Subject = 'Debug Test Interview',
    StartDateTime = DateTime.newInstance(System.today().addDays(1), Time.newInstance(9, 0, 0, 0)),
    EndDateTime = DateTime.newInstance(System.today().addDays(1), Time.newInstance(10, 0, 0, 0))
);
insert event1;
System.debug('Event 1 inserted: ' + event1.Id);