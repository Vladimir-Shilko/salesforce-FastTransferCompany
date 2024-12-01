public without sharing class OrderQueryService {

    public static List<Offer__c> getRelatedOffers(Id orderId) {
        return [
            SELECT Id, Name, Max_Price__c, Min_Price__c, Closed_Date__c, Shipping_Company_Owner__r.Name
            FROM Offer__c
            WHERE Order__c = :orderId AND Status__c = 'New'
        ];
    }

    public static User getShippingCompanyUser(Id contactId) {
        return [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
    }

    public static List<Offer__c> getRelatedNotWinnerOffers(Id excludedOfferId, Id orderId) {
        return [SELECT Id FROM Offer__c WHERE Id != :excludedOfferId AND Order__c = :orderId AND Status__c = 'New'];
    }

}