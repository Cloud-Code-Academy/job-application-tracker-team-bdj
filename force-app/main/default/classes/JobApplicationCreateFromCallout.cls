public with sharing class JobApplicationCreateFromCallout {

    // Constructors to deal with Jooble Responses
    public class JoobleResponse {
        public Integer totalCount;            
        public List<JoobleJob> jobs;
    }

    public class JoobleJob {
        public String id;           // Source_Id__c
        public String title;        // Position_Title__c
        public String location;     // Location__c
        public String snippet;      // Description__c 
        public String salary;       // Salary__c
        public String source;       // Sourced_From__c
        public String type;         // Employment_Type__c
        public String link;         // URL__c
        public String company;      // Company_Name__c
        public String updated;      // Application_Date__c
    }

    // Main Method
    public static void createJobAppFromJson(String jsonResponse){

        // Deserialize jsonResponse passed from JoobleCallout class
        JoobleResponse joobleData = (JoobleResponse) JSON.deserialize(jsonResponse, JoobleResponse.class);

        if (joobleData.jobs == null || joobleData.jobs.isEmpty()){
            System.debug('JoobleCallout: Deserialization succeeded but no jobs were returned. Total count: ' + joobleData.totalCount);
            return;
        }

        // Build a set for unique company(account) names
        Set<String> companyNames = new Set<String>();
        for(JoobleJob job : joobleData.jobs){
            if(String.isNotBlank(job.company)){
                companyNames.add(job.company);
            }
        }

        // Query for existing accounts and add to a Map<AccountName, AccountId)
        Map<String, Id> accountsByName = new Map<String, Id>();
        for(Account acc : [SELECT Id, Name FROM Account WHERE Name IN :companyNames]){
            accountsByName.put(acc.Name, acc.Id);
        }

        // Build a list of new accounts by comparing original set to keys in the map
        List<Account> newAccounts = new List<Account>();
        for(String accName : companyNames){
            if(!accountsByName.containsKey(accName)){
                newAccounts.add(new Account(Name = accName));
            }
        }

        // If there are new accounts, insert them and add back to map with Id's
        if(!newAccounts.isEmpty()){
            insert newAccounts;
            for(Account acc : newAccounts){
                accountsByName.put(acc.Name, acc.Id);
            }
        }

        // Build a set for existing Jooble Id's and query for them, if any
        Set<String> joobleIds = new Set<String>();
        for(JoobleJob job : joobleData.jobs){
            if(String.isNotBlank(job.id)){
                joobleIds.add(job.id);
            }
        }

        Set<String> existingJoobleIds = new Set<String>();
        for(Job_Application__c existingJobApp : [SELECT Source_Id__c FROM Job_Application__c WHERE Source_Id__c IN :joobleIds]){
            existingJoobleIds.add(existingJobApp.Source_Id__c);
        }

        // Build new Job Application records and assign to a list for inserts
        List<Job_Application__c> jobAppsToInsert = new List<Job_Application__c>();
        for(JoobleJob job : joobleData.jobs){
            if(existingJoobleIds.contains(job.id)){
                continue;
            }

            Job_Application__c jobApp = new Job_Application__c();
            jobApp.Source_Id__c = job.id;
            jobApp.Position_Title__c = job.title;
            jobApp.Location__c = String.isNotBlank(job.location) ? job.location : 'Unknown';
            jobApp.Description__c = stripHTML(job.snippet);
            jobApp.Salary__c = String.isNotBlank(job.salary) ? job.salary : 'Not Listed';
            jobApp.Sourced_From__c = job.source;
            jobApp.Employment_Type__c = String.isNotBlank(job.type) ? job.type : 'Not Listed';
            jobApp.URL__c = job.link;
            jobApp.Application_Date__c = parseDate(job.updated);
            jobApp.Status__c = 'New';
            jobApp.Name = (job.title + ' - ' + job.company).left(80);

            if(String.isNotBlank(job.company) && accountsByName.containsKey(job.company)){
                jobApp.Company_Name__c = accountsByName.get(job.company);
            }

            jobAppsToInsert.add(jobApp);
        }

        // Insert newly populated list, or skip if list is empty
        if(!jobAppsToInsert.isEmpty()){
            insert jobAppsToInsert;
        }
        
    }

    /// *** HELPER METHODS *** ///
    
    // Strip HTML tags to populate Description__c
    private static String stripHTML(String snippet){
        if(String.isBlank(snippet)){
            return '';
        }

        String cleanSnippet = snippet.stripHtmlTags();
        cleanSnippet = cleanSnippet.replace('&nbsp;', ' ')
                                   .replace('&amp;',  '&')
                                   .replace('&lt;',   '<')
                                   .replace('&gt;',   '>')
                                   .replace('&quot;', '"');
        cleanSnippet = cleanSnippet.replaceAll('\\s+', ' ').trim();
        return cleanSnippet;
    }

    // Correct the date format of 'updated' for Application_Date__c
    private static Date parseDate(String updated){
        if(String.isBlank(updated)) {
            return Date.today();
        }
        try{
            // Jooble's format: "2026-03-06T00:00:00.0000000"
            return Date.valueOf(updated.substring(0, 10));
        } catch(Exception e) {
            return Date.today();
        }
    }

}
