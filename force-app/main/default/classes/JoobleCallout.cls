public with sharing class JoobleCallout implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext queueContext){

        // Initialize HTTP Request and generate a JSON Body
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://jooble.org/api/6329be08-40b4-4a7a-a9a7-dae3517b1f47');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(generateJsonPayload());

        // Initialize HTTP Response and send the Request
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        // Call JobApplicationCreateFromCallout.createJobAppFromJson to actually build the job apps
        if(response.getStatusCode() >= 200 && response.getStatusCode() <= 299){
            JobApplicationCreateFromCallout.createJobAppFromJson(response.getBody());
        } else {
            System.debug('Jooble callout failed. Status: ' + response.getStatusCode() + ' Body: ' + response.getBody());
        }

    }

    /// *** HELPER METHODS *** ///

    private static String generateJsonPayload(){

        Map<String, String> jsonMap = new Map<String, String>();

        jsonMap.put('keywords', 'Salesforce Developer');
        jsonMap.put('location', 'Remote');
        jsonMap.put('datecreatedfrom', '2026-03-01');

        String jsonPayload = JSON.serialize(jsonMap);
        return jsonPayload;

    }  

}