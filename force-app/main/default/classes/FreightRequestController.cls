public without sharing class FreightRequestController {

    @AuraEnabled
    public static void createFreightRequest(Map<String, String> requestData) {
		
        FreightRequestOrderData orderData = new FreightRequestOrderData(requestData);
        
        FreightRequestCustomerData customerData;
        
        User currentUser = QueryManager.getCurrentUserWithContactProfile();
        
        Contact contact;
        if(currentUser != null){
            contact = currentUser.Contact ?? null;
        }
        
        
        try{
            if(contact == null){
            	customerData = new FreightRequestCustomerData(requestData);
                if(customerData == null) throw new AuraException('Something went wrong with customer data');
        	}
        	else{
            	customerData = null;
        	}
        }
        catch(Exception e){
            throw new AuraException(e.getMessage());
        }
        
        
        if(orderData == null) throw new AuraException('Something went wrong with order data');
		
        if(contact==null) contact = getContactByEmailAndPhone(customerData);

        if (contact == null) contact = createContactFromLead(customerData);
        
        if (contact == null) contact = createContactFromAccount(customerData);
        
        if(contact == null) contact = createContactAndAccountReturningContact(customerData);
        
        if (contact == null) return;

        User salesManager = QueryManager.getSalesManager();
        try{
            createTask(contact, salesManager.Id, orderData.shippingName, orderData.orderDate);
        }
        catch(Exception e){
            throw new AuraException('error creating task: '+e.getMessage());
        }
        

        if (contact.AccountId == null) return;

        try{
        createOpportunity(contact, orderData);
        }
        catch(Exception e){
            throw new AuraException('error creating opportunity: '+e.getMessage());
        }
    }

    private static Contact getContactByEmailAndPhone(FreightRequestCustomerData request) {
        List<Contact> foundContacts = QueryManager.getContactsByEmailOrPhone(request.email, request.phone);
        if (foundContacts == null || foundContacts.isEmpty()) {
            return null;
        }
        return foundContacts[0];
    }

    private static Contact createContactFromLead(FreightRequestCustomerData request) {
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

    private static Contact createContactFromAccount(FreightRequestCustomerData request) {
        Account account;

        try {
            account = QueryManager.getAccountByEmail(request.companyEmail);
        } catch (Exception e) {
            account = null;
        }

        if (account == null) return null;
        
        return createContact(account, request);

    }
    private static Contact createContactAndAccountReturningContact(FreightRequestCustomerData request){
        System.debug('Name: '+request);
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
    private static Contact createContact(Account account, FreightRequestCustomerData request) {
        Contact contact = new Contact(
            AccountId = account.Id,
            FirstName = request.firstName,
            LastName = request.lastName,
            Email = request.email,
            Phone = request.phone,
            Language__c = 'EN'
        );
        insert contact;
        return contact;
    }

    private static void createTask(Contact contact, Id managerId, String subject, Date orderDate) {
        Task task = new Task(
            OwnerId = managerId,
            Subject = 'Freight Request: ' + subject,
            WhoId = contact.Id,
            WhatId = contact.AccountId,
            Status = 'New',
            Mobile_Phone__c = contact.Phone,
            ActivityDate = orderDate,
            Auto_Created__c = True
        );
        insert task;
    }

    private static void createOpportunity(Contact contact, FreightRequestOrderData request) {
        Integer numberOfDays = Date.daysInMonth(Date.today().year(), Date.today().month());
        Date lastDayOfMonth = Date.newInstance(Date.today().year(), Date.today().month(), numberOfDays);

        Opportunity opp = new Opportunity(
            Name = 'from Request:'+request.shippingName,
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