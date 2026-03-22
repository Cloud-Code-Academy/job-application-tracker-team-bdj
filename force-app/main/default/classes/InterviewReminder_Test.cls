@IsTest
private class InterviewReminder_Test {

    @TestSetup
    static void setupData() {
        //creating an event setup for tomorrow 
        Event tomorrowInterview = new Event (
            Subject = 'Testing Interview',
            StartDateTime = DateTime.newInstance(System.today().addDays(1), Time.newInstance(9,0,0,0)),
            EndDateTime = DateTime.newInstance(System.today().addDays(1), Time.newInstance(10,0,0,0)),
            Location = 'Zoom',
            Description = 'interview with hiring manager'
        );
        insert tomorrowInterview;
    }

    @IsTest
    static void reminderSendsEmail_interviewTomorrow() {
        Test.startTest();
        InterviewReminder reminder = new InterviewReminder();
        reminder.execute(null);
        Test.stopTest();
    
        //Make sure the email was called
        Assert.areEqual(1, Limits.getEmailInvocations(), 'One email send call should have been made');
    }

    @IsTest
    static void reminderNoEmail_interviewToday() {
        //Create an event for today instead of tomorrow. 
        Event todayInterview = new Event(
            Subject = 'Today Interview',
            StartDateTime = DateTime.newInstance(System.today(), Time.newInstance(10,0,0,0)),
            EndDateTime = DateTime.newInstance(System.today(), Time.newInstance(11,0,0,0))

        );
        insert todayInterview;

        //Delete the tomorrow interview from test setup so there is only an interview for today.
        delete [SELECT Id FROM Event WHERE Subject = 'Testing Interview'];  
    
        Test.startTest();
        InterviewReminder reminder = new InterviewReminder();
        reminder.execute(null);
        Test.stopTest();

        Assert.areEqual(0, Limits.getEmailInvocations(), 'No emails should be sent for today interviews');

    }
@IsTest
static void reminderNoEmail_interviewNextWeek() { 
    //Delete tomorrows event and create one for next week instead
    delete [SELECT Id FROM Event WHERE Subject = 'Testing Interview'];

    Event nextWeekInterview = new Event(
        Subject = 'Next Week Interview',
        StartDateTime = DateTime.newInstance(System.today().addDays(7), Time.newInstance(9,0,0,0)),
        EndDateTime = DateTime.newInstance(System.today().addDays(7), Time.newInstance(11,0,0,0))
        );
        insert nextWeekInterview;

        Test.startTest();
        InterviewReminder reminder = new InterviewReminder();
        reminder.execute(null);
        Test.stopTest();

        Assert.areEqual(0,Limits.getEmailInvocations(), 'No emails should be sent for next week interviews');
    }
}

