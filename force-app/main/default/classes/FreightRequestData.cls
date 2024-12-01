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
        this.firstName = validateString(data, 'firstName');
        this.lastName = validateString(data, 'lastName');
        this.email = validateString(data, 'email');
        this.phone = validateString(data, 'phone');
        this.companyName = validateString(data, 'companyName');
        this.companyType = validateString(data, 'accountType');
        this.companyEmail = validateString(data, 'companyEmail');
        this.companyPhone = validateString(data, 'companyPhone');
        this.shippingName = validateString(data, 'shippingName');
        this.cargoWeight = validateDecimal(data, 'cargoWeight');
        this.cargoType = validateString(data, 'cargoType');
        this.fromCity = validateString(data, 'fromCity');
        this.toCity = validateString(data, 'toCity');
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