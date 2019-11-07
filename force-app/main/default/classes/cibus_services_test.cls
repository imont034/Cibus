@isTest
public with sharing class cibus_services_test {
    public @IsTest
    static void testPost(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        //request.requestURI = 'https://yourInstance.salesforce.com/services/apexrest/V00/services/'
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"name": "Test Service",' 
                                            +'"alternate_name": "the best service",'
                                            +'"description": "string",'
                                            +'"url": "https://bar.com",'
                                            +'"email": "foo@bar.com",'
                                            +'"status": "string",'
                                            +'"interpretation_services": "string",'
                                            +'"application_process": "string",'
                                            +'"wait_time": "string",'
                                            +'"fees": null,'
                                            +'"accreditations": "string",'
                                            +'"licenses": "string"}');
        RestContext.request = request;
        response = RestContext.response;
        System.assertEquals(request.requestBody, response.responseBody);
        System.debug(RestContext.response);
    }
}
