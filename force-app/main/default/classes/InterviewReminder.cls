/**
 * InterviewReminder
 * Scheduled Apex class that sends email reminders the day before an interview.
 * 
 * Implements the Schedulable interface so it can be scheduled via Setup or Apex:
 *   String cronExp = '0 0 8 * * ?';  // Runs daily at 8:00 AM
 *   System.schedule('Interview Reminder', cronExp, new InterviewReminderScheduler());
 * 
 * Pseudo Rules:
 * Every day at the scheduled time
 * Query all Event records where StartDateTime is tomorrow
 * For each event found
 * Build an email with interview details (subject, date/time, location, notes)
 * Send the email to the event owner (interviewer)
 * Send all emails in a single call to stay within governor limits
 * 
 * "with sharing" enforces the running user's record-level security.
 */
public with sharing class InterviewReminder implements Schedulable {

    //Counter so tests can verify how many emails were built
    @TestVisible private static Integer emailsSentCount = 0;

    //Lets tests set a fake "today" so they don't break on weekends
    @TestVisible private static Date referenceDate = null;

    public void execute(SchedulableContext sc) {
        sendInterviewReminders();
    }

    private static void sendInterviewReminders() {
        //Get the interviews scheduled for tomorrow
        Date baseDate = referenceDate != null ? referenceDate : System.today();
        Date tomorrow = baseDate.addDays(1);
        DateTime tomorrowStart = DateTime.newInstance(tomorrow, Time.newInstance(0, 0, 0, 0));
        DateTime tomorrowEnd = DateTime.newInstance(tomorrow, Time.newInstance(23, 59, 59, 0));

        //Query interview records
        List<Event> interviews = [
            SELECT Id, Subject, StartDateTime, EndDateTime, Description, Location, OwnerId
            FROM Event
            WHERE StartDateTime >= :tomorrowStart
            AND StartDateTime <= :tomorrowEnd
        ];

        //Collect Owner Ids to get email
        Set<Id> ownerIds = new Set<Id>();
        for (Event evt : interviews) {
            ownerIds.add(evt.OwnerId);
        }

        //Query users to get emails
        Map<Id, User> userMap = new Map<Id, User>(
            [SELECT Id, Email
            FROM User
            WHERE Id IN :ownerIds]
        );

        //Structure individual emails for every interview
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Event evt : interviews) {
            User owner = userMap.get(evt.OwnerId);
            if (owner == null || owner.Email == null) {
                continue;
            }

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ owner.Email });
            email.setSubject('Interview Reminder: ' + evt.Subject);
            email.setHtmlBody(buildEmailBody(evt));
            emails.add(email);
        }

        //Send emails
        emailsSentCount = emails.size();
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    //HTML body for interview details
    private static String buildEmailBody(Event evt) {
        String body = '<h2>Interview Reminder</h2>';
        body += '<p>You have an interview scheduled tomorrow.</p>';
        body += '<p><strong>Subject:</strong> ' + evt.Subject + '</p>';
        body += '<p><strong>Date/Time:</strong> ' + evt.StartDateTime.format('EEEE, MMM d, yyyy h:mm a') + '</p>';

        if (evt.Location != null) {
            body += '<p><strong>Location:</strong> ' + evt.Location + '</p>';
        }
        if (evt.Description != null) {
            body += '<p><strong>Notes:</strong> ' + evt.Description + '</p>';
        }

        body += '<p>Good luck!</p>';
        return body;
    }
}