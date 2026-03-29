/**
 * UpcomingActivityController
 * Apex controller for the upcomingActivityDashboard LWC.
 * Queries the current user's upcoming interviews and tasks
 * so they can see what's coming up on the home page.
 */
public with sharing class UpcomingActivityController {

    /*
     * getUpcomingInterviews
     * Finds all Events in the next 7 days where the Subject contains 'Interview'.
     * We use 'with sharing' so users only see their own events.
     * 
     * @AuraEnabled(cacheable=true) makes this callable from an LWC
     * and allows Lightning to cache the results for better performance.
     */
    @AuraEnabled(cacheable=true)
    public static List<Event> getUpcomingInterviews(Integer days) {
        if (days == null || days < 1 || days > 30) {
            days = 7;
        }
        return [
            SELECT Id, Subject, StartDateTime, EndDateTime, Description
            FROM Event
            WHERE OwnerId = :UserInfo.getUserId()
              AND StartDateTime >= :DateTime.now()
              AND StartDateTime <= :DateTime.now().addDays(days)
              AND Subject LIKE '%Interview%'
            ORDER BY StartDateTime ASC
        ];
    }

    /*
     * getUpcomingTasks
     * Finds all open (not completed) Tasks due in the next 7 days.
     * These are the tasks that Dave's status automation creates —
     * things like "Research the company" or "Prepare interview questions."
     */
    @AuraEnabled(cacheable=true)
    public static List<Task> getUpcomingTasks(Integer days) {
        if (days == null || days < 1 || days > 30) {
            days = 7;
        }
        return [
            SELECT Id, Subject, ActivityDate, Status, Priority, 
                   WhatId, What.Name
            FROM Task
            WHERE OwnerId = :UserInfo.getUserId()
              AND Status != 'Completed'
              AND ActivityDate >= :Date.today()
              AND ActivityDate <= :Date.today().addDays(days)
            ORDER BY ActivityDate ASC
        ];
    }
}
