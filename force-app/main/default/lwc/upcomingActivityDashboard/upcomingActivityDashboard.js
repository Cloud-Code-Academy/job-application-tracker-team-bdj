// Import the base LightningElement class and the wire decorator
// wire automatically calls our Apex methods when the component loads
import { LightningElement, wire } from 'lwc';

// Import our two Apex methods from the controller we just created
import getUpcomingInterviews from '@salesforce/apex/UpcomingActivityController.getUpcomingInterviews';
import getUpcomingTasks from '@salesforce/apex/upcomingActivityController.getUpcomingTasks';

export default class UpcomingActivityDashboard extends LightningElement {

    // These hold the data returned from Apex
    interviews = [];
    tasks = [];

    // These hold any errors so we can display them
    interviewError;
    taskError;

    @wire(getUpcomingInterviews)
    wiredInterviews({ data, error }) {
        if (data) {
            this.interviews = data.map(event => ({
                Id: event.Id,
                Subject: event.Subject,
                StartDateTime: event.StartDateTime,
                EndDateTime: event.EndDateTime,
                FormattedDate: new Date(event.StartDateTime).toLocaleString('en-US', {
                    weekday: 'short',
                    month: 'short',
                    day: 'numeric',
                    hour: 'numeric',
                    minute: '2-digit'
                })
            }));
            this.interviewError = undefined;
        } else if (error) {
            this.interviewError = error.body?.message || 'Error loading interviews';
            this.interviews = [];
        }
    }

    @wire(getUpcomingTasks)
    wiredTasks({ data, error }) {
        if (data) {
            this.tasks = data.map(task => ({
                Id: task.Id,
                Subject: task.Subject,
                ActivityDate: task.ActivityDate,
                Status: task.Status,
                Priority: task.Priority,
                RelatedTo: task.What.Name,
                FormattedDate: new Date(task.ActivityDate + 'T00:00:00').toLocaleString('en-US', {
                    weekday: 'short',
                    month: 'short',
                    day: 'numeric'
                })
            }));
            this.taskError = undefined;
        } else if (error) {
            this.taskError = error.body?.message || 'Error loading tasks';
            this.tasks = [];
        }
    }

    get hasInterviews() {
        return this.interviews.length > 0;
    }

    get hasTasks() {
        return this.tasks.length > 0;
    }

    get hasNoData() {
        return !this.hasInterviews && !this.hasTasks;
    }
}
