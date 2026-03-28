/** What cases do I want to test? 
 * Positive 
 * Negative 
 * Destructive
 * 1.No conflicts, two completely different times
 * 2.Exact same time 
 * 3.Partial time overlap
 * 4. back to back (Should be ok unless we want to add the buffer time) 
 * 5. Bulk Insert
 */
@IsTest
private class EventHandler_Test {

@IsTest
static void overlap_noConflict_differentTimes() {

    //This is the first event with no conflict in time. 
    Event event1 =new Event(
        Subject = 'Interview 1',
        StartDAteTime = DateTime.newInstance(2025, 1,6,9,0,0),
        EndDateTime = DateTime.newInstance(2025,1,6,10,0,0)
    );
    insert event1;

    //Creating second event. 
    Event event2 = new Event(
        Subject = 'Interview 2',
        StartDateTime = DateTime.newInstance(2025,1,6,11,0,0),
        EndDateTime = DateTime.newInstance(2025,1,6,12,0,0)
    
    );

    test.startTest();
    insert event2;
    Test.stopTest();

    //Checking that both events saved 
    List<Event> allEvents = [SELECT Id FROM Event];
    Assert.areEqual(2,allEvents.size(), 'Both appointments should be saved. ');
    
    }

@IsTest 
static void overlap_conflict_exactSameTime(){

    //Create the next event. 
    Event event1 = new Event( 
    Subject = 'Interview 1',
    StartDateTime = DateTime.newInstance(2025,1,6,9,0,0),
    EndDateTime =DateTime.newInstance(2025,1,6,10,0,0)
    );
    insert event1;

    //Creating an event at the exact same time. 

    Event event2 = new Event(
        Subject = 'Interview 2',
        StartDateTime = DateTime.newInstance(2025,1,6,9,0,0),
        EndDateTime = DateTime.newInstance(2025,1,6,10,0,0)
    );

    Test.startTest();
try{
    insert event2;
    Assert.fail('Expected an error because the events overlap completely.');
}catch(DmlException error) {
    Assert.isTrue(
        error.getMessage().contains('This interview time conflicts'),
        'Error message should mention the conflict. Got: ' + error.getMessage()
    );
    }
    Test.stopTest();
}

