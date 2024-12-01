public without sharing class FreightRequestData {
    public String firstName { get; private set; }
    public String lastName { get; private set; }
    public String email { get; private set; }
    public String phone { get; private set; }
    public String companyName { get; private set; }
    public String companyType { get; private set; }
    public String companyEmail { get; private set; }
    public String companyPhone { get; private set; }
    public String shippingName { get; private set; }
    public Decimal cargoWeight { get; private set; }
    public String cargoType { get; private set; }
    public String fromCity { get; private set; }
    public String toCity { get; private set; }

    public FreightRequestData(Map<String, String> data) {

        Map<String, String> currentUserData = getCurrentUserData();
        if(currentUserData != null){
            fillUserData(currentUserData);
        }
        else{
            fillUserData(data);
        }
        
        fillOrderData(data);
    }
    private void fillOrderData(Map<String, String> data){
        this.shippingName = validateString(data, 'shippingName');
        this.cargoWeight = validateDecimal(data, 'cargoWeight');
        this.cargoType = validateString(data, 'cargoType');
        this.fromCity = validateString(data, 'fromCity');
        this.toCity = validateString(data, 'toCity');
    }
    private void fillUserData(Map<String, String> userData){
        this.firstName = validateString(userData, 'firstName');
        this.lastName = validateString(userData, 'lastName');
        this.email = validateString(userData, 'email');
        this.phone = validateString(userData, 'phone');
        this.companyName = validateString(userData, 'companyName');
        this.companyType = validateString(userData, 'accountType');
        this.companyEmail = validateString(userData, 'companyEmail');
        this.companyPhone = validateString(userData, 'companyPhone');
    }
    private Map<String, String> getCurrentUserData() {

        Map<String, String> userData = new Map<String, String>();

        try {
            User currentUser = [
                SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Phone, Contact.Account.Name, Contact.Account.Type, Contact.Account.Email__c, Contact.Account.Phone
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ] ?? null;

            if(currentUser == null) return null;

            if(currentUser.Contact == null) return null;

            if(currentUser.Contact.Account == null) return null;

            
            userData.put('firstName', currentUser.Contact.FirstName);
            userData.put('lastName', currentUser.Contact.LastName);
            userData.put('email', currentUser.Contact.Email);
            userData.put('phone', currentUser.Contact.Phone);

            
            userData.put('companyName', currentUser.Contact.Account.Name);
            userData.put('accountType', currentUser.Contact.Account.Type);
            userData.put('companyEmail', currentUser.Contact.Account.Email__c);
            userData.put('companyPhone', currentUser.Contact.Account.Phone);
    
        } catch (Exception e) {
            
            throw new AuraException('Error fetching current user data: ' + e.getMessage());
        }

        return userData;
    }

    private String validateString(Map<String, String> data, String key) {
        if (!data.containsKey(key) || String.isBlank(data.get(key))) {
            throw new IllegalArgumentException('Missing or invalid value for required field: ' + key);
        }
        return data.get(key);
    }

    private Decimal validateDecimal(Map<String, String> data, String key) {
        if (!data.containsKey(key) || String.isBlank(data.get(key))) {
            throw new IllegalArgumentException('Missing or invalid value for required field: ' + key);
        }
        try {
            return Decimal.valueOf(data.get(key));
        } catch (Exception e) {
            throw new IllegalArgumentException('Invalid decimal value for field: ' + key);
        }
    }
}