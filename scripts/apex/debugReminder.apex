Date tomorrow = System.today().addDays(1);
DateTime tomorrowStart = DateTime.newInstance(tomorrow, Time.newInstance(0, 0, 0, 0));
DateTime tomorrowEnd = DateTime.newInstance(tomorrow, Time.newInstance(23, 59, 59, 0));

System.debug('Tomorrow: ' + tomorrow);
System.debug('Range: ' + tomorrowStart + ' to ' + tomorrowEnd);

List<Event> events = [
    SELECT Id, Subject, StartDateTime, OwnerId 
    FROM Event 
    WHERE StartDateTime >= :tomorrowStart AND StartDateTime <= :tomorrowEnd
];
System.debug('Events found: ' + events.size());
for (Event e : events) {
    System.debug('Event: ' + e.Subject + ' | Start: ' + e.StartDateTime + ' | Owner: ' + e.OwnerId);
}
