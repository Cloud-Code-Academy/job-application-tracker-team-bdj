// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
// Query events that already exist in the org
try {
    Event event2 = new Event(
        Subject = 'Overlapping Interview',
        StartDateTime = DateTime.newInstance(System.today().addDays(1), Time.newInstance(9, 30, 0, 0)),
        EndDateTime = DateTime.newInstance(System.today().addDays(1), Time.newInstance(10, 30, 0, 0))
    );
    insert event2;
    System.debug('Event 2 inserted (overlap was NOT caught)');
} catch (DmlException e) {
    System.debug('Overlap caught: ' + e.getMessage());
}