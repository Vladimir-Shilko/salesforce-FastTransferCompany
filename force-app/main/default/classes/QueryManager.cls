public without sharing class QueryManager {
    public static Offer__c getOfferById(Id offerId) {
        return [
            SELECT Id, Name, Max_Price__c, Min_Price__c, Closed_Date__c, Special_Terms__c, Shipping_Company_Owner__r.ContactId
            FROM Offer__c
            WHERE Id = :offerId
            LIMIT 1
        ] ?? null;
    }

    public static Order getOrderById(Id orderId) {
        return [
            SELECT Id, ShipToContactId, OpportunityId FROM Order WHERE Id = :orderId LIMIT 1
        ] ?? null;
    }

    public static User getCurrentUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()] ?? null;
    }
    
    public static User getCurrentUserWithContactProfile() {
        return [
                SELECT Id, ContactId, Contact.AccountId, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Phone, Contact.Account.Name, Contact.Account.Type, Contact.Account.Email__c, Contact.Account.Phone
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ] ?? null;
    }
    
    public static User getUserByContactId(Id contactId) {
        return [SELECT Id, ContactId FROM User WHERE ContactId = :contactId LIMIT 1] ?? null;
    }

    public static Account getAccountByUser(Id userId) {
        //Contact contact = [SELECT Id, AccountId FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id = :userId)] ?? null;
        //if(contact == null) return null;
        
        //return contact.Account;
        return [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM User WHERE Id = :userId) LIMIT 1];
    }

    public static Opportunity getOpportunityById(Id opportunityId) {
        return [SELECT Id FROM Opportunity WHERE Id = :opportunityId LIMIT 1] ?? null;
    }

    public static List<Contact> getContactsByEmailOrPhone(String email, String phone) {
        return [
            SELECT Id, AccountId
            FROM Contact
            WHERE Email = :email OR Phone = :phone
            LIMIT 1
        ];
    }

    public static List<Lead> getLeadsByEmailOrPhone(String email, String phone) {
        return [
            SELECT Id
            FROM Lead
            WHERE Email = :email OR Phone = :phone
            LIMIT 1
        ];
    }

    public static User getSalesManager() {
        return [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'Sales Manager'
            LIMIT 1
        ] ?? null;
    }

    public static Account getAccountByEmail(String email) {
        return [
            SELECT Id
            FROM Account
            WHERE Email__c = :email
            LIMIT 1
        ] ?? null;
    }

    public static LeadStatus getConvertedLeadStatus() {
        return [
            SELECT Id, ApiName, IsConverted
            FROM LeadStatus
            WHERE IsConverted = true
            LIMIT 1
        ] ?? null;
    }

    public static Contact getContactById(Id contactId) {
        return [
            SELECT Id, AccountId
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ] ?? null;
    }
}