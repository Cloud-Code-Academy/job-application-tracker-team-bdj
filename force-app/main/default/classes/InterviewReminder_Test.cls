@isTest
private class InterviewReminder_Test{

    //Gets the next weekday from today so event dates never land on weekends
    static Date getNextWeekday() {
        Date d = System.today();
        DateTime dt = DateTime.newInstance(d, Time.newInstance(0,0,0,0));
        String dayOfWeek = dt.format('u'); // 1=Mon ... 5=Fri, 6=Sat, 7=Sun
        if (dayOfWeek == '6') d = d.addDays(2);      //Saturday -> Monday
        else if (dayOfWeek == '7') d = d.addDays(1);  //Sunday -> Monday
        else if (dayOfWeek == '5') d = d.addDays(3);  //Friday -> Monday (so tomorrow is Tuesday)
        return d;
    }

    static final Date BASE_DATE = getNextWeekday();
    static final Date TOMORROW = BASE_DATE.addDays(1);

    @TestSetup
    static void setupData() {
        //creating an event setup for tomorrow
        Event tomorrowInterview = new Event (
            Subject = 'Testing Interview',
            StartDateTime = DateTime.newInstance(TOMORROW, Time.newInstance(9,0,0,0)),
            EndDateTime = DateTime.newInstance(TOMORROW, Time.newInstance(10,0,0,0)),
            Location = 'Zoom',
            Description = 'interview with hiring manager'
        );
        insert tomorrowInterview;
    }

    @IsTest
    static void reminderSendsEmail_interviewTomorrow() {
        //Tell the reminder class to treat BASE_DATE as "today"
        InterviewReminder.referenceDate = BASE_DATE;

        Test.startTest();
        InterviewReminder reminder = new InterviewReminder();
        reminder.execute(null);
        //Make sure the email was called
        Assert.areEqual(1, InterviewReminder.emailsSentCount, 'One email should have been built');
        Test.stopTest();
    }

    @IsTest
    static void reminderNoEmail_interviewToday() {
        //Create an event for BASE_DATE (Monday) instead of tomorrow.
        Event todayInterview = new Event(
            Subject = 'Today Interview',
            StartDateTime = DateTime.newInstance(BASE_DATE, Time.newInstance(10,0,0,0)),
            EndDateTime = DateTime.newInstance(BASE_DATE, Time.newInstance(11,0,0,0))

        );
        insert todayInterview;

        //Delete the tomorrow interview from test setup so there is only an interview for today.
        delete [SELECT Id FROM Event WHERE Subject = 'Testing Interview'];  
    
        //Tell the reminder class to treat BASE_DATE as "today"
        InterviewReminder.referenceDate = BASE_DATE;

        Test.startTest();
        InterviewReminder reminder = new InterviewReminder();
        reminder.execute(null);
        Assert.areEqual(0, InterviewReminder.emailsSentCount, 'No emails should be sent for today interviews');
        Test.stopTest();

    }
@IsTest
static void reminderNoEmail_interviewNextWeek() { 
    //Delete tomorrows event and create one for next week instead
    delete [SELECT Id FROM Event WHERE Subject = 'Testing Interview'];

    Event nextWeekInterview = new Event(
        Subject = 'Next Week Interview',
        StartDateTime = DateTime.newInstance(BASE_DATE.addDays(7), Time.newInstance(9,0,0,0)),
        EndDateTime = DateTime.newInstance(BASE_DATE.addDays(7), Time.newInstance(10,0,0,0))
        );
        insert nextWeekInterview;

        //Tell the reminder class to treat BASE_DATE as "today"
        InterviewReminder.referenceDate = BASE_DATE;

        Test.startTest();
        InterviewReminder reminder = new InterviewReminder();
        reminder.execute(null);
        Assert.areEqual(0, InterviewReminder.emailsSentCount, 'No emails should be sent for next week interviews');
        Test.stopTest();
    }


@IsTest
static void remindersSendsEmail_bulk() { 
    //Delete Single Interview from test setup
    delete[SELECT Id FROM Event WHERE Subject = 'Testing Interview'];

    //Create bulk records at different times
    List<Event> bulkInterviews = new List<Event>();
    for (Integer i = 0; i < 5; i++) {
        bulkInterviews.add(new Event(
            Subject = 'Bulk Interview' + i,
            StartDateTime = DateTime.newInstance(TOMORROW, Time.newInstance(8+i,0,0,0)),
            EndDateTime = DateTime.newInstance(TOMORROW, Time.newInstance(9 + i,0,0,0)),
            Location = 'Zoom',
            Description = 'Bulk test interview number'+ i
        ));

    }
    insert bulkInterviews;

    //Tell the reminder class to treat BASE_DATE as "today"
    InterviewReminder.referenceDate = BASE_DATE;

    Test.startTest();
    InterviewReminder reminder = new InterviewReminder();
    reminder.execute(null);
    //Use invocation to only call once on for 5 emails.
    Assert.areEqual(5, InterviewReminder.emailsSentCount, '5 emails should have been built for all 5 interviews');
    Test.stopTest();
    }
}