    @IsTest
    static void overlap_conflict_partialOverlap(){

        //Create the first event: Monday 9:00 AM - 10:00 AM
        Event event1 = new Event(
          Subject = 'Interview 1',
          StartDateTime = DateTime.newInstance(2025,1,6,9,0,0),
          EndDateTime = DateTime.newInstance(2025,1,6,10,0,0)
        );
        insert event1;

    //Try to create an event that starts at 9:30 AM (overlaps by 30 min)
        Event event2 = new Event(
            Subject = 'Interview 2',
            StartDateTime = DateTime.newInstance(2025,1,6,9,30,0),
            EndDateTime = DateTime.newInstance(2025,1,6,10,30,0)
        );


        Test.startTest();
        try {
            insert event2;
            Assert.fail('Expected an error because the events partially overlap.');
        } catch (DmlException error) {
            Assert.isTrue(
                error.getMessage().contains('This interview time conflicts'),
                'Error message should mention the conflict. Got: ' + error.getMessage()
           
            );
        }
        Test.stopTest();
    }

@IsTest
static void overlap_noConflict_backToBack() {

        //Creating the first event. Monday 9am - 10am
        Event event1 = new Event( 
            Subject = 'Interview 1', 
            StartDateTime = Datetime.newInstance(2025,1,6,9,0,0),
            EndDateTime = DateTime.newInstance(2025,1,6,10,0,0)
        );
        insert event1;
        
        //Creating an event that starts at the exact same time as an end time. 
        Event event2 = new Event( 
            Subject = 'Interview 2',
            StartDateTime = Datetime.newInstance(2025,1,6,10,0,0),
            EndDateTime = Datetime.newinstance(2025,1,6,11,0,0)       
        );

Test.startTest();
insert event2;
Test.stopTest();

List<Event> allEvents = [SELECT Id FROM Event];
Assert.areEqual(2,allEvents.size(), 'Back to back events should be allowed');

}

@IsTest
static void overlap_noConflict_bulkInsert() {

//Create multiple events are the same day to see if it will prevent you from creating above 3.
List<Event> eventList = new List<Event>();
for(Integer i = 0; i< 5; i++) {
    eventList.add(new Event(
        Subject = 'Interview' + i,
        StartDateTime = DateTime.newInstance(2025,1,6,8 + i, 0,0),
        EndDateTime = DateTime.newInstance(2025,1,6,9 + i, 0,0)
        ));

}

    Test.startTest();
    insert eventList;
    Test.stopTest();

    List<Event> allEvents = [SELECT Id FROM Event];
    Assert.areEqual(5, allEvents.size(), 'All 5 non-overlapping events should be saved');

}
@IsTest 
static void duration_allow_60mins() {
    Event evt = new Event(
        Subject = 'Valid Interview',
        StartDateTime = DateTime.newInstance(2025,1,6,9,0,0),
        EndDateTime = DateTime.newInstance(2025,1,6,10,0,0)
    );

    Test.startTest();
    insert evt;
    Test.stopTest();

    List<Event> allEvents = [SELECT Id FROM Event];
    Assert.areEqual(1,allEvents.size(), 'A 60 minute interview should be allowed.');

}

@IsTest
static void duration_rejection_90mins() {
    Event evt = new Event(
        Subject = 'Interview too long',
        StartDateTime = DateTime.newInstance(2025,1,6,9,0,0),
        EndDateTime = DateTime.newInstance(2025,1,6,10,30,0)
    );
    Test.startTest();
    try {
        insert evt;
        Assert.fail('Expecting an error because the interview is longer than 90mins');
    } catch (DMLException error) {
        Assert.isTrue(
            error.getMessage().contains('60'),
            'Error should mention 60 mins. Got:' + error.getMessage()
            );
        }
        Test.stopTest();
    }
@IsTest
static void businessHours_reject_tooEarly() {
    Event evt = new Event(
        Subject ='Before business hours',
        StartDateTime = DateTime.newInstance(2025,1,6,7,0,0),
        EndDateTime = DateTime.newInstance(2025,1,6,8,0,0)
    );

    Test.startTest();
    try{
        insert evt;
        Assert.fail('Expect an error because the interview starts before 8am.');
    }catch (DMLException error) {
        Assert.isTrue(
            error.getMessage().contains('8'),
            'Error should mention business hours. Got:' +error.getMessage()
            );
    }
    Test.stopTest();
}

@IsTest
static void businessHours_allow_withinHours() {
    Event evt = new Event(
        Subject = 'Normal Interview',
        StartDateTime = DateTime.newInstance(2025,1,6,9,0,0),
        EndDateTime = DateTime.newInstance(2025,1,6,10,0,0)
    );

    Test.startTest();
    insert evt;
    Test.stopTest();

    List<Event> allEvents = [SELECT Id FROM Event];
    Assert.areEqual(1,allEvents.size(),'An interview during business hours is allowed');

}
@IsTest 
static void weekend_reject_saturday() {
    Event evt =new Event(
        Subject = 'Saturday Interview',
        StartDateTime = DateTime.newInstance(2025,1,4,9,0,0),
        EndDateTime = DateTime.newInstance(2025,1,4,10,0,0)

    );

    Test.startTest();
    try{
        insert evt;
        Assert.fail('Expect an error because the interview in on Saturday');
    } catch (DMLException error) {
        Assert.isTrue(
        error.getMessage().contains('weekend'),
        'Error should mention weekends. Got:' + error.getMessage()
        );

    }
    Test.stopTest();  
}

@IsTest 
static void weekend_allow_weekday() {
    Event evt = new Event(
        Subject = 'Monday Interview',
        StartDateTime = DateTime.newInstance(2025,1,6,9,0,0),
        EndDateTime= DateTime.newInstance(2025,1,6,10,0,0)
    );

    Test.startTest();
    insert evt;
    Test.stopTest();

    List<Event> allEvents = [SELECT Id FROM Event];
    Assert.areEqual(1,allEvents.size(), 'A weekday should be allowed');
}

}