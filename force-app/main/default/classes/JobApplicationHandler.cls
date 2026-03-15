public with sharing class JobApplicationHandler {

    public static void afterUpdate(List<Job_Application__c> newJobList, Map<Id, Job_Application__c> oldJobMap) {

        // Initialize job app & task lists //
        List<Job_Application__c> listSaved = new List<Job_Application__c>();
        List<Job_Application__c> listApplying = new List<Job_Application__c>();
        List<Job_Application__c> listApplied = new List<Job_Application__c>();
        List<Job_Application__c> listInterviewing = new List<Job_Application__c>();
        List<Job_Application__c> listNegotiating = new List<Job_Application__c>();
        List<Job_Application__c> listAccepted = new List<Job_Application__c>();
        List<Job_Application__c> listClosed = new List<Job_Application__c>();
        List<Task> tasksToInsert = new List<Task>();

        // Initialize boolean variable to check for status changes
        Boolean statusesChanged = false;
        
        // Evaluate if Status has changed
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

        // Verify that at least one list has records
        if(statusesChanged == false) { 
            return; 
        }
            
        // Initialize task template //
        Task taskTemplate = taskHelper();

        // Call helper methods for new Job App records with a changed Status //
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

        if(!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }

    }
        


/// *** HELPER METHODS *** ///

    private static Task taskHelper() {
        Task taskTemplate = new Task(
            Status = 'Not Started',
            Type = 'Other',
            OwnerId = UserInfo.getUserId(),
            ActivityDate = System.today().addDays(1),
            Priority = 'Normal'
        );

        return taskTemplate;
    }

    private static List<Task> jobAppStatusSaved(List<Job_Application__c> jobApplications, Task taskTemplate) {
        // Initialize task list to pass back to the caller method //
        List<Task> taskList = new List<Task>();

        // Loop through the list of passed Job Applications to build the Tasks for them //
        for(Job_Application__c jobApp : jobApplications) {

            Task task1 = taskTemplate.clone(false, true, false, false);
            task1.WhatId = jobApp.Id;
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

    private static List<Task> jobAppStatusApplying(List<Job_Application__c> jobApplications, Task taskTemplate) {
        // Initialize task list to pass back to the caller method //
        List<Task> taskList = new List<Task>();

        // Loop through the list of passed Job Applications to build the Tasks for them //
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

    private static List<Task> jobAppStatusApplied(List<Job_Application__c> jobApplications, Task taskTemplate) {
        // Initialize task list to pass back to the caller method //
        List<Task> taskList = new List<Task>();

        // Loop through the list of passed Job Applications to build the Tasks for them //
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

    private static List<Task> jobAppStatusInterviewing(List<Job_Application__c> jobApplications, Task taskTemplate) {
        // Initialize task list to pass back to the caller method //
        List<Task> taskList = new List<Task>();

        // Loop through the list of passed Job Applications to build the Tasks for them //
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
        
    private static List<Task> jobAppStatusNegotiating(List<Job_Application__c> jobApplications, Task taskTemplate) {
        // Initialize task list to pass back to the caller method //
        List<Task> taskList = new List<Task>();

        // Loop through the list of passed Job Applications to build the Tasks for them //
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

    private static List<Task> jobAppStatusAccepted(List<Job_Application__c> jobApplications, Task taskTemplate) {
        // Initialize task list to pass back to the caller method //
        List<Task> taskList = new List<Task>();

        // Loop through the list of passed Job Applications to build the Tasks for them //
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

    private static List<Task> jobAppStatusClosed(List<Job_Application__c> jobApplications, Task taskTemplate) {
        // Initialize task list to pass back to the caller method //
        List<Task> taskList = new List<Task>();

        // Loop through the list of passed Job Applications to build the Tasks for them //
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