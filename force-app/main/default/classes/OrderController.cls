public without sharing class OrderController {

    @AuraEnabled(cacheable=true)
    public static List<Offer__c> getRelatedOffers(Id orderId) {
        return OrderQueryService.getRelatedOffers(orderId);
    }

    @AuraEnabled
    public static void createContract(Id offerId, Id orderId) {
        validateId(offerId, 'offer id');
        validateId(orderId, 'order id');
        
        Offer__c selectedOffer = QueryManager.getOfferById(offerId);
        validateSingleRecord(selectedOffer, 'selectedOffer');
        
        Order currentOrder = QueryManager.getOrderById(orderId);
        validateSingleRecord(currentOrder, 'currentOrder');
        
        User salesManager = QueryManager.getCurrentUser();
        validateSingleRecord(salesManager, 'Sales manager');
        
        User clientUser = QueryManager.getUserByContactId(currentOrder.ShipToContactId);
        validateSingleRecord(clientUser, 'selectedOffer');
        
        Account account = QueryManager.getAccountByUser(clientUser.Id);
        validateSingleRecord(account, 'account');
        
        User shippingCompanyUser = OrderQueryService.getShippingCompanyUser(selectedOffer.Shipping_Company_Owner__r.ContactId);
        validateSingleRecord(shippingCompanyUser, 'shipping company user');

        Date d = Date.today();

        Contract contract = new Contract(
            AccountId = account.Id,
            OwnerId = salesManager.Id,
            Status = 'Draft',
            SpecialTerms = selectedOffer.Special_Terms__c,
            CustomerSignedDate = selectedOffer.Closed_Date__c.date(),
            Price__c = (selectedOffer.Max_Price__c + selectedOffer.Min_Price__c) / 2,
            User__c = clientUser.Id,
            Order__c = orderId,
            Shipping_CompanyUser__c = shippingCompanyUser.Id,
            StartDate = d
        );

        insert contract;

     
        selectedOffer.Status__c = 'Winner';
        update selectedOffer;

        List<Offer__c> loserOffers = OrderQueryService.getRelatedNotWinnerOffers(offerId, orderId);
        
        if(loserOffers != null && !loserOffers.isEmpty()){
            for (Offer__c loser : loserOffers) {
            	loser.Status__c = 'Loser';
        	}
        	update loserOffers;
        }
        

        Opportunity opp = QueryManager.getOpportunityById(currentOrder.OpportunityId);
        if(opp == null) return;
        opp.StageName = 'Price Quote';
        update opp;
    }

    public static void validateId(Id inputId, String parameterName) {
        if (String.isBlank(inputId)) {
            throw new IllegalArgumentException('The parameter ' + parameterName + ' is required and cannot be null or empty.');
        }
    }

    public static void validateListNotEmpty(List<SObject> records, String objectName) {
        if (records == null || records.isEmpty()) {
            throw new QueryException(objectName + ' records not found.');
        }
    }

    public static void validateSingleRecord(SObject record, String objectName) {
        if (record == null) {
            throw new QueryException('The required ' + objectName + ' record was not found.');
        }
    }
}