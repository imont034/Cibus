/*
*   cibus_services.cls
*   Auth: Atticus Rains
*   Date: 2019-11-6
*   Desc: The project Cibus /services/ endpoint.
*/

@RestResource(urlMapping='/V00/services/')
global with sharing class cibus_services {

/*
* an apex type to describe an HSDS compliant service
* SF service object may not be 1:1 w/ HSDS,
* because of this we cannot deserialize the request body into the SF object directly.
*/
public class HSDSService {
    public String id;
    public String organization_id;
    public String program_id;
    public String location_id;
    public String name;
    public String alternate_name;
    public String description;
    public String url;
    public String email;
    public String status;
    public String interpretation_services;
    public String application_process;
    public String wait_time;
    public String fees;
    public String accreditations;
    public String licenses;
}

    @HttpGet
    global static void getServices(){
        //TODO: all of this
    }  

    @HttpPost
    global static void createService(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug(LoggingLevel.ERROR, req.requestBody.toString());
        //TODO: Authenticate user, return 403 if auth fails
        
        HSDSService s = (HSDSService)JSON.deserialize(req.requestBody.toString(), HSDSService.class);
        cibus_service__c service = new cibus_service__c();
        
        //convert HSDSService (s) to cibus_service__c (service)
        //TODO: org_id, program_id, location_id
        service.name = s.name;
        service.alternate_name__c = s.alternate_name;
        service.description__c =  s.description;
        service.url__c = s.url;
        service.email__c = s.email;
        service.status__c = s.status;
        service.Interpretation_Services__c	= s.interpretation_services;
        service.Application_Process__c = s.application_process;
        service.Wait_Time__c = s.wait_time;
        service.Fees__c = s.fees;
        service.Accreditation__c = s.accreditations;
        service.Licenses__c = s.licenses;

        insert service;
        res.statusCode = 200;
        res.responseBody = req.requestBody;
        System.debug(res.responseBody);
        
        //TODO: on success send 200 response
        //TODO: check for duplicates before insertion
        //TODO: send service to staging before insertion

    }

}