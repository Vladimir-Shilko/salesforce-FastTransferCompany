public class ContactTriggerHandler extends TriggerHandler{
    
    protected override void afterInsert() {
        PhoneCountryService.updateCountryFromPhone(this.newList, Contact.Phone, Contact.Country_from_Phone__c);
    }
   
}