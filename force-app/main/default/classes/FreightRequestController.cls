public without sharing class FreightRequestController {

    @AuraEnabled
    public static void createFreightRequest(Map<String, String> requestData) {

        FreightRequestData request = new FreightRequestData(requestData);

        Contact contact = getContactByEmailAndPhone(request);

        if (contact == null) {
            contact = createContactFromLead(request);
        }

        if (contact == null) {
            contact = createContactFromAccount(request);
        }

        if(contact == null){
            contact = createContactAndAccountReturningContact(request);
        }
        if (contact == null) return;

        User salesManager = QueryManager.getSalesManager();
        createTask(contact.Id, salesManager.Id, request.shippingName);

        if (contact.AccountId == null) return;

        createOpportunity(contact, request);
    }

    private static Contact getContactByEmailAndPhone(FreightRequestData request) {
        List<Contact> foundContacts = QueryManager.getContactsByEmailOrPhone(request.email, request.phone);
        if (foundContacts == null || foundContacts.isEmpty()) {
            return null;
        }
        return foundContacts[0];
    }

    private static Contact createContactFromLead(FreightRequestData request) {
        List<Lead> foundLeads = QueryManager.getLeadsByEmailOrPhone(request.email, request.phone);

        if (foundLeads == null || foundLeads.isEmpty()) return null;
        
        Lead lead = foundLeads[0];

        Database.LeadConvert leadConvert = new Database.LeadConvert();
        leadConvert.setLeadId(lead.Id);
        LeadStatus convertStatus = QueryManager.getConvertedLeadStatus();
        leadConvert.setConvertedStatus(convertStatus.ApiName);

        Database.LeadConvertResult convertResult = Database.convertLead(leadConvert);

        Contact contact = QueryManager.getContactById(convertResult.getContactId());
        return contact;
        
    }

    private static Contact createContactFromAccount(FreightRequestData request) {
        Account account;

        try {
            account = QueryManager.getAccountByEmail(request.companyEmail);
        } catch (Exception e) {
            account = null;
        }

        if (account == null) return null;
        
        return createContact(account, request);

    }
    private static Contact createContactAndAccountReturningContact(FreightRequestData request){
        Account account = new Account(
            Name = request.companyName,
            Phone = request.companyPhone,
            Email__c = request.companyEmail,
            Type = request.companyType,
            OwnerId = QueryManager.getSalesManager().Id
        );
        insert account;

        return createContact(account, request);
    }
    private static Contact createContact(Account account, FreightRequestData request) {
        Contact contact = new Contact(
            AccountId = account.Id,
            FirstName = request.firstName,
            LastName = request.lastName,
            Email = request.email,
            MobilePhone = request.phone,
            Language__c = 'EN'
        );
        insert contact;
        return contact;
    }

    private static void createTask(Id contactId, Id managerId, String subject) {
        Task task = new Task(
            OwnerId = managerId,
            Subject = 'Freight Request: ' + subject,
            WhoId = contactId,
            Status = 'New'
        );
        insert task;
    }

    private static void createOpportunity(Contact contact, FreightRequestData request) {
        Integer numberOfDays = Date.daysInMonth(Date.today().year(), Date.today().month());
        Date lastDayOfMonth = Date.newInstance(Date.today().year(), Date.today().month(), numberOfDays);

        Opportunity opp = new Opportunity(
            Name = 'from Request:'+request.cargoType,
            AccountId = contact.AccountId,
            Amount = 0,
            StageName = 'New',
            CloseDate = lastDayOfMonth,
            Probability = 10,
            Shipping_Name__c = request.shippingName,
            Cargo_weight__c = request.cargoWeight,
            Cargo_type__c = request.cargoType,
            To_City__c = request.toCity,
            From_City__c = request.fromCity
        );
        insert opp;
    }
}