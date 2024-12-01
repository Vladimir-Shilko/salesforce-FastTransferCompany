public class LeadTriggerHandler extends TriggerHandler{
    
    protected override void afterInsert() {
        PhoneCountryService.updateCountryFromPhone(this.newList, Lead.Phone, Lead.Country_from_Phone__c);
    }
   
}