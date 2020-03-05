@RestResource(urlMapping='/V00/eligibility/')
global with sharing class cibus_Eligibility 
{
 
    public class HSDSEligibility
    {
        public String id;
        public String service_id;
        public String eligibility;
    }

    //Mapping from HSDS 
    public static final Map<SObjectField, String> fieldMapping = new Map<SObjectField, String>
    {
            //"__c" custom object field
            eligibility__c.id => 'id',
            eligibility__c.service__c => 'service_id',
            eligibility__c.eligibility__c => 'eligibility'
    };
    /**
     * @description: Handles GET requests on /services/
     */
    @HttpGet
    global static String getEligibility()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //takes URL encoding and formats it into plain text
        String reqURI = EncodingUtil.urlDecode(req.requestURI, 'UTF-8');

        // valid parameters we allow people to search by that will include the enum 
        //constraints and id
    
        //We want to be able to include enum constraints as parameters
        //String[] validParams = new String[]{'id', 'service_id','adult','child', 'teen','family','female','male', 'Transgender', 'Transgender - M to F', 'Transgender - F to M' };
        String[] validParams = new String[]{'id', 'service_id', 'eligibility'};

        String query = 'service__r.id, eligibility, id';

        //here we are daying we want all three of the fields FROM the eligibility custom object
        List<Eligibility__c> eligibilities = 'SELECT id, service__r.id, eligibility__c FROM eligibility__c';
        return(genJSON(services, true));


        /*
        *   Should consider including page offsetting parameters
        *   but is not mentioned in openreferral Get method. 
        *   It will be mentioned in the call with openreferral
        */
    }
    /**
     * @description: Handles GET requests on /services/
     */
    @HttpPost
    global static String postEligibility(String body)
    {
        RestRequest req= RestContext.request;
        RestResponse res= new RestResponse();
        System.debug(LoggingLevel.FINEST, body);

        //here you are deserializing the JSON formatted entry into an HSDS input 
        
        HSDSEligibility e = (HSDSEligibility)JSON.deserialize(body, HSDSEligibility.class);
        eligibility__c eligibility = new eligibility__c();

        try{
            eligibility.id = e.id;
            eligibility.service__c = e.service_id;
            eligibility.eligibility__c = e.eligibility;

            insert elgibility;
            //then once all are deserialized and stored within this custom sf object
            //"eligibility" successfully, it'll insert the object into sf
            res.statusCode 200;
            
            //returns the object, but now check what args are for genJSON
            return genJSON(service, true, false);
            }
        catch(DmlException e)
        {
            //if not successful
            res.statusCode = 500;
            return '[\n\t{\n\t\t"code": 500,\n\t\t"message": "Failed to insert service. Internal error message: ' + e.getMessage() +'"\n\t}\n]';
        }
        
    }
    
}
