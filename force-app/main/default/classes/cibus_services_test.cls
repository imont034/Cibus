@isTest
public with sharing class cibus_services_test {
    public @IsTest
    static void testPost(){
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonService = '{' +
                                '"name" : "New Service",'+ 
                                '"alternate_name" : "aka",' +
                                '"description" : "This is a description",' + 
                                '"url" : "https://www.hungerfreeamerica.org",'+
                                '"email" : "arains@hungerfreeamerica.org",' +
                                '"status" : "active",' +
                                '"interpretation_services" : "Interpretation",' +
                                '"application_process" : "Application",' +
                                '"wait_time" : "2 hours",' +
                                '"fees" : "$0",' +
                                '"accreditations" : "street cred",' +
                                '"licenses" : "License to kill..."'+
                                '}';

        
        //request.requestURI = 'https://sandbox-cibus-developer-edition.cs91.force.com/services/apexrest/V00/services/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
/*
        request.requestBody = Blob.valueOf(jsonService);
        RestContext.request = request;
        cibus_services.createService(jsonService);
        System.debug(RestContext.request);
        RestContext.response = res;
        System.debug('----Res Body:' + res.responseBody);  
        System.assertEquals(blob.valueOf(jsonService), res.responseBody);
*/
        String response = cibus_services.createService(jsonService);
        System.debug(response);
        cibus_services.HSDSService s = (cibus_services.HSDSService)JSON.deserialize(response, cibus_services.HSDSService.class);
        String serviceId = s.id;
        String expectedJSON =   '{\n' +
                                '  "id" : "' + serviceId + '",\n' +
                                '  "name" : "New Service",\n'+ 
                                '  "alternate_name" : "aka",\n' +
                                '  "description" : "This is a description",\n' + 
                                '  "url" : "https://www.hungerfreeamerica.org",\n'+
                                '  "emial" : "arains@hungerfreeamerica.org",\n' +
                                '  "status" : "active",\n' +
                                '  "interpretation_services" : "Interpretation",\n' +
                                '  "application_process" : "Application",\n' +
                                '  "wait_time" : "2 hours",\n' +
                                '  "fees" : "$0",\n' +
                                '  "accreditations" : "street cred",\n' +
                                '  "licenses" : "License to kill..."\n'+
                                '}';
        

        System.assertEquals(expectedJSON, response);
    }

    @isTest
    static void testGet(){
        Id serviceId = createTestRecord();
        String expectedJSON =   '[ {\n' +
                                '  "id" : "' + serviceId + '",\n' +
                                '  "name" : "New Service",\n'+ 
                                '  "alternate_name" : "aka",\n' +
                                '  "description" : "This is a description",\n' + 
                                '  "url" : "https://www.hungerfreeamerica.org",\n'+
                                '  "emial" : "arains@hungerfreeamerica.org",\n' +
                                '  "status" : "active",\n' +
                                '  "interpretation_services" : "Interpretation",\n' +
                                '  "application_process" : "Application",\n' +
                                '  "wait_time" : "2 hours",\n' +
                                '  "fees" : "$0",\n' +
                                '  "accreditations" : "street cred",\n' +
                                '  "licenses" : "License to kill..."\n'+
                                '} ]';
       
        RestRequest request = new RestRequest();
        request.requestURI = 'https://na112.salesforce.com/services/apexrest/services/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        String res = cibus_services.getServices();
        System.debug(res);
        System.assertEquals(expectedJSON, res);

        request = new RestRequest();
        request.requestURI = 'https://na112.salesforce.com/services/apexrest/services?query=name=New%20Service&sort_by=name&order=asc&per_page=1';
        request.httpMethod = 'GET';
        RestContext.request = request;
        res = cibus_services.getServices();
        System.debug(res);
        System.assertEquals(expectedJSON, res);
        //TODO: add more test cases for multipe qury params, pagination, and sort order
    }

    @isTest
    static void testGetParams(){
        String uri = 'https://na112.salesforce.com/services/apexrest/services?query=foo=bar,color=blue&sort_by=name&order=asc';
        Map<String, String> params = cibus_services.getURLParams(uri);
        Set <String> keySet = params.keySet();
        for(String field : keySet){
            System.debug(field + ' : ' + params.get(field));
        }
        System.assertEquals('foo=bar,color=blue',params.get('query'));
        System.assertEquals('name', params.get('sort_by'));
        System.assertEquals('asc', params.get('order'));
    }

    @isTest
    static void testGenJCampaignsSON(){
        Id serviceId = createTestRecord();
        String expectedJSON =   '[ {\n' +
                                '  "id" : "' + serviceId + '",\n' +
                                '  "name" : "New Service",\n'+ 
                                '  "alternate_name" : "aka",\n' +
                                '  "description" : "This is a description",\n' + 
                                '  "url" : "https://www.hungerfreeamerica.org",\n'+
                                '  "emial" : "arains@hungerfreeamerica.org",\n' +
                                '  "status" : "active",\n' +
                                '  "interpretation_services" : "Interpretation",\n' +
                                '  "application_process" : "Application",\n' +
                                '  "wait_time" : "2 hours",\n' +
                                '  "fees" : "$0",\n' +
                                '  "accreditations" : "street cred",\n' +
                                '  "licenses" : "License to kill..."\n'+
                                '} ]';
        
        cibus_service__c s = [SELECT id, name, alternate_name__c, description__c, url__c,  email__c, status__c, Interpretation_Services__c, Application_Process__c, Wait_Time__c, Fees__c, Accreditation__c, Licenses__c FROM cibus_service__c WHERE id =: serviceId];
        String json = cibus_services.genJSON(s, true, true);
        System.debug(json);
        System.assertEquals(expectedJSON, json);  
    }

    static Id createTestRecord(){
        cibus_service__c s = new cibus_service__c(
            name='New Service',
            alternate_name__c = 'aka',
            description__c = 'This is a description',
            url__c = 'https://www.hungerfreeamerica.org',
            email__c = 'arains@hungerfreeamerica.org',
            status__c = 'active',
            Interpretation_Services__c = 'Interpretation',
            Application_Process__c = 'Application',
            Wait_Time__c = '2 hours',
            Fees__c = '$0',
            Accreditation__c = 'street cred',
            Licenses__c = 'License to kill...'
        );

        insert s;
        return s.Id;
    }

}