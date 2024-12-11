@isTest
private class OrderQueryServiceTest {
    
    @testSetup
    static void setupData() {
        // Создаем Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
		Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'johndoec@example.com', Phone = '1234567890', AccountId = testAccount.Id);
        insert testContact;
        // Создаем Order
        Order testOrder = new Order(Name = 'Test Order', Status = 'Draft', AccountId = testAccount.Id, EffectiveDate = Date.today());
        insert testOrder;

        // Создаем Offer
        Offer__c testOffer1 = new Offer__c(Name = 'Test Offer 1', Status__c = 'New', Order__c = testOrder.Id);
        Offer__c testOffer2 = new Offer__c(Name = 'Test Offer 2', Status__c = 'New', Order__c = testOrder.Id);
        insert new List<Offer__c>{ testOffer1, testOffer2 };
    }

    @isTest
    static void testGetRelatedOffers() {
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        List<Offer__c> offers = OrderQueryService.getRelatedOffers(testOrder.Id);
        System.assertNotEquals(0, offers.size(), 'Related Offers should be returned');
    }


    @isTest
    static void testGetRelatedNotWinnerOffers() {
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        List<Offer__c> offers = OrderQueryService.getRelatedOffers(testOrder.Id);
        Offer__c excludedOffer = offers[0];

        List<Offer__c> notWinnerOffers = OrderQueryService.getRelatedNotWinnerOffers(excludedOffer.Id, testOrder.Id);
        System.assertEquals(offers.size() - 1, notWinnerOffers.size(), 'Not winner offers should be returned excluding the given offer');
    }
}