public without sharing class FreightRequestOrderData extends FreightRequestData{
   
    public String shippingName { get; private set; }
    public Decimal cargoWeight { get; private set; }
    public String cargoType { get; private set; }
    public String fromCity { get; private set; }
    public String toCity { get; private set; }

    public FreightRequestOrderData(Map<String, String> data) {
        fill(data);
    }
    
    protected override void fill(Map<String, String> data) {
        
        try{
            this.shippingName = validateString(data, 'shippingName');
            this.cargoWeight = validateDecimal(data, 'cargoWeight');
            this.cargoType = validateString(data, 'cargoType');
            this.fromCity = validateString(data, 'fromCity');
            this.toCity = validateString(data, 'toCity');
        } catch (Exception e) {
          
            throw new AuraException('Error fetching current user data: ' + e.getMessage());
        }
    }

    
}