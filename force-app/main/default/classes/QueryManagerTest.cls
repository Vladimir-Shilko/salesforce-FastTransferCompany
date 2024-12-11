@isTest
private class QueryManagerTest {
    
    @testSetup
    static void setupData() {
        Profile profilePortal  = [SELECT Id FROM Profile WHERE Name = 'FasTTransfer Client' LIMIT 1];
        UserRole srole = [SELECT Id from UserRole Where DeveloperName = 'CEO' LIMIT 1];
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Sales Manager' LIMIT 1];
        User salesManager = new User(
            Username = 'salesmanagerrr@test.com',
            FirstName = 'Sales',
            LastName = 'Managerrr',
            Email = 'salesmanagerrr@test.com',
            Alias = 'sman',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            LanguageLocaleKey = 'en_US',
            UserRoleId = srole.Id
        );
        insert salesManager;
      
        Account testAccount = new Account(Name = 'Test Account');
        System.runAs(salesManager){
            insert testAccount;}
		
        
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'johndoec@example.com', Phone = '1234567890', AccountId = testAccount.Id);
        System.runAs(salesManager){
            insert testContact;}
		
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            System.debug('prof: '+profilePortal.Id);
            User testUser = new User(
            FirstName = 'Testc',
            LastName = 'Userc',
            Username = 'testuserc@example.com',
            Email = 'testuserc@example.com',
            Alias = 'tuser',
            CommunityNickname = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            //ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            ContactId = testContact.Id,
            ProfileId = profilePortal.Id
            //UserRoleId = srole.Id
         );
        insert testUser;
        }
        
		
       
        Order testOrder = new Order(Name = 'Test Order', Status = 'Draft', AccountId = testAccount.Id, ShipToContactId = testContact.Id, EffectiveDate = Date.today());
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert testOrder;}
		
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        
        Offer__c testOffer = new Offer__c(Name = 'Test Offer', Max_Price__c = 1000, Min_Price__c = 500, Order__c = testOrder.Id, Status__c = 'New');
            insert testOffer;}

       
        Lead testLead = new Lead(FirstName = 'Lead', LastName = 'Test', Email = 'leadc@example.com', Phone = '9876543210', Company = 'Test Company');
        System.runAs(salesManager){
            insert testLead;}

        
    }

    @isTest
    static void testGetOfferById() {
        Offer__c testOffer = [SELECT Id FROM Offer__c LIMIT 1];
        Offer__c result = QueryManager.getOfferById(testOffer.Id);
        System.assertNotEquals(null, result, 'Offer__c should be returned');
        System.assertEquals(testOffer.Id, result.Id, 'Returned Id should match the input Id');
    }

    @isTest
    static void testGetOrderById() {
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        Order result = QueryManager.getOrderById(testOrder.Id);
        System.assertNotEquals(null, result, 'Order should be returned');
        System.assertEquals(testOrder.Id, result.Id, 'Returned Id should match the input Id');
    }

    @isTest
    static void testGetCurrentUser() {
        User currentUser = QueryManager.getCurrentUser();
        System.assertNotEquals(null, currentUser, 'Current user should be returned');
        System.assertEquals(UserInfo.getUserId(), currentUser.Id, 'Returned user Id should match the current user Id');
    }

    @isTest
    static void testGetUserByContactId() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        User result = QueryManager.getUserByContactId(testContact.Id);
        System.assertNotEquals(null, result, 'User should be returned');
        System.assertEquals(testContact.Id, result.ContactId, 'Returned ContactId should match the input ContactId');
    }

    @isTest
    static void testGetAccountByUser() {
        User testUser = [SELECT Id FROM User LIMIT 1];
        Account result = QueryManager.getAccountByUser(testUser.Id);
        System.assertNotEquals(null, result, 'Account should be returned');
    }

    @isTest
    static void testGetContactsByEmailOrPhone() {
        List<Contact> contacts = QueryManager.getContactsByEmailOrPhone('johndoec@example.com', '1234567890');
        System.assertNotEquals(0, contacts.size(), 'Contacts should be returned');
    }

    @isTest
    static void testGetLeadsByEmailOrPhone() {
        List<Lead> leads = QueryManager.getLeadsByEmailOrPhone('leadc@example.com', '9876543210');
        System.assertNotEquals(0, leads.size(), 'Leads should be returned');
    }

    @isTest
    static void testGetSalesManager() {
        User salesManager = QueryManager.getSalesManager();
        System.assertNotEquals(null, salesManager, 'Sales Manager user should be returned');
    }

    @isTest
    static void testGetAccountByEmail() {
        Account result = QueryManager.getAccountByEmail('johndoec@example.com');
        System.assertNotEquals(null, result, 'Account should be returned');
    }

    @isTest
    static void testGetConvertedLeadStatus() {
        LeadStatus status = QueryManager.getConvertedLeadStatus();
        System.assertNotEquals(null, status, 'Converted Lead Status should be returned');
        System.assertEquals(true, status.IsConverted, 'Lead Status should be marked as converted');
    }
}