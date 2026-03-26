@isTest
public with sharing class JoobleCalloutMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest request){

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setBody(
            '{"totalCount":2,"jobs":[{"id":"12345","title":"Salesforce Developer","location":"Remote","snippet":"A great <b>Salesforce</b> job","salary":"$100k - $120k","source":"Lensa.com","type":"Full-Time","link":"https://jooble.org/away/12345","company":"Test Company One","updated":"2026-03-06T00:00:00.0000000"},{"id":"67890","title":"Salesforce Admin","location":"Charlotte, NC","snippet":"Another &nbsp; great job","salary":"","source":"appcast.io","type":"","link":"https://jooble.org/away/67890","company":"Test Company Two","updated":"2026-03-09T00:00:00.0000000"}]}'
        );
        
        return response;
    }

    public class FailMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            response.setBody('Internal Server Error');
            
            return response;
        }
    }

    public class EmptyMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setBody('{"totalCount":0,"jobs":[]}');
            
            return response;
        }
    }

    public class BadDateMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setBody(
                '{"totalCount":2,"jobs":[{"id":"22222","title":"Salesforce Developer","location":"Remote","snippet":"Test","salary":"","source":"Test","type":"","link":"https://jooble.org/away/22222","company":"Test Company","updated":""},{"id":"33333","title":"Salesforce Admin","location":"Remote","snippet":"Test","salary":"","source":"Test","type":"","link":"https://jooble.org/away/33333","company":"Test Company","updated":"not-a-date"}]}'
            );
        
            return response;
    }
}

}