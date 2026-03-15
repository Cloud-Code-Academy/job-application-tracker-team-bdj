/**
 * JobApplicationHandler
 * Handler class for the Job Application trigger. Contains all business logic
 * for the Job_Application__c object, following the single-trigger-per-object pattern.
 * 
 * "with sharing" is used to enforce the running user's sharing rules,
 * ensuring proper data access and security.
 */
public with sharing class JobApplicationHandler {

    /**
     * afterUpdate - Fires after Job Application records are updated.
     * Creates status-specific Task records when a Job Application's Status changes.
     * 
     * Approach: Uses the oldMap to compare previous vs. current Status values.
     * Records are sorted into status-specific lists, then passed to dedicated helper
     * methods that generate the appropriate Tasks. This keeps each status's logic
     * isolated and maintainable.
     * 
     * @param newJobList - Trigger.new (list of updated Job Application records)
     * @param oldJobMap  - Trigger.oldMap (map of records with their previous field values)
     */
    public static void afterUpdate(List<Job_Application__c> newJobList, Map<Id, Job_Application__c> oldJobMap) {

        // Separate lists for each status — records are sorted here so each helper
        // method only processes the records relevant to its status.
        List<Job_Application__c> listSaved = new List<Job_Application__c>();
        List<Job_Application__c> listApplying = new List<Job_Application__c>();
        List<Job_Application__c> listApplied = new List<Job_Application__c>();
        List<Job_Application__c> listInterviewing = new List<Job_Application__c>();
        List<Job_Application__c> listNegotiating = new List<Job_Application__c>();
        List<Job_Application__c> listAccepted = new List<Job_Application__c>();
        List<Job_Application__c> listClosed = new List<Job_Application__c>();

        // Collects all Tasks from every status helper into one list
        // so we can perform a single bulk DML insert at the end.
        List<Task> tasksToInsert = new List<Task>();

        // Flag to track whether any record actually changed status.
        // Used as an early exit optimization — if no statuses changed,
        // we skip all helper method calls and the DML operation entirely.
        Boolean statusesChanged = false;
        
        // Loop through updated records and compare current Status to the old value.
        // A switch statement routes each record to the correct status-specific list.
        for(Job_Application__c jobApp : newJobList) {
            if(jobApp.Status__c != oldJobMap.get(jobApp.Id).Status__c) {
                if(statusesChanged == false) {
                    statusesChanged = true;
                }
                switch on jobApp.Status__c {
                    when 'Saved' {listSaved.add(jobApp);}
                    when 'Applying' {listApplying.add(jobApp);}
                    when 'Applied' {listApplied.add(jobApp);}
                    when 'Interviewing' {listInterviewing.add(jobApp);}
                    when 'Negotiating' {listNegotiating.add(jobApp);}
                    when 'Accepted' {listAccepted.add(jobApp);}
                    when 'Closed'   {listClosed.add(jobApp);}
                }
            }
        }

        // Early exit: if no record changed status, there's nothing to do.
        // This avoids unnecessary processing and DML when only non-status fields were edited.
        if(statusesChanged == false) { 
            return; 
        }
            
        // Create a reusable Task template with default field values.
        // Each helper method clones this template, which avoids repeating
        // the same field assignments and keeps defaults consistent.
        Task taskTemplate = taskHelper();

        // Call the appropriate helper method for each status that has records.
        // Each helper returns a list of Tasks, which are added to the master list.
        // Checking isEmpty() first avoids calling methods with no records to process.
        if(!listSaved.isEmpty()) {
            tasksToInsert.addAll(jobAppStatusSaved(listSaved, taskTemplate));
        }
        if(!listApplying.isEmpty()) {
            tasksToInsert.addAll(jobAppStatusApplying(listApplying, taskTemplate));
        }
        if(!listApplied.isEmpty()) {
            tasksToInsert.addAll(jobAppStatusApplied(listApplied, taskTemplate));
        }
        if(!listInterviewing.isEmpty()) {
            tasksToInsert.addAll(jobAppStatusInterviewing(listInterviewing, taskTemplate));
        }
        if(!listNegotiating.isEmpty()) {
            tasksToInsert.addAll(jobAppStatusNegotiating(listNegotiating, taskTemplate));
        }
        if(!listAccepted.isEmpty()) {
            tasksToInsert.addAll(jobAppStatusAccepted(listAccepted, taskTemplate));
        }
        if(!listClosed.isEmpty()) {
            tasksToInsert.addAll(jobAppStatusClosed(listClosed, taskTemplate));
        }

        // Bulk insert all Tasks in a single DML statement.
        // This is critical for governor limit compliance — inserting one list
        // instead of inserting inside each helper method or each loop iteration.
        if(!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }

    }
        


/// *** HELPER METHODS *** ///

    /**
     * taskHelper - Creates a reusable Task template with default values.
     * 
     * Approach: By defining defaults in one place, all status-specific methods
     * can clone() this template and only override what differs (Subject, WhatId).
     * This follows DRY (Don't Repeat Yourself) and makes future changes to
     * defaults easy — update once here instead of in every method.
     * 
     * clone(false, true, false, false) = no Id, deep clone, no auto-number, no preserve Id
     */
    private static Task taskHelper() {
        Task taskTemplate = new Task(
            Status = 'Not Started',
            Type = 'Other',
            OwnerId = UserInfo.getUserId(),       // Assigns task to the current user
            ActivityDate = System.today().addDays(1), // Due tomorrow by default
            Priority = 'Normal'
        );

        return taskTemplate;
    }

    /**
     * jobAppStatusSaved - Creates 3 Tasks for Job Applications moved to 'Saved' status.
     * Tasks guide the user to evaluate whether the role is worth pursuing.
     * Each task is cloned from the template so it inherits the default values.
     */
    private static List<Task> jobAppStatusSaved(List<Job_Application__c> jobApplications, Task taskTemplate) {
        List<Task> taskList = new List<Task>();

        for(Job_Application__c jobApp : jobApplications) {

            Task task1 = taskTemplate.clone(false, true, false, false);
            task1.WhatId = jobApp.Id;  // Links the Task to the Job Application record
            task1.Subject = 'Ensure job description aligns with interests and values';
            taskList.add(task1);

            Task task2 = taskTemplate.clone(false, true, false, false);
            task2.WhatId = jobApp.Id;
            task2.Subject = 'Review highlighted skills to ensure good role fit';
            taskList.add(task2);

            Task task3 = taskTemplate.clone(false, true, false, false);
            task3.WhatId = jobApp.Id;
            task3.Subject = 'Research the company or role and mark excitement level';
            taskList.add(task3);
        
        }

        return taskList;

    }

    /**
     * jobAppStatusApplying - Creates 5 Tasks for Job Applications moved to 'Applying' status.
     * Tasks focus on networking, research, and application preparation steps.
     */
    private static List<Task> jobAppStatusApplying(List<Job_Application__c> jobApplications, Task taskTemplate) {
        List<Task> taskList = new List<Task>();

        for(Job_Application__c jobApp : jobApplications) {

            Task task1 = taskTemplate.clone(false, true, false, false);
            task1.WhatId = jobApp.Id;
            task1.Subject = 'Find and research someone who works at the company and add them as a contact';
            taskList.add(task1);

            Task task2 = taskTemplate.clone(false, true, false, false);
            task2.WhatId = jobApp.Id;
            task2.Subject = 'Set up an informational interview to learn more about the role/company';
            taskList.add(task2);

            Task task3 = taskTemplate.clone(false, true, false, false);
            task3.WhatId = jobApp.Id;
            task3.Subject = 'Identify potential referrals to help get your application on the top of the pile';
            taskList.add(task3);

            Task task4 = taskTemplate.clone(false, true, false, false);
            task4.WhatId = jobApp.Id;
            task4.Subject = 'Customize your work achievements using the job description keywords';
            taskList.add(task4);

            Task task5 = taskTemplate.clone(false, true, false, false);
            task5.WhatId = jobApp.Id;
            task5.Subject = 'Submit your application on the company website if possible';
            taskList.add(task5);
        }

        return taskList;
    }

    /**
     * jobAppStatusApplied - Creates 4 Tasks for Job Applications moved to 'Applied' status.
     * Tasks encourage follow-up outreach and continued job searching.
     */
    private static List<Task> jobAppStatusApplied(List<Job_Application__c> jobApplications, Task taskTemplate) {
        List<Task> taskList = new List<Task>();

        for(Job_Application__c jobApp : jobApplications) {
            Task task1 = taskTemplate.clone(false, true, false, false);
            task1.WhatId = jobApp.Id;
            task1.Subject = 'Reach out to the hiring manager or recruiter';
            taskList.add(task1);

            Task task2 = taskTemplate.clone(false, true, false, false);
            task2.WhatId = jobApp.Id;
            task2.Subject = 'Follow up on your application via email weekly';
            taskList.add(task2);

            Task task3 = taskTemplate.clone(false, true, false, false);
            task3.WhatId = jobApp.Id;
            task3.Subject = 'Continue identifying and saving similar job opportunities';
            taskList.add(task3);

            Task task4 = taskTemplate.clone(false, true, false, false);
            task4.WhatId = jobApp.Id;
            task4.Subject = 'Set up weekly networking calls to explore similar companies/roles';
            taskList.add(task4);
        }

        return taskList;
    }

    /**
     * jobAppStatusInterviewing - Creates 5 Tasks for Job Applications moved to 'Interviewing' status.
     * Tasks cover interview preparation, research, and post-interview etiquette.
     */
    private static List<Task> jobAppStatusInterviewing(List<Job_Application__c> jobApplications, Task taskTemplate) {
        List<Task> taskList = new List<Task>();

        for(Job_Application__c jobApp : jobApplications) {

            Task task1 = taskTemplate.clone(false, true, false, false);
            task1.WhatId = jobApp.Id;
            task1.Subject = 'Prepare your blurb or “tell me about yourself” response';
            taskList.add(task1);

            Task task2 = taskTemplate.clone(false, true, false, false);
            task2.WhatId = jobApp.Id;
            task2.Subject = 'Practice answering behavioral interview questions';
            taskList.add(task2);

            Task task3 = taskTemplate.clone(false, true, false, false);
            task3.WhatId = jobApp.Id;
            task3.Subject = 'Research the company and your interviewers';
            taskList.add(task3);

            Task task4 = taskTemplate.clone(false, true, false, false);
            task4.WhatId = jobApp.Id;
            task4.Subject = 'Set up your virtual interview space and test your tech';
            taskList.add(task4);

            Task task5 = taskTemplate.clone(false, true, false, false);
            task5.WhatId = jobApp.Id;
            task5.Subject = 'Send thank you emails within 24 hours';
            taskList.add(task5);
        }

        return taskList;
    }
        
    /**
     * jobAppStatusNegotiating - Creates 3 Tasks for Job Applications moved to 'Negotiating' status.
     * Tasks guide salary research, script preparation, and final offer evaluation.
     */
    private static List<Task> jobAppStatusNegotiating(List<Job_Application__c> jobApplications, Task taskTemplate) {
        List<Task> taskList = new List<Task>();

        for(Job_Application__c jobApp : jobApplications) {

            Task task1 = taskTemplate.clone(false, true, false, false);
            task1.WhatId = jobApp.Id;
            task1.Subject = 'Research your market value and know your numbers';
            taskList.add(task1);

            Task task2 = taskTemplate.clone(false, true, false, false);
            task2.WhatId = jobApp.Id;
            task2.Subject = 'Prepare your negotiation scripts';
            taskList.add(task2);

            Task task3 = taskTemplate.clone(false, true, false, false);
            task3.WhatId = jobApp.Id;
            task3.Subject = 'Evaluate your offer and decline or accept';
            taskList.add(task3);
        }

        return taskList;
    }

    /**
     * jobAppStatusAccepted - Creates 3 Tasks for Job Applications moved to 'Accepted' status.
     * Tasks cover resignation planning, self-care, and onboarding prep.
     */
    private static List<Task> jobAppStatusAccepted(List<Job_Application__c> jobApplications, Task taskTemplate) {
        List<Task> taskList = new List<Task>();

        for(Job_Application__c jobApp : jobApplications) {
            
            Task task1 = taskTemplate.clone(false, true, false, false);
            task1.WhatId = jobApp.Id;
            task1.Subject = 'Plan your resignation if applicable';
            taskList.add(task1);

            Task task2 = taskTemplate.clone(false, true, false, false);
            task2.WhatId = jobApp.Id;
            task2.Subject = 'Take some time to relax and recharge';
            taskList.add(task2);

            Task task3 = taskTemplate.clone(false, true, false, false);
            task3.WhatId = jobApp.Id;
            task3.Subject = 'Prepare for your first day of onboarding';
            taskList.add(task3);
        }

        return taskList;
    }

    /**
     * jobAppStatusClosed - Creates 2 Tasks for Job Applications moved to 'Closed' status.
     * Tasks encourage reflection and maintaining professional relationships.
     */
    private static List<Task> jobAppStatusClosed(List<Job_Application__c> jobApplications, Task taskTemplate) {
        List<Task> taskList = new List<Task>();

        for(Job_Application__c jobApp : jobApplications) {

            Task task1 = taskTemplate.clone(false, true, false, false);
            task1.WhatId = jobApp.Id;
            task1.Subject = 'Send a follow-up email thanking the interviewer and asking for feedback';
            taskList.add(task1);

            Task task2 = taskTemplate.clone(false, true, false, false);
            task2.WhatId = jobApp.Id;
            task2.Subject = 'Review your notes and reflect on areas of improvement';
            taskList.add(task2);
        }

        return taskList;
    }

}
