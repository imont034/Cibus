/*
*   cibus_services.cls
*   Author: Atticus Rains
*   Date: 2019-11-6
*   Desc: The project Cibus /services/ endpoint.
*/
@RestResource(urlMapping='/V00/services/')
global with sharing class cibus_services {

    /**
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

    //Maps cibus_service__c fields to HSDS
    public static final Map<SObjectField, String> fieldMapping = new Map<SObjectField, String>{
        cibus_service__c.id => 'id',
        cibus_service__c.name => 'name',
        cibus_service__c.alternate_name__c => 'alternate_name',
        cibus_service__c.description__c => 'description',
        cibus_service__c.url__c => 'url',
        cibus_service__c.email__c => 'emial',
        cibus_service__c.status__c => 'status',
        cibus_service__c.Interpretation_Services__c => 'interpretation_services',
        cibus_service__c.Application_Process__c => 'application_process',
        cibus_service__c.Wait_Time__c => 'wait_time',
        cibus_service__c.Fees__c => 'fees',
        cibus_service__c.Accreditation__c => 'accreditations',
        cibus_service__c.Licenses__c => 'licenses'
    };

    
    /**
     * @description: Handels GET requests on /services/
     */
    @HttpGet
    global static void getServices(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String reqUri = EncodingUtil.urlDecode(req.requestURI,'UTF-8');

        String[] validParams = new String[]{'id', 'location_id', 'program_id', 'organization_id', 'name', 'status', 'alternate_name'};

        String query = 'SELECT id, name, alternate_name__c, description__c, url__c,  email__c, status__c, Interpretation_Services__c, Application_Process__c, Wait_Time__c, Fees__c, Accreditation__c, Licenses__c FROM cibus_service__c';

        Integer lim = 100;
        Integer pageNum = 0;
        Integer offset = 0;
        Boolean sortBy, orderDesc = false;


        if(reqUri.contains('?')){
            Map<String, String> params = getURLParams(reqUri);
            for(String field : params.keySet()){

                //pagination
                if(field.equals('page')){
                    pageNum = Integer.valueOf(params.get(field));

                } else if(field.equals('per_page')){
                    if(Integer.valueOf(params.get(field)) < 100) //max reccords per page is 100
                        lim = Integer.valueOf(params.get(field));
                //sorting
                } else if(field.equals('sort_by') && validParams.contains(params.get(field))){
                    sortBy = true;
                    if(params.containsKey('order'))
                        if(params.get('order').equals('desc'))
                            orderDesc = true;
                //filtering
                //This assumes that the query param is formated like /services?query=color=red,number=2,vehicle=car
                //All query fields are ANDed together
                } else if(field.equals('query')){
                    String[] queries = params.get(query).split(',');
                    Map<String, String> m = new Map<String, String>();

                    for(Integer i = 0; i < queries.size(); i++){
                        String[] keyValue = queries[i].split('=');
                        m.put(keyValue[0], keyValue[1]);
                    }
                    
                    query += ' WHERE';
                    for(Integer i = 0; i < m.size(); i++){
                        Set <String> keySet = m.keySet();
                        List<String> queryFields = new List<String>(keySet); //this is dumb
                        if(validParams.contains(m.get(queryFields[i]))){
                            query += ' ' + queryFields[i] + ' = \'' + String.escapeSingleQuotes(m.get(queryFields[i])) + '\''; 
                            if(i < m.size()-1){
                                query += ' AND';
                            }
                        }
                    }
                }
            }
            if(sortBy && orderDesc){
                query += ' ORDER BY ' + String.escapeSingleQuotes(params.get('sort')) + ' DESC'; 
            } else if(sortBy && !orderDesc) {
                query += ' ORDER BY ' + String.escapeSingleQuotes(params.get('sort')) + ' ASC'; 
            }

            offset = lim*pageNum;
            query += ' LIMIT ' + lim + 'OFFSET ' + offset;
            system.debug(query);
        }
        //TODO: Watch out for little bobby tables
        List<cibus_service__c> services = Database.query(query);
        res.responseBody = Blob.valueOf(serializeServices(services));
        res.statusCode = 200;
        //TODO: error handling
    }
    
    /**
     * @description: Handels POST requests on /services/
     */
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
        res.responseBody = Blob.valueOf(serializeSingleService(service));
        System.debug(res.responseBody);
        
        //TODO: authenticate user
        //TODO: error handling
        //TODO: check for duplicates before insertion
        //TODO: send service to staging before insertion (same as above?)
    }

    /**
     * @description: Serializes a list of serivces to JSON.
     * @param: A List<cibus_service__c> of services to serialize.  
     * @return: A JSON String.
     */
    public static String serializeServices(List<cibus_service__c> services){
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        for(cibus_service__c s : services){
            Map<String, Object> m = new Map<String, Object>();
            for (SObjectField field : fieldMapping.keySet()) {
                String fieldName = fieldMapping.get(field);
                System.debug(fieldName + ': ' + s.get(field));
                m.put(fieldName, s.get(field));
                result.add(m);
            }
        }
        System.debug(JSON.serialize(result)); //result should be a collection of services
        return JSON.serialize(result);
    }

    /**
     * @description: Serializes a single to JSON.
     * @param: A List<cibus_service__c> of services to serialize.  
     * @return: A JSON String.
     */
    public static String serializeSingleService(cibus_service__c service){
        List<Map<String, Object>> result = new List<Map<String, Object>>();

            Map<String, Object> m = new Map<String, Object>();
            for (SObjectField field : fieldMapping.keySet()) {
                String fieldName = fieldMapping.get(field);
                System.debug(fieldName + ': ' + service.get(field));
                m.put(fieldName, service.get(field));
                result.add(m);
            }

        System.debug(JSON.serialize(result)); //result should be a singal services
        return JSON.serialize(result);
    }

    /**
     * @description: Fetches query parameters from a uri.
     * @param: String uri
     * @return Returns a map of fields to query and their values.
     */
    public static Map<String, String> getURLParams(String uri){
        Map<String, String> params = new Map<String, String>();        
        do{
            String nextParam = uri.substring(uri.indexOf('?')+1, uri.indexOf('&'));
            String[] keyValue = nextParam.split('=', 2);
            params.put(keyValue[0], keyValue[1]);
            if(uri.indexof('&') != -1){
                uri = uri.substring(uri.indexOf('&')+1);
            }
        }while(uri.indexOf('?') != -1);
        return params;
    }

}