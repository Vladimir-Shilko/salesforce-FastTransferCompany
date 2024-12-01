@isTest
private class OrderServiceTest {

    @isTest
    static void testGetOpenOrders_ValidAccount() {
    
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Order testOrder = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            EndDate = Date.today().addDays(5),
            Status = 'Draft'
        );
        insert testOrder;
      
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/orders/' + testAccount.Id;
        RestContext.request = req;

        OrderService.OrderResponse response = OrderService.getOpenOrders();

        System.assertEquals('success', response.status);
        System.assertEquals(testAccount.Id, response.clientId);
        System.assertNotEquals(null, response.orders);
        System.assertEquals(1, response.orders.size());
    }

    @isTest(SeeAllData=true)
    static void testGetOpenOrders_InvalidClientId() {
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/orders';
        RestContext.request = req;

        OrderService.OrderResponse response = OrderService.getOpenOrders();

        System.assertEquals('error', response.status);
        System.assertEquals('Wrong parameter.', response.error);
    }

    @isTest
    static void testGetOpenOrders_ClientNotFound() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/orders/invalidClientId';
        RestContext.request = req;

        OrderService.OrderResponse response = OrderService.getOpenOrders();

        System.assertEquals('error', response.status);
        System.assertEquals('Client not found.', response.error);
    }

   
}