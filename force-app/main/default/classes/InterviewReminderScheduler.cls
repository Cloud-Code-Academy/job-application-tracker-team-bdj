/**
 * InterviewReminderScheduler
 * Scheduled Apex class that sends email reminders the day before an interview.
 * 
 * Implements the Schedulable interface so it can be scheduled via Setup or Apex:
 *   String cronExp = '0 0 8 * * ?';  // Runs daily at 8:00 AM
 *   System.schedule('Interview Reminder', cronExp, new InterviewReminderScheduler());
 * 
 * Pseudo Rules:
 * Every day at the scheduled time
 *     Query all Event records where StartDateTime is tomorrow
 *     For each event found
 *         Build an email with interview details (subject, date/time, location, notes)
 *         Send the email to the event owner (interviewer)
 *     Send all emails in a single call to stay within governor limits
 * 
 * "with sharing" enforces the running user's record-level security.
 */
public with sharing class InterviewReminderScheduler implements Schedulable {

    // TODO: execute() — Required Schedulable method
    // TODO: sendInterviewReminders() — Core logic
    // TODO: buildEmailBody() — HTML email builder

}
