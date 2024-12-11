public without sharing class FreightRequestCustomerData extends FreightRequestData{
	
    public String firstName { get; private set; }
    public String lastName { get; private set; }
    public String email { get; private set; }
    public String phone { get; private set; }
    public String companyName { get; private set; }
    public String companyType { get; private set; }
    public String companyEmail { get; private set; }
    public String companyPhone { get; private set; }
    
    public FreightRequestCustomerData(Map<String, String> data) {
        fill(data);
    }
    
    protected override void fill(Map<String, String> userData) {
        
        try{
            this.firstName = validateString(userData, 'firstName');
            this.lastName = validateString(userData, 'lastName');
            this.email = validateString(userData, 'email');
            this.phone = validateString(userData, 'phone');
            this.companyName = validateString(userData, 'companyName');
            this.companyType = validateString(userData, 'accountType');
            this.companyEmail = validateString(userData, 'companyEmail');
            this.companyPhone = validateString(userData, 'companyPhone');
        } catch (Exception e) {
            
            throw new AuraException('Error fetching user data: ' + e.getMessage());
        }
    }
}