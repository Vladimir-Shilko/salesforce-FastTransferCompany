@isTest
private class PhoneCountryFutureCalloutTest {

    @isTest
    static void testMakeCallout() {
       
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = 'Test', LastName = 'User', Phone = '+375 555-555-5555'),
            new Contact(FirstName = 'Sample', LastName = 'User', Phone = '+7 20 7946 0958')
        };
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
      
        Test.startTest();
        insert contacts;
        Test.stopTest();

        List<Contact> updatedContacts = [SELECT Id, Country_from_Phone__c FROM Contact WHERE Id IN :contacts];

        System.assertEquals('Belarus', updatedContacts[0].Country_from_Phone__c);
        System.assertEquals('Russia', updatedContacts[1].Country_from_Phone__c);
    }

   
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);

          
            if (req.getEndpoint().contains('375')) {
                response.setBody('[{"name": "Belarus"}]');
            } else if (req.getEndpoint().contains('48')) {
                response.setBody('[{"name": "United Kingdom"}]');
            }
            else if (req.getEndpoint().contains('7')) {
                response.setBody('[{"name": "Russia"}]');
            }else {
                response.setBody('[]'); 
            }
            return response;
        }
    }
}