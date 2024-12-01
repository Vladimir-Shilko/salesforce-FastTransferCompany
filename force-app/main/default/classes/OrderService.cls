@RestResource(urlMapping='/orders/*')
global with sharing class OrderService {

    @HttpGet
    global static OrderResponse getOpenOrders() {
        RestRequest req = RestContext.request;
        String clientId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
		
        if (String.isEmpty(clientId) || clientId=='orders') {
            return new OrderResponse(null, 'error', 'Wrong parameter.', null);
        }
        SObject client = null;
        try{
        	client = getClientById(clientId);
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        if (client == null) {
            return new OrderResponse(clientId, 'error', 'Client not found.', null);
        }

        List<Order> openOrders = getOpenOrdersForClient(clientId, client.getSObjectType());

        return new OrderResponse(clientId, 'success', null, openOrders);
    }

    private static SObject getClientById(String clientId) {
       
        List<Account> accs = [SELECT Id FROM Account WHERE Id = :clientId ];
        if (accs.size() != 0) {
            return accs[0];
        }

        List<Contact> cons = [SELECT Id FROM Contact WHERE Id = :clientId LIMIT 1];
        return cons[0];
    }

    private static List<Order> getOpenOrdersForClient(String clientId, Schema.SObjectType clientType) {

        String query = 'SELECT Id, EffectiveDate, EndDate, SLA_Offers_Date__c, Status, Cargo_type__c, Cargo_weight__c, From_City__c, To_City__c FROM Order WHERE ' + (clientType == Account.SObjectType ? 'AccountId' : 'ShipToContactId') + ' = :clientId AND Status NOT IN (\'Finished\', \'Cancelled\')';
        return Database.query(query);
    }

    global class OrderResponse {
        public String clientId;
        public String status;
        public String error;
        public List<Order> orders;

        public OrderResponse(String clientId, String status, String error, List<Order> orders) {
            this.clientId = clientId;
            this.status = status;
            this.error = error;
            this.orders = orders;
        }
    }
}