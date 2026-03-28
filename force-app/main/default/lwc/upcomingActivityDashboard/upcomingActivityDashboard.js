import { LightningElement, wire } from 'lwc';

//import files
import getUpcomingInterviews from '@salesforce/apex/UpcomingActivityController.getUpcomingInterviews';
import getUpcomingTasks from '@salesforce/apex/UpcomingActivityController.getUpcomingTasks';

export default class UpcomingActivityDashboard extends LightningElement {

    // These hold the data returned from Apex
    interviews = [];
    tasks = [];

    // These hold any errors so we can display them
    interviewError;
    taskError;
        // Filter values
    selectedRange = '7';
    selectedStatus = 'All';

    // Dropdown options for time range
    rangeOptions = [
        { label: 'Next 7 Days', value: '7' },
        { label: 'Next 14 Days', value: '14' },
        { label: 'Next 30 Days', value: '30' }
    ];

    // Dropdown options for task status filter
    statusOptions = [
        { label: 'All', value: 'All' },
        { label: 'Not Started', value: 'Not Started' },
        { label: 'In Progress', value: 'In Progress' }
    ];

    handleRangeChange(event) {
        this.selectedRange = event.detail.value;
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
    }

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
                RelatedTo: task.What?.Name || '',
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
    get filteredTasks() {
        if(this.selectedStatus === 'All'){
        return this.tasks;
        }
        return this.tasks.filter(task => task.Status === this.selectedStatus);
    }
get hasTasks() {
        return this.filteredTasks.length> 0;
    }
    get interviewTabLabel() {
        return 'Interviews (' + this.interviews.length+')';
    }
    get taskTabLabel(){
        return 'Tasks ('+ this.filteredTasks.length+ ')';
    }

    get hasNoData(){
        return !this.hasInterviews && !this.hasTasks;
}
}