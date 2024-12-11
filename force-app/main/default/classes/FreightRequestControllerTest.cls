@isTest
public class FreightRequestControllerTest {

    @testSetup
    static void setupTestData() {
        // Create a test Sales Manager user
        Profile salesManagerProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Manager' LIMIT 1];
        User salesManager = new User(
            Username = 'salesmanagerrr@test.com',
            FirstName = 'Sales',
            LastName = 'Manager',
            Email = 'salesmanagerrr@test.com',
            Alias = 'salesmgr',
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = salesManagerProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert salesManager;

       
    }

    @isTest
    static void testCreateFreightRequestWithExistingContact() {
        
        Account account = new Account(Name = 'Test Account', Email__c = 'contacttt@test.com');
        insert account;
        Contact existingContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'contacttt@test.com',
            MobilePhone = '+375-12-3456789',
            AccountId = account.Id
        );
        insert existingContact;

       
        Map<String, String> requestData = new Map<String, String>{
            'firstName' => 'Jane',
            'lastName' => 'Doe',
            'companyName' => 'Test Company',
            'accountType' => 'special',
            'companyEmail' => 'test@mail.ci',
            'companyPhone' => '+375-30-3933243',
            'email' => 'contacttt@test.com',
            'phone' => '+375-12-3456789',
            'shippingName' => 'Shipping Test',
            'cargoWeight' => '1000',
            'cargoType' => 'Food',
            'toCity' => 'Minsk',
            'fromCity' => 'Brest'
        };

      
        Test.startTest();
        FreightRequestController.createFreightRequest(requestData);
        Test.stopTest();

        Task task = [SELECT Id, Subject, WhoId FROM Task WHERE WhoId = :existingContact.Id LIMIT 1];
        System.assertEquals('Freight Request: Shipping Test', task.Subject);
    }

    @isTest
    static void testCreateFreightRequestWithLead() {
       
        Lead testLead = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe',
            Company = 'Test Company',
            Email = 'leaddd@test.com',
            Phone = '+375-44-1234567',
            Status = 'Open'
        );
        insert testLead;

       
        Map<String, String> requestData = new Map<String, String>{
            'firstName' => 'Jane',
            'lastName' => 'Doe',
            'companyName' => 'Test Company',
            'accountType' => 'special',
            'companyEmail' => 'test@mail.ci',
            'companyPhone' => '+375-30-3933243',
            'email' => 'leaddd@test.com',
            'phone' => '+375-44-1234567',
            'shippingName' => 'Lead Shipping Test',
            'cargoWeight' => '2500',
            'cargoType' => 'Animals',
            'toCity' => 'Orsha',
            'fromCity' => 'Pinsk'
        };

       	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        FreightRequestController.createFreightRequest(requestData);
        Test.stopTest();

       
        Contact convertedContact = [SELECT Id, AccountId FROM Contact WHERE Email = 'leaddd@test.com' LIMIT 1];
        System.assertNotEquals(null, convertedContact);
        
        Task task = [SELECT Id, Subject, WhoId FROM Task WHERE WhoId = :convertedContact.Id LIMIT 1];
        System.assertEquals('Freight Request: Lead Shipping Test', task.Subject);
    }

    @isTest
    static void testCreateFreightRequestWithNewAccountAndContact() {
        
        Map<String, String> requestData = new Map<String, String>{
            
            'email' => 'newcontacttt@test.com',
            'phone' => '+375-44-7654321',
            'shippingName' => 'New Account Shipping',
            'firstName' => 'Alice',
            'lastName' => 'Johnson',
            'companyName' => 'New Company',
            'accountType' => 'Customer',
            'cargoWeight' => '500',
            'cargoType' => 'Technics',
            'toCity' => 'Vitebsk',
            'fromCity' => 'Salihorsk',
            'companyPhone' => '+375-44-7544321',
            'companyEmail' => 'newaccounttt@test.com'
        };

      	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        FreightRequestController.createFreightRequest(requestData);
        Test.stopTest();

       
        Account newAccount = [SELECT Id, Name FROM Account WHERE Email__c = 'newaccounttt@test.com' LIMIT 1];
        System.assertEquals('New Company', newAccount.Name);

        Contact newContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email = 'newcontacttt@test.com' LIMIT 1];
        System.assertEquals('Alice', newContact.FirstName);
        System.assertEquals('Johnson', newContact.LastName);

        Task task = [SELECT Id, Subject, WhoId FROM Task WHERE WhoId = :newContact.Id LIMIT 1];
        System.assertEquals('Freight Request: New Account Shipping', task.Subject);

     
        Opportunity newOpportunity = [SELECT Id, AccountId, StageName, Cargo_type__c FROM Opportunity WHERE AccountId = :newAccount.Id LIMIT 1];
        System.assertEquals('New', newOpportunity.StageName);
        System.assertEquals('Technics', newOpportunity.Cargo_type__c);
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