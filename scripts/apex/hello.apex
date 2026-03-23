// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
// Query events that already exist in the org
Date tomorrow = System.today().addDays(1);
DateTime tomorrowStart = DateTime.newInstance(tomorrow, Time.newInstance(0, 0, 0, 0));
DateTime tomorrowEnd = DateTime.newInstance(tomorrow, Time.newInstance(23, 59, 59, 0));
List<Event> tomorrowEvents = [SELECT Id, Subject, StartDateTime FROM Event WHERE StartDateTime >= :tomorrowStart AND StartDateTime <= :tomorrowEnd];
System.debug('Interviews found for tomorrow: ' + tomorrowEvents.size());
for (Event evt : tomorrowEvents) {
    System.debug('Interview: ' + evt.Subject + ' at ' + evt.StartDateTime);
